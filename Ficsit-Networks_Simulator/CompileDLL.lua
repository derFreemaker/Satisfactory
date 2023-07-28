local currentPath = io.popen("cd"):read("a"):gsub("/", "\\"):gsub("\n", "")
print("CurrentPath: '".. currentPath .."'\n")

local args = table.pack(...)

local foundfiles = {}

---@param file string
local function addFile(file)
    local len = file:len()
    local extPos = file:reverse():find("%.") - 1
    local ext = file:sub(len - extPos)
    if ext == ".cpp" or ext == ".h" then
        table.insert(foundfiles, file)
    end
end

---@param folder string
---@param parentFolder string
local function addFolder(folder, parentFolder)
    parentFolder = parentFolder or ""

    if folder:sub(0, 1) == "." and folder:len() > 1 then
        return
    end

    local files = io.popen("dir \"" .. parentFolder .. "\\" .. folder .. "\" /b /a:-D /o 2>NUL", "r")
    if not files then
        error("Unable to run 'dir' command with path: '" .. parentFolder .. "\\" .. folder .. "'")
    end
    for file in files:lines() do
        addFile(parentFolder .. [[\]] .. folder .. [[\]] .. file)
    end
    local directories = io.popen("dir \"" .. parentFolder .. "\\" .. folder .. "\" /b /a:D /o 2>NUL", "r")
    if not directories then
        error("Unable to run 'dir' command with path: '" .. parentFolder .. "\\" .. folder .. "'")
    end
    for directory in directories:lines() do
        addFolder(directory, parentFolder .. "\\" .. folder)
    end
end

addFolder("src", currentPath)

local command = "g++"

for _, file in ipairs(foundfiles) do
    command = command .. [[ "]] .. file .. [["]]
end

command = command .. " -shared"

command = command .. [[ -I"]] .. currentPath .. [[\include"]]
command = command .. [[ -L"]] .. currentPath .. [[\include" -llua]]

command = command .. " -o " .. (args[1] or "out.dll") .. ".dll"

print("compiling...\n" .. command .. "\n")
io.popen(command)