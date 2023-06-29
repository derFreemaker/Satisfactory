local Event = require("Ficsit-Networks_Sim.Utils.Event")
local Tools = require("Ficsit-Networks_Sim.Utils.Tools")

---@alias Ficsit_Networks_Sim.Utils.Logger.LogLevel integer
---|0 Trace
---|1 Debug
---|2 Info
---|3 Warning
---|4 Error
---|5 Fatal

---@class Ficsit_Networks_Sim.Utils.Logger
---@field OnLog Ficsit_Networks_Sim.Utils.Event
---@field OnAllLog Ficsit_Networks_Sim.Utils.Event
---@field OnClearLog Ficsit_Networks_Sim.Utils.Event
---@field OnClearMainLog Ficsit_Networks_Sim.Utils.Event
---@field Name string
---@field private logLevel Ficsit_Networks_Sim.Utils.Logger.LogLevel
local Logger = {}
Logger.__index = Logger

---@private
---@param node table
---@param maxLevel number | nil
---@param properties string[] | nil
---@param logFunc function
---@param logFuncParent table
---@param level number | nil
---@param padding string | nil
---@return Array<string>
function Logger.tableToLineTree(node, maxLevel, properties, logFunc, logFuncParent, level, padding)
  padding = padding or '     '
  maxLevel = maxLevel or 5
  level = level or 1
  local lines = {}

  if type(node) == 'table' then
    local keys = {}
    if type(properties) == 'string' then
      local propSet = {}
      for p in string.gmatch(properties, "%b{}") do
        local propName = string.sub(p, 2, -2)
        for k in string.gmatch(propName, "[^,%s]+") do
          propSet[k] = true
        end
      end
      for k in pairs(node) do
        if propSet[k] then
          keys[#keys + 1] = k
        end
      end
    else
      for k in pairs(node) do
        if not properties or properties[k] then
          keys[#keys + 1] = k
        end
      end
    end
    table.sort(keys)

    for i, k in ipairs(keys) do
      local line = ''
      if i == #keys then
        line = padding .. '└── ' .. tostring(k)
      else
        line = padding .. '├── ' .. tostring(k)
      end
      table.insert(lines, line)

      if level < maxLevel then
        ---@cast properties string[]
        local childLines = Logger.tableToLineTree(node[k], maxLevel, properties, logFunc, logFuncParent, level + 1,
          padding .. (i == #keys and '    ' or '│   '))
        for _, l in ipairs(childLines) do
          table.insert(lines, l)
        end
      elseif i == #keys then
        table.insert(lines, padding .. '└── ...')
      end
    end
  else
    table.insert(lines, padding .. tostring(node))
  end

  if level == 1 then
    if logFuncParent == nil then
      for line in pairs(lines) do
        logFunc(line)
      end
    elseif type(logFuncParent) ~= "table" then
      error("logFuncParent was not a table", 2)
    else
      for line in pairs(lines) do
        logFunc(logFuncParent, line)
      end
    end
  end

  return lines
end

---@param name string
---@param logLevel Ficsit_Networks_Sim.Utils.Logger.LogLevel | integer
---@return Ficsit_Networks_Sim.Utils.Logger
function Logger.new(name, logLevel)
  return setmetatable({
    logLevel = (logLevel or 0),
    Name = (string.gsub(name, " ", "_") or ""),
    OnLog = Event.new(),
    OnAllLog = Event.new(),
    OnClearLog = Event.new(),
    OnClearMainLog = Event.new()
  }, Logger)
end

---@param name string
---@return Ficsit_Networks_Sim.Utils.Logger
function Logger:create(name)
  local logger = Logger.new(self.Name .. "." .. name, self.logLevel)
  logger.OnLog:TransferListeners(self.OnLog)
  logger.OnAllLog:TransferListeners(self.OnAllLog)
  logger.OnClearMainLog:TransferListeners(self.OnClearMainLog)
  return logger
end

---@private
---@param message string
---@param logLevel number
function Logger:Log(message, logLevel)
  message = "[" .. self.Name .. "] " .. message

  self.OnAllLog:Trigger(message)
  if logLevel >= self.logLevel then
    self.OnLog:Trigger(message)
  end
end

---@param message any
function Logger:LogTrace(message)
  if message == nil then return end
  self:Log("TRACE! " .. tostring(message), 0)
end

---@param table table | any
---@param maxLevel number | nil
---@param properties table | nil
function Logger:LogTableTrace(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  Logger.tableToLineTree(table, maxLevel, properties, self.LogTrace, self)
end

---@param message any
function Logger:LogDebug(message)
  if message == nil then return end
  self:Log("DEBUG! " .. tostring(message), 1)
end

---@param table table | any
---@param maxLevel number | nil
---@param properties table | nil
function Logger:LogTableDebug(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  Logger.tableToLineTree(table, maxLevel, properties, self.LogDebug, self)
end

---@param message any
function Logger:LogInfo(message)
  if message == nil then return end
  self:Log("INFO! " .. tostring(message), 2)
end

---@param table table | any
---@param maxLevel number | nil
---@param properties table | nil
function Logger:LogTableInfo(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  Logger.tableToLineTree(table, maxLevel, properties, self.LogInfo, self)
end

---@param message any
function Logger:LogWarning(message)
  if message == nil then return end
  self:Log("WARN! " .. tostring(message), 3)
end

---@param table table | any
---@param maxLevel number | nil
---@param properties table | nil
function Logger:LogTableWarning(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  Logger.tableToLineTree(table, maxLevel, properties, self.LogWarning, self)
end

---@param message any
function Logger:LogError(message)
  if message == nil then return end
  self:Log("ERROR! " .. tostring(message), 4)
end

---@param table table | any
---@param maxLevel number | nil
---@param properties table | nil
function Logger:LogTableError(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  Logger.tableToLineTree(table, maxLevel, properties, self.LogError, self)
end

---@param message any
function Logger:LogFatal(message)
  if message == nil then return end
  self:Log("FATAL! " .. tostring(message), 5)
end

---@param table table | any
---@param maxLevel number | nil
---@param properties table | nil
function Logger:LogTableFatal(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  Logger.tableToLineTree(table, maxLevel, properties, self.LogFatal, self)
end

---@param clearMainFile boolean | nil
function Logger:ClearLog(clearMainFile)
  if clearMainFile then
    self.OnClearMainLog:Trigger()
  end
  self.OnClearLog:Trigger()
end

return Logger
