-- todo: replace proxy

local config = {
	proxy = "https://coolestwebsiteverrr.000webhostapp.com/proxy.php"
	--proxy = "https://jumpingstudios.xyz/robloxapi/proxy.php"; -- My own host, you can check out the setup tutorial if you want to use your own host.
}

local utils = require(script.Parent:WaitForChild("Utils")); -- Utilities module

return function(url)
	return utils.get(config.proxy .. '?url=' .. url) -- get request for the url specified (avatar.roblox.com) only.
end