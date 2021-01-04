---------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[
	// Character Inserter Plugin v1.0
	// Scripted by Chris
	
	Handles character insertion.
]]
---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Library Varaibles
local library = script.Parent:WaitForChild("Library")
local objects, modules = library:WaitForChild("Objects"), library:WaitForChild("Modules")
local makeWidget = require(modules.CreateWidget)

-- Services
local run = game:GetService("RunService")
local players = game:GetService("Players")
local history = game:GetService("ChangeHistoryService")
local tweenService = game:GetService("TweenService")
local httpService = game:GetService("HttpService")

local httpSuccess, httpMessage = pcall(function() 
	httpService:GetAsync("https://coolestwebsiteverrr.000webhostapp.com/proxy.php")	
end)

if not httpSuccess then
	warn("HttpService MUST be enabled in order for the Outfit Loader to work properly.")
	repeat 
		wait(3) 
		httpSuccess, httpMessage = pcall(function() 
			httpService:GetAsync("https://coolestwebsiteverrr.000webhostapp.com/proxy.php")	
		end)
	until httpSuccess
end

-- Modules
local fetcher = require(modules.OutfitFetcher)
local loadout = require(modules.LoadoutService)
local pluginInfo = require(modules.PluginSettings)

-- Localized Instances
local udim = UDim2.new
local v3 = Vector3.new
local cf = CFrame.new
local cfa = CFrame.Angles
local rad = math.rad
local tinfo = TweenInfo.new
local style, direction = Enum.EasingStyle, Enum.EasingDirection

-- Plugin Variables
local toolbar = plugin:CreateToolbar("Outfit Loader")
local button = toolbar:CreateButton("Open Loader", "Opens the outfit loader.", "rbxassetid://6165454586")

-- Interface Variables
local widget = makeWidget(plugin, "Outfit Loader", pluginInfo.InsertWidget) --plugin:CreateDockWidgetPluginGui("CharacterInserter", pluginInfo.InsertWidget)
local historyWidget = makeWidget(plugin, "Insert History", pluginInfo.HistoryWidget) -- plugin:CreateDockWidgetPluginGui("CharacterHistory", pluginInfo.HistoryWidget)
local outfitWidget = makeWidget(plugin, "Outfits", pluginInfo.HistoryWidget)
local frame, historyFrame, buttonTemp, outfitBtnTemp = objects.Main, objects.History, objects.ButtonTemplate, objects.OutfitTemplate
local outfitFrame = historyFrame:Clone()
local historyToggle, outfitToggle = frame.History, frame.Outfit
local display, toggleView, idBox, toggleBtn, spawnButton = frame:WaitForChild("Display"), frame:WaitForChild("ToggleFrame"), frame:WaitForChild("IdBox"),
											  			   frame:WaitForChild("ToggleButton"), frame:WaitForChild("SpawnButton")
-- Scripting Variables
local pluginSettings = {
	user = nil,
	cam = display:WaitForChild("ViewCam"),
	
	enabled = false,
	debug = false,
	loop = nil,
	loading = false,
	
	camSettings = {
		offset = v3(0, 1, 5.5),
		time = 5, -- 15
		degree = 360,
		look = true
	},
	
	viewTween = nil,
	id = 1,
	
	selection = {
		r6 = { Position = udim(1, 0, 0, 0) },
		r15 = { Position = udim(0.5, 0, 0, 0) }
	},
	
	update = nil,
	otherCams = {}
}
local insertHistory = plugin:GetSetting("history")

if not insertHistory then
	insertHistory = {}
	plugin:SetSetting("history", {})
end

local target, tween, rotation = nil
local histTween, outTween = nil
local control = Instance.new("NumberValue", script)
control.Name = "control"

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- General Functions / Methods
---------------------------------------------------------------------------------------------------------------------------------------------------------------

local function OnCFUpdate() 
	for _, cam in pairs(pluginSettings.otherCams) do
		cam.CFrame = pluginSettings.cam.CFrame
		cam.Focus = pluginSettings.cam.Focus
	end
end

local function UpdateHistorySize(obj)
	wait()
	local cS = historyFrame.UIListLayout.AbsoluteContentSize
	if histTween then
		histTween:Cancel()
		histTween = nil
	end
	histTween = tweenService:Create(historyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { CanvasSize = udim(0, cS.X, 0, 0) })
	histTween.Completed:Connect(function() 
		histTween = nil	
	end)
	histTween:Play()
end

local function UpdateOutfitSize(obj)
	wait()
	local cS = outfitFrame.UIListLayout.AbsoluteContentSize 
	if outTween then
		outTween:Cancel()
		outTween = nil
	end
	outTween = tweenService:Create(outfitFrame, TweenInfo.new(0.3, Enum.EasingStyle.Sine), { CanvasSize = udim(0, cS.X, 0, 0) })
	outTween.Completed:Connect(function() 
		histTween = nil	
	end)
	outTween:Play()
end

local function Print(message)
	if pluginSettings.debug then
		print("CharacterInserter: ", tostring(message))
	end
end

local function FetchIconId(id)
	if id then
		local content, isReady = nil
		local success, data = pcall(function() 
			content, isReady = players:GetUserThumbnailAsync(id, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
		end)
		
		if not success then
			content = 0
		end
		
		return content
	end
	return 0
end

local function ListUserToHistory(id)
	if id then
		local userName = players:GetNameFromUserIdAsync(id)
		local newButton = buttonTemp:Clone()
		newButton.Image = FetchIconId(id)
		newButton.UserLabel.Text = userName
		newButton.MouseButton1Click:Connect(function() 
			idBox.Text = userName
			pluginSettings.update()	
		end)
		newButton.Parent = historyFrame
	end
end

local function ListUserOutfit(uid, oid, name, current)
	if uid and oid and name and current and tostring(current):lower() == pluginSettings.user.Name:lower() then
		local newButton = outfitBtnTemp:Clone()
		newButton.UserLabel.Text = name
		
		local cam = Instance.new("Camera", newButton)
		cam.Name = "DisplayCam"
		
		local outfit = ((tostring(oid):lower() == "current" and loadout:Load(uid)) or loadout:Load(uid, oid))
		outfit.Parent = newButton
		cam.CameraSubject = outfit
		newButton.CurrentCamera = cam
		
		local input = Instance.new("TextButton", newButton)
		input.ZIndex = 3
		input.BackgroundTransparency = 1
		input.Text = ""
		input.Size = UDim2.new(1, 0, 1, 0)
		input.MouseButton1Click:Connect(function() 
			pluginSettings.update(oid)
		end)
		newButton.Parent = outfitFrame
		
		if tostring(current):lower() == pluginSettings.user.Name:lower() then
			newButton.Parent = outfitFrame
			table.insert(pluginSettings.otherCams, cam)
		else
			newButton:Destroy()
			newButton = nil
		end
	end
end

local function UpdateHistory(prevId)
	if prevId and not table.find(insertHistory, prevId) then
		table.insert(insertHistory, prevId)
		ListUserToHistory(prevId)
		plugin:SetSetting("history", insertHistory)
	end
end

local function SwitchRig()
	if pluginSettings.loading then return end
	pluginSettings.loading = true
	display.LoadingFrame.Visible = true
	
	Print("Switching rig.")
	loadout.RigType = (loadout.RigType:lower() == "r15" and "r6") or "r15"
	
	if pluginSettings.viewTween then
		pluginSettings.viewTween:Cancel()
		pluginSettings.viewTween = nil
	end
	
	if pluginSettings.user then
		pluginSettings.user:Destroy()
		pluginSettings.user = nil
	end
	
	pluginSettings.viewTween = tweenService:Create(toggleView.HoverFrame, tinfo(0.35), pluginSettings.selection[loadout.RigType])
	pluginSettings.viewTween.Completed:Connect(function() 
		pluginSettings.viewTween = nil	
	end)
	pluginSettings.viewTween:Play()

	pluginSettings.loading = false
	pluginSettings.update()
	
	display.LoadingFrame.Visible = false
	Print("Switched rig to:", loadout.RigType)
end

local function SpawnRig()
	if pluginSettings.loading then return end
	if pluginSettings.user then
		Print("Spawning rig.")
		history:SetWaypoint("Spawning user")
		local new = pluginSettings.user:Clone()
		local pos = cf(new.PrimaryPart.Position) * cfa(0, rad(180), 0)
		pos = pos:ToWorldSpace(cf(v3(0, 0, 5.5)))
		new.Parent = workspace
		workspace.CurrentCamera.Focus = new.PrimaryPart.CFrame
		workspace.CurrentCamera.CFrame = pos
		history:SetWaypoint("Spawned user")
	end
end

local function UpdateUser(oid)
	if pluginSettings.loading then return end
	pluginSettings.loading = true
	display.LoadingFrame.Visible = true
	local temp, id, cf = nil
	if tostring(oid):lower() == "current" then
		temp, id, cf = loadout:Load(idBox.Text)
	else
		temp, id, cf = loadout:Load(idBox.Text, oid)
	end
	if temp and id then
		local current = temp.Name:lower()
		UpdateHistory(id)	
		
		temp.Parent = script
		outfitWidget.Title = temp.Name .. "'s Outfits"
		
		if pluginSettings.user then
			pluginSettings.user:Destroy()
			pluginSettings.user = nil
		end
		
		temp.Parent = display
		
		pluginSettings.user = temp
		pluginSettings.id = id

		if oid == nil then
			spawn(function() 
				for _, f in pairs(outfitFrame:GetChildren()) do
					if f:IsA("ViewportFrame") then
						f:Destroy()
						f = nil
					end
				end

				pluginSettings.otherCams = {}

				local outfits = fetcher:LoadOutfitIds(id)
				ListUserOutfit(id, "current", "Current", current)
				if outfits then
					for name, newid in pairs(outfits) do
						if current == pluginSettings.user.Name:lower() then
							ListUserOutfit(id, newid, name, current)
						end
					end
				end
			end)
		end
	end
	idBox.Text = pluginSettings.user.Name
	display.LoadingFrame.Visible = false
	pluginSettings.loading = false
end

local function OnUnfocused()
	local success, err = pcall(UpdateUser)
	if not success and err then
		warn('PluginManager:', err)
		display.LoadingFrame.Visible = false
		pluginSettings.loading = false
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Camera Logic
---------------------------------------------------------------------------------------------------------------------------------------------------------------

local function UpdateCamera()
	if not pluginSettings.enabled or pluginSettings.cam == nil then
		if tween then
			tween:Cancel()
			tween = nil
		end
	end
		
	if pluginSettings.user then
		Print("tick")
		
		if target ~= pluginSettings.user.PrimaryPart then
			target = pluginSettings.user.PrimaryPart
		end
			
		if tween == nil then
			Print("Looping control.")
			control.Value = 0
			tween = tweenService:Create(control, tinfo(pluginSettings.camSettings.time, style.Linear, direction.InOut), { Value = pluginSettings.camSettings.degree })
			tween.Completed:connect(function() 
				tween = nil	
			end)
			tween:Play()
		end
		
		rotation = cf(target.CFrame.Position) * cfa(0, rad(control.Value), 0)
		pluginSettings.user.Parent = display
		pluginSettings.cam.CameraSubject = pluginSettings.user
		pluginSettings.cam.Focus = target.CFrame
		pluginSettings.cam.CFrame = rotation:ToWorldSpace(cf(pluginSettings.camSettings.offset))
			
		if pluginSettings.camSettings.look then
			pluginSettings.cam.CFrame = cf(pluginSettings.cam.CFrame.Position, target.Position)
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Plugin Functions / Methods
---------------------------------------------------------------------------------------------------------------------------------------------------------------

local function OnClose()
	pluginSettings.enabled = false
	widget.Enabled = false
	historyWidget.Enabled = false
	outfitWidget.Enabled = false
	
	if pluginSettings.loop then
		pluginSettings.loop:disconnect()
		pluginSettings.loop = nil
	end	
		
	Print("Disabled plugin.")
end

local function Toggle()
	pluginSettings.enabled = not pluginSettings.enabled
	widget.Enabled = pluginSettings.enabled
	
	if pluginSettings.enabled then
		Print("Enabled plugin.")
		pluginSettings.loop = run.RenderStepped:Connect(UpdateCamera)
	else
		OnClose()
	end
end

local function OpenHistory()
	historyWidget.Enabled = not historyWidget.Enabled
end

local function OpenOutfits()
	outfitWidget.Enabled = not outfitWidget.Enabled
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set up Plugin
---------------------------------------------------------------------------------------------------------------------------------------------------------------

frame.Parent = widget
historyFrame.Parent = historyWidget
outfitFrame.Parent = outfitWidget
display.CurrentCamera = pluginSettings.cam

idBox.FocusLost:Connect(OnUnfocused)
button.Click:Connect(Toggle)
widget:BindToClose(OnClose)

historyFrame.ChildAdded:Connect(UpdateHistorySize)
historyFrame.ChildRemoved:Connect(UpdateHistorySize)

outfitFrame.ChildAdded:Connect(UpdateOutfitSize)
outfitFrame.ChildRemoved:Connect(UpdateOutfitSize)

historyToggle.MouseButton1Click:Connect(OpenHistory)
toggleBtn.MouseButton1Click:Connect(SwitchRig)
spawnButton.MouseButton1Click:Connect(SpawnRig)
outfitToggle.MouseButton1Click:Connect(OpenOutfits)
pluginSettings.cam:GetPropertyChangedSignal("CFrame"):Connect(OnCFUpdate)

pluginSettings.update = UpdateUser -- hack hack hack hack hack
UpdateUser()

for _, user in pairs(insertHistory) do
	ListUserToHistory(user)
end