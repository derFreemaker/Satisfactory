---
title: FIN.Computer.Api
date: "2023-12-06"
---

# FIN.Computer.Api

**Lua Lib:** `computer`

The Computer API provides a interface to the computer owns functionalities.

## computer.getMemory() -> usage: integer, capacity: integer

Returns the current memory usage

**Returns**

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| usage    | integer |             |
| capacity | integer |             |

## computer.getInstance() -> FIN.Components.ComputerCase_C

Returns the current computer case instance

**Returns**

| Name | Type                          | Description |
| ---- | ----------------------------- | ----------- |
|      | FIN.Components.ComputerCase_C |             |

## computer.reset()

Stops the current code execution immediately and queues the system to restart in the next tick.

## computer.stop()

Stops the current code execution.
Basically kills the PC runtime immediately.

## computer.panic(errorMsg: string)

Crashes the computer with the given error message.

**Params**

| Name     | Type   | Description                             |
| -------- | ------ | --------------------------------------- |
| errorMsg | string | The crash error message you want to use |

## computer.skip()

This function is mainly used to allow switching to a higher tick runtime state. Usually you use this when you want to make your code run faster when using functions that can run in asynchronous environment.

## computer.promote()

Does the same as computer.skip

## computer.demote()

Reverts effects of skip

## computer.isPromoted() -> isPromoted: boolean

Returns `true` if the tick state is to higher

**Returns**

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| isPromoted | boolean |             |

## computer.state() -> state: 0 / 1

If computer state is async probably after calling computer.skip.

**Returns**

| Name  | Type  | Description         |
| ----- | ----- | ------------------- |
| state | 0 / 1 | 0 = Sync, 1 = Async |

## computer.beep(pitch: number)

Lets the computer emit a simple beep sound with the given pitch.

**Params**

| Name  | Type   | Description                                   |
| ----- | ------ | --------------------------------------------- |
| pitch | number | The pitch of the beep sound you want to play. |

## computer.setEEPROM(code: string)

Sets the code of the current eeprom. Doesn’t cause a system reset.

**Params**

| Name | Type   | Description                                 |
| ---- | ------ | ------------------------------------------- |
| code | string | The code you want to place into the eeprom. |

## computer.getEEPROM() -> code: string

Returns the code the current eeprom contents.

**Returns**

| Name | Type   | Description            |
| ---- | ------ | ---------------------- |
| code | string | The code in the EEPROM |

## computer.time() -> time: number

Returns the number of game seconds passed since the save got created. A game day consists of 24 game hours, a game hour consists of 60 game minutes, a game minute consists of 60 game seconds.

**Returns**

| Name | Type   | Description                                                   |
| ---- | ------ | ------------------------------------------------------------- |
| time | number | The number of game seconds passed since the save got created. |

## computer.millis() -> milliseconds: integer

Returns the amount of milliseconds passed since the system started.

**Returns**

| Name         | Type    | Description                               |
| ------------ | ------- | ----------------------------------------- |
| milliseconds | integer | Amount of milliseconds since system start |

## computer.magicTime() -> Timestamp: integer, DateTimeStamp: string, DateTimeStamp: string

Returns some kind of strange/mysterious time data from a unknown place (the real life).

**Returns**

| Name          | Type    | Description                          |
| ------------- | ------- | ------------------------------------ |
| Timestamp     | integer | Unix Timestamp                       |
| DateTimeStamp | string  | Serverside Formatted Date-Time-Stamp |
| DateTimeStamp | string  | Date-Time-Stamp after ISO 8601       |

## computer.log(verbosity: FIN.Components.LogEntry.Verbosity, format: string, ...any)

**Params**

| Name      | Type                              | Description |
| --------- | --------------------------------- | ----------- |
| verbosity | FIN.Components.LogEntry.Verbosity |             |
| format    | string                            |             |
| ...       | any                               |             |

## computer.getPCIDevices(type: FIN.Class) -> TPCIDevice[]

This function allows you to get all installed PCI-Devices in a computer of a given type.
@generic TPCIDevice

**Params**

| Name | Type      | Description |
| ---- | --------- | ----------- |
| type | FIN.Class |             |

**Returns**

| Name | Type         | Description |
| ---- | ------------ | ----------- |
|      | TPCIDevice[] |             |

## computer.textNotification(text: string, playerName: string?)

Shows a text notification to the player. If player is `nil` to all players.

**Params**

| Name       | Type    | Description |
| ---------- | ------- | ----------- |
| text       | string  |             |
| playerName | string? |             |

## computer.attentionPing(position: Satisfactory.Components.Vector, playerName: string?)

Creates an attentionPing at the given position to the player. If player is `nil` to all players.

**Params**

| Name       | Type                           | Description |
| ---------- | ------------------------------ | ----------- |
| position   | Satisfactory.Components.Vector |             |
| playerName | string?                        |             |
