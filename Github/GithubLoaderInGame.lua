---
--- Created by Freemaker
--- DateTime: 24/10/2022
---

InternetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]

if filesystem:initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

local disk_uuid = filesystem:childs("/dev")[1]

filesystem.initFileSystem("/dev")
filesystem.makeFileSystem("tmpFs", "tmp")
filesystem.mount("/dev/"..disk_uuid,"/")

if filesystem.exists("GithubLoader.lua") == false then
    local req = InternetCard:request("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/Github/GithubLoader.lua", "GET", "")
    local _, libdata = req:await()
    local file = filesystem:open("GithubLoader.lua", "w")
    file:write(libdata)
    file:close()
end

local GithubLoader = filesystem.doFile("GithubLoader.lua")

-- Show Options
--GithubLoader:showOptions()

-- Example
--GithubLoader:download("Test")

GithubLoader:run(false)