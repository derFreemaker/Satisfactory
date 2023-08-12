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

local BaseUrl = "https://raw.githubusercontent.com/derFreemaker/Satisfactory/Module-Bundling"

-- ########## Don't touch that ########## --
local LoaderFilesUrl = BaseUrl .. "/Github-Loading"
local LoaderUrl = LoaderFilesUrl .. "/Loader.lua"
local LoaderFilesPath = "Loader"
local LoaderPath = LoaderFilesPath .. "/Loader.lua"

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

if not filesystem.exists(LoaderFilesPath) then
    filesystem.createDir(LoaderFilesPath)
end

if not filesystem.exists(LoaderPath) or loaderForceDownload then
    print("[Computer] INFO! downloading Github loader...")
    local req = internetCard:request(LoaderUrl, "GET", "")
    local _, libdata = req:await()
    ---@cast libdata string
    local file = filesystem.open(LoaderPath, "w")
    assert(file, "Unable to open file: '" .. LoaderPath .. "'")
    file:write(libdata)
    file:close()
    print("[Computer] INFO! downloaded Github loader")
end

-- ######## load Loader files ######## --

---@type Github_Loading.Loader
local Loader = filesystem.doFile(LoaderPath)
assert(Loader, "Unable to load loader")

Loader = Loader.new(BaseUrl, LoaderFilesPath, loaderForceDownload, internetCard)
assert(Loader:Download(), "Unable to download loader Files")
Loader:Load()

-- ######## setup logger ######## --

---@type Utils
local Utils = Loader:Get("/Github-Loading/Loader/10_Utils.lua")

local function log(message)
    print(message)
    Utils.File.Write("/Logs/main.log", "+a", message .. "\n", true)
end
local function clear()
    Utils.File.Clear("/Logs/main.log")
end

---@type Github_Loading.Listener
local Listener = Loader:Get("/Github-Loading/Loader/20_Listener.lua")
---@type Github_Loading.Logger
local Logger = Loader:Get("/Github-Loading/Loader/20_Logger.lua")
local loaderLogger = Logger.new("Loader", loaderLogLevel)
loaderLogger.OnLog:AddListener(Listener.new(log))
loaderLogger.OnClear:AddListener(Listener.new(clear))
loaderLogger:setErrorLogger()
loaderLogger:Clear()

-- ######## handling option ######## --

---@type Github_Loading.Option
local Option = Loader:Get("/Github-Loading/Loader/10_Option.lua")
---@type Github_Loading.Option[]
local Options = {}
for name, url in pairs(Loader:Get("/Github-Loading/100_Options.lua")) do
    local optionObj = Option.new(name, url)
    table.insert(Options, optionObj)
end
if option == nil then
    print("\nOptions:")
    for _, optionObj in ipairs(Options) do
        optionObj:Print(showExtendOptionDetails)
    end
    computer.stop()
    return
end

---@param optionName string
---@return Github_Loading.Option?
local function getOption(optionName)
    for _, optionObj in ipairs(Options) do
        if optionObj.Name == optionName then
            return optionObj
        end
    end
end
local chosenOption = getOption(option)
if not chosenOption then
    computer.panic("Option: '".. option .."' not found")
    return
end

-- ######## load main module ######## --

---@type Github_Loading.PackageLoader
local PackageLoader = Loader:Get("/Github-Loading/Loader/40_PackageLoader.lua")
PackageLoader = PackageLoader.new(BaseUrl .. "/Packages", LoaderFilesPath .. "/Packages", loaderLogger:create("PackageLoader"), internetCard)

local package = PackageLoader:LoadPackage(chosenOption.Url, programForceDownload)

local mainModule = package:GetModule(package.Name .. ".Main")
assert(mainModule, "Unable to get main module from option")
assert(mainModule.IsRunnable, "main module from option is not runnable")

---@type Github_Loading.Main
local mainModuleData = mainModule:Load()

---@type Github_Loading.Entities
local Entities = Loader:Get("/Github-Loading/Loader/10_Entities.lua")
local programEntry = Entities.newMain(mainModuleData)

-- ######## configure program ######## --

local function configure()
    loaderLogger:LogTrace("configuring program...")
    local programLogger = loaderLogger.new("Program", programLogLevel)
    programLogger.OnLog:AddListener(Listener.new(log))
    programLogger.OnClear:AddListener(Listener.new(clear))
    programEntry.Logger = programLogger
    programLogger:setErrorLogger()
    local errorMsg = programEntry:Configure()
    loaderLogger:setErrorLogger()
    if errorMsg ~= "not found" then
        programLogger:LogTrace("configured program")
    else
        programLogger:LogTrace("no configure function found")
    end
end
configure()

-- ######## run program ######## --

local function run()
    loaderLogger:LogTrace("running program...")
    programEntry.Logger:setErrorLogger()
    local result = programEntry:Run()
    loaderLogger:setErrorLogger()
    if result == "$%not found%$" then
        error("no main run function found")
    end
    loaderLogger:LogInfo("program stoped running: " .. tostring(result))
end
run()