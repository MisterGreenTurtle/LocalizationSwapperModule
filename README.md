# LocalizationSwapperModule
A module to help Roblox developers manage the swapping / removing / inserting of non-text assets that need to be localized for different languages.

## Purpose
This module is designed to help developers manage non-text assets in their games that require special translation, such as 3D text signs or symbols that should be presented differently in other locales, or 2D decals or UI images that contain text. This cannot be done through the built-in LocalizationService / Translator API, since this only handles textual content, and therefore has to be done manually. This module simplifies the process by providing an easy way to insert, remove, and swap between versions of an asset for each locale.

## Installation and Usage
1. Download the files `LocalizationSwapper.lua` and `Database.rbxm`.
2. Use the `Insert from file...` context menu action in Studio to insert the `LocalizationSwapper.lua` file as a ModuleScript in some location in your game.
   - Change the file type to `Scripts (*rbxs *.lua *.txt)` to make it pop up in the file explorer)
3. Use the `Insert from file...` context menu action to insert `Database.rbxm` into game.ReplicatedStorage.

To use this module, you just need to require it:
```lua
local LocalizationSwapper = require([PATH TO MODULE])
```
Then simply use its API members like so:
```lua
LocalizationSwapper:SwapForCurrentLocale(primary, "NameOfAsset")
```

See a full list of functionality and API below.

# Storing Assets for Localization
An example of how to store assets is given with the file `Database.rbxm` that you have inserted into ReplicatedStorage. It should look like this:

![alt text](https://imgur.com/wdN2KpP.png)

The folder should be called ```"Localization Assets"```. You can then add children folders underneath that represent collections of assets for a particular locale. Locale folders can be added or removed as needed. The folders' names must match the locale name. Make sure to use lower-case version of locales with dashes as separators ("en-us", "fr-fr", and **not** "en-US" nor "en_us").

You do not need to provide alterations of assets for the "default" locale necessarily. If none are present, the asset will simply remain unaffected when using the swapping API (SwapForCurrentLocale). You do however need to set a default version of an asset when using some other API members of the module on this asset, such as GetForCurrentLocale.

## Asset Requirements
1. Each asset must have a unique name, and that unique name must be shared for each locale version of the asset.
   - So if you have "ShopSign1" in en-us, its version in ch-zh should also be called "ShopSign1".
2. The asset can be anything (BasePart, Model, Decal, ScreenGui) as long as it is an Instance.
   - If it is a BasePart or Model, the asset's CFrame will be carried over when swapping.
   - Name and Parent are always carried over regardless of Instance type when swapping.
   - If it is a Model, make sure to set PrimaryPart of the origin/destination model if you want the CFrame to carry over when swapping.

## Adding new assets
To make an asset available to the module, it must be placed in a locale folder under "Localization Assets". This version of the asset will then be used if the current locale matches that locale.

## Adding new locales
1. Create a new Folder instance in the database.
2. Set the name of the Folder to the locale name.
3. Add localized assets as children to the folder as desired.

# API Members
#### Example references:
Default Asset | Replacement Asset | Placement Asset | Database
------------ | ------------- | ------------- | ------------- 
<img src="https://i.imgur.com/pM5iNUE.png" height=200 width=200> | <img src="https://i.imgur.com/PVnzZVD.png" height=200 width=200> | <img src="https://i.imgur.com/KSXHLE7.png" height=200 width=200> | ![alt text](https://i.imgur.com/K7V6Zpp.png)

#### Example setup
No functions have been called. `Default Asset` is currently in Workspace.

<img src="https://i.imgur.com/pM5iNUE.png" height=250 width=250> 

## SwapForCurrentLocale(Instance object, string assetName)
Switches out `object` with an asset that matches the string `assetName` from the proper locale folder in ```"Localization Assets"```. `object` is destroyed with this function. If no suitable version can be found for the locale, `object` remains unaltered.

#### Usage:

`currentLocale = "de-de"`
```lua
local asset = LocaleModule:SwapForCurrentLocale(workspace["Default Asset"], "Replacement Asset Name")
print(asset:GetFullName() .. " is the result after swapping!")
```
#### Returns:
Returns the actually used asset (either a new cloned asset, or `object` if no changes could be made).

#### Results:

<img src="https://i.imgur.com/PVnzZVD.png" height=250 width=250>

## RemoveForLocales(localeTable, object)
Removes `object` if the player's currently locale matches an element in `localeTable`.

#### Usage:

`currentLocale = "en-us"`
```lua
local isRemoved = LocaleModule:RemoveForLocales({"en-us", "fr-fr"}, workspace["Default Asset"])
print("Was the asset removed? Answer: ", isRemoved) --> true
```
#### Returns:
Boolean value whether the asset was removed.
#### Results:

<img src="https://i.imgur.com/uk7suHx.png" height=250 width=250>

## InsertForLocales(localeTable, assetName, parent, cframe)
If the player's locale matches an element in `localeTable`, it will find an asset matching the string `assetName` from the proper locale folder in ```"Localization Assets"```. This asset will be cloned and returned.

Optionally, a `parent` argument may be provided to set the parent, and a `cframe` argument may be provided to set the CFrame of the asset in case it is a Model (with PrimaryPart set) or a BasePart.

#### Usage:

`currentLocale = "de-de"`
```lua
local asset = LocaleModule:InsertForLocales({"de-de"}, "Asset Name", game.Workspace, CFrame.new(Vector3.new(0, 5, 0)))
print(asset:GetFullName()) --> Workspace.Asset Name
```

#### Returns:
Copy of the asset for current locale, or nil if no appropriate asset was found.

#### Results:

<img src="https://i.imgur.com/HGfjbN9.png" height=250 width=250>

## GetForCurrentLocale(assetName)
This will return a copy of an asset named `assetName` from the proper locale folder in ```"Localization Assets"```. If no such asset exists and no default asset for that name exists either, the module will return nil.

#### Usage:
`currentLocale = "de-de"`
```lua
local copy = LocaleModule:GetForCurrentLocale("Placement Asset")
```
#### Returns:
Copy of the asset for current locale.
