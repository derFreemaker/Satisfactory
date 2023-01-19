ModuleLoader = {}
ModuleLoader.__index = {}

local libs = {}
local logger = {}
local waitingForLoad = {}

local function split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
       table.insert(result, each)
    end
    return result
end

local function checkEntry(entry)
    if entry.Name == nil and entry.FullName ~= nil then
        entry.Name = entry.FullName
    else
        entry.Name = entry.Name
	end

	if entry.FullName == nil then
		entry.FullName = entry.Name
	else
        entry.FullName = entry.FullName
    end

    if entry.IsFolder == true then
        entry.IsFolder = true
    else
        entry.IsFolder = false
    end

	if entry.IgnoreLoad == true then
		entry.IgnoreLoad = true
	else
		entry.IgnoreLoad = false
	end

    if entry.IsFolder ~= true then
		local nameLength = entry.Name:len()
    	if entry.Name:sub(nameLength - 3, nameLength) == ".lua" then
			entry.Name = entry.Name:sub(0, nameLength - 4)
		end
		nameLength = entry.FullName:len()
		if entry.FullName:sub(nameLength - 3, nameLength) ~= ".lua" then
			entry.FullName = entry.FullName..".lua"
	 	end
	end

	if entry.IsFolder and not entry.IgnoreLoad then
		local childs = {}
		for _, child in pairs(entry) do
			if type(child) == "table" then
				table.insert(childs, checkEntry(child))
			end
		end
		entry.Childs = childs
	end

	return entry
end

local function extractCallerInfo(short_src)
	local callerData = {
		Path = short_src,
		File = {
			IgnoreLoad = false,
			IsFolder = false,
			Name = "",
			FullName = ""
		}
	}

	local splitedName = split(callerData.Path, "\\")
	callerData.File.FullName = splitedName[#splitedName]
	callerData.File = checkEntry(callerData.File)
end

function ModuleLoader.doEntry(parentPath, entry)
	if entry.IgnoreLoad == true then return end
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
        print("DEBUG! Unable to find module: "..path)
	end
end

function ModuleLoader.doFolder(parentPath, folder)
	if folder.IgnoreLoad == true then return end
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
	if caller == nil then logger:LogError("caller was nil") return end
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
end

function ModuleLoader.LoadModule(file, path)
    if file.IgnoreLoad == true then return end
    libs[file.Name] = filesystem.doFile(path)
    logger:LogDebug("loaded module: "..file.Name)
	for moduleName, waiters in pairs(waitingForLoad) do
		if moduleName == file.Name then
			for _, waiter in pairs(waiters) do
				ModuleLoader.LoadModule(waiter.File, waiter.Path)
			end
		end
	end
end

function ModuleLoader.LoadModules(modulesTree)
    logger:LogDebug("loading modules...")
	if modulesTree == nil then
		logger:LogDebug("modules tree was empty")
		return
	end
    ModuleLoader.doFolder("", checkEntry(modulesTree))
	if #waitingForLoad > 0 then
		for moduleName, waiters in pairs(waitingForLoad) do
			logger:LogError("Unable to load: "..moduleName.." for "..#waiters.." modules")
		end
		computer.panic("Unable to load modules")
	end
    logger:LogDebug("loaded modules")
end

function ModuleLoader.GetModule(moduleNameToLoad)
    for moduleName, module in pairs(libs) do
        if moduleName == moduleNameToLoad then
            return module
        end
    end
	ModuleLoader.handleCouldNotLoadModule(moduleNameToLoad)
	error("Unable to load module: "..moduleNameToLoad)
end