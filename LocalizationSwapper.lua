local LocalizationSwapper = {}

--[[
	This module is designed to help developers switch out assets that need special translation.
	It requires that the developer have a storage setup in ReplicatedStorage, which contains the translated assets.
	These directories must be named after the LocaleId.
--]]

local ASSET_FOLDER = "Localization Assets"
local SEARCH_RECURSIVELY = true
local DEFAULT_FALLBACK = "default"
local DEFAULT_LOCALE = "en-us"

local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

local currentLocale = DEFAULT_LOCALE

-- Check if not running on client (different from IsServer() in some situations)
if not game:GetService("RunService"):IsClient() then
	error("LocalizationSwapper should not be used on the server", 2)
end

-- Location of all the locale directories
local rootAssetStorage = ReplicatedStorage:FindFirstChild(ASSET_FOLDER, SEARCH_RECURSIVELY)
if not rootAssetStorage then
	-- Cannot continue if folder not found
	error("Could not find descendant '" .. ASSET_FOLDER .. "' to use for asset swapping!", 2)
end

-- Default directory that could contain objects without translations
-- Defaults to this directory if a missing locale is selected
local defaultFallback = rootAssetStorage:FindFirstChild(DEFAULT_FALLBACK)
if not defaultFallback then
	warn("Default directory not found, creating empty one and continuing")
	defaultFallback = Instance.new("Folder")
	defaultFallback.Name = DEFAULT_FALLBACK
	defaultFallback.Parent = rootAssetStorage
end

-- Used to set the module's locale for debugging
-- Can be used to manually set the locale
function LocalizationSwapper:SetLocale(locale)
	if typeof(locale) ~= "string" then
		error("bad argument #1 to 'SetLocale' (string expected, got " .. typeof(locale) .. ")", 2)	
	end
	
	currentLocale = locale
end

-- This function switches out the object with a replacement, referenced by name
-- The replacement should be stored under under the correct locale in storage
function LocalizationSwapper:SwapForCurrentLocale(object, assetName)
	if typeof(object) ~= "Instance" then
		error("bad argument #1 to 'SwapForCurrentLocale' (Instance expected, got " .. typeof(object) .. ")", 2)
	elseif typeof(assetName) ~= "string" then
		error("bad argument #2 to 'SwapForCurrentLocale' (string expected, got " .. typeof(assetName) .. ")", 2)
	end
	
	-- Attempt finding asset to swap with
	local localeDir = rootAssetStorage:FindFirstChild(currentLocale) or defaultFallback
	local asset = localeDir:FindFirstChild(assetName)
	
	if asset then
		-- Replace object
		local replacement = asset:Clone()

		-- Find cframe from object if applicable
		local cframe
		if object:IsA("Model") and object.PrimaryPart then
			cframe = object:GetPrimaryPartCFrame()
		elseif object:IsA("BasePart") then
			cframe = object.CFrame
		end

		-- Apply cframe to replacement if applicable
		if cframe then
			if replacement:IsA("Model") and replacement.PrimaryPart then
				replacement:SetPrimaryPartCFrame(cframe)
			elseif replacement:IsA("BasePart") then
				replacement.CFrame = cframe
			end
		end

		-- Copy over other common properties
		replacement.Name = object.Name
		replacement.Parent = object.Parent
		
		object:Destroy()
		return replacement
	end
	
	-- unchanged
	return object
end

-- This function creates a copy of an asset by name, for the current locale
-- If no such asset exists for the locale, it will give back a copy of the default locale of that asset instead
-- If no default exists either, the function will throw
function LocalizationSwapper:GetForCurrentLocale(assetName)
	if typeof(assetName) ~= "string" then
		error("bad argument #1 to 'GetForCurrentLocale' (string expected, got " .. typeof(assetName) .. ")", 2)
	end
	
	-- Validate directory and find asset
	local localeDir = rootAssetStorage:FindFirstChild(currentLocale)
	if localeDir then
		local asset = localeDir:FindFirstChild(assetName)
		if asset then
			return asset:Clone()	
		end
	end
	
	-- Not found for locale, try default
	local asset = defaultFallback:FindFirstChild(assetName)
	if asset then
		return asset:Clone()
	else
		error("No default asset set for '" .. assetName .. "' (reached for locale = '" .. currentLocale .. "')", 2)	
	end
end

-- This function removes object if the user is using a locale that matches an element from localeTable
function LocalizationSwapper:RemoveForLocales(localeTable, object)
	if typeof(localeTable) ~= "table" then
		error("bad argument #1 to 'RemoveForLocales' (table expected, got " .. typeof(localeTable) .. ")", 2)
	elseif typeof(object) ~= "Instance" then
		error("bad argument #2 to 'RemoveForLocales' (Instance expected, got " .. typeof(object) .. ")", 2)
	end
	
	-- Remove object if currentLocale is in provided localeTable
	for _, locale in pairs(localeTable) do
		if currentLocale == locale then
			object:Destroy()
			return true
		end
	end
	
	-- not removed
	return false
end

-- This function places an asset by reference in an optionally provided cframe/parent
-- Placement will only happen if the currentLocale matches an element from localeTable
function LocalizationSwapper:InsertForLocales(localeTable, assetName, parent, cframe)
	if typeof(localeTable) ~= "table" then
		error("bad argument #1 to 'InsertForLocales' (table expected, got " .. typeof(localeTable) .. ")", 2)
	elseif typeof(assetName) ~= "string" then
		error("bad argument #2 to 'InsertForLocales' (string expected, got " .. typeof(assetName) .. ")", 2)
	elseif parent ~= nil and typeof(parent) ~= "Instance" then
		error("bad argument #3 to 'InsertForLocales' (Instance expected, got " .. typeof(parent) .. ")", 2)
	elseif cframe ~= nil and typeof(cframe) ~= "CFrame" then
		error("bad argument #4 to 'InsertForLocales' (CFrame expected, got " .. typeof(cframe) .. ")", 2)
	end
	
	-- Check if currentLocale is in localeTable
	local found = false
	for _, locale in pairs(localeTable) do
		if currentLocale == locale then
			found = true
			break
		end
	end

	if not found then
		return -- Placement not needed for this locale
	end
	
	-- Validate directory and clone replacement
	local localeDir = rootAssetStorage:FindFirstChild(currentLocale) or defaultFallback
	local asset = localeDir:FindFirstChild(assetName)

	if asset then
		-- Place asset
		local copy = asset:Clone()
		
		-- CFrame is given, attempt applying it
		if cframe then
			if copy:IsA("Model") then
				if copy.PrimaryPart then
					copy:SetPrimaryPartCFrame(cframe)
				else
					warn("[LocalizationSwapper] Cannot apply CFrame to inserted copy of '" .. assetName .. "' because it has no PrimaryPart set")
				end
			elseif copy:IsA("BasePart") then
				copy.CFrame = cframe
			else
				warn("[LocalizationSwapper] Cannot apply CFrame to inserted copy of '" .. assetName .. "' because it is not a Model/Instance")
			end
		end

		-- Parent it, if provided
		copy.Parent = parent

		return copy
	else
		warn("[LocalizationSwapper] No asset with name '" .. asset .. "' exists for locale '" .. currentLocale .. "' to place down")
	end
end

do -- Set the initial locale of the player

	-- Get the translator that the player will be using
	local success, translator = pcall(function()
		return LocalizationService:GetTranslatorForPlayer(LocalPlayer)
	end)

	-- Sets the initial locale of the player if successful
	if success then
		LocalizationSwapper:SetLocale(translator.LocaleId)
	else
		warn("[LocalizationSwapper] Initializing locale for local player failed!")
	end

end

return LocalizationSwapper
