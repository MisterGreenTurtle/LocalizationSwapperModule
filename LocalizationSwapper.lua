local LocalizationSwapper = {}

--[[
	This module is designed to help developers switch out assets that need special translation
	It requires that the developer have a storage setup, rootAssetStorage, which contains the translated assets
	These directories must be named after the LocaleId
--]]

local ASSET_FOLDER_NAME = "Localization Assets"
local SEARCH_RECURSIVELY = true
local DEFAULT_FALLBACK = "default"

local LocalPlayer = game:GetService("Players").LocalPlayer
local LocalizationService = game:GetService("LocalizationService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Location of all the language directories
local rootAssetStorage = ReplicatedStorage:FindFirstChild(ASSET_FOLDER_NAME, SEARCH_RECURSIVELY)
if not rootAssetStorage then
	-- Cannot continue if folder not found
	error("Could not find descendant '" .. ASSET_FOLDER_NAME .. "' to use for asset swapping!", 2)
end

-- Default directory that could contain objects without translations
-- Defaults to this directory if a missing language is selected
local defaultFallback = rootAssetStorage:FindFirstChild(DEFAULT_FALLBACK)
if not defaultFallback then
	warn("Default directory not found, creating it and continuing")
	local folder = Instance.new("Folder")
	folder.Name = DEFAULT_FALLBACK
	folder.Parent = rootAssetStorage
	defaultFallback = folder
end

local currentLanguage = nil

-- Used to set the module's language
-- This is so that the language does not need to be checked multiple times
-- Can be used to manually set the language
function LocalizationSwapper:SetLanguage(language)
	currentLanguage = language
end

-- Sets the initial language of the player
local function getLocalization()
	-- Get the translator that the player will be using
	local success, translator = pcall(function()
		return LocalizationService:GetTranslatorForPlayer(LocalPlayer)
	end)
 
	if success then -- If successful, then set the language
		LocalizationSwapper:SetLanguage(translator.LocaleId)
	else -- If there is an error, this module cannot be used
		LocalizationSwapper:SetLanguage(nil)
	end
end

-- This function switches out the primary with a replacement
-- Both the primary and the replacement need to have a PrimaryPart
-- The replacement should be stored under under the correct language in rootAssetStorage
function LocalizationSwapper:SwapForLocalization(primary, replacement)
	if not (currentLanguage and primary and replacement) then
		return
	end
	
	-- Validate directory and clone replacement
	local success, replacementAsset = pcall(function()
		local localeDir = rootAssetStorage:FindFirstChild(currentLanguage)
		if localeDir == nil then
			localeDir = defaultFallback -- use default asset if language is missing
		end
		
		return localeDir:FindFirstChild(replacement):Clone()
	end)	
	
	if success then -- Replace primary with the replacement
		replacementAsset:SetPrimaryPartCFrame(primary.PrimaryPart.CFrame)
		replacementAsset.Parent = primary.Parent
		primary:Destroy()
	end
end

-- This function removes primary if the user is using a language that matches an element from languageTable
function LocalizationSwapper:RemoveForLocalization(primary, languageTable)
	if not (currentLanguage and primary and languageTable) then
		return
	end
	
	-- Check if currentLanguage is in languageTable
	for _,v in pairs(languageTable) do
		if currentLanguage == v then
			primary:Destroy() -- Remove primary
			break
		end
	end
end

-- This function places primary as a child to parent at cframe
-- Placement will only happen if the currentLanguage matches and element from languageTable
function LocalizationSwapper:PlaceForLocalization(languageTable, primary, cframe, parent)
	if not (currentLanguage and languageTable and primary and cframe) then
		return
	end
	
	-- Check if currentLanguage is in languageTable
	local foundLanguage = false
	for _, lang in pairs(languageTable) do
		if currentLanguage == lang then
			foundLanguage = true
			break
		end
	end
	if not foundLanguage then
		return -- Placement not needed
	end
	
	-- Validate directory and clone replacement
	local success, primaryAsset = pcall(function()
		local localeDir = rootAssetStorage:FindFirstChild(currentLanguage)
		if not localeDir then
			localeDir = defaultFallback -- use default asset if language is missing
		end

		return localeDir:FindFirstChild(primary):Clone()
	end)
	
	if success then -- Place primary
		primaryAsset:SetPrimaryPartCFrame(cframe)
		primaryAsset.Parent = parent
	end
end

getLocalization()

return LocalizationSwapper
