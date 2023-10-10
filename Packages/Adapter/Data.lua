local PackageData = {}

PackageData["AdapterComputerInternetCard"] = {
    Location = "Adapter.Computer.InternetCard",
    Namespace = "Adapter.Computer.InternetCard",
    IsRunnable = true,
    Data = [[
---@class Adapter.InternetCard : object
---@field internetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
local InternetCard = {}

---@param url string
---@param logger Core.Logger?
---@param internetCardAdapter Adapter.InternetCard?
---@return boolean success, string? data, number code
function InternetCard.Static__Download(url, logger, internetCardAdapter)
    if not internetCardAdapter then
        internetCardAdapter = InternetCard()
    end
    if logger then
        logger:LogTrace("downloading from: '" .. url .. "'...")
    end
    local req = internetCardAdapter.internetCard:request(url, 'GET', '')
    repeat
    until req:canGet()
    local code,
    data = req:get()
    if code ~= 200 or data == nil then
        return false, nil, 400
    end
    if logger then
        logger:LogTrace("downloaded from: '" .. url .. "'")
    end
    return true, data, code
end

---@param indexOrInternetCard number | FicsIt_Networks.Components.FINComputerMod.InternetCard_C
function InternetCard:__init(indexOrInternetCard)
    if not indexOrInternetCard then
        indexOrInternetCard = 1
    end

    if type(indexOrInternetCard) == "number" then
        self.internetCard = computer.getPCIDevices(findClass('InternetCard_C'))[indexOrInternetCard]
        if self.internetCard == nil then
            error('no internetCard was found')
        end
        return
    end

    ---@cast indexOrInternetCard FicsIt_Networks.Components.FINComputerMod.InternetCard_C
    self.internetCard = indexOrInternetCard
end

---@param url string
---@param logger Core.Logger?
---@return boolean success, string? data, number code
function InternetCard:Download(url, logger)
    if logger then
        logger:LogTrace("downloading from: '" .. url .. "'...")
    end
    local req = self.internetCard:request(url, 'GET', '')
    repeat
    until req:canGet()
    local code,
    data = req:get()
    if code ~= 200 or data == nil then
        return false, nil, 400
    end
    if logger then
        logger:LogTrace("downloaded from: '" .. url .. "'")
    end
    return true, data, code
end

return Utils.Class.CreateClass(InternetCard, "Adapter.InternetCard")
]]
}

PackageData["AdapterComputerNetworkCard"] = {
    Location = "Adapter.Computer.NetworkCard",
    Namespace = "Adapter.Computer.NetworkCard",
    IsRunnable = true,
    Data = [[
---@class Adapter.Computer.NetworkCard : object
---@field private networkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
---@overload fun(idOrIndexOrNetworkCard: FicsIt_Networks.UUID | integer | FicsIt_Networks.Components.FINComputerMod.NetworkCard_C) : Adapter.Computer.NetworkCard
local NetworkCard = {}

---@private
---@param idOrIndexOrNetworkCard FicsIt_Networks.UUID | integer | FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
function NetworkCard:__init(idOrIndexOrNetworkCard)
	if not idOrIndexOrNetworkCard then
		idOrIndexOrNetworkCard = 1
	end

	if type(idOrIndexOrNetworkCard) == 'string' then
		---@cast idOrIndexOrNetworkCard FicsIt_Networks.UUID
		self.networkCard = component.proxy(idOrIndexOrNetworkCard) --{{{@as FicsIt_Networks.Components.FINComputerMod.NetworkCard_C}}}
		return
	end

	if type(idOrIndexOrNetworkCard) == 'number' then
		self.networkCard = computer.getPCIDevices(findClass('NetworkCard_C'))[idOrIndexOrNetworkCard]
		if self.networkCard == nil then
			error('no networkCard was found')
		end
		return
	end

	---@cast idOrIndexOrNetworkCard FicsIt_Networks.Components.FINComputerMod.NetworkCard_C
	self.networkCard = idOrIndexOrNetworkCard
end

---@return FicsIt_Networks.UUID
function NetworkCard:GetId()
	return self.networkCard.id
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

PackageData["AdapterPipelineValve"] = {
    Location = "Adapter.Pipeline.Valve",
    Namespace = "Adapter.Pipeline.Valve",
    IsRunnable = true,
    Data = [[
---@class Adapter.Pipeline.Valve : object
---@field private valve FicsIt_Networks.Components.Factory.Build_Valve_C
---@overload fun(id: FicsIt_Networks.UUID, valve: FicsIt_Networks.Components.Factory.Build_Valve_C?)
local Valve = {}

---@param nickName string?
---@return FicsIt_Networks.UUID[]
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
---@param idOrValve FicsIt_Networks.UUID | FicsIt_Networks.Components.Factory.Build_Valve_C
function Valve:__init(idOrValve)
	if type(idOrValve) == 'string' then
		self.valve = component.proxy(idOrValve) --{{{@as FicsIt_Networks.Components.Factory.Build_Valve_C}}}
		return
	end
	---@cast idOrValve FicsIt_Networks.Components.Factory.Build_Valve_C
	self.valve = idOrValve
end

---@return FicsIt_Networks.UUID
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
]]
}

return PackageData
