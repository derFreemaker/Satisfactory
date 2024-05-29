local EventPullAdapter = require("Core.Event.EventPullAdapter")

local Config = require("FactoryControl.Core.Config")

local Uri = require("Net.Core.Uri")
local HttpClient = require("Net.Http.Client")
local HttpRequest = require("Net.Http.Request")

---@class Test.Http.Main : Github_Loading.Entities.Main
---@field private m_httpClient Net.Http.Client
local Main = {}

function Main:Configure()
    EventPullAdapter:Initialize(self.Logger:subLogger("EventPullAdapter"))

    self.m_httpClient = HttpClient(self.Logger:subLogger("HttpClient"))
end

function Main:Run()
    log("running test")

    local request = HttpRequest("GET", Config.DOMAIN, Uri.Static__Parse("/Controller/GetWithName/Test"))
    local response = self.m_httpClient:Send(request)

    assert(response:GetStatusCode() == 404, "Expected 404, got " .. response:GetStatusCode())

    log("test passed")
end

return Main
