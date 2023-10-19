local DbTable = require("Database.DbTable")
local Path = require("Core.FileSystem.Path")
local Address = require("DNS.Core.Entities.Address.Address")


---@class DNS.Server.AddressDatabase : object
---@field private _DbTable Database.DbTable
---@overload fun(logger: Core.Logger) : DNS.Server.AddressDatabase
local AddressDatabase = {}

---@private
---@param logger Core.Logger
function AddressDatabase:__init(logger)
    self._DbTable = DbTable("Addresses", Path("/Database/Addresses/"), logger:subLogger("DbTable"))
    self._DbTable:Load()
end

---@param createAddress DNS.Core.Entities.Address.Create
---@return boolean
function AddressDatabase:Create(createAddress)
    if self:GetWithId(createAddress.Id) then
        return false
    end
    local address = Address:Static__CreateFromCreateAddress(createAddress)
    self._DbTable:Set(address.Id, address:ExtractData())

    self._DbTable:Save()
    return true
end

---@param addressAddress string
---@return boolean
function AddressDatabase:Delete(addressAddress)
    local address = self:GetWithAddress(addressAddress)
    if not address then
        return false
    end
    self._DbTable:Delete(address.Id)

    self._DbTable:Save()
    return true
end

---@param id string
---@return DNS.Core.Entities.Address? address
function AddressDatabase:GetWithId(id)
    for addressId, data in pairs(self._DbTable) do
        if addressId == id then
            return Address:Static__CreateFromData(data)
        end
    end
end

---@param addressAddress string
---@return DNS.Core.Entities.Address? createAddress
function AddressDatabase:GetWithAddress(addressAddress)
    for _, data in pairs(self._DbTable) do
        local address = Address:Static__CreateFromData(data)
        if address.Address == addressAddress then
            return address
        end
    end
end

return Utils.Class.CreateClass(AddressDatabase, "DNS.Server.AddressDatabase")
