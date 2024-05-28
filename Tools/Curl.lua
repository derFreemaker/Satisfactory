---@param ... any data
---@return Test.Curl.Future
local function newFuture(...)
    ---@class Test.Curl.Future
    local instance = { m_data = { ... } }

    function instance:await()
        return table.unpack(self.m_data)
    end

    function instance:canGet()
        return true
    end

    function instance:get()
        return table.unpack(self.m_data)
    end

    return instance
end

---@class Test.Curl : FIN.FINInternetCard
---@field location string
local Curl = {}

---@param folderPath string
function Curl:SetProgramLocation(folderPath)
    self.location = folderPath:gsub("/", "\\")
end

---@param url string
---@param method string
---@param data string
function Curl:request(url, method, data)
    if not self.location then
        return newFuture(400, "no locaiton set for curl.exe")
    end

    local command = self.location .. "\\bin\\curl.exe"
        .. " --url \"" .. url .. "\""
        .. " --request " .. method
        .. " --data \"" .. data .. "\""
        .. " --include --no-progress-meter"

    local file, msg = io.popen(command, "r")
    -- local success, exitCode, code = os.execute(command)
    if not file then
        return newFuture(400, "did not successfully execute curl command: " .. tostring(msg))
    end

    ---@type string
    local reqData = file:read("a")

    local headersEndPos = reqData:find("\n\n")
    if not headersEndPos then
        return newFuture(400, "Unable to find headers end pos")
    end

    local onlyHeaderData = reqData:sub(0, headersEndPos)
    local onlyResponseData = reqData:sub(headersEndPos + 2)

    local code = tonumber(onlyHeaderData:match("HTTP/%S+ (%S+) .*"))

    return newFuture(code, onlyResponseData)
end

return Curl
