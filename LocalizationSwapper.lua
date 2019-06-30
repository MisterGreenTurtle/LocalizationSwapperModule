local LocalizationSwapper = {}

--[[
	This module is designed to help developers switch out assets that need special translation
	It requires that the developer have a storage setup, rootAssetStorage, which contains the translated assets
	These directories must be named after the LocaleId
--]]

local ASSET_FOLDER = "Localization Assets"
local SEARCH_RECURSIVELY = true
local DEFAULT_FALLBACK = "default"

local LocalPlayer = game:GetService("Players").LocalPlayer
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local currentLocale = nil

-- Check if not running on client (different from IsServer() in some situations)
if not RunService:IsClient() then
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

-- Used to set the module's locale
-- This is so that the locale does not need to be checked multiple times
-- Can be used to manually set the locale
function LocalizationSwapper:SetLocale(locale)
	if typeof(locale) ~= "string" and locale ~= nil then
		error("bad argument #1 to 'SetLocale' (string or nil expected, got " .. typeof(locale) .. ")", 2)	
	end
	currentLocale = locale
end

-- This function switches out the primary with a replacement
-- Both the primary and the replacement need to have a PrimaryPart
-- The replacement should be stored under under the correct locale in rootAssetStorage
function LocalizationSwapper:SwapForCurrentLocale(primary, replacement)
	if typeof(primary) ~= "Instance" or not primary:IsA("Model") then
		error("bad argument #1 to 'SwapForCurrentLocale' (Model expected, got " .. typeof(primary) .. ")", 2)
	elseif not primary.PrimaryPart then
		error("bad argument #1 to 'SwapForCurrentLocale' (Model has no PrimaryPart set)", 2)
	elseif typeof(replacement) ~= "string" then
		error("bad argument #2 to 'SwapForCurrentLocale' (string expected, got " .. typeof(replacement) .. ")", 2)
	end
	
	if not currentLocale then
		return
	end
	
	-- Validate directory and clone replacement
	local localeDir = rootAssetStorage:FindFirstChild(currentLocale) or defaultFallback
	local primaryAsset = localeDir:FindFirstChild(replacement)
	
	if primaryAsset then -- Replace primary with the replacement
		local clone = primaryAsset:Clone()
		clone:SetPrimaryPartCFrame(primary.PrimaryPart.CFrame)
		clone.Parent = primary.Parent
		primary:Destroy()
	else
		warn("No asset with name '" .. replacement .. "' exists for locale '" .. currentLocale .. "' to do swapping with")
	end
end

-- This function removes primary if the user is using a locale that matches an element from localeTable
function LocalizationSwapper:RemoveForLocales(primary, localeTable)
	if typeof(primary) ~= "Instance" then
		error("bad agument #1 to 'RemoveForLocales' (Instance expected, got " .. typeof(primary) .. ")", 2)
	elseif typeof(localeTable) ~= "table" then
		error("bad argument #2 to 'RemoveForLocales' (table expected, got " .. typeof(localeTable) .. ")", 2)
	end

	if not currentLocale then
		return
	end
	
	-- Check if currentLocale is in localeTable
	for _, locale in pairs(localeTable) do
		if currentLocale == locale then
			primary:Destroy() -- Remove primary
			break
		end
	end
end

-- This function places primary as a child to parent at cframe
-- Placement will only happen if the currentLocale matches and element from localeTable
function LocalizationSwapper:PlaceForLocales(localeTable, asset, cframe, parent)
	if typeof(localeTable) ~= "table" then
		error("bad agument #1 to 'PlaceForLocales' (table expected, got " .. typeof(localeTable) .. ")", 2)
	elseif typeof(asset) ~= "string" then
		error("bad argument #2 to 'PlaceForLocales' (string expected, got " .. typeof(asset) .. ")", 2)
	elseif typeof(cframe) ~= "CFrame" then
		error("bad argument #3 to 'PlaceForLocales' (CFrame expected, got " .. typeof(cframe) .. ")", 2)
	elseif typeof(parent) ~= "Instance" then
		error("bad argument #4 to 'PlaceForLocales' (Instance expected, got " .. typeof(parent) .. ")", 2)
	end
	
	if not currentLocale then
		return
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
		return -- Placement not needed
	end
	
	-- Validate directory and clone replacement
	local localeDir = rootAssetStorage:FindFirstChild(currentLocale) or defaultFallback
	local primaryAsset = localeDir:FindFirstChild(asset)

	if primaryAsset then -- Place primary
		local clone = primaryAsset:Clone()
		clone:SetPrimaryPartCFrame(cframe)
		clone.Parent = parent
	else -- warn/error
		warn("No asset with name '" .. asset .. "' exists for locale '" .. currentLocale .. "' to place down")
	end
end

-- Sets the initial locale of the player
local function initializeLocale()
	-- Get the translator that the player will be using
	local success, translator = pcall(function()
		return LocalizationService:GetTranslatorForPlayer(LocalPlayer)
	end)
 
	if success then
		-- If successful, then set the locale
		LocalizationSwapper:SetLocale(translator.LocaleId)
	end
end

initializeLocale()

return LocalizationSwapper
