ModuleLoader = {}
ModuleLoader.__index = {}

local libs = {}

local function checkEntry(entry)
	if entry.Name == nil then
		entry.Name = entry[1]
	end
	if entry.FullName == nil then
		entry.FullName = entry.Name
	end

	if entry.IsFolder ~= true then
		local nameLength = entry.Name:len()
    	if entry.FullName:sub(nameLength - 3, nameLength) ~= ".lua" then
       		entry.FullName = entry.FullName..".lua"
    	end
		if entry.Name:sub(nameLength - 3, nameLength) == ".lua" then
			entry.Name = entry.Name:sub(0, nameLength)
		end
	end
	return entry
end

function ModuleLoader.doEntry(parentPath, entry, debug)
	entry = checkEntry(entry)
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
    ModuleLoader.doFolder("", modulesTree, debug)
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
    for moduleName, module in pairs(libs) do
        if moduleName == moduleNameToLoad then
            return module
        end
    end
    computer.panic("FATAL! Unable to load: "..moduleNameToLoad)
end