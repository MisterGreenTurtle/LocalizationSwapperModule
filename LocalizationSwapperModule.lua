local module = {}

--[[
	This module is designed to help developers switch out assets that need special translation
	It requires that the developer have a storage setup, rootAssetStorage, which contains the translated assets
	These directories must be named after the LocaleId
--]]

local player = game.Players.LocalPlayer
local localService = game:GetService("LocalizationService")

local currentLanguage = nil

-- Location of all the language directories
local rootAssetStorage = game.ReplicatedStorage["Localization Assets"]
-- Default directory that could contain objects without translations
-- Defaults to this directory if a missing language is selected
local defaultFallback = rootAssetStorage.default

-- Used to set the module's language
-- This is so that the language does not need to be checked multiple times
-- Can be used to manually set the language
function module:setLanguage(language)
	currentLanguage = language
end

-- Sets the initial language of the player
function getLocalization()
	-- Get the translator that the player will be using
	local success, translator = pcall(function()
		return localService:GetTranslatorForPlayer(player)
	end)
 
	if success then -- If successful, then set the language
		module:setLanguage(translator.LocaleId)
	else -- If there is an error, this module cannot be used
		module:setLanguage(nil)
	end
end

-- This function switches out the primary with a replacement
-- Both the primary and the replacement need to have a PrimaryPart
-- The replacement should be stored under under the correct language in rootAssetStorage
function module:swapForLocalization(primary, replacement)
	if currentLanguage == nil or primary == nil or replacement == nil then return end
	
	-- Validate directory and clone replacement
	local success, replacementAsset = pcall(function()
		local localeDir = rootAssetStorage:FindFirstChild(currentLanguage)
		if localeDir == nil then localeDir = defaultFallback end -- use default asset if language is missing
		
		local replacementAsset = localeDir:findFirstChild(replacement):Clone()
		
		return replacementAsset
	end)	
	
	if success then -- Replace primary with the replacement
		replacementAsset:SetPrimaryPartCFrame(primary.PrimaryPart.CFrame)
		replacementAsset.Parent = primary.Parent
		primary:Destroy()
	else -- Error with validation
		return
	end
end

-- This function removes primary if the user is using a language that matches an element from languageTable
function module:removeForLocalization(primary, languageTable)
	if currentLanguage == nil or primary == nil or languageTable == nil then return end
	
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
function module:placeForLocalization(languageTable, primary, cframe, parent)
	if currentLanguage == nil or languageTable == nil or primary == nil or cframe == nil then return end
	
	-- Check if currentLanguage is in languageTable
	local foundLanguage = false
	for _,v in pairs(languageTable) do
		if currentLanguage == v then
			foundLanguage = true
			break
		end
	end
	if foundLanguage == false then return end -- Placement not needed
	
	-- Validate directory and clone replacement
	local success, primaryAsset = pcall(function()
		local localeDir = rootAssetStorage:FindFirstChild(currentLanguage)
		if localeDir == nil then localeDir = defaultFallback end -- use default asset if language is missing
		
		local primaryAsset = localeDir:findFirstChild(primary):Clone()
		
		return primaryAsset
	end)
	
	if success then -- Place primary
		primaryAsset:SetPrimaryPartCFrame(cframe)
		primaryAsset.Parent = parent
	else -- Error with validation
		return
	end
end

getLocalization()

return module
