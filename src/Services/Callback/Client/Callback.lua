---@class Services.Callback.Client.Callback : object
---@field private m_id Core.UUID
---@field private m_callbackMethod string
---@field private m_handler Core.Task
---@overload fun(id: Core.UUID, callbackMethod: string, handler: Core.Task) : Services.Callback.Client.Callback
local Callback = {}

---@private
---@param id Core.UUID
---@param callbackMethod string
---@param handler Core.Task
function Callback:__init(id, callbackMethod, handler)
    self.m_id = id
    self.m_callbackMethod = callbackMethod
    self.m_handler = handler
end

---@return Core.UUID
function Callback:GetId()
    return self.m_id
end

---@return string
function Callback:GetCallbackMethod()
    return self.m_callbackMethod
end

---@param id Core.UUID
---@param callbackMethod string
---@return boolean
function Callback:Check(id, callbackMethod)
    if not self.m_id:Equals(id) then
        return false
    end

    if self.m_callbackMethod ~= callbackMethod then
        return false
    end

    return true
end

---@param logger Core.Logger
---@param args any[]
---@return any[] results
function Callback:Invoke(logger, args)
    local results = { self.m_handler:Execute(table.unpack(args)) }
    self.m_handler:LogError(logger)
    return results
end

return Utils.Class.CreateClass(Callback, "Services.Callback.Client.Callback")
