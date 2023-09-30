local PackageData = {}

PackageData.eyRiSnwa = {
    Location = "PowerPlant.Coal.__main",
    Namespace = "PowerPlant.Coal.__main",
    IsRunnable = true,
    Data = [[
local ValveAdapter = require('Adapter.Pipeline.Valve')

---@class PowerPlant.Coal.Main : Github_Loading.Entities.Main
---@field private hotSteamValves Adapter.Pipeline.Valve[]
local Main = {}

function Main:Configure()
	self.hotSteamValves = ValveAdapter.Static__FindAllValvesInNetwork()
end

function Main:Run()
	for _, valve in pairs(self.hotSteamValves) do
		log(valve:GetId(), valve:GetFlowLimit())
	end
end

return Main
]]
}

return PackageData
