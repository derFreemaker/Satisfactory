local filesystem = {}

---@param path string
---@return string
function filesystem.fixPath(path)
    if path == nil then
        return ""
    end

    path = path:gsub("\\\\", "/")
    path = path:gsub("\\", "/")

    return path
end

---@param path1 string
---@param path2 string
---@return string
function filesystem.combinePaths(path1, path2)
    if path1 == nil or path1 == "" then
        return path2 or ""
    end
    if path2 == nil or path2 == "" then
        return path1 or ""
    end

    path1 = filesystem.fixPath(path1)
    path2 = filesystem.fixPath(path2)

    if (path1:find("./$") or path1 == "/") and path2:find("^[^/].") then
        return path1 .. path2
    end
    if path1 == "/" and (path2:find("^/.") or path2 == "/") then
        return path2
    end

    if path1:find(".[^/]$") and (path2:find("^/.") or path2 == "/") then
        return path1 .. path2
    end
    if (path1:find("./$") or path1 == "/") and path2 == "/" then
        return path1
    end

    if path1:find(".[^/]$") and path2:find("^[^/].") then
        return path1 .. "/" .. path2
    end

    error("could not combine paths: '" .. path1 .. "' <-> '" .. path2 .. "'")
end



local GithubLoaderFiles = {
    "Github-Loading",
    {
        "shared",
        { "Entities.lua" },
        { "Logger.lua" },
        { "PackageLoader.lua" },
        { "Utils.lua" }
    },
    { "Options.lua" }
}

---@private
---@param fileName string
---@return string | nil
local function searchForFile(fileName, path)
    local funcs = {
        GithubLoaderBasePath = path
    }

    ---@param parentPath string
    ---@param entry table | string
    ---@param fileName string
    ---@return string | nil
    function funcs:doEntry(parentPath, entry, fileName)
        if #entry == 1 then
            ---@cast entry string
            return self:doFile(parentPath, entry, fileName)
        else
            ---@cast entry table
            return self:doFolder(parentPath, entry, fileName)
        end
    end

    ---@param parentPath string
    ---@param file string
    ---@param fileName string
    ---@return string | nil
    function funcs:doFile(parentPath, file, fileName)
        if file[1] ~= fileName then
            return nil
        end
        local path = filesystem.combinePaths(parentPath, file[1])
        return filesystem.combinePaths(self.GithubLoaderBasePath, path)
    end

    ---@param parentPath string
    ---@param folder table
    ---@param fileName string
    ---@return string | nil
    function funcs:doFolder(parentPath, folder, fileName)
        local path = filesystem.combinePaths(parentPath, folder[1])
        table.remove(folder, 1)
        for _, child in pairs(folder) do
            local success = self:doEntry(path, child, fileName)
            if success then
                return success
            end
        end
    end

    return funcs:doEntry("/", GithubLoaderFiles, fileName)
end

print(searchForFile("Utils.lua", "/"))