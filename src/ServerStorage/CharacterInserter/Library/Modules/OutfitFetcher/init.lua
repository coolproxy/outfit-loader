---------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
	// OutfitFetcher
	// Scripted by Chris
	
	Fetches a user's outfit. Utilizes HTTP service.
	Dependencies weren't made by me.
]]
---------------------------------------------------------------------------------------------------------------------------------------------------------------

local api = {}
local players = game:GetService("Players")

local modules = {
	proxy = require(script.Proxy);
	utils = require(script.Utils);
}
local cache = {}

local function GetOutfits(uid)
	if uid then
		local url = 'https://avatar.roblox.com/v1/users/' .. uid .. '/outfits?itemsPerPage=50' 

		if cache[url] then 
			return cache[url] 
		else
			local data = modules.proxy(url)
			if data and #data >= 1 then
				data = modules.utils.decode(data)
				local count = data.total

				data = modules.utils.getinfo(data)
				
				local tbl = { 
					amount = count,
					outfits = data
				}
				
				return tbl
			else
				warn('OutfitFetcher: No data found for "' .. uid .. '"')
				return nil
			end
		end
	end
	return nil
end

local function CreateOutfit(id)
	if id then
		return players:GetHumanoidDescriptionFromOutfitId(id)
	end
	return nil
end

function api:LoadOutfitIds(uid)
	if uid then
		local success, index = pcall(function() 
			return GetOutfits(uid)	
		end)
		if not success then
			warn('OutfitFetcher: ' .. index)
			return nil
		end
		if index and index.outfits then
			return index.outfits
		end
	end
	return nil
end

return api