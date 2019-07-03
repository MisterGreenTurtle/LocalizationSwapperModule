# LocalizationSwapperModule
A module to help developers manage assets for different languages.

## Purpose
This module is designed to help developers manage assets that require special translation. It provides an an easy way to swap, remove, insert, or obtain a copy of an asset that contains the proper translation when it cannot be done by the default translator. 

## Installation and Usage
1. Download the files `LocalizationSwapper.lua` and `Database.rbxm`
2. Right click on StarterPlayerScripts and select `Insert from file...`
3. Change the file type to `Scripts (*rbxs *.lua *.txt)`
4. Select `LocalizationSwapper.lua` and click `Open`
5. Create a LocalScript to run the module functions in
6. Right click on ReplicatedStorage and select `Insert from file...`
7. Select `Database.rbxm` and click `Open`

To use this module, add the following to the LocalScript you created in step 5.
```lua
local LocaleModule = require([PATH TO MODULE]:WaitForChild("LocalizationSwapperModule"))
```
Then, call the functions as so
```lua
LocaleModule:SwapForCurrentLocale(primary, "replacement")
```

## Key Functions

### SetLocale()
Sets the current locale that the module will use.

Usage:
```lua
LocaleModule:LocalizationSwapper:SetLocale("en-us")
```

### SwapForCurrentLocale(primary, replacement)
Switches out `primary` with an asset that matches the string `replacement` from the proper locale folder in `rootAssetStorage`. `primary` is destroyed with this function.

Usage:
```lua
LocaleModule:SwapForCurrentLocale(game.Workspace.Part, "Part")
```

### RemoveForLocales(primary, localeTable)
Removes `primary` if the player's currently locale matches an element in `localeTable`

Usage:
```lua
LocaleModule:RemoveForLocales(game.Workspace.Part, {"en-us"})
```

### InsertForLocales(localeTable, asset, cframe, parent)
If the player's locale matches an element in `localeTable`, it will find an asset matching the string `asset` from the proper locale folder in `rootAssetStorage`. This asset will be cloned, placed at the CFrame `cframe`, and set as a child of `parent`.

Usage:
```lua
LocaleModule:InsertForLocales({"en-us"}, "Part", CFrame.new(Vector3.new(0,0,0)), game.Workspace)
```

### GetForCurrentLocale(asset)
This will return an asset named `asset` from the proper locale folder in `rootAssetStorage`, if it exists.

Usage:
```lua
LocaleModule:GetForCurrentLocale("Part")
```

Returns:
Part
