local vertex = nil
local connections = {}
local name = nil

local gpu = computer.getPCIDevices(findClass("GPUT1"))[1]
local screen = component.proxy("");

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

local File = filesystem.doFile("NodeHyperTubeNetzwerkServer.lua")

screen = component.proxy(screen)
gpu:bindScreen(screen)
event.listen(gpu)

fs.doFile("PageScroller.lua")
fs.doFile("AuxiliaryServer.lua")

File:run_with_screen(vertex, connections, name, screen, gpu)