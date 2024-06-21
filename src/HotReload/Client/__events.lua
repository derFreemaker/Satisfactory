---@class HotReload.Client.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    require("HotReload.Client.Extensions.HostExtensions")
end

return Events
