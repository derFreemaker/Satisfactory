---
--- Created by Freemaker
--- DateTime: 15/01/2023
---

GithubLoader = {}
GithubLoader.__index = GithubLoader

local function internalDownload(url, name)
    local req = InternetCard:request(url, "GET", "")
    local _, libdata = req:await()
    local file = filesystem.open(name, "w")
    file:write(libdata)
    file:close()
end

local function loadGithubFileLoader()
    if not filesystem.exists("GithubFileLoader.lua") then
        print("INFO! downloading Github file loader...")
        internalDownload("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/Github/GithubFileLoader.lua", "GithubFileLoader.lua")
        print("INFO! downloaded Github file loader")
    end
end

local function checkVersion(option)
    if not filesystem.exists("Info.lua") then return false end
    loadGithubFileLoader()

    local currentInfo = filesystem.doFile("Info.lua")
    internalDownload("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/" .. option .. "/Info.lua", "Info.lua")
    local newInfo = filesystem.doFile("Info.lua")

    if not currentInfo.Name == newInfo.Name then return false end
    if currentInfo.Version == newInfo.Version then return false end

    return true
end

local function loadSetupFiles(newVersion)
    loadGithubFileLoader()
    local fileLoader = filesystem.doFile("GithubFileLoader.lua").new()
    local setupFiles = filesystem.doFile("SetupFiles.lua")
    fileLoader:DownloadFileTree(setupFiles.Tree, newVersion)
    print("INFO! loaded setup files")
end

GithubLoader.options = {}

function GithubLoader:loadOptions()
    internalDownload("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/Github/Options.lua", "options.lua")
    self.options = filesystem.doFile("options.lua")
    print("INFO! loaded options")
end

function GithubLoader:checkOption(option)
    self:loadOptions()
    local url = self.options[option]
    if url == nil then
        print("ERROR! Could not find option: " .. option)
        return false
    end
    return true
end

function GithubLoader:loadOptionFiles(option)
    if self:checkOption(option) == false then return false end
    local url = self.options[option]
    internalDownload(url.."/SetupFiles.lua", "SetupFiles.lua")
    internalDownload(url.."/Main.lua", "Main.lua")
    return true
end

function GithubLoader:ShowOptions()
    self:loadOptions()
    print()
    print("Options:")
    for name, url in pairs(self.options) do
        if name ~= "__index" then
            print(name.." -> "..url)
        end
    end
end

function GithubLoader:Download(option, force)
    if checkVersion(option) then return end
    if self:loadOptionFiles(option) == false then return end
    loadSetupFiles(force)
end

function GithubLoader:Run(debug)
    if debug then
        print("INFO! running program in debug...")
    else
        print("INFO! running program...")
    end
    print()
    print()

    local main = filesystem.doFile("Main.lua")
    main:Run(debug)
end

return GithubLoader