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
    local output
    if extended == true and type(self.Url) == "string" then
        output = self.Name .. " -> " .. self.Url
    end
    print(output)
end


---@class ProgramInfo
---@field Name string
---@field Version string
local ProgramInfo = {}
ProgramInfo.__index = ProgramInfo

---@param name string
---@param version string
---@return ProgramInfo
function ProgramInfo.new(name, version)
    return setmetatable({
        Name = name,
        Version = version
    }, ProgramInfo)
end

---@param programInfo ProgramInfo
function ProgramInfo:Compare(programInfo)
    if self.Name ~= programInfo.Name
        or self.Version ~= programInfo.Version then
        return false
    end
    return true
end


---@class GithubLoader
---@field private forceDownloadLoaderFiles boolean
---@field private options Option[]
---@field private currentOption Option
---@field private currentProgramInfo ProgramInfo
---@field private mainProgramModule Main
---@field private logger Logger
---@field private fileLoader GithubFileLoader
---@field private entryClass Entry
local GithubLoader = {}
GithubLoader.__index = GithubLoader

local GithubLoaderFilesUrl = GithubLoaderBaseUrl .. "Github/"
local GithubLoaderFilesPath = "GithubLoaderFiles"
local OptionsUrl = GithubLoaderFilesUrl .. "Options.lua"
local OptionsPath = filesystem.path(GithubLoaderFilesPath, "Options.lua")
local GithubFileLoaderUrl = GithubLoaderFilesUrl .. "GithubFileLoader.lua"
local GithubFileLoaderPath = filesystem.path(GithubLoaderFilesPath, "GithubFileLoader.lua")

local SharedFolderUrl = GithubLoaderBaseUrl .. "shared/"
local SharedFolderPath = "shared"
local ModuleFileLoaderUrl = SharedFolderUrl .. "ModuleLoader.lua"
local ModuleFileLoaderPath = filesystem.path(SharedFolderPath, "ModuleLoader.lua")
local LoggerUrl = SharedFolderUrl .. "Logger.lua"
local LoggerPath = filesystem.path(SharedFolderPath, "Logger.lua")
local UtilsUrl = SharedFolderUrl .. "Utils.lua"
local UtilsPath = filesystem.path(SharedFolderPath, "Utils.lua")
local EntryUrl = SharedFolderUrl .. "Entry.lua"
local EntryPath = filesystem.path(SharedFolderPath, "Entry.lua")
local MainUrl = SharedFolderUrl .. "Main.lua"
local MainPath = filesystem.path(SharedFolderPath, "Main.lua")

local VersionFilePath = "Version.lua"
local MainFilePath = "Main.lua"

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
        self.logger:LogTrace("downloading " .. path .. " from: " .. url)
    end
    local req = InternetCard:request(url, "GET", "")
    local code, data = req:await()
    if code ~= 200 or data == nil then return false end
    local file = filesystem.open(path, "w")
    file:write(data)
    file:close()
    if self.logger ~= nil then
        self.logger:LogTrace("downloaded " .. path .. " from: " .. url)
    end
    return true
end

function GithubLoader:createLoaderFilesFolders()
    if not filesystem.exists(GithubLoaderFilesPath) then
        filesystem.createDir(GithubLoaderFilesPath)
    end
    if not filesystem.exists(SharedFolderPath) then
        filesystem.createDir(SharedFolderPath)
    end
end

---@private
---@return boolean
function GithubLoader:loadUtils()
    if not self:internalDownload(UtilsUrl, UtilsPath, self.forceDownloadLoaderFiles) then
        return false
    end
    filesystem.doFile(UtilsPath)
    return true
end

---@private
---@param logLevel number
---@return boolean
function GithubLoader:loadLogger(logLevel)
    if not filesystem.exists("log") then
        filesystem.createDir("log")
    end
    if not self:internalDownload(LoggerUrl, LoggerPath, self.forceDownloadLoaderFiles) then return false end
    self.logger = filesystem.doFile(LoggerPath).new("Loader", logLevel)
    if self.logger == nil then
        return false
    end
    self.logger:ClearLog(true)
    return true
end

---@private
---@return boolean
function GithubLoader:loadEntry()
    self.logger:LogDebug("loading entry...")
    if not self:internalDownload(EntryUrl, EntryPath, self.forceDownloadLoaderFiles) then
        return false
    end
    self.entryClass = filesystem.doFile(EntryPath).new(self.logger)
    if self.entryClass == nil then
        return false
    end
    self.logger:LogDebug("loaded github file loader")
    return true
end

---@private
---@return boolean
function GithubLoader:loadGithubFileLoader()
    self.logger:LogDebug("loading github file loader...")
    if not self:internalDownload(GithubFileLoaderUrl, GithubFileLoaderPath, self.forceDownloadLoaderFiles) then
        return false
    end
    self.fileLoader = filesystem.doFile(GithubFileLoaderPath).new(self.logger)
    if self.fileLoader == nil then
        return false
    end
    self.logger:LogDebug("loaded github file loader")
    return true
end

---@private
---@return boolean
function GithubLoader:loadModuleLoader()
    self.logger:LogDebug("loading module loader...")
    if not self:internalDownload(ModuleFileLoaderUrl, ModuleFileLoaderPath, self.forceDownloadLoaderFiles) then
        return false
    end
    filesystem.doFile(ModuleFileLoaderPath)
    ModuleLoader.Initialize(self.logger, self.entryClass)
    self.logger:LogDebug("loaded module loader")
    return true
end

---@private
---@return boolean
function GithubLoader:loadMainClass()
    self.logger:LogDebug("loading main class...")
    if not self:internalDownload(MainUrl, MainPath, self.forceDownloadLoaderFiles) then
        return false
    end
    self.mainClass = filesystem.doFile(MainPath)
    self.logger:LogDebug("loaded main class")
    return true
end

---@private
---@return boolean
function GithubLoader:loadOptions()
    if not self.options == nil then return true end
    if not self:internalDownload(OptionsUrl, OptionsPath, true) then return false end
    self.logger:LogDebug("loading options...")
    local options = filesystem.doFile(OptionsPath)

    ---@type Option[]
    local formatedOptions = {}
    for name, url in pairs(options) do
        ---@cast name string
        ---@cast url string
        table.insert(formatedOptions, Option.new(name, url))
    end
    self.options = formatedOptions
    self.logger:LogDebug("loaded options")
    return true
end

---@private
---@param optionName string
---@return boolean
function GithubLoader:loadOption(optionName)
    if not self:loadOptions() then return false end
    self.logger:LogDebug("loading option: " .. optionName)
    for _, option in pairs(self.options) do
        if option.Name == optionName then
            self.currentOption = option
            self.logger:LogDebug("loaded option: " .. option.Name)
            return true
        end
    end
    return false
end

---@private
---@return boolean
function GithubLoader:isVersionTheSame()
    self.logger:LogDebug("loading info data...")
    local versionFileExists = filesystem.exists(VersionFilePath)
    if versionFileExists then
        self.currentProgramInfo = filesystem.doFile(VersionFilePath)
    else
        self.logger:LogTrace("no version file found")
    end

    if not self:internalDownload(self.currentOption.Url .. "/Version.lua", VersionFilePath, true) then return false end

    local versionFile = filesystem.doFile(VersionFilePath)
    local newProgramInfo = ProgramInfo.new(versionFile.Name, versionFile.Version)

    if newProgramInfo == nil then
        return false
    end

    if not versionFileExists then
        self.currentProgramInfo = newProgramInfo
    end

    self.logger:LogDebug("loaded info data")
    local isSame = self.currentProgramInfo:Compare(newProgramInfo)
    if not isSame then
        self.currentProgramInfo = newProgramInfo
    end
    return isSame
end

---@private
---@param forceDownload boolean
---@return boolean
function GithubLoader:loadOptionFiles(forceDownload)
    self.logger:LogDebug("loading main program file...")
    if not filesystem.exists(MainFilePath) or forceDownload then
        if not self:internalDownload(self.currentOption.Url .. "/Main.lua", MainFilePath, forceDownload) then
            self.logger:LogError("Unable to download main program file")
            return false
        end
    end
    self.mainProgramModule = filesystem.doFile(MainFilePath)
    self.logger:LogDebug("loaded main program file")
    return true
end

---@private
---@param option string
---@param forceDownload boolean
---@return boolean
function GithubLoader:download(option, forceDownload)
    if self:loadOption(option) == false then
        self.logger:LogError("Unable not find option: " .. option)
        return false
    end
    local loadProgramFiles = self:isVersionTheSame()
    if not loadProgramFiles then
        self.logger:LogInfo("new Version of '" .. option .. "' found or diffrent program")
        forceDownload = true
    else
        self.logger:LogInfo("no new Version available")
    end
    if not self:loadOptionFiles(forceDownload) then
        self.logger:LogError("Unable to load option files")
        return false
    end
    if forceDownload then
        loadProgramFiles = true
    end
    if not self.fileLoader:DownloadFileTree(GithubLoaderBaseUrl, self.mainProgramModule.SetupFilesTree, loadProgramFiles) then
        self.logger:LogError("Unable to load setup files")
        return false
    end
    return true
end

---@private
---@param logLevel number
---@return boolean
function GithubLoader:runConfigureFunction(logLevel)
    self.logger:LogDebug("configuring program...")
    self.mainProgramModule._logger = self.logger.new("Program", logLevel)
    local thread, success, error = Utils.ExecuteFunction(self.mainProgramModule.Configure, self.mainProgramModule)
    if success and error ~= "not found" then
        self.logger:LogDebug("configured program")
    elseif error ~= "$%not found%$" then
        self.logger:LogError("configuration failed")
        self.logger:LogError(debug.traceback(thread, error) .. debug.traceback():sub(17))
        return false
    else
        self.logger:LogDebug("no configure function found")
        return false
    end
    return true
end

---@private
---@return boolean
function GithubLoader:runMainFunction()
    self.logger:LogDebug("running program...")
    local thread, success, result = Utils.ExecuteFunction(self.mainProgramModule.Run, self.mainProgramModule)
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

---@param logLevel number
---@param forceDownload boolean
function GithubLoader:Initialize(logLevel, forceDownload)
    self.forceDownloadLoaderFiles = forceDownload or false
    self.options = {}
    self.currentOption = {}
    self.currentProgramInfo = {}
    self.mainProgramModule = {}
    self.logger = nil
    self.fileLoader = nil
    self.entry = {}
    self:createLoaderFilesFolders()
    if not self:loadUtils() then
        computer.panic("Unable to load utils")
    end
    if not self:loadLogger(logLevel) then
        computer.panic("Unable to load logger")
    end
    if not self:loadGithubFileLoader() then
        computer.panic("Unable to load github file loader")
    end
    if not self:loadModuleLoader() then
        computer.panic("Unable to load module loader")
    end
    if self.forceDownloadLoaderFiles then
        self.logger:LogInfo("loaded loader files")
    end
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
    self.logger:LogDebug("downloading program data...")
    if not self:download(option, forceDownload) then
        self.logger:LogError("Unable to download '" .. option .. "'")
        return false
    end
    self.logger:LogDebug("downloaded program data")
    print()

    if not ModuleLoader.LoadModules(self.mainProgramModule.SetupFilesTree, true) then return false end

    if not self:runConfigureFunction(logLevel) then return false end
    if not self:runMainFunction() then return false end
    return true
end

return GithubLoader