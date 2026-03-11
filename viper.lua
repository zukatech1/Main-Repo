local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local activeRemote = nil
local targets = {
    "ExecuteRemote", "G_Execute", "ServerSide", "RemoteEvent", "DataRemote", 
    "Handshake", "Adonis", "Messaging", "MainRemote", "ControlRemote",
    "Action", "Request", "Communication", "HDAdminRemote", "F3XRemote",
    "Remote", "Event", "Process", "Bridge", "Krypton", "C7RR"
}
local function scan()
    activeRemote = nil
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            for _, name in pairs(targets) do
                if v.Name:lower():match(name:lower()) then
                    local success = pcall(function() 
                        v:FireServer("print('Handshake Attempt')") 
                    end)
                    if success then activeRemote = v return v.Name end
                end
            end
        end
    end
    return "No Backdoor Found"
end
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Sidebar = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local Content = Instance.new("Frame")
local Title = Instance.new("TextLabel")
ScreenGui.Name = "Viper_SS"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Size = UDim2.new(0, 450, 0, 300)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.Size = UDim2.new(0, 100, 1, 0)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
UIListLayout.Parent = Sidebar
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 5)
Title.Parent = MainFrame
Title.Text = "VIPER SS"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 255, 160)
Title.TextSize = 12
Title.Size = UDim2.new(0, 100, 0, 40)
Title.BackgroundTransparency = 1
Content.Name = "Content"
Content.Parent = MainFrame
Content.Position = UDim2.new(0, 110, 0, 10)
Content.Size = UDim2.new(1, -120, 1, -20)
Content.BackgroundTransparency = 1
local ExecPage = Instance.new("Frame", Content)
ExecPage.Size = UDim2.new(1, 0, 1, 0)
ExecPage.BackgroundTransparency = 1
local HubPage = Instance.new("Frame", Content)
HubPage.Size = UDim2.new(1, 0, 1, 0)
HubPage.BackgroundTransparency = 1
HubPage.Visible = false
local CodeBox = Instance.new("TextBox", ExecPage)
CodeBox.Size = UDim2.new(1, 0, 0, 200)
CodeBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
CodeBox.TextColor3 = Color3.fromRGB(200, 200, 200)
CodeBox.Font = Enum.Font.Code
CodeBox.Text = "-- Server Side Lua here"
CodeBox.TextYAlignment = Enum.TextYAlignment.Top
CodeBox.MultiLine = true
CodeBox.ClearTextOnFocus = false
Instance.new("UICorner", CodeBox)
local ExecBtn = Instance.new("TextButton", ExecPage)
ExecBtn.Size = UDim2.new(1, 0, 0, 35)
ExecBtn.Position = UDim2.new(0, 0, 1, -35)
ExecBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
ExecBtn.Text = "Execute"
ExecBtn.Font = Enum.Font.GothamBold
ExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", ExecBtn)
local HubList = Instance.new("UIListLayout", HubPage)
HubList.Padding = UDim.new(0, 5)
local function QuickScript(name, code)
    local btn = Instance.new("TextButton", HubPage)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        if activeRemote then
            activeRemote:FireServer(code)
        end
    end)
end
QuickScript("FE Kill All", [[for _,v in pairs(game.Players:GetPlayers()) do v.Character.Humanoid.Health = 0 end]])
QuickScript("Give F3X Btools", [[local b = Instance.new("HopperBin", game.Players:FindFirstChild("]]..lp.Name..[[").Backpack) b.BinType = 4]])
QuickScript("SS Flight (Click to Toggle)", [[
    local p = game.Players:FindFirstChild("]]..lp.Name..[[")
    local char = p.Character
    if char:FindFirstChild("ViperFly") then char.ViperFly:Destroy() else
        local bg = Instance.new("BodyGyro", char.HumanoidRootPart)
        bg.Name = "ViperFly"
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = char.HumanoidRootPart.CFrame
        local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
        bv.Name = "ViperFlyVel"
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.velocity = Vector3.new(0,0.1,0)
    end
]])
QuickScript("Load Infinite Yield", [[require(3006154415):Fire("]]..lp.Name..[[")]])
local function NavBtn(text, page)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0, 80, 0, 30)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
    btn.TextSize = 13
    btn.MouseButton1Click:Connect(function()
        ExecPage.Visible = false
        HubPage.Visible = false
        page.Visible = true
    end)
end
NavBtn("Executor", ExecPage)
NavBtn("Script Hub", HubPage)
local ScanBtn = Instance.new("TextButton", Sidebar)
ScanBtn.Size = UDim2.new(0, 80, 0, 30)
ScanBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
ScanBtn.Text = "RE-SCAN"
ScanBtn.Font = Enum.Font.GothamBold
ScanBtn.TextColor3 = Color3.fromRGB(255,255,255)
ScanBtn.TextSize = 10
Instance.new("UICorner", ScanBtn)
ExecBtn.MouseButton1Click:Connect(function()
    if activeRemote then
        activeRemote:FireServer(CodeBox.Text)
    end
end)
ScanBtn.MouseButton1Click:Connect(function()
    ScanBtn.Text = "SCANNING..."
    local res = scan()
    ScanBtn.Text = "FOUND: " .. res
end)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)
local dragStart, startPos, dragging
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
print("Viper SS Loaded. Keybind: RightShift")
scan()
