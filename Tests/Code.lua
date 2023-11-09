local _, logger = require('Tests.Simulator.Simulator'):Initialize(1)

local UUID = require("Core.Common.UUID")

local test = UUID.Static__New()

log(UUID)

print("## END ##")
