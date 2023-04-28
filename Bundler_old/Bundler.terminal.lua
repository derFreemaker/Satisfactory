bundlerFilesystem = require("FileSystem.BundlerFileSystem")
local Config = require("BundlerConfig")


---@param node table
---@param padding string | nil
---@param maxLevel number | nil
---@param level number | nil
---@param properties string[] | nil
---@return string[]
local function tableToLineTree(node, padding, maxLevel, level, properties)
    padding = padding or '     '
    maxLevel = maxLevel or 5
    level = level or 1
    local lines = {}

    if type(node) == 'table' then
        local keys = {}
        if type(properties) == 'string' then
            local propSet = {}
            for p in string.gmatch(properties, "%b{}") do
                local propName = string.sub(p, 2, -2)
                for k in string.gmatch(propName, "[^,%s]+") do
                    propSet[k] = true
                end
            end
            for k in pairs(node) do
                if propSet[k] then
                    keys[#keys + 1] = k
                end
            end
        else
            for k in pairs(node) do
                if not properties or properties[k] then
                    keys[#keys + 1] = k
                end
            end
        end
        table.sort(keys)

        for i, k in ipairs(keys) do
            local line = ''
            if i == #keys then
                line = padding .. '└── ' .. tostring(k)
            else
                line = padding .. '├── ' .. tostring(k)
            end
            table.insert(lines, line)

            if level < maxLevel then
                ---@cast properties string[]
                local childLines = tableToLineTree(node[k], padding .. (i == #keys and '    ' or '│   '),
                    maxLevel, level + 1,
                    properties)
                for _, l in ipairs(childLines) do
                    table.insert(lines, l)
                end
            elseif i == #keys then
                table.insert(lines, padding .. '└── ...')
            end
        end
    else
        table.insert(lines, padding .. tostring(node))
    end

    return lines
end


local function main(args)
    args[1] = "-p--E:\\Coding\\Lua\\Satisfactory\\Example"

    local config = Config.new(args)
    local bundler = require("Bundler").new(config:Build())
    bundler:Build()
    --TODO: Bundle Data

    local lines = tableToLineTree(bundler.RootBundlePart)
    for _, line in ipairs(lines) do
        print(line)
    end
end

main(arg)