---
--- Created by Freemaker
--- LastChange: 16/01/2023
---

local GithubLoader = {}
GithubLoader.__index = GithubLoader

local BasePath = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/"
local OptionsUrl = BasePath.."Github/Options.lua"
local GithubLoaderUrl = BasePath.."Github/GithubFileLoader.lua"

GithubLoader.options = {}
GithubLoader.currentOption = {}
GithubLoader.currentProgramInfo = {}
GithubLoader.mainProgramModule = {}

function GithubLoader:internalDownload(url, path)
    local req = InternetCard:request(url, "GET", "")
    local code, data = req:await()
    if code ~= 200 or not data then return false end
    local file = filesystem.open(path, "w")
    file:write(data)
    file:close()
    return true
end

function GithubLoader:loadGithubFileLoader()
    if not filesystem.exists("GithubFileLoader.lua") then
        print("INFO! downloading Github file loader...")
        if not self:internalDownload(GithubLoaderUrl, "GithubFileLoader.lua") then
            print("ERROR! Unable to download Github file loader")
            return false
        end
        print("INFO! downloaded Github file loader")
        return true
    end
    return true
end

function GithubLoader:loadOptions(force)
    if force == nil then force = false end
    if not self.options == nil and not force then return true end
    if not self:internalDownload(OptionsUrl, "Options.lua") then return false end
    self.options = filesystem.doFile("Options.lua")

    local formatedOptions = {}
    for name, url in pairs(self.options) do
        formatedOptions[name:gsub("_", "/")] = url
    end
    self.options = formatedOptions

    print("INFO! loaded options")
    return true
end

function GithubLoader:loadOption(option, force)
    if not self:loadOptions(force) then return false end

    for name, url in pairs(self.options) do
        if name == option then
            self.currentOption = {
                Name = name,
                Url = url
            }
            return true
        end
    end

    return false
end

function GithubLoader:loadSetupFiles(isNewVersion)
    if not self:loadGithubFileLoader() then
        return false
    end
    local fileLoader = filesystem.doFile("GithubFileLoader.lua").new()
    if not fileLoader:DownloadFileTree(BasePath, self.mainProgramModule.SetupFilesTree, isNewVersion) then
        return false
    end
    return true
end

function GithubLoader:isVersionTheSame(option)
    if not filesystem.exists("Info.lua") then return false end
    if not self:loadGithubFileLoader() then return false end
    if not self:loadOptions(option) then return false end

    self.currentProgramInfo = filesystem.doFile("Info.lua")
    if not self:internalDownload(self.currentOption.Url .. "/Info.lua", "Info.lua") then return false end

    local newProgramInfo = filesystem.doFile("Info.lua")

    if not self.currentProgramInfo.Name == newProgramInfo.Name then return false end
    if self.currentProgramInfo.Version == newProgramInfo.Version then return false end

    return true
end

function GithubLoader:loadOptionFiles(option)
    if self:loadOption(option) == false then
        print("ERROR! Unable not find option: " .. option)
        return false
    end
    if not self:internalDownload(self.currentOption.Url .. "/Main.lua", "Main.lua") then
        print("ERROR! Unable to download main program file")
        return false
    end
    self.mainProgramModule = filesystem.doFile("Main.lua")
    return true
end

function GithubLoader:download(option, force)
    if self:isVersionTheSame(option) then return false end
    if not self:loadOptionFiles(option) then
        print("ERROR! Unable to load option files")
        return false
    end
    if not self:loadSetupFiles(force) then
       print("ERROR! Unable to load setup files")
       return false
    end
    return true
end

function GithubLoader:ShowOptions(extended, force)
    if not self:loadOptions(force) then
        print("ERROR! Unable to load options")
    end
    print()
    print("Options:")
    for name, url in pairs(self.options) do
        local output = name
        if extended == true then
            output = output .. " -> " .. url
        end
        print(output)
    end
end

function GithubLoader:Run(option, forceDownload, debug)
    if not self:download(option, forceDownload) then
        print("ERROR! Unable to download option program")
        return "error"
    end
    if debug then
        print("INFO! in DEBUG mode")
    end

    print()
    self.mainProgramModule:Configure()
    print()
    print("INFO! configured program")

    print("\n\n")
    return self.mainProgramModule:Run(debug)
end

return GithubLoader