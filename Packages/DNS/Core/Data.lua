local PackageData = {}

-- ########## DNS.Core ##########

-- ########## DNS.Core.Entities ##########

-- ########## DNS.Core.Entities.Address ##########

PackageData.vvWJKhpz = {
    Namespace = "DNS.Core.Entities.Address.Address",
    Name = "Address",
    FullName = "Address.lua",
    IsRunnable = true,
    Data = [[
local Address = {}
function Address:__call(address, id)
    self.Address = address
    self.Id = id
end
function Address:ExtractData()
    return {
        Address = self.Address,
        Id = self.Id
    }
end
function Address:Static__CreateFromData(data)
    return Address(data.Address, data.Id)
end
function Address:Static__CreateFromCreateAddress(createAddress)
    return Address(createAddress.Address, createAddress.Id)
end
return Utils.Class.CreateClass(Address, "DNS.Entities.Address")
]]
}

PackageData.XKHUhbMZ = {
    Namespace = "DNS.Core.Entities.Address.Create",
    Name = "Create",
    FullName = "Create.lua",
    IsRunnable = true,
    Data = [[
local CreateAddress = {}
function CreateAddress:__call(address, id)
    self.Address = address
    self.Id = id
end
function CreateAddress:ExtractData()
    return {
        Address = self.Address,
        Id = self.Id
    }
end
function CreateAddress:Static__CreateFromData(data)
    return CreateAddress(data.Address, data.Id)
end
return Utils.Class.CreateClass(CreateAddress, "DNS.Entities.Address.Create")
]]
}

-- ########## DNS.Core.Entities.Address ########## --

-- ########## DNS.Core.Entities ########## --

-- ########## DNS.Core ########## --

return PackageData
