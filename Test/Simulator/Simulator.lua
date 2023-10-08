local FileSystem = require('Tools.FileSystem')

local CurrentPath = ''

---@param loadEntries string[][]
---@param loadOrder integer[]
---@param loadedLoaderFiles Dictionary<string, any[]>
---@param path string
local function preloadFile(loadEntries, loadOrder, loadedLoaderFiles, path)
	local fileName = FileSystem.GetFileStem(path)
	local num = fileName:match('^(%d+)_.+$')
	if num then
		num = tonumber(num)
		---@cast num integer
		local entries = loadEntries[num]
		if not entries then
			entries = {}
			loadEntries[num] = entries
			table.insert(loadOrder, num)
		end
		table.insert(entries, path)
	else
		local file = FileSystem.OpenFile(path, 'r')
		local str = ''
		while true do
			local buf = file:read(8192)
			if not buf then
				break
			end
			str = str .. buf
		end
		path = path:match('^(.+/.+)%..+$')
		loadedLoaderFiles[path:gsub(CurrentPath, '')] = { str }
		file:close()
	end
end

---@param loadEntries string[][]
---@param loadOrder integer[]
---@param loadedLoaderFiles Dictionary<string, any[]>
---@param path string
local function preloadDirectory(loadEntries, loadOrder, loadedLoaderFiles, path)
	for _, value in pairs(FileSystem.GetFiles(path)) do
		preloadFile(loadEntries, loadOrder, loadedLoaderFiles, path .. '/' .. value)
	end
	for _, value in pairs(FileSystem.GetDirectories(path)) do
		preloadDirectory(loadEntries, loadOrder, loadedLoaderFiles, path .. '/' .. value)
	end
end

---@class Test.Simulator
---@field private loadedLoaderFiles Dictionary<string, any[]>
local Simulator = {}

---@private
function Simulator:LoadLoaderFiles()
	self.loadedLoaderFiles = require("Test.Simulator.LoadFiles")(CurrentPath)
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
function Simulator:Prepare()
	component = {}
	computer = {}
	event = {}
	filesystem = {}

	self:LoadLoaderFiles()
	self:OverrideRequire()

	Utils = self.loadedLoaderFiles['/Github-Loading/Loader/Utils'][1] --[[@as Utils]]
end

local temp = { ... }

---@return Test.Simulator
function Simulator:Initialize()
	local simulatorPath = FileSystem.GetCurrentDirectory()
	CurrentPath = simulatorPath:gsub("/Test/Simulator", "")

	self:Prepare()

	return self
end

return Simulator:Initialize()
