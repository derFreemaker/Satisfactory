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

local function Send(result)
    data.result = "Switches failed: "..result
    network:send("C5E11D73425FFC44DD3B5B954CDA7F9C", 1245, Serialize(sender, action, data))
end

local function DataRequest(tableName)
    local Sender = {
        name = "SenarioServer",
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
    local S, D, s, p, table, answer = event.pull()
    print("got Devices for Table:", tableName)
    return answer
end

local function switchSwitch(tableName, switchName, state)
    local Sender2 = {
        name = "SenarioServer",
        ID = "None"
    };

    local Action2 = {
        server = "SwitchServer",
        device = tableName.."+"..switchName,
        ID = ""
    };

    local Data2 = {
        option = state,
        result = ""
    };

    print(switchName.." switching".." ...")
    network:send("EAE21CA74C17FEFAB3EA578AB25EEA02", 1325, Serialize(Sender2, Action2, Data2))

    local S, D, s, p, name, result = event.pull()
    
    if result == "working" then
        local S, D, s, p, name, result = event.pull()
        if result == "switched" then
            print(name, result)
            return 0
        else
            print(name, "failed")
            return 1
        end
    else
        if result == "switched" then
            print(name, result)
            return 0
        else
            print(name, "failed2")
            return 1
        end
    end
end

--#endregion

--#endregion

print("started")

while true do
    local S, D, s, p, Data = event.pull()

    Deserialize(Data)

    print(sender.name..":", action.device, data.option)

    if action.device == "Productions" then
        local devicesSerialized = DataRequest("Production")

        local Devices = Split(devicesSerialized, "/")
        local i = 0
        Failed = 0;
        for _, D in pairs(Devices) do
            local Device = Split(D, "+")
            if i == 1 then
                Failed = Failed + switchSwitch("Production", Device[1], data.option)
            else
                i = 1
            end
        end
    else
        Send(Failed)
    end
end