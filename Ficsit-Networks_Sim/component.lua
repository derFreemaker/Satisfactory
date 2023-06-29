local args = table.pack(...)
---@type Ficsit_Networks_Sim.Component.ComponentManager
local ComponentManager = args[1]
local Tools = require("Ficsit-Networks_Sim.Utils.Tools")

---@class Ficsit_Networks_Sim.component
local component = {}
component.__index = component

---@param id string
---@return table | nil
---@overload fun(ids: string[]) : table[] | nil
function component.proxy(id)
    Tools.CheckParameterType(id, { "string", "table" })
    local idType = type(id)
    if idType == "string" then
        return ComponentManager:GetComponentWithId(id)
    elseif idType == "table" then
        ---@type Ficsit_Networks_Sim.Component.Entities.Object[]
        local foundComponents = {}
        for index, componentId in ipairs(id) do
            foundComponents[index] = ComponentManager:GetComponentWithId(componentId)
        end
        if #foundComponents == 0 then
            return nil
        end
        return foundComponents
    end
end

---@param query string | Ficsit_Networks_Sim.Component.Entities.Object
---@return table[]
function component.findComponent(query)
    Tools.CheckParameterType(query, { "string", "table" })
    local queryType = type(query)
    if queryType == "table" then
        return ComponentManager:GetComponentsWithClass(query)
    elseif queryType == "string" then
        return ComponentManager:GetComponentsWithNickname(query)
    end
    return {}
end

return component