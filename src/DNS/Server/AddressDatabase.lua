local DbTable = require("Database.DbTable")
local Path = require("Core.FileSystem.Path")
local Address = require("DNS.Core.Entities.Address.Address")

local UUID = require("Core.UUID")

---@class DNS.Server.AddressDatabase : object
---@field private _DbTable Database.DbTable | Dictionary<Core.UUID, DNS.Core.Entities.Address>
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
    if self:GetWithUrl(createAddress.Url) then
        return false
    end

    local address = Address(UUID.Static__New(), createAddress.Url, createAddress.IPAddress)
    self._DbTable:Set(address.Id, address)

    self._DbTable:Save()
    return true
end

---@param id Core.UUID
---@return boolean
function AddressDatabase:DeleteById(id)
    self._DbTable:Delete(id)

    self._DbTable:Save()
    return true
end

---@param addressAddress string
---@return boolean
function AddressDatabase:DeleteByUrl(addressAddress)
    local address = self:GetWithUrl(addressAddress)
    if not address then
        return false
    end

    self._DbTable:Delete(address.Id)

    self._DbTable:Save()
    return true
end

---@param addressId Core.UUID
---@return DNS.Core.Entities.Address? address
function AddressDatabase:GetWithId(addressId)
    for id, address in pairs(self._DbTable) do
        if id == addressId then
            return address
        end
    end
end

---@param addressAddress string
---@return DNS.Core.Entities.Address? createAddress
function AddressDatabase:GetWithUrl(addressAddress)
    for _, address in pairs(self._DbTable) do
        if address.Url == addressAddress then
            return address
        end
    end
end

return Utils.Class.CreateClass(AddressDatabase, "DNS.Server.AddressDatabase")
