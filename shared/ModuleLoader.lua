ModuleLoader = {}
ModuleLoader.__index = {}

local libs = {}
local logger = {}

local function checkTree(entry)
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

    local checkedEntry = {
        Name = "",
        FullName = "",
        IsFolder = false,
    }

    checkedEntry.Name = entry.Name
    checkedEntry.FullName = entry.FullName
    checkedEntry.IsFolder = entry.IsFolder
	checkedEntry.IgnoreLoad = entry.IgnoreLoad

	if entry.IsFolder and not entry.IgnoreLoad then
		local childs = {}
		for _, child in pairs(entry) do
			if type(child) == "table" then
				table.insert(childs, checkTree(child))
			end
		end
		checkedEntry.Childs = childs
	end

	return checkedEntry
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

function ModuleLoader.Initialize(newLogger)
    logger = newLogger
end

function ModuleLoader.LoadModules(modulesTree)
    logger:LogDebug("loading modules...")
	if modulesTree == nil then
		logger:LogDebug("modules tree was empty")
		return
	end
    ModuleLoader.doFolder("", checkTree(modulesTree))
    logger:LogDebug("loaded modules")
end

function ModuleLoader.LoadModule(file, path)
    if file.IgnoreLoad == true then return end
    libs[file.Name] = filesystem.doFile(path)
    logger:LogDebug("loaded module: "..file.Name)
end

function ModuleLoader.GetModule(moduleNameToLoad)
    for moduleName, module in pairs(libs) do
        if moduleName == moduleNameToLoad then
            return module
        end
    end
    computer.panic("FATAL! Unable to load: "..moduleNameToLoad)
end