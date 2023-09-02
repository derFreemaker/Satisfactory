---@class DNS.Core.Entities.Address.Create
---@field Address string
---@field Id string
---@overload fun(address: string, id: string) : DNS.Core.Entities.Address.Create
local CreateAddress = {}

---@private
---@param address string
---@param id string
function CreateAddress:__call(address, id)
    self.Address = address
    self.Id = id
end

---@return table data
function CreateAddress:ExtractData()
    return {
        Address = self.Address,
        Id = self.Id
    }
end

---@param data table
---@return DNS.Core.Entities.Address.Create entitiy
function CreateAddress:Static__CreateFromData(data)
    return CreateAddress(data.Address, data.Id)
end

return Utils.Class.CreateClass(CreateAddress, "DNS.Entities.Address.Create")
