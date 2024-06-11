local math = math
local string = string

---@class Core.UUID : object, Core.Json.Serializable
---@field private m_head number[]
---@field private m_body number[]
---@field private m_tail number[]
---@overload fun(head: number[] | string, body: number[] | nil, tail: number[] | nil) : Core.UUID
local UUID = {}

---@private
---@type integer
UUID.Static__GeneratedCount = 0

---@private
---@type string
UUID.Static__TemplateRegex = "....%-....%-........"

---@param amount integer
---@return number[] char
local function generateRandomChars(amount)
    ---@type number[]
    local chars = {}

    for i = 1, amount, 1 do
        local j = math.random(0, 57)

        if j <= 7 then
            chars[i] = j + 48
        elseif j <= 32 then
            chars[i] = j + 65
        else
            chars[i] = j + 97
        end
    end
    return chars
end

---@return Core.UUID
function UUID.Static__New()
    math.randomseed(math.floor(computer.time()) + UUID.Static__GeneratedCount)
    local head = generateRandomChars(4)
    local body = generateRandomChars(4)
    local tail = generateRandomChars(8)
    return UUID(head, body, tail)
end

---@type Core.UUID
---@diagnostic disable-next-line: missing-fields
UUID.Static__Empty = {}

---@param str string
---@return integer[]
local function convertStringToCharArray(str)
    return { string.byte(str, 1, str:len()) }
end

---@return number[] head, number[] body, number[] tail
local function parse(str)
    local splittedStr = Utils.String.Split(str, "-")

    local head = convertStringToCharArray(splittedStr[1])
    local body = convertStringToCharArray(splittedStr[2])
    local tail = convertStringToCharArray(splittedStr[3])

    return head, body, tail
end

---@param str string
---@return Core.UUID?
function UUID.Static__Parse(str)
    if not str:find(UUID.Static__TemplateRegex) then
        return nil
    end

    return UUID(parse(str))
end

---@private
---@param headOrString number[] | string
---@param body number[] | nil
---@param tail number[] | nil
function UUID:__init(headOrString, body, tail)
    if type(headOrString) == "string" then
        headOrString, body, tail = parse(headOrString)
    end
    ---@cast body number[]
    ---@cast tail number[]

    self:Raw__ModifyBehavior(function(modify)
        modify.CustomIndexing = false
    end)

    self.m_head = headOrString
    self.m_body = body
    self.m_tail = tail

    self:Raw__ModifyBehavior(function(modify)
        modify.CustomIndexing = true
    end)
end

---@param other Core.UUID
---@return boolean isSame
function UUID:Equals(other)
    for i, char in ipairs(self.m_head) do
        if char ~= other.m_head[i] then
            return false
        end
    end

    for i, char in ipairs(self.m_body) do
        if char ~= other.m_body[i] then
            return false
        end
    end

    for i, char in ipairs(self.m_tail) do
        if char ~= other.m_tail[i] then
            return false
        end
    end

    return true
end

---@return string str
function UUID:ToString()
    local str = ""

    for _, char in ipairs(self.m_head) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.m_body) do
        str = str .. string.char(char)
    end

    str = str .. "-"

    for _, char in ipairs(self.m_tail) do
        str = str .. string.char(char)
    end

    return str
end

function UUID:Serialize()
    return self:ToString()
end

---@private
function UUID:__newindex()
    error("Core.UUID is completely read only", 3)
end

---@private
function UUID:__tostring()
    return self:ToString()
end

class("Core.UUID", UUID, { Inherit = require("Core.Json.Serializable") })

local empty = {}
local splittedTemplate = Utils.String.Split(UUID.Static__TemplateRegex, "%-")
for index, splittedTemplatePart in pairs(splittedTemplate) do
    empty[index] = {}
    for _ in string.gmatch(splittedTemplatePart, ".") do
        table.insert(empty[index], 48)
    end
end

UUID.Static__Empty = UUID(table.unpack(empty))

return UUID
