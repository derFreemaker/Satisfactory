local PCIDeviceReference = require("Core.References.PCIDeviceReference")

local Cache = require("Core.Adapter.Cache")()

---@class Adapter.Computer.InternetCard : Adapter.IAdapter
---@field m_refInternetCard Core.IReference<FIN.Components.InternetCard_C>
---@overload fun(index: integer) : Adapter.Computer.InternetCard
local InternetCard = {}
return class("Adapter.Computer.InternetCard", InternetCard, function()
    ---@private
    ---@param index integer
    function InternetCard:__init(index)
        if not index then
            index = 1
        end

        ---@type Out<Adapter.Computer.InternetCard>
        local internetCardAdapter = {}
        if Cache:TryGet(index, internetCardAdapter) then
            return internetCardAdapter.Value
        end

        local internetCard = PCIDeviceReference(classes.InternetCard_C, index)
        if not internetCard:Fetch() then
            error("no internet card found")
        end

        self.m_refInternetCard = internetCard
        Cache:Add(index, self)
    end

    ---@param url string
    ---@param logger Core.Logger?
    ---@return boolean success, string? data, number statusCode
    function InternetCard:Download(url, logger)
        if logger then
            logger:LogTrace("downloading from: '" .. url .. "'...")
        end

        local req = self.m_refInternetCard:Get():request(url, 'GET', '')
        repeat until req:canGet()

        local code, data = req:get()

        if logger then
            logger:LogTrace("downloaded from: '" .. url .. "'")
        end

        if code > 302 then
            return false, data, code
        end

        return true, data, code
    end
end)
