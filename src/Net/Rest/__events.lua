---@class Net.Rest.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    require("Net.Rest.Api.NetworkContextExtensions")
end

return Events
