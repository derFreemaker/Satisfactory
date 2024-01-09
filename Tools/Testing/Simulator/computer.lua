---@param eeprom string
return function(eeprom)
    computer = {}

    ---@diagnostic disable-next-line
    function computer.promote()
    end

    ---@diagnostic disable-next-line
    function computer.millis()
        return math.floor(os.clock())
    end

    ---@diagnostic disable-next-line
    function computer.time()
        return os.time()
    end

    ---@diagnostic disable-next-line
    function computer.magicTime()
        return os.time, os.date(), os.date()
    end

    ---@diagnostic disable-next-line
    function computer.panic(errorMsg)
        os.exit(-1)
    end

    ---@diagnostic disable-next-line
    function computer.stop()
        os.exit(0)
    end

    ---@param pitch number
    ---@diagnostic disable-next-line
    function computer.beep(pitch)
    end

    ---@param position Satisfactory.Components.Vector
    ---@param playerName string?
    ---@diagnostic disable-next-line
    function computer.attentionPing(position, playerName)
    end

    ---@return integer usage, integer capacity
    ---@diagnostic disable-next-line
    function computer.getMemory()
        return math.floor(collectgarbage("count")), 0
    end

    ---@return string
    ---@diagnostic disable-next-line
    function computer.getEEPROM()
        return eeprom
    end

    ---@param code string
    ---@diagnostic disable-next-line
    function computer.setEEPROM(code)
        eeprom = code
    end
end
