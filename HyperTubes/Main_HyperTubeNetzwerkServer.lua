local Size = 20
local Debug = false
local Aux_screen = false

local fs = filesystem

if fs.initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

local drives = fs.childs("/dev")

local disk_uuid = ""

for idx, drive in pairs(drives) do
    if drive == "serial" then table.remove(drives, idx)
    else disk_uuid = drive end
end

fs.mount("/dev/"..disk_uuid, "/")

print("Current Disk: "..disk_uuid)

local File = filesystem.doFile("MainHyperTubeNetzwerkServer.lua")

File:run(Size, Debug, Aux_screen)