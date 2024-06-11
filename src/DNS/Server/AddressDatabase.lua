local DbTable = require("Database.DbTable")
local Path = require("Core.FileSystem.Path")
local Address = require("DNS.Core.Entities.Address.Address")

local UUID = require("Core.Common.UUID")

---@class DNS.Server.AddressDatabase : object
---@field private m_dbTable Database.DbTable | table<string, DNS.Core.Entities.Address>
---@overload fun(logger: Core.Logger) : DNS.Server.AddressDatabase
local AddressDatabase = {}

---@private
---@param logger Core.Logger
function AddressDatabase:__init(logger)
    self.m_dbTable = DbTable(Path("/Database/Addresses/"), logger:subLogger("DbTable"))
    self.m_dbTable:Load()
end

---@param createAddress DNS.Core.Entities.Address.Create
---@return boolean
function AddressDatabase:Create(createAddress)
    if self:GetWithDomain(createAddress.Domain) then
        return false
    end

    local address = Address(UUID.Static__New(), createAddress.Domain, createAddress.IPAddress)
    self.m_dbTable:Set(address.Id:ToString(), address)

    self.m_dbTable:Save()
    return true
end

---@param id Core.UUID
---@return boolean
function AddressDatabase:DeleteById(id)
    self.m_dbTable:Delete(id:ToString())

    self.m_dbTable:Save()
    return true
end

---@param addressAddress string
---@return boolean
function AddressDatabase:DeleteByUrl(addressAddress)
    local address = self:GetWithDomain(addressAddress)
    if not address then
        return false
    end

    self.m_dbTable:Delete(address.Id:ToString())

    self.m_dbTable:Save()
    return true
end

---@param addressId Core.UUID
---@return DNS.Core.Entities.Address? address
function AddressDatabase:GetWithId(addressId)
    for id, address in pairs(self.m_dbTable) do
        if id == addressId:ToString() then
            return address
        end
    end
end

---@param addressAddress string
---@return DNS.Core.Entities.Address? createAddress
function AddressDatabase:GetWithDomain(addressAddress)
    for _, address in pairs(self.m_dbTable) do
        if address.Domain == addressAddress then
            return address
        end
    end
end

return class("DNS.Server.AddressDatabase", AddressDatabase)
