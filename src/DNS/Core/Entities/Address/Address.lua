---@class DNS.Core.Entities.Address
---@field Address string
---@field Id string
---@overload fun(address: string, id: string) : DNS.Core.Entities.Address
local Address = {}

---@private
---@param address string
---@param id string
function Address:__init(address, id)
    self.Address = address
    self.Id = id
end

---@return table data
function Address:ExtractData()
    return {
        Address = self.Address,
        Id = self.Id
    }
end

---@param data table
---@return DNS.Core.Entities.Address entitiy
function Address:Static__CreateFromData(data)
    return Address(data.Address, data.Id)
end

---@param createAddress DNS.Core.Entities.Address.Create
---@return DNS.Core.Entities.Address
function Address:Static__CreateFromCreateAddress(createAddress)
    return Address(createAddress.Address, createAddress.Id)
end

return Utils.Class.CreateClass(Address, "DNS.Entities.Address")
