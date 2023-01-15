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

local s = Serialize(sender, action, data)
data.option = "Hello"
Deserialize(s)
print(data.option)