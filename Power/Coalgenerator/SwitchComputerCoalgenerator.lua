event.pull(2)

--#region initialize

--#region Network Card
local network = computer.getPCIDevices(findClass("NetworkCard"))[1]
network.open(network, 5647)
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

local function Send()
    data.result = "switched"
    network.send(network, sender.ID, 4535, action.device, data.result, data.option)
end

local function Create()
    print("creating...")
    local Sender = {
        name = "SwitchComputer",
        ID = "None"
    }

    local Action = {
        server = "DataServer",
        device = "create",
        ID = ""
    }

    local Data = {
        option = "Power+SwitchCoalgenerator+ID",
        result = ""
    }

    network.send(network, "EAE21CA74C17FEFAB3EA578AB25EEA02", 1325, Serialize(Sender, Action, Data));
    print("created")
end

local function Switch(state)
    network.send(network, "ID", 8674, state);
end

--#endregion

--#endregion

local waterPumpSwitch = component.proxy("")

Create()

while true do
    local S, D, s, p, Data = event.pull()
    
    Deserialize(Data)

    print(data.option, "from", sender.name)

    if data.option == "false" then
        waterPumpSwitch.isSwitchOn = false
    elseif data.option == "true" then
        waterPumpSwitch.isSwitchOn = true
    elseif data.option == "restart" then
        computer.reset();
    end

    Send()
end