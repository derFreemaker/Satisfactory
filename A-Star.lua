AStar = {}
AStar.__index = AStar

-- Define a function to check if an array contains a given element
local function arrayContains(array, element)
    for _, value in ipairs(array) do
        if value == element then
            return true
        end
    end
    return false
end

local function heuristic(node1, node2)
    -- Calculate the Euclidean distance between the nodes
    local dx = node1.x - node2.x
    local dy = node1.y - node2.y
    local dz = node1.z - node2.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

-- Define the function that will perform the A* search
function AStar:Astar3D(start, goal, neighbors)
    -- Create a table to store the open and closed sets
    local openSet = {}
    local closedSet = {}
      
    -- Add the start node to the open set
    table.insert(openSet, start)
      
    -- Set the g-score (distance from start) and f-score (estimated total distance) for the start node
    start.gScore = 0
    start.fScore = heuristic(start, goal)
      
    -- Loop until the open set is empty
    while #openSet > 0 do
        -- Find the node with the lowest f-score in the open set
        local current = openSet[1]
        for i, node in ipairs(openSet) do
            if node.fScore < current.fScore then
                current = node
            end
        end
      
        -- If the current node is the goal, we have found the shortest path
        if current == goal then
            -- Return the path from the start to the goal
            local path = {}
            local node = goal
            while node ~= start do
                table.insert(path, 1, node)
                node = node.parent
            end
            table.insert(path, 1, start)
            return path
        end
      
        -- Remove the current node from the open set and add it to the closed set
        for i, node in ipairs(openSet) do
            if node == current then
                table.remove(openSet, i)
                break
            end
        end
        table.insert(closedSet, current)

        -- Get the neighbors of the current node
        local neighbors = neighbors(current)

        -- For each neighbor:
        for _, neighbor in ipairs(neighbors) do
            -- Skip the neighbor if it is already in the closed set
            if not arrayContains(closedSet, neighbor) then
                -- Calculate the tentative g-score for the neighbor
                local tentativeGScore = current.gScore + heuristic(current, neighbor)

                -- If the neighbor is not in the open set, or the tentative g-score is better than its current g-score, update the neighbor's g-score and f-score
                if not arrayContains(openSet, neighbor) or tentativeGScore < neighbor.gScore then
                    neighbor.parent = current
                    neighbor.gScore = tentativeGScore
                    neighbor.fScore = neighbor.gScore + heuristic(neighbor, goal)
      
                    -- If the neighbor is not in the open set, add it to the open set
                    if not arrayContains(openSet, neighbor) then
                        table.insert(openSet, neighbor)
                    end
                end
            end
        end
    end
    -- If we reach here, it means we didn't find a path to the goal
    return nil
end

return AStar