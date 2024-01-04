local FileSystem = require("Tools.Freemaker.bin.filesystem")
local Path = require("Tools.Freemaker.bin.path")

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
	self.m_loadedLoaderFiles = require("Tools.Testing.Simulator.LoadFiles")(CurrentPath)
end

local requireFunc = require --[[@as fun(moduleName: string)]]
function Simulator:OverrideRequire()
	---@param moduleToGet string
	function require(moduleToGet)
		local success, result = pcall(requireFunc, 'src.' .. moduleToGet)
		if success then
			return result
		end

		return requireFunc("src." .. moduleToGet .. ".init")
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
function Simulator:prepare(logLevel, fileSystemPath)
	loadComputer()
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
---@return Test.Simulator
function Simulator:Initialize(logLevel, fileSystemPath)
	local simulatorPath = FileSystem.GetCurrentDirectory()
	CurrentPath = simulatorPath:gsub("/Tools/Testing/Simulator", "")

	if not fileSystemPath then
		local info = debug.getinfo(2)
		fileSystemPath = Path.new(info.source)
			:GetParentFolderPath()
			:Append("Sim-Files")
			:ToString()
	end

	self:prepare(logLevel or 3, Path.new(fileSystemPath))

	return self
end

---@param logLevel Github_Loading.Logger.LogLevel?
---@param fileSystemPath string?
---@return Test.Simulator, Github_Loading.Loader
function Simulator:InitializeWithLoader(logLevel, fileSystemPath)
	local Curl = require("Tools.Curl")
	local Loader = require("Github-Loading.Loader")
	self:Initialize(logLevel, fileSystemPath)

	Loader = Loader.new("http://localhost", "", false, Curl)
	Loader:Load(1)

	return self, Loader
end

return Simulator
