---
--- Created by Freemaker
--- DateTime: 15/01/2023
---

local Main = {}
Main.__index = Main

Main.SetupFilesTree = {
    "/",
    IsFolder = true,
    {
        "libs",
        IsFolder = true,
        {"Serializer.lua"}
    }
}

function Main:Configure(debug)
    ModuleLoader.LoadModules(self.SetupFilesTree, debug)
end

function Main:Run(debug)
    local serializer = ModuleLoader.GetModule("Serializer")
    if serializer ~= nil then
        print("INFO! loaded Serializer")
    else
        print("INFO! Unable to load Serializer")
    end
end

return Main