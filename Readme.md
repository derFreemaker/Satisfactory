# Overview

This Repository contains all my code for the [FicsIt-Networks Mod](https://github.com/Panakotta00/FicsIt-Networks) for [Satisfactory](https://www.satisfactorygame.com).

## Supported Module Modifiers

- **---@namespace {moduleNamespace}** -> overrides the namespace of the module its in
- **---@isRunnable {true|false}** -> overrides the IsRunnable mark of the module its in
- **---@using {Package}** -> adds the package to the required Packges if not already in

## Push Pipeline

1. write source code
2. bundle the code with task: "bundle all" or "bundle all optimized" for smaller files
3. push the code to repo
4. can download in game (github has a 300sec raw data cache)

## Run Sequence Overview

[InGameLoader](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/GithubLoaderInGame.lua) starts executing...

1. loads [Loader](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/Loader.lua)

   - loads all files in [LoaderFiles](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/Loader/)
   - checks version in [VersionFile](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/Version.latest.txt)
   - loads [Options](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/00_Options.lua)
   - sets up [PackageLoader](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/Loader/100_PackageLoader.lua)

2. loads [Core Package](https://github.com/derFreemaker/Satisfactory/blob/main/src/Core)
3. loads selected [Option](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/GithubLoaderInGame.lua#L2)
4. runs the selected [Option](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/GithubLoaderInGame.lua#L2)

# Package System

## Package Structure

```ini
├── src
|   ├── Info.package.json -> marks the folder as package
│   ├── __main.lua -> has main functions
│   ├── __events.lua -> has event functions
|   └── **/*.lua -> will be marked as runnable from bundler
└── bundled Package
    ├── Data.lua -> all modules of the package
    └── Info.lua -> contains information about the package

```

## Package Info File

### [Template:](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/Info.package.json)

```json
{
    "Name": "PackageName",
    "Version": "0.1.0-0",
    "Namespace": "PackageNamespace",
    "RequiredPackages": [ "Package1", "Package2" ],
    "ApplicationType": "Library"
}

```

"Version": "[Version]-[BuildNumber]" the BuildNumber will be increased by one erverytime the bundler bundles this package.
The BuildNumber can only be an integer.

"ApplicationType": can be "Library" or "Application" at the moment.

## Package Load Sequence

1. download of the Package from [Packages](https://github.com/derFreemaker/Satisfactory/blob/main/Packages/)
2. running events in module [__events.lua](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__events.lua) of the Package
   - [OnLoaded](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__events.lua#L4) function gets executed if it exists

## Package Run Sequence

1. setting [Logger](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__main.lua#L2) of Package
2. running [Configure](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__main.lua#L5) function
3. running [Run](https://github.com/derFreemaker/Satisfactory/blob/main/PackageTemplate/__main.lua#L9) function

### More Information in the Obsidian Vault

Download: [Obsidian](https://obsidian.md)
