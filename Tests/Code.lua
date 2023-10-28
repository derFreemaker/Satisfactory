-- require('Test.Simulator.Simulator'):Initialize(1)

local function foo()
    for i = 1, 10, 1 do
        if i == 5 then
            goto continue
        end

        print(i)

        ::continue::
    end
end

foo()
