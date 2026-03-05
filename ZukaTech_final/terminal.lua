if getgenv().ZukaTerm_Loaded then
    pcall(function() getgenv().ZukaTerm_GUI:Destroy() end)
    getgenv().ZukaTerm_Loaded = nil
    getgenv().ZukaTerm_GUI = nil
end
getgenv().ZukaTerm_Loaded = true
local Players          = game:GetService("Players")
local UIS              = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local TeleportService  = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting         = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace        = workspace
local LocalPlayer      = Players.LocalPlayer
local Commands = {}
local Prefix   = ";"
local Modules  = {}
local function RegisterCommand(info, func)
    local name = info.Name:lower()
    Commands[name] = { Info = info, Func = func }
    for _, alias in ipairs(info.Aliases or {}) do
        Commands[alias:lower()] = Commands[name]
    end
end
local function Utilities_findPlayer(name)
    name = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then return p end
    end
end
local screen = Instance.new("ScreenGui")
screen.Name = "ZukaTerm"
screen.ResetOnSpawn = false
screen.Parent = game.CoreGui
getgenv().ZukaTerm_GUI = screen
local window = Instance.new("Frame", screen)
window.Size = UDim2.new(0, 640, 0, 420)
window.Position = UDim2.new(0.5, -320, 0.5, -210)
window.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
window.BorderSizePixel = 0
window.Active = true
window.ClipsDescendants = false
local function makeBorder(parent, inset)
    local tl = inset and Color3.fromRGB(128,128,128) or Color3.fromRGB(255,255,255)
    local br = inset and Color3.fromRGB(255,255,255) or Color3.fromRGB(128,128,128)
    local function edge(name, size, pos, color)
        local f = Instance.new("Frame", parent)
        f.Name=name; f.Size=size; f.Position=pos
        f.BackgroundColor3=color; f.BorderSizePixel=0; f.ZIndex=parent.ZIndex+1
        return f
    end
    edge("Top",    UDim2.new(1,0,0,2), UDim2.new(0,0,0,0), tl)
    edge("Left",   UDim2.new(0,2,1,0), UDim2.new(0,0,0,0), tl)
    edge("Bottom", UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2), br)
    edge("Right",  UDim2.new(0,2,1,0), UDim2.new(1,-2,0,0), br)
end
makeBorder(window, false)
local titleBar = Instance.new("Frame", window)
titleBar.Size = UDim2.new(1,-6,0,22)
titleBar.Position = UDim2.new(0,3,0,3)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 2
local titleGrad = Instance.new("UIGradient", titleBar)
titleGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 168)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 132, 208))
}
titleGrad.Rotation = 90
local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1,-72,1,0)
titleLabel.Position = UDim2.new(0,6,0,0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Text = "C:\\ROBLOX\\system32\\cmd.exe"
titleLabel.TextColor3 = Color3.new(1,1,1)
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 3
local function makeTitleBtn(symbol, xOffset, onClick)
    local btn = Instance.new("TextButton", titleBar)
    btn.Size = UDim2.new(0,16,0,16)
    btn.Position = UDim2.new(1, xOffset, 0, 3)
    btn.BackgroundColor3 = Color3.fromRGB(192,192,192)
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = symbol
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.TextSize = 13
    btn.ZIndex = 4
    btn.AutoButtonColor = false
    makeBorder(btn, false)
    btn.MouseButton1Click:Connect(onClick)
    return btn
end
local minimized = false
local minBtn = makeTitleBtn("_", -54, function()
    minimized = not minimized
    if minimized then
        TweenService:Create(window, TweenInfo.new(0.15), {Size=UDim2.new(0,640,0,28)}):Play()
    else
        TweenService:Create(window, TweenInfo.new(0.15), {Size=UDim2.new(0,640,0,420)}):Play()
    end
end)
local maxBtn = makeTitleBtn("□", -36, function()
    TweenService:Create(window, TweenInfo.new(0.15), {
        Size=UDim2.new(0.95,0,0.9,0),
        Position=UDim2.new(0.025,0,0.05,0)
    }):Play()
end)
local closeBtn = makeTitleBtn("×", -18, function()
    pcall(function() screen:Destroy() end)
    getgenv().ZukaTerm_Loaded = nil
    getgenv().ZukaTerm_GUI = nil
end)
closeBtn.TextSize = 15
do
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging=true; dragStart=input.Position; startPos=window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging=false end end) end end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local d = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                         startPos.Y.Scale, startPos.Y.Offset+d.Y) end end)
end
local resizeHandle = Instance.new("Frame", window)
resizeHandle.Size = UDim2.new(0,14,0,14)
resizeHandle.Position = UDim2.new(1,-16,1,-16)
resizeHandle.BackgroundColor3 = Color3.fromRGB(192,192,192)
resizeHandle.BorderSizePixel = 0
resizeHandle.ZIndex = 10
for i=0,2 do
    local line = Instance.new("Frame", resizeHandle)
    line.Size=UDim2.new(0,2,1,-4*i); line.Position=UDim2.new(0,4+(4*i),0,4*i)
    line.BackgroundColor3=Color3.fromRGB(128,128,128); line.BorderSizePixel=0; line.Rotation=45; line.ZIndex=11
end
do
    local resizing, resizeStart, startSize
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing=true; resizeStart=input.Position; startSize=window.Size
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then resizing=false end end) end end)
    UIS.InputChanged:Connect(function(input)
        if resizing and input.UserInputType==Enum.UserInputType.MouseMovement then
            local d = Vector2.new(input.Position.X-resizeStart.X, input.Position.Y-resizeStart.Y)
            window.Size = UDim2.new(0, math.max(400,startSize.X.Offset+d.X),
                                     0, math.max(200,startSize.Y.Offset+d.Y)) end end)
end
local termContainer = Instance.new("Frame", window)
termContainer.Size = UDim2.new(1,-12,1,-34)
termContainer.Position = UDim2.new(0,6,0,28)
termContainer.BackgroundColor3 = Color3.fromRGB(0,0,0)
termContainer.BorderSizePixel = 0
makeBorder(termContainer, true)
local scanlineOverlay = Instance.new("Frame", termContainer)
scanlineOverlay.Size=UDim2.new(1,0,1,0); scanlineOverlay.BackgroundTransparency=1
scanlineOverlay.BorderSizePixel=0; scanlineOverlay.ZIndex=8
for i=0,60 do
    local line = Instance.new("Frame", scanlineOverlay)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,i/60,0)
    line.BackgroundColor3=Color3.fromRGB(0,0,0); line.BackgroundTransparency=0.82; line.BorderSizePixel=0; line.ZIndex=9
end
local animScan = Instance.new("Frame", scanlineOverlay)
animScan.Size=UDim2.new(1,0,0,3); animScan.BackgroundColor3=Color3.fromRGB(0,255,0)
animScan.BackgroundTransparency=0.93; animScan.BorderSizePixel=0; animScan.ZIndex=10
task.spawn(function()
    while task.wait(0.04) do
        if not animScan or not animScan.Parent then break end
        animScan.Position = UDim2.new(0,0,(animScan.Position.Y.Scale+0.02)%1,0)
    end
end)
local outputLog = Instance.new("ScrollingFrame", termContainer)
outputLog.Size = UDim2.new(1,-8,1,-30)
outputLog.Position = UDim2.new(0,4,0,4)
outputLog.BackgroundTransparency = 1
outputLog.BorderSizePixel = 0
outputLog.ScrollBarThickness = 14
outputLog.ScrollBarImageColor3 = Color3.fromRGB(80,80,80)
outputLog.CanvasSize = UDim2.new(0,0,0,0)
outputLog.AutomaticCanvasSize = Enum.AutomaticSize.Y
outputLog.ScrollingDirection = Enum.ScrollingDirection.Y
outputLog.ZIndex = 2
local logLayout = Instance.new("UIListLayout", outputLog)
logLayout.Padding = UDim.new(0,0)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
local inputArea = Instance.new("Frame", termContainer)
inputArea.Size = UDim2.new(1,-8,0,22)
inputArea.Position = UDim2.new(0,4,1,-26)
inputArea.BackgroundTransparency = 1
inputArea.ZIndex = 3
local promptLabel = Instance.new("TextLabel", inputArea)
promptLabel.Size = UDim2.new(0,40,1,0)
promptLabel.BackgroundTransparency = 1
promptLabel.Font = Enum.Font.RobotoMono
promptLabel.Text = "C:\\>"
promptLabel.TextColor3 = Color3.fromRGB(0,255,0)
promptLabel.TextSize = 14
promptLabel.TextXAlignment = Enum.TextXAlignment.Left
promptLabel.ZIndex = 4
local suggestionLabel = Instance.new("TextLabel", inputArea)
suggestionLabel.Name = "Suggestion"
suggestionLabel.Size = UDim2.new(1,-44,1,0)
suggestionLabel.Position = UDim2.new(0,44,0,0)
suggestionLabel.BackgroundTransparency = 1
suggestionLabel.Font = Enum.Font.RobotoMono
suggestionLabel.Text = ""
suggestionLabel.TextColor3 = Color3.fromRGB(0,100,0)
suggestionLabel.TextSize = 14
suggestionLabel.TextXAlignment = Enum.TextXAlignment.Left
suggestionLabel.ZIndex = 3
local inputField = Instance.new("TextBox", inputArea)
inputField.Size = UDim2.new(1,-44,1,0)
inputField.Position = UDim2.new(0,44,0,0)
inputField.BackgroundTransparency = 1
inputField.Font = Enum.Font.RobotoMono
inputField.TextSize = 14
inputField.TextColor3 = Color3.fromRGB(0,255,0)
inputField.Text = ""
inputField.ClearTextOnFocus = false
inputField.PlaceholderText = ""
inputField.ZIndex = 5
local cursor = Instance.new("Frame", inputArea)
cursor.Size = UDim2.new(0,8,0,16)
cursor.Position = UDim2.new(0,44,0,3)
cursor.BackgroundColor3 = Color3.fromRGB(0,255,0)
cursor.BorderSizePixel = 0
cursor.ZIndex = 6
task.spawn(function()
    while task.wait(0.53) do
        if not cursor or not cursor.Parent then break end
        cursor.BackgroundTransparency = inputField:IsFocused() and
            (cursor.BackgroundTransparency == 0 and 1 or 0) or 1
    end
end)
local lineCount = 0
local COLOR = {
    GREEN  = Color3.fromRGB(0,   255, 0),
    LIME   = Color3.fromRGB(0,   200, 80),
    CYAN   = Color3.fromRGB(0,   220, 255),
    YELLOW = Color3.fromRGB(255, 255, 0),
    RED    = Color3.fromRGB(255, 60,  60),
    GRAY   = Color3.fromRGB(150, 150, 150),
    WHITE  = Color3.fromRGB(240, 240, 240),
    ORANGE = Color3.fromRGB(255, 160, 40),
    BLUE   = Color3.fromRGB(80,  160, 255),
}
local function addLine(text, color)
    lineCount = lineCount + 1
    local lbl = Instance.new("TextLabel", outputLog)
    lbl.LayoutOrder = lineCount
    lbl.Size = UDim2.new(1,-8,0,16)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.RobotoMono
    lbl.TextSize = 14
    lbl.TextColor3 = color or COLOR.GREEN
    lbl.Text = text or ""
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 2
    task.defer(function() outputLog.CanvasPosition = Vector2.new(0,math.huge) end)
    return lbl
end
local function addBlank() addLine("") end
local function addHeader(text)
    addLine("  " .. string.rep("═",50), COLOR.CYAN)
    addLine("  " .. text, COLOR.CYAN)
    addLine("  " .. string.rep("═",50), COLOR.CYAN)
end
local function addSuccess(text) addLine("  [OK]  " .. text, COLOR.LIME) end
local function addError(text)   addLine("  [ERR] " .. text, COLOR.RED) end
local function addInfo(text)    addLine("  " .. text, COLOR.GRAY) end
local function addWarn(text)    addLine("  [!]   " .. text, COLOR.YELLOW) end
local function DoNotif(text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title="ZukaTerm", Text=text, Duration=duration or 3}) end)
    addInfo(text)
end
inputField:GetPropertyChangedSignal("Text"):Connect(function()
    local ts = game:GetService("TextService")
    local w = ts:GetTextSize(inputField.Text, 14, Enum.Font.RobotoMono, Vector2.new(10000,20)).X
    cursor.Position = UDim2.new(0, 44+w, 0, 3)
    local partial = inputField.Text:lower():gsub("^%s*;?","")
    if #partial > 0 then
        local best = nil
        for name, entry in pairs(Commands) do
            if name:sub(1,#partial) == partial and entry.Info.Name:lower() == name then
                best = name; break end end
        suggestionLabel.Text = best and (Prefix..best) or ""
    else
        suggestionLabel.Text = "" end
end)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Tab and inputField:IsFocused() then
        local sug = suggestionLabel.Text
        if sug ~= "" then
            inputField.Text = sug
            inputField.CursorPosition = #inputField.Text+1 end end end)
local commandHistory = {}
local historyIdx = 0
local function processCommand(raw)
    local stripped = raw:match("^%s*;?(.-)%s*$") or ""
    if stripped == "" then return true end
    local parts = {}
    for w in stripped:gmatch("%S+") do table.insert(parts,w) end
    local cmdName = parts[1]:lower()
    table.remove(parts, 1)
    if cmdName == "cls" or cmdName == "clear" then
        for _, c in ipairs(outputLog:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end end
        lineCount = 0; return true end
    if cmdName == "exit" or cmdName == "quit" then
        pcall(function() screen:Destroy() end)
        getgenv().ZukaTerm_Loaded = nil; getgenv().ZukaTerm_GUI = nil; return true end
    local entry = Commands[cmdName]
    if entry then
        local ok, err = pcall(entry.Func, parts)
        if not ok then addError(tostring(err)) end
        return true end
    return false
end
inputField.FocusLost:Connect(function(enter)
    if not enter then return end
    local raw = inputField.Text
    inputField.Text = ""
    suggestionLabel.Text = ""
    raw = raw:match("^%s*(.-)%s*$")
    if raw == "" then return end
    table.insert(commandHistory, 1, raw)
    if #commandHistory > 50 then table.remove(commandHistory) end
    historyIdx = 0
    addLine("C:\\>" .. raw, COLOR.GREEN)
    if not processCommand(raw) then
        addLine("'"..(raw:match("%S+") or raw).."' is not recognized as an internal command.", COLOR.WHITE)
        addInfo("Type 'help' for a list of commands.") end end)
UIS.InputBegan:Connect(function(input, gp)
    if not inputField:IsFocused() then return end
    if input.KeyCode == Enum.KeyCode.Up then
        historyIdx = math.min(historyIdx+1, #commandHistory)
        if commandHistory[historyIdx] then inputField.Text = commandHistory[historyIdx] end
    elseif input.KeyCode == Enum.KeyCode.Down then
        historyIdx = math.max(historyIdx-1, 0)
        inputField.Text = commandHistory[historyIdx] or "" end end)
RegisterCommand({Name="help", Aliases={"cmds","dir","commands","?"}, Description="List all commands"}, function(args)
    if args[1] then
        local entry = Commands[args[1]:lower()]
        if entry then
            addBlank()
            addLine("  " .. entry.Info.Name:upper(), COLOR.CYAN)
            addLine("  " .. (entry.Info.Description or "(no description)"), COLOR.WHITE)
            local aliases = entry.Info.Aliases or {}
            if #aliases > 0 then
                addLine("  Aliases: " .. table.concat(aliases, ", "), COLOR.GRAY) end
            addBlank(); return end
        addError("Unknown command: " .. args[1]); return end
    addBlank()
    addHeader("ZUKATERM COMMAND REFERENCE")
    addBlank()
    local cats = {
        {"Movement",   {"fly","noclip","infjump","walkspeed","anchor","clicktp","unlockmouse"}},
        {"Combat",     {"fling","autoattack","aimbot"}},
        {"Protection", {"antifling","antikb","revert","desync","killbrick"}},
        {"Visual",     {"esp","fpsboost","fov","chams"}},
        {"Utility",    {"rejoin","joingame","loadstring","exec","run","info","serverinfo","players"}},
        {"Game",       {"walkspeed","jumppower","gravity","time","fog","ambient"}},
        {"Bypass",     {"bypassgamepass","bypassdevproduct"}},
        {"Terminal",   {"help","cls","clear","exit","history","echo","lua"}},
    }
    for _, cat in ipairs(cats) do
        local catName, cmds = cat[1], cat[2]
        addLine("  " .. catName:upper() .. ":", COLOR.YELLOW)
        for _, name in ipairs(cmds) do
            local entry = Commands[name]
            if entry then
                addLine(string.format("    %-18s %s", ";"..name, entry.Info.Description or ""), COLOR.WHITE) end end
        addBlank() end end)
RegisterCommand({Name="echo", Aliases={}, Description="Print text to terminal"}, function(args)
    addLine("  " .. table.concat(args," "), COLOR.WHITE) end)
RegisterCommand({Name="history", Aliases={"hist"}, Description="Show command history"}, function()
    addBlank()
    for i=#commandHistory,1,-1 do
        addLine(string.format("  %3d  %s", #commandHistory-i+1, commandHistory[i]), COLOR.GRAY) end
    addBlank() end)
RegisterCommand({Name="lua", Aliases={"exec","run","l"}, Description="Execute Lua. lua <code>"}, function(args)
    local code = table.concat(args, " ")
    if code=="" then addError("Usage: lua <code>"); return end
    local f, err = loadstring(code)
    if not f then addError("Syntax: "..tostring(err)); return end
    local ok, res = pcall(f)
    if ok then
        if res ~= nil then addSuccess(tostring(res)) end
    else addError(tostring(res)) end end)
RegisterCommand({Name="info", Aliases={"whoami","me"}, Description="Show your player info"}, function()
    addBlank()
    addHeader("PLAYER INFO")
    addLine("  Username:    " .. LocalPlayer.Name,                      COLOR.LIME)
    addLine("  Display:     " .. (LocalPlayer.DisplayName or "-"),      COLOR.LIME)
    addLine("  UserId:      " .. tostring(LocalPlayer.UserId),          COLOR.LIME)
    addLine("  Team:        " .. (LocalPlayer.Team and LocalPlayer.Team.Name or "None"), COLOR.LIME)
    addLine("  Profile:     https://roblox.com/users/"..LocalPlayer.UserId.."/profile", COLOR.BLUE)
    addBlank() end)
RegisterCommand({Name="serverinfo", Aliases={"sinfo","server"}, Description="Show server info"}, function()
    addBlank()
    addHeader("SERVER INFO")
    addLine("  PlaceId:  " .. tostring(game.PlaceId),  COLOR.LIME)
    addLine("  JobId:    " .. tostring(game.JobId),    COLOR.LIME)
    addLine("  Players:  " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers, COLOR.LIME)
    addLine("  Game URL: https://roblox.com/games/"..game.PlaceId, COLOR.BLUE)
    addBlank() end)
RegisterCommand({Name="players", Aliases={"plist","who"}, Description="List players in server"}, function()
    addBlank()
    addHeader("PLAYER LIST  [" .. #Players:GetPlayers() .. "]")
    for i, p in ipairs(Players:GetPlayers()) do
        local marker = p==LocalPlayer and " ◄ YOU" or ""
        addLine(string.format("  %2d.  %-20s  (uid: %d)%s", i, p.Name, p.UserId, marker),
            p==LocalPlayer and COLOR.YELLOW or COLOR.WHITE) end
    addBlank() end)
Modules.Fly = { IsActive=false, Speed=60, SprintMul=2.5, Connections={}, BodyMovers={} }
RegisterCommand({Name="fly", Aliases={"flight","f"}, Description="Toggle fly. fly [speed]"}, function(args)
    if args[1] then
        local n = tonumber(args[1])
        if n then Modules.Fly.Speed=n; DoNotif("Fly speed: "..n,1); return end end
    local m = Modules.Fly
    if m.IsActive then
        m.IsActive = false
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=false end
        for _,v in pairs(m.BodyMovers) do pcall(function()v:Destroy()end) end
        for _,c in ipairs(m.Connections) do pcall(function()c:Disconnect()end) end
        table.clear(m.BodyMovers); table.clear(m.Connections)
        DoNotif("Fly OFF",1)
    else
        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not (hrp and hum) then addError("No character found."); return end
        m.IsActive = true; hum.PlatformStand = true
        local att = Instance.new("Attachment",hrp)
        local attW = Instance.new("Attachment",Workspace.Terrain); attW.WorldCFrame=hrp.CFrame
        local ao = Instance.new("AlignOrientation",hrp)
        ao.Mode=Enum.OrientationAlignmentMode.OneAttachment; ao.Attachment0=att
        ao.Responsiveness=200; ao.MaxTorque=math.huge
        local lv = Instance.new("LinearVelocity",hrp)
        lv.Attachment0=att; lv.RelativeTo=Enum.ActuatorRelativeTo.World
        lv.MaxForce=math.huge; lv.VectorVelocity=Vector3.zero
        m.BodyMovers = {att=att,attW=attW,ao=ao,lv=lv}
        local keys={}
        local function inp(i,gp) if not gp then keys[i.KeyCode]=(i.UserInputState==Enum.UserInputState.Begin) end end
        table.insert(m.Connections, UIS.InputBegan:Connect(inp))
        table.insert(m.Connections, UIS.InputEnded:Connect(inp))
        table.insert(m.Connections, RunService.RenderStepped:Connect(function()
            if not m.IsActive or not hrp.Parent then return end
            local cam = Workspace.CurrentCamera; ao.CFrame=cam.CFrame
            local dir = Vector3.zero
            if keys[Enum.KeyCode.W] then dir=dir+cam.CFrame.LookVector end
            if keys[Enum.KeyCode.S] then dir=dir-cam.CFrame.LookVector end
            if keys[Enum.KeyCode.D] then dir=dir+cam.CFrame.RightVector end
            if keys[Enum.KeyCode.A] then dir=dir-cam.CFrame.RightVector end
            if keys[Enum.KeyCode.Space] or keys[Enum.KeyCode.E] then dir=dir+Vector3.yAxis end
            if keys[Enum.KeyCode.LeftControl] or keys[Enum.KeyCode.Q] then dir=dir-Vector3.yAxis end
            local spd = keys[Enum.KeyCode.LeftShift] and m.Speed*m.SprintMul or m.Speed
            lv.VectorVelocity = dir.Magnitude>0 and dir.Unit*spd or Vector3.zero end))
        DoNotif("Fly ON — WASD/E(up)/Q(dn)/Shift(sprint)",2) end end)
Modules.NoClip = { IsEnabled=false, Connections={}, Tracked=setmetatable({},{__mode="k"}) }
RegisterCommand({Name="noclip", Aliases={"nc","ghost"}, Description="Toggle noclip"}, function()
    local m = Modules.NoClip
    if m.IsEnabled then
        m.IsEnabled=false
        for k,v in pairs(m.Connections) do
            if type(v)=="table" then for _,c in ipairs(v) do pcall(function()c:Disconnect()end) end
            else pcall(function()v:Disconnect()end) end end
        table.clear(m.Connections)
        for part in pairs(m.Tracked) do
            if part and part.Parent then part.CanCollide=true end end
        table.clear(m.Tracked); DoNotif("NoClip OFF",2)
    else
        m.IsEnabled=true
        local function proc(char)
            if not char then return end
            for _,d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") then m.Tracked[d]=true; d.CanCollide=false end end
            local t={}
            table.insert(t, char.DescendantAdded:Connect(function(d)
                if d:IsA("BasePart") then m.Tracked[d]=true; d.CanCollide=false end end))
            m.Connections[char]=t end
        if LocalPlayer.Character then proc(LocalPlayer.Character) end
        m.Connections.CA = LocalPlayer.CharacterAdded:Connect(proc)
        m.Connections.Enforcer = RunService.Stepped:Connect(function()
            for part in pairs(m.Tracked) do
                if part and part.Parent and part.CanCollide then part.CanCollide=false end end end)
        DoNotif("NoClip ON",2) end end)
RegisterCommand({Name="walkspeed", Aliases={"ws","speed"}, Description="Set walkspeed. ws <number|reset>"}, function(args)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then addError("No humanoid."); return end
    if not args[1] then addLine("  WalkSpeed: "..hum.WalkSpeed, COLOR.LIME); return end
    if args[1]:lower()=="reset" then hum.WalkSpeed=16; DoNotif("WalkSpeed reset to 16",1); return end
    local n=tonumber(args[1]); if n then hum.WalkSpeed=n; DoNotif("WalkSpeed: "..n,1)
    else addError("Provide a number.") end end)
RegisterCommand({Name="jumppower", Aliases={"jp"}, Description="Set jump power. jp <number|reset>"}, function(args)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then addError("No humanoid."); return end
    if not args[1] then addLine("  JumpPower: "..hum.JumpPower, COLOR.LIME); return end
    if args[1]:lower()=="reset" then hum.JumpPower=50; DoNotif("JumpPower reset",1); return end
    local n=tonumber(args[1]); if n then hum.JumpPower=n; DoNotif("JumpPower: "..n,1)
    else addError("Provide a number.") end end)
RegisterCommand({Name="gravity", Aliases={"grav"}, Description="Set gravity. gravity <number|reset>"}, function(args)
    if not args[1] then addLine("  Gravity: "..Workspace.Gravity, COLOR.LIME); return end
    if args[1]:lower()=="reset" then Workspace.Gravity=196.2; DoNotif("Gravity reset",1); return end
    local n=tonumber(args[1]); if n then Workspace.Gravity=n; DoNotif("Gravity: "..n,1)
    else addError("Provide a number.") end end)
Modules.InfJump = { Enabled=false }
RegisterCommand({Name="infjump", Aliases={"ij","infj"}, Description="Toggle infinite jump"}, function()
    Modules.InfJump.Enabled = not Modules.InfJump.Enabled
    DoNotif("InfJump "..(Modules.InfJump.Enabled and "ON" or "OFF"),1) end)
UIS.JumpRequest:Connect(function()
    if Modules.InfJump.Enabled then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end)
Modules.AnchorSelf = { Enabled=false, Saved={} }
RegisterCommand({Name="anchor", Aliases={"lock","lockpos"}, Description="Toggle anchor self in place"}, function()
    local m=Modules.AnchorSelf
    if m.Enabled then
        local char=LocalPlayer.Character
        if char then for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.Anchored = m.Saved[p] or false end end end
        table.clear(m.Saved); m.Enabled=false; DoNotif("Anchor OFF",2)
    else
        local char=LocalPlayer.Character; if not char then addError("No character."); return end
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then m.Saved[p]=p.Anchored; p.Anchored=true end end
        m.Enabled=true; DoNotif("Anchor ON",2) end end)
Modules.Fling = { FPDH=Workspace.FallenPartsDestroyHeight, OldPos=nil, Config={Power=9e7, Wait=2} }
local function doFling(target)
    local char=LocalPlayer.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
    local hrp=hum and hum.RootPart
    if not (char and hum and hrp) then return end
    local tc=target.Character; if not tc then return end
    local thum=tc:FindFirstChildOfClass("Humanoid"); if not thum then return end
    local thrp=thum.RootPart; if not thrp then return end
    if hrp.Velocity.Magnitude<50 then Modules.Fling.OldPos=hrp.CFrame end
    Workspace.CurrentCamera.CameraSubject=thrp
    local function FPos(bp,ang)
        hrp.CFrame=CFrame.new(bp.Position)*CFrame.new(0,1.5,0)*CFrame.Angles(math.rad(ang),0,0)
        hrp.Velocity=Vector3.new(Modules.Fling.Config.Power,Modules.Fling.Config.Power*10,Modules.Fling.Config.Power)
        hrp.RotVelocity=Vector3.new(Modules.Fling.Config.Power)*10 end
    Workspace.FallenPartsDestroyHeight=0/0
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,false)
    local t=tick(); local a=0
    repeat
        if hrp and thum then a=a+100; FPos(thrp,a); task.wait()
        else break end
    until thrp.Velocity.Magnitude>500 or tick()>t+Modules.Fling.Config.Wait
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated,true)
    Workspace.CurrentCamera.CameraSubject=hum
    if Modules.Fling.OldPos then
        repeat
            hrp.CFrame=Modules.Fling.OldPos*CFrame.new(0,0.5,0)
            hum:ChangeState("GettingUp")
            for _,v in ipairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.Velocity=Vector3.new(); v.RotVelocity=Vector3.new() end end
            task.wait()
        until (hrp.Position-Modules.Fling.OldPos.p).Magnitude<10 end
    Workspace.FallenPartsDestroyHeight=Modules.Fling.FPDH end
RegisterCommand({Name="fling", Aliases={"ff","fff"}, Description="Fling player. fling <name|all|random>"}, function(args)
    local name=(args[1] or ""):lower()
    local targets={}
    if name=="all" or name=="others" then
        for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(targets,p) end end
    elseif name=="random" then
        local list={}; for _,p in ipairs(Players:GetPlayers()) do if p~=LocalPlayer then table.insert(list,p) end end
        if #list>0 then table.insert(targets,list[math.random(#list)]) end
    else local p=Utilities_findPlayer(name); if p then table.insert(targets,p)
        else addError("Player not found: "..(args[1] or "?")); return end end
    for _,p in ipairs(targets) do
        addInfo("Flinging "..p.Name.."...")
        task.spawn(doFling, p) end end)
Modules.AntiFling = { Enabled=false, Conn=nil, LastCF=nil, LastT=0,
    VelThresh=150, DispThresh=30, Cooldown=0.5 }
local function removeForcesAF(char)
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BodyMover") or v.ClassName:find("Velocity") or v.ClassName:find("Align") or v.ClassName:find("Force") then
            pcall(function()v:Destroy()end) end end end
RegisterCommand({Name="antifling", Aliases={"af","antifling"}, Description="Toggle anti-fling protection"}, function()
    local m=Modules.AntiFling
    m.Enabled = not m.Enabled
    if m.Enabled then
        if m.Conn then pcall(function()m.Conn:Disconnect()end) end
        m.Conn = RunService.Heartbeat:Connect(function()
            if not m.Enabled then return end
            local char=LocalPlayer.Character; if not char then return end
            local hrp=char:FindFirstChild("HumanoidRootPart")
            local hum=char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health<=0 then return end
            removeForcesAF(char)
            local vel=hrp.AssemblyLinearVelocity or Vector3.zero
            if vel.Magnitude<m.VelThresh*0.25 and not hum.PlatformStand then
                m.LastCF=hrp.CFrame; m.LastT=tick() end
            if vel.Magnitude>m.VelThresh then
                pcall(function()hrp.AssemblyLinearVelocity=Vector3.zero end)
                if m.LastCF and tick()-m.LastT>m.Cooldown then
                    pcall(function()
                        hum.PlatformStand=true; hrp.CFrame=m.LastCF
                        task.wait(0.06); hum.PlatformStand=false end); m.LastT=tick() end
            elseif m.LastCF and (m.LastCF.Position-hrp.CFrame.Position).Magnitude>m.DispThresh then
                if tick()-m.LastT>m.Cooldown then
                    pcall(function()hrp.AssemblyLinearVelocity=Vector3.zero; hrp.CFrame=m.LastCF end)
                    m.LastT=tick() end end end)
        DoNotif("Anti-Fling ON",2)
    else
        if m.Conn then pcall(function()m.Conn:Disconnect()end); m.Conn=nil end
        DoNotif("Anti-Fling OFF",2) end end)
Modules.KillBrick = { Enabled=false, Conns={}, Tracked=setmetatable({},{__mode="k"}) }
RegisterCommand({Name="antikb", Aliases={"antikillbrick","akb","killbrick"}, Description="Toggle anti-killbrick"}, function()
    local m=Modules.KillBrick
    m.Enabled=not m.Enabled
    if m.Enabled then
        local function prot(part)
            if part:IsA("BasePart") and LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then
                pcall(function()part.CanTouch=false end); m.Tracked[part]=true end end
        local char=LocalPlayer.Character
        if char then for _,d in ipairs(char:GetDescendants()) do prot(d) end end
        table.insert(m.Conns, LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(0.1); for _,d in ipairs(c:GetDescendants()) do prot(d) end
            table.insert(m.Conns, c.DescendantAdded:Connect(function(d) task.defer(prot,d) end)) end))
        table.insert(m.Conns, RunService.Stepped:Connect(function()
            for part in pairs(m.Tracked) do
                if part and part.Parent and part.CanTouch then pcall(function()part.CanTouch=false end) end end end))
        DoNotif("Anti-KillBrick ON",2)
    else
        for _,c in ipairs(m.Conns) do pcall(function()c:Disconnect()end) end
        table.clear(m.Conns); table.clear(m.Tracked)
        DoNotif("Anti-KillBrick OFF",2) end end)
Modules.RAD = { Enabled=false, LastCF=nil, DiedConn=nil, CharConn=nil }
RegisterCommand({Name="revert", Aliases={"deathspawn","rad"}, Description="Toggle respawn at death location"}, function()
    local m=Modules.RAD
    m.Enabled=not m.Enabled
    if m.Enabled then
        local function onDied()
            local r=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if r then m.LastCF=r.CFrame end end
        local function onCharAdded(char)
            local hum=char:WaitForChild("Humanoid")
            if m.DiedConn then m.DiedConn:Disconnect() end
            m.DiedConn=hum.Died:Connect(onDied)
            if m.LastCF then coroutine.wrap(function()
                task.wait(0.1)
                local root=char:WaitForChild("HumanoidRootPart"); if not root then return end
                root.Anchored=true; root.CFrame=m.LastCF
                RunService.Heartbeat:Wait(); root.Anchored=false; m.LastCF=nil
            end)() end end
        m.CharConn=LocalPlayer.CharacterAdded:Connect(onCharAdded)
        if LocalPlayer.Character then onCharAdded(LocalPlayer.Character) end
        DoNotif("Revert ON",2)
    else
        if m.DiedConn then m.DiedConn:Disconnect() end
        if m.CharConn then m.CharConn:Disconnect() end
        m.LastCF=nil; DoNotif("Revert OFF",2) end end)
Modules.ClickTP = { IsActive=false, Conn=nil }
RegisterCommand({Name="clicktp", Aliases={"ctp"}, Description="Toggle Ctrl+Click to teleport"}, function()
    local m=Modules.ClickTP
    m.IsActive=not m.IsActive
    if m.IsActive then
        m.Conn=UIS.InputBegan:Connect(function(input,gp)
            if gp or input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            if not UIS:IsKeyDown(Enum.KeyCode.LeftControl) then return end
            local hrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local cam=Workspace.CurrentCamera; local mp=UIS:GetMouseLocation()
            local ray=cam:ViewportPointToRay(mp.X,mp.Y)
            local params=RaycastParams.new(); params.FilterType=Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances={LocalPlayer.Character}
            local res=Workspace:Raycast(ray.Origin,ray.Direction*1000,params)
            if res then hrp.CFrame=CFrame.new(res.Position+Vector3.new(0,3,0)) end end)
        DoNotif("Click TP ON — Ctrl+LClick",2)
    else
        if m.Conn then m.Conn:Disconnect(); m.Conn=nil end; DoNotif("Click TP OFF",2) end end)
Modules.ESP = { Enabled=false, Conns={}, Tracked=setmetatable({},{__mode="k"}) }
local function espSetupPlayer(player, char)
    if player==LocalPlayer then return end
    local head=char:WaitForChild("Head",10); local hrp=char:WaitForChild("HumanoidRootPart",10)
    local hum=char:WaitForChild("Humanoid",10)
    if not (head and hrp and hum) then return end
    local hl=Instance.new("Highlight",char); hl.FillColor=player.TeamColor and player.TeamColor.Color or Color3.fromRGB(255,50,50)
    hl.OutlineColor=Color3.new(1,1,1); hl.FillTransparency=0.7; hl.OutlineTransparency=0.1
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    local bb=Instance.new("BillboardGui",char); bb.Adornee=head; bb.AlwaysOnTop=true
    bb.Size=UDim2.new(0,180,0,50); bb.StudsOffset=Vector3.new(0,3,0); bb.MaxDistance=2000
    local ct=Instance.new("Frame",bb); ct.Size=UDim2.new(1,0,1,0); ct.BackgroundTransparency=1
    local nl=Instance.new("TextLabel",ct); nl.Size=UDim2.new(1,0,0.5,0); nl.BackgroundTransparency=1
    nl.Font=Enum.Font.BuilderSansBold; nl.TextColor3=Color3.new(1,1,1); nl.TextSize=14
    nl.Text=player.DisplayName; nl.TextXAlignment=Enum.TextXAlignment.Left
    local sl=Instance.new("TextLabel",ct); sl.Size=UDim2.new(1,0,0.4,0); sl.Position=UDim2.new(0,0,0.55,0)
    sl.BackgroundTransparency=1; sl.Font=Enum.Font.BuilderSansMedium; sl.TextSize=12
    sl.TextColor3=hl.FillColor; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.Text="0 st"
    local rConn=RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent then return end
        local lhrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if lhrp then
            local d=(hrp.Position-lhrp.Position).Magnitude
            sl.Text=(d>=1000 and string.format("%.1fk",d/1000) or tostring(math.floor(d))).." st" end end)
    Modules.ESP.Tracked[player]={hl=hl,bb=bb,rConn=rConn} end
RegisterCommand({Name="esp", Aliases={"visuals","chams"}, Description="Toggle player ESP/highlights"}, function()
    local m=Modules.ESP
    m.Enabled=not m.Enabled
    if m.Enabled then
        table.insert(m.Conns, Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(c) task.spawn(espSetupPlayer,p,c) end)
            if p.Character then task.spawn(espSetupPlayer,p,p.Character) end end))
        table.insert(m.Conns, Players.PlayerRemoving:Connect(function(p)
            local d=m.Tracked[p]
            if d then pcall(function()d.hl:Destroy()end); pcall(function()d.bb:Destroy()end)
                pcall(function()d.rConn:Disconnect()end); m.Tracked[p]=nil end end))
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LocalPlayer then
                p.CharacterAdded:Connect(function(c) task.spawn(espSetupPlayer,p,c) end)
                if p.Character then task.spawn(espSetupPlayer,p,p.Character) end end end
        DoNotif("ESP ON",2)
    else
        for _,c in ipairs(m.Conns) do pcall(function()c:Disconnect()end) end; table.clear(m.Conns)
        for p,d in pairs(m.Tracked) do
            if d then pcall(function()d.hl:Destroy()end); pcall(function()d.bb:Destroy()end)
                pcall(function()d.rConn:Disconnect()end) end; m.Tracked[p]=nil end
        DoNotif("ESP OFF",2) end end)
Modules.Perf={Enabled=false}
RegisterCommand({Name="fpsboost", Aliases={"performance","perf","noshadows"}, Description="Toggle FPS boost (disable shadows/effects)"}, function()
    Modules.Perf.Enabled=not Modules.Perf.Enabled
    if Modules.Perf.Enabled then
        pcall(function()
            Lighting.GlobalShadows=false; Lighting.FogEnd=9e9
            for _,v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") then v.Enabled=false end end end)
        DoNotif("FPS Boost ON",2)
    else
        pcall(function()
            Lighting.GlobalShadows=true
            for _,v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") then v.Enabled=true end end end)
        DoNotif("FPS Boost OFF",2) end end)
Modules.FOV={Enabled=false,Target=70,Default=70,Conn=nil}
pcall(function() Modules.FOV.Default=Workspace.CurrentCamera.FieldOfView end)
RegisterCommand({Name="fov", Aliases={"fieldofview","camfov"}, Description="Set camera FOV. fov <number|reset>"}, function(args)
    if not args[1] then addLine("  FOV: "..Workspace.CurrentCamera.FieldOfView, COLOR.LIME); return end
    if args[1]:lower()=="reset" then
        Modules.FOV.Enabled=false
        if Modules.FOV.Conn then Modules.FOV.Conn:Disconnect(); Modules.FOV.Conn=nil end
        Workspace.CurrentCamera.FieldOfView=Modules.FOV.Default; DoNotif("FOV reset",2); return end
    local n=tonumber(args[1]); if not n then addError("Provide a number or 'reset'."); return end
    n=math.clamp(n,1,120); Modules.FOV.Target=n; Modules.FOV.Enabled=true
    if not Modules.FOV.Conn then
        Modules.FOV.Conn=RunService.RenderStepped:Connect(function()
            if Modules.FOV.Enabled then Workspace.CurrentCamera.FieldOfView=Modules.FOV.Target end end) end
    DoNotif("FOV locked to "..n,2) end)
Modules.Desync={IsActive=false,Ghost=nil,Conn=nil}
RegisterCommand({Name="desync", Aliases={"astral","ghost"}, Description="Toggle server desync (ghost at old position)"}, function()
    local m=Modules.Desync
    m.IsActive=not m.IsActive
    if m.IsActive then
        local char=LocalPlayer.Character; if not char then addError("No character."); m.IsActive=false; return end
        local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then m.IsActive=false; return end
        local ghost=char:Clone()
        for _,p in ipairs(ghost:GetDescendants()) do
            if p:IsA("BasePart") then p.Transparency=1; p.CanCollide=false end
            if p:IsA("BillboardGui") or p:IsA("Highlight") or p:IsA("Script") then p:Destroy() end end
        ghost.Parent=Workspace; m.Ghost=ghost
        m.Conn=RunService.Heartbeat:Connect(function()
            if not m.IsActive then return end
            local gh=ghost:FindFirstChild("HumanoidRootPart")
            if gh then pcall(function()gh.CFrame=hrp.CFrame end) end end)
        DoNotif("Desync ON",2)
    else
        if m.Ghost then pcall(function()m.Ghost:Destroy()end); m.Ghost=nil end
        if m.Conn then pcall(function()m.Conn:Disconnect()end); m.Conn=nil end
        DoNotif("Desync OFF",2) end end)
Modules.UnlockMouse={Enabled=false,Conn=nil}
RegisterCommand({Name="unlockmouse", Aliases={"um","freemouse"}, Description="Unlock/lock mouse cursor"}, function()
    local m=Modules.UnlockMouse; m.Enabled=not m.Enabled
    if m.Enabled then
        m.Conn=RunService.RenderStepped:Connect(function()
            UIS.MouseBehavior=Enum.MouseBehavior.Default; UIS.MouseIconEnabled=true end)
        DoNotif("Mouse Unlock ON",2)
    else
        if m.Conn then m.Conn:Disconnect(); m.Conn=nil end; DoNotif("Mouse Unlock OFF",2) end end)
Modules.AA={Enabled=false,Delay=0.1,Conn=nil,Last=0}
RegisterCommand({Name="autoattack", Aliases={"aa","autoclick"}, Description="Toggle auto-attack. aa [delay_ms]"}, function(args)
    local m=Modules.AA
    if args[1] then
        local n=tonumber(args[1]); if n then m.Delay=n/1000; DoNotif("AA delay: "..n.."ms",1); return end end
    m.Enabled=not m.Enabled
    if m.Enabled then
        m.Conn=RunService.Heartbeat:Connect(function()
            if UIS:GetFocusedTextBox() then return end
            local now=os.clock()
            if now-m.Last>m.Delay then pcall(mouse1press); task.wait(); pcall(mouse1release); m.Last=now end end)
        DoNotif("Auto-Attack ON — "..math.floor(m.Delay*1000).."ms",2)
    else
        if m.Conn then m.Conn:Disconnect(); m.Conn=nil end; DoNotif("Auto-Attack OFF",2) end end)
RegisterCommand({Name="tp", Aliases={"teleport"}, Description="Teleport to player. tp <name>"}, function(args)
    if not args[1] then addError("Usage: tp <player>"); return end
    local target=Utilities_findPlayer(args[1])
    if not target then addError("Player not found: "..args[1]); return end
    local tc=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    local my=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tc or not my then addError("Character not loaded."); return end
    my.CFrame=tc.CFrame+Vector3.new(0,3,0); DoNotif("TP'd to "..target.Name,2) end)
RegisterCommand({Name="bring", Aliases={"b"}, Description="Bring a player to you. bring <name>"}, function(args)
    if not args[1] then addError("Usage: bring <player>"); return end
    local target=Utilities_findPlayer(args[1])
    if not target then addError("Player not found."); return end
    local tc=target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    local my=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tc or not my then addError("Character not loaded."); return end
    tc.CFrame=my.CFrame+Vector3.new(2,0,0); DoNotif("Brought "..target.Name,2) end)
RegisterCommand({Name="rejoin", Aliases={"rj","reconnect"}, Description="Rejoin current server"}, function()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,LocalPlayer) end) end)
RegisterCommand({Name="joingame", Aliases={"jg","join"}, Description="Join a game by PlaceId. join <id>"}, function(args)
    local pid=tonumber(args[1]); if not pid then addError("Provide a PlaceId."); return end
    pcall(function() TeleportService:Teleport(pid,LocalPlayer) end) end)
RegisterCommand({Name="bypassgamepass", Aliases={"bpgp"}, Description="Hook GamePassAsync to always return true"}, function()
    local old; old=hookfunction(MarketplaceService.UserOwnsGamePassAsync,function(self,uid,gpid)
        if uid==LocalPlayer.UserId then return true end; return old(self,uid,gpid) end)
    DoNotif("Gamepass bypass ON",2) end)
RegisterCommand({Name="bypassdevproduct", Aliases={"bpdp"}, Description="Block dev product purchase prompts"}, function()
    hookfunction(MarketplaceService.PromptProductPurchase,function() return end)
    DoNotif("DevProduct bypass ON",2) end)
RegisterCommand({Name="loadscript", Aliases={"load","ls","http"}, Description="Load a script from URL. load <url>"}, function(args)
    if not args[1] then addError("Usage: load <url>"); return end
    local url=args[1]
    addInfo("Loading: "..url)
    local ok,err=pcall(function() loadstring(game:HttpGet(url))() end)
    if ok then addSuccess("Script executed.") else addError(tostring(err):sub(1,80)) end end)
RegisterCommand({Name="time", Aliases={"t","settime"}, Description="Set time of day. time <0-24>"}, function(args)
    if not args[1] then addLine("  Time: "..tostring(Lighting.TimeOfDay), COLOR.LIME); return end
    local n=tonumber(args[1])
    if n then Lighting.TimeOfDay=string.format("%02d:00:00",math.clamp(math.floor(n),0,23))
        DoNotif("Time: "..n,1)
    else addError("Provide 0-24.") end end)
RegisterCommand({Name="fog", Aliases={"fogend","fogdist"}, Description="Set fog distance. fog <number|off>"}, function(args)
    if not args[1] then addLine("  Fog: "..Lighting.FogEnd, COLOR.LIME); return end
    if args[1]:lower()=="off" then Lighting.FogEnd=9e9; DoNotif("Fog OFF",1); return end
    local n=tonumber(args[1]); if n then Lighting.FogEnd=n; DoNotif("Fog: "..n,1)
    else addError("Provide a number or 'off'.") end end)
RegisterCommand({Name="ambient", Aliases={"brightness"}, Description="Set ambient brightness. ambient <0-10>"}, function(args)
    if not args[1] then addLine("  Brightness: "..Lighting.Brightness, COLOR.LIME); return end
    local n=tonumber(args[1]); if n then Lighting.Brightness=n; DoNotif("Ambient: "..n,1)
    else addError("Provide a number.") end end)
Modules.Aimbot={Enabled=false,Target=nil,Part="Head",Conn=nil,Silent=false}
RegisterCommand({Name="aimbot", Aliases={"aim","ab"}, Description="Toggle aimbot. aimbot [target|part|silent|off]"}, function(args)
    local m=Modules.Aimbot
    if args[1] then
        local sub=args[1]:lower()
        if sub=="off" then
            m.Enabled=false
            if m.Conn then m.Conn:Disconnect(); m.Conn=nil end; DoNotif("Aimbot OFF",2); return end
        if sub=="silent" then m.Silent=not m.Silent; DoNotif("Silent aim: "..(m.Silent and "ON" or "OFF"),2); return end
        if sub=="head" or sub=="hrp" or sub=="torso" or sub=="uppertorso" then
            m.Part=args[1]; DoNotif("Aimbot part: "..args[1],2); return end
        local target=Utilities_findPlayer(args[1])
        if target then m.Target=target; DoNotif("Aimbot target: "..target.Name,2); return end
        addError("Unknown arg: "..args[1]); return end
    m.Enabled=not m.Enabled
    if m.Enabled then
        local mouse=LocalPlayer:GetMouse()
        if m.Conn then m.Conn:Disconnect() end
        m.Conn=RunService.RenderStepped:Connect(function()
            if not m.Enabled then return end
            local target=m.Target
            if not target then
                local minDist,closest=math.huge,nil
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LocalPlayer and p.Character and p.Character:FindFirstChild(m.Part) then
                        local part=p.Character[m.Part]
                        local pos,onScreen=Workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local d=(Vector2.new(pos.X,pos.Y)-Vector2.new(mouse.X,mouse.Y)).Magnitude
                            if d<minDist then minDist=d; closest=p end end end end
                target=closest end
            if target and target.Character and target.Character:FindFirstChild(m.Part) then
                local part=target.Character[m.Part]
                if m.Silent then getgenv().ZukaSilentAimTarget=part.Position
                else
                    local cam=Workspace.CurrentCamera
                    cam.CFrame=CFrame.new(cam.CFrame.Position,part.Position) end end end)
        DoNotif("Aimbot ON — targeting ".. (m.Target and m.Target.Name or "closest"),2)
    else
        if m.Conn then m.Conn:Disconnect(); m.Conn=nil end; DoNotif("Aimbot OFF",2) end end)
RegisterCommand({Name="status", Aliases={"modules","modstatus"}, Description="Show all module states"}, function()
    addBlank(); addHeader("MODULE STATUS")
    local status={
        {"Fly",            Modules.Fly.IsActive},
        {"NoClip",         Modules.NoClip.IsEnabled},
        {"InfJump",        Modules.InfJump.Enabled},
        {"Anchor",         Modules.AnchorSelf.Enabled},
        {"Anti-Fling",     Modules.AntiFling.Enabled},
        {"Anti-KillBrick", Modules.KillBrick.Enabled},
        {"ESP",            Modules.ESP.Enabled},
        {"FPS Boost",      Modules.Perf.Enabled},
        {"FOV Lock",       Modules.FOV.Enabled},
        {"Desync",         Modules.Desync.IsActive},
        {"Mouse Unlock",   Modules.UnlockMouse.Enabled},
        {"Auto-Attack",    Modules.AA.Enabled},
        {"Aimbot",         Modules.Aimbot.Enabled},
        {"Click TP",       Modules.ClickTP.IsActive},
        {"Revert",         Modules.RAD.Enabled},
    }
    for _,s in ipairs(status) do
        local name,state=s[1],s[2]
        addLine(string.format("  %-20s %s", name, state and "[ ON ]" or "[ -- ]"),
            state and COLOR.LIME or COLOR.GRAY) end
    addBlank() end)
RegisterCommand({Name="killall", Aliases={"stopall","reset"}, Description="Disable all active modules"}, function()
    if Modules.Fly.IsActive then processCommand("fly") end
    if Modules.NoClip.IsEnabled then processCommand("noclip") end
    if Modules.AntiFling.Enabled then processCommand("antifling") end
    if Modules.KillBrick.Enabled then processCommand("antikb") end
    if Modules.ESP.Enabled then processCommand("esp") end
    if Modules.Perf.Enabled then processCommand("fpsboost") end
    if Modules.AA.Enabled then processCommand("autoattack") end
    if Modules.Aimbot.Enabled then processCommand("aimbot off") end
    if Modules.Desync.IsActive then processCommand("desync") end
    if Modules.UnlockMouse.Enabled then processCommand("unlockmouse") end
    if Modules.ClickTP.IsActive then processCommand("clicktp") end
    if Modules.RAD.Enabled then processCommand("revert") end
    addSuccess("All modules disabled.") end)
local bootLines = {
    {"Microslop(R) Windows 95", COLOR.GRAY},
    {"(C)Copyright Microslop Corp 1995. All rights reserved.", COLOR.GRAY},
    {"", nil},
    {"ROBLOX driver loaded OK.", COLOR.GREEN},
    {"ZukaTerm v1.0 by zukatech1", COLOR.CYAN},
    {"", nil},
    {"Type ;help or help to list commands.", COLOR.GREEN},
    {"Type ;status to see module states.", COLOR.GREEN},
    {"Press ` (backtick) to toggle this terminal.", COLOR.GRAY},
    {"", nil},
}
for _, line in ipairs(bootLines) do addLine(line[1], line[2]) end
local visible = true
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.BackQuote then
        visible = not visible
        screen.Enabled = visible
        if visible then
            task.defer(function() inputField:CaptureFocus() end) end end end)
task.defer(function() inputField:CaptureFocus() end)