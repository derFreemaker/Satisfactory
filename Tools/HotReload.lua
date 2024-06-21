local args = {...}

local WorkspaceFolder = args[1]

local file = io.open(WorkspaceFolder .. "/HotReload/latest", "r+")
if not file then
    error("unable to open file: " .. WorkspaceFolder .. "/HotReload/latest")
end

local num = tonumber(file:read("a"))
file:seek("set", 0)
file:write(tostring(num + 1))
file:close()
