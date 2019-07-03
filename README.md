# LocalizationSwapperModule
A module to help developers manage assets for different languages.

## Purpose
This module is designed to help developers manage assets that require special translation. It provides an easy way to swap, remove, insert, or obtain a copy of an asset that contains the proper translation when it cannot be done by the default translator. 

## Installation and Usage
1. Download the files `LocalizationSwapper.lua` and `Database.rbxm`
2. Right click on StarterPlayerScripts and select `Insert from file...`
3. Change the file type to `Scripts (*rbxs *.lua *.txt)`
4. Select `LocalizationSwapper.lua` and click `Open`
5. Create a LocalScript to run the module functions in
6. Right click on ReplicatedStorage and select `Insert from file...`
7. Select `Database.rbxm` and click `Open`

To use this module, add the following to the LocalScript created in step 5.
```lua
local LocaleModule = require([PATH TO MODULE]:WaitForChild("LocalizationSwapperModule"))
```
Then, call the functions as so
```lua
LocaleModule:SwapForCurrentLocale(primary, "replacement")
```

# Custom Locales and Database Setup
The database for this module is strict with it's setup. The database must be setup as the following:

![alt text](https://i.imgur.com/Ovbkdsr.png)

Locale folders can be added or removed as needed. The folder's names must match the locale name.

For the default locale, replacement assets are not needed in the locale folder, since `primary` will remain unaffected.

## Asset Requirements
1. Each asset must have a unique name, but the name must be shared for each locale version of the asset
2. The asset must be a Model
3. The `PrimaryPart` of the asset must be set to a part that will be used as a CFrame reference. This `PrimaryPart` must be the same as `primary` if it is being used

## Adding new assets to the Database
In order to make an asset available to the module, it must be placed in the proper folder for the asset's locale. This asset will then be used if the `currentLocale` matches the player's locale.

## Adding new Locales
1. Create a new Folder instance in the database
2. Set the name of the Folder to the locale name
3. Add translated assets as desired

## Custom Locale Usage
Use `SetLocale()` to change the locale to a custom locale, then run the module's functions as needed.


# Key Functions
#### Example references:
Default Asset | Replacement Asset | Placement Asset | Database
------------ | ------------- | ------------- | ------------- 
<img src="https://i.imgur.com/pM5iNUE.png" height=200 width=200> | <img src="https://i.imgur.com/PVnzZVD.png" height=200 width=200> | <img src="https://i.imgur.com/KSXHLE7.png" height=200 width=200> | ![alt text](https://i.imgur.com/K7V6Zpp.png)

#### Example setup
No functions have been called. `Default Asset` is currently in Workspace.

<img src="https://i.imgur.com/pM5iNUE.png" height=250 width=250> 

## SwapForCurrentLocale(primary, replacement)
Switches out `primary` with an asset that matches the string `replacement` from the proper locale folder in `rootAssetStorage`. `primary` is destroyed with this function.

#### Usage:

`currentLocale = "de-de"`
```lua
LocaleModule:SwapForCurrentLocale(game.Workspace["Default Asset"], "Replacement Asset")
```
#### Results:

<img src="https://i.imgur.com/PVnzZVD.png" height=250 width=250>

## RemoveForLocales(localeTable, primary)
Removes `primary` if the player's currently locale matches an element in `localeTable`

#### Usage:

`currentLocale = "en-us"`
```lua
LocaleModule:RemoveForLocales({"en-us"}, game.Workspace["Default Asset"])
```
#### Results:

<img src="https://i.imgur.com/uk7suHx.png" height=250 width=250>

## InsertForLocales(localeTable, asset, cframe, parent)
If the player's locale matches an element in `localeTable`, it will find an asset matching the string `asset` from the proper locale folder in `rootAssetStorage`. This asset will be cloned, placed at the CFrame `cframe`, and set as a child of `parent`.

#### Usage:

`currentLocale = "de-de"`
```lua
LocaleModule:InsertForLocales({"de-de"}, "Placement Asset", CFrame.new(Vector3.new(0, 5, 0)), game.Workspace)
```
#### Results:

<img src="https://i.imgur.com/HGfjbN9.png" height=250 width=250>

## GetForCurrentLocale(asset)
This will return an asset named `asset` from the proper locale folder in `rootAssetStorage`, if it exists.

#### Usage:
`currentLocale = "de-de"`
```lua
LocaleModule:GetForCurrentLocale("Placement Asset")
```
#### Returns:
Placement Asset

## SetLocale()
Sets the current locale that the module will use.

#### Usage:
```lua
LocaleModule:LocalizationSwapper:SetLocale("en-us")
```
