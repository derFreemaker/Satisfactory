---
--- Created by Freemaker
--- DateTime: 15/01/2023
---

Test = {}
Test.__index = Test

function Test:Run(debug)
    if debug == true then
        print("debug was activated")
    end
end

return Test