---@class Services.Callback.Core.Events : Github_Loading.Entities.Events
local Events = {}

function Events:OnLoaded()
    require("Services.Callback.Core.Extensions.NetworkContextExtensions")
end

return Events
