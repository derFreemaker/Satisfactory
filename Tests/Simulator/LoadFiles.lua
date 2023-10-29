local FileSystem = require("Tools.FileSystem")

local LoaderFiles = {
	'Github-Loading',
	{
		'Loader',
		{
			'Utils',
			{
				"Class",
				{ "00_Config.lua" },
				{ "20_Instance.lua" },
				{ "20_Object.lua" },
				{ "30_Members.lua" },
				{ "30_Type.lua" },
				{ "40_Metatable.lua" },
				{ "50_Construction.lua" },
				{ "80_Index.lua" }
			},
			{ '10_File.lua' },
			{ '10_Function.lua' },
			{ '10_String.lua' },
			{ '10_Table.lua' },
			{ '100_Index.lua' }
		},
		{ '10_ComputerLogger.lua' },
		{ '10_Entities.lua' },
		{ '10_Module.lua' },
		{ '10_Option.lua' },
		{ '120_Event.lua' },
		{ '120_Listener.lua' },
		{ '120_Package.lua' },
		{ '140_Logger.lua' },
		{ '200_PackageLoader.lua' }
	},
	{ '00_Options.lua' },
	{ 'Version.latest.txt' }
}

local FileTreeTools = {}

---@private
---@param parentPath string
---@param entry table | string
---@param fileFunc fun(path: string) : boolean
---@param folderFunc fun(path: string) : boolean
---@return boolean
function FileTreeTools:doEntry(parentPath, entry, fileFunc, folderFunc)
	if #entry == 1 then
		---@cast entry string
		return self:doFile(parentPath, entry, fileFunc)
	else
		---@cast entry table
		return self:doFolder(parentPath, entry, fileFunc, folderFunc)
	end
end

---@private
---@param parentPath string
---@param file string
---@param func fun(path: string) : boolean
---@return boolean
function FileTreeTools:doFile(parentPath, file, func)
	local path = FileSystem.Path(parentPath, file[1])
	return func(path)
end

---@param parentPath string
---@param folder table
---@param fileFunc fun(path: string) : boolean
---@param folderFunc fun(path: string) : boolean
---@return boolean
function FileTreeTools:doFolder(parentPath, folder, fileFunc, folderFunc)
	local path = FileSystem.Path(parentPath, folder[1])
	if not folderFunc(path) then
		return false
	end
	for index, child in pairs(folder) do
		if index ~= 1 then
			local success = self:doEntry(path, child, fileFunc, folderFunc)
			if not success then
				return false
			end
		end
	end
	return true
end

---@param loaderBasePath string
---@return table<string, any[]> loadedLoaderFiles
local function loadFiles(loaderBasePath)
	---@type string[][]
	local loadEntries = {}
	---@type integer[]
	local loadOrder = {}
	---@type table<string, any[]>
	local loadedLoaderFiles = {}

	---@param path string
	---@return boolean success
	local function retrivePath(path)
		local fileName = FileSystem.GetFileName(path)
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
			local file = FileSystem.OpenFile(loaderBasePath .. path, 'r')
			local str = ''
			while true do
				local buf = file:read(8192)
				if not buf then
					break
				end
				str = str .. buf
			end
			path = path:match('^(.+/.+)%..+$')
			loadedLoaderFiles[path] = { str }
			file:close()
		end
		return true
	end

	assert(
		FileTreeTools:doFolder(
			'',
			LoaderFiles,
			retrivePath,
			function()
				return true
			end
		),
		'Unable to load loader Files'
	)

	table.sort(loadOrder)
	for _, num in ipairs(loadOrder) do
		for _, path in pairs(loadEntries[num]) do
			local loadedFile = { loadfile(loaderBasePath .. path)(loadedLoaderFiles) }
			local folderPath,
			filename = path:match('^(.+)/%d+_(.+)%..+$')
			if filename == 'Index' then
				loadedLoaderFiles[folderPath] = loadedFile
			else
				loadedLoaderFiles[folderPath .. '/' .. filename] = loadedFile
			end
		end
	end

	return loadedLoaderFiles
end

return loadFiles
