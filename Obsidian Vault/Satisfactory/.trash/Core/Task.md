---
tags:
  - Core
sticker: lucide//calendar
---
# Constructor
---
## Arguments:

|Name|Type|Description|
|----|----|----|
|func|function|The function that will be executed as Task.|
|passthrough|any|Something you want to pass through to the function as first parameter.|

# IsSuccess
---
## Return:

|Name|Type|Description|
|----|----|----|
|isSuccess|boolean|True if Task exited with no error.|

# GetResults
---
Returns all last returned values as the function returned them.
## Return:

|Name|Type|Description|
|---|---|---|
|...|any|All returned values from start function.|

# GetResultsArray
---
Returns all last returned values in an array.
## Return:

|Name|Type|Description|
|---|---|---|
|results|any[]|All returned values from start function.|

# GetTraceback
---
Returns the traceback from `debug.traceback`.
## Return:

|Name|Type|Description|
|---|---|---|
|traceback|string|The traceback formated as string from `debug.traceback`.|

# Execute
---
Executes the task with the given parameters
## Parameter:

|Name|Type|Description|
|---|---|---|
|...|any|The parameters the start function should receive after the passthrough if there is.|
## Return:

|Name|Type|Description|
|---|---|---|
|...|any|The returned values from start function or `coroutine.yield`.

# Resume
---
Resumes the thread that is used behind the scenes if `coroutine.yield` was called in the function.
### Parameter:

|Name|Type|Description|
|---|---|---|
|...|any|The parameters the start function should receive after the passthrough if there is.|
## Return:

|Name|Type|Description|
|---|---|---|
|...|any|The returned values from start function or `corotine.yield`.

# Close
---
Closes the thread that is used behind the scenes.

# State
---
Returns current state of the task.
## Return:

|Name|Type|Description|
|---|---|---|
|state|string| - `not created` If the thread behind the scenes was not created yet. <br> (no execution) <br> - `dead` If the task is closed. <br> - `normal` If the task is active but not running. <br> - `running` If the task is running. <br> - `suspended` If the task is suspended.|

# LogError
---
Logs error, if there is one, to provided logger.
## Parameter:

|Name|Type|Description|
|---|---|---|
|logger|Core.Logger?|The logger that is used when logging the error.|
