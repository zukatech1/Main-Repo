local CFrameDesync = {
    State = {
        IsEnabled      = false,
        DesyncActive   = false,
        RealCFrame     = CFrame.new(),
        VisualOffset   = CFrame.new(),
        UI             = nil,
        Mode           = "position",
        Increment      = 1,
        Connections    = {},
        FakeCharacter  = nil,
        GhostHighlight = nil,
        PinnedParts    = {},
    },
    Config = {
        HighlightColor    = Color3.fromRGB(255, 0, 200),
        PinnedColor       = Color3.fromRGB(0, 220, 255),
        ShowFakeCharacter = true,
    },
}
local PART_GROUPS = {
    { label = "HEAD",      parts = { "Head" } },
    { label = "TORSO",     parts = { "UpperTorso", "LowerTorso", "Torso" } },
    { label = "LEFT ARM",  parts = { "LeftUpperArm", "LeftLowerArm", "LeftHand", "Left Arm" } },
    { label = "RIGHT ARM", parts = { "RightUpperArm", "RightLowerArm", "RightHand", "Right Arm" } },
    { label = "LEFT LEG",  parts = { "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Left Leg" } },
    { label = "RIGHT LEG", parts = { "RightUpperLeg", "RightLowerLeg", "RightFoot", "Right Leg" } },
}
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local function getChar()
    local char = LocalPlayer.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChild("Humanoid")
    return char, hrp, hum
end
local function isPinned(self, partName)
    return self.State.PinnedParts[partName] == true
end
function CFrameDesync:ActivateDesync()
    local char, hrp = getChar()
    if not hrp then warn("[CFrameDesync] No character.") return end
    self.State.DesyncActive = true
    self.State.RealCFrame   = hrp.CFrame
    if self.Config.ShowFakeCharacter then
        self:CreateFakeCharacter()
    end
    self.State.Connections.Heartbeat = RunService.Heartbeat:Connect(function()
        local _, root = getChar()
        if not root then return end
        self.State.RealCFrame = root.CFrame
        local rotOnly = CFrame.fromMatrix(
            Vector3.zero,
            self.State.VisualOffset.RightVector,
            self.State.VisualOffset.UpVector,
            -self.State.VisualOffset.LookVector
        )
        local spoof = CFrame.new(root.CFrame.Position + self.State.VisualOffset.Position)
                    * CFrame.fromMatrix(Vector3.zero, root.CFrame.RightVector, root.CFrame.UpVector, -root.CFrame.LookVector)
                    * rotOnly
        root.CFrame = spoof
    end)
    self.State.Connections.RenderStepped = RunService.RenderStepped:Connect(function()
        local _, root = getChar()
        if not root then return end
        root.CFrame = self.State.RealCFrame
        self:UpdateVisuals()
    end)
    local camera = workspace.CurrentCamera
    local savedCameraType = camera.CameraType
    camera.CameraType = Enum.CameraType.Custom
    self.State.SavedCameraType = savedCameraType
    local camAnchor = Instance.new("Part")
    camAnchor.Name        = "DesyncCamAnchor"
    camAnchor.Size        = Vector3.new(0.1, 0.1, 0.1)
    camAnchor.Transparency = 1
    camAnchor.CanCollide  = false
    camAnchor.CanTouch    = false
    camAnchor.CanQuery    = false
    camAnchor.Anchored    = true
    camAnchor.CFrame      = self.State.RealCFrame
    camAnchor.Parent      = workspace
    self.State.CamAnchor  = camAnchor
    camera.CameraSubject  = camAnchor
    self.State.Connections.CamAnchor = RunService.RenderStepped:Connect(function()
        if camAnchor and camAnchor.Parent then
            camAnchor.CFrame = self.State.RealCFrame
        end
    end)
    local ui = self.State.UI.MainFrame
    ui.Content.DesyncToggle.Text             = "DEACTIVATE DESYNC"
    ui.Content.DesyncToggle.BackgroundColor3 = Color3.fromRGB(110, 25, 45)
    ui.TitleBar.StatusIndicator.Text             = "ONLINE"
    ui.TitleBar.StatusIndicator.BackgroundColor3 = self.Config.HighlightColor
    ui.TitleBar.StatusIndicator.TextColor3       = Color3.fromRGB(10, 10, 20)
    self:UpdateDisplay()
end
function CFrameDesync:DeactivateDesync()
    self.State.DesyncActive = false
    for _, conn in pairs(self.State.Connections) do conn:Disconnect() end
    table.clear(self.State.Connections)
    if self.State.FakeCharacter then
        self.State.FakeCharacter:Destroy()
        self.State.FakeCharacter  = nil
        self.State.GhostHighlight = nil
    end
    local camera = workspace.CurrentCamera
    local char, hrp = getChar()
    if hrp then
        camera.CameraSubject = hrp
    elseif char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then camera.CameraSubject = hum end
    end
    if self.State.CamAnchor then
        self.State.CamAnchor:Destroy()
        self.State.CamAnchor = nil
    end
    if not self.State.UI then return end
    local ui = self.State.UI.MainFrame
    ui.Content.DesyncToggle.Text             = "ACTIVATE DESYNC"
    ui.Content.DesyncToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    ui.TitleBar.StatusIndicator.Text             = "OFFLINE"
    ui.TitleBar.StatusIndicator.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    ui.TitleBar.StatusIndicator.TextColor3       = Color3.fromRGB(160, 160, 160)
    self:UpdateDisplay()
end
function CFrameDesync:ToggleDesync()
    if self.State.DesyncActive then self:DeactivateDesync() else self:ActivateDesync() end
end
function CFrameDesync:CreateFakeCharacter()
    local char = LocalPlayer.Character
    if not char then return end
    local fake = Instance.new("Model")
    fake.Name = "Desync_Visualizer"
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local p = part:Clone()
            p.CanCollide  = false
            p.CanTouch    = false
            p.CanQuery    = false
            p.CastShadow  = false
            p.Material    = Enum.Material.Neon
            p.Transparency = isPinned(self, part.Name) and 0.45 or 0.2
            p.Color       = isPinned(self, part.Name)
                and self.Config.PinnedColor or self.Config.HighlightColor
            p.Parent = fake
            for _, child in pairs(p:GetChildren()) do
                if not child:IsA("SpecialMesh") then child:Destroy() end
            end
        end
    end
    local hl = Instance.new("Highlight", fake)
    hl.FillColor           = self.Config.HighlightColor
    hl.OutlineColor        = Color3.new(1, 1, 1)
    hl.FillTransparency    = 0.4
    hl.OutlineTransparency = 0.0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    self.State.GhostHighlight = hl
    fake.Parent = workspace
    self.State.FakeCharacter = fake
end
function CFrameDesync:_refreshFakeCharacterColors()
    if not self.State.FakeCharacter then return end
    for _, part in pairs(self.State.FakeCharacter:GetChildren()) do
        if part:IsA("BasePart") then
            local pinned = isPinned(self, part.Name)
            part.Color        = pinned and self.Config.PinnedColor or self.Config.HighlightColor
            part.Transparency = pinned and 0.45 or 0.2
        end
    end
    if self.State.GhostHighlight then
        self.State.GhostHighlight.FillColor = self.Config.HighlightColor
    end
end
function CFrameDesync:UpdateVisuals()
    local char = LocalPlayer.Character
    if not char or not self.State.FakeCharacter then return end
    local realHRP = char:FindFirstChild("HumanoidRootPart")
    if not realHRP then return end
    local rotOnly = CFrame.fromMatrix(
        Vector3.zero,
        self.State.VisualOffset.RightVector,
        self.State.VisualOffset.UpVector,
        -self.State.VisualOffset.LookVector
    )
    local spoof = CFrame.new(self.State.RealCFrame.Position + self.State.VisualOffset.Position)
                * CFrame.fromMatrix(Vector3.zero,
                    self.State.RealCFrame.RightVector,
                    self.State.RealCFrame.UpVector,
                    -self.State.RealCFrame.LookVector)
                * rotOnly
    for _, part in pairs(self.State.FakeCharacter:GetChildren()) do
        if part:IsA("BasePart") then
            local realPart = char:FindFirstChild(part.Name)
            if realPart then
                local relative = realHRP.CFrame:Inverse() * realPart.CFrame
                if isPinned(self, part.Name) then
                    part.CFrame = self.State.RealCFrame * relative
                else
                    part.CFrame = spoof * relative
                end
            end
        end
    end
end
function CFrameDesync:AdjustOffset(vec)
    local inc = self.State.Increment
    if self.State.Mode == "position" then
        local cur = self.State.VisualOffset.Position
        self.State.VisualOffset = CFrame.new(cur + vec * inc)
    else
        local r = vec * math.rad(inc * 5)
        self.State.VisualOffset = self.State.VisualOffset * CFrame.Angles(r.X, r.Y, r.Z)
    end
    self:UpdateDisplay()
end
function CFrameDesync:UpdateDisplay()
    if not self.State.UI then return end
    local info = self.State.UI.MainFrame.Content.InfoBox
    if not info then return end
    if not self.State.DesyncActive then
        info.Text = "STATUS: INACTIVE\nAWAITING ACTIVATION..."
        return
    end
    local pinnedCount = 0
    for _, v in pairs(self.State.PinnedParts) do if v then pinnedCount += 1 end end
    local pos = self.State.VisualOffset.Position
    local rx, ry, rz = self.State.VisualOffset:ToEulerAnglesXYZ()
    info.Text = string.format(
        "STATUS: DESYNCED  |  PINNED: %d PARTS\n\nSPOOF OFFSET:\n  X: %.2f  |  Y: %.2f  |  Z: %.2f\n\nROT OFFSET:\n  X: %.1f\xc2\xb0  |  Y: %.1f\xc2\xb0  |  Z: %.1f\xc2\xb0",
        pinnedCount, pos.X, pos.Y, pos.Z,
        math.deg(rx), math.deg(ry), math.deg(rz)
    )
end
function CFrameDesync:_createUI()
    local existing = CoreGui:FindFirstChild("CFrameDesync_SA")
    if existing then existing:Destroy() end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "CFrameDesync_SA"
    screenGui.ResetOnSpawn   = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.DisplayOrder   = 9999
    self.State.UI = screenGui
    local mainFrame = Instance.new("Frame")
    mainFrame.Name             = "MainFrame"
    mainFrame.Size             = UDim2.fromOffset(360, 640)
    mainFrame.Position         = UDim2.new(1, -375, 0.5, -320)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    mainFrame.BorderSizePixel  = 0
    mainFrame.ClipsDescendants = false
    mainFrame.Parent           = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", mainFrame)
    stroke.Color = self.Config.HighlightColor; stroke.Thickness = 1.5
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Name = "TitleBar"; titleBar.Size = UDim2.new(1,0,0,38)
    titleBar.BackgroundColor3 = Color3.fromRGB(8,8,14); titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,10)
    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1,-110,1,0); title.Position = UDim2.fromOffset(12,0)
    title.BackgroundTransparency = 1; title.Font = Enum.Font.Code
    title.Text = "▸ CFRAME DESYNC  //  STANDALONE"
    title.TextColor3 = self.Config.HighlightColor; title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    local si = Instance.new("TextLabel", titleBar)
    si.Name = "StatusIndicator"; si.Size = UDim2.fromOffset(70,20)
    si.Position = UDim2.new(1,-82,0.5,-10)
    si.BackgroundColor3 = Color3.fromRGB(35,35,42); si.Font = Enum.Font.GothamBold
    si.Text = "OFFLINE"; si.TextColor3 = Color3.fromRGB(160,160,160); si.TextSize = 10
    Instance.new("UICorner", si).CornerRadius = UDim.new(0,4)
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = inp.Position; startPos = mainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    titleBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    local scroll = Instance.new("ScrollingFrame", mainFrame)
    scroll.Name = "Content"; scroll.Size = UDim2.new(1,-16,1,-48)
    scroll.Position = UDim2.fromOffset(8,44); scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = self.Config.HighlightColor
    scroll.CanvasSize = UDim2.fromOffset(0,0); scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0,8); layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    local function sectionLabel(text, order)
        local l = Instance.new("TextLabel", scroll)
        l.LayoutOrder = order; l.Size = UDim2.new(1,-8,0,18)
        l.BackgroundTransparency = 1; l.Text = text
        l.TextColor3 = Color3.fromRGB(130,130,150); l.Font = Enum.Font.Code
        l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left
    end
    local function bigBtn(text, color, order, name)
        local b = Instance.new("TextButton", scroll)
        b.LayoutOrder = order; b.Size = UDim2.new(1,-8,0,40)
        b.BackgroundColor3 = color; b.Font = Enum.Font.GothamBold
        b.Text = text; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 13
        b.BorderSizePixel = 0; if name then b.Name = name end
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
        return b
    end
    local tog = bigBtn("ACTIVATE DESYNC", Color3.fromRGB(35,35,50), 10, "DesyncToggle")
    local ts = Instance.new("UIStroke", tog); ts.Color = self.Config.HighlightColor; ts.Thickness = 1
    tog.MouseButton1Click:Connect(function() self:ToggleDesync() end)
    sectionLabel("MANIPULATION MODE", 20)
    local modeRow = Instance.new("Frame", scroll)
    modeRow.LayoutOrder = 21; modeRow.Size = UDim2.new(1,-8,0,34); modeRow.BackgroundTransparency = 1
    local ml = Instance.new("UIListLayout", modeRow); ml.FillDirection = Enum.FillDirection.Horizontal; ml.Padding = UDim.new(0,6)
    local modeButtons = {}
    for _, mode in ipairs({"POSITION","ROTATION"}) do
        local b = Instance.new("TextButton", modeRow)
        b.Size = UDim2.new(0.5,-3,1,0)
        b.BackgroundColor3 = (mode:lower()==self.State.Mode) and self.Config.HighlightColor or Color3.fromRGB(28,28,38)
        b.Font = Enum.Font.GothamBold; b.Text = mode; b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 12; b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
        modeButtons[mode:lower()] = b
        b.MouseButton1Click:Connect(function()
            self.State.Mode = mode:lower()
            for m, btn in pairs(modeButtons) do
                btn.BackgroundColor3 = m==self.State.Mode and self.Config.HighlightColor or Color3.fromRGB(28,28,38)
            end
        end)
    end
    sectionLabel("INCREMENT VALUE", 30)
    local inc = Instance.new("TextBox", scroll)
    inc.LayoutOrder = 31; inc.Size = UDim2.new(1,-8,0,34)
    inc.BackgroundColor3 = Color3.fromRGB(18,18,26); inc.Text = "1"
    inc.TextColor3 = Color3.new(1,1,1); inc.Font = Enum.Font.Code; inc.TextSize = 13
    inc.PlaceholderText = "Enter increment..."; inc.PlaceholderColor3 = Color3.fromRGB(80,80,100)
    inc.BorderSizePixel = 0
    Instance.new("UICorner", inc).CornerRadius = UDim.new(0,5)
    Instance.new("UIStroke", inc).Color = Color3.fromRGB(40,40,55)
    inc.FocusLost:Connect(function()
        local v = tonumber(inc.Text)
        if v and v > 0 then self.State.Increment = v else inc.Text = tostring(self.State.Increment) end
    end)
    sectionLabel("SPOOF OFFSET CONTROLS", 40)
    local grid = Instance.new("Frame", scroll)
    grid.LayoutOrder = 41; grid.Size = UDim2.new(1,-8,0,76); grid.BackgroundTransparency = 1
    local axes = {
        {t="+X",o=Vector3.new(1,0,0)},{t="-X",o=Vector3.new(-1,0,0)},
        {t="+Y",o=Vector3.new(0,1,0)},{t="-Y",o=Vector3.new(0,-1,0)},
        {t="+Z",o=Vector3.new(0,0,1)},{t="-Z",o=Vector3.new(0,0,-1)},
    }
    local axColors = {
        Color3.fromRGB(180,60,60),Color3.fromRGB(130,30,30),
        Color3.fromRGB(60,180,60),Color3.fromRGB(30,130,30),
        Color3.fromRGB(60,60,180),Color3.fromRGB(30,30,130),
    }
    for i, ax in ipairs(axes) do
        local c=(i-1)%3; local r=math.floor((i-1)/3)
        local b = Instance.new("TextButton", grid)
        b.Size = UDim2.fromOffset(106,34); b.Position = UDim2.fromOffset(c*112, r*40)
        b.BackgroundColor3 = axColors[i]; b.Font = Enum.Font.GothamBold
        b.Text = ax.t; b.TextColor3 = Color3.new(1,1,1); b.TextSize = 13; b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
        local vec = ax.o
        b.MouseButton1Click:Connect(function() self:AdjustOffset(vec) end)
    end
    local rst = bigBtn("↺  RESET OFFSET", Color3.fromRGB(70,30,30), 50)
    rst.MouseButton1Click:Connect(function()
        self.State.VisualOffset = CFrame.new(); self:UpdateDisplay()
    end)
    sectionLabel("PART PIN CONTROL  (CYAN = PINNED / STAYS AT REAL POS IN GHOST)", 60)
    local pinButtons = {}
    for gi, group in ipairs(PART_GROUPS) do
        local row = Instance.new("Frame", scroll)
        row.LayoutOrder = 60+gi; row.Size = UDim2.new(1,-8,0,34); row.BackgroundTransparency = 1
        local rl = Instance.new("UIListLayout", row)
        rl.FillDirection = Enum.FillDirection.Horizontal; rl.Padding = UDim.new(0,6)
        rl.VerticalAlignment = Enum.VerticalAlignment.Center
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(0.42,0,1,0); lbl.BackgroundTransparency = 1
        lbl.Text = group.label; lbl.Font = Enum.Font.Code
        lbl.TextColor3 = Color3.fromRGB(200,200,210); lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local pb = Instance.new("TextButton", row)
        pb.Size = UDim2.new(0.58,-6,0.9,0); pb.BackgroundColor3 = Color3.fromRGB(28,28,38)
        pb.Font = Enum.Font.GothamBold; pb.Text = "FREE"
        pb.TextColor3 = Color3.fromRGB(160,160,170); pb.TextSize = 11; pb.BorderSizePixel = 0
        Instance.new("UICorner", pb).CornerRadius = UDim.new(0,5)
        pinButtons[gi] = {btn=pb, group=group}
        local function refreshBtn(pinned)
            if pinned then
                pb.BackgroundColor3 = self.Config.PinnedColor
                pb.TextColor3 = Color3.fromRGB(5,5,15); pb.Text = "PINNED"
            else
                pb.BackgroundColor3 = Color3.fromRGB(28,28,38)
                pb.TextColor3 = Color3.fromRGB(160,160,170); pb.Text = "FREE"
            end
        end
        local function groupPinned()
            for _, p in ipairs(group.parts) do if not self.State.PinnedParts[p] then return false end end
            return true
        end
        refreshBtn(groupPinned())
        pb.MouseButton1Click:Connect(function()
            local now = groupPinned()
            for _, p in ipairs(group.parts) do self.State.PinnedParts[p] = not now end
            refreshBtn(not now)
            if self.State.FakeCharacter then self:_refreshFakeCharacterColors() end
        end)
    end
    sectionLabel("QUICK PRESETS", 80)
    local presetRow = Instance.new("Frame", scroll)
    presetRow.LayoutOrder = 81; presetRow.Size = UDim2.new(1,-8,0,34); presetRow.BackgroundTransparency = 1
    local pl = Instance.new("UIListLayout", presetRow); pl.FillDirection = Enum.FillDirection.Horizontal; pl.Padding = UDim.new(0,6)
    local presets = {
        {label="PIN ARMS", pinned={["LEFT ARM"]=true,["RIGHT ARM"]=true}},
        {label="PIN LEGS", pinned={["LEFT LEG"]=true,["RIGHT LEG"]=true}},
        {label="ALL FREE", pinned={}},
        {label="ALL PIN",  pinned={["HEAD"]=true,["TORSO"]=true,["LEFT ARM"]=true,["RIGHT ARM"]=true,["LEFT LEG"]=true,["RIGHT LEG"]=true}},
    }
    for _, preset in ipairs(presets) do
        local pb = Instance.new("TextButton", presetRow)
        pb.Size = UDim2.new(0.25,-5,1,0); pb.BackgroundColor3 = Color3.fromRGB(22,22,32)
        pb.Font = Enum.Font.GothamBold; pb.Text = preset.label
        pb.TextColor3 = Color3.fromRGB(180,180,200); pb.TextSize = 9; pb.BorderSizePixel = 0
        Instance.new("UICorner", pb).CornerRadius = UDim.new(0,5)
        Instance.new("UIStroke", pb).Color = Color3.fromRGB(50,50,70)
        local cap = preset.pinned
        pb.MouseButton1Click:Connect(function()
            self.State.PinnedParts = {}
            for _, group in ipairs(PART_GROUPS) do
                for _, p in ipairs(group.parts) do
                    self.State.PinnedParts[p] = cap[group.label] or false
                end
            end
            for _, info in ipairs(pinButtons) do
                local all = true
                for _, p in ipairs(info.group.parts) do if not self.State.PinnedParts[p] then all=false; break end end
                if all then
                    info.btn.BackgroundColor3 = self.Config.PinnedColor
                    info.btn.TextColor3 = Color3.fromRGB(5,5,15); info.btn.Text = "PINNED"
                else
                    info.btn.BackgroundColor3 = Color3.fromRGB(28,28,38)
                    info.btn.TextColor3 = Color3.fromRGB(160,160,170); info.btn.Text = "FREE"
                end
            end
            if self.State.FakeCharacter then self:_refreshFakeCharacterColors() end
        end)
    end
    sectionLabel("LIVE STATUS", 90)
    local infoBox = Instance.new("TextLabel", scroll)
    infoBox.Name = "InfoBox"; infoBox.LayoutOrder = 91; infoBox.Size = UDim2.new(1,-8,0,110)
    infoBox.BackgroundColor3 = Color3.fromRGB(8,8,14); infoBox.Font = Enum.Font.Code
    infoBox.Text = "STATUS: IDLE\nAWAITING ACTIVATION..."
    infoBox.TextColor3 = self.Config.HighlightColor; infoBox.TextSize = 11
    infoBox.TextXAlignment = Enum.TextXAlignment.Left; infoBox.TextYAlignment = Enum.TextYAlignment.Top
    infoBox.BorderSizePixel = 0; infoBox.TextWrapped = true
    Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0,6)
    Instance.new("UIStroke", infoBox).Color = Color3.fromRGB(30,30,45)
    local ip = Instance.new("UIPadding", infoBox)
    ip.PaddingLeft = UDim.new(0,8); ip.PaddingTop = UDim.new(0,6); ip.PaddingBottom = UDim.new(0,6)
    local spacer = Instance.new("Frame", scroll)
    spacer.LayoutOrder = 99; spacer.Size = UDim2.new(1,0,0,6); spacer.BackgroundTransparency = 1
    screenGui.Parent = CoreGui
end
function CFrameDesync:Enable()
    if self.State.IsEnabled then return end
    self.State.IsEnabled = true
    self:_createUI()
end
function CFrameDesync:Disable()
    self:DeactivateDesync()
    if self.State.UI then self.State.UI:Destroy(); self.State.UI = nil end
    self.State.IsEnabled = false
end
function CFrameDesync:Toggle()
    if self.State.IsEnabled then self:Disable() else self:Enable() end
end
CFrameDesync:Enable()
return CFrameDesync
