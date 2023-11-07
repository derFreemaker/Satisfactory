---@meta
local PackageData = {}

PackageData["HostingHost"] = {
    Location = "Hosting.Host",
    Namespace = "Hosting.Host",
    IsRunnable = true,
    Data = [[
local EventPullAdapter = require("Core.Event.EventPullAdapter")
local JsonSerializer = require("Core.Json.JsonSerializer")

local ServiceCollection = require("Hosting.ServiceCollection")

---@class Hosting.Host : object
---@field Services Hosting.ServiceCollection
---@field package m_name string
---@field package m_ready boolean
---@field package m_jsonSerializer Core.Json.Serializer
---@field package m_logger Core.Logger
---@overload fun(logger: Core.Logger, name: string?, jsonSerializer: Core.Json.Serializer?) : Hosting.Host
local Host = {}

---@type Core.Task[]
Host._Static__ReadyTasks = {}

---@private
---@param logger Core.Logger
---@param name string?
---@param jsonSerializer Core.Json.Serializer?
function Host:__init(logger, name, jsonSerializer)
    self.m_jsonSerializer = jsonSerializer or JsonSerializer.Static__Serializer
    self.m_logger = logger
    self.m_name = name or "Host"
    self.m_ready = false

    self.Services = ServiceCollection()

    EventPullAdapter:Initialize(logger:subLogger("EventPullAdapter"))

    for _, task in pairs(self._Static__ReadyTasks) do
        task:Execute(self)
        task:LogError(self.m_logger)
    end

    self.m_logger:LogDebug(self.m_name .. " starting...")
end

function Host:GetName()
    return self.m_name
end

function Host:GetJsonSerializer()
    return self.m_jsonSerializer
end

function Host:GetHostLogger()
    return self.m_logger
end

---@param name string
---@return Core.Logger logger
function Host:CreateLogger(name)
    return self.m_logger:subLogger(name)
end

function Host:Ready()
    if self.m_ready then
        return
    end

    self.m_logger:LogInfo(self.m_name .. " started")
    self.m_ready = true
end

function Host:Run()
    self:Ready()

    EventPullAdapter:Run()
end

---@param timeoutSeconds number?
function Host:RunCycle(timeoutSeconds)
    if not self.m_ready then
        error("cannot run cycle whitout a ready call")
    end

    self.m_logger:LogTrace("running cycle")
    EventPullAdapter:WaitForAll(timeoutSeconds)
end

return Utils.Class.CreateClass(Host, "Hosting.Host")
]]
}

PackageData["HostingServiceCollection"] = {
    Location = "Hosting.ServiceCollection",
    Namespace = "Hosting.ServiceCollection",
    IsRunnable = true,
    Data = [[
---@class Hosting.ServiceCollection : object
---@field private m_services table<string, object>
---@overload fun() : Hosting.ServiceCollection
local ServiceCollection = {}

---@private
function ServiceCollection:__init()
    self.m_services = {}
end

---@param service object
function ServiceCollection:AddService(service)
    self.m_services[typeof(service).Name] = service
end

---@param serviceTypeName string
---@return object?
function ServiceCollection:GetService(serviceTypeName)
    return self.m_services[serviceTypeName]
end

return Utils.Class.CreateClass(ServiceCollection, "Hosting.ServiceCollection")
]]
}

return PackageData
