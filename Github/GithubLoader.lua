local version = "1.0.8"

local GithubLoader = {}
GithubLoader.__index = GithubLoader

local BaseUrl = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/"

local GithubLoaderFilesUrl = BaseUrl.."Github/"
local GithubLoaderFilesPath = "GithubLoaderFiles"
local OptionsUrl = GithubLoaderFilesUrl.."Options.lua"
local OptionsPath = filesystem.path(GithubLoaderFilesPath, "Options.lua")
local GithubFileLoaderUrl = GithubLoaderFilesUrl.."GithubFileLoader.lua"
local GithubFileLoaderPath = filesystem.path(GithubLoaderFilesPath, "GithubFileLoader.lua")

local SharedFolderUrl = BaseUrl.."shared/"
local SharedFolderPath = "shared"
local ModuleFileLoaderUrl = SharedFolderUrl.."ModuleLoader.lua"
local ModuleFileLoaderPath = filesystem.path(SharedFolderPath, "ModuleLoader.lua")
local LoggerUrl = SharedFolderUrl.."Logger.lua"
local LoggerPath = filesystem.path(SharedFolderPath, "Logger.lua")

local VersionFilePath = "Version.lua"
local MainFilePath = "Main.lua"

GithubLoader.forceDownloadLoaderFiles = false
GithubLoader.options = {}
GithubLoader.currentOption = {}
GithubLoader.currentProgramInfo = {}
GithubLoader.mainProgramModule = {}
GithubLoader.logger = nil
GithubLoader.fileLoader = nil

function GithubLoader:internalDownload(url, path, forceDownload)
    if forceDownload == nil then forceDownload = false end
    if filesystem.exists(path) and not forceDownload then
        return true
    end
    if self.logger ~= nil then
        self.logger:LogTrace("downloading "..path.." from: "..url)
    end
    local req = InternetCard:request(url, "GET", "")
    local code, data = req:await()
    if code ~= 200 or not data then return false end
    local file = filesystem.open(path, "w")
    file:write(data)
    file:close()
    if self.logger ~= nil then
        self.logger:LogTrace("downloaded "..path.." from: "..url)
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

function GithubLoader:loadGithubFileLoader()
    self.logger:LogDebug("loading github file loader...")
    if not self:internalDownload(GithubFileLoaderUrl, GithubFileLoaderPath, self.forceDownloadLoaderFiles) then return false end
    self.fileLoader = filesystem.doFile(GithubFileLoaderPath).new(self.logger:create("File Loader"))
    if self.fileLoader == nil then
        return false
    end
    self.logger:LogDebug("loaded github file loader")
    return true
end

function GithubLoader:loadModuleLoader()
    self.logger:LogDebug("loading module loader...")
    if not self:internalDownload(ModuleFileLoaderUrl, ModuleFileLoaderPath, self.forceDownloadLoaderFiles) then return false end
    filesystem.doFile(ModuleFileLoaderPath)
    ModuleLoader.Initialize(self.logger:create("ModuleLoader"))
    self.logger:LogDebug("loaded module loader")
    return true
end

function GithubLoader:loadOptions()
    if not self.options == nil then return true end
    if not self:internalDownload(OptionsUrl, OptionsPath, true) then return false end
    self.logger:LogDebug("loading options...")
    self.options = filesystem.doFile(OptionsPath)

    local formatedOptions = {}
    for name, url in pairs(self.options) do
        formatedOptions[name:gsub("_", "/")] = url
    end
    self.options = formatedOptions
    self.logger:LogDebug("loaded options")
    return true
end

function GithubLoader:loadOption(option)
    if not self:loadOptions() then return false end
    self.logger:LogDebug("loading option: "..option)
    for name, url in pairs(self.options) do
        if name == option then
            self.currentOption = {
                Name = name,
                Url = url
            }
            self.logger:LogDebug("loaded option: "..option)
            return true
        end
    end
    return false
end

function GithubLoader:isVersionTheSame(forceDownload)
    self.logger:LogDebug("loading info data...")
    if filesystem.exists(VersionFilePath) then
        self.currentProgramInfo = filesystem.doFile(VersionFilePath)
    end
    if self.currentProgramInfo == nil then
        self.currentProgramInfo = {Name = "None", Version = ""}
    end
    if not self:internalDownload(self.currentOption.Url .. "/Version.lua", VersionFilePath, forceDownload) then return false end
    local newProgramInfo = filesystem.doFile(VersionFilePath)
    if newProgramInfo == nil then
        newProgramInfo = {Name = "None", Version = ""}
    end
    self.logger:LogDebug("loaded info data")
    if not self.currentProgramInfo.Name == newProgramInfo.Name
    or self.currentProgramInfo.Version == newProgramInfo.Version then
        return false
    end
    return true
end

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

function GithubLoader:download(option, forceDownload)
    if self:loadOption(option) == false then
        self.logger:LogError("Unable not find option: " .. option)
        return false
    end
    local loadProgramFiles = self:isVersionTheSame(forceDownload)
    if loadProgramFiles then
        self.logger:LogDebug("new Version of '"..option.."' found or diffrent program")
    else
        self.logger:LogDebug("no new Version available")
    end
    if not self:loadOptionFiles(forceDownload) then
        self.logger:LogError("Unable to load option files")
        return false
    end
    if forceDownload then
        loadProgramFiles = true
    end
    if not self.fileLoader:DownloadFileTree(BaseUrl, self.mainProgramModule.SetupFilesTree, loadProgramFiles) then
        self.logger:LogError("Unable to load setup files")
        return false
    end
    return true
end

function GithubLoader:Initialize(logLevel, forceDownload)
    if forceDownload == false or forceDownload == true then self.forceDownloadLoaderFiles = forceDownload end
    self:createLoaderFilesFolders()
    if not self:loadLogger(logLevel) then
        computer.panic("Unable to load logger")
    end
    self.logger:LogDebug("Github Loader Version: "..version)
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

function GithubLoader:ShowOptions(extended)
    if not self:loadOptions() then
        self.logger:LogError("Unable to load options")
    end
    print()
    print("Options:")
    for name, url in pairs(self.options) do
        if name ~= "//index" then
            local output = name
            if extended == true and type(url) == "string" then
                output = output .. " -> " .. url
            end
            print(output)
        end
    end
end

function GithubLoader:Run(option, debug, forceDownload)
    self.logger:LogDebug("downloading program data...")
    if not self:download(option, forceDownload) then
        self.logger:LogError("Unable to download '"..option.."'")
        return false
    end
    self.logger:LogDebug("downloaded program data")
    print()

    local loadedModules = ModuleLoader.LoadModules(self.mainProgramModule.SetupFilesTree)
    if not loadedModules then return false end

    self.logger:LogDebug("configuring program...")
    self.mainProgramModule.Logger = self.logger.new("Program", debug)
    if self.mainProgramModule.Configure ~= nil then
        local success = pcall(self.mainProgramModule:Configure())
        if success then
            self.logger:LogDebug("configured program")
        else
            self.logger:LogError("configuration failed")
            return false
        end
    else
        self.logger:logDebug("no configure function found")
    end

    self.logger:LogDebug("running program...")
    if self.mainProgramModule.Run == nil then
        self.logger:LogError("no main run function found")
        return false
    end
    local result = self.mainProgramModule:Run()
    self.logger:LogInfo("program stoped running: "..tostring(result))
    return true
end

return GithubLoader