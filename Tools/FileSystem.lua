local Utils = require("Tools.Utils")

---@param str string
---@return string str
local function formatStr(str)
	str = str:gsub("\\", "/")
	return str
end

---@class Tools.FileSystem.Path
---@field private m_nodes string[]
local Path = {}

---@param str string
---@return boolean isNode
function Path.IsNode(str)
	if str:find("/") then
		return false
	end

	return true
end

---@package
---@param pathOrNodes string | string[]
---@return Tools.FileSystem.Path
function Path.new(pathOrNodes)
	local instance = {}
	if not pathOrNodes then
		instance.m_nodes = {}
		return setmetatable(instance, Path)
	end

	if type(pathOrNodes) == "string" then
		pathOrNodes = formatStr(pathOrNodes)
		pathOrNodes = Utils.SplitStr(pathOrNodes, "/")
	end

	local length = #pathOrNodes
	local node = pathOrNodes[length]
	if node ~= "" and not node:find("^.+%..+$") then
		pathOrNodes[length + 1] = ""
	end

	instance.m_nodes = pathOrNodes
	instance = setmetatable(instance, { __index = Path })
	instance:Normalize()

	return instance
end

---@return string path
function Path:GetPath()
	return Utils.JoinStr(self.m_nodes, "/")
end

---@return boolean
function Path:IsEmpty()
	return #self.m_nodes == 0 or (#self.m_nodes == 2 and self.m_nodes[1] == "" and self.m_nodes[2] == "")
end

---@return boolean
function Path:IsFile()
	return self.m_nodes[#self.m_nodes] ~= ""
end

---@return boolean
function Path:IsDir()
	return self.m_nodes[#self.m_nodes] == ""
end

function Path:Exists()
	local path = self:GetPath()
	return os.rename(path, path) and true or false
end

---@return string
function Path:GetParentFolder()
	local copy = Utils.CopyTable(self.m_nodes)
	local length = #copy

	if length > 0 then
		if length > 1 and copy[length] == "" then
			copy[length] = nil
			copy[length - 1] = ""
		else
			copy[length] = nil
		end
	end

	return Utils.JoinStr(copy, "/")
end

---@return Tools.FileSystem.Path
function Path:GetParentFolderPath()
	local copy = self:Copy()
	local length = #copy.m_nodes

	if length > 0 then
		if length > 1 and copy.m_nodes[length] == "" then
			copy.m_nodes[length] = nil
			copy.m_nodes[length - 1] = ""
		else
			copy.m_nodes[length] = nil
		end
	end

	return copy
end

---@return string fileName
function Path:GetFileName()
	if not self:IsFile() then
		error("path is not a file: " .. self:GetPath())
	end

	return self.m_nodes[#self.m_nodes]
end

---@return string fileExtension
function Path:GetFileExtension()
	if not self:IsFile() then
		error("path is not a file: " .. self:GetPath())
	end

	local fileName = self.m_nodes[#self.m_nodes]

	local _, _, extension = fileName:find("^.+(%..+)$")
	return extension
end

---@return string fileStem
function Path:GetFileStem()
	if not self:IsFile() then
		error("path is not a file: " .. self:GetPath())
	end

	local fileName = self.m_nodes[#self.m_nodes]

	local _, _, stem = fileName:find("^(.+)%..+$")
	return stem
end

---@return Tools.FileSystem.Path
function Path:Normalize()
	---@type string[]
	local newNodes = {}

	for index, value in ipairs(self.m_nodes) do
		if value == "." then
		elseif value == "" then
			if index == 1 or index == #self.m_nodes then
				newNodes[#newNodes + 1] = ""
			end
		elseif value == ".." then
			if index ~= 1 then
				newNodes[#newNodes] = nil
			end
		else
			newNodes[#newNodes + 1] = value
		end
	end

	self.m_nodes = newNodes
	return self
end

---@param path string
---@return Tools.FileSystem.Path
function Path:Append(path)
	path = formatStr(path)
	local newNodes = Utils.SplitStr(path, "/")

	for _, value in ipairs(newNodes) do
		self.m_nodes[#self.m_nodes + 1] = value
	end

	self:Normalize()

	return self
end

---@param path string
---@return Tools.FileSystem.Path
function Path:Extend(path)
	local copy = self:Copy()
	return copy:Append(path)
end

---@return Tools.FileSystem.Path
function Path:Copy()
	local copyNodes = Utils.CopyTable(self.m_nodes)
	return Path.new(copyNodes)
end

---@class Tools.FileSystem
local FileSystem = {}

---@param str string?
---@return Tools.FileSystem.Path
function FileSystem.Path(str)
	if str == nil then
		str = ""
	end
	return Path.new(str)
end

---@param path string
---@param mode openmode
---@return file*
function FileSystem.OpenFile(path, mode)
	local file = io.open(path, mode)
	if not file then
		error('unable to open file: ' .. path)
	end
	return file
end

---@return string
function FileSystem.GetCurrentDirectory()
	local source = debug.getinfo(2, 'S').source:gsub('\\', '/'):gsub('@', '')
	local slashPos = source:reverse():find('/')
	local length = source:len()
	local currentPath = source:sub(0, length - slashPos)
	return currentPath
end

---@param path string
---@return string[]
function FileSystem.GetDirectories(path)
	local command = 'dir "' .. path .. '" /ad /b'
	local result = io.popen(command)
	if not result then
		error('unable to run command: ' .. command)
	end
	---@type string[]
	local children = {}
	for line in result:lines() do
		table.insert(children, line)
	end
	return children
end

---@param path string
---@return string[]
function FileSystem.GetFiles(path)
	local command = 'dir "' .. path .. '" /a-d /b'
	local result = io.popen(command)
	if not result then
		error('unable to run command: ' .. command)
	end
	---@type string[]
	local children = {}
	for line in result:lines() do
		table.insert(children, line)
	end
	return children
end

return FileSystem
