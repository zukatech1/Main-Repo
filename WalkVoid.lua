

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

-- Configuration Table
local CONFIG = {
    platformHeight = Workspace.FallenPartsDestroyHeight + 5, -- Automatically sits just above the kill zone
    followPlayer = true,
    visualize = true,
    size = Vector3.new(2048, 1, 2048),
    color = Color3.fromRGB(0, 170, 255),
    material = Enum.Material.Neon,
    transparency = 0.8
}

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Cleanup existing instances to prevent stacking
local existing = Workspace:FindFirstChild("AntiVoidPlatform")
if existing then existing:Destroy() end
local existingSpawn = Workspace:FindFirstChild("VoidSpawn")
if existingSpawn then existingSpawn:Destroy() end

-- Platform Initialization
local safetyPart = Instance.new("Part")
safetyPart.Name = "AntiVoidPlatform"
safetyPart.Size = CONFIG.size
safetyPart.Anchored = true
safetyPart.CanCollide = true
safetyPart.Transparency = CONFIG.visualize and CONFIG.transparency or 1
safetyPart.Material = CONFIG.material
safetyPart.Color = CONFIG.color
safetyPart.Position = Vector3.new(0, CONFIG.platformHeight, 0)
safetyPart.Parent = Workspace

-- Logic for teleportation
local function teleportToPlatform()
    if character and rootPart then
        -- Teleporting slightly above the part to avoid clipping
        rootPart.CFrame = CFrame.new(safetyPart.Position + Vector3.new(0, 15, 0))
        print("[!] Emergency Teleport Executed")
    end
end

-- Spawn Location Logic
local function setSpawnAtPlatform()
    local spawnLocation = Instance.new("SpawnLocation")
    spawnLocation.Name = "VoidSpawn"
    spawnLocation.Size = Vector3.new(12, 1, 12)
    spawnLocation.Anchored = true
    spawnLocation.CanCollide = true
    spawnLocation.Transparency = 0.5
    spawnLocation.BrickColor = BrickColor.new("Lime green")
    spawnLocation.Position = safetyPart.Position + Vector3.new(0, 2, 0)
    spawnLocation.Duration = 0
    spawnLocation.Parent = Workspace
    print("[+] Respawn Anchor Set at Void Threshold")
    return spawnLocation
end

-- Persistence Loop
RunService.Heartbeat:Connect(function()
    if CONFIG.followPlayer and rootPart and rootPart.Parent then
        -- Keep the platform centered under the player on the X/Z axes
        safetyPart.Position = Vector3.new(
            rootPart.Position.X, 
            CONFIG.platformHeight, 
            rootPart.Position.Z
        )
    end
end)

-- Input Controller
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.V then 
        teleportToPlatform()
    elseif input.KeyCode == Enum.KeyCode.B then 
        CONFIG.visualize = not CONFIG.visualize
        safetyPart.Transparency = CONFIG.visualize and CONFIG.transparency or 1
        print("[?] Visibility Toggled:", CONFIG.visualize)
    end
end)

-- Character Integrity Protocol
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- Execution
setSpawnAtPlatform()

print("-----------------------------------------")
print("CALM ANTI-VOID LOADED")
print("Void Level Detected:", Workspace.FallenPartsDestroyHeight)
print("Hotkey [V]: Teleport to Platform")
print("Hotkey [B]: Toggle Platform Visibility")
print("-----------------------------------------")
