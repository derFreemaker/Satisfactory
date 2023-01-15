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

local function checkVersion(option)
    if not filesystem.exists("Info.lua") then return false end

    local currentInfo = filesystem.doFile("Info.lua")
    internalDownload("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/" .. option .. "/Info.lua", "Info.lua")
    local newInfo = filesystem.doFile("Info.lua")

    if not currentInfo.Name == newInfo.Name then return false end
    if currentInfo.Version < newInfo.Version then return false end

    return true
end

local function downloadSetupFiles()
    internalDownload("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/Github/GithubFileLoader.lua", "GithubFileLoader.lua")
    local fileLoader = filesystem.doFile("GithubFileLoader.lua").new()
    local fileTree = filesystem.doFile("SetupFiles.lua").Tree
    fileLoader.downloadFileTree(fileTree)
end

GithubLoader.options = {}

function GithubLoader:loadOptions()
    internalDownload("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/Github/Options.lua", "options.lua")
    self.options = filesystem.dofile("options.lua")
end

function GithubLoader:checkOption(option)
    self:loadOptions()
    local url = self.options[option]
    if url == nil then
        computer.print("ERROR! Could not find option: " .. option)
        return false
    end
    return true
end

function GithubLoader:loadOptionFiles(option)
    internalDownload("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/" .. option .. "SetupFiles.lua", "SetupFiles.lua")
    internalDownload("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/" .. option .. "Main.lua", "Main.lua")
end

function GithubLoader:ShowOptions()
    self:loadOptions()
    for name, url in pairs(self.options) do
        print(name.."->"..url)
    end
end

function GithubLoader:Download(option)
    if checkVersion(option) then return end
    print("INFO! downloading info files...")
    self:loadOptionFiles(option)
    print("INFO! downloaded info files")
    print("INFO! downloading setup files...")
    downloadSetupFiles()
    print("INFO! downloaded setup files!")
end

function GithubLoader:Run(debug)
    print("INFO! running program...")
    local main = filesystem.doFile("Main.lua")
    main:Run(debug)
end


return GithubLoader
