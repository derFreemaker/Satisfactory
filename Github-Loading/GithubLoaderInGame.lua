-- if option is nil it will show you all options
local option = nil
local showExtendOptionDetails = false

-- Config --
-- to define any config variables
Config = {}

-- logLevel
-- 1 = Trace / 2 = Debug / 3 = Info / 4 = Warning / 5 = Error / 6 = Fatal
local loaderLogLevel = 3
local programLogLevel = 3

-- forceDownload
local loaderForceDownload = false
local programForceDownload = false

local BaseUrl = "http://localhost"
-- local BaseUrl = 'https://raw.githubusercontent.com/derFreemaker/Satisfactory/main'

local showDriveUUID = false

-- ########## Don't touch that ########## --
-- ! Changing this can cause the game to crash, because of some file watch bug in the mod code.
local LoaderFilesUrl = BaseUrl .. '/Github-Loading'
local LoaderUrl = LoaderFilesUrl .. '/Loader.lua'
local LoaderFilesPath = ''
local LoaderPath = LoaderFilesPath .. '/Loader.lua'

local internetCard = computer.getPCIDevices(classes.InternetCard_C)[1]
if not internetCard then
	computer.beep(0.2)
	error('No internet-card found!')
	return
end
filesystem.initFileSystem('/dev')
local drive = ""
for _, child in pairs(filesystem.childs('/dev')) do
	if child ~= "serial" then
		drive = child
		break
	end
end
if drive:len() < 1 then
	computer.beep(0.2)
	error('Unable to find filesystem to load on! Insert a drive or floppy.')
	return
end
filesystem.mount('/dev/' .. drive, '/')

if showDriveUUID then
	print('[Computer] DEBUG mounted filesystem on drive: ' .. drive)
end

---@type Github_Loading.Loader?
local Loader

---@return boolean restart
local function Run()
	if not filesystem.exists(LoaderFilesPath) then
		filesystem.createDir(LoaderFilesPath)
	end
	if not filesystem.exists(LoaderPath) or loaderForceDownload then
		local req = internetCard:request(LoaderUrl, 'GET', '')
		print('[Computer] INFO downloading Github Loader...')
		repeat
		until req:canGet()
		---@type integer, string
		local _, libData = req:get()
		local file = filesystem.open(LoaderPath, 'w')
		file:write(libData)
		file:close()
		print('[Computer] INFO downloaded Github Loader')
	end

	InGame = true

	-- ######## load Loader Files and initialize ######## --
	---@type Github_Loading.Loader
	Loader = filesystem.doFile(LoaderPath)
	assert(Loader, 'Unable to load Github Loader')

	Loader = Loader.new(BaseUrl, LoaderFilesPath, loaderForceDownload, internetCard)
	Loader:Load(loaderLogLevel)
	local differentVersionFound = Loader:CheckVersion()
	if differentVersionFound then
		loaderForceDownload = true
		return true
	end

	-- ######## load option ######## --
	if option == nil then
		Loader:ShowOptions(showExtendOptionDetails)
		return false
	end

	local chosenOption = Loader:LoadOption(option)
	local program, package = Loader:LoadProgram(chosenOption, programForceDownload)

	-- ######## start Program ######## --
	Loader:Configure(program, package, programLogLevel)
	Loader:Run(program)

	return false
end

repeat
	local thread = coroutine.create(Run)
	local success, result = coroutine.resume(thread)

	if not success then
		print(debug.traceback(thread, result))
	end

	coroutine.close(thread)
until not result or type(result) ~= 'boolean'

if Loader then
	Loader:Cleanup()
end

-- to invoke garbage collection
computer.stop()
