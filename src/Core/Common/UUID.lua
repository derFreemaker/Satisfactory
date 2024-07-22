local math = math
local string = string

---@class Core.UUID : object, Core.Json.Serializable
---@field m_head number[]
---@field m_body number[]
---@field m_tail number[]
---@field m_str string
---@overload fun(head: number[] | string, body: number[] | nil, tail: number[] | nil) : Core.UUID
local UUID = {}

---@private
---@type integer
UUID.Static__GeneratedCount = 0

---@private
---@type string
UUID.Static__Template = "xxxx-xxxx-xxxxxxxx"
local UUID_HEAD_COUNT = 4
local UUID_BODY_COUNT = 4
local UUID_TAIL_COUNT = 8

local function generateRandomChars(amount)
    ---@type number[]
    local chars = {}

    for i = 1, amount, 1 do
        local j = math.random(0, 61)

        if j <= 9 then
            chars[i] = j + 48
        elseif j <= 35 then
            chars[i] = j + 55
        else
            chars[i] = j + 61
        end

        if chars[i] < string.byte("0") then
            error("lol1")
        end
        if chars[i] > string.byte("9") and chars[i] < string.byte("A") then
            error("lol2")
        end
        if chars[i] > string.byte("Z") and chars[i] < string.byte("a") then
            error("lol3")
        end
        if chars[i] > string.byte("z") then
            error("lol4")
        end
    end
    return chars
end

---@return Core.UUID
function UUID.Static__New()
    math.randomseed(math.floor(computer.time()) + UUID.Static__GeneratedCount)
    local head = generateRandomChars(UUID_HEAD_COUNT)
    local body = generateRandomChars(UUID_BODY_COUNT)
    local tail = generateRandomChars(UUID_TAIL_COUNT)
    UUID.Static__GeneratedCount = UUID.Static__GeneratedCount + 1
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
    if not str:find(UUID.Static__Template:gsub("x", "."), 0) then
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
    if self.m_str then
        return self.m_str
    end

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

    self:Raw__ModifyBehavior(function(modify)
        modify.CustomIndexing = false
    end)

    self.m_str = str

    self:Raw__ModifyBehavior(function(modify)
        modify.CustomIndexing = true
    end)

    return str
end

---@private
function UUID:__newindex()
    error("Core.UUID is completely read only", 3)
end

---@private
---@param other any
function UUID:__eq(other)
    do
        local selfType = typeof(self)
        local otherType = typeof(other)
        if not selfType or selfType.Name ~= "Core.UUID"
            or not otherType or otherType.Name ~= "Core.UUID" then
            return false
        end
    end

    return self:Equals(other)
end

---@private
UUID.__tostring = UUID.ToString

-------------------------
-- Core.Json.Serializable
-------------------------

function UUID:Serialize()
    return self:ToString()
end

class("Core.UUID", UUID, { Inherit = require("Core.Json.Serializable") })

local empty = {}
local splittedTemplate = Utils.String.Split(UUID.Static__Template, "-")
for index, splittedTemplatePart in pairs(splittedTemplate) do
    empty[index] = {}
    for _ in string.gmatch(splittedTemplatePart, "x") do
        table.insert(empty[index], 48)
    end
end

UUID.Static__Empty = UUID(table.unpack(empty))

return UUID
