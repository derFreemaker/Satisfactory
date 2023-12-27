---@class Services.Callback.Client.Callback : object
---@field protected Id Core.UUID
---@field protected CallbackMethod string
---@field protected Handler Core.Task?
---@overload fun(id: Core.UUID, callbackMethod: string, handler: Core.Task?) : Services.Callback.Client.Callback
local Callback = {}

---@alias Services.Callback.Client.Callback.Constructor fun(id: Core.UUID, callbackMethod: string, handler: Core.Task?) : Services.Callback.Client.Callback

---@private
---@param id Core.UUID
---@param callbackMethod string
---@param handler Core.Task?
function Callback:__init(id, callbackMethod, handler)
    self.Id = id
    self.CallbackMethod = callbackMethod
    self.Handler = handler
end

---@return Core.UUID
function Callback:GetId()
    return self.Id
end

---@return string
function Callback:GetCallbackMethod()
    return self.CallbackMethod
end

---@param task Core.Task
function Callback:SetHandler(task)
    self.Handler = task
end

---@param id Core.UUID
---@param callbackMethod string
---@return boolean
function Callback:Check(id, callbackMethod)
    if not self.Id:Equals(id) then
        return false
    end

    if self.CallbackMethod ~= callbackMethod then
        return false
    end

    return true
end

---@param logger Core.Logger
---@param args any[]
function Callback:Send(logger, args)
    if not self.Handler then
        return
    end

    self.Handler:Execute(table.unpack(args))
    self.Handler:Close()
    self.Handler:LogError(logger)
end

---@param logger Core.Logger
---@param args any[]
---@return any[] results
function Callback:Invoke(logger, args)
    if not self.Handler then
        return {}
    end

    local results = { self.Handler:Execute(table.unpack(args)) }
    self.Handler:Close()
    self.Handler:LogError(logger, false)
    return results
end

return Utils.Class.Create(Callback, "Services.Callback.Client.Callback")
