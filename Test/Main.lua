local Main = {}
Main.__index = Main

Main.SetupFilesTree = {
    "/",
    IsFolder = true,
    {
        "shared",
        IsFolder = true,
        IgnoreDownload = true,
        {"Logger.lua"}
    },
    {
        "libs",
        IsFolder = true,
        {"Event.lua"},
        {"EventPullAdapter.lua"},
        {"NetworkCard.lua"},
        {"Serializer.lua"}
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