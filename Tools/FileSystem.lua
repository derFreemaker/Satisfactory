---@class Tools.FileSystem
local FileSystem = {}

local debugTemp = { paths = {} }

---@param path string
---@param mode openmode
---@return file*
function FileSystem.OpenFile(path, mode)
	table.insert(debugTemp.paths, { Function = "OpenFile", Path = path })

	local file = io.open(path, mode)
	if not file then
		error('unable to open file: ' .. path)
	end
	return file
end

---@param path string
---@return string fileName
function FileSystem.GetFileName(path)
	local slash = (path:reverse():find('/') or 0) - 2
	if slash == nil or slash == -2 then
		return path
	end
	return path:sub(path:len() - slash)
end

---@param path string
---@return string fileStem
function FileSystem.GetFileStem(path)
	local name = FileSystem.GetFileName(path)
	local pos = (name:reverse():find('%.') or 0)
	local lenght = name:len()
	if pos == lenght then
		return name
	end
	return name:sub(0, lenght - pos)
end

---@return string
function FileSystem.GetCurrentDirectory()
	local source = debug.getinfo(2, 'S').source:gsub('\\', '/'):gsub('@', '')
	local slashPos = source:reverse():find('/')
	local lenght = source:len()
	local currentPath = source:sub(0, lenght - slashPos)
	return currentPath
end

---@param path string
---@return string[]
function FileSystem.GetDirectories(path)
	table.insert(debugTemp.paths, { Function = "GetDirectories", Path = path })

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
	table.insert(debugTemp.paths, { Function = "GetFiles", Path = path })

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

function FileSystem.ThrowDebug()
	local errorMsg = "\n"
	for _, value in pairs(debugTemp.paths) do
		errorMsg = errorMsg .. value.Function .. " -> " .. value.Path .. "\n"
	end
	error(errorMsg)
end

return FileSystem
