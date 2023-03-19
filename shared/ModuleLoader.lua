ModuleLoader = {}

local function extractCallerInfo(path)
    local callerData = {
        FullName = filesystem.path(3, path),
        Path = path
    }
    return Utils.Entry.Check(callerData)
end

local _libs = {}
local _loadingPhase = false
local _waitingForLoad = {}
local _getGetWithName = true
local _logger = {}

function ModuleLoader.doEntry(entry)
    if entry.IgnoreLoad then return end
    if entry.IsFolder == true then
        ModuleLoader.doFolder(entry)
    else
        ModuleLoader.doFile(entry)
    end
end

function ModuleLoader.doFile(file)
    if file.IgnoreLoad == true then return end
    if filesystem.exists(file.Path) then
        ModuleLoader.LoadModule(file)
    else
        _logger:LogDebug("Unable to find module: " .. file.Path)
    end
end

function ModuleLoader.doFolder(folder)
    for _, child in pairs(folder.Childs) do
        if type(child) == "table" then
            ModuleLoader.doEntry(child)
        end
    end
end

function ModuleLoader.loadWaitingModules(awaitingModule)
    for i, moduleWaiters in pairs(_waitingForLoad) do
        if string.gsub(moduleWaiters.AwaitingModule, ".", "\\") == awaitingModule.Path then
            for x, waitingModule in pairs(moduleWaiters.Waiters) do
                local success = ModuleLoader.LoadModule(waitingModule)
                if success then
                    table.remove(moduleWaiters.Waiters, x)
                end
            end
        end
        if #moduleWaiters.Waiters == 0 then
            table.remove(_waitingForLoad, i)
        end
    end
end

function ModuleLoader.handleCouldNotLoadModule(moduleCouldNotLoad)
    local caller = extractCallerInfo(debug.getinfo(3).short_src)
    if caller == nil then
        _logger:LogError("caller was nil")
        return
    end
    for _, moduleWaiters in pairs(_waitingForLoad) do
        if string.gsub(moduleWaiters.AwaitingModule, ".", "\\") == moduleCouldNotLoad then
            table.insert(moduleWaiters.Waiters, caller)
            _logger:LogDebug("Added: '" .. caller.Name .. "' to load after '" .. moduleCouldNotLoad .. "' was loaded")
            return
        end
    end
    table.insert(_waitingForLoad, { AwaitingModule = moduleCouldNotLoad, Waiters = { caller } })
    _logger:LogDebug("Added: '" .. caller.Name .. "' to load after '" .. moduleCouldNotLoad .. "' was loaded")
end

function ModuleLoader.internalGetModule(moduleToGet)
    for _, lib in pairs(_libs) do
        if lib.Info.Path == string.gsub(moduleToGet, ".", "\\") then
            return lib
        end
        if _getGetWithName and lib.Info.Name == moduleToGet then
            return lib
        end
    end
end

function ModuleLoader.checkForSameModuleNames()
    local dupes = {}
    for _, lib in pairs(_libs) do
        for _, dupeLibInfo in pairs(dupes) do
            if lib.Info.Name == dupeLibInfo.Name then
                _getGetWithName = false
                return
            end
        end
        table.insert(dupes, lib.Info)
    end
end

function ModuleLoader.Initialize(logger)
    _logger = logger:create("MOduleLoader")
end

function ModuleLoader.GetModules()
    local clone = {}
    for _, value in pairs(_libs) do
        table.insert(clone, value)
    end
    return clone
end

function ModuleLoader.LoadModule(file)
    if file.IgnoreLoad == true then return true end
    _logger:LogTrace("loading module: '" .. file.Name .. "' from path: '" .. file.Path .. "'")
    local success, fileData = pcall(filesystem.doFile, file.Path)
    if not success then
        _logger:LogTrace("unable to load module: '" .. file.Name .. "'")
        return false
    end
    table.insert(_libs, { Info = file, Data = fileData })
    _logger:LogTrace("loaded module: '" .. file.Name .. "'")

    ModuleLoader.loadWaitingModules(file)
    return true
end

function ModuleLoader.LoadModules(modulesTree, loadingPhase)
    _loadingPhase = loadingPhase or false
    _logger:LogDebug("loading modules...")
    if modulesTree == nil then
        _logger:LogDebug("modules tree was empty")
        return true
    end
    ModuleLoader.doFolder(Utils.Entry.Check(modulesTree))
    if #_waitingForLoad > 0 then
        for _, waiters in pairs(_waitingForLoad) do
            _logger:LogError("Unable to load: '" .. waiters.AwaitingModule ..
                "' for '" .. #waiters.Waiters .. "' modules")
        end
        _logger:LogError("Unable to load modules")
        return false
    end
    _logger:LogDebug("loaded modules")
    _loadingPhase = false
    ModuleLoader.checkForSameModuleNames()
    return true
end

function ModuleLoader.PreLoadModule(moduleToLoad)
    local lib = ModuleLoader.internalGetModule(moduleToLoad)
    if lib ~= nil then
        _logger:LogTrace("pre loaded module: '" .. lib.Info.Name .. "'")
        return lib.Data
    end
    ModuleLoader.handleCouldNotLoadModule(moduleToLoad)
    error("unable to load module: '" .. moduleToLoad .. "'")
end

function ModuleLoader.GetModule(moduleToLoad)
    if _loadingPhase then
        computer.panic("can't get module while being in loading phase")
    end
    local lib = ModuleLoader.internalGetModule(moduleToLoad)
    _logger:LogTrace("geted module: '" .. lib.Info.Name .. "'")
    return lib.Data
end

function require(moduleToLoad)
    if _loadingPhase then
        return ModuleLoader.PreLoadModule(moduleToLoad)
    end
    return ModuleLoader.GetModule(moduleToLoad)
end
