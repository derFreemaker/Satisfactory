---@class ApiEndpoint
---@field Name string
---@field Listener Listener
local ApiEndpoint = {}
ApiEndpoint.__index = ApiEndpoint

---@param name string
---@param listener Listener
---@return ApiEndpoint
function ApiEndpoint.new(name, listener)
    return setmetatable({
        Name = name,
        Listener = listener
    }, ApiEndpoint)
end

---@param logger Logger
---@param context NetworkContext
---@return thread, boolean, 'result'
function ApiEndpoint:Execute(logger, context)
    return self.Listener:Execute(logger, context)
end

return ApiEndpoint