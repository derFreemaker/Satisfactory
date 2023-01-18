ModuleLoader = {}
ModuleLoader.__index = {}

local libs = {}

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
        Childs = {}
    }

    checkedEntry.Name = entry.Name
    checkedEntry.FullName = entry.FullName
    checkedEntry.IsFolder = entry.IsFolder

    for _, child in pairs(entry) do
        if type(child) == "table" then
            table.insert(checkedEntry.Childs, checkTree(child))
        end
    end

	return checkedEntry
end

function ModuleLoader.doEntry(parentPath, entry, debug)
	if entry.IsFolder == true then
		ModuleLoader.doFolder(parentPath, entry, debug)
	else
		ModuleLoader.doFile(parentPath, entry, debug)
	end
end

function ModuleLoader.doFile(parentPath, file, debug)
	local path = filesystem.path(parentPath, file.FullName)
	if filesystem.exists(path) then
		ModuleLoader.LoadModule(file, path, debug)
    else
        print("DEBUG! Unable to find module: "..path)
	end
end

function ModuleLoader.doFolder(parentPath, folder, debug)
	local path = filesystem.path(parentPath, folder.Name)
	table.remove(folder, 1)
	filesystem.createDir(path)
	for _, child in pairs(folder) do
		if type(child) == "table" then
			ModuleLoader.doEntry(path, child, debug)
		end
	end
end

function ModuleLoader.LoadModules(modulesTree, debug)
    if debug then
        print("DEBUG! loading modules")
    end
    ModuleLoader.doFolder("", checkTree(modulesTree), debug)
    if debug then
        print("DEBUG! loaded modules")
    end
end

function ModuleLoader.LoadModule(file, path, debug)
    if file.IgnoreLoad == true then return end
    libs[file.Name] = filesystem.doFile(path)
    if debug then
        print("DEBUG! loaded module: "..file.Name)
    end
end

function ModuleLoader.GetModule(moduleNameToLoad)
	print(libs)
    for moduleName, module in pairs(libs) do
        if moduleName == moduleNameToLoad then
            return module
        end
    end
    computer.panic("FATAL! Unable to load: "..moduleNameToLoad)
end