local JsonConverter = require("Ficsit-Networks_Sim.Utils.JsonConverter")

---@alias Ficsit_Networks_Sim.Utils.CurlRequest.RequestMethod
---|"GET"
---|"POST"

---@class Ficsit_Networks_Sim.Utils.CurlRequest
---@field private command string
---@field private dataPath string
---@field Method string
---@field Url string
---@field OutputFilePath string | nil
---@field Data string | nil
local CurlRequest = {}
CurlRequest.__index = CurlRequest

---@param method Ficsit_Networks_Sim.Utils.CurlRequest.RequestMethod
---@param url string
---@param outputFilePath string | nil
---@param data any | nil
---@return Ficsit_Networks_Sim.Utils.CurlRequest
function CurlRequest.new(method, url, outputFilePath, data)
    if data then
        data = JsonConverter.encode(data)
    end
    ---@cast data string
    return setmetatable({
        command = nil,
        Method = method,
        Url = url,
        OutputFilePath = outputFilePath,
        Data = data
    }, CurlRequest)
end

---@param url string
---@param outputFilePath string
---@return Ficsit_Networks_Sim.Utils.CurlRequest
function CurlRequest.newGet(url, outputFilePath)
    return CurlRequest.new("GET", url, outputFilePath, nil)
end

---@param url string
---@param outputFilePath string
---@param data any | nil
---@return Ficsit_Networks_Sim.Utils.CurlRequest
function CurlRequest.newPost(url, outputFilePath, data)
    return CurlRequest.new("POST", url, outputFilePath, data)
end

---@private
---@param command string
---@return string
function CurlRequest:buildData(command)
    if not self.Data then
        return command
    end
    local path = os.tmpname()
    local dataFile = io.open(path, "w")
    if not dataFile then
        error("Unable to open file: '".. path .. "'", 3)
    end
    dataFile:write(self.Data)
    dataFile:close()
    command = command .. " -d  \"@" .. path .. "\""
    command = command .. " -H \"Content-Type: application/json\""
    return command
end

---@return Ficsit_Networks_Sim.Utils.CurlRequest
function CurlRequest:Build()
    local command = "curl -i -s -S -X ".. self.Method
    command = command .. " \"".. self.Url .."\""
    command = self:buildData(command)
    if self.OutputFilePath then
        command = command .. " -o \"" .. self.OutputFilePath .. "\""
    end
    self.command = command
    return self
end

---@return boolean
function CurlRequest:Send()
    if not self.command then
        error("have to build request first")
    end
    local success, exitcode, code = os.execute(self.command)
    return (success or false)
end

return CurlRequest