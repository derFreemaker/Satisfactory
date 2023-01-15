---
--- Created by Freemaker
--- DateTime: 15/01/2023s
---

Test = {}
Test.__index = Test

function Test:run(debug)
    print(debug)
end

return Test