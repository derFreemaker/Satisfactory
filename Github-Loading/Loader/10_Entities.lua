---@class Github_Loading.Entities
local Entities = {}

---@class Github_Loading.Entities.Main
---@field Logger Core.Logger
local Main = {}

---@param mainModule Github_Loading.Entities.Main
---@return Github_Loading.Entities.Main
function Entities.newMain(mainModule)
    local metatable = {
        __index = Main
    }
    return setmetatable(mainModule, metatable)
end

---@return string | any
function Main:Configure()
    return "$%not found%$"
end

---@return string | any
function Main:Run()
    return "$%not found%$"
end

Entities.Main = Main


---@class Github_Loading.Entities.Events
---@field OnLoaded fun()
local Events = {}

---@param loadModule Github_Loading.Entities.Events
---@return Github_Loading.Entities.Events
function Entities.newEvents(loadModule)
    local metatable = {
        __index = Events
    }
    return setmetatable(loadModule, metatable)
end

Entities.Load = Events


return Entities

-- Types and Classes --

---@class Dictionary<K, T>: { [K]: T }