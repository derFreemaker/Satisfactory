--#region initialize

--#region Network Card
local network = computer.getPCIDevices(findClass("NetworkCard"))[1]
network.open(network, 5647)
event.listen(network)
--#endregion

--#region Data
local sender = {
    name = "SendComputer",
    ID = "None"
}

local action = {
    server = "DataServer",
    device = "get",
    ID = ""
}

local data = {
    option = "Production+SwitchCopper",
    result = ""
}
--#endregion

--#region Serialize
local function Split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

local function inTabelSerialized(f)
    local table = Split(f, "/")
    print(table[1]..">"..table[2])
    local t = Split(table[2], ",")
    for _,d in pairs(t) do
        local content = Split(d, ":")
        if table[1] == "action" then
            if content[1] == "server" then
                action.server = content[2]
            end
            if content[1] == "device" then
                action.device = content[2]
            end
            if content[1] == "ID" then
                action.ID = content[2]
            end
        end
    
        if table[1] == "sender" then
            if content[1] == "name" then
                sender.name = content[2]
            end
            if content[1] == "ID" then
                sender.ID = content[2]
            end
        end

        if table[1] == "data" then
            if content[1] == "option" then
                data.option = content[2]
            end
            if content[1] == "result" then
                data.result = content[2]
            end
        end
    end
end

local function Deserialize(data)
    local tables = Split(data, ";")
    inTabelSerialized(tables[1])
    inTabelSerialized(tables[2])
    inTabelSerialized(tables[3])
end

local function Serialize(Sender, Action, Data)
    local d = ""
    d = d.."sender/".."name:"..Sender.name..",ID:"..Sender.ID..";"
    d = d.."action/".."server:"..Action.server..",device:"..Action.device..",ID:"..Action.ID..";"
    d = d.."data/".."option:"..Data.option..",result:"..Data.result
    return d
end
--#endregion

--#endregion

print("sending...")
network.send(network, "EAE21CA74C17FEFAB3EA578AB25EEA02", 1325, Serialize(sender, action,data))
print("sended")
local S, D, s, p, name, result = event.pull()
print(name, result)
if result == "working" then
    local S, D, s, p, name, result = event.pull()
    print(name, result)
elseif name == "table" then
    local Devices = Split(result, "/")
    local i = 0
    for _, D in pairs(Devices) do
        local Device = Split(D, "+")
        if i == 1 then
            print(Device[1]..": "..Device[2])
        else
            i = 1
        end
    end
end