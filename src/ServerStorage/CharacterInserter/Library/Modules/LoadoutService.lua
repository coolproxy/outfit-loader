local players = game:GetService("Players")
local r6, r15 = script.R6, script.R15

local api = {}
api.RigType = "r15"

local function CompileCharacter(user, outfit)
	if user then
		user = tostring(user)
		local dummy = (api.RigType:lower() == "r15" and r15:Clone()) or r6:Clone()
		local oldCF = nil
		
		if not tonumber(user) then
			local success, data = pcall(function() 
				return players:GetUserIdFromNameAsync(user)	
			end)
			
			if not success then
				warn("CharacerInsert: " .. data)
				dummy:Destroy()
				return nil
			end
			
			user = data
		end
		
		local success, message = pcall(function() 
			local appearance = ((outfit and players:GetHumanoidDescriptionFromOutfitId(outfit)) or players:GetHumanoidDescriptionFromUserId(user))
			dummy.Parent = workspace.CurrentCamera
			oldCF = dummy.PrimaryPart.CFrame
			dummy.PrimaryPart.CFrame = CFrame.new(Vector3.new(0, 10000, 0))
			dummy.Humanoid:ApplyDescription(appearance)
			dummy.Name = players:GetNameFromUserIdAsync(user)
			dummy.PrimaryPart.CFrame = oldCF
			dummy.Parent = script
		end)
		
		if not success then
			warn("CharacerInsert: " .. message)
			dummy:Destroy()
			return nil
		end
		
		return dummy, user, oldCF
	end
	return nil
end

function api:Load(id, outfit)
	if id then
		return CompileCharacter(id, outfit)
	end
end

return api