local PackageData = {}

-- ########## Core ##########

-- ########## Core.libs ##########

-- ########## Core.libs.Api ##########

PackageData.PksKdJNx = {
    Namespace = "Core.libs.Api.ApiClient",
    Name = "ApiClient",
    FullName = "ApiClient.lua",
    IsRunable = true,
    Data = [[
local ApiClient = {}
ApiClient.__index = ApiClient
function ApiClient.new(netClient, serverIPAddress, serverPort, returnPort)
    local instance = setmetatable({
        NetClient = netClient,
        ServerIPAddress = serverIPAddress,
        ServerPort = serverPort,
        ReturnPort = returnPort,
        Logger = netClient.Logger:create("ApiClient")
    }, ApiClient)
    return instance
end
function ApiClient:request(endpointName, data)
    self.NetClient:SendMessage(self.ServerIPAddress, self.ServerPort, endpointName, data, { ReturnPort = self.ReturnPort })
    local response = self.NetClient:WaitForEvent(endpointName, self.ReturnPort)
    response.Body.Success = response.Body.Success or false
    response.Body.Result = response.Body.Result or nil
    return response
end
return ApiClient
]] }


PackageData.qzdVACkX = {
    Namespace = "Core.libs.Api.ApiController",
    Name = "ApiController",
    FullName = "ApiController.lua",
    IsRunable = true,
    Data = [[
local Listener = require("libs.Listener")
local ApiEndpoint = require("libs.Api.ApiEndpoint")
local ApiController = {}
ApiController.__index = ApiController
function ApiController.new(netPort)
    local instance = setmetatable({
        NetPort = netPort,
        _logger = netPort.Logger:create("ApiController"),
        Endpoints = {}
    }, ApiController)
    netPort:AddListener("all", Listener.new(instance.onMessageRecieved, instance))
    return instance
end
function ApiController:onMessageRecieved(context)
    self.Logger:LogTrace("recieved request on endpoint: " .. context.EventName)
    local thread, success, result = self:ExcuteEndpoint(context)
    if context.Header.ReturnPort ~= nil then
        self.NetPort.NetClient:SendMessage(context.SenderIPAddress, context.Header.ReturnPort,
            context.EventName, { Success = success, Result = result })
    end
    if success then
        self.Logger:LogTrace("request finished successfully")
    else
        self.Logger:LogTrace("request finished with error: " .. debug.traceback(thread, result))
    end
end
function ApiController:GetEndpoint(name)
    for _, endpoint in pairs(self.Endpoints) do
        if endpoint.Name == name then
            return endpoint
        end
    end
    return nil
end
function ApiController:AddEndpoint(name, listener)
    if self:GetEndpoint(name) ~= nil then error("Endpoint allready exsits") end
    table.insert(self.Endpoints, ApiEndpoint.new(name, listener))
    return self
end
function ApiController:ExcuteEndpoint(context)
    local endpoint = self.Endpoints[""]
    if endpoint == nil then
        local NotFound = "Not Found"
        ---@cast NotFound 'result'
        return nil, false, NotFound
    end
    return endpoint:Execute(self.Logger, context)
end
return ApiController
]] }


PackageData.RONgYwHx = {
    Namespace = "Core.libs.Api.ApiEndpoint",
    Name = "ApiEndpoint",
    FullName = "ApiEndpoint.lua",
    IsRunable = true,
    Data = [[
local ApiEndpoint = {}
ApiEndpoint.__index = ApiEndpoint
function ApiEndpoint.new(name, listener)
    return setmetatable({
        Name = name,
        Listener = listener
    }, ApiEndpoint)
end
function ApiEndpoint:Execute(logger, context)
    return self.Listener:Execute(logger, context)
end
return ApiEndpoint
]] }

-- ########## Core.libs.Api ########## --


-- ########## Core.libs.NetworkClient ##########

PackageData.TtiCTjCx = {
    Namespace = "Core.libs.NetworkClient.NetworkClient",
    Name = "NetworkClient",
    FullName = "NetworkClient.lua",
    IsRunable = true,
    Data = [[
local Serializer = require("libs.Serializer")
local EventPullAdapter = require("libs.EventPullAdapter")
local NetworkPort = require("libs.NetworkClient.NetworkPort")
local NetworkContext = require("libs.NetworkClient.NetworkContext")
local Listener = require("libs.Listener")
local NetworkClient = {}
NetworkClient.__index = NetworkClient
function NetworkClient.new(logger, networkCard)
    if networkCard == nil then
        networkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]
        if networkCard == nil then
            error("no networkCard was found")
            return
        end
    end
    local instance = {
        ports = {},
        networkCard = networkCard,
        Logger = logger:create("NetworkCard")
    }
    instance = setmetatable(instance, NetworkClient)
    event.listen(instance.networkCard)
    EventPullAdapter:AddListener("NetworkMessage", Listener.new(instance.networkMessageRecieved, instance))
    return instance
end
function NetworkClient:networkMessageRecieved(signalName, signalSender, data)
    if data == nil then return end
    local extractedData = {
        SenderIPAddress = data[1],
        Port = data[2],
        EventName = data[3],
        Header = data[4],
        Body = data[5]
    }
    self.Logger:LogTrace("got network message with event: '" ..
    extractedData.EventName .. "'' on port: '" .. extractedData.Port .. "'")
    if extractedData.EventName == nil then return end
    local removePorts = {}
    for i, port in pairs(self.ports) do
        if port.Port == extractedData.Port or port.Port == "all" then
            port:executeCallback(NetworkContext.Parse(signalName, signalSender, extractedData))
        end
        if #port.Events == 0 then
            table.insert(removePorts, { Pos = i, Port = port })
        end
    end
    for _, port in pairs(removePorts) do
        port.Port:ClosePort()
        table.remove(self.ports, port.Pos)
    end
end
function NetworkClient:AddListener(onRecivedEventName, onRecivedPort, listener)
    onRecivedPort = (onRecivedPort or "all")
    for _, networkPort in pairs(self.ports) do
        if networkPort.Port == onRecivedPort then
            networkPort:AddListener(onRecivedEventName, listener)
            return networkPort
        end
    end
    local networkPort = self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListener(onRecivedEventName, listener)
    return networkPort
end
function NetworkClient:AddListenerOnce(onRecivedEventName, onRecivedPort, listener)
    onRecivedPort = (onRecivedPort or "all")
    for _, networkPort in pairs(self.ports) do
        if networkPort.Port == onRecivedPort then
            networkPort:AddListenerOnce(onRecivedEventName, listener)
            return networkPort
        end
    end
    local networkPort = self:CreateNetworkPort(onRecivedPort)
    networkPort:AddListenerOnce(onRecivedEventName, listener)
    return networkPort
end
function NetworkClient:CreateNetworkPort(port)
    port = (port or "all")
    local networkPort = self:GetNetworkPort(port)
    if networkPort ~= nil then return networkPort end
    networkPort = NetworkPort.new(port, self.Logger, self)
    table.insert(self.ports, networkPort)
    return networkPort
end
function NetworkClient:GetNetworkPort(port)
    for _, networkPort in pairs(self.ports) do
        if networkPort.Port == port then
            return networkPort
        end
    end
    return nil
end
function NetworkClient:WaitForEvent(eventName, port)
    local gotCalled = false
    local result = nil
    local function set(context)
        gotCalled = true
        result = context
    end
    while gotCalled == false do
        self:AddListenerOnce(eventName, port, Listener.new(set)):OpenPort()
        EventPullAdapter:Wait()
    end
    return result
end
function NetworkClient:OpenPort(port)
    self.networkCard:open(port)
end
function NetworkClient:ClosePort(port)
    self.networkCard:close(port)
end
function NetworkClient:CloseAllPorts()
    self.networkCard:closeAll()
end
function NetworkClient:SendMessage(ipAddress, port, eventName, data, header)
    self.networkCard:send(ipAddress, port, eventName, Serializer:Serialize(header or {}),
    Serializer:Serialize(data or {}))
end
function NetworkClient:BroadCastMessage(port, eventName, data)
    self.networkCard:broadcast(port, eventName, Serializer:Serialize(data))
end
return NetworkClient
]] }


PackageData.vISNqcZX = {
    Namespace = "Core.libs.NetworkClient.NetworkContext",
    Name = "NetworkContext",
    FullName = "NetworkContext.lua",
    IsRunable = true,
    Data = [[
local Serializer = require("libs.Serializer")
local NetworkContext = {}
NetworkContext.__index = NetworkContext
function NetworkContext.new(signalName, signalSender, senderIPAddress, port, eventName, header, body)
    return setmetatable({
        SignalName = signalName,
        SignalSender = signalSender,
        SenderIPAddress = senderIPAddress,
        Port = port,
        EventName = eventName,
        Header = header or {},
        Body = body or {}
    }, NetworkContext)
end
function NetworkContext.Parse(signalName, signalSender, extractedData)
    return NetworkContext.new(signalName, signalSender, extractedData.SenderIPAddress, extractedData.Port,
        extractedData.EventName, Serializer:Deserialize(extractedData.Body), Serializer:Deserialize(extractedData.Header))
end
return NetworkContext
]] }


PackageData.WXDYOWwx = {
    Namespace = "Core.libs.NetworkClient.NetworkPort",
    Name = "NetworkPort",
    FullName = "NetworkPort.lua",
    IsRunable = true,
    Data = [[
local Event = require("libs.Event")
local NetworkPort = {}
NetworkPort.__index = NetworkPort
function NetworkPort.new(port, logger, netClient)
    local instance = setmetatable({
        Port = port,
        Events = {},
        Logger = logger:create("Port:'"..port.."'"),
        NetClient = netClient
    }, NetworkPort)
    return instance
end
function NetworkPort:executeCallback(context)
    self.Logger:LogTrace("got triggerd with event: "..context.EventName)
    local removeEvent = {}
    for i, event in pairs(self.Events) do
        if event.Name == context.EventName or event.Name == "all" then
            event:Trigger(context)
        end
        if #event:Listeners() == 0 then
            table.insert(removeEvent, {Pos = i, Event = event})
        end
    end
    for _, event in pairs(removeEvent) do
        table.remove(self.Events, event.Pos)
    end
end
function NetworkPort:AddListener(onRecivedEventName, listener)
    for _, event in pairs(self.Events) do
        if event.Name == onRecivedEventName then
            event:AddListener(listener)
            return self
        end
    end
    local event = Event.new(onRecivedEventName, self.Logger)
    event:AddListener(listener)
    table.insert(self.Events, event)
    return self
end
function NetworkPort:AddListenerOnce(onRecivedEventName, listener)
    for _, event in pairs(self.Events) do
        if event.Name == onRecivedEventName then
            event:AddListenerOnce(listener)
            return self
        end
    end
    local event = Event.new(onRecivedEventName, self.Logger)
    event:AddListenerOnce(listener)
    table.insert(self.Events, event)
    return self
end
function NetworkPort:OpenPort()
    if type(self.Port) == "number" then
        self.NetClient:OpenPort(self.Port)
    end
end
function NetworkPort:ClosePort()
    if type(self.Port) == "number" then
        self.NetClient:ClosePort(self.Port)
    end
end
return NetworkPort
]] }

-- ########## Core.libs.NetworkClient ########## --


PackageData.xnnklPUX = {
    Namespace = "Core.libs.Event",
    Name = "Event",
    FullName = "Event.lua",
    IsRunable = true,
    Data = [[
local Event = {}
Event.__index = Event
function Event.new(name, logger)
    if name == nil then
        name = "Event"
    else
        name = name.."Event"
    end
    local instance = {
        funcs = {},
        onceFuncs = {},
        Logger = logger:create(name)
    }
    instance = setmetatable(instance, Event)
    return instance
end
function Event:AddListener(listener)
    table.insert(self.funcs, listener)
    return self
end
Event.On = Event.AddListener
function Event:AddListenerOnce(listener)
    table.insert(self.onceFuncs, listener)
    return self
end
Event.Once = Event.AddListenerOnce
function Event:Trigger(...)
    for _, listener in ipairs(self.funcs) do
        listener:Execute(self.Logger, ...)
    end
    for _, listener in ipairs(self.onceFuncs) do
        listener:Execute(self.Logger, ...)
    end
    self.OnceFuncs = {}
end
function Event:Listeners()
    local clone = {}
    for _, listener in ipairs(self.funcs) do
        table.insert(clone, {Mode = "Permanent", Listener = listener})
    end
    for _, listener in ipairs(self.onceFuncs) do
        table.insert(clone, {Mode = "Once", Listener = listener})
    end
    return clone
end
return Event
]] }


PackageData.YCXvIIrx = {
    Namespace = "Core.libs.EventPullAdapter",
    Name = "EventPullAdapter",
    FullName = "EventPullAdapter.lua",
    IsRunable = true,
    Data = [[
local Event = require("libs.Event")
local Listener = require("libs.Listener")
local EventPullAdapter = {}
EventPullAdapter.__index = EventPullAdapter
function EventPullAdapter:onEventPull(signalName, signalSender, data)
    ---@type number[]
    local removeEvent = {}
    for pos, event in pairs(self.events) do
        if event.Name == signalName .. "Event" then
            event:Trigger(signalName, signalSender, data)
        end
        if #event:Listeners() == 0 then
            table.insert(removeEvent, pos)
        end
    end
    for _, pos in pairs(removeEvent) do
        table.remove(self.events, pos)
    end
end
function EventPullAdapter:Initialize(logger)
    self.events = {}
    self.logger = logger:create("EventPullAdapter")
    self.OnEventPull = Event.new("EventPull", logger)
    self.OnEventPull:AddListener(Listener.new(self.onEventPull, self))
    return self
end
function EventPullAdapter:AddListener(signalName, listener)
    for _, event in pairs(self.events) do
        if event.Name == signalName .. "Event" then
            event:AddListener(listener)
            return self
        end
    end
    local event = Event.new(signalName, self.logger)
    event:AddListener(listener)
    table.insert(self.events, event)
    return self
end
function EventPullAdapter:AddListenerOnce(signalName, listener)
    for _, event in pairs(self.events) do
        if event.Name == signalName .. "Event" then
            event:AddListener(listener)
            return self
        end
    end
    local event = Event.new(signalName, self.logger)
    event:AddListenerOnce(listener)
    table.insert(self.events, event)
    return self
end
function EventPullAdapter:Wait()
    local eventPull = { event.pull() }
    local signalName, signalSender, data = (function(signalName, signalSender, ...)
        return signalName, signalSender, { ... }
    end)(table.unpack(eventPull))
    self.OnEventPull:Trigger(signalName, signalSender, data)
end
function EventPullAdapter:Run()
    while true do
        self:Wait()
    end
end
return EventPullAdapter
]] }


PackageData.zRIGgCOY = {
    Namespace = "Core.libs.Listener",
    Name = "Listener",
    FullName = "Listener.lua",
    IsRunable = true,
    Data = [[
local Listener = {}
Listener.__index = Listener
function Listener.new(func, parent)
    return setmetatable({
        func = func,
        parent = parent
    }, Listener)
end
function Listener:Execute(logger, ...)
    local thread, status, result = Utils.ExecuteFunction(self.func, self.parent, ...)
    if not status then
        logger:LogError("execution error: \n" .. debug.traceback(thread, result) .. debug.traceback():sub(17))
    end
    return thread, status, result
end
return Listener
]] }


PackageData.agsRDvly = {
    Namespace = "Core.libs.Serializer",
    Name = "Serializer",
    FullName = "Serializer.lua",
    IsRunable = true,
    Data = [[
local Serializer = {}
Serializer.__index = Serializer
local serialize
local function dostring(str)
    return assert((load)(str))()
end
local serialize_map = {
  [ "boolean" ] = tostring,
  [ "nil"     ] = tostring,
  [ "string"  ] = function(v) return string.format("%q", v) end,
  [ "number"  ] = function(v)
    if      v ~=  v     then return  "0/0"      --  nan
    elseif  v ==  1 / 0 then return  "1/0"      --  inf
    elseif  v == -1 / 0 then return "-1/0" end  -- -inf
    return tostring(v)
  end,
  [ "table"   ] = function(t, stk)
    stk = stk or {}
    if stk[t] then error("circular reference") end
    local rtn = {}
    stk[t] = true
    for k, v in pairs(t) do
      rtn[#rtn + 1] = "[" .. serialize(k, stk) .. "]=" .. serialize(v, stk)
    end
    stk[t] = nil
    return "{" .. table.concat(rtn, ",") .. "}"
  end
}
setmetatable(serialize_map, {
  __index = function(_, k) error("unsupported serialize type: " .. k) end
})
serialize = function(x, stk)
  return serialize_map[type(x)](x, stk)
end
function Serializer:Serialize(x)
  if x == nil then return nil end
  return serialize(x)
end
function Serializer:Deserialize(str)
  if str == nil then return nil end
  return dostring("return " .. str)
end
return Serializer
]] }

-- ########## Core.libs ########## --


-- ########## Core.shared ##########

PackageData.dLNnyigy = {
    Namespace = "Core.shared.Logger",
    Name = "Logger",
    FullName = "Logger.lua",
    IsRunable = true,
    Data = [[
local Logger = {}
Logger.__index = Logger
local mainLogFilePath = filesystem.path("log", "Log.txt")
function Logger.tableToLineTree(node, padding, maxLevel, level, properties)
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
        local childLines = Logger.tableToLineTree(node[k], padding .. (i == #keys and '    ' or '│   '), maxLevel, level + 1,
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
  local lineTree = Logger.tableToLineTree(table, nil, maxLevel, nil, properties)
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
  local lineTree = Logger.tableToLineTree(table, nil, maxLevel, nil, properties)
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
  local lineTree = Logger.tableToLineTree(table, nil, maxLevel, nil, properties)
  for _, line in pairs(lineTree) do
    self:LogInfo(line)
  end
end
function Logger:LogWarning(message)
  if message == nil then return end
  self:Log("ERROR! " .. tostring(message), 3)
end
function Logger:LogTableWarning(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  local lineTree = Logger.tableToLineTree(table, nil, maxLevel, nil, properties)
  for _, line in pairs(lineTree) do
    self:LogError(line)
  end
end
function Logger:LogError(message)
  if message == nil then return end
  self:Log("ERROR! " .. tostring(message), 4)
end
function Logger:LogTableError(table, maxLevel, properties)
  if table == nil or type(table) ~= "table" then return end
  local lineTree = Logger.tableToLineTree(table, nil, maxLevel, nil, properties)
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
]] }


PackageData.EaxyWcDY = {
    Namespace = "Core.shared.ModuleLoader",
    Name = "ModuleLoader",
    FullName = "ModuleLoader.lua",
    IsRunable = true,
    Data = [[
local ModuleOld = {}
ModuleOld.__index = {}
function ModuleOld.new(info, data)
    return setmetatable({
        Info = info,
        Data = data
    }, ModuleOld)
end
local WaitingModuleOld = {}
WaitingModuleOld.__index = WaitingModuleOld
function WaitingModuleOld.new(awaitingModule, waiters)
    return setmetatable({
        AwaitingModule = awaitingModule,
        Waiters = waiters
    }, WaitingModuleOld)
end
ModuleLoader = {}
ModuleLoader.__index = ModuleLoader
function ModuleLoader.extractCallerInfo(path)
    local callerData = {
        FullName = filesystem.path(3, path),
        Path = path
    }
    return Utils.Entry.Parse(callerData)
end
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
        ModuleLoader.logger:LogDebug("Unable to find module: " .. file.Path)
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
    for i, moduleWaiters in pairs(ModuleLoader.waitingForLoad) do
        if string.gsub(moduleWaiters.AwaitingModule, "%.", "/") .. ".lua" == awaitingModule.Info.Path then
            for _, waitingModule in pairs(moduleWaiters.Waiters) do
                ModuleLoader.LoadModule(waitingModule)
            end
        end
        table.remove(ModuleLoader.waitingForLoad, i)
    end
end
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
function ModuleLoader.PreLoadModule(moduleToLoad)
    local lib = ModuleLoader.internalGetModule(moduleToLoad)
    if lib ~= nil then
        ModuleLoader.logger:LogTrace("pre loaded module: '" .. lib.Info.Name .. "'")
        return lib.Data
    end
    ModuleLoader.handleCouldNotLoadModule(moduleToLoad)
    error("unable to load module: '" .. moduleToLoad .. "'")
end
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
function require(moduleToLoad)
    if ModuleLoader.loadingPhase then
        return ModuleLoader.PreLoadModule(moduleToLoad)
    end
    return ModuleLoader.GetModule(moduleToLoad)
end
]] }


PackageData.fphJtVby = {
    Namespace = "Core.shared.Utils",
    Name = "Utils",
    FullName = "Utils.lua",
    IsRunable = true,
    Data = [[
Utils = {}
function Utils.Sleep(ms)
    if type(ms) ~= "number" then error("ms was not a number", 1) end
    local startTime = computer.millis()
    local endTime = startTime + ms
    while startTime <= endTime do startTime = computer.millis() end
end
function Utils.ExecuteFunction(func, object, ...)
    local thread = coroutine.create(func)
    if object == nil then
        return thread, coroutine.resume(thread, ...)
    else
        return thread, coroutine.resume(thread, object, ...)
    end
end
Utils.File = {}
function Utils.File.Write(path, mode, data)
    if data == nil then return end
    local file = filesystem.open(path, mode)
    file:write(data)
    file:close()
end
function Utils.File.Read(path)
    local file = filesystem.open(path, "r")
    local str = ""
    while true do
        local buf = file:read(256)
        if not buf then
            break
        end
        str = str .. buf
    end
    return str
end
Utils.Table = {}
function Utils.Table.Copy(table)
    local copy = {}
    for key, value in pairs(table) do copy[key] = value end
    return setmetatable(copy, getmetatable(table))
end
local Entry = {}
Entry.__index = Entry
function Entry.new(name, fullName, isFolder, ignoreDownload, ignoreLoad, path, childs)
    return setmetatable({
        Name = name or "",
        FullName = fullName or "",
        IsFolder = isFolder == nil or isFolder,
        IgnoreDownload = ignoreDownload == nil or ignoreDownload,
        IgnoreLoad = ignoreLoad == nil or ignoreLoad,
        Path = path or "/",
        Childs = childs or {}
    }, Entry)
end
function Entry.Parse(entry, parentEntry)
    parentEntry = parentEntry or Entry.new()
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
    entry.Name = entry.Name or entry.FullName or entry[1]
    entry.FullName = entry.FullName or entry.Name
    entry.IgnoreDownload = entry.IgnoreDownload or false
    entry.IgnoreLoad = entry.IgnoreLoad or false
    if entry.IsFolder then
        entry.Path = entry.Path or filesystem.path(parentEntry.Path, entry.FullName)
        local childs = {}
        for _, child in pairs(entry) do
            if type(child) == "table" then
                local childEntry, _ = Utils.Entry.Parse(child, entry)
                table.insert(childs, childEntry)
            end
        end
        return Entry.new(entry.Name, entry.FullName, entry.IsFolder, entry.IgnoreDownload, entry.IgnoreLoad,
            entry.Path, childs), true
    end
    local nameLength = entry.Name:len()
    if entry.Name:sub(nameLength - 3, nameLength) == ".lua" then
        entry.Name = entry.Name:sub(0, nameLength - 4)
    end
    nameLength = entry.FullName:len()
    if entry.FullName:sub(nameLength - 3, nameLength) ~= ".lua" then
        entry.FullName = entry.FullName .. ".lua"
    end
    entry.Path = entry.Path or filesystem.path(parentEntry.Path, entry.FullName)
    return Entry.new(entry.Name, entry.FullName, entry.IsFolder, entry.IgnoreDownload,
        entry.IgnoreLoad, entry.Path, entry.Childs), true
end
Utils.Entry = Entry
local ProgramInfo = {}
ProgramInfo.__index = ProgramInfo
function ProgramInfo.new(name, version)
    return setmetatable({
        Name = name,
        Version = version
    }, ProgramInfo)
end
function ProgramInfo:Compare(programInfo)
    if self.Name ~= programInfo.Name
        or self.Version ~= programInfo.Version then
        return false
    end
    return true
end
Utils.ProgramInfo = ProgramInfo
local Main = {}
Main.__index = Main
function Main.new(mainModule)
    local instance = setmetatable({
        SetupFilesTree = mainModule.SetupFilesTree,
        Configure = mainModule.Configure,
        Run = mainModule.Run
    }, Main)
    return instance
end
function Main:Configure()
    return "$%not found%$"
end
function Main:Run()
    return "$%not found%$"
end
Utils.Main = Main
]] }

-- ########## Core.shared ########## --

-- ########## Core ########## --

return PackageData
