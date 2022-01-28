local Main_HyperTubeNetzwerkServer = {}

function Main_HyperTubeNetzwerkServer:run()

--#region initialize

--#region Tables

local Nodes = {}

--#endregion

--#region File System

local Serialize = filesystem.doFile("Serializer.lua")

local function Save()
  local data = Serialize:serialize(Nodes)
  local File = filesystem.open("/HyperTubesNodes.Satis", "w")
  File:write(data)
  File:close()
end

local function Load()
  local File = filesystem.open("/HyperTubesNodes.Satis", "r")
  local str = ""
    while true do
        local buf = File:read(265)
        if not buf then
            break
        end
    str = str .. buf
    end
  File:close()
  Nodes = Serialize:deserialize(str)
end

--#endregion

--#region Network Card
local network = computer.getPCIDevices(findClass("NetworkCard"))[1]
network.open(network, 7654)
event.listen(network)
--#endregion

--#region Functions

local function createMap()
 
end

--#endregion

--#endregion

local function Main()
  Load()
  while true do
    local S, D, s, p, Action, Data = event.pull()
    if Action == "create" then
      local node = Serialize:deserialize(Data)
      table.insert(Nodes, node)
    end

    Save()
  end
end

Main()

end

return Main_HyperTubeNetzwerkServer