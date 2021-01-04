local http = game:GetService("HttpService")
local utils = {}
local cache = {}

function utils.get(url)
	local result;
	local success, err = pcall(function()
		result = http:GetAsync(url)
	end)
	
	if success and not err then
		return result
	else
		warn('Error occured, "'..err.."'")
		return err
	end
end

function utils.encode(data) -- json encode
	return http:JSONEncode(data)
end

function utils.decode(data) -- json decode
	return http:JSONDecode(data)
end

function utils.getinfo(tbl)
	local data = {}
	for index,value in pairs(tbl.data) do
		local name = value.name
		local id = value.id
		data[name] = id
	end
	return data
end

function utils.getTemplateId(assetId)
	local key = '.' .. assetId
	if cache[key] then
		return cache[key]
	else
		local info = utils.get("https://coolestwebsiteverrr.000webhostapp.com/getTemplate.php?assetId=" .. assetId)
		cache[key] = info
		return info
	end
end

return utils;
