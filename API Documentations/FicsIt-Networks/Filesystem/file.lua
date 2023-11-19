---@meta

-- //TODO: update documentation

---@class FIN.Filesystem.File
local File = {}

---@param data string
function File:write(data) end

---@param length integer
function File:read(length) end

---@param offset integer
function File:seek(offset) end

function File:close() end
