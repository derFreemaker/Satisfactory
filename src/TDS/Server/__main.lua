local EventPullAdapter = require("Core.Event.EventPullAdapter")

local DistributionSystem = require("TDS.Server.DistributionSystem")

---@class TDS.Server.Main : Github_Loading.Entities.Main
---@field m_distibutionSystem TDS.Server.DistributionSystem
local Main = {}

function Main:Configure()
    -- add host to host endpoints

    self.m_distibutionSystem = DistributionSystem(self.Logger:subLogger("TrainDistributionSystem"))
end

function Main:Run()
	while true do
        EventPullAdapter:Wait(2)

        self.m_distibutionSystem:Run()
	end
end

return Main
