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
