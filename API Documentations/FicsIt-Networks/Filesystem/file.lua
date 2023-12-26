---@meta

-- //TODO: update documentation

---@class FIN.Filesystem.File
local File = {}

---@param data string
function File:write(data) end

---@param length integer
function File:read(length) end

---@alias FIN.Filesystem.File.SeekMode
---|"set" # Base is beginning of the file.
---|"cur" # Base is current position.
---|"end" # Base is end of file.

---@param mode FIN.Filesystem.File.SeekMode
---@param offset integer
---@return integer offset
function File:seek(mode, offset) end

function File:close() end
