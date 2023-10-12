---@class Adapter.Pipeline.Valve : object
---@field private valve Satisfactory.Components.Factory.Build_Valve_C
---@overload fun(id: FIN.UUID, valve: Satisfactory.Components.Factory.Build_Valve_C?)
local Valve = {}

---@param nickName string?
---@return FIN.UUID[]
function Valve.Static__FindAllValvesInNetwork(nickName)
	local valveIds = {}
	if nickName == nil then
		valveIds = component.findComponent(findClass('Build_Valve_C'))
	else
		valveIds = component.findComponent(nickName)
	end
	return valveIds
end

---@param nickName string?
---@return Adapter.Pipeline.Valve[]
function Valve.Static__FindAllValvesInNetworkAndAddAdapter(nickName)
	local valveIds = Valve.Static__FindAllValvesInNetwork(nickName)
	local valveAdapters = {}
	for _, valveId in ipairs(valveIds) do
		table.insert(valveAdapters, Valve(valveId))
	end
	return valveAdapters
end

---@private
---@param idOrValve FIN.UUID | Satisfactory.Components.Factory.Build_Valve_C
function Valve:__init(idOrValve)
	if type(idOrValve) == 'string' then
		self.valve = component.proxy(idOrValve) --[[@as Satisfactory.Components.Factory.Build_Valve_C]]
		return
	end
	---@cast idOrValve Satisfactory.Components.Factory.Build_Valve_C
	self.valve = idOrValve
end

---@return FIN.UUID
function Valve:GetId()
	return self.valve.id
end

--- Closes the valve so nothing goes through it anymore.
function Valve:Close()
	self.valve.userFlowLimit = 0
end

--- Opens the value so it can go as much through as the pipe allows.
function Valve:Open()
	self.valve.userFlowLimit = -1
end

---@param amountPct number
function Valve:SetFlowLimitPercentage(amountPct)
	self.valve.userFlowLimit = amountPct / 10
end

---@param amount number 0 = nothing; 10 = max
function Valve:SetFlowLimit(amount)
	self.valve.userFlowLimit = amount
end

---@return number flowLimit
function Valve:GetFlowLimitPercentage()
	return self.valve.userFlowLimit * 10
end

---@return number flowLimit
function Valve:GetFlowLimit()
	return self.valve.userFlowLimit
end

return Utils.Class.CreateClass(Valve, 'Adapter.Pipeline.Valve')
