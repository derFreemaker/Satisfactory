---
sticker: lucide//package-open
---
## Checks

- **Packages** in [RequiredPackages](https://github.com/derFreemaker/Satisfactory/blob/05084fcd3c762d58193abb0072917733042324c6/PackageTemplate/Info.package.json#L5) exist
- **Package Circle Reference** -> checks if two packages depend on each other
- **require({module})** -> checks if module exists after a bundle would happen

---
## Autocorrection

- adds missing package to [RequiredPackages](https://github.com/derFreemaker/Satisfactory/blob/05084fcd3c762d58193abb0072917733042324c6/PackageTemplate/Info.package.json#L5) of the package
- removes unused packages from [RequiredPackages](https://github.com/derFreemaker/Satisfactory/blob/05084fcd3c762d58193abb0072917733042324c6/PackageTemplate/Info.package.json#L5) of the package