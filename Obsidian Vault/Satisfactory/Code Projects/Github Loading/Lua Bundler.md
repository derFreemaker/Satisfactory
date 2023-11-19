---
sticker: lucide//package-open
---
## Package Checks

- **Package_CircularReference** -> if two packages depend on each other
- **Package_Exists_MoreThanOnce** -> if two packages with the same Namespace exist
- **Require_Package_NotFound** -> if package in RequiredPackages does not exists
- **Using_Package_NotFound** -> if package does not exist used by **"---@using {packageNamespace}"**
- **Package_UnkownType** -> if package type is unknown

---
## Module Checks

- **Module_CircularReference** -> if two modules depend on each other
- **Module_Exists_MoreThanOnce** -> if two moduls with the same Namespace exist
- **Module_NotFound** -> if module was not found used by **"require("{moduleNamespace}")"**

---
## Class Checks

- **Class_Exists_MoreThanOnce** -> if the same class name is used two
