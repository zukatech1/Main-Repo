--[[
	Enhanced Aimbot - Luna UI Version (Fixed)
	Receives Luna instance instead of loading it
--]]

local AimbotGUILuna = {}
AimbotGUILuna.__index = AimbotGUILuna

local RunService = game:GetService("RunService")

function AimbotGUILuna.new(aimbotSystem, lunaInstance)
	local self = setmetatable({}, AimbotGUILuna)
	
	self.aimbot = aimbotSystem
	self.luna = lunaInstance
	self.connections = {}
	self.window = nil
	
	return self
end

function AimbotGUILuna:build()
	print("[GUI] Building Luna window...")
	
	-- Create main window using the Luna instance passed in
	self.window = self.luna:CreateWindow({
		Name = "Enhanced Aimbot Suite",
		LogoID = "rbxassetid://7733993369",
		LoadedCallback = function()
			print("[GUI] Luna window loaded!")
		end,
		FolderToSave = "AimbotConfig",
		Footer = "Enhanced Aimbot v2.0"
	})
	
	print("[GUI] Creating tabs...")
	
	-- Create tabs
	local mainTab = self.window:CreateTab({
		Name = "Main",
		Icon = "rbxassetid://7733673466"
	})
	
	local targetingTab = self.window:CreateTab({
		Name = "Targeting",
		Icon = "rbxassetid://7733779610"
	})
	
	local visualsTab = self.window:CreateTab({
		Name = "Visuals",
		Icon = "rbxassetid://7733955511"
	})
	
	local settingsTab = self.window:CreateTab({
		Name = "Settings",
		Icon = "rbxassetid://7734021200"
	})
	
	-- =====================================
	-- MAIN TAB
	-- =====================================
	
	print("[GUI] Building Main tab...")
	local generalSection = mainTab:CreateSection({
		Name = "General"
	})
	
	-- Keybind
	generalSection:CreateKeybind({
		Name = "Aimbot Toggle Key",
		CurrentKey = "MouseButton2",
		Callback = function(key)
			local inputType = Enum.UserInputType.MouseButton2
			local keyCode = nil
			
			if key ~= "MouseButton2" then
				inputType = Enum.UserInputType.Keyboard
				keyCode = Enum.KeyCode[key]
			end
			
			self.aimbot.settings.toggleKey = keyCode or inputType
		end
	})
	
	-- Aim Part Dropdown
	generalSection:CreateDropdown({
		Name = "Aim Part",
		Options = {"Head", "UpperTorso", "HumanoidRootPart", "Torso", "LowerTorso"},
		CurrentOption = self.aimbot.settings.aimPart,
		Callback = function(option)
			self.aimbot.settings.aimPart = option
		end
	})
	
	-- Smart Hitbox Toggle
	generalSection:CreateToggle({
		Name = "Smart Hitbox Selection",
		CurrentValue = self.aimbot.settings.hitboxPriority,
		Callback = function(state)
			self.aimbot.settings.hitboxPriority = state
		end
	})
	
	generalSection:CreateLabel({
		Text = "Smart Hitbox auto-selects the best visible target part"
	})
	
	-- FOV Section
	local fovSection = mainTab:CreateSection({
		Name = "Field of View"
	})
	
	fovSection:CreateSlider({
		Name = "FOV Radius",
		Range = {50, 500},
		Increment = 10,
		CurrentValue = self.aimbot.settings.fovRadius,
		Callback = function(value)
			self.aimbot.settings.fovRadius = value
		end
	})
	
	-- Smoothing Section
	local smoothingSection = mainTab:CreateSection({
		Name = "Smoothing"
	})
	
	smoothingSection:CreateToggle({
		Name = "Enable Smoothing",
		CurrentValue = self.aimbot.settings.smoothingEnabled,
		Callback = function(state)
			self.aimbot.settings.smoothingEnabled = state
		end
	})
	
	smoothingSection:CreateSlider({
		Name = "Smoothness",
		Range = {0.05, 1.0},
		Increment = 0.05,
		CurrentValue = self.aimbot.settings.smoothingFactor,
		Callback = function(value)
			self.aimbot.settings.smoothingFactor = value
		end
	})
	
	smoothingSection:CreateToggle({
		Name = "Distance-Based Smoothing",
		CurrentValue = self.aimbot.settings.distanceBasedSmoothing,
		Callback = function(state)
			self.aimbot.settings.distanceBasedSmoothing = state
		end
	})
	
	smoothingSection:CreateLabel({
		Text = "Distance-based makes close targets smoother, far targets faster"
	})
	
	-- =====================================
	-- TARGETING TAB
	-- =====================================
	
	print("[GUI] Building Targeting tab...")
	local predictionSection = targetingTab:CreateSection({
		Name = "Prediction"
	})
	
	predictionSection:CreateToggle({
		Name = "Enable Prediction",
		CurrentValue = self.aimbot.settings.predictionEnabled,
		Callback = function(state)
			self.aimbot.settings.predictionEnabled = state
		end
	})
	
	predictionSection:CreateSlider({
		Name = "Prediction Strength",
		Range = {0.5, 2.0},
		Increment = 0.1,
		CurrentValue = self.aimbot.settings.predictionMultiplier,
		Callback = function(value)
			self.aimbot.settings.predictionMultiplier = value
		end
	})
	
	predictionSection:CreateLabel({
		Text = "Higher = predict further ahead (good for fast targets)"
	})
	
	-- Target Lock Section
	local targetLockSection = targetingTab:CreateSection({
		Name = "Target Lock"
	})
	
	targetLockSection:CreateToggle({
		Name = "Sticky Target",
		CurrentValue = self.aimbot.settings.stickyTarget,
		Callback = function(state)
			self.aimbot.settings.stickyTarget = state
		end
	})
	
	targetLockSection:CreateLabel({
		Text = "Sticky keeps locked on current target even outside FOV"
	})
	
	-- Specific player targeting
	local specificTargetToggle
	local specificTargetDropdown
	
	local function updatePlayerList()
		local players = game:GetService("Players"):GetPlayers()
		local playerNames = {"None"}
		
		for _, player in ipairs(players) do
			if player ~= game:GetService("Players").LocalPlayer then
				table.insert(playerNames, player.Name)
			end
		end
		
		return playerNames
	end
	
	specificTargetDropdown = targetLockSection:CreateDropdown({
		Name = "Specific Target",
		Options = updatePlayerList(),
		CurrentOption = "None",
		Callback = function(option)
			if option == "None" then
				self.aimbot.settings.specificTarget = nil
			else
				local player = game:GetService("Players"):FindFirstChild(option)
				self.aimbot.settings.specificTarget = player
			end
		end
	})
	
	specificTargetToggle = targetLockSection:CreateToggle({
		Name = "Lock to Specific Target",
		CurrentValue = self.aimbot.settings.specificTargetEnabled,
		Callback = function(state)
			self.aimbot.settings.specificTargetEnabled = state
		end
	})
	
	targetLockSection:CreateButton({
		Name = "Refresh Player List",
		Callback = function()
			-- Update dropdown with current players
			specificTargetDropdown:Refresh(updatePlayerList())
		end
	})
	
	-- Modifiers Section
	local modifiersSection = targetingTab:CreateSection({
		Name = "Modifiers"
	})
	
	modifiersSection:CreateToggle({
		Name = "Ignore Teammates",
		CurrentValue = self.aimbot.settings.ignoreTeam,
		Callback = function(state)
			self.aimbot.settings.ignoreTeam = state
		end
	})
	
	modifiersSection:CreateToggle({
		Name = "Wall Check",
		CurrentValue = self.aimbot.settings.wallCheckEnabled,
		Callback = function(state)
			self.aimbot.settings.wallCheckEnabled = state
		end
	})
	
	modifiersSection:CreateLabel({
		Text = "Wall Check only targets visible enemies"
	})
	
	-- =====================================
	-- VISUALS TAB
	-- =====================================
	
	print("[GUI] Building Visuals tab...")
	local fovVisualSection = visualsTab:CreateSection({
		Name = "FOV Circle"
	})
	
	local fovCircleEnabled = true
	
	fovVisualSection:CreateToggle({
		Name = "Show FOV Circle",
		CurrentValue = true,
		Callback = function(state)
			fovCircleEnabled = state
			if self.aimbot.fovCircle then
				if not state and not self.aimbot.aiming then
					self.aimbot.fovCircle.Visible = false
				end
			end
		end
	})
	
	fovVisualSection:CreateColorPicker({
		Name = "FOV Circle Color",
		CurrentColor = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			if self.aimbot.fovCircle then
				self.aimbot.fovCircle.Color = color
			end
		end
	})
	
	fovVisualSection:CreateSlider({
		Name = "FOV Transparency",
		Range = {0, 1},
		Increment = 0.1,
		CurrentValue = 0.6,
		Callback = function(value)
			if self.aimbot.fovCircle then
				self.aimbot.fovCircle.Transparency = value
			end
		end
	})
	
	fovVisualSection:CreateSlider({
		Name = "FOV Thickness",
		Range = {1, 5},
		Increment = 1,
		CurrentValue = 2,
		Callback = function(value)
			if self.aimbot.fovCircle then
				self.aimbot.fovCircle.Thickness = value
			end
		end
	})
	
	-- ESP Section
	local espSection = visualsTab:CreateSection({
		Name = "ESP"
	})
	
	espSection:CreateColorPicker({
		Name = "ESP Color",
		CurrentColor = Color3.fromRGB(255, 80, 80),
		Callback = function(color)
			-- Store for ESP creation
			self.espColor = color
		end
	})
	
	espSection:CreateLabel({
		Text = "ESP automatically shows on locked targets"
	})
	
	-- =====================================
	-- SETTINGS TAB
	-- =====================================
	
	print("[GUI] Building Settings tab...")
	
	-- Profile Section
	local profileSection = settingsTab:CreateSection({
		Name = "Profiles"
	})
	
	local profileName = "default"
	
	profileSection:CreateTextbox({
		Name = "Profile Name",
		PlaceholderText = "Enter profile name",
		RemoveTextAfterFocusLost = false,
		Callback = function(text)
			profileName = text
		end
	})
	
	profileSection:CreateButton({
		Name = "Save Profile",
		Callback = function()
			local success, err = self.aimbot:saveProfile(profileName)
			if success then
				self.luna:Notification({
					Title = "Profile Saved",
					Content = "Profile '" .. profileName .. "' saved successfully!",
					Duration = 3
				})
			else
				self.luna:Notification({
					Title = "Save Failed",
					Content = err or "Failed to save profile",
					Duration = 3
				})
			end
		end
	})
	
	profileSection:CreateButton({
		Name = "Load Profile",
		Callback = function()
			local success = self.aimbot:loadProfile(profileName)
			if success then
				self.luna:Notification({
					Title = "Profile Loaded",
					Content = "Profile '" .. profileName .. "' loaded successfully!",
					Duration = 3
				})
			else
				self.luna:Notification({
					Title = "Load Failed",
					Content = "Profile '" .. profileName .. "' not found",
					Duration = 3
				})
			end
		end
	})
	
	-- Preset Profiles Section
	local presetsSection = settingsTab:CreateSection({
		Name = "Presets"
	})
	
	presetsSection:CreateButton({
		Name = "Sniper Preset",
		Callback = function()
			self.aimbot.settings.fovRadius = 125
			self.aimbot.settings.smoothingFactor = 0.4
			self.aimbot.settings.predictionMultiplier = 1.3
			self.aimbot.settings.stickyTarget = true
			self.aimbot.settings.distanceBasedSmoothing = true
			self.luna:Notification({
				Title = "Preset Applied",
				Content = "Sniper preset loaded",
				Duration = 2
			})
		end
	})
	
	presetsSection:CreateButton({
		Name = "Close Combat Preset",
		Callback = function()
			self.aimbot.settings.fovRadius = 250
			self.aimbot.settings.smoothingFactor = 0.15
			self.aimbot.settings.predictionMultiplier = 0.9
			self.aimbot.settings.stickyTarget = false
			self.aimbot.settings.distanceBasedSmoothing = false
			self.luna:Notification({
				Title = "Preset Applied",
				Content = "Close Combat preset loaded",
				Duration = 2
			})
		end
	})
	
	presetsSection:CreateButton({
		Name = "Tracking Preset",
		Callback = function()
			self.aimbot.settings.fovRadius = 175
			self.aimbot.settings.smoothingFactor = 0.5
			self.aimbot.settings.predictionMultiplier = 1.1
			self.aimbot.settings.stickyTarget = true
			self.aimbot.settings.distanceBasedSmoothing = true
			self.luna:Notification({
				Title = "Preset Applied",
				Content = "Tracking preset loaded",
				Duration = 2
			})
		end
	})
	
	-- Info Section
	local infoSection = settingsTab:CreateSection({
		Name = "Information"
	})
	
	local statusLabel = infoSection:CreateLabel({
		Text = "Status: Ready"
	})
	
	local targetLabel = infoSection:CreateLabel({
		Text = "Targets: 0"
	})
	
	local fpsLabel = infoSection:CreateLabel({
		Text = "FPS: 60"
	})
	
	-- Update info labels
	local lastUpdate = tick()
	local frameCount = 0
	
	table.insert(self.connections, RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		local now = tick()
		
		if now - lastUpdate >= 1 then
			local fps = frameCount / (now - lastUpdate)
			
			-- Update status
			if self.aimbot.aiming then
				if self.aimbot.currentTarget then
					local player = game:GetService("Players"):GetPlayerFromCharacter(self.aimbot.currentTarget)
					statusLabel:Set("Status: Locked - " .. (player and player.Name or "Unknown"))
				else
					statusLabel:Set("Status: Aiming - No Target")
				end
			else
				statusLabel:Set("Status: Ready")
			end
			
			targetLabel:Set("Targets: " .. #self.aimbot.targetIndex)
			fpsLabel:Set("FPS: " .. math.floor(fps))
			
			frameCount = 0
			lastUpdate = now
		end
	end))
	
	-- About Section
	local aboutSection = settingsTab:CreateSection({
		Name = "About"
	})
	
	aboutSection:CreateLabel({
		Text = "Enhanced Aimbot Suite v2.0"
	})
	
	aboutSection:CreateLabel({
		Text = "Complete rewrite with advanced features"
	})
	
	aboutSection:CreateButton({
		Name = "Destroy GUI",
		Callback = function()
			self:destroy()
			self.window:Destroy()
		end
	})
	
	-- Initial notification
	self.luna:Notification({
		Title = "Aimbot Loaded",
		Content = "Enhanced Aimbot Suite initialized successfully!",
		Duration = 3
	})
	
	print("[GUI] All tabs built successfully!")
	
	return self.window
end

function AimbotGUILuna:destroy()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	self.connections = {}
	
	if self.aimbot then
		self.aimbot:destroy()
	end
end

return AimbotGUILuna
