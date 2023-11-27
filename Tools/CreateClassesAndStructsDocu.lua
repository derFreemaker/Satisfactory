local FileSystem = require("Tools.FileSystem")

local args = { ... }

if #args < 1 then
    error("not all args given")
end

local WorkspaceFolder = args[1]

local ApiDocumentations = FileSystem.Path(WorkspaceFolder, "/API Documentations")

---@param path string
---@param childs string[]
local function scanDir(path, childs)
    local childsFound = FileSystem.GetFiles(path)
    for _, child in pairs(childsFound) do
        if child:find(".lua") then
            child = child:gsub(".lua", "")
            table.insert(childs, child)
        end
    end

    local childDirs = FileSystem.GetDirectories(path)
    for _, childDir in pairs(childDirs) do
        scanDir(FileSystem.Path(path, childDir), childs)
    end
end

---@param path string
------@return string[]
local function documentClasses(path)
    path = FileSystem.Path(path, "/Classes")

    local classes = {}
    scanDir(path, classes)
    return classes
end

---@param path string
---@return string[]
local function documentStructs(path)
    path = FileSystem.Path(path, "/Structs")

    local structs = {}
    scanDir(path, structs)
    return structs
end

local function documentSatisfactory(classes, structs)
    local path = FileSystem.Path(ApiDocumentations, "/Satisfactory/Components")
    return documentClasses(path), documentStructs(path)
end

local function documentFicsItNetworks(classes, structs)
    local path = FileSystem.Path(ApiDocumentations, "/FicsIt-Networks/Components")
    return documentClasses(path), documentStructs(path)
end

local satisfactoryClasses, satisfactoryStructs = documentSatisfactory()
local ficsItNetworksClasses, ficsItNetworksStructs = documentFicsItNetworks()

local file = FileSystem.OpenFile(FileSystem.Path(ApiDocumentations, "/FicsIt-Networks/classes&structs.lua"), "w")
file:write("---@meta\n\n")
file:write("---@class classes\n")

for _, class in pairs(satisfactoryClasses) do
    file:write("---@field " .. class .. " Satisfactory.Components." .. class .. "\n")
end

for _, class in pairs(ficsItNetworksClasses) do
    file:write("---@field " .. class .. " FIN.Components." .. class .. "\n")
end

file:write("classes = {}\n")

file:write("\n---@class structs\n")

for _, class in pairs(satisfactoryStructs) do
    file:write("---@field " .. class .. " Satisfactory.Components." .. class .. "\n")
end

for _, class in pairs(ficsItNetworksStructs) do
    file:write("---@field " .. class .. " FIN.Components." .. class .. "\n")
end

file:write("structs = {}\n")

file:close()
