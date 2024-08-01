---@class Github_Loading.Entities
local Entities = {}

---@class Github_Loading.Entities.Main
---@field Logger Core.Logger
local Main = {}

Entities.MainNotFound = {}
Entities.ConfigureNotFound = {}

---@param mainModule Github_Loading.Entities.Main
---@return Github_Loading.Entities.Main
function Entities.newMain(mainModule)
    return setmetatable(mainModule, { __index = Main })
end

---@return string | any
function Main:Configure()
    return Entities.ConfigureNotFound
end

---@return string | any
function Main:Run()
    return Entities.MainNotFound
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

---@class Out<T> : { Value: T }
