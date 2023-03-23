---@class Logger
---@field private logLevel number
---@field private path string
---@field Name string
local Logger = {}
Logger.__index = Logger

local mainLogFilePath = filesystem.path("log", "Log.txt")

local function tableToLineTree(node, padding, maxLevel, level, properties)
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
        local childLines = tableToLineTree(node[k], padding .. (i == #keys and '    ' or '│   '), maxLevel, level + 1,
          properties)
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

  return lines
end

function Logger.new(name, logLevel, path)
  if not filesystem.exists("log") then filesystem.createDir("log") end
  local instance = {
    logLevel = (logLevel or 0),
    path = (path or nil),
    Name = (string.gsub(name, " ", "_") or ""),
  }
  instance = setmetatable(instance, Logger)
  return instance
end

function Logger:create(name, path)
  return Logger.new(self.Name .. "." .. name, self.logLevel, path)
end

function Logger:Log(message, logLevel)
  message = "[" .. self.Name .. "] " .. message

  if self.path ~= nil then
    Utils.File.Write(self.path, "+a", message .. "\n")
  end

  Utils.File.Write(mainLogFilePath, "+a", message .. "\n")
  if logLevel >= self.logLevel then
    print(message)
  end
end

function Logger:LogTrace(message)
  if message == nil then return end
  self:Log("TRACE! " .. tostring(message), 0)
end

function Logger:LogTableTrace(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  local lineTree = tableToLineTree(table, nil, maxLevel, nil, properties)
  for _, line in pairs(lineTree) do
    self:LogTrace(line)
  end
end

function Logger:LogDebug(message)
  if message == nil then return end
  self:Log("DEBUG! " .. tostring(message), 1)
end

function Logger:LogTableDebug(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  local lineTree = tableToLineTree(table, nil, maxLevel, nil, properties)
  for _, line in pairs(lineTree) do
    self:LogDebug(line)
  end
end

function Logger:LogInfo(message)
  if message == nil then return end
  self:Log("INFO! " .. tostring(message), 2)
end

function Logger:LogTableInfo(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  local lineTree = tableToLineTree(table, nil, maxLevel, nil, properties)
  for _, line in pairs(lineTree) do
    self:LogInfo(line)
  end
end

function Logger:LogError(message)
  if message == nil then return end
  self:Log("ERROR! " .. tostring(message), 3)
end

function Logger:LogTableError(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  local lineTree = tableToLineTree(table, nil, maxLevel, nil, properties)
  for _, line in pairs(lineTree) do
    self:LogError(line)
  end
end

function Logger:ClearLog(clearMainFile)
  if self.path ~= nil then
    local ownFile = filesystem.open(self.path, "w")
    ownFile:write("")
    ownFile:close()
  end

  if clearMainFile then
    local mainFile = filesystem.open("log\\Log.txt", "w")
    mainFile:write("")
    mainFile:close()
  end
end

return Logger
