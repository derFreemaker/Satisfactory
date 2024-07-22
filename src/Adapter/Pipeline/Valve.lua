local ProxyReference = require("Core.Reference.ProxyReference")

---@class Adapter.Pipeline.Valve : object
---@field private m_iPAddress Net.IPAddress
---@field private m_valve Core.Ref<Satis.Build_Valve_C>
---@overload fun(id: FIN.UUID) : Adapter.Pipeline.Valve
local Valve = {}

---@param nickName string?
---@return FIN.UUID[]
function Valve.Static__FindAllValveIdsInNetwork(nickName)
	local valveIds = {}
	if nickName == nil then
		valveIds = component.findComponent(classes.Build_Valve_C)
	else
		valveIds = component.findComponent(nickName)
	end
	return valveIds
end

---@param nickName string?
---@return Adapter.Pipeline.Valve[]
function Valve.Static__GetAllValvesInNetwork(nickName)
	local valveIds = Valve.Static__FindAllValveIdsInNetwork(nickName)

	---@type Adapter.Pipeline.Valve[]
	local valveAdapters = {}
	for _, valveId in ipairs(valveIds) do
		table.insert(valveAdapters, Valve(valveId))
	end

	return valveAdapters
end

---@private
---@param id FIN.UUID
function Valve:__init(id)
	local valve = ProxyReference(id)
	if not valve:Fetch() then
		error("was not found")
	end

	self.m_valve = valve
end

---@return FIN.UUID
function Valve:GetId()
	return self.m_valve:Get().id
end

---@return string
function Valve:GetNick()
	return self.m_valve:Get().nick
end

--- Closes the valve so nothing goes through it anymore.
function Valve:Close()
	self.m_valve:Get().userFlowLimit = 0
end

--- Opens the value so it can go as much through as the pipe allows.
function Valve:Open()
	self.m_valve:Get().userFlowLimit = -1
end

---@return number
function Valve:GetFlow()
	return self.m_valve:Get().flow
end

---@param amountPct number
function Valve:SetFlowLimitPercentage(amountPct)
	self.m_valve:Get().userFlowLimit = amountPct / 10
end

---@param amount number 0 = nothing; 10 = max
function Valve:SetFlowLimit(amount)
	self.m_valve:Get().userFlowLimit = amount
end

---@return number flowLimit
function Valve:GetFlowLimitPercentage()
	return self.m_valve:Get().userFlowLimit * 10
end

---@return number flowLimit
function Valve:GetFlowLimit()
	return self.m_valve:Get().userFlowLimit
end

return class("Adapter.Pipeline.Valve", Valve)
