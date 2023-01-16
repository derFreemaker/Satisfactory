---
--- Created by Freemaker
--- DateTime: 15/01/2023
---

local Main = {}
Main.__index = Main

Main.SetupFilesTree = {
    "/",
    {
        "libs",
        {"Serializer.lua"}
    }
}

function Main:Configure()
    print("INFO! called configure function")
end

function Main:Run(debug)
    local serializer = filesystem.doFile("libs/Serializer.lua")

    if serializer then
        print("loaded 'Serializer'")
    end
end

return Main