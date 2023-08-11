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

if not filesystem.exists(LoaderPath) then
    print("[Computer] INFO! downloading Github loader...")
    local req = internetCard:request(LoaderUrl, "GET", "")
    local _, libdata = req:await()
    ---@cast libdata string
    local file = filesystem.open(LoaderPath, "w")
    if file == nil then
        error("Unable to open file: '" .. LoaderPath .. "'")
    end
    file:write(libdata)
    file:close()
    print("[Computer] INFO! downloaded Github loader")
end

-- ######## load Loader files ######## --

---@type Github_Loading.Loader
local Loader = filesystem.doFile(LoaderPath)
if Loader == nil then
    error("Unable to load loader")
end

Loader = Loader.new(BaseUrl, LoaderFilesPath, loaderForceDownload, internetCard)
if not Loader:Download() then
    error("Unable to download loader Files")
end
Loader:Load()

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
    print("Options:")
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

-- ######## setup logger ######## --

---@type Utils
local Utils = Loader:Get("/Github-Loading/Loader/10_Utils.lua")

local function log(message)
    print(message)
    Utils.File.Write("/Logs/main.log", "+a", message, true)
end
local function clear()
    Utils.File.Clear("/Logs/main.log")
end

---@type Github_Loading.Listener
local Listener = Loader:Get("/Github-Loading/Loader/20_Listener.lua")
---@type Github_Loading.Logger
local Logger = Loader:Get("/Github-Loading/Loader/20_Logger.lua")
Logger = Logger.new("Loader", loaderLogLevel)
Logger.OnLog:AddListener(Listener.new(log))
Logger.OnClear:AddListener(Listener.new(clear))

-- ######## load main module ######## --

---@type Github_Loading.PackageLoader
local PackageLoader = Loader:Get("/Github-Loading/Loader/40_PackageLoader.lua")
PackageLoader = PackageLoader.new(BaseUrl .. "/Packages", "/Packages", Logger:create("PackageLoader"), internetCard)

local package = PackageLoader:LoadPackage(chosenOption.Url, programForceDownload)

local mainModule = package:GetModule(package.Name .. ".Main")
if not mainModule then
    error("Unable to get main module from option")
end
if not mainModule.IsRunnable then
    error("main module from option is not runnable")
end

---@type Github_Loading.Main
local mainModuleData = mainModule:Load()

---@type Github_Loading.Entities
local Entities = Loader:Get("/Github-Loading/Loader/10_Entities.lua")
local programEntry = Entities.newMain(mainModuleData)

-- ######## configure program ######## --

Logger:LogTrace("configuring program...")
local programLogger = Logger.new("Program", programLogLevel)
programLogger.OnLog:AddListener(Listener.new(log))
programLogger.OnClear:AddListener(Listener.new(clear))
programEntry.Logger = programLogger
local thread, success, errorMsg = Utils.Function.InvokeFunctionAsThread(programEntry.Configure, programEntry)
if success and errorMsg ~= "not found" then
    programLogger:LogTrace("configured program")
elseif errorMsg ~= "$%not found%$" then
    programLogger:LogError("configuration failed")
    programLogger:LogError(debug.traceback(thread, errorMsg))
    error("configure function failed")
else
    programLogger:LogTrace("no configure function found")
end

-- ######## run program ######## --

Logger:LogTrace("running program...")
local thread, success, result = Utils.Function.InvokeFunctionAsThread(programEntry.Run, programEntry)
if result == "$%not found%$" then
    Logger:LogError("no main run function found")
    error("no main run function found")
end
if not success then
    Logger:LogError("program stoped running:")
    Logger:LogError(debug.traceback(thread, result))
    computer.panic("porgram stoped running: " .. debug.traceback(thread, result))
else
    Logger:LogInfo("program stoped running: " .. tostring(result))
end