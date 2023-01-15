local Test = {}

filesystem.doFile("AdjacencyMatrix.lua")
filesystem.doFile("Serializer.lua")

function Test:run(size, debug, aux_screen)

    local NetworkCard = computer.getPCIDevices(findClass("NetworkCard"))[1]

    local panel = component.proxy(component.findComponent("HyperTubeNetworkControlPanel")[1])
    local reset_button = panel:getModule(0,0)

    local hyper_network = AdjacencyMatrix(size, debug);
    local hyper_network_vertex_name = {};
    local hyper_network_name_vertex = {};
    local hyper_network_dest_vertices = {};
    local current_entrance = 1;

    NetworkCard:open(15060)
    event.listen(NetworkCard)
    event.listen(reset_button)
    event.clear();

    while true do
        local s, name, _, _, Data = event.pull();

        local data = Serializer:deserialize(Data);

        if data.mode == "connect" then
            if data.vertex > hyper_network.size then
                hyper_network:add_vertex()
                hyper_network:add_vertex()
            end
            for i=1, #data.connections do
                hyper_network:connect(data.vertex, data.connections[i])
                print("Connecting: "..data.vertex.." to "..data.connections[i])
            end

        elseif data.mode == "assign_location" then
            hyper_network:assign_location(data.vertex, data.location.x, data.location.y, data.location.z)
            print("Assigning Location: "..data.vertex.."with x: "..data.location.x.." y: "..data.location.y.." z: "..data.location.z)

        elseif data.mode == "assign_name" then
            hyper_network_vertex_name[data.vertex] = data.name
            if aux_screen then
                hyper_network_name_vertex[data.name] = data.vertex
                NetworkCard:send(s, 15061, Serializer:serialize({mode = "auxiliary", name = data.name}))
            end

            hyper_network_dest_vertices[#hyper_network_dest_vertices + 1] = data.vertex
            print("Assigning Name: "..data.vertex.." with "..data.name)

        elseif name == reset_button then
            hyper_network = AdjacencyMatrix(10, debug)
            hyper_network_vertex_name = {}
            hyper_network_dest_vertices = {}
            current_entrance = 0
            NetworkCard:broadcast(15061, Serializer:serialize({mode = "reset"}))
            print("resetting Network")

        elseif data.mode == "generate_path" then
            local origin = data.current_destination
            local destination = hyper_network_name_vertex[data.target_destination]

            if aux_screen then
                destination = hyper_network_name_vertex[data.target_destination]
            end

            print("Generating Path: "..origin.." to "..destination)

            local Path = {
                path = hyper_network:generate_path(origin, destination),
                string = ""
            }
            
            if #Path.path ~= 0 then
                Path.string = Path.path[1]
                for i=2,#Path.path do
                    Path.string = Path.string..","..Path.path[i]
                end
            else
                Path.string = "Failed"
            end

            print("Path: "..Path.string)
            NetworkCard:send(s, 15061, Serializer:serialize({mode = "new_path", path_string = Path.string}))

        elseif data.mode == "main" and (data.button_direction == "button_left" or data.button_direction == "button_right") then
            if data.button_direction == "button_left" then
                current_entrance = current_entrance - 1
                if current_entrance < 1 then
                    current_entrance = #hyper_network_dest_vertices
                end
            else
                current_entrance = current_entrance + 1
                if current_entrance > #hyper_network_dest_vertices then
                    current_entrance = 1
                end
            end
            print("Cycling Destination: "..hyper_network_vertex_name[hyper_network_dest_vertices[current_entrance]])

            NetworkCard:send(s, 15061, Serializer:serialize({mode = "auxiliary", hyper_network_vertex_name[hyper_network_dest_vertices[current_entrance]]}))
        end
    end
end