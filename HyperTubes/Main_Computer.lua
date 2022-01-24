--#region initialize

--#region Network Card
local network = computer.getPCIDevices(findClass("NetworkCard"))[1]
network.open(network, 7654)
event.listen(network)
--#endregion

--#region Tables

local Nodes = {}

--#endregion

--#endregion

local function Main()
    local S, D, s, p = event.pull()
end
