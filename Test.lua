local ItemType = require("Ficsit-Networks_Sim.Component.Entities.Object.ItemType")

---@type Ficsit_Networks_Sim.Component.Entities.ItemType
local test = ItemType({ Message = "2" })

test.__onDeconstruct:On(function (self)
    print(self.Message)
    print(self:GetType())
end)

print("!END!")