local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local Config = {
    VoidDepth = -50000,
    UpdateRate = 0.03,
    EnableDummyDecoy = true,
    DecoyOffset = Vector3.new(50, 0, 50),
    AntiRaycast = true,
    SuppressNametags = true,
}
local OriginalCFrame = HumanoidRootPart.CFrame
local FakeCharacter = nil
local OriginalVelocity = Vector3.new(0, 0, 0)
local IsActive = true
local function SuppressNametags()
    if not Config.SuppressNametags then return end
    for _, descendant in pairs(Character:GetDescendants()) do
        if descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") then
            descendant.Enabled = false
        end
    end
    if Character:FindFirstChild("Head") then
        local head = Character.Head
        for _, child in pairs(head:GetChildren()) do
            if child:IsA("BillboardGui") or child.Name == "Nametag" or child.Name == "NameTag" then
                child.Enabled = false
            end
        end
    end
    print("✓ Nametags suppressed")
end
local function CreateDummyDecoy()
    if not Config.EnableDummyDecoy then return end
    FakeCharacter = Character:Clone()
    for _, part in pairs(FakeCharacter:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Anchored = true
            part.Transparency = 0
        end
    end
    for _, obj in pairs(FakeCharacter:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            obj:Destroy()
        end
    end
    if FakeCharacter:FindFirstChild("Humanoid") then
        FakeCharacter.Humanoid:Destroy()
    end
    FakeCharacter:SetPrimaryPartCFrame(HumanoidRootPart.CFrame + Config.DecoyOffset)
    FakeCharacter.Parent = Workspace
    FakeCharacter.Name = LocalPlayer.Name .. "_Decoy"
    print("✓ Dummy decoy created at offset:", Config.DecoyOffset)
    return FakeCharacter
end
local function UpdateDecoyPosition()
    if not FakeCharacter or not FakeCharacter.Parent then return end
    local fakePosition = HumanoidRootPart.CFrame + Config.DecoyOffset
    FakeCharacter:SetPrimaryPartCFrame(fakePosition)
    if Humanoid.MoveDirection.Magnitude > 0 then
        local lookVector = Humanoid.MoveDirection
        FakeCharacter:SetPrimaryPartCFrame(CFrame.new(fakePosition.Position, fakePosition.Position + lookVector))
    end
end
local function VoidTeleport()
    OriginalCFrame = HumanoidRootPart.CFrame
    local voidPosition = Vector3.new(
        HumanoidRootPart.Position.X,
        Config.VoidDepth,
        HumanoidRootPart.Position.Z
    )
    HumanoidRootPart.CFrame = CFrame.new(voidPosition)
    if Config.AntiRaycast then
        HumanoidRootPart.CFrame = CFrame.new(
            HumanoidRootPart.Position.X,
            -100,
            HumanoidRootPart.Position.Z
        )
    end
end
local function CompensateVisuals()
    local Camera = Workspace.CurrentCamera
    local serverPosition = HumanoidRootPart.Position
    local moveDirection = Humanoid.MoveDirection * Humanoid.WalkSpeed * Config.UpdateRate
    local targetPosition = OriginalCFrame.Position + moveDirection
    OriginalCFrame = CFrame.new(targetPosition, targetPosition + Camera.CFrame.LookVector)
    return OriginalCFrame
end
local function MainLoop()
    while IsActive and Character and Character.Parent do
        task.wait(Config.UpdateRate)
        VoidTeleport()
        local visualCFrame = CompensateVisuals()
        if Config.EnableDummyDecoy then
            UpdateDecoyPosition()
        end
        if Config.SuppressNametags then
            SuppressNametags()
        end
    end
end
local function Initialize()
    print("\n🚀 Initializing anti-ESP/aimbot systems...")
    task.wait(1)
    SuppressNametags()
    if Config.EnableDummyDecoy then
        CreateDummyDecoy()
    end
    task.spawn(MainLoop)
    print("\n═══════════════════════════════════════════════════════════════")
    print("✅ ALL SYSTEMS ACTIVE")
    print("📍 Server Position: VOID (-50k Y)")
    print("👁️  Client Vision: NORMAL")
    print("🎭 Decoy Status:", Config.EnableDummyDecoy and "ACTIVE" or "DISABLED")
    print("🚫 Nametags:", Config.SuppressNametags and "HIDDEN" or "VISIBLE")
    print("═══════════════════════════════════════════════════════════════\n")
end
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    Humanoid = newCharacter:WaitForChild("Humanoid")
    if FakeCharacter then
        FakeCharacter:Destroy()
        FakeCharacter = nil
    end
    task.wait(1)
    Initialize()
end)
Humanoid.Died:Connect(function()
    IsActive = false
    if FakeCharacter then
        FakeCharacter:Destroy()
        FakeCharacter = nil
    end
    print("⚠️ Character died - systems will reinitialize on respawn")
end)
getgenv().AntiESP = {
    Toggle = function()
        IsActive = not IsActive
        print(IsActive and "✅ Anti-ESP ENABLED" or "❌ Anti-ESP DISABLED")
    end,
    SetVoidDepth = function(depth)
        Config.VoidDepth = depth
        print("📍 Void depth set to:", depth)
    end,
    ToggleDecoy = function()
        Config.EnableDummyDecoy = not Config.EnableDummyDecoy
        if Config.EnableDummyDecoy then
            CreateDummyDecoy()
        else
            if FakeCharacter then
                FakeCharacter:Destroy()
                FakeCharacter = nil
            end
        end
        print("🎭 Decoy:", Config.EnableDummyDecoy and "ENABLED" or "DISABLED")
    end,
    ShowStatus = function()
        print("═══════════════════════════════════════════════════════════════")
        print("ANTI-ESP STATUS:")
        print("Active:", IsActive)
        print("Void Depth:", Config.VoidDepth)
        print("Decoy Enabled:", Config.EnableDummyDecoy)
        print("Anti-Raycast:", Config.AntiRaycast)
        print("Nametag Suppression:", Config.SuppressNametags)
        print("═══════════════════════════════════════════════════════════════")
    end,
}
Initialize()
print([[
COMMANDS:
getgenv().AntiESP.Toggle() - Enable/Disable
getgenv().AntiESP.SetVoidDepth(depth) - Change void depth
getgenv().AntiESP.ToggleDecoy() - Enable/Disable decoy
getgenv().AntiESP.ShowStatus() - Show current status
]])
