local FileSystem = require('Tools.FileSystem')

local CurrentPath = ''

---@class Test.Simulator
---@field private m_loadedLoaderFiles table<string, any[]>
local Simulator = {}

---@private
function Simulator:LoadLoaderFiles()
	self.m_loadedLoaderFiles = require("Tests.Simulator.LoadFiles")(CurrentPath)
end

local requireFunc = require
---@private
function Simulator:OverrideRequire()
	---@param moduleToGet string
	function require(moduleToGet)
		if requireFunc == nil then
			error('require Func was nil')
		end
		return requireFunc('src.' .. moduleToGet)
	end
end

---@private
function Simulator:loadComputer()
	computer = {}

	---@diagnostic disable-next-line
	function computer.millis()
		return math.floor(os.clock())
	end

	---@diagnostic disable-next-line
	computer.time = function()
		return os.time()
	end

	---@diagnostic disable-next-line
	computer.magicTime = function()
		return os.time, os.date(), os.date()
	end
end

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
---@return Core.Logger
function Simulator:Prepare(logLevel)
	component = {}
	event = {}
	filesystem = {}
	self:loadComputer()

	self:LoadLoaderFiles()

	local logger = self:setupLogger(logLevel)

	self:OverrideRequire()

	Utils = self.m_loadedLoaderFiles['/Github-Loading/Loader/Utils'][1] --[[@as Utils]]

	local Logger = require("Core.Common.Logger")
	local newLogger = Logger("Simulator", logLevel)
	logger:CopyListenersToCoreLogger(require("Core.Common.Task"), newLogger)
	___logger:setLogger(newLogger)

	return newLogger
end

---@param logLevel Github_Loading.Logger.LogLevel?
---@return Test.Simulator, Core.Logger
function Simulator:Initialize(logLevel)
	local simulatorPath = FileSystem.GetCurrentDirectory()
	CurrentPath = simulatorPath:gsub("/Tests/Simulator", "")

	local logger = self:Prepare(logLevel or 3)

	return self, logger
end

return Simulator
