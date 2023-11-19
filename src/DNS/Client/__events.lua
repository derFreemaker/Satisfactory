---@class DNS.Client.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    require("DNS.Client.Hosting.HostExtensions")
end

return Events
