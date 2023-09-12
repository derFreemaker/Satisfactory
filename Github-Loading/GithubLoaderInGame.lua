local printFunc = print
function print(...)
    local thread = coroutine.running()
    printFunc(debug.traceback(thread, "print called"))
    printFunc(...)
end

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

local BaseUrl = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/Http-Client"

local showDriveUUID = false

-- ########## Don't touch that ########## --
local LoaderFilesUrl = BaseUrl .. "/Github-Loading"
local LoaderUrl = LoaderFilesUrl .. "/Loader.lua"
local LoaderFilesPath = "Loader"
local LoaderPath = LoaderFilesPath .. "/Loader.lua"

---@type FicsIt_Networks.Components.FINComputerMod.InternetCard_C
local internetCard = computer.getPCIDevices(findClass("FINInternetCard"))[1]
if not internetCard then
    computer.beep(0.2)
    error("No internet-card found!")
    return
end
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

if showDriveUUID then
    print("[Computer] DEBUG mounted filesystem on drive: " .. drive)
end

---@return boolean restart
local function Run()
    if not filesystem.exists(LoaderFilesPath) then
        filesystem.createDir(LoaderFilesPath)
    end
    if not filesystem.exists(LoaderPath) or loaderForceDownload then
        print("[Computer] INFO downloading Github Loader...")
        local req = internetCard:request(LoaderUrl, "GET", "")
        repeat until req:canGet()
        local _, libdata = req:get()
        ---@cast libdata string
        local file = filesystem.open(LoaderPath, "w")
        assert(file, "Unable to open file: '" .. LoaderPath .. "'")
        file:write(libdata)
        file:close()
        print("[Computer] INFO downloaded Github Loader")
    end

    -- ######## load Loader Files and initialize ######## --
    ---@type Github_Loading.Loader
    local Loader = filesystem.doFile(LoaderPath)
    assert(Loader, "Unable to load Github Loader")

    Loader = Loader.new(BaseUrl, LoaderFilesPath, loaderForceDownload, internetCard)
    Loader:Load(loaderLogLevel)
    local diffrentVersionFound = Loader:CheckVersion()
    if diffrentVersionFound then
        loaderForceDownload = true
        return true
    end

    -- ######## load option ######## --
    local chosenOption = Loader:LoadOption(option, showExtendOptionDetails)
    local program, package = Loader:LoadProgram(chosenOption, BaseUrl, programForceDownload)

    -- ######## start Program ######## --
    Loader:Configure(program, package, programLogLevel)
    Loader:Run(program)

    return false
end

repeat
    local thread = coroutine.create(function()
        coroutine.yield(Run())
    end)
    local success, result = coroutine.resume(thread)
    if not success then
        print(debug.traceback(thread, result))
    end
    coroutine.close(thread)
until not result or type(result) ~= "boolean"
