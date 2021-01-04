local config = {
	proxy = "https://coolestwebsiteverrr.000webhostapp.com/proxy.php"
}

local utils = require(script.Parent:WaitForChild("Utils"))

return function(url)
	return utils.get(config.proxy .. '?url=' .. url)
end
