---@using Net.Core
---@using HotReload.Client

local Usage = require("Core.Usage.init")

local Host = require("Hosting.Host")
local InternetCard = require("Adapter.Computer.InternetCard")
local Url = require("Core.Common.Url")

local HotReloadPath = "/HotReload/latest"

---@class HotReload.Server.Main : Github_Loading.Entities.Main
---@field m_host Hosting.Host
local Main = {}

function Main:Configure()
	self.m_host = Host(self.Logger:subLogger("Host"), "Host")

	self.m_host:AddHotReload()
end

function Main:Run()
	if not Config.HotReloadUrl or type(Config.HotReloadUrl) ~= "string" then
        computer.panic("Config.HotReloadUrl not set or not string")
    end
    local baseUrl = Url(Config.HotReloadUrl)
    local logger = self.m_host:GetLogger()():subLogger("HotReload")

	local networkClient = self.m_host:GetNetworkClient() 
    local internetCard = InternetCard()
	local latestUrl = baseUrl:Extend("/HotReload/latest")

	while true do
		self.m_host:RunCycle(1)

		logger:LogTrace("checking...")
		local success, data = internetCard:Download(latestUrl:GetUrl(), logger)

		if not filesystem.exists(HotReloadPath) then
			if not success then
				computer.panic("unable to connect download from Config.HotReloadUrl")
			end

			Utils.File.Write(HotReloadPath, "w", data, true)
		elseif Utils.File.ReadAll(HotReloadPath) ~= data then
			networkClient:BroadCast(Usage.Ports.HotReload, Usage.Events.HotReload)
		end

    	logger:LogDebug("no HotReload")
	end
end

return Main
