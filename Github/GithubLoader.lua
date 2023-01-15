---
--- Created by Freemaker
--- DateTime: 24/10/2022
---

GithubLoader = {}
GithubLoader.__index = GithubLoader

local setupFile = {}

local options = {
    Test = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/Test"
}

function GithubLoader:showOptions()
    for name, url in pairs(options) do
        print(name.."->"..url)
    end
end

local function internalDownload(url)
    if filesystem.exists("SetupFile.lua") == false then
        local req = InternetCard:request(url, "GET", "")
        local _, libdata = req:await()
        local file = filesystem:open("SetupFile.lua", "w")
        file:write(libdata)
        file:close()
    end
end

function GithubLoader:download(option)
    local url = options[option]
    if url == nil then
        computer.print("ERROR! Could not find option: " .. option)
        return
    end
    internalDownload(url)
end

function GithubLoader:run(debug)
    setupFile = filesystem:doFile("SetupFile.lua")
    setupFile:run(debug)
end