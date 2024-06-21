-- 0 .. 10000

---@enum Core.PortUsage
local PortUsage = {
	-- HotReload
	HotReload = 1,

	-- DNS
	DNS_Heartbeat = 10,
	DNS = 53,

	HTTP = 80,

	-- FactoryControl
	FactoryControl_Heartbeat = 1250,
	FactoryControl = 1251,

	-- Callback
	CallbackService = 2400,
	CallbackService_Response = 2401,

	-- TDS (TrainDistributionSystem)
	TDS = 3200,
	TDS_Heartbeat = 3201,
}

return PortUsage
