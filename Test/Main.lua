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
    logger:LogInfo("called configure function")
end

function Main:Run(logger)
    local serializer = ModuleLoader.GetModule("Serializer")
    if serializer ~= nil then
        logger:LogInfo("loaded Serializer")
    else
        logger:LogInfo("Unable to load Serializer")
    end
end

return Main