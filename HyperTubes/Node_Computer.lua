--#region initialize

--#region Network Card
--local network = computer.getPCIDevices(findClass("NetworkCard"))[1]
--network.open(network, 5984)
--event.listen(network)
--#endregion

--#endregion

--#region Functions

local function createConnection(id, endPointNodeName)
    local connection = {
        ID = id,
        EndPointNodeName = endPointNodeName
    }
    return connection
end

local function createNode(name)
    local connections = {
        AluProduction = createConnection("1", "AluProduction"),
        Test = createConnection("2", "Test")
    }

    local node = {
        Name = name,
        Connections = connections
    }
    return node
end

--#endregion

local function Initialize()
    local node = createNode("CopperWireProduction")
end

Initialize()