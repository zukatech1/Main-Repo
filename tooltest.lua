do
    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService     = game:GetService("TweenService")
    local LocalPlayer      = Players.LocalPlayer
    local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")
    local TARGET_ANIM_ID   = "rbxassetid://96221947062314"
    local M1_INTERVAL      = 0
    local _animLockEnabled = false
    local _m1SpamEnabled   = false
    local _namecallHook    = nil
    local _m1Conn          = nil
    local _swappedTracks   = {}
    local _loadedAnims     = {}
    local function getCharAnimator()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        return hum:FindFirstChildOfClass("Animator")
    end
    local function isOurAnimator(obj)
        local animator = getCharAnimator()
        return animator and rawequal(obj, animator)
    end
    local function patchAnimObject(anim)
        if not anim or not anim:IsA("Animation") then return end
        if _loadedAnims[anim] then return end
        _loadedAnims[anim] = anim.AnimationId
        pcall(function() anim.AnimationId = TARGET_ANIM_ID end)
    end
    local function enableAnimLock()
        if _namecallHook then return end
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "LoadAnimation" and isOurAnimator(self) then
                local animObj = select(1, ...)
                if animObj and typeof(animObj) == "Instance" and animObj:IsA("Animation") then
                    patchAnimObject(animObj)
                    local track = oldNamecall(self, ...)
                    if track then _swappedTracks[track] = animObj.AnimationId end
                    return track
                end
            end
            if method == "Play" and typeof(self) == "Instance" and self.ClassName == "AnimationTrack" then
                local animator = getCharAnimator()
                if animator then
                    pcall(function()
                        if self.Animation and self.Animation.AnimationId ~= TARGET_ANIM_ID then
                            local swapAnim = Instance.new("Animation")
                            swapAnim.AnimationId = TARGET_ANIM_ID
                            local newTrack = animator:LoadAnimation(swapAnim)
                            local result = oldNamecall(self, ...)
                            newTrack:Play()
                            return result
                        end
                    end)
                end
            end
            return oldNamecall(self, ...)
        end))
        _namecallHook = oldNamecall
        task.spawn(function()
            local animator = getCharAnimator()
            if not animator then return end
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function()
                    if track.Animation and track.Animation.AnimationId ~= TARGET_ANIM_ID then
                        local swapAnim = Instance.new("Animation")
                        swapAnim.AnimationId = TARGET_ANIM_ID
                        local newTrack = animator:LoadAnimation(swapAnim)
                        newTrack:Play(0, track.Looped and 1 or 0, track.Speed)
                        _swappedTracks[newTrack] = track.Animation.AnimationId
                        track:Stop(0)
                    end
                end)
            end
        end)
        local watchFrame = 0
        RunService.Heartbeat:Connect(function()
            watchFrame += 1
            if watchFrame % 6 ~= 0 then return end
            if not _animLockEnabled then return end
            local animator = getCharAnimator()
            if not animator then return end
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function()
                    if track.Animation and track.Animation.AnimationId ~= TARGET_ANIM_ID then
                        local swapAnim = Instance.new("Animation")
                        swapAnim.AnimationId = TARGET_ANIM_ID
                        local newTrack = animator:LoadAnimation(swapAnim)
                        newTrack:Play(0)
                        _swappedTracks[newTrack] = track.Animation.AnimationId
                        track:Stop(0)
                    end
                end)
            end
        end)
        _animLockEnabled = true
    end
    local function disableAnimLock()
        _animLockEnabled = false
        if _namecallHook then
            pcall(hookmetamethod, game, "__namecall", _namecallHook)
            _namecallHook = nil
        end
        _swappedTracks = {}
        _loadedAnims   = {}
    end
    local function getEquippedTool()
        local char = LocalPlayer.Character
        if not char then return nil end
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then return obj end
        end
        return nil
    end
    local _lastClick = 0
    local function enableM1Spam()
        if _m1Conn then _m1Conn:Disconnect() end
        local mouse = LocalPlayer:GetMouse()
        _m1Conn = RunService.Heartbeat:Connect(function()
            if not _m1SpamEnabled then return end
            local now = tick()
            if now - _lastClick < M1_INTERVAL then return end
            _lastClick = now
            local tool = getEquippedTool()
            if not tool then return end
            pcall(function() tool.Activated:Fire() end)
            pcall(function() mouse:Button1Click() end)
            pcall(function()
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local cd = handle:FindFirstChildOfClass("ClickDetector")
                    if cd and fireclickdetector then fireclickdetector(cd) end
                end
            end)
        end)
    end
    local function disableM1Spam()
        _m1SpamEnabled = false
        if _m1Conn then _m1Conn:Disconnect() _m1Conn = nil end
    end
    local function makeTween(obj, props, t)
        return TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    end
    local oldGui = PlayerGui:FindFirstChild("ToolModGUI")
    if oldGui then oldGui:Destroy() end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name             = "ToolModGUI"
    ScreenGui.ResetOnSpawn     = false
    ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset   = true
    ScreenGui.Parent           = PlayerGui
    local Window = Instance.new("Frame")
    Window.Name            = "Window"
    Window.Size            = UDim2.new(0, 280, 0, 310)
    Window.Position        = UDim2.new(0, 20, 0, 60)
    Window.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent          = ScreenGui
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Window)
    Stroke.Color = Color3.fromRGB(55, 55, 70)
    Stroke.Thickness = 1
    local TitleBar = Instance.new("Frame")
    TitleBar.Size             = UDim2.new(1, 0, 0, 36)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    TitleBar.BorderSizePixel  = 0
    TitleBar.Parent           = Window
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size            = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position        = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font            = Enum.Font.GothamBold
    TitleLabel.TextSize        = 13
    TitleLabel.TextColor3      = Color3.fromRGB(210, 210, 230)
    TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
    TitleLabel.Text            = "⚙  ToolMod"
    TitleLabel.Parent          = TitleBar
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size               = UDim2.new(0, 28, 0, 28)
    MinBtn.Position           = UDim2.new(1, -34, 0, 4)
    MinBtn.BackgroundColor3   = Color3.fromRGB(50, 50, 65)
    MinBtn.BorderSizePixel    = 0
    MinBtn.Font               = Enum.Font.GothamBold
    MinBtn.TextSize           = 14
    MinBtn.TextColor3         = Color3.fromRGB(180, 180, 200)
    MinBtn.Text               = "–"
    MinBtn.Parent             = TitleBar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
    local Body = Instance.new("Frame")
    Body.Name             = "Body"
    Body.Size             = UDim2.new(1, 0, 1, -36)
    Body.Position         = UDim2.new(0, 0, 0, 36)
    Body.BackgroundTransparency = 1
    Body.Parent           = Window
    local Layout = Instance.new("UIListLayout", Body)
    Layout.Padding          = UDim.new(0, 0)
    Layout.SortOrder        = Enum.SortOrder.LayoutOrder
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    local Padding = Instance.new("UIPadding", Body)
    Padding.PaddingLeft   = UDim.new(0, 12)
    Padding.PaddingRight  = UDim.new(0, 12)
    Padding.PaddingTop    = UDim.new(0, 10)
    Padding.PaddingBottom = UDim.new(0, 10)
    local function makeSection(text, order)
        local lbl = Instance.new("TextLabel")
        lbl.Size               = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Font               = Enum.Font.GothamSemibold
        lbl.TextSize           = 10
        lbl.TextColor3         = Color3.fromRGB(100, 100, 130)
        lbl.TextXAlignment     = Enum.TextXAlignment.Left
        lbl.Text               = string.upper(text)
        lbl.LayoutOrder        = order
        lbl.Parent             = Body
        return lbl
    end
    local ACTIVE_COLOR  = Color3.fromRGB(80, 200, 120)
    local INACTIVE_COLOR = Color3.fromRGB(35, 35, 48)
    local ACTIVE_TEXT   = Color3.fromRGB(20, 20, 30)
    local INACTIVE_TEXT = Color3.fromRGB(180, 180, 200)
    local function makeToggle(labelText, order, onToggle)
        local row = Instance.new("Frame")
        row.Size             = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        row.BorderSizePixel  = 0
        row.LayoutOrder      = order
        row.Parent           = Body
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color     = Color3.fromRGB(42, 42, 58)
        rowStroke.Thickness = 1
        local lbl = Instance.new("TextLabel")
        lbl.Size               = UDim2.new(1, -60, 1, 0)
        lbl.Position           = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font               = Enum.Font.Gotham
        lbl.TextSize           = 12
        lbl.TextColor3         = INACTIVE_TEXT
        lbl.TextXAlignment     = Enum.TextXAlignment.Left
        lbl.Text               = labelText
        lbl.Parent             = row
        local pill = Instance.new("Frame")
        pill.Size             = UDim2.new(0, 36, 0, 20)
        pill.Position         = UDim2.new(1, -46, 0.5, -10)
        pill.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        pill.BorderSizePixel  = 0
        pill.Parent           = row
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame")
        knob.Size             = UDim2.new(0, 14, 0, 14)
        knob.Position         = UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(160, 160, 180)
        knob.BorderSizePixel  = 0
        knob.Parent           = pill
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local state = false
        local btn = Instance.new("TextButton")
        btn.Size               = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text               = ""
        btn.Parent             = row
        local function refresh()
            if state then
                makeTween(pill,  {BackgroundColor3 = ACTIVE_COLOR}, 0.2):Play()
                makeTween(knob,  {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255,255,255)}, 0.2):Play()
                makeTween(lbl,   {TextColor3 = Color3.fromRGB(220,220,240)}, 0.15):Play()
            else
                makeTween(pill,  {BackgroundColor3 = Color3.fromRGB(50, 50, 65)}, 0.2):Play()
                makeTween(knob,  {Position = UDim2.new(0, 3, 0.5, -7),   BackgroundColor3 = Color3.fromRGB(160,160,180)}, 0.2):Play()
                makeTween(lbl,   {TextColor3 = INACTIVE_TEXT}, 0.15):Play()
            end
        end
        btn.MouseButton1Click:Connect(function()
            state = not state
            refresh()
            onToggle(state)
        end)
        return { row = row, setState = function(v) state = v refresh() end }
    end
    local function makeInput(placeholder, order, onSubmit)
        local row = Instance.new("Frame")
        row.Size             = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        row.BorderSizePixel  = 0
        row.LayoutOrder      = order
        row.Parent           = Body
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color     = Color3.fromRGB(42, 42, 58)
        rowStroke.Thickness = 1
        local box = Instance.new("TextBox")
        box.Size               = UDim2.new(1, -50, 0, 24)
        box.Position           = UDim2.new(0, 8, 0.5, -12)
        box.BackgroundColor3   = Color3.fromRGB(30, 30, 40)
        box.BorderSizePixel    = 0
        box.Font               = Enum.Font.Code
        box.TextSize           = 11
        box.TextColor3         = Color3.fromRGB(160, 220, 160)
        box.PlaceholderColor3  = Color3.fromRGB(80, 80, 100)
        box.PlaceholderText    = placeholder
        box.Text               = ""
        box.ClearTextOnFocus   = false
        box.Parent             = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        local applyBtn = Instance.new("TextButton")
        applyBtn.Size             = UDim2.new(0, 36, 0, 24)
        applyBtn.Position         = UDim2.new(1, -42, 0.5, -12)
        applyBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 90)
        applyBtn.BorderSizePixel  = 0
        applyBtn.Font             = Enum.Font.GothamBold
        applyBtn.TextSize         = 10
        applyBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        applyBtn.Text             = "SET"
        applyBtn.Parent           = row
        Instance.new("UICorner", applyBtn).CornerRadius = UDim.new(0, 6)
        local function submit()
            if box.Text ~= "" then onSubmit(box.Text) end
        end
        applyBtn.MouseButton1Click:Connect(submit)
        box.FocusLost:Connect(function(enter) if enter then submit() end end)
        return { row = row, box = box }
    end
    local function spacer(h, order)
        local f = Instance.new("Frame")
        f.Size               = UDim2.new(1, 0, 0, h)
        f.BackgroundTransparency = 1
        f.LayoutOrder        = order
        f.Parent             = Body
    end
    makeSection("Animation", 1)
    spacer(4, 2)
    local animToggle = makeToggle("AnimLock", 3, function(on)
        if on then
            if not hookmetamethod or not getnamecallmethod then
                warn("[AnimLock] Missing hookmetamethod/getnamecallmethod")
                return
            end
            enableAnimLock()
        else
            disableAnimLock()
        end
    end)
    spacer(6, 4)
    local animInput = makeInput("rbxassetid://...", 5, function(val)
        TARGET_ANIM_ID = val
        print("[AnimLock] Target ID updated: " .. TARGET_ANIM_ID)
        if _animLockEnabled then
            disableAnimLock()
            task.wait()
            enableAnimLock()
        end
    end)
    spacer(10, 6)
    makeSection("Combat", 7)
    spacer(4, 8)
    local m1Toggle = makeToggle("M1 Spam", 9, function(on)
        _m1SpamEnabled = on
        if on then enableM1Spam() else disableM1Spam() end
    end)
    spacer(6, 10)
    local m1Input = makeInput("interval (secs)  e.g. 0.05", 11, function(val)
        local n = tonumber(val)
        if n then
            M1_INTERVAL = n
            print("[M1Spam] Interval set: " .. n)
        end
    end)
    spacer(8, 12)
    local statusBar = Instance.new("TextLabel")
    statusBar.Size               = UDim2.new(1, 0, 0, 18)
    statusBar.BackgroundTransparency = 1
    statusBar.Font               = Enum.Font.Gotham
    statusBar.TextSize           = 10
    statusBar.TextColor3         = Color3.fromRGB(70, 70, 90)
    statusBar.TextXAlignment     = Enum.TextXAlignment.Left
    statusBar.Text               = "F7 = AnimLock  |  F8 = M1 Spam"
    statusBar.LayoutOrder        = 13
    statusBar.Parent             = Body
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = input.Position
            startPos  = Window.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized
            and UDim2.new(0, 280, 0, 36)
            or  UDim2.new(0, 280, 0, 310)
        makeTween(Window, {Size = targetSize}, 0.22):Play()
        MinBtn.Text = minimized and "+" or "–"
    end)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.F7 then
            local newState = not _animLockEnabled
            animToggle.setState(newState)
            if newState then
                if hookmetamethod and getnamecallmethod then enableAnimLock() end
            else
                disableAnimLock()
            end
        elseif input.KeyCode == Enum.KeyCode.F8 then
            local newState = not _m1SpamEnabled
            m1Toggle.setState(newState)
            _m1SpamEnabled = newState
            if newState then enableM1Spam() else disableM1Spam() end
        end
    end)
    print("[ToolMod] GUI loaded — F7: AnimLock | F8: M1 Spam")
end
