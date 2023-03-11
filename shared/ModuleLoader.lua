local version = "1.0.3"

ModuleLoader = {}
ModuleLoader.__index = {}

local libs = {}
local logger = {}
local waitingForLoad = {}

local function checkEntry(entry)
    if entry.Name == nil then
		if entry.FullName ~= nil then
        	entry.Name = entry.FullName
		else
			entry.Name = entry[1]
		end
	end

	if entry.FullName == nil then
		entry.FullName = entry.Name
	end

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

	if entry.IgnoreDownload == true then
		entry.IgnoreDownload = true
	else
		entry.IgnoreDownload = false
	end

	if entry.IgnoreLoad == true then
		entry.IgnoreLoad = true
	else
		entry.IgnoreLoad = false
	end

	local checkedEntry = {
		Name = entry.Name,
		FullName = entry.FullName,
		IsFolder = entry.IsFolder,
		IgnoreDownload = entry.IgnoreDownload,
		IgnoreLoad = entry.IgnoreLoad
	}

	if entry.IsFolder and not entry.IgnoreLoad then
		local childs = {}
		for _, child in pairs(entry) do
			if type(child) == "table" then
				table.insert(childs, checkEntry(child))
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
			checkedEntry.FullName = entry.FullName..".lua"
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
		ModuleLoader.LoadModule(file, path)
    else
        logger:LogDebug("Unable to find module: "..path)
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
        logger:LogError("caller was nil")
        return
    end
    for moduleName, waiters in pairs(waitingForLoad) do
        if moduleName == moduleNameToLoad then
            table.insert(waiters, caller)
            return
        end
    end
    waitingForLoad[moduleNameToLoad] = {caller}
    logger:LogDebug("Added: "..caller.File.Name.." to load after "..moduleNameToLoad.." was loaded")
end

function ModuleLoader.Initialize(newLogger)
    logger = newLogger
	logger:LogDebug("Module Loader Version: "..version)
end

function ModuleLoader.ShowModules()
	for moduleName, _ in pairs(libs) do
		print("Name: "..moduleName)
	end
end

function ModuleLoader.LoadModule(file, path)
    if file.IgnoreLoad == true then return end
    logger:LogDebug("loading module: "..file.Name.." from path: "..path)
    libs[file.Name] = filesystem.doFile(path)
    logger:LogDebug("loaded module: "..file.Name)
    if waitingForLoad[file.Name] ~= nil then
        for _, waiter in pairs(waitingForLoad[file.Name]) do
            ModuleLoader.LoadModule(waiter.File, waiter.Path)
        end
    end
end

function ModuleLoader.LoadModules(modulesTree)
    logger:LogDebug("loading modules...")
    if modulesTree == nil then
        logger:LogDebug("modules tree was empty")
        return false
    end
    local checkedTree = checkEntry(modulesTree)
    ModuleLoader.doFolder("", checkedTree)
    if #waitingForLoad > 0 then
        for moduleName, waiters in pairs(waitingForLoad) do
            logger:LogError("Unable to load: "..moduleName.." for "..#waiters.." modules")
        end
        logger:LogError("Unable to load modules")
        return false
    end
    logger:LogDebug("loaded modules")
    return true
end

function ModuleLoader.PreLoadModule(moduleNameToLoad)
    for moduleName, module in pairs(libs) do
        if moduleName == moduleNameToLoad then
            logger:LogDebug("pre loaded module: "..moduleName)
            return module
        end
    end
    ModuleLoader.handleCouldNotLoadModule(moduleNameToLoad)
    error("Unable to load module: "..moduleNameToLoad, 1)
end

function ModuleLoader.GetModule(moduleNameToLoad)
    for moduleName, module in pairs(libs) do
        if moduleName == moduleNameToLoad then
            logger:LogDebug("geted module: "..moduleName)
            return module
        end
    end
end