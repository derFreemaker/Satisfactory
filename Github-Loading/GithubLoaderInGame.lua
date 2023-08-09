-- if option is nil it will show you all options
local option = nil
local showExtendOptionDetails = false

-- logLevel
-- 0 = Trace / 1 = Debug / 2 = Info / 3 = Warning / 4 = Error
local loaderLogLevel = 2
local programLogLevel = 2

-- forceDownload
local loaderForceDownload = false
local programForceDownload = false

-- Config --
-- to define any config variables
Config = {}

local GithubLoaderBaseUrl = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/Module-Bundling"

-- ########## Don't touch that ########## --
local GithubLoaderUrl = GithubLoaderBaseUrl .. "/Github-Loading/GithubLoader.lua"
local GithubLoaderFilesFolderPath = "Github-Loading"
local GithubLoaderPath = GithubLoaderFilesFolderPath .. "/GithubLoader.lua"

---@type FicsIt_Networks.Components.FINComputerMod.FINInternetCard
local internetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]
if not internetCard then
    computer.beep(0.2)
    error("No internet-card found!")
    return
end

-- //TODO: debug message
print("[Computer] DBUG! found internet-card")

filesystem.initFileSystem("/dev")

local drive = ""
for _, child in pairs(filesystem.childs("/dev")) do
    if not (child == "serial") then
        drive = child
        break
    end
end
if drive:len() < 1 then
    computer.beep(0.2)
    error("Unable to find filesystem to load on! Insert a drive or floppy.")
    return
end
filesystem.mount("/dev/" .. drive, "/")

-- //TODO: debug message
print("[Computer] DBUG! mounted filesystem on drive: " .. drive)

if not filesystem.exists(GithubLoaderFilesFolderPath) then
    filesystem.createDir(GithubLoaderFilesFolderPath)
end

if not filesystem.exists(GithubLoaderPath) then
    print("[Computer] INFO! downloading Github loader...")
    local req = internetCard:request(GithubLoaderUrl, "GET", "")
    local _, libdata = req:await()
    ---@cast libdata string
    local file = filesystem.open(GithubLoaderPath, "w")
    if file == nil then
        error("Unable to open file: '" .. GithubLoaderPath .. "'")
    end
    file:write(libdata)
    file:close()
    print("[Computer] INFO! downloaded Github loader")
end

---@type GithubLoader
local GithubLoader = filesystem.doFile(GithubLoaderPath)
if GithubLoader == nil then
    error("Unable to load GithubLoader")
end
GithubLoader = GithubLoader.new(GithubLoaderBaseUrl, "", loaderForceDownload, internetCard):Initialize(loaderLogLevel)

if option == nil then
    GithubLoader:ShowOptions(showExtendOptionDetails)
else
    GithubLoader:Run(option, programLogLevel, programForceDownload)
end