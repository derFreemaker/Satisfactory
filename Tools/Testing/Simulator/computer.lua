---@param eeprom string
---@param curl Test.Curl
return function(eeprom, curl)
    computer = {}

    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.promote()
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.millis()
        return math.floor(os.clock())
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.time()
        return os.time()
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.magicTime()
        return os.time, os.date(), os.date()
    end

    ---@param errorMsg string
    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.panic(errorMsg)
        errorMsg = "[PANIC]: " .. errorMsg
        print(errorMsg)
        os.exit(-1)
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.stop()
        os.exit(0)
    end

    ---@param pitch number
    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.beep(pitch)
    end

    ---@param position Satisfactory.Components.Vector
    ---@param playerName string?
    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.attentionPing(position, playerName)
    end

    ---@return integer usage, integer capacity
    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.getMemory()
        return math.floor(collectgarbage("count")), 0
    end

    ---@return string
    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.getEEPROM()
        return eeprom
    end

    ---@param code string
    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.setEEPROM(code)
        eeprom = code
    end

    ---@generic TPCIDevice : FIN.PCIDevice
    ---@param type TPCIDevice
    ---@return TPCIDevice[]
    ---@diagnostic disable-next-line: duplicate-set-field
    function computer.getPCIDevices(type)
        if type == classes.InternetCard_C then
            return { curl }
        end

        return {}
    end
end
