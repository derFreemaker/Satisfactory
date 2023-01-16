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
    ModuleLoader:Load("Serializer", "Serializer.lua")

    print("INFO! called configure function")
end

function Main:Run(debug)
    local serializer = ModuleLoader:GetModule("Serializer")

    if not serializer then
        print("module loader loded 'Serializer'")
    end
end

return Main