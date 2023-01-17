local version = "1.0.5"

local GithubLoader = {}
GithubLoader.__index = GithubLoader

local BasePath = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/"
local OptionsUrl = BasePath.."Github/Options.lua"
local GithubFileLoaderUrl = BasePath.."Github/GithubFileLoader.lua"
local ModuleFileLoader = BasePath.."Github/ModuleLoader.lua"

GithubLoader.debug = false
GithubLoader.forceDownloadLoaderFiles = false
GithubLoader.options = {}
GithubLoader.currentOption = {}
GithubLoader.currentProgramInfo = {}
GithubLoader.mainProgramModule = {}

function GithubLoader:internalDownload(url, path, forceDownload)
    if forceDownload == nil then forceDownload = false end
    if not filesystem.exists(path) or forceDownload then
        if self.debug then
            print("DEBUG! downloading "..path.." from: "..url)
        end
        local req = InternetCard:request(url, "GET", "")
        local code, data = req:await()
        if code ~= 200 or not data then return false end
        local file = filesystem.open(path, "w")
        file:write(data)
        file:close()
        if self.debug then
            print("DEBUG! downloaded "..path.." from: "..url)
        end
    end
    return true
end

function GithubLoader:loadGithubFileLoader()
    if not self:internalDownload(GithubFileLoaderUrl, "ModuleLoader.lua", self.forceDownloadLoaderFiles) then
        print("ERROR! Unable to load Github file loader")
        return false
    end
    return true
end

function GithubLoader:loadModuleLoader()
    if not self:internalDownload(ModuleFileLoader, "ModuleLoader.lua", self.forceDownloadLoaderFiles) then
        print("ERROR! Unable to load Module loader")
        return false
    end
    filesystem.doFile("ModuleLoader.lua")
    return true
end

function GithubLoader:loadOptions(forceDownload)
    if forceDownload == nil then forceDownload = false end
    if not self.options == nil and not forceDownload then return true end
    if not self:internalDownload(OptionsUrl, "GitubLoaderFiles/Options.lua", forceDownload) then return false end
    if self.debug then
        print("DEBUG! loading options...")
    end
    self.options = filesystem.doFile("GitubLoaderFiles/Options.lua")

    local formatedOptions = {}
    for name, url in pairs(self.options) do
        formatedOptions[name:gsub("_", "/")] = url
    end
    self.options = formatedOptions

    print("INFO! loaded options")
    return true
end

function GithubLoader:loadOption(option, forceDownload)
    if not self:loadOptions(forceDownload) then return false end

    if self.debug then
        print("DEBGU! loading option: "..option)
    end

    for name, url in pairs(self.options) do
        if name == option then
            self.currentOption = {
                Name = name,
                Url = url
            }
            if self.debug then
                print("DEBGU! loaded option: "..option)
            end
            return true
        end
    end

    return false
end

function GithubLoader:isVersionTheSame(option, forceDownload)
    if not filesystem.exists("Info.lua") then return false end
    if not self:loadOptions(option) then return false end

    if self.debug then
        print("DEBUG! loading info data...")
    end
    self.currentProgramInfo = filesystem.doFile("Info.lua")
    if not self:internalDownload(self.currentOption.Url .. "/Info.lua", "Info.lua", forceDownload) then return false end

    local newProgramInfo = filesystem.doFile("Info.lua")
    if self.debug then
        print("DEBUG! loaded info data")
    end

    if not self.currentProgramInfo.Name == newProgramInfo.Name
    or self.currentProgramInfo.Version == newProgramInfo.Version then
        return false
    end

    return true
end

function GithubLoader:loadOptionFiles(option, forceDownload)
    if self:loadOption(option) == false then
        print("ERROR! Unable not find option: " .. option)
        return false
    end
    if self.debug then
        print("DEBUG! loading main program file...")
    end
    if not self:internalDownload(self.currentOption.Url .. "/Main.lua", "Main.lua", forceDownload) then
        print("ERROR! Unable to download main program file")
        return false
    end
    self.mainProgramModule = filesystem.doFile("Main.lua")
    if self.debug then
        print("DEBUG! loaded main program file")
    end
    return true
end

function GithubLoader:loadSetupFiles(isNewVersion)
    if self.debug then
        print("DEBUG! loading github file loader...")
    end
    if not self:loadGithubFileLoader() then
        return false
    end
    local fileLoader = filesystem.doFile("GitubLoaderFiles/GithubFileLoader.lua").new()
    if self.debug then
        print("DEBUG! loaded github file loader")
    end
    if not fileLoader:DownloadFileTree(BasePath, self.mainProgramModule.SetupFilesTree, isNewVersion, self.debug) then
        return false
    end
    return true
end

function GithubLoader:download(option, forceDownload)
    if self.debug then
        print("DEBGU! downloading program data...")
    end
    if self:isVersionTheSame(option, forceDownload) then
        return false
    else
        if self.debug then
            print("DEBUG! new Version of '"..option.."' found or diffrent program")
        end
    end
    if not self:loadOptionFiles(option) then
        print("ERROR! Unable to load option files")
        return false
    end
    if not self:loadSetupFiles(forceDownload) then
       print("ERROR! Unable to load setup files")
       return false
    end
    if self.debug then
        print("DEBGU! downloaded program data")
    end
    return true
end

function GithubLoader:Initialize(debug, forceDownload)
    if debug == false or debug == true then self.debug = debug end
    if forceDownload == false or forceDownload == true then self.debug = debug end
    self.forceDownloadLoaderFiles = forceDownload
    if self.debug then
        print("INFO! Github Loader Version: "..version)
    end
    return self
end

function GithubLoader:ShowOptions(extended, forceDownload)
    if not self:loadOptions(forceDownload) then
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
        print("ERROR! Unable to download '"..option.."' program")
        return "error"
    end

    if debug then
        print("INFO! in DEBUG mode")
    end

    print()
    if self.debug then
        print("DEBUG! configuring program...")
    end
    self:loadModuleLoader()
    self.mainProgramModule:Configure()
    if self.debug then
        print("DEBUG! configured program")
    end
    return self.mainProgramModule:Run(debug)
end

return GithubLoader