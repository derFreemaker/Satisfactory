---@class Entities
local Entities = {}

---@class Main
---@field Logger Github_Loading.shared.Logger
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

---@return string | any
function Entities.Main:Configure()
    return "$%not found%$"
end

---@return string | any
function Entities.Main:Run()
    return "$%not found%$"
end

return Entities