local version = "1.0.8"

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

function GithubLoader:loadUtils()
    if not self:internalDownload(UtilsUrl, UtilsPath, self.forceDownloadLoaderFiles) then
        return false
    end
    filesystem.doFile(UtilsPath)
    return true
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
    if not self:internalDownload(GithubFileLoaderUrl, GithubFileLoaderPath, self.forceDownloadLoaderFiles) then
        return false
    end
    self._fileLoader = filesystem.doFile(GithubFileLoaderPath).new(self.logger)
    if self._fileLoader == nil then
        return false
    end
    self.logger:LogDebug("loaded github file loader")
    return true
end

function GithubLoader:loadModuleLoader()
    self.logger:LogDebug("loading module loader...")
    if not self:internalDownload(ModuleFileLoaderUrl, ModuleFileLoaderPath, self.forceDownloadLoaderFiles) then
        return false
    end
    filesystem.doFile(ModuleFileLoaderPath)
    ModuleLoader.Initialize(self.logger)
    self.logger:LogDebug("loaded module loader")
    return true
end

function GithubLoader:loadOptions()
    if not self.options == nil then return true end
    if not self:internalDownload(OptionsUrl, OptionsPath, true) then return false end
    self.logger:LogDebug("loading options...")
    self._options = filesystem.doFile(OptionsPath)

    local formatedOptions = {}
    for name, url in pairs(self._options) do
        formatedOptions[name:gsub("_", "/")] = url
    end
    self._options = formatedOptions
    self.logger:LogDebug("loaded options")
    return true
end

function GithubLoader:loadOption(option)
    if not self:loadOptions() then return false end
    self.logger:LogDebug("loading option: " .. option)
    for name, url in pairs(self._options) do
        if name == option then
            self._currentOption = {
                Name = name,
                Url = url
            }
            self.logger:LogDebug("loaded option: " .. option)
            return true
        end
    end
    return false
end

function GithubLoader:isVersionTheSame()
    self.logger:LogDebug("loading info data...")
    local versionFileExists = filesystem.exists(VersionFilePath)
    if versionFileExists then
        self._currentProgramInfo = filesystem.doFile(VersionFilePath)
    else
        self.logger:LogTrace("no version file found")
    end

    if not self:internalDownload(GithubLoaderBaseUrl .. self._currentOption.Url .. "/Version.lua", VersionFilePath, true) then return false end

    local newProgramInfo = filesystem.doFile(VersionFilePath)
    if newProgramInfo == nil then
        newProgramInfo = { Name = "None", Version = "" }
        return false
    end

    if not versionFileExists then
        self._currentProgramInfo = newProgramInfo
        return false
    end

    self.logger:LogDebug("loaded info data")
    if self._currentProgramInfo.Name ~= newProgramInfo.Name
        or self._currentProgramInfo.Version ~= newProgramInfo.Version then
        return false
    end
    return true
end

function GithubLoader:loadOptionFiles(forceDownload)
    self.logger:LogDebug("loading main program file...")
    if not filesystem.exists(MainFilePath) or forceDownload then
        if not self:internalDownload(GithubLoaderBaseUrl .. self._currentOption.Url .. "/Main.lua", MainFilePath, forceDownload) then
            self.logger:LogError("Unable to download main program file")
            return false
        end
    end
    self._mainProgramModule = filesystem.doFile(MainFilePath)
    self.logger:LogDebug("loaded main program file")
    return true
end

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
    if not self._fileLoader:DownloadFileTree(GithubLoaderBaseUrl, self._mainProgramModule.SetupFilesTree, loadProgramFiles) then
        self.logger:LogError("Unable to load setup files")
        return false
    end
    return true
end

function GithubLoader:runConfigureFunction(logLevel)
    self.logger:LogDebug("configuring program...")
    self._mainProgramModule._logger = self.logger.new("Program", logLevel)
    if self._mainProgramModule.Configure ~= nil then
        local thread, success, error = Utils.ExecuteFunction(self._mainProgramModule.Configure, self._mainProgramModule)
        if success then
            self.logger:LogDebug("configured program")
        else
            self.logger:LogError("configuration failed")
            self.logger:LogError(debug.traceback(thread, error) .. debug.traceback():sub(17))
            return false
        end
    else
        self.logger:LogDebug("no configure function found")
    end
    return true
end

function GithubLoader:runMainFunction()
    self.logger:LogDebug("running program...")
    if self._mainProgramModule.Run == nil then
        self.logger:LogError("no main run function found")
        return false
    end
    local thread = coroutine.create(self._mainProgramModule.Run)
    local success, result = coroutine.resume(thread, self._mainProgramModule)
    if not success then
        self.logger:LogError("program stoped running")
        self.logger:LogError(debug.traceback(thread, result) .. debug.traceback():sub(17))
        return false
    else
        self.logger:LogInfo("program stoped running: " .. tostring(result))
    end
    return true
end

function GithubLoader:Initialize(logLevel, forceDownload)
    if forceDownload == false or forceDownload == true then self._forceDownloadLoaderFiles = forceDownload end
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
    if self._forceDownloadLoaderFiles then
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
    for name, url in pairs(self._options) do
        if name ~= "//index" then
            local output = name
            if extended == true and type(url) == "string" then
                output = output .. " -> " .. url
            end
            print(output)
        end
    end
end

function GithubLoader:Run(option, logLevel, forceDownload)
    self.logger:LogDebug("downloading program data...")
    if not self:download(option, forceDownload) then
        self.logger:LogError("Unable to download '" .. option .. "'")
        return false
    end
    self.logger:LogDebug("downloaded program data")
    print()

    if not ModuleLoader.LoadModules(self._mainProgramModule.SetupFilesTree, true) then return false end

    if not self:runConfigureFunction(logLevel) then return false end
    if not self:runMainFunction() then return false end
    return true
end

return GithubLoader
