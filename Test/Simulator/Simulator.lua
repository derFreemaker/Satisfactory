local FileSystem = require('Tools.FileSystem')

local CurrentPath = ''

---@class Test.Simulator
---@field private m_loadedLoaderFiles table<string, any[]>
local Simulator = {}

---@private
function Simulator:LoadLoaderFiles()
	self.m_loadedLoaderFiles = require("Test.Simulator.LoadFiles")(CurrentPath)
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

	computer.time = os.time

	---@diagnostic disable-next-line
	computer.magicTime = function()
		return os.time, os.date(), os.date()
	end
end

---@param logLevel Github_Loading.Logger.LogLevel
function Simulator:setupLogger(logLevel)
	---@type Github_Loading.Logger
	local Logger = self.m_loadedLoaderFiles['/Github-Loading/Loader/Logger'][1]
	local Listener = self.m_loadedLoaderFiles['/Github-Loading/Loader/Listener'][1]

	local logger = Logger.new("Simulator", logLevel)
	logger.OnLog:AddListener(Listener(print))

	___logger:initialize()
	___logger:setLogger(logger)
end

---@private
---@param logLevel Github_Loading.Logger.LogLevel
function Simulator:Prepare(logLevel)
	component = {}
	event = {}
	filesystem = {}
	self:loadComputer()

	self:LoadLoaderFiles()

	self:setupLogger(logLevel)

	self:OverrideRequire()

	Utils = self.m_loadedLoaderFiles['/Github-Loading/Loader/Utils'][1] --[[@as Utils]]
end

---@param logLevel Github_Loading.Logger.LogLevel?
---@return Test.Simulator
function Simulator:Initialize(logLevel)
	local simulatorPath = FileSystem.GetCurrentDirectory()
	CurrentPath = simulatorPath:gsub("/Test/Simulator", "")

	self:Prepare(logLevel or 3)

	return self
end

return Simulator
