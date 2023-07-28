local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Tools = require("Ficsit-Networks_Sim.Utils.Tools")
local Object = require("Ficsit-Networks_Sim.Component.Entities.Object")

---@class Ficsit_Networks_Sim.Component.Entities.Recipe : Ficsit_Networks_Sim.Component.Entities.Object
---@field name string
---@field duration number
---@field private products Array<Struct<Ficsit_Networks_Sim.Component.Entities.ItemAmount>> use Recipe:getProducts()
---@field private ingredients Array<Struct<Ficsit_Networks_Sim.Component.Entities.ItemAmount>> use Recipe:getIngredients()
local Recipe = ClassManipulation.CreateSubclass(Object, "Recipe")
Recipe.__index = Recipe

---@param data table | nil
---@return Ficsit_Networks_Sim.Component.Entities.Recipe
function Recipe.new(data)
    return setmetatable(data or {}, Recipe)
end

---@return Array<Struct<Ficsit_Networks_Sim.Component.Entities.ItemAmount>>
function Recipe:getProducts()
    return self.products
end

---@return Array<Struct<Ficsit_Networks_Sim.Component.Entities.ItemAmount>>
function Recipe:getIngredients()
    return self.ingredients
end

return Recipe