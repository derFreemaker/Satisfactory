---
--- Created by Freemaker
--- DateTime: 15/01/2023
---

local Main = {}
Main.__index = Main

Main.SetupFilesTree = {
    Name = "/",
    IsFolder = true,
    {
        Name = "libs",
        IsFolder = true,
        {Name = "Serializer.lua"}
    }
}

function Main:Configure(logger)
    ModuleLoader.LoadModules(self.SetupFilesTree)
end

function Main:Run(logger)
    local serializer = ModuleLoader.GetModule("Serializer")
    if serializer ~= nil then
        print("INFO! loaded Serializer")
    else
        print("INFO! Unable to load Serializer")
    end
end

return Main