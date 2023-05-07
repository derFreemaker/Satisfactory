-- if option is equeals to '%show%' it will show you all options
local option = ""
local extendOptionDetails = false

-- logLevel
-- 0 = Trace / 1 = Debug / 2 = Info / 3 = Warning / 4 = Error
local loaderLogLevel = 2
local programLogLevel = 2

-- forceDownload
local loaderForceDownload = false
local programForceDownload = false

-- Config --
-- to define any config variables
--Config = {}

GithubLoaderBaseUrl = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/Module-Bundling/"



local GithubLoaderUrl = GithubLoaderBaseUrl .. "Github/GithubLoader.lua"
local GithubLoaderFilesFolderPath = "GithubLoaderFiles"
local GithubLoaderPath = filesystem.path(GithubLoaderFilesFolderPath, "GithubLoader.lua")

computer.beep(5.0)
InternetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]
if not InternetCard then
	print("[Computer] ERROR! No internet-card found! Please install a internet card!")
	computer.beep(0.2)
	return
end
print("[Computer] INFO! found internet-card")

filesystem.initFileSystem("/dev")

local drive = ""
for _,f in pairs(filesystem.childs("/dev")) do
	if not (f == "serial") then
		drive = f
		break
	end
end
if drive:len() < 1 then
	print("[Computer] ERROR! Unable to find filesystem to load on! Please insert a drive or floppy!")
	computer.beep(0.2)
	return
end
filesystem.mount("/dev/" .. drive, "/")
print("[Computer] INFO! mounted filesystem on drive: " .. drive)

if not filesystem.exists(GithubLoaderFilesFolderPath) then
	filesystem.createDir(GithubLoaderFilesFolderPath)
end

if not filesystem.exists(GithubLoaderPath) then
	print("[Computer] INFO! downloading Github loader...")
    local req = InternetCard:request(GithubLoaderUrl, "GET", "")
    local _, libdata = req:await()
    local file = filesystem.open(GithubLoaderPath, "w")
    file:write(libdata)
    file:close()
	print("[Computer] INFO! downloaded Github loader")
end

-- Initialize([logLevel:int], [forceDownload:boolean])
local GithubLoader = filesystem.doFile(GithubLoaderPath)
GithubLoader:Initialize(loaderLogLevel, loaderForceDownload)

if option == "%show%" then
	-- GithubLoader:ShowOptions([extended:boolean])
	GithubLoader:ShowOptions(extendOptionDetails)
else
	-- GithubLoader:Run([option:string], [logLevel:int], [forceDownload:boolean])
	GithubLoader:Run(option, programLogLevel, programForceDownload)
end