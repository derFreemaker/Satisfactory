---@meta

--- Component Api from Documentation and in Code found.
--- [Documentation](https://docs.ficsit.app/ficsit-networks/latest/index.html)
--- [Code](https://github.com/Panakotta00/FicsIt-Networks/tree/master)
--- Date: 08.09.2023
---@class FicsIt_Networks.Component.Api
component = {}


--- Generates and returns instances of the network component with the given UUID.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@param id FicsIt_Networks.UUID UUID of a network component.
---@return FicsIt_Networks.Component component
function component.proxy(id) end

--- Generates and returns instances of the network components with the given UUIDs.
--- You can pass any amount of parameters and each parameter will then have a corresponding return value.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@param ... FicsIt_Networks.UUID UUIDs
---@return FicsIt_Networks.Component ... components
function component.proxy(...) end

--- Generates and returns instances of the network components with the given UUIDs.
--- You can pass any amount of parameters and each parameter will then have a corresponding return value.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@param ids FicsIt_Networks.UUID[]
---@return FicsIt_Networks.Component[] components
function component.proxy(ids) end

--- Generates and returns instances of the network components with the given UUIDs.
--- You can pass any amount of parameters and each parameter will then have a corresponding return value.
--- If a network component cannot be found for a given UUID, nil will be used for the return. Otherwise, an instance of the network component will be returned.
---@param ... FicsIt_Networks.UUID[]
---@return FicsIt_Networks.Component[] ... components
function component.proxy(...) end

--- Searches the component network for components with the given query.
---@param query string
---@return FicsIt_Networks.UUID[] UUIDs
function component.findComponent(query) end

--- Searches the component network for components with the given query.
--- You can pass multiple parameters and each parameter will be handled separately and returns a corresponding return value.
---@param ... string querys
---@return FicsIt_Networks.UUID[] ... UUIDs
function component.findComponent(...) end

--- Searches the component network for components with the given type.
---@param type FicsIt_Networks.Class
---@return FicsIt_Networks.UUID[] UUIDs
function component.findComponent(type) end

--- Searches the component network for components with the given type.
--- You can pass multiple parameters and each parameter will be handled separately and returns a corresponding return value.
---@param ... FicsIt_Networks.Class
---@return FicsIt_Networks.UUID[] ... UUIDs
function component.findComponent(...) end
