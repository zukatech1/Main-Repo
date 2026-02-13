local function loadAimbotGUI(args)
	local Players = game:GetService("Players")
	
	print("=== Loading Enhanced Aimbot ===")
	
	local success, err = pcall(function()
		-- Load Luna UI Library FIRST
		print("[1/4] Loading Luna UI...")
		local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/main/source.lua"))()
		
		if not Luna then
			error("Luna UI failed to load - check your internet connection")
		end
		print("✓ Luna UI loaded successfully")
		
		-- Load Aimbot System (core logic)
		print("[2/4] Loading Aimbot core system...")
		local AimbotSystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/gaminghcairimproved.lua"))()
		
		if not AimbotSystem then
			error("Aimbot core system failed to load - check GitHub URL")
		end
		print("✓ Core system loaded successfully")
		
		-- Load Luna GUI (UPDATED VERSION - must be aimbot_gui_luna_fixed.lua)
		print("[3/4] Loading Luna GUI module...")
		local AimbotGUILuna = loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/aimbot_gui_luna_fixed.lua"))()
		
		if not AimbotGUILuna then
			error("Luna GUI module failed to load - make sure you uploaded aimbot_gui_luna_fixed.lua")
		end
		print("✓ Luna GUI module loaded successfully")
		
		-- Initialize aimbot system
		print("[4/4] Initializing aimbot...")
		local aimbot = AimbotSystem.new()
		
		if not aimbot then
			error("Failed to create aimbot instance")
		end
		
		-- Load profile if specified
		if args and args.profile then
			local profileSuccess = aimbot:loadProfile(args.profile)
			if profileSuccess then
				Luna:Notification({
					Title = "Profile Loaded",
					Content = "Loaded profile: " .. args.profile,
					Duration = 2
				})
			end
		end
		
		-- Initialize GUI (passing Luna instance)
		print("Building GUI...")
		local gui = AimbotGUILuna.new(aimbot, Luna)
		
		if not gui then
			error("Failed to create GUI instance")
		end
		
		-- Build the GUI
		gui:build()
		print("✓ GUI built successfully")
		
		-- Start aimbot
		aimbot:start()
		print("✓ Aimbot started")
		
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
		
		print("=== All systems loaded successfully! ===")
	end)
	
	if not success then
		warn("==========================================")
		warn("AIMBOT LOAD ERROR:")
		warn(tostring(err))
		warn("==========================================")
		
		-- Detailed error notification
		if DoNotif then
			DoNotif("Aimbot Load Error: " .. tostring(err), 5)
		end
	end
end

-- Command registration (if using a command system)
if RegisterCommand then
	RegisterCommand({
		Name = "aimbot",
		Aliases = {},
		Description = "Loads the enhanced aimbot GUI. Optional: [player name] to lock target."
	}, function(args)
		local target = args and args[1]
		loadAimbotGUI(target and {targetPlayer = target} or nil)
	end)
end

-- Return loader function for external use
return loadAimbotGUI
