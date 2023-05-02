---@class Main
---@field Logger Logger
---@field SetupFilesTree Entry
local Main = {}
Main.__index = Main

---@param mainModule table
---@return Main
function Main.new(mainModule)
    local instance = setmetatable({
        SetupFilesTree = mainModule.SetupFilesTree,
        Configure = mainModule.Configure,
        Run = mainModule.Run
    }, Main)
    return instance
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