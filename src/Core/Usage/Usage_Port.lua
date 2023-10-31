-- 0 .. 10000

---@enum Core.PortUsage
local PortUsage = {
	-- DNS
	DNS_Heartbeat = 10,
	DNS = 53,

	HTTP = 80,

	-- FactoryControl
	FactoryControl_Heartbeat = 1250,
	FactoryControl = 1251,
}

return PortUsage
