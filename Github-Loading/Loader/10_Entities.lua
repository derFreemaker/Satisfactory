local LoadedLoaderFiles = table.pack(...)[1]

---@class Github_Loading.Entities
local Entities = {}

---@class Github_Loading.Main
---@field Logger Github_Loading.Logger
local Main = {}

---@param mainModule Github_Loading.Main
---@return Github_Loading.Main
function Entities.newMain(mainModule)
    local metatable = Main
    metatable.__index = Main
    return setmetatable({
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

Entities.Main = Main

return Entities

-- Types and Classes --

---@class Dictionary<K, T>: { [K]: T }