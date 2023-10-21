---@meta
local PackageData = {}

PackageData["HostingHost"] = {
    Location = "Hosting.Host",
    Namespace = "Hosting.Host",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local JsonSerializer = require("Core.Json.JsonSerializer")

---@class Hosting.Host : object
---@field private _JsonSerializer Core.Json.Serializer
---@field private _Logger Core.Logger
---@field private _Name string
---@field private _Ready boolean
---@overload fun(logger: Core.Logger, name: string?, jsonSerializer: Core.Json.Serializer?) : Hosting.Host
local Host = {}

--#region - Core -

---@private
---@param logger Core.Logger
---@param name string?
---@param jsonSerializer Core.Json.Serializer?
function Host:__init(logger, name, jsonSerializer)
    self._JsonSerializer = jsonSerializer or JsonSerializer.Static__Serializer
    self._Logger = logger
    self._Name = name or "Host"
    self._Ready = false

    EventPullAdapter:Initialize(logger:subLogger("EventPullAdapter"))
    self._Logger:LogDebug(self._Name .. "starting...")
end

function Host:GetJsonSerializer()
    return self._JsonSerializer
end

function Host:Ready()
    if self._Ready then
        return
    end

    self._Logger:LogDebug(self._Name .. " started")
    self._Ready = true
end

function Host:Run()
    self:Ready()

    EventPullAdapter:Run()
end

---@param timeoutSeconds number?
function Host:RunCycle(timeoutSeconds)
    EventPullAdapter:WaitForAll(timeoutSeconds)
end

--#endregion

--#region - Logger -

---@param name string
---@return Core.Logger logger
function Host:CreateLogger(name)
    return self._Logger:subLogger(name)
end

--#endregion

return Utils.Class.CreateClass(Host, "Hosting.Host")
]]
}

return PackageData
