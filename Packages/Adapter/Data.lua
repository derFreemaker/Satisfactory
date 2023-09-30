local PackageData = {}

PackageData.lqndKdvW = {
    Location = "Adapter.Computer.NetworkCard",
    Namespace = "Adapter.Computer.NetworkCard",
    IsRunnable = true,
    Data = [[
---@class Adapter.Computer.NetworkCard : object
---@field private id FicsIt_Networks.UUID
---@field private networkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
---@overload fun(idOrIndexOrNetworkCard: FicsIt_Networks.UUID | integer | FicsIt_Networks.Components.FINComputerMod.NetworkCard_C) : Adapter.Computer.NetworkCard
local NetworkCard = {}

---@private
---@param idOrIndexOrNetworkCard FicsIt_Networks.UUID | integer | FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
function NetworkCard:__init(idOrIndexOrNetworkCard)
	if type(idOrIndexOrNetworkCard) == 'string' then
		---@cast idOrIndexOrNetworkCard FicsIt_Networks.UUID
		self.networkCard = component.proxy(idOrIndexOrNetworkCard) --{{{@as FicsIt_Networks.Components.FINComputerMod.NetworkCard_C}}}
		return
	end

	if type(idOrIndexOrNetworkCard) == 'number' then
		---@cast idOrIndexOrNetworkCard integer
		self.networkCard = computer.getPCIDevices(findClass('NetworkCard_C'))[idOrIndexOrNetworkCard]
		if self.networkCard == nil then
			error('no networkCard was found')
		end
		return
	end

	---@cast idOrIndexOrNetworkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
	self.networkCard = idOrIndexOrNetworkCard
end

---@return string
function NetworkCard:GetId()
	if self.id then
		return self.id
	end

	local splittedPrint = Utils.String.Split(tostring(self.networkCard), ' ')
	self.id = splittedPrint[#splittedPrint] --{{{@as FicsIt_Networks.UUID}}}
	return self.id
end

function NetworkCard:Listen()
	event.listen(self.networkCard)
end

---@param port integer
function NetworkCard:OpenPort(port)
	self.networkCard:open(port)
end

---@param port integer
function NetworkCard:ClosePort(port)
	self.networkCard:close(port)
end

function NetworkCard:CloseAllPorts()
	self.networkCard:closeAll()
end

---@param address string
---@param port integer
---@param ... any
function NetworkCard:Send(address, port, ...)
	self.networkCard:send(address, port, ...)
end

---@param port integer
---@param ... any
function NetworkCard:BroadCast(port, ...)
	self.networkCard:broadcast(port, ...)
end

return Utils.Class.CreateClass(NetworkCard, 'Adapter.Computer.NetworkCard')
]]
}

PackageData.MFYoiWSx = {
    Location = "Adapter.Pipeline.Valve",
    Namespace = "Adapter.Pipeline.Valve",
    IsRunnable = true,
    Data = [[
---@class Adapter.Pipeline.Valve : object
---@field private valve FicsIt_Networks.Components.Factory.Build_Valve_C
---@overload fun(idOrValve: FicsIt_Networks.UUID | FicsIt_Networks.Components.Factory.Build_Valve_C)
local Valve = {}

---@param groupName string?
---@return Adapter.Pipeline.Valve[]
function Valve.Static__FindAllValvesInNetwork(groupName)
	local valves = {}
	if groupName == nil then
		valves = component.findComponent(findClass('Build_Valve_C'))
	else
		valves = component.findComponent(groupName)
	end
	local valveAdapters = {}
	for _, valve in ipairs(valves) do
		table.insert(valveAdapters, Valve(valve))
	end
	return valveAdapters
end

---@private
---@param idOrValve FicsIt_Networks.UUID | FicsIt_Networks.Components.Factory.Build_Valve_C
function Valve:__init(idOrValve)
	if type(idOrValve) == 'string' then
		---@cast idOrValve FicsIt_Networks.UUID
		self.valve = component.proxy(idOrValve) --{{{@as FicsIt_Networks.Components.Factory.Build_Valve_C}}}
		return
	end
	---@cast idOrValve FicsIt_Networks.Components.Factory.Build_Valve_C
	self.valve = idOrValve
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
]]
}

return PackageData
