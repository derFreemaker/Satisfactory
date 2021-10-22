print("starting...")

--#region initialize

--#region Network Card
local network = computer.getPCIDevices(findClass("NetworkCard"))[1]
network.open(network, 1874)
event.listen(network)
--#endregion

--#region Variables

local sender = {
    name = "",
    ID = ""
}

local action = {
    server = "",
    device = "",
    ID = ""
}

local data = {
    option = "",
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

--#region Functions

local function Send(deviceID, Port, Data)
    network.send(network, deviceID, Port, Data, sender.name, action.server)
end

local function DataRequest(tableName)
    local Sender = {
        name = "SwitchServer",
        ID = "None"
    };

    local Action = {
        server = "DataServer",
        device = "get all",
        ID = ""
    };

    local Data = {
        option = tableName,
        result = ""
    };

    network.send(network, "402BC1854D31D5AAC708E7B94FC04E65", "1465", Serialize(Sender, Action, Data), Sender.name, Action.server)
    local S, D, s, p, answer = event.pull()
    return answer
end

local function switchSwitch(switchName, state)
    local Sender = {
        name = "SenarioServer",
        ID = "None"
    };

    local Action = {
        server = "SwitchServer",
        device = switchName,
        ID = ""
    };

    local Data = {
        option = state,
        result = ""
    };

    network.send(network, "EAE21CA74C17FEFAB3EA578AB25EEA02", 1325, Serialize(Sender, Action, Data))

    local S, D, s, p, name, result = event.pull()
    
    if result == "working" then
        local S, D, s, p, name, result = event.pull()
        if result == "switched" then
            print(name, result)
        else
            print(name, "failed")
        end
    else
        if result == "switched" then
            print(name, result)
        else
            print(name, "failed")
        end
    end
end

--#endregion

--#endregion

print("started")

while true do
    local S, D, s, p, Data = event.pull()

    Deserialize(Data)

    if action.device == "Productions" then
        local devicesSerialized = DataRequest("Production")
        local devices = Split(devicesSerialized, "/")
        for _, d in pairs(devices) do
            local device = Split(d, "+")
            switchSwitch(device[1], data.option)
        end
    end
end