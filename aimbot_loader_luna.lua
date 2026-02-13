--[[
	Enhanced Aimbot Suite - Luna UI Loader
	
	Usage:
		loadAimbotGUI() -- Basic load
		loadAimbotGUI({targetPlayer = "PlayerName"}) -- Lock to specific player
		loadAimbotGUI({profile = "sniper"}) -- Load specific profile
		
	Commands (if using a command system):
		aimbot -- Open GUI
		aimbot [player] -- Open and lock to player
		aimbot clear -- Clear target lock
--]]

local function loadAimbotGUI(args)
	local Players = game:GetService("Players")
	
	local success, err = pcall(function()
		-- Load Luna UI Library
		local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/main/source.lua"))()
		
		-- Load modules
		-- NOTE: Replace these with your actual module loading method
		-- Option 1: HTTP (if hosted online)
		-- local AimbotSystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourrepo/aimbot_improved.lua"))()
		-- local AimbotGUILuna = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourrepo/aimbot_gui_luna.lua"))()
		
		-- Option 2: Require (if using module scripts)
		-- local AimbotSystem = require(script.Parent.aimbot_improved)
		-- local AimbotGUILuna = require(script.Parent.aimbot_gui_luna)
		
		-- Option 3: Load from string (for testing - replace with actual code)
		local AimbotSystem = loadstring(game:HttpGet("YOUR_AIMBOT_IMPROVED_URL"))()
		local AimbotGUILuna = loadstring(game:HttpGet("YOUR_AIMBOT_GUI_LUNA_URL"))()
		
		-- Initialize aimbot system
		local aimbot = AimbotSystem.new()
		
		-- Load profile if specified
		if args and args.profile then
			local success = aimbot:loadProfile(args.profile)
			if success then
				Luna:Notification({
					Title = "Profile Loaded",
					Content = "Loaded profile: " .. args.profile,
					Duration = 2
				})
			end
		end
		
		-- Initialize GUI
		local gui = AimbotGUILuna.new(aimbot)
		gui:build()
		
		-- Start aimbot
		aimbot:start()
		
		-- Handle target player argument
		if args and args.targetPlayer then
			local targetName = args.targetPlayer
			
			if targetName:lower() == "clear" or targetName:lower() == "reset" or targetName:lower() == "off" then
				aimbot.settings.specificTargetEnabled = false
				aimbot.settings.specificTarget = nil
				Luna:Notification({
					Title = "Target Cleared",
					Content = "Aimbot target lock cleared",
					Duration = 2
				})
			else
				-- Find player
				local foundPlayer = nil
				local targetLower = targetName:lower()
				
				for _, player in ipairs(Players:GetPlayers()) do
					if player.Name:lower():find(targetLower) or player.DisplayName:lower():find(targetLower) then
						foundPlayer = player
						break
					end
				end
				
				if foundPlayer then
					aimbot.settings.specificTargetEnabled = true
					aimbot.settings.specificTarget = foundPlayer
					Luna:Notification({
						Title = "Target Locked",
						Content = "Locked onto: " .. foundPlayer.Name,
						Duration = 3
					})
				else
					Luna:Notification({
						Title = "Target Not Found",
						Content = "Player '" .. targetName .. "' not found",
						Duration = 3
					})
				end
			end
		end
		
		-- Success notification
		Luna:Notification({
			Title = "Aimbot Loaded",
			Content = "Enhanced Aimbot Suite loaded with Luna UI!",
			Duration = 3
		})
	end)
	
	if not success then
		warn("Failed to load Enhanced Aimbot:", err)
		
		-- Try to show error notification if Luna loaded
		pcall(function()
			Luna:Notification({
				Title = "Load Error",
				Content = "Failed to load aimbot: " .. tostring(err),
				Duration = 5
			})
		end)
		
		-- Fallback to standard notification if available
		if DoNotif then
			DoNotif("Error loading Aimbot: " .. tostring(err), 5)
		end
	end
end

-- Command registration (if using a command system)
if RegisterCommand then
	RegisterCommand({
		Name = "aimbot",
		Aliases = {"aim", "ab"},
		Description = "Loads the enhanced aimbot GUI. Optional: [player name] to lock target."
	}, function(args)
		local target = args and args[1]
		loadAimbotGUI(target and {targetPlayer = target} or nil)
	end)
end

-- Return loader function for external use
return loadAimbotGUI
