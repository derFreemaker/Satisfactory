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
        IsFolder = true,
        {"Serializer.lua"}
    }
}

function Main:Configure(debug)
    ModuleLoader.LoadModules(self.SetupFilesTree, debug)

    if debug then
        print("DEBUG! loaded modules")
    end
end

function Main:Run(debug)
    local serializer = ModuleLoader.GetModule("Serializer")
end

return Main