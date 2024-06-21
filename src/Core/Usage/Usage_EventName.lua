---@enum Core.EventNameUsage
local EventNameUsage = {
    -- DNS
    DNS_Heartbeat = "DNS",
    DNS_GetServerAddress = "Get-DNS-Server-Address",
    DNS_ReturnServerAddress = "Return-DNS-Server-Address",

    -- Rest
    RestRequest = "Rest-Request",
    RestResponse = "Rest-Response",

    -- FactoryControl
    FactoryControl_Heartbeat = "FactoryControl",
    FactoryControl_Feature_Update = "FactoryControl-Feature-Update",

    -- CallbackService
    CallbackService_Request = "CallbackService-Request",
    CallbackService_Response = "CallbackService-Response",

    -- TDS (TrainDistributionSystem)
    TDS_Heartbeat = "TrainDistributionSystem",

    -- HotReload
    HotReload = "HotReload"
}

return EventNameUsage
