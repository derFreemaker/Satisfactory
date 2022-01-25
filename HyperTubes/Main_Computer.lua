--#region initialize

--#region Network Card
local network = computer.getPCIDevices(findClass("NetworkCard"))[1]
network.open(network, 7654)
event.listen(network)
--#endregion

--#region Tables

local Nodes = {}

--#endregion

--#region Serialization

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

local function Serialize(x)
  return serialize(x)
end

local function Deserialize(str)
  return dostring("return " .. str)
end

--#endregion

--#endregion

local function Main()
    local S, D, s, p, Action, Data = event.pull()
    if Action == "create" then
        local node = Deserialize(Data)
        table.insert(Nodes, node)
    end

    
end

Main()