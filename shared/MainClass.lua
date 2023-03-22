---@class Main
---@field Logger Logger
---@field SetupFilesTree table
local Main = {}
Main.__index = Main

---@param mainModule table
function Main.new(mainModule)
    return setmetatable({
        Logger = mainModule.Logger or {},
        SetupFilesTree = mainModule.SetupFilesTree or {},
        Configure = mainModule.Configure,
        Run = mainModule.Run
    }, Main)
end

---@return string | any
function Main:Configure()
    return "$%not found%$"
end

---@return string | any
function Main:Run()
    return "$%not found%$"
end

return Main