---
sticker: lucide//loader
---
## Run Sequence
[InGameLoader](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/GithubLoaderInGame.lua) starts executing...

1. loads [Loader](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/Loader.lua)
	- loads all files in [LoaderFiles](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/Loader/)
	- checks version in [VersionFile](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/Version.latest.txt)
	- loads [Options](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/00_Options.lua)
	- sets up [PackageLoader](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/Loader/100_PackageLoader.lua)
2. loads [Core Package](https://github.com/derFreemaker/Satisfactory/blob/main/src/Core)
3. loads selected [Option](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/GithubLoaderInGame.lua#L2)
4. runs the selected [Option](https://github.com/derFreemaker/Satisfactory/blob/main/Github-Loading/GithubLoaderInGame.lua#L2)
