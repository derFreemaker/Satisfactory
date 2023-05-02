local Table = {}

function Table.Copy(table)
    local copy = {}
    for key, value in pairs(table) do copy[key] = value end
    return setmetatable(copy, getmetatable(table))
end

return Table