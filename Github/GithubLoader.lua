local version = "1.0.5"

local FileLoader = nil
local Logger = nil

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
    if not filesystem.exists(path) or forceDownload then
        if self.logger ~= nil then
            self.logger:LogDebug("downloading "..path.." from: "..url)
        end
        local req = InternetCard:request(url, "GET", "")
        local code, data = req:await()
        if code ~= 200 or not data then return false end
        local file = filesystem.open(path, "w")
        file:write(data)
        file:close()
        if self.logger ~= nil then
            self.logger:LogDebug("downloaded "..path.." from: "..url)
        end
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

function GithubLoader:loadLogger(debug)
    if not filesystem.exists("log") then
        filesystem.createDir("log")
    end
    if not self:internalDownload(LoggerUrl, LoggerPath, self.forceDownloadLoaderFiles) then return false end
    Logger = filesystem.doFile(LoggerPath)
    self.logger = Logger.new("Loader", debug)
    self.logger:LogInfo("\nstarted logging\n")
    return true
end

function GithubLoader:loadGithubFileLoader(debug)
    self.logger:LogDebug("loading github file loader...")
    if not self:internalDownload(GithubFileLoaderUrl, GithubFileLoaderPath, self.forceDownloadLoaderFiles) then return false end
    FileLoader = filesystem.doFile(GithubFileLoaderPath)
    self.fileLoader = FileLoader.new(Logger.new("File Loader", debug))
    self.logger:LogDebug("loaded github file loader")
    return true
end

function GithubLoader:loadModuleLoader(debug)
    if not self:internalDownload(ModuleFileLoaderUrl, ModuleFileLoaderPath, self.forceDownloadLoaderFiles) then return false end
    filesystem.doFile(ModuleFileLoaderPath)
    ModuleLoader.Initialize(Logger.new("ModuleLoader", debug))
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
    self.logger:LogInfo("loaded options")
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
    self.logger:LogDebug("loading infa data...")
    if not filesystem.exists(VersionFilePath) then
        self.currentProgramInfo = {Name = "None", Version = ""}
    else
        self.currentProgramInfo = filesystem.doFile(VersionFilePath)
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
    if not filesystem.exists(MainFilePath) then
        if not self:internalDownload(self.currentOption.Url .. "/Main.lua", MainFilePath, forceDownload) then
            print("ERROR! Unable to download main program file")
            return false
        end
    end
    self.mainProgramModule = filesystem.doFile(MainFilePath)
    self.logger:LogDebug("loaded main program file")
    return true
end

function GithubLoader:download(option, forceDownload)
    if self:loadOption(option) == false then
        print("ERROR! Unable not find option: " .. option)
        return false
    end
    self.logger:LogDebug("downloading program data...")
    local newProgram = self:isVersionTheSame(forceDownload)
    if not newProgram then
        return false
    else
        self.logger:LogDebug("new Version of '"..option.."' found or diffrent program")
    end
    if not self:loadOptionFiles(forceDownload) then
        print("ERROR! Unable to load option files")
        return false
    end
    if not self.fileLoader:DownloadFileTree(BaseUrl, self.mainProgramModule.SetupFilesTree, newProgram, self.logger) then
       print("ERROR! Unable to load setup files")
       return false
    end
    self.logger:LogDebug("downloaded program data")
    return true
end

function GithubLoader:Initialize(debug, forceDownload)
    if forceDownload == false or forceDownload == true then self.forceDownloadLoaderFiles = debug end
    self:createLoaderFilesFolders()
    if not self:loadLogger(debug) then
        computer.panic("Unable to load logger")
    end
    if debug == true then
        self.logger:LogInfo("Github Loader Version: "..version)
    end
    if not self:loadGithubFileLoader(debug) then
        computer.panic("Unable to load github file loader")
    end
    if not self:loadModuleLoader(debug) then
        computer.panic("Unable to load module loader")
    end
    if self.forceDownloadLoaderFiles then
        self.logger:LogInfo("loaded loader files")
    end
    return self
end

function GithubLoader:ShowOptions(extended)
    if not self:loadOptions() then
        print("ERROR! Unable to load options")
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
    if not self:download(option, forceDownload) then
        computer.panic("Unable to download '"..option.."' program")
    end
    local logger = filesystem.doFile(LoggerPath).new("Program", debug)
    print()
    ModuleLoader.LoadModules(self.mainProgramModule.SetupFilesTree)
    self.logger:LogDebug("configuring program...")
    self.mainProgramModule:Configure(logger)
    self.logger:LogDebug("configured program")
    self.logger:LogDebug("running program...")
    local result = self.mainProgramModule:Run(logger)
    self.logger:LogDebug("program stoped running: "..tostring(result))
end

return GithubLoader