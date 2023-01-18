local GithubLoaderFilesFolder = "GithubLoaderFiles"
local GithubLoaderPath = filesystem.path(GithubLoaderFilesFolder, "GithubLoader.lua")
local GithubLoaderUrl = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/main/Github/GithubLoader.lua"

computer.beep(5.0)
InternetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]
if not InternetCard then
	print("[Computer] ERROR! No internet-card found! Please install a internet card!")
	computer.beep(0.2)
	return
end
print("[Computer] INFO! loaded internet")

filesystem.initFileSystem("/dev")

local drive = ""
for _,f in pairs(filesystem.childs("/dev")) do
	if not (f == "serial") then
		drive = f
		break
	end
end
if drive:len() < 1 then
	print("[Computer] ERROR! Unable to find filesystem to install on! Please insert a drive or floppy!")
	computer.beep(0.2)
	return
end
filesystem.mount("/dev/" .. drive, "/")
print("[Computer] INFO! loaded filesystem on drive: " .. drive)

if not filesystem.exists(GithubLoaderFilesFolder) then
	filesystem.createDir(GithubLoaderFilesFolder)
end

if filesystem.exists(GithubLoaderPath) == false then
	print("[Computer] INFO! downloading Github loader...")
    local req = InternetCard:request(GithubLoaderUrl, "GET", "")
    local _, libdata = req:await()
    local file = filesystem.open(GithubLoaderPath, "w")
    file:write(libdata)
    file:close()
	print("[Computer] INFO! downloaded Github loader")
end

-- Initialize([debug:boolean])
local GithubLoader = filesystem.doFile(GithubLoaderPath):Initialize(false)

-- Show Options
-- GithubLoader:ShowOptions([extended:boolean], [forceDownload:boolean])
GithubLoader:ShowOptions(true, false)

-- GithubLoader:Run([option:string], [debug:boolean], [forceDownload:boolean])
--GithubLoader:Run("Test", false, false)