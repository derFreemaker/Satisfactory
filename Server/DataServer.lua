print("starting...");

--#region initialize

--#region Floopy Disk
local fs = filesystem

if fs.initFileSystem("/dev") == false then
    computer.panic("Cannot initialize /dev")
end

local disk_uuid = "88F8D19A43E9C554620135B3D8C11E33"

fs.mount("/dev/"..disk_uuid, "/")
--#endregion

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

local function Save()
    local content = "Production/"
    for _, Device in pairs(Production) do
        content = content..","..Device.name..":"..Device.ID
    end
    content = content..";"
    content = content.."Main/"
    for _, Device in pairs(Main) do
        content = content..","..Device.name..":"..Device.ID
    end
    content = content..";"
    content = content.."Power/"
    for _, Device in pairs(Power) do
        content = content..","..Device.name..":"..Device.ID
    end

    local file = filesystem.open("/Devices.Satis", "w")
    file:write(content)
    file:close()
end

local function RemoveDeviceWithName(tableObject, name)
    local num = 0;
    for _, D in pairs(tableObject) do
        if D.name == name then
            num = _;
            break;
        end
    end
    table.remove(tableObject, num);
end

local function RemoveDeviceWithID(tableObject, ID)
    local num = 0;
    for _, D in pairs(tableObject) do
        if D.ID == ID then
            num = _;
            break;
        end
    end
    table.remove(tableObject, num);
end

local function CreateDevice(table, tableName, name, ID, File)
    local result = "adding"
    for _, D in pairs(table) do
        if D.name == name then
            result = "exists"
        elseif D.ID == ID then
            RemoveDeviceWithID(table, name)
        end
    end

    if result == "adding" then
        local device = {
            name = name,
            ID = ID
        }

        table[#table+1] = device;
        
        print("created Device: "..name..": "..ID.." to "..tableName);
        result = "added";
    end    

    if File == false then
        local Port = 1111;
        if string.match(name, "Switch") then
            Port = 5647
        else
            Port = 4535
        end

        network:send(sender.ID, Port, result)
    end
end

local function GetDevice(table, name)
    for _, Device in pairs(table) do
        if Device.name == name then
            return Device;
        end
     end
end

local function GetDevices(table)
    local content = ""
    for _, Device in pairs(table) do
        content = content.."/"..Device.name.."+"..Device.ID
    end
    return content
end

local function Send(SenderName, deviceID, content, content2)
    local Port = 1111;
    if string.match(SenderName, "Server") then
        Port = 1874
    else
        Port = 4535
    end

    network.send(network, deviceID, Port, content, content2)
end

local function Load()
    local file = fs.open("/Devices.Satis")

    local str = ""
    while true do
        local buf = file:read(265)
        if not buf then
            break
        end
    str = str .. buf
    end

    file:close()

    local tables = Split(str, ";")
    for _, t in pairs(tables) do
        local table = Split(t, "/")
        if table[1] == "Production" then
            local Devices = Split(table[2], ",")
            local i = 0
            for _, value in pairs(Devices) do
                if i == 1 then
                    local Device = Split(value, ":")
                    CreateDevice(Production, "Production", Device[1], Device[2], true)
                else
                    i = 1
                end
            end
        elseif table[1] == "Main" then
            local Devices = Split(table[2], ",")
            local i = 0
            for _, value in pairs(Devices) do
                if i == 1 then
                    local Device = Split(value, ":")
                    CreateDevice(Main, "Main", Device[1], Device[2], true)
                else
                    i = 1
                end
            end
        elseif table[1] == "Power" then
            local Devices = Split(table[2], ",")
            local i = 0
            for _, value in pairs(Devices) do
                if i == 1 then
                    local Device = Split(value, ":")
                    CreateDevice(Power, "Power", Device[1], Device[2], true)
                else
                    i = 1
                end
            end
        end
    end
end

--#endregion

--#region Variables

Production = {};
Main = {};
Power = {};

Load()
--#endregion

--endregion

print("started");

while true do
    local S, D, s, p, Data = event.pull();

    Deserialize(Data);

    if action.device == "create" then
       local content = Split(data.option, "+");
       
        if content[3] == "None" then
            content[3] = sender.ID;
        end

        if content[1] == "Production" then
           CreateDevice(Production, "Production", content[2], content[3], false);
        end
    
        if content[1] == "Main" then
           CreateDevice(Main, "Main", content[2], content[3], false);
        end

        if content[1] == Power then
           CreateDevice(Power, "Power", content[2], content[3], false);
        end
    elseif action.device == "get" then
        local content = Split(data.option, "+");

        if content[1] == "Production" then
            local Device = GetDevice(Production, content[2])
            Send(sender.name, sender.ID, Device.ID, Device.name);
        end

        if content[1] == "Main" then
            local Device = GetDevice(Main, content[2])
            Send(sender.name, sender.ID, Device.ID, Device.name)
        end

        if content[1] == "Power" then
            local Device = GetDevice(Power, content[2])
            Send(sender.name, sender.ID, Device.ID, Device.name)
        end

        print("get Device: "..content[2])
    elseif action.device == "get all" then
        if data.option == "Production" then
            local Devices = GetDevices(Production)
            Send(sender.name, sender.ID, "table", Devices)
        end

        if data.option == "Main" then
            local Devices = GetDevices(Main)
            Send(sender.name, sender.ID, "table", Devices)
        end

        if data.option == "Power" then
            local Devices = GetDevices(Power)
            Send(sender.name, sender.ID, "table", Devices)
        end
    end
    Save()
end