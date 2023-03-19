Utils = {}

function Utils.Sleep(ms)
    if type(ms) ~= "number" then error("ms was not a number", 1) end
    local startTime = computer.millis()
    local endTime = startTime + ms
    while startTime <= endTime do startTime = computer.millis() end
end

function Utils.ExecuteFunction(func, object, ...)
    local thread = coroutine.create(func)
    if object == nil then
        return thread, coroutine.resume(thread, ...)
    else
        return thread, coroutine.resume(thread, object, ...)
    end
end

Utils.File = {}

function Utils.File.Write(path, mode, data)
    local file = filesystem.open(path, mode)
    file:write(data)
    file:close()
end

function Utils.File.Read(path)
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

Utils.Entry = {}

function Utils.Entry.Check(entry, parentPath)
    parentPath = parentPath or ""

    entry.Name = entry.Name or entry.FullName or entry[1]

    entry.FullName = entry.FullName or entry.Name

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

    entry.IgnoreDownload = entry.IgnoreDownload or false
    entry.IgnoreLoad = entry.IgnoreLoad or false

    if entry.IsFolder then
        entry.Path = entry.Path or filesystem.path(parentPath, entry.FullName)
        local childs = {}
        for _, child in pairs(entry) do
            if type(child) == "table" then
                table.insert(childs, Utils.CheckEntry(child, entry.Path))
            end
        end
        return {
            Name = entry.Name,
            FullName = entry.FullName,
            IsFolder = entry.IsFolder,
            IgnoreDownload = entry.IgnoreDownload,
            IgnoreLoad = entry.IgnoreLoad,
            Path = entry.Path,
            Childs = childs
        }
    end

    local nameLength = entry.Name:len()
    if entry.Name:sub(nameLength - 3, nameLength) == ".lua" then
        entry.Name = entry.Name:sub(0, nameLength - 4)
    end
    nameLength = entry.FullName:len()
    if entry.FullName:sub(nameLength - 3, nameLength) ~= ".lua" then
        entry.FullName = entry.FullName .. ".lua"
    end

    entry.Path = entry.Path or filesystem.path(parentPath, entry.FullName)

    return {
        Name = entry.Name,
        FullName = entry.FullName,
        IsFolder = entry.IsFolder,
        IgnoreDownload = entry.IgnoreDownload,
        IgnoreLoad = entry.IgnoreLoad,
        Path = entry.Path
    }
end