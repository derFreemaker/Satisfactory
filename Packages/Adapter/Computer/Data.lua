---@meta
local PackageData = {}

PackageData["AdapterComputerInternetCard"] = {
    Location = "Adapter.Computer.InternetCard",
    Namespace = "Adapter.Computer.InternetCard",
    IsRunnable = true,
    Data = [[
---@class Adapter.InternetCard : object
---@field internetCard FIN.Components.FINComputerMod.InternetCard_C
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

---@param indexOrInternetCard number | FIN.Components.FINComputerMod.InternetCard_C
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

    ---@cast indexOrInternetCard FIN.Components.FINComputerMod.InternetCard_C
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
---@field private networkCard FIN.Components.FINComputerMod.NetworkCard_C
---@overload fun(idOrIndexOrNetworkCard: FIN.UUID | integer | FIN.Components.FINComputerMod.NetworkCard_C) : Adapter.Computer.NetworkCard
local NetworkCard = {}

---@private
---@param idOrIndexOrNetworkCard FIN.UUID | integer | FIN.Components.FINComputerMod.NetworkCard_C
function NetworkCard:__init(idOrIndexOrNetworkCard)
	if not idOrIndexOrNetworkCard then
		idOrIndexOrNetworkCard = 1
	end

	if type(idOrIndexOrNetworkCard) == 'string' then
		---@cast idOrIndexOrNetworkCard FIN.UUID
		self.networkCard = component.proxy(idOrIndexOrNetworkCard) --{{{@as FIN.Components.FINComputerMod.NetworkCard_C}}}
		return
	end

	if type(idOrIndexOrNetworkCard) == 'number' then
		self.networkCard = computer.getPCIDevices(findClass('NetworkCard_C'))[idOrIndexOrNetworkCard]
		if self.networkCard == nil then
			error('no networkCard was found')
		end
		return
	end

	---@cast idOrIndexOrNetworkCard FIN.Components.FINComputerMod.NetworkCard_C
	self.networkCard = idOrIndexOrNetworkCard
end

---@return FIN.UUID
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

---@param address Net.Core.IPAddress
---@param port integer
---@param ... any
function NetworkCard:Send(address, port, ...)
	self.networkCard:send(address:GetAddress(), port, ...)
end

---@param port integer
---@param ... any
function NetworkCard:BroadCast(port, ...)
	self.networkCard:broadcast(port, ...)
end

return Utils.Class.CreateClass(NetworkCard, 'Adapter.Computer.NetworkCard')
]]
}

return PackageData
