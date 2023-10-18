---@enum Core.EventNameUsage
local EventNameUsage = {
    -- DNS
    DNS_Heartbeat = "DNS",
    DNS_ReturnServerAddress = "Return-DNS-Server-Address",

    -- Rest
    RestRequest = "Rest-Request",
    RestResponse = "Rest-Response",

    -- FactoryControl
    FactoryControl = "FactoryControl"
}

return EventNameUsage
