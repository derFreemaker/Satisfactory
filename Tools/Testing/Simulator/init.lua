local FileSystem = require("Tools.Freemaker.bin.filesystem")
local Path = require("Tools.Freemaker.bin.path")

local loadClassesAndStructs = require("Tools.Testing.Simulator.classes&structs")
local loadFileSystem = require("Tools.Testing.Simulator.filesystem")
local loadComputer = require("Tools.Testing.Simulator.computer")
local loadComponent = require("Tools.Testing.Simulator.component")
local loadEvent = require("Tools.Testing.Simulator.event")

local CurrentPath = ''

---@class Test.Simulator
---@field Logger Core.Logger
---@field private m_loadedLoaderFiles table<string, any[]>
local Simulator = {}

---@private
function Simulator:loadLoaderFiles()
	self.m_loadedLoaderFiles = require("tools.Testing.Simulator.LoadFiles")(CurrentPath)
end

local requireFunc = require --[[@as fun(moduleName: string) : any]]
---@return boolean success, table results
local function getResult(success, ...)
	return success, { ... }
end
---@param moduleToGet string
---@return any
local function modifiedRequire(moduleToGet)
	local thread = coroutine.create(requireFunc)
	local success
	local result = { coroutine.resume(thread, moduleToGet) }
	success, result = getResult(table.unpack(result))
	if not success then
		print("error when trying to get module: " .. moduleToGet .. "\n" .. debug.traceback(thread, result[1]))
		return { requireFunc(moduleToGet .. ".init") }
	end
	return result
end
function Simulator:OverrideRequire()
	---@param moduleToGet string
	function require(moduleToGet)
		local result = modifiedRequire("src." .. moduleToGet)
		if type(result[#result]) == "string" then
			result[#result] = nil
		end
		return table.unpack(result)
	end
end

---@private
---@param logLevel Github_Loading.Logger.LogLevel
---@return Github_Loading.Logger
function Simulator:setupLogger(logLevel)
	---@type Github_Loading.Logger
	local Logger = self.m_loadedLoaderFiles['/Github-Loading/Loader/Logger'][1]
	---@type Github_Loading.Listener
	local Listener = self.m_loadedLoaderFiles['/Github-Loading/Loader/Listener'][1]

	local logger = Logger.new("Simulator", logLevel)
	logger.OnLog:AddListener(Listener.new(print))

	___logger:initialize()
	___logger:setLogger(logger)

	return logger
end

---@private
---@param logLevel Github_Loading.Logger.LogLevel
---@param fileSystemPath Freemaker.FileSystem.Path
---@param eeprom string
---@param curl Test.Curl
function Simulator:prepare(logLevel, fileSystemPath, eeprom, curl)
	loadClassesAndStructs()
	loadComputer(eeprom, curl)
	loadFileSystem(fileSystemPath)
	loadComponent()
	loadEvent()

	self:loadLoaderFiles()

	local logger = self:setupLogger(logLevel)

	self:OverrideRequire()

	Utils = self.m_loadedLoaderFiles['/Github-Loading/Loader/Utils'][1] --[[@as Utils]]

	local Logger = require("Core.Common.Logger")
	local newLogger = Logger("Simulator", logLevel)
	logger:CopyListenersToCoreLogger(require("Core.Common.Task"), newLogger)
	___logger:setLogger(newLogger)

	self.Logger = newLogger
end

---@param logLevel Github_Loading.Logger.LogLevel?
---@param fileSystemPath string?
---@param eeprom string?
---@return Test.Simulator
function Simulator:Initialize(logLevel, fileSystemPath, eeprom)
	local Curl = require("Tools.Curl")

	local simulatorPath = FileSystem.GetCurrentDirectory()
	CurrentPath = simulatorPath:gsub("Tools/Testing/Simulator", "")

	-- init curl for internet requests
	Curl:SetProgramLocation(CurrentPath .. "Tools/Curl")

	if not fileSystemPath then
		local info = debug.getinfo(2)
		fileSystemPath = Path.new(info.source)
			:GetParentFolderPath()
			:Append("Sim-Files")
			:ToString()
	end

	self:prepare(logLevel or 3, Path.new(fileSystemPath), eeprom or "", Curl)

	return self
end

---@param logLevel Github_Loading.Logger.LogLevel?
---@param fileSystemPath string?
---@param eeprom string?
---@param forceDownload boolean?
---@return Test.Simulator, Github_Loading.Loader
function Simulator:InitializeWithLoader(logLevel, fileSystemPath, eeprom, forceDownload)
	local Curl = require("Tools.Curl")
	local Loader = require("Github-Loading.Loader")

	local simulatorPath = FileSystem.GetCurrentDirectory()
	CurrentPath = simulatorPath:gsub("Tools/Testing/Simulator", "")

	-- init curl for internet requests
	Curl:SetProgramLocation(CurrentPath .. "Tools/Curl")

	if not fileSystemPath then
		local info = debug.getinfo(2)
		fileSystemPath = Path.new(info.source)
		:GetParentFolderPath()
		:Append("Sim-Files")
		:ToString()
	end

	self:prepare(logLevel or 3, Path.new(fileSystemPath), eeprom or "", Curl)

	Loader = Loader.new("http://localhost", "", forceDownload or false, Curl)
	Loader:Load(logLevel)

	return self, Loader
end

return Simulator
