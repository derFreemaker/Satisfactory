local ClassManipulation = require("Ficsit-Networks_Sim.Utils.ClassManipulation")
local Path = require("Ficsit-Networks_Sim.Filesystem.Path")

-- //TODO: complete Components

---@class Ficsit_Networks_Sim.Component.ComponentManager
---@field private entitiesPath Ficsit_Networks_Sim.Filesystem.Path
---@field private registeredComponents Array<Ficsit_Networks_Sim.Component.Entities.Object>
---@field private components Array<Ficsit_Networks_Sim.Component.Component>
local ComponentManager = {}
ComponentManager.__index = ComponentManager

---@param simLibPath Ficsit_Networks_Sim.Filesystem.Path
---@return Ficsit_Networks_Sim.Component.ComponentManager
function ComponentManager.new(simLibPath)
    simLibPath = simLibPath:Copy()
    return setmetatable({
        entitiesPath = simLibPath
            :Append("Component")
            :Append("Entities"),
        registeredComponents = {}
    }, ComponentManager)
end

---@param path Ficsit_Networks_Sim.Filesystem.Path
---@return boolean success
function ComponentManager:LoadComponentClass(path)
    if not path:GetFileExtension() == ".lua" then
        return true
    end
    ---@type Ficsit_Networks_Sim.Component.Entities.Object
    local component = loadfile(path:GetPath())(ClassManipulation.useBase)
    local componentType = component:GetType()
    for _, registeredComponent in ipairs(self.registeredComponents) do
        if registeredComponent:GetType() == componentType then
            print("Unable to register component twice: '" .. componentType .. "'")
            return false
        end
    end
    table.insert(self.registeredComponents, component)
    return true
end

---@private
---@param path Ficsit_Networks_Sim.Filesystem.Path
---@return boolean success
function ComponentManager:loadFolder(path)
    local result = io.popen("dir \"" .. path:GetPath() .. "\" /b /a:-D /o 2>NUL", "r")
    if not result then
        error("Unable to run 'dir' command with path: '".. path .."'")
    end
    for line in result:lines() do
        if not self:LoadComponentClass(path:Extend(line)) then
            return false
        end
    end
    result = io.popen("dir \"" .. path:GetPath() .. "\" /b /a:D /o 2>NUL", "r")
    if not result then
        error("Unable to run 'dir' command with path: '" .. path .. "'")
    end
    for line in result:lines() do
        if not self:loadFolder(path:Extend(line)) then
            return false
        end
    end
    return true
end

---@param pathStr string | nil
---@return boolean success
function ComponentManager:LoadComponentClasses(pathStr)
    local path = self.entitiesPath
    if pathStr then
        path = Path.new(pathStr)
    end
    return self:loadFolder(path)
end

---@generic TComponent
---@param type string
---@return TComponent, boolean
function ComponentManager:GetComponentClass(type)
    for _, component in ipairs(self.registeredComponents) do
        if component:GetType() == type then
            return component, true
        end
    end
    return nil, false
end

---@param id string
---@return Array<Ficsit_Networks_Sim.Component.Entities.Object>
function ComponentManager:GetComponentWithId(id)
    for _, component in ipairs(self.components) do
        if component.Id == id then
            return {component:Build(self)}
        end
    end
    return {}
end

---@param nickname string
---@return Array<Ficsit_Networks_Sim.Component.Entities.Object>
function ComponentManager:GetComponentsWithNickname(nickname)
    ---@type Array<Ficsit_Networks_Sim.Component.Entities.Object>
    local foundComponents = {}
    for _, component in ipairs(self.components) do
        if component.Nickname and component.Nickname == nickname then
            table.insert(foundComponents, component:Build(self))
        end
    end
    return foundComponents
end

---@param class Ficsit_Networks_Sim.Component.Entities.Object
---@return Array<Ficsit_Networks_Sim.Component.Entities.Object>
function ComponentManager:GetComponentsWithClass(class)
    ---@type Array<Ficsit_Networks_Sim.Component.Entities.Object>
    local foundComponents = {}
    for _, component in ipairs(self.components) do
        if component.Type == class:GetType() then
            table.insert(foundComponents, component:Build(self))
        end
    end
    return foundComponents
end

---@param config Ficsit_Networks_Sim.Component.Config
function ComponentManager:Configure(config)
    self.components = config.Components
end

return ComponentManager