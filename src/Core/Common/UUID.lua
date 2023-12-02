local math = math
local string = string

---@class Core.UUID : Core.Json.Serializable
---@field private m_head number[]
---@field private m_body number[]
---@field private m_tail number[]
---@overload fun(head: number[], body: number[], tail: number[]) : Core.UUID
local UUID = {}

---@type integer
UUID.Static__GeneratedCount = 1

UUID.Static__TemplateRegex = "......%-....%-........"

--- Replaces 'x' in template with random character.
---@param amount integer
---@return number[] char
local function generateRandomChars(amount)
    ---@type number[]
    local chars = {}
    for i = 1, amount, 1 do
        local j = math.random(1, 3)

        if j == 1 then
            chars[i] = math.random(48, 57)
        elseif j == 2 then
            chars[i] = math.random(65, 90)
        elseif j == 3 then
            chars[i] = math.random(97, 122)
        end
    end
    return chars
end

---@return Core.UUID
function UUID.Static__New()
    math.randomseed(math.floor(computer.time()) + UUID.Static__GeneratedCount)
    local head = generateRandomChars(6)
    local body = generateRandomChars(4)
    local tail = generateRandomChars(8)
    return UUID(head, body, tail)
end

---@type Core.UUID
UUID.Static__Empty = Utils.Class.Placeholder

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
---@param headOrString number[]
---@param body number[]
---@param tail number[]
function UUID:__init(headOrString, body, tail)
    if type(headOrString) == "string" then
        headOrString, body, tail = parse(headOrString)
    end

    self:Raw__ModifyBehavior({ DisableCustomIndexing = true })
    self.m_head = headOrString
    self.m_body = body
    self.m_tail = tail
    self:Raw__ModifyBehavior({ DisableCustomIndexing = false })
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

Utils.Class.CreateClass(UUID, 'Core.UUID', require("Core.Json.Serializable"))

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
