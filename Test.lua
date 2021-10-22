local fs = filesystem

if fs.initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

local disk_uuid = "88F8D19A43E9C554620135B3D8C11E33"

fs.mount("/dev/"..disk_uuid, "/")

local File = fs.open("/dev/"..disk_uuid, "/Devices.Satis", "r")

