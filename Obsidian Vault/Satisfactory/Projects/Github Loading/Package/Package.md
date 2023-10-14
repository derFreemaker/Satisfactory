---
sticker: lucide//package
---
## Info

- Name
- Version
- Namespace
- RequiredPackages
- ApplicationType

---
## Data

- All Files in Package Folder as Modules

---
## Load Sequence

1. downloading Package from [Packages](https://github.com/derFreemaker/Satisfactory/blob/main/Packages/)
2. running events in module [events.lua](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__events.lua) of the Package
	- [OnLoaded](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__events.lua#L4) function gets executed if it exists

---
## Run Sequence

Only if Package has Type "Application"

1. getting module [__main.lua](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__main.lua) of the Package
2. setting [Logger](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__main.lua#L2) for main module instance
3. running [Configure](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__main.lua#L5) function
4. running [Run](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__main.lua#L9) function