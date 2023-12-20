local BaseUrl = "http://localhost"
-- local BaseUrl = 'https://raw.githubusercontent.com/derFreemaker/Satisfactory/main'

local InstallUrl = BaseUrl .. "/OS/Install"
local ToolsUrl = BaseUrl .. "/Tools.lua"

local OSPath = "/OS"

local InstallPath = OSPath .. "/Install"
local ToolsPath = InstallPath .. "/Tools.lua"

-- # Initialize
print("initializing...")

---@type FIN.Components.InternetCard_C
local internetCard = computer.getPCIDevices(classes.FINInternetCard)[1]
if not internetCard then
    computer.beep(0.2)
    error('No internet-card found!')
    return
end
filesystem.initFileSystem('/dev')
local drive = ''
for _, child in pairs(filesystem.childs('/dev')) do
    if not (child == 'serial') then
        drive = child
        break
    end
end
if drive:len() < 1 then
    computer.beep(0.2)
    error('Unable to find filesystem to load on! Insert a drive or floppy.')
    return
end
filesystem.mount('/dev/' .. drive, '/')

print("initialized")

local req = internetCard:request(ToolsUrl, 'GET', '')
repeat
until req:canGet()
local _, libData = req:get()
local file = filesystem.open(ToolsPath, 'w')
file:write(libData)
file:close()

---@type OS.Installer.Tools
local Tools = filesystem.doFile(ToolsPath)

-- # OS Data load
local bootCode = ""

-- # Cleanup
filesystem.remove(InstallPath, true)
computer.setEEPROM(bootCode)

warn("# close the window until the beep")
event.pull(5)
computer.beep(2)

computer.reset()
