
--[[ this adds a baseplate right above the spot in the void that kills you ]]


local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Configuration
local CONFIG = {
    platformHeight = -450,
    platformSize = Vector3.new(2048, 1, 2048),
    followPlayer = true,
    visualize = false -- Set to true to see the platform
}

-- Create safety platform
local safetyPart = Instance.new("Part")
safetyPart.Name = "AntiVoidPlatform"
safetyPart.Size = CONFIG.platformSize
safetyPart.Anchored = true
safetyPart.CanCollide = true
safetyPart.Transparency = CONFIG.visualize and 0.5 or 1
safetyPart.Material = Enum.Material.Neon
safetyPart.BrickColor = BrickColor.new("Bright blue")
safetyPart.Parent = workspace
safetyPart.Position = Vector3.new(0, CONFIG.platformHeight, 0)

-- Teleport to platform function
local function teleportToPlatform()
    if character and humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(safetyPart.Position + Vector3.new(0, 10, 0))
        print("Teleported to platform")
    end
end

-- Set spawn location function
local function setSpawnAtPlatform()
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "VoidSpawn"
    spawnLocation.Size = Vector3.new(10, 1, 10)
    spawnLocation.Anchored = true
    spawnLocation.CanCollide = true
    spawnLocation.Transparency = 0.3
    spawnLocation.BrickColor = BrickColor.new("Lime green")
    spawnLocation.Parent = workspace
    spawnLocation.Position = safetyPart.Position + Vector3.new(0, 5, 0)
    spawnLocation.Duration = 0
    print("Spawn location created at platform")
    return spawnLocation
end

-- Platform following logic
if CONFIG.followPlayer then
    game:GetService("RunService").Heartbeat:Connect(function()
        if character and humanoidRootPart then
            safetyPart.Position = Vector3.new(
                humanoidRootPart.Position.X, 
                CONFIG.platformHeight, 
                humanoidRootPart.Position.Z
            )
        end
    end)
end

-- Keybind setup (optional)
local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.V then -- Press V to teleport
        teleportToPlatform()
    elseif input.KeyCode == Enum.KeyCode.B then -- Press B to toggle visibility
        CONFIG.visualize = not CONFIG.visualize
        safetyPart.Transparency = CONFIG.visualize and 0.5 or 1
        print("Platform visibility:", CONFIG.visualize)
    end
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

print("Anti-Void Platform Active")
print("Press V to teleport to platform")
print("Press B to toggle platform visibility")

-- Optional: Uncomment to create spawn location
setSpawnAtPlatform()
