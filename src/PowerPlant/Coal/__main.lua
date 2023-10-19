local ValveAdapter = require('Adapter.Pipeline.Valve')

---@class PowerPlant.Coal.Main : Github_Loading.Entities.Main
---@field private _HotSteamValves Adapter.Pipeline.Valve[]
local Main = {}

function Main:Configure()
	self._HotSteamValves = ValveAdapter.Static__FindAllValvesInNetworkAndAddAdapter()
end

function Main:Run()
	for _, valve in pairs(self._HotSteamValves) do
		log(valve:GetId(), valve:GetFlowLimit())
	end
end

return Main
