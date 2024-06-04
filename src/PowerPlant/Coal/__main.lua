local EventPullAdapter = require("Core.Event.EventPullAdapter")

local ValveAdapter = require("Adapter.Pipeline.Valve")
local FactoryControlClient = require("FactoryControl.Client.Client")

---@class PowerPlant.Coal.Main : Github_Loading.Entities.Main
---@field private m_hotSteamValves Adapter.Pipeline.Valve[]
local Main = {}

function Main:Configure()
	if not Config.Name then
		computer.panic("'Config.Name' must be set");
	end

	self.m_hotSteamValves = ValveAdapter.Static__GetAllValvesInNetwork()
end

function Main:Run()
	local factoryClient = FactoryControlClient(self.Logger:subLogger("FactoryControlClient"))
	local controller = factoryClient:Connect(Config.Name)

	---@type { Feature: FactoryControl.Client.Entities.Controller.Feature.Chart, Adapter: Adapter.Pipeline.Valve }[]
	local valves = {}
	for _, valve in pairs(self.m_hotSteamValves) do
		local feature = controller:AddChart("steam valve: " .. valve:GetId())
		table.insert(valves, { Feature = feature, Adapter = valve })
	end

	while true do
		EventPullAdapter:Wait(5)

		for _, valve in ipairs(valves) do
			valve.Feature:Modify(function (modify)
				modify.Data[({computer.magicTime()})[1]] = valve.Adapter:GetFlow()
			end)
		end
	end
end

return Main
