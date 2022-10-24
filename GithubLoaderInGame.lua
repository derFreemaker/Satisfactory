---
--- Created by Freemaker
--- DateTime: 24/10/2022
---

---
---  Github Loader Options
---
---  1 -> HyperTubeMainServer
---  2 -> HyperTubeNodeServer
---

local networkCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]
local fs = filesystem

if fs:initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

local disk_uuid = fs:childs("/dev")[1]

fs.initFileSystem("/dev")
fs.makeFileSystem("tmpfs", "tmp")
fs.mount("/dev/"..disk_uuid,"/")

if fs.exists("GithubLoader.lua") == false then
    local req = networkCard:request("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/GithubLoader.lua", "GET", "")
    local _, libdata = req:await()
    local file = fs:open("GithubLoader.lua", "w")
    file:write(libdata)
    file:close()
end

local GithubLoader = fs.doFile("GithubLoader.lua")

GithubLoader:initialize()

-- Show Options
--GithubLoader:showOptions()

GithubLoader:download("Test")
GithubLoader:run(true)