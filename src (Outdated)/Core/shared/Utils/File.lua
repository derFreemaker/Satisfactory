local File = {}

---@param path string
---@param mode string
---@param data string | nil
function File.Write(path, mode, data)
    if data == nil then return end
    local file = filesystem.open(path, mode)
    file:write(data)
    file:close()
end

---@param path string
---@return string
function File.Read(path)
    local file = filesystem.open(path, "r")
    local str = ""
    while true do
        local buf = file:read(256)
        if not buf then
            break
        end
        str = str .. buf
    end
    return str
end

return File