---
--- Created by Freemaker
--- DateTime: 24/10/2022
---

GithubLoader = {}
GithubLoader.__index = GithubLoader

local setupFile = {}

local options = {}

function GithubLoader:initialize()
    options["Test"] = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/Test.lua"
    --options["HyperTubeNetworkMainServer"] = "https://"
    --options["HyperTubeNetworkNodeServer"] = "https://"
end

function GithubLoader:showOptions()
    for name, url in pairs(options) do
        print(name.."->"..url)
    end
end

local function internalDownload(url)
    if fs.exists("SetupFile.lua") == false then
        local req = networkCard:request(url, "GET", "")
        local _, libdata = req:await()
        local file = fs:open("SetupFile.lua", "w")
        file:write(libdata)
        file:close()
    end
    setupFile = fs:doFile("SetupFile.lua")
end

function GithubLoader:download(option)
    local url = options[option]
    if url == nil then
        computer.panic("could not find option")
    end
    internalDownload(url)
end

function GithubLoader:run(debug)
    setupFile:run(debug)
end