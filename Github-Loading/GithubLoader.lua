---@class Option
---@field Name string
---@field Url string
local Option = {}
Option.__index = Option

---@param name string
---@param url string
---@return Option
function Option.new(name, url)
    return setmetatable({
        Name = name,
        Url = url
    }, Option)
end

---@param extended boolean
function Option:Print(extended)
    ---@type string
    local output = self.Name
    if extended == true then
        output = output .. " -> " .. self.Url
    end
    print(output)
end

-- ########## Option ########## --

---@class GithubLoader
---@field private GithubLoaderBaseUrl string
---@field private GithubLoaderBasePath string
---@field private options Array<Option>
---@field private currentOption Option
---@field private mainProgramModule Main
---@field private forceDownloadLoaderFiles boolean
---@field private entities Entities
---@field private packageLoader PackageLoader
---@field private internetCard table
---@field private logger Logger
local GithubLoader = {}
GithubLoader.__index = GithubLoader

local GithubLoaderFiles = {
    "Github-Loading",
    {
        "shared",
        { "Entities.lua" },
        { "Logger.lua" },
        { "PackageLoader.lua" },
        { "Utils.lua" }
    },
    { "Options.lua" }
}

---@private
---@param url string
---@param path string
---@param forceDownload boolean
---@return boolean
function GithubLoader:internalDownload(url, path, forceDownload)
    if forceDownload == nil then forceDownload = false end
    if filesystem.exists(path) and not forceDownload then
        return true
    end
    if self.logger ~= nil then
        self.logger:LogTrace("downloading '" .. path .. "' from: '" .. url .. "'...")
    end
    local req = self.internetCard:request(url, "GET", "")
    local code, data = req:await()
    if code ~= 200 or data == nil then return false end
    local file = filesystem.open(path, "w")
    file:write(data)
    file:close()
    if self.logger ~= nil then
        self.logger:LogTrace("downloaded '" .. path .. "' from: '" .. url .. "'")
    end
    return true
end

---@private
---@param parentPath string
---@param entry table | string
---@return boolean
function GithubLoader:doEntry(parentPath, entry)
    if #entry == 1 then
        ---@cast entry string
        return self:doFile(parentPath, entry)
    else
        ---@cast entry table
        return self:doFolder(parentPath, entry)
    end
end

---@private
---@param parentPath string
---@param file string
---@return boolean
function GithubLoader:doFile(parentPath, file)
    local path = filesystem.combinePaths(parentPath, file[1])
    return self:internalDownload(self.GithubLoaderBaseUrl .. path, path, self.forceDownloadLoaderFiles)
end

---@private
---@param parentPath string
---@param folder table
---@return boolean
function GithubLoader:doFolder(parentPath, folder)
    local path = filesystem.combinePaths(parentPath, folder[1])
    filesystem.createDir(path)
    local successes = {}
    for index, child in pairs(folder) do
        if index ~= 1 then
            local success = self:doEntry(path, child)
            table.insert(successes, success)
        end
    end
    for _, success in ipairs(successes) do
        if not success then
            return false
        end
    end
    return true
end

---@private
---@return boolean
function GithubLoader:downloadLoaderFiles()
    return self:doFolder("/", GithubLoaderFiles)
end

-- ########## download Loader Files ########## --

---@private
---@param fileName string
---@return string | nil
function GithubLoader:searchForFile(fileName)
    local funcs = {
        GithubLoaderBasePath = self.GithubLoaderBasePath
    }

    ---@param parentPath string
    ---@param entry table | string
    ---@param fileName string
    ---@return string | nil
    function funcs:doEntry(parentPath, entry, fileName)
        if #entry == 1 then
            ---@cast entry string
            return self:doFile(parentPath, entry, fileName)
        else
            ---@cast entry table
            return self:doFolder(parentPath, entry, fileName)
        end
    end

    ---@param parentPath string
    ---@param file string
    ---@param fileName string
    ---@return string | nil
    function funcs:doFile(parentPath, file, fileName)
        if file[1] ~= fileName then
            return nil
        end
        local path = filesystem.combinePaths(parentPath, file[1])
        return filesystem.combinePaths(self.GithubLoaderBasePath, path)
    end

    ---@param parentPath string
    ---@param folder table
    ---@param fileName string
    ---@return string | nil
    function funcs:doFolder(parentPath, folder, fileName)
        local path = filesystem.combinePaths(parentPath, folder[1])
        for index, child in pairs(folder) do
            if index ~= 1 then
                local success = self:doEntry(path, child, fileName)
                if success then
                    return success
                end
            end
        end
    end

    return funcs:doEntry("/", GithubLoaderFiles, fileName)
end

---@private
---@return boolean
function GithubLoader:loadUtils()
    local path = self:searchForFile("Utils.lua")
    filesystem.doFile(path)
    return true
end

---@private
---@param logLevel integer
---@return boolean
function GithubLoader:loadLogger(logLevel)
    if not filesystem.exists("logs") then filesystem.createDir("logs") end
    local path = self:searchForFile("Logger.lua")
    local logger = filesystem.doFile(path)
    self.logger = logger.new("Loader", logLevel)
    self.logger:ClearLog(true)
    return true
end

---@private
---@return boolean
function GithubLoader:loadEntites()
    local path = self:searchForFile("Entities.lua")
    self.entitites = filesystem.doFile(path)
    return true
end

---@private
---@return boolean
function GithubLoader:loadPackageLoader()
    local baseUrl = self.GithubLoaderBaseUrl .. "/Packages"
    local basePath = filesystem.combinePaths(self.GithubLoaderBasePath, "Packages")
    if not filesystem.exists(basePath) then
        filesystem.createDir(basePath)
    end
    local path = self:searchForFile("PackageLoader.lua")
    local packageLoader = filesystem.doFile(path)
    local logger = self.logger:create("PackageLoader")
    self.packageLoader = packageLoader.new(baseUrl, basePath, logger, self.internetCard)
    return true
end

---@private
---@param logLevel integer
function GithubLoader:loadLoaderFiles(logLevel)
    if not self:downloadLoaderFiles() then
        computer.panic("Unable to download loader files")
    elseif logLevel <= 1 then
        print("downloaded loader files")
    end

    if not self:loadUtils() then
        computer.panic("Unable to load Utils")
    elseif logLevel <= 1 then
        print("loaded Utils")
    end
    if not self:loadLogger(logLevel) then
        computer.panic("Unable to load Logger")
    elseif logLevel <= 1 then
        print("loaded Logger")
    end
    if not self:loadEntites() then
        computer.panic("Unable to load Entites")
    elseif logLevel <= 1 then
        print("loaded Entites")
    end
    if not self:loadPackageLoader() then
        computer.panic("Unable to load Package Loader")
    elseif logLevel <= 1 then
        print("loaded Package Loader")
    end
    if self.forceDownloadLoaderFiles then
        self.logger:LogInfo("loaded Loader Files")
    end
end

-- ########## loading Loader Files ########## --

---@private
---@return boolean
function GithubLoader:loadOptions()
    if not self.options == nil then return true end
    self.logger:LogTrace("loading options...")
    local path = self:searchForFile("Options.lua")
    for name, url in pairs(filesystem.doFile(path)) do
        ---@cast name string
        ---@cast url string
        table.insert(self.options, Option.new(name, url))
    end
    self.logger:LogTrace("loaded options")
    return true
end

---@private
---@param optionName string
---@return boolean
function GithubLoader:loadOption(optionName)
    if not self:loadOptions() then return false end
    self.logger:LogTrace("loading option: " .. optionName)
    for _, option in pairs(self.options) do
        if option.Name == optionName then
            self.currentOption = option
            self.logger:LogTrace("loaded option: " .. option.Name)
            return true
        end
    end
    return false
end

-- ########## loading Options ########## --

---@private
---@param package Package
---@return boolean
function GithubLoader:loadMainModule(package)
    local mainModule = package:GetModule(package.Name .. "." .. "Main")
    if not mainModule then
        self.logger:LogError("Unable to get main module")
        return false
    end
    ---@cast mainModule Module
    if not mainModule.IsRunnable then
        self.logger:LogError("Unable to run main module")
        return false
    end
    local mainModuleData = mainModule:GetData()
    ---@cast mainModuleData table
    self.mainProgramModule = self.entities.Main.new(mainModuleData)
    return true
end

---@private
---@param logLevel number
---@return boolean
function GithubLoader:runConfigureFunction(logLevel)
    self.logger:LogTrace("configuring program...")
    local logger = self.logger.new("Program", logLevel)
    local thread, success, error = Utils.ExecuteFunctionAsThread(self.mainProgramModule.Configure, self.mainProgramModule, logger)
    if success and error ~= "not found" then
        self.logger:LogTrace("configured program")
    elseif error ~= "$%not found%$" then
        self.logger:LogError("configuration failed")
        self.logger:LogError(debug.traceback(thread, error) .. debug.traceback():sub(17))
        return false
    else
        self.logger:LogTrace("no configure function found")
        return false
    end
    return true
end

---@private
---@return boolean
function GithubLoader:runMainFunction()
    self.logger:LogTrace("running program...")
    local thread, success, result = Utils.ExecuteFunctionAsThread(self.mainProgramModule.Run, self.mainProgramModule)
    if result == "$%not found%$" then
        self.logger:LogError("no main run function found")
        return false
    end
    if not success then
        self.logger:LogError("program stoped running")
        self.logger:LogError(debug.traceback(thread, result) .. debug.traceback():sub(17))
        return false
    else
        self.logger:LogInfo("program stoped running: " .. tostring(result))
    end
    return true
end

-- ########## running main Module ########## --

---@param baseUrl string
---@param basePath string
---@param forceDownload boolean
---@return GithubLoader
function GithubLoader.new(baseUrl, basePath, forceDownload, internetCard)
    return setmetatable({
        GithubLoaderBaseUrl = baseUrl,
        GithubLoaderBasePath = basePath,
        options = {},
        forceDownloadLoaderFiles = forceDownload,
        internetCard = internetCard,
        logger = nil
    }, GithubLoader)
end

---@param logLevel integer
function GithubLoader:Initialize(logLevel)
    self:loadLoaderFiles(logLevel)
    return self
end

---@param extended boolean
function GithubLoader:ShowOptions(extended)
    if not self:loadOptions() then
        self.logger:LogError("Unable to load options")
    end
    print()
    print("Options:")
    for _, option in pairs(self.options) do
        if option.Name ~= "//index" then
            option:Print(extended)
        end
    end
end

---@param option string
---@param logLevel number
---@param forceDownload boolean
---@return boolean
function GithubLoader:Run(option, logLevel, forceDownload)
    if not self:loadOption(option) then
        self.logger:LogError("Unable not find option: " .. option)
        return false
    end
    self.logger:LogTrace("downloading program data...")
    local package = self.packageLoader:LoadPackage(self.currentOption.Name, forceDownload)
    if not package then
        self.logger:LogError("Unable to download '" .. option .. "'")
        return false
    end
    self.logger:LogTrace("downloaded program data")
    if not self:loadMainModule(package) then
        self.logger:LogError("Unable to load main module")
        return false
    end
    print()
    if not self:runConfigureFunction(logLevel) then return false end
    if not self:runMainFunction() then return false end
    return true
end

return GithubLoader
