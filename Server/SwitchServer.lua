print("starting...")
--#region initialize

--#region Network Card
local network = computer.getPCIDevices(findClass("NetworkCard"))[1]
network.open(network, 1874)
event.listen(network)
--#endregion

--#region Templates
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

local function DataRequest(tableName, deviceName)
    local Sender = {
    name = "",
    ID = ""
    };

    local Action = {
        server = "",
        device = "",
        ID = ""
    };

    local Data = {
        option = "",
        result = ""
    };

    Sender.name = "SwitchServer";
    Sender.ID = "None";
    Action.device = "get";
    Action.server = "DataServer";
    Data.option = tableName.."+"..deviceName;

    network.send(network, "402BC1854D31D5AAC708E7B94FC04E65", "1465", Serialize(Sender, Action, Data), Sender.name, Action.server)
    local S, D, s, p, switchID = event.pull()
    return switchID
end

--#endregion

--#endregion

local function Send(deviceID)
    action.ID = deviceID
    data.result = "working"
    local deviceName = Split(action.device, "+")
    action.device = deviceName[2]
    network.send(network, "C5E11D73425FFC44DD3B5B954CDA7F9C", 1245, Serialize(sender, action, data))
end

print("started")
while true do
    local S, D, s, p, Data = event.pull()

    Deserialize(Data)

    local deviceContent = Split(action.device, "+")

    print(deviceContent[2], "option: >" .. data.option .. "<", "from", sender.name)

    local SwitchID = DataRequest(deviceContent[1], deviceContent[2]);

    Send(SwitchID);
end