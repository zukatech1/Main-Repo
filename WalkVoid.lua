
--[[ this adds a baseplate right above the spot in the void that kills you ]]


local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local safetyPart = Instance.new("Part")
safetyPart.Name = "AntiVoidPlatform"
safetyPart.Size = Vector3.new(2048, 1, 2048) -- Huge platform
safetyPart.Anchored = true
safetyPart.CanCollide = true
safetyPart.Transparency = 0.8
safetyPart.Material = Enum.Material.Neon
safetyPart.BrickColor = BrickColor.new("Bright blue")
safetyPart.Parent = workspace
safetyPart.Position = Vector3.new(0, -450, 0)
game:GetService("RunService").Heartbeat:Connect(function()
    if character and humanoidRootPart then
        safetyPart.Position = Vector3.new(humanoidRootPart.Position.X, -450, humanoidRootPart.Position.Z)
    end
end)
print("Walk-Void")
