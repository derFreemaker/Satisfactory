local EventPullAdapter = require("Core.Event.EventPullAdapter")

local DistributionSystem = require("TDS.DistributionSystem")

---@class TDS.Server.Main : Github_Loading.Entities.Main
---@field m_distibutionSystem TDS.DistributionSystem
local Main = {}

function Main:Configure()
    self.m_distibutionSystem = DistributionSystem(self.Logger:subLogger("TrainDistributionSystem"))
end

function Main:Run()
	while true do
        EventPullAdapter:Wait(2)

        self.m_distibutionSystem:Save()
	end
end

return Main
