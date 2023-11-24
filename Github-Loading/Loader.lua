-- //TODO: hold up-to-date
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
			{ '20_Value.lua' },
			{ '100_Index.lua' }
		},
		{ "10_ComputerLogger.lua" },
		{ "10_Entities.lua" },
		{ "10_Event.lua" },
		{ "10_Module.lua" },
		{ "10_Option.lua" },
		{ "120_Listener.lua" },
		{ "120_Package.lua" },
		{ "140_Logger.lua" },
		{ "200_PackageLoader.lua" },
		{ "300_Overrides.lua" }
	},
	{ '00_Options.lua' },
	{ 'Version.latest.txt' }
}

---@param url string
---@param path string
---@param forceDownload boolean
---@param internetCard FIN.Components.FINComputerMod.InternetCard_C
---@return boolean
local function internalDownload(url, path, forceDownload, internetCard)
	if forceDownload == nil then
		forceDownload = false
	end

	if filesystem.exists(path) and not forceDownload then
		return true
	end

	local req = internetCard:request(url, 'GET', '')
	repeat until req:canGet()

	local code, data = req:get()
	if code ~= 200 or data == nil then
		return false
	end

	local file = filesystem.open(path, 'w')
	if file == nil then
		return false
	end

	file:write(data)
	file:close()

	return true
end

---@class Github_Loading.FilesTreeTools
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
	local path = filesystem.path(parentPath, file[1])
	return func(path)
end

---@param parentPath string
---@param folder table
---@param fileFunc fun(path: string) : boolean
---@param folderFunc fun(path: string) : boolean
---@return boolean
function FileTreeTools:doFolder(parentPath, folder, fileFunc, folderFunc)
	local path = filesystem.path(parentPath, folder[1])
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

---@param loaderBaseUrl string
---@param loaderBasePath string
---@param forceDownload boolean
---@param internetCard FIN.Components.FINComputerMod.InternetCard_C
---@return boolean
local function downloadFiles(loaderBaseUrl, loaderBasePath, forceDownload, internetCard)
	---@param path string
	---@return boolean success
	local function downloadFile(path)
		local url = loaderBaseUrl .. path
		path = loaderBasePath .. path
		local downloadAnyway = false
		if path:find('Version.latest.txt') or path:find('00_Options.lua') then
			downloadAnyway = true
		end
		assert(internalDownload(url, path, downloadAnyway or forceDownload, internetCard),
			"Unable to download file: '" .. path .. "'")
		return true
	end

	---@param path string
	---@return boolean success
	local function createFolder(path)
		if not filesystem.exists(loaderBasePath .. path) then
			return filesystem.createDir(loaderBasePath .. path)
		end
		return true
	end

	return FileTreeTools:doFolder('/', LoaderFiles, downloadFile, createFolder)
end

---@param loaderBasePath string
---@return table<string, table> loadedLoaderFiles
local function loadFiles(loaderBasePath)
	---@type string[][]
	local loadEntries = {}
	---@type integer[]
	local loadOrder = {}
	---@type table<string, table>
	local loadedLoaderFiles = {}

	---@param path string
	---@return boolean success
	local function retrivePath(path)
		local fileName = filesystem.path(4, path)
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
			local file = filesystem.open(loaderBasePath .. path, 'r')
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
			'/',
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
			local loadedFile = { filesystem.loadFile(loaderBasePath .. path)(loadedLoaderFiles) }
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

---@class Github_Loading.Loader
---@field private m_loaderBaseUrl string
---@field private m_loaderBasePath string
---@field private m_forceDownload boolean
---@field private m_internetCard FIN.Components.FINComputerMod.InternetCard_C
---@field private m_loadedLoaderFiles table<string, table>
---@field Logger Github_Loading.Logger
local Loader = {}

---@param loaderBaseUrl string
---@param loaderBasePath string
---@param forceDownload boolean
---@param internetCard FIN.Components.FINComputerMod.InternetCard_C
---@return Github_Loading.Loader
function Loader.new(loaderBaseUrl, loaderBasePath, forceDownload, internetCard)
	-- //TODO: computer.promote used
	computer.promote()

	return setmetatable(
		{
			m_loaderBaseUrl = loaderBaseUrl,
			m_loaderBasePath = loaderBasePath,
			m_forceDownload = forceDownload,
			m_internetCard = internetCard,
			m_loadedLoaderFiles = {}
		}, { __index = Loader })
end

function Loader:LoadFiles()
	self.m_loadedLoaderFiles = loadFiles(self.m_loaderBasePath)
end

---@param moduleToGet string
---@return any ...
function Loader:Get(moduleToGet)
	local module = self.m_loadedLoaderFiles[moduleToGet]
	if not module then
		return
	end
	return table.unpack(module)
end

---@private
---@param logLevel Github_Loading.Logger.LogLevel
function Loader:setupLogger(logLevel)
	local function logConsole(message)
		print(message)
	end
	local function logFile(message)
		Utils.File.Write('/Logs/main.log', '+a', message .. '\n', true)
	end
	local function clear()
		Utils.File.Clear('/Logs/main.log')
	end

	---@type Github_Loading.Listener
	local Listener = self:Get('/Github-Loading/Loader/Listener')
	---@type Github_Loading.Logger
	local Logger = self:Get('/Github-Loading/Loader/Logger')
	self.Logger = Logger.new('Github Loader', logLevel)

	self.Logger.OnLog:AddListener(Listener.new(logFile))
	self.Logger.OnClear:AddListener(Listener.new(clear))
	___logger:setLogger(self.Logger)

	self.Logger:Clear()
	self.Logger:LogWrite('###### LOG START: ' .. tostring(({ computer.magicTime() })[2]) .. ' ######')
	self.Logger:LogWrite("###### Loader Version: " .. tostring(self:Get('/Github-Loading/Version.latest')) .. " ######")

	self.Logger.OnLog:AddListener(Listener.new(logConsole))
end

---@param logLevel Github_Loading.Logger.LogLevel
function Loader:Load(logLevel)
	assert(downloadFiles(self.m_loaderBaseUrl, self.m_loaderBasePath, self.m_forceDownload, self.m_internetCard),
		'Unable to download loader Files')
	self:LoadFiles()

	---@type Utils
	Utils = self:Get('/Github-Loading/Loader/Utils')

	___logger:initialize()
	self:setupLogger(logLevel)
end

---@nodiscard
---@return boolean diffrentVersionFound
function Loader:CheckVersion()
	self.Logger:LogTrace('checking Version...')
	local versionFilePath = self.m_loaderBasePath .. '/Github-Loading/Version.current.txt'
	local OldVersionString = Utils.File.ReadAll(versionFilePath)
	local NewVersionString = self:Get('/Github-Loading/Version.latest')
	Utils.File.Write(versionFilePath, 'w', NewVersionString, true)

	local diffrentVersionFound = OldVersionString ~= NewVersionString
	if diffrentVersionFound then
		self.Logger:LogInfo('found new Github Loader version: ' .. NewVersionString)
	else
		self.Logger:LogDebug('Github Loader Version: ' .. NewVersionString)
	end

	return diffrentVersionFound
end

---@param option string?
---@param extendOptionDetails boolean
---@return Github_Loading.Option chosenOption
function Loader:LoadOption(option, extendOptionDetails)
	---@type Github_Loading.Option
	local Option = self:Get('/Github-Loading/Loader/Option')
	local options = self:Get('/Github-Loading/Options')

	---@type Github_Loading.Option[]
	local mappedOptions = {}
	for name, url in pairs(options) do
		local optionObj = Option.new(name, url)
		table.insert(mappedOptions, optionObj)
	end

	self.Logger:LogDebug('loaded Options')
	if option == nil then
		local output = 'Options:'
		for _, optionObj in ipairs(mappedOptions) do
			output = output .. "\n" .. optionObj:Get(extendOptionDetails)
		end
		print(output)
		computer.stop()
		return {}
	end

	---@param optionName string
	---@return Github_Loading.Option?
	local function getOption(optionName)
		for _, optionObj in ipairs(mappedOptions) do
			if optionObj.Name == optionName then
				return optionObj
			end
		end
	end

	local chosenOption = getOption(option)
	if not chosenOption then
		computer.panic("Option: '" .. option .. "' not found")
		return {}
	end

	self.Logger:LogDebug('found Option')
	return chosenOption
end

---@param option Github_Loading.Option
---@param baseUrl string
---@param forceDownload boolean
---@return Github_Loading.Entities.Main program, Github_Loading.Package package
function Loader:LoadProgram(option, baseUrl, forceDownload)
	---@type Github_Loading.PackageLoader
	local PackageLoader = self:Get('/Github-Loading/Loader/PackageLoader')
	PackageLoader = PackageLoader.new(baseUrl .. '/Packages', self.m_loaderBasePath .. '/Packages',
		self.Logger:subLogger('PackageLoader'), self.m_internetCard)
	PackageLoader:SetGlobal()
	self.Logger:LogDebug('setup PackageLoader')

	self.Logger:LogTrace('loading Core package...')
	PackageLoader:LoadPackage('Core')
	self.Logger:LogTrace('loaded Core package')

	self.Logger:LogTrace('loading option package...')
	local package = PackageLoader:LoadPackage(option.Url, forceDownload)
	PackageLoader:SetCurrentPackage(package)
	PackageLoader:OnLoaded()
	self.Logger:LogTrace('loaded package from chosen Option: ' .. option.Name)

	local mainModule = package:GetModule(package.Namespace .. '.__main')
	assert(mainModule, 'Unable to get main module from option')
	assert(mainModule.IsRunnable, 'main module from option is not runnable')
	self.Logger:LogTrace('got main module')

	---@type Github_Loading.Entities.Main
	local mainModuleData = mainModule:Load()
	self.Logger:LogDebug('loaded main module')

	---@type Github_Loading.Entities
	local Entities = self:Get('/Github-Loading/Loader/Entities')
	local mainModuleEntity = Entities.newMain(mainModuleData)
	self.Logger:LogTrace('loaded Program')
	return mainModuleEntity, package
end

---@param program Github_Loading.Entities.Main
---@param package Github_Loading.Package
---@param logLevel Github_Loading.Logger.LogLevel
function Loader:Configure(program, package, logLevel)
	self.Logger:LogTrace('configuring program...')

	local Logger = require('Core.Common.Logger')
	program.Logger = Logger(package.Name, logLevel)
	local Task = require('Core.Common.Task')
	self.Logger:CopyListenersToCoreLogger(Task, program.Logger)
	___logger:setLogger(program.Logger)

	local success, errorMsg, returns = Utils.Function.InvokeProtected(program.Configure, program)
	if not success then
		self.Logger:LogError(errorMsg)
		error("Unable to complete configure function")
	end
	___logger:revert()

	if returns[1] == "$%not found%$" then
		self.Logger:LogTrace('no configure function found')
	else
		self.Logger:LogTrace('configured program')
	end
end

---@param program Github_Loading.Entities.Main
function Loader:Run(program)
	self.Logger:LogTrace('running program...')

	___logger:setLogger(program.Logger)
	local success, errorMsg, returns = Utils.Function.InvokeProtected(program.Run, program)
	if not success then
		self.Logger:LogError(errorMsg)
		error("program stoped")
	end
	___logger:revert()

	if returns[1] == '$%not found%$' then
		error('no main run function found')
	end
	self.Logger:LogInfo('program stoped running: ' .. tostring(returns[1]))
end

function Loader:Cleanup()
	---@type FIN.Filesystem.File[]
	local openFiles = self.m_loadedLoaderFiles["/Github-Loading/Loader/Utils/File"][2]

	for _, file in pairs(openFiles) do
		file:close()
	end
end

return Loader
