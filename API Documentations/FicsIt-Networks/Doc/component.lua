---@meta

--- **Lua Lib:** `component`
---
--- The Component API provides structures, functions and signals for interacting with the network itself like returning network components.
---@class FIN.Component.Api
component = {}


--- Generates and returns instances of the network component with the given UUID.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@param id FIN.UUID - UUID of a network component.
---@return FIN.Component? component
function component.proxy(id) end

--- Generates and returns instances of the network components with the given UUIDs.
--- You can pass any amount of parameters and each parameter will then have a corresponding return value.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@param ... FIN.UUID - UUIDs
---@return FIN.Component? ... - components
function component.proxy(...) end

--- Generates and returns instances of the network components with the given UUIDs.
--- You can pass any amount of parameters and each parameter will then have a corresponding return value.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@param ids FIN.UUID[]
---@return FIN.Component[] components
function component.proxy(ids) end

--- Generates and returns instances of the network components with the given UUIDs.
--- You can pass any amount of parameters and each parameter will then have a corresponding return value.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@param ... FIN.UUID[]
---@return FIN.Component[] ... - components
function component.proxy(...) end

--- Searches the component network for components with the given query.
---@param query string
---@return FIN.UUID[] UUIDs
function component.findComponent(query) end

--- Searches the component network for components with the given query.
--- You can pass multiple parameters and each parameter will be handled separately and returns a corresponding return value.
---@param ... string - querys
---@return FIN.UUID[] ... - UUIDs
function component.findComponent(...) end

--- Searches the component network for components with the given type.
---@param type FIN.Class
---@return FIN.UUID[] UUIDs
function component.findComponent(type) end

--- Searches the component network for components with the given type.
--- You can pass multiple parameters and each parameter will be handled separately and returns a corresponding return value.
---@param ... FIN.Class - classes to search for
---@return FIN.UUID[] ... - UUIDs
function component.findComponent(...) end
