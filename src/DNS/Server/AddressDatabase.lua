local DbTable = require("Database.DbTable")
local Path = require("Core.Path")
local Address = require("DNS.Core.Entities.Address.Address")


---@class DNS.Server.AddressDatabase : object
---@field private dbTable Database.DbTable
---@overload fun(logger: Core.Logger) : DNS.Server.AddressDatabase
local AddressDatabase = {}


---@private
---@param logger Core.Logger
function AddressDatabase:__init(logger)
    self.dbTable = DbTable("Addresses", Path("/Database/Addresses.db"), logger:subLogger("DbTable"))
    self.dbTable:Load()
end


---@param createAddress DNS.Core.Entities.Address.Create
---@return boolean
function AddressDatabase:Create(createAddress)
    if self:GetWithId(createAddress.Id) then
        return false
    end
    local address = Address:Static__CreateFromCreateAddress(createAddress)
    self.dbTable:Set(address.Id, address:ExtractData())
    return true
end


---@param addressAddress string
---@return boolean
function AddressDatabase:Delete(addressAddress)
    local address = self:GetWithAddress(addressAddress)
    if not address then
        return false
    end
    self.dbTable:Delete(address.Id)
    return true
end


---@param id string
---@return DNS.Core.Entities.Address? address
function AddressDatabase:GetWithId(id)
    for addressId, data in pairs(self.dbTable) do
        if addressId == id then
            return Address:Static__CreateFromData(data)
        end
    end
end


---@param addressAddress string
---@return DNS.Core.Entities.Address? createAddress
function AddressDatabase:GetWithAddress(addressAddress)
    for _, data in pairs(self.dbTable) do
        local address = Address:Static__CreateFromData(data)
        if address.Address == addressAddress then
            return address
        end
    end
end


return Utils.Class.CreateClass(AddressDatabase, "DNS.Server.AddressDatabase")