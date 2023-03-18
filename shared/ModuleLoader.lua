local version = "1.0.3"

ModuleLoader = {}

local _libs = {}
local _logger = {}
local _waitingForLoad = {}
local _loadingPhase = false

local function checkEntry(entry, parentPath)
    if entry.Name == nil then
        if entry.FullName ~= nil then
            entry.Name = entry.FullName
        else
            entry.Name = entry[1]
        end
    end

    entry.FullName = (entry.FullName or entry.Name)

    if entry.IsFolder == nil then
        local childs = 0
        for _, child in pairs(entry) do
            if type(child) == "table" then
                childs = childs + 1
            end
        end
        if childs == 0 then
            entry.IsFolder = false
        else
            entry.IsFolder = true
        end
    end

    entry.IgnoreDownload = (entry.IgnoreDownload or false)
    entry.IgnoreLoad = (entry.IgnoreDownload or false)
    entry.Path = (entry.Path or filesystem.path(parentPath, entry.FullName))

    local checkedEntry = {
        Name = entry.Name,
        FullName = entry.FullName,
        IsFolder = entry.IsFolder,
        IgnoreDownload = entry.IgnoreDownload,
        IgnoreLoad = entry.IgnoreLoad,
        Path = entry.Path
    }

    if entry.IsFolder and not entry.IgnoreLoad then
        local childs = {}
        for _, child in pairs(entry) do
            if type(child) == "table" then
                table.insert(childs, checkEntry(child, checkedEntry.Path))
            end
        end
        checkedEntry.Childs = childs
    else
        local nameLength = entry.Name:len()
        if entry.Name:sub(nameLength - 3, nameLength) == ".lua" then
            checkedEntry.Name = entry.Name:sub(0, nameLength - 4)
        end
        nameLength = entry.FullName:len()
        if entry.FullName:sub(nameLength - 3, nameLength) ~= ".lua" then
            checkedEntry.FullName = entry.FullName .. ".lua"
        end
    end

    return checkedEntry
end

local function extractCallerInfo(path)
	local callerData = {
		Path = path,
		File = {
			IgnoreLoad = false,
			IgnoreDownload = false,
			IsFolder = false,
			Name = filesystem.path(4, path),
			FullName = filesystem.path(3, path)
		}
	}
	callerData.File = checkEntry(callerData.File)
	return callerData
end

function ModuleLoader.doEntry(parentPath, entry)
	if entry.IsFolder == true then
		ModuleLoader.doFolder(parentPath, entry)
	else
		ModuleLoader.doFile(parentPath, entry)
	end
end

function ModuleLoader.doFile(parentPath, file)
	if file.IgnoreLoad == true then return end
	local path = filesystem.path(parentPath, file.FullName)
	if filesystem.exists(path) then
		pcall(ModuleLoader.LoadModule, file, path)
    else
        _logger:LogDebug("Unable to find module: "..path)
	end
end

function ModuleLoader.doFolder(parentPath, folder)
	local path = filesystem.path(parentPath, folder.Name)
	table.remove(folder, 1)
	for _, child in pairs(folder.Childs) do
		if type(child) == "table" then
			ModuleLoader.doEntry(path, child)
		end
	end
end

function ModuleLoader.handleCouldNotLoadModule(moduleNameToLoad)
    local caller = extractCallerInfo(debug.getinfo(3).short_src)
    if caller == nil then
        _logger:LogError("caller was nil")
        return
    end
    for moduleName, waiters in pairs(_waitingForLoad) do
        if moduleName == moduleNameToLoad then
            table.insert(waiters, caller)
            return
        end
    end
    _waitingForLoad[moduleNameToLoad] = {caller}
    _logger:LogDebug("Added: "..caller.File.Name.." to load after "..moduleNameToLoad.." was loaded")
end

function ModuleLoader.Initialize(logger)
    _logger = logger:create("ModuleLoader")
	_logger:LogDebug("Module Loader Version: "..version)
end

function ModuleLoader.ShowModules()
	for moduleName, _ in pairs(_libs) do
		print("Name: "..moduleName)
	end
end

function ModuleLoader.LoadModule(file, path)
    if file.IgnoreLoad == true then return end
    _logger:LogTrace("loading module: "..file.Name.." from path: "..path)
    _libs[file.Name] = filesystem.doFile(path)
    _logger:LogDebug("loaded module: "..file.Name)
    if _waitingForLoad[file.Name] ~= nil then
        for _, waiter in pairs(_waitingForLoad[file.Name]) do
            ModuleLoader.LoadModule(waiter.File, waiter.Path)
        end
    end
end

function ModuleLoader.LoadModules(modulesTree, loadingPhase)
	_loadingPhase = loadingPhase
    _logger:LogDebug("loading modules...")
    if modulesTree == nil then
        _logger:LogDebug("modules tree was empty")
        return false
    end
    local checkedTree = checkEntry(modulesTree)
    ModuleLoader.doFolder("", checkedTree)
    if #_waitingForLoad > 0 then
        for moduleName, waiters in pairs(_waitingForLoad) do
            _logger:LogError("Unable to load: "..moduleName.." for "..#waiters.." modules")
        end
        _logger:LogError("Unable to load modules")
        return false
    end
    _logger:LogDebug("loaded modules")
	_loadingPhase = false
    return true
end

function ModuleLoader.PreLoadModule(moduleNameToLoad)
    for moduleName, module in pairs(_libs) do
        if moduleName == moduleNameToLoad then
            _logger:LogTrace("pre loaded module: "..moduleName)
            return module
        end
    end
    ModuleLoader.handleCouldNotLoadModule(moduleNameToLoad)
    error("Unable to load module: "..moduleNameToLoad, 1)
end

function ModuleLoader.GetModule(moduleNameToLoad)
	if _loadingPhase then
		computer.panic("Cann't get module while being in loading Phase!")
	end
    for moduleName, module in pairs(_libs) do
        if moduleName == moduleNameToLoad then
            _logger:LogDebug("geted module: "..moduleName)
            return module
        end
    end
end

function require(moduleNameToLoad)
	if _loadingPhase then
		return ModuleLoader.PreLoadModule(moduleNameToLoad)
	end
	return ModuleLoader.GetModule(moduleNameToLoad)
end