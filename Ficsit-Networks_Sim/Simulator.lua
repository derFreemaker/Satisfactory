local Path = require("Ficsit-Networks_Sim.Filesystem.Path")
local Listener = require("Ficsit-Networks_Sim.Utils.Listener")
local Logger = require("Ficsit-Networks_Sim.Utils.Logger")
local SimulatorNetwork = require("Ficsit-Networks_Sim.Network.SimulatorNetwork")
local FileSystemManager = require("Ficsit-Networks_Sim.Filesystem.FileSystemManager")
local EEPROMManager     = require("Ficsit-Networks_Sim.Computer.EEPROMManager")
local ComponentManager  = require("Ficsit-Networks_Sim.Component.ComponentManager")
local SimulatorConfig   = require("Ficsit-Networks_Sim.SimulatorConfig")

---@alias Ficsit_Networks_Sim.Simulator.exitcode integer
---|0 success
---|1 stop
---|2 error
---|3 reset

---@class Ficsit_Networks_Sim.Simulator
---@field Id string
---@field CurrentPath Ficsit_Networks_Sim.Filesystem.Path
---@field CurrentDataPath Ficsit_Networks_Sim.Filesystem.Path
---@field private simLibPath Ficsit_Networks_Sim.Filesystem.Path
---@field private simThread thread | nil
---@field private simConfig Ficsit_Networks_Sim.SimulatorConfig
---@field private configureFunc function
---@field private loaded boolean
---@field private filePath string
---@field private fileSystemManager Ficsit_Networks_Sim.Filesystem.FileSystemManager
---@field private EEPROMManager Ficsit_Networks_Sim.Computer.EEPROMManager
---@field private componentManager Ficsit_Networks_Sim.Component.ComponentManager
---@field private filesystemAPI Ficsit_Networks_Sim.filesystem
---@field private computerAPI Ficsit_Networks_Sim.computer
---@field private componentAPI Ficsit_Networks_Sim.component
---@field private logger Ficsit_Networks_Sim.Utils.Logger
local Simulator = {}
Simulator.__index = Simulator

---@param configure function | nil
---@param id string
---@param filePath string
---@param currentPath string | Ficsit_Networks_Sim.Filesystem.Path
---@param logLevel Ficsit_Networks_Sim.Utils.Logger.LogLevel
---@return Ficsit_Networks_Sim.Simulator
function Simulator.new(configure, id, filePath, currentPath, logLevel)
    if type(currentPath) == "string" then
        currentPath = Path.new(currentPath)
    elseif type(currentPath) ~= "table" then
        error("What the fuck are you doing?! Check currentPath!", 2)
    end

    local source = debug.getinfo(1, "S").source:gsub("\\", "/"):gsub("@", "")
    local slashPos = source:reverse():find("/")
    local lenght = source:len()
    local simLibPath = Path.new(source:sub(0, lenght - slashPos))

    local logger = Logger.new("Simulator:'" .. id .. "'", logLevel)

    return setmetatable({
        simLibPath = simLibPath,
        Id = id,
        configureFunc = (configure or (function() return true end)),
        loaded = false,
        filePath = filePath,
        CurrentPath = currentPath,
        CurrentDataPath = currentPath:Extend("Ficsit-Networks"),
        logger = logger
    }, Simulator)
end

---@private
function Simulator:configure()
    self.simConfig = SimulatorConfig.new(self.logger)
    if self.configureFunc and not self.configureFunc(self.simConfig) then
        error("Unable to configure. Do you return true if the function successes?", 2)
    end
    self.logger:LogDebug("configured Simulator")
end

function Simulator:loadNetwork()
    self.simNetwork = SimulatorNetwork.new(self.CurrentDataPath:Extend("Network"),
        self.Id, self.logger:create("SimulatorNetwork"))
    self.logger:LogDebug("loaded Simulator Network")
end

---@private
function Simulator:loadFileSystemAPI()
    self.fileSystemManager = FileSystemManager.new(self.CurrentDataPath:Extend("Filesystem"), self.Id)
    local filesystemFunc = loadfile(self.simLibPath:Extend("filesystem.lua"):GetPath())
    if not filesystemFunc then
        error("Unable to load filesystem API", 3)
    end
    self.filesystemAPI = filesystemFunc(self.fileSystemManager)
    self.logger:LogDebug("loaded file system API")
end

---@private
function Simulator:loadComputerAPI()
    self.EEPROMManager = EEPROMManager.new(self.CurrentPath:Extend(self.filePath):GetPath())
    local computerFunc = loadfile(self.simLibPath:Extend("computer.lua"):GetPath())
    if not computerFunc then
        error("Unable to load computer API", 3)
    end
    self.computerAPI = computerFunc(self.EEPROMManager, self)
    self.logger:LogDebug("loaded computer API")
end

---@private
function Simulator:loadComponentAPI()
    self.componentManager = ComponentManager.new(self.simLibPath)
    self.componentManager:LoadComponentClasses()
    local componentFunc = loadfile(self.simLibPath:Extend("component.lua"):GetPath())
    if not componentFunc then
        error("Unable to load component API", 3)
    end
    self.componentAPI = componentFunc(self.componentManager)
    self.logger:LogDebug("loaded component API")
end

---@private
function Simulator:applyConfiguration()
    self.fileSystemManager:Configure(self.simConfig.FileSystemConfig)
    self.componentManager:Configure(self.simConfig.ComponentConfig)
    self.logger:LogDebug("loaded rest of configuration")
end

---@private
function Simulator:loadGlobal()
    filesystem = self.filesystemAPI
    computer = self.computerAPI
    component = self.componentAPI
    local globalFunctionsFunc = loadfile(self.simLibPath:Extend("GlobalFunctions.lua"):GetPath())
    if not globalFunctionsFunc then
        error("Unable to load global functions", 3)
    end
    globalFunctionsFunc(self.componentManager)
    self.logger:LogDebug("mapped all global functions and APIs")
end

---@return boolean
function Simulator:Load()
    self:configure()
    self:loadNetwork()
    self:loadFileSystemAPI()
    self:loadComputerAPI()
    self:loadComponentAPI()
    self:applyConfiguration()
    self:loadGlobal()

    -- //TODO: finish load sequence
    self.simThread = coroutine.create(self.EEPROMManager:GetEEPROMFunc())
    self.loaded = true
    return true
end

---@return boolean
function Simulator:Cleanup()
    self.fileSystemManager:Cleanup()
    self.fileSystemManager = nil
    filesystem = nil
    computer = nil
    component = nil
    event = nil
    return true
end

---@return boolean
function Simulator:Start()
    local success, result, message
    repeat
        self.logger:LogDebug("running script...")
        print([[\\\\\\\\\\]])
        ---@type boolean, Ficsit_Networks_Sim.Simulator.exitcode, string
        success, result, message = coroutine.resume(self.simThread)
        print("//////////")
        if result == 3 then
            if not self:Cleanup() then
                self.logger:LogError("Unable to cleanup")
                error("Unable to cleanup")
            end
            self:Load()
        end
    until result ~= 3
    success = success or false
    result = result or 0
    ---@cast success boolean
    ---@cast result Ficsit_Networks_Sim.Simulator.exitcode
    ---@cast message string
    if  result == 1 then
        self.logger:LogInfo("Process ended with message: '" .. message .. "'")
    elseif not success and (result == 2 or type(result) ~= "number") then
        self.logger:LogError("Process crashed: \n" .. result .. "\n" .. debug.traceback(self.simThread))
    elseif result == 3 then
        self.logger:LogFatal("How the Fuck?! Are you here!")
    end
    if not self:Cleanup() then
        self.logger:LogError("Unable to cleanup")
        error("Unable to cleanup")
    end
    if success then
        self.logger:LogInfo("Simulator finished successfully")
    else
        self.logger:LogInfo("Simulator didn't finish successfully")
    end
    return success
end

---@param exitCode Ficsit_Networks_Sim.Simulator.exitcode
---@param message string
function Simulator:Stop(exitCode, message)
    exitCode = exitCode or 1
    if coroutine.running() == self.simThread then
        if exitCode == 0 then
            error(message, 3)
        else
            coroutine.yield(exitCode, message)
        end
        return
    end
    if coroutine.status(self.simThread) == "running" then
        error("this is not possible! What are you doing")
    end
    self.simThread = nil
end

---@return boolean success
function Simulator:Run()
    if not self:Load() then
        error("Unable to load Simulator")
    else
        self.logger:LogInfo("loaded Simulator")
    end
    return self:Start()
end

function Simulator:Reset()
    self:Stop(3, "reset")
end

return Simulator
