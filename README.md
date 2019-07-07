# LocalizationSwapperModule
A module to help Roblox developers manage 3D and 2D assets that need to be localized for different languages.

## Purpose
This module is designed to help developers manage non-text assets in their games that require special translation, such as 3D text signs or symbols that should be presented differently in other locales. This cannot be done through the built-in LocalizationService / Translator API, since this only handles textual content, and therefore has to be done manually. This module simplifies the process by providing an easy way to insert, remove, and swap between versions of an asset for each locale. 

## Installation and Usage
1. Download the files `LocalizationSwapper.lua` and `Database.rbxm`
2. Use the `Insert from file...` context menu action in Studio to insert the `LocalizationSwapper.lua` file as a ModuleScript in some location in your game.
   - Change the file type to `Scripts (*rbxs *.lua *.txt)` to make it pop up in the file explorer)
3. Use the `Insert from file...` context menu action to insert Database.rbxm into ReplicatedStorage.

To use this module, you just need to require it:
```lua
local LocalizationSwapper = require([PATH TO MODULE])
```
Then simply use its API members like so:
```lua
LocalizationSwapper:SwapForCurrentLocale(primary, "NameOfAsset")
```

# Storing Assets for Localization
An example of how to store assets is given with the file Database.rbxm that you have inserted into ReplicatedStorage. It should look like this:

![](https://imgur.com/a/N17meWU)

The folder should be called "Localization Assets". You can then add children folders underneath that represent collections of assets for a particular locale. Locale folders can be added or removed as needed. The folders' names must match the locale name. Make sure to use lower-case version of locales with dashes as separators.

You do not need to provide alterations of assets for the "default" locale necessarily. If none are present, `primary` will simply remain unaffected when swapping. You do however need to set a default version of an asset when using some other API members of the module on this asset.

## Asset Requirements
1. Each asset must have a unique name, and that unique name must be shared for each locale version of the asset.
   - So if you have "ShopSign1" in en-us, its version in ch-zh should also be called "ShopSign1".
2. The asset must be a Model. (TODO)
3. The `PrimaryPart` of the Model must be set, so that it can be positioned in the right place when swapping.

## Adding new assets
To make an asset available to the module, it must be placed in a locale folder under "Localization Assets". This version of the asset will then be used if the current locale matches that locale.

## Adding new locales
1. Create a new Folder instance in the database
2. Set the name of the Folder to the locale name
3. Add localized assets as desired

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
