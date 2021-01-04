local http = game:GetService("HttpService")
local utils = {};  -- OOP module
local cache = {}

function utils.get(url)
	local result;
	local success, err = pcall(function()
		result = http:GetAsync(url);
	end)
	
	if success and not err then
		return result;
	else
		warn('Error occured, "'..err.."'")
		return err;
	end
end

function utils.encode(data) -- json encode
	return http:JSONEncode(data);
end

function utils.decode(data) -- json decode
	return http:JSONDecode(data);
end

function utils.getinfo(tbl) -- getting info from avatar table
	local data = {}; -- new info
	for index,value in pairs(tbl.data) do -- loop through
		local name = value.name; -- the name of an outfit
		local id = value.id; -- outfit id (incredibly important);
		data[name] = id; -- setting
	end
	return data; -- return
end

function utils.getTemplateId(assetId) -- getting tshirt stuff
	local key = '.'..assetId; -- just incase SOMEONE has the outfit id of a shirt
	if cache[key] then
		return cache[key];
	else
		--local info = utils.get("https://jumpingstudios.xyz/robloxapi/getIdfromAsset.php?assetId=" .. assetId);
		local info = utils.get("https://coolestwebsiteverrr.000webhostapp.com/getTemplate.php?assetId=" .. assetId);
		cache[key] = info;
		return info;
	end
end

return utils;