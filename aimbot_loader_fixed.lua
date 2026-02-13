local function loadAimbotGUI(args)
	local CoreGui = game:GetService("CoreGui")
	local Players = game:GetService("Players")
	
	local GUI_NAME = "EnhancedAimbotSuite"
	
	-- Check if already open
	if CoreGui:FindFirstChild(GUI_NAME) and not args then
		if DoNotif then
			DoNotif("Aimbot GUI is already open.", 2)
		else
			warn("Aimbot GUI is already open.")
		end
		return
	end
	
	-- Clean up old instance if reloading
	if CoreGui:FindFirstChild(GUI_NAME) then
		CoreGui[GUI_NAME]:Destroy()
	end
	
	local success, err = pcall(function()
		-- Load Luna UI Library
		local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/main/source.lua"))()
		
		-- Load Aimbot System (core logic)
		local AimbotSystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/gaminghcairimproved.lua"))()
		
		-- Load Luna GUI
		local AimbotGUILuna = loadstring(game:HttpGet("https://raw.githubusercontent.com/zukatech1/Main-Repo/refs/heads/main/aimbot_gui_luna.lua"))()
		
		-- Initialize aimbot system
		local aimbot = AimbotSystem.new()
		
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
		
		-- Initialize and build GUI
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
			Title = "Gaming Chair Loaded",
			Content = "Enhanced Aimbot Suite ready!",
			Duration = 3
		})
	end)
	
	if not success then
		warn("Failed to load Enhanced Aimbot:", err)
		
		-- Fallback notification
		if DoNotif then
			DoNotif("Error loading Aimbot: " .. tostring(err), 5)
		else
			warn("Error loading Aimbot: " .. tostring(err))
		end
		
		local gui = CoreGui:FindFirstChild(GUI_NAME)
		if gui then
			gui:Destroy()
		end
	end
end

-- Command registration (if using a command system)
if RegisterCommand then
	RegisterCommand({
		Name = "aimbot",
		Aliases = {"aim", "gc"},
		Description = "Loads the enhanced aimbot GUI. Optional: [player name] to lock target."
	}, function(args)
		if not game:GetService("CoreGui"):FindFirstChild("EnhancedAimbotSuite") then
			local target = args and args[1]
			loadAimbotGUI(target and {targetPlayer = target} or nil)
		else
			if args and args[1] then
				if DoNotif then
					DoNotif("Aimbot is already open. Close and reopen to set a target.", 4)
				end
			else
				if DoNotif then
					DoNotif("Aimbot GUI is already open.", 2)
				end
			end
		end
	end)
end

-- Return loader function for external use
return loadAimbotGUI
