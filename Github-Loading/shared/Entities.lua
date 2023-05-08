---@class Entities
local Entities = {}

---@class Main
Entities.Main = {}
Entities.Main.__index = Entities.Main

---@param mainModule table
---@return Main
function Entities.Main.new(mainModule)
    local instance = setmetatable({
        SetupFilesTree = mainModule.SetupFilesTree,
        Configure = mainModule.Configure,
        Run = mainModule.Run
    }, Entities.Main)
    return instance
end

---@param logger Logger
---@return string | any
function Entities.Main:Configure(logger)
    return "$%not found%$"
end

---@return string | any
function Entities.Main:Run()
    return "$%not found%$"
end

return Entities