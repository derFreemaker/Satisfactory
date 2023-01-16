---
--- Created by Freemaker
--- LastChange: 16/01/2023
---

computer.beep(5.0)
InternetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]
if not InternetCard then
	print("ERROR! No internet-card found! Please install a internet card!")
	computer.beep(0.2)
	return
end
print("INFO! loaded internet")

filesystem.initFileSystem("/dev")

local drive = ""
for _,f in pairs(filesystem.childs("/dev")) do
	if not (f == "serial") then
		drive = f
		break
	end
end
if drive:len() < 1 then
	print("ERROR! Unable to find filesystem to install on! Please insert a drive or floppy!")
	computer.beep(0.2)
	return
end
filesystem.mount("/dev/" .. drive, "/")
print("INFO! loaded filesystem on drive: " .. drive)

if filesystem.exists("GithubLoader.lua") == false then
	print("INFO! downloading Github loader...")
    local req = InternetCard:request("https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/Github/GithubLoader.lua", "GET", "")
    local _, libdata = req:await()
    local file = filesystem.open("GithubLoader.lua", "w")
    file:write(libdata)
    file:close()
	print("INFO! downloaded Github loader")
end

-- Initialize([debug:boolean], [forceDownloadLoaderFiles:boolean])
local GithubLoader = filesystem.doFile("GithubLoader.lua"):Initialize(true, true)

-- Show Options
-- GithubLoader:ShowOptions([extended:boolean], [force:boolean])
GithubLoader:ShowOptions(true, false)

-- GithubLoader:Run([option:string], [forceDownload:boolean], [debug:boolean])
--GithubLoader:Run("Test", false, false)