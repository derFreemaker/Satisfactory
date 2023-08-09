-- if option is empty it will show you all options
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

local GithubLoaderBaseUrl = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/Module-Bundling"

local GithubLoaderUrl = GithubLoaderBaseUrl .. "/Github-Loading/GithubLoader.lua"
local GithubLoaderFilesFolderPath = "Github-Loading"
local GithubLoaderPath = filesystem.path(GithubLoaderFilesFolderPath, "GithubLoader.lua")

computer.beep(5.0)
local internetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]
if not internetCard then
    print("[Computer] ERROR! No internet-card found! Please install a internet card!")
    computer.beep(0.2)
    return
end
print("[Computer] INFO! found internet-card")

filesystem.initFileSystem("/dev")

local drive = ""
for _, child in pairs(filesystem.childs("/dev")) do
    if not (child == "serial") then
        drive = child
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
    local req = internetCard:request(GithubLoaderUrl, "GET", "")
    local _, libdata = req:await()
    local file = filesystem.open(GithubLoaderPath, "w")
    if file == nil then
        error("Unable to open file: '".. GithubLoaderPath .."'")
    end
    file:write(libdata)
    file:close()
    print("[Computer] INFO! downloaded Github loader")
end

-- Initialize([logLevel:int], [forceDownload:boolean])
---@type GithubLoader
local GithubLoader = filesystem.doFile(GithubLoaderPath)
if GithubLoader == nil then
    error("Unable to load GithubLoader")
end
GithubLoader = GithubLoader.new(GithubLoaderBaseUrl, "", loaderForceDownload, internetCard)
GithubLoader:Initialize(loaderLogLevel)

if option == "" then
    -- GithubLoader:ShowOptions([extended:boolean])
    GithubLoader:ShowOptions(extendOptionDetails)
else
    -- GithubLoader:Run([option:string], [logLevel:int], [forceDownload:boolean])
    GithubLoader:Run(option, programLogLevel, programForceDownload)
end
