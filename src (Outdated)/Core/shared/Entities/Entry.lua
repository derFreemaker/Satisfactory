---@class Entry
---@field Name string
---@field FullName string
---@field IsFolder boolean
---@field IgnoreDownload boolean
---@field IgnoreLoad boolean
---@field Path string
---@field Childs Entry[]
local Entry = {}
Entry.__index = Entry

---@param name string | nil
---@param fullName string | nil
---@param isFolder boolean | nil
---@param ignoreDownload boolean | nil
---@param ignoreLoad boolean | nil
---@param path string | nil
---@param childs Entry[] | nil
---@return Entry
function Entry.new(name, fullName, isFolder, ignoreDownload, ignoreLoad, path, childs)
    return setmetatable({
        Name = name or "",
        FullName = fullName or "",
        IsFolder = isFolder == nil or isFolder,
        IgnoreDownload = ignoreDownload == nil or ignoreDownload,
        IgnoreLoad = ignoreLoad == nil or ignoreLoad,
        Path = path or "/",
        Childs = childs or {}
    }, Entry)
end

---@param entry table
---@param parentEntry Entry | nil
---@return Entry | nil, boolean
function Entry.Parse(entry, parentEntry)
    parentEntry = parentEntry or Entry.new()

    if entry.IsFolder == nil then
        local childs = 0
        for _, child in pairs(entry) do
            if type(child) == "table" then
                childs = childs + 1
            end
        end
        if childs == 0 then
            entry.IsFolder = false
        else
            entry.IsFolder = true
        end
    end

    entry.Name = entry.Name or entry.FullName or entry[1]
    entry.FullName = entry.FullName or entry.Name
    entry.IgnoreDownload = entry.IgnoreDownload or false
    entry.IgnoreLoad = entry.IgnoreLoad or false

    if entry.IsFolder then
        entry.Path = entry.Path or filesystem.path(parentEntry.Path, entry.FullName)
        local childs = {}
        for _, child in pairs(entry) do
            if type(child) == "table" then
                local childEntry, _ = Entry.Parse(child, entry)
                table.insert(childs, childEntry)
            end
        end
        return Entry.new(entry.Name, entry.FullName, entry.IsFolder, entry.IgnoreDownload, entry.IgnoreLoad,
            entry.Path, childs), true
    end

    local nameLength = entry.Name:len()
    if entry.Name:sub(nameLength - 3, nameLength) == ".lua" then
        entry.Name = entry.Name:sub(0, nameLength - 4)
    end
    nameLength = entry.FullName:len()
    if entry.FullName:sub(nameLength - 3, nameLength) ~= ".lua" then
        entry.FullName = entry.FullName .. ".lua"
    end

    entry.Path = entry.Path or filesystem.path(parentEntry.Path, entry.FullName)

    return Entry.new(entry.Name, entry.FullName, entry.IsFolder, entry.IgnoreDownload,
        entry.IgnoreLoad, entry.Path, entry.Childs), true
end

return Entry