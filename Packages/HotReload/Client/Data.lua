local Data={
["HotReload.Client.__events"] = [==========[
---@class HotReload.Client.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    require("HotReload.Client.Extensions.HostExtensions")
end

return Events

]==========],
["HotReload.Client.Extensions.HostExtensions"] = [==========[
---@using Net.Core

local Usage = require("Core.Usage.init")

---@class Hosting.Host
local HostExtensions = {}

function HostExtensions:AddHotReload()
    self:AddCallableEventListener(Usage.Ports.HotReload, Usage.Events.HotReload, function(context)
        self:GetHostLogger():LogInfo("recieved HotReload Signal")
        computer.reset()
    end)
end

Utils.Class.Extend(require("Hosting.Host"), HostExtensions)

]==========],
}

return Data
