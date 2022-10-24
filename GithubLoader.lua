---
--- Created by Freemaker
--- DateTime: 24/10/2022
---

GithubLoader = {}
GithubLoader.__index = GithubLoader

local setupFile = {}

local options = {}

function GithubLoader:initialize()
    options[1] = "https://" --HyperTubeNetworkMainServer
    options[2] = "https://" --HyperTubeNetworkNodeServer
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
    internalDownload(url)
end

function GithubLoader:run(debug)
    setupFile:run(debug)
end