---@type function
local useBase = table.pack(...)[1]
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Component.Entities.Color
---@field r number Red
---@field g number Green
---@field b number Blue
---@field a number Alpha
local Color = useBase({
    type = "Color"
}, Object.new())
Color.__index = Color

---@return Ficsit_Networks_Sim.Component.Entities.Color
function Color.new()
    return setmetatable({}, Color)
end

return Color