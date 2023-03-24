---@class ModuleOld
---@field Info Entry
---@field Data 'ModuleType'
local ModuleOld = {}
ModuleOld.__index = {}

---@param info Entry
---@param data 'ModuleType'
---@return ModuleOld
function ModuleOld.new(info, data)
    return setmetatable({
        Info = info,
        Data = data
    }, ModuleOld)
end

---@class WaitingModuleOld
---@field AwaitingModule string
---@field Waiters Entry[]
local WaitingModuleOld = {}
WaitingModuleOld.__index = WaitingModuleOld

---@param awaitingModule string
---@param waiters Entry[]
---@return WaitingModuleOld
function WaitingModuleOld.new(awaitingModule, waiters)
    return setmetatable({
        AwaitingModule = awaitingModule,
        Waiters = waiters
    }, WaitingModuleOld)
end

---@class ModuleLoaderOld
---@field private libs ModuleOld[]
---@field private waitingForLoad WaitingModuleOld[]
---@field private loadingPhase boolean
---@field private getGetWithName boolean
---@field private logger Logger
ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

function ModuleLoader.extractCallerInfo(path)
    local callerData = {
        FullName = filesystem.path(3, path),
        Path = path
    }
    return Utils.Entry.Parse(callerData)
end

---@private
---@param entry Entry
function ModuleLoader.doEntry(entry)
    if entry.IgnoreLoad then return end
    if entry.IsFolder == true then
        ModuleLoader.doFolder(entry)
    else
        ModuleLoader.doFile(entry)
    end
end

---@private
---@param file Entry
function ModuleLoader.doFile(file)
    if file.IgnoreLoad == true then return end
    if filesystem.exists(file.Path) then
        ModuleLoader.LoadModule(file)
    else
        ModuleLoader.logger:LogDebug("Unable to find module: " .. file.Path)
    end
end

---@private
---@param folder Entry
function ModuleLoader.doFolder(folder)
    for _, child in pairs(folder.Childs) do
        if type(child) == "table" then
            ModuleLoader.doEntry(child)
        end
    end
end

---@private
---@param awaitingModule ModuleOld
function ModuleLoader.loadWaitingModules(awaitingModule)
    for i, moduleWaiters in pairs(ModuleLoader.waitingForLoad) do
        if string.gsub(moduleWaiters.AwaitingModule, "%.", "/") .. ".lua" == awaitingModule.Info.Path then
            for _, waitingModule in pairs(moduleWaiters.Waiters) do
                ModuleLoader.LoadModule(waitingModule)
            end
        end
        table.remove(ModuleLoader.waitingForLoad, i)
    end
end

---@private
---@param moduleCouldNotLoad string
function ModuleLoader.handleCouldNotLoadModule(moduleCouldNotLoad)
    local caller = ModuleLoader.extractCallerInfo(debug.getinfo(3).short_src)
    if caller == nil then
        ModuleLoader.logger:LogError("caller was nil")
        return
    end
    for _, moduleWaiters in pairs(ModuleLoader.waitingForLoad) do
        if moduleWaiters.AwaitingModule == moduleCouldNotLoad then
            table.insert(moduleWaiters.Waiters, caller)
            ModuleLoader.logger:LogDebug("added: '" ..
                caller.Name .. "' to load after '" .. moduleCouldNotLoad .. "' was loaded")
            return
        end
    end
    table.insert(ModuleLoader.waitingForLoad, WaitingModuleOld.new(moduleCouldNotLoad, { caller }))
    ModuleLoader.logger:LogDebug("added: '" .. caller.Name .. "' to load after '" .. moduleCouldNotLoad .. "' was loaded")
end

---@private
---@param moduleToGet string
function ModuleLoader.internalGetModule(moduleToGet)
    for _, lib in pairs(ModuleLoader.libs) do
        if lib.Info.Path == string.gsub(moduleToGet, "%.", "/") .. ".lua" then
            return lib
        end
        if ModuleLoader.getGetWithName and lib.Info.Name == moduleToGet then
            return lib
        end
    end
end

---@private
function ModuleLoader.checkForSameModuleNames()
    local dupes = {}
    for _, lib in pairs(ModuleLoader.libs) do
        for _, dupeLibInfo in pairs(dupes) do
            if lib.Info.Name == dupeLibInfo.Name then
                ModuleLoader.getGetWithName = false
                return
            end
        end
        table.insert(dupes, lib.Info)
    end
end

---@param logger Logger
function ModuleLoader.Initialize(logger)
    ModuleLoader.libs = {}
    ModuleLoader.waitingForLoad = {}
    ModuleLoader.loadingPhase = false
    ModuleLoader.getGetWithName = false
    ModuleLoader.logger = logger:create("ModuleLoader")
end

function ModuleLoader.GetModules()
    local clone = {}
    for _, value in pairs(ModuleLoader.libs) do
        table.insert(clone, value)
    end
    return clone
end

---@param fileEntry Entry
function ModuleLoader.LoadModule(fileEntry)
    if fileEntry.IgnoreLoad == true then return true end
    ModuleLoader.logger:LogTrace("loading module: '" .. fileEntry.Name .. "' from path: '" .. fileEntry.Path .. "'")
    local success, fileData = pcall(filesystem.doFile, fileEntry.Path)
    if not success then
        ModuleLoader.logger:LogTrace("unable to load module: '" .. fileEntry.Name .. "'")
        return
    end
    local module = ModuleOld.new(fileEntry, fileData)
    table.insert(ModuleLoader.libs, module)
    ModuleLoader.logger:LogTrace("loaded module: '" .. fileEntry.Name .. "'")

    ModuleLoader.loadWaitingModules(module)
end

---@param modulesTree Entry
---@param loadingPhase boolean
---@return boolean
function ModuleLoader.LoadModules(modulesTree, loadingPhase)
    ModuleLoader.loadingPhase = loadingPhase or false
    ModuleLoader.logger:LogTrace("loading modules...")
    if modulesTree == nil then
        ModuleLoader.logger:LogDebug("modules tree was empty")
        return true
    end
    ModuleLoader.doFolder(modulesTree)
    if #ModuleLoader.waitingForLoad > 0 then
        for _, waiters in pairs(ModuleLoader.waitingForLoad) do
            local waitersNames = waiters.Waiters[1].Name
            for i, waiter in pairs(waiters.Waiters) do
                if i ~= 1 then
                    waitersNames = waitersNames .. ", '" .. waiter.Name .. "'"
                end
            end
            ModuleLoader.logger:LogError("Unable to load: '" .. waiters.AwaitingModule ..
                "' for '" .. waitersNames .. "'")
        end
        ModuleLoader.logger:LogError("Unable to load modules")
        return false
    end
    ModuleLoader.logger:LogTrace("loaded modules")
    ModuleLoader.loadingPhase = false
    ModuleLoader.checkForSameModuleNames()
    return true
end

---@param moduleToLoad string
---@return 'ModuleType'
function ModuleLoader.PreLoadModule(moduleToLoad)
    local lib = ModuleLoader.internalGetModule(moduleToLoad)
    if lib ~= nil then
        ModuleLoader.logger:LogTrace("pre loaded module: '" .. lib.Info.Name .. "'")
        return lib.Data
    end
    ModuleLoader.handleCouldNotLoadModule(moduleToLoad)
    error("unable to load module: '" .. moduleToLoad .. "'")
end

---@param moduleToLoad string
---@return 'ModuleType'
function ModuleLoader.GetModule(moduleToLoad)
    if ModuleLoader.loadingPhase then
        computer.panic("can't get module while being in loading phase")
    end
    local lib = ModuleLoader.internalGetModule(moduleToLoad)
    if lib == nil then
        error("could not get module: '" .. moduleToLoad .. "'")
    end
    ModuleLoader.logger:LogTrace("geted module: '" .. lib.Info.Name .. "'")
    return lib.Data
end

---@param moduleToLoad string
---@return 'ModuleType'
function require(moduleToLoad)
    if ModuleLoader.loadingPhase then
        return ModuleLoader.PreLoadModule(moduleToLoad)
    end
    return ModuleLoader.GetModule(moduleToLoad)
end
