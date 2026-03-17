-- ============================================================
--  Callum_AdonisTools  v1.0
--  Dedicated Adonis internal tool
--  RightAlt = toggle
-- ============================================================

local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local CoreGui  = game:GetService("CoreGui")
local RepStore = game:GetService("ReplicatedStorage")
local lp       = Players.LocalPlayer

-- ── exploit functions ────────────────────────────────────────
local getupvalues  = getupvalues  or function() return {} end
local setupvalue   = setupvalue   or function() end
local hookfn       = hookfunction or function(a,b) end
local newcc        = newcclosure  or function(f) return f end
local islua        = islclosure   or function() return false end
local getgc        = getgc        or nil

-- ── Adonis internal cache ────────────────────────────────────
local A = {
    -- resolved refs
    Core        = nil,   -- client.Core
    Remote      = nil,   -- client.Remote  (has .Send/.Get/.Fire)
    Anti        = nil,   -- client.Anti    (has .Detected/.AddDetector)
    Functions   = nil,   -- client.Functions
    Variables   = nil,   -- client.Variables (has G_Access_Key)
    Service     = nil,   -- service table   (has .Wrap/.UnWrap/.TrackTask)
    RemoteEvent = nil,   -- the actual RemoteEvent instance
    -- ACLI
    acliLogs    = nil,   -- v_u_36 string log table
    acliKickFn  = nil,   -- v_u_48 loader kick closure
    -- intercepted values
    key         = nil,
}

-- ── resolution status labels (updated after resolve) ─────────
local StatusRows = {}  -- filled in after UI is built

-- ─────────────────────────────────────────────────────────────
--  RESOLUTION
-- ─────────────────────────────────────────────────────────────

-- Signature checks — returns a string label or nil
local function Fingerprint(t)
    if type(t) ~= "table" then return nil end
    if type(t.GetEvent)=="function" and (t.ScriptCache~=nil or type(t.LoadPlugin)=="function") then
        return "Core"
    end
    if type(t.Send)=="function" and type(t.Get)=="function" and type(t.Fire)=="function" then
        return "Remote"
    end
    if type(t.Detected)=="function" and type(t.AddDetector)=="function" then
        return "Anti"
    end
    if type(t.Wrap)=="function" and type(t.UnWrap)=="function" and type(t.TrackTask)=="function" then
        return "Service"
    end
    if rawget(t,"G_Access_Key") ~= nil then
        return "Variables"
    end
    if type(t.SHA256)=="function" or type(t.MakeAdmin)=="function" then
        return "Functions"
    end
    return nil
end

local function ApplyRef(label, tbl)
    if label == "Core"      and not A.Core      then A.Core=tbl      end
    if label == "Remote"    and not A.Remote     then A.Remote=tbl    end
    if label == "Anti"      and not A.Anti       then A.Anti=tbl      end
    if label == "Service"   and not A.Service    then A.Service=tbl   end
    if label == "Variables" and not A.Variables  then A.Variables=tbl end
    if label == "Functions" and not A.Functions  then A.Functions=tbl end
end

-- Strategy 1: getgc — scan all live Lua objects
local function ResolveViaGC()
    if not getgc then return end
    -- tables
    pcall(function()
        for _, obj in ipairs(getgc(true)) do
            if type(obj) == "table" then
                local label = Fingerprint(obj)
                if label then ApplyRef(label, obj) end
                -- also check for acliLogs: sequential string table with "ACLI:" entries
                if not A.acliLogs then
                    local ok, hasACLI, allStr, n = true, false, true, 0
                    for k, v in pairs(obj) do
                        n = n + 1
                        if type(k) ~= "number" or type(v) ~= "string" then
                            allStr = false break
                        end
                        if v:find("ACLI:", 1, true) then hasACLI = true end
                        if n > 500 then allStr = false break end
                    end
                    if allStr and hasACLI and n > 0 then A.acliLogs = obj end
                end
            end
        end
    end)
    -- functions — find acliKickFn:
    -- Lua closure with (boolean upvalue) AND (C-function upvalue named "Kick")
    if not A.acliKickFn then
        pcall(function()
            for _, obj in ipairs(getgc(false)) do
                if type(obj) == "function" and islua(obj) then
                    local uvs = {} pcall(function() uvs = getupvalues(obj) end)
                    local hasBool, hasKick = false, false
                    for _, uv in ipairs(uvs) do
                        if type(uv) == "boolean" then hasBool = true end
                        if type(uv) == "function" and not islua(uv) then
                            local ok, name = pcall(debug.info, uv, "n")
                            if ok and name == "Kick" then hasKick = true end
                        end
                    end
                    if hasBool and hasKick then A.acliKickFn = obj break end
                end
            end
        end)
    end
end

-- Strategy 2: upvalue walk — scan fns from already-required modules
-- We require modules from PlayerScripts and RepStore (with timeout),
-- grab their functions, and walk upvalues 2 levels deep.
local function SafeRequire(ms)
    local done, ok, res = false, false, nil
    task.spawn(function() ok, res = pcall(require, ms) done = true end)
    local t = 0
    while not done and t < 1.5 do task.wait(0.05); t = t + 0.05 end
    return done and ok, res
end

local function WalkFn(fn)
    local uvs = {} pcall(function() uvs = getupvalues(fn) end)
    for _, uv in ipairs(uvs) do
        if type(uv) == "table" then
            ApplyRef(Fingerprint(uv), uv)
        elseif type(uv) == "function" then
            -- one level deeper
            local uvs2 = {} pcall(function() uvs2 = getupvalues(uv) end)
            for _, uv2 in ipairs(uvs2) do
                if type(uv2) == "table" then ApplyRef(Fingerprint(uv2), uv2) end
            end
            -- also check getfenv of the upvalue-function
            pcall(function()
                local env = getfenv(uv)
                if type(env) ~= "table" then return end
                local c = rawget(env, "client")
                if type(c) == "table" then
                    ApplyRef(Fingerprint(c.Core),      c.Core)
                    ApplyRef(Fingerprint(c.Remote),    c.Remote)
                    ApplyRef(Fingerprint(c.Anti),      c.Anti)
                    ApplyRef(Fingerprint(c.Functions), c.Functions)
                    ApplyRef(Fingerprint(c.Variables), c.Variables)
                end
                local s = rawget(env, "service")
                ApplyRef(Fingerprint(s), s)
            end)
        end
    end
end

local function ResolveViaUpvalues()
    local containers = {RepStore}
    local ps = lp:FindFirstChild("PlayerScripts")
    if ps then table.insert(containers, ps) end

    for _, container in ipairs(containers) do
        local descs = {} pcall(function() descs = container:GetDescendants() end)
        for _, d in ipairs(descs) do
            if d:IsA("ModuleScript") then
                local ok, res = SafeRequire(d)
                if ok and type(res) == "table" then
                    -- getfenv on the module table's functions
                    for _, v in pairs(res) do
                        if type(v) == "function" then
                            WalkFn(v)
                            -- also try getfenv directly
                            pcall(function()
                                local env = getfenv(v)
                                if type(env) ~= "table" then return end
                                local c = rawget(env, "client")
                                if type(c) == "table" then
                                    ApplyRef("Core",      c.Core)
                                    ApplyRef("Remote",    c.Remote)
                                    ApplyRef("Anti",      c.Anti)
                                    ApplyRef("Functions", c.Functions)
                                    ApplyRef("Variables", c.Variables)
                                    if A.Anti then
                                        -- also grab DetectedFn directly
                                    end
                                end
                                ApplyRef("Service", rawget(env,"service"))
                            end)
                        end
                    end
                end
            end
            if A.Core and A.Remote and A.Anti and A.Service then break end
        end
        if A.Core and A.Remote and A.Anti and A.Service then break end
    end
end

-- RemoteEvent: from Core or direct RepStore scan
local function ResolveRemoteEvent()
    if A.Core and not A.RemoteEvent then
        pcall(function()
            local re = rawget(A.Core, "RemoteEvent")
            if re then A.RemoteEvent = rawget(re, "Object") or re end
        end)
    end
    if not A.RemoteEvent then
        pcall(function()
            for _, d in ipairs(RepStore:GetDescendants()) do
                if d:IsA("RemoteEvent") and d:FindFirstChild("__FUNCTION") then
                    A.RemoteEvent = d break
                end
            end
        end)
    end
end

local function Resolve()
    ResolveViaGC()
    -- fill in anything still missing via upvalue walk
    local needMore = not (A.Core and A.Remote and A.Anti and A.Service)
    if needMore then ResolveViaUpvalues() end
    ResolveRemoteEvent()
    -- propagate DetectedFn
    if A.Anti and type(A.Anti.Detected) == "function" then
        A._DetectedFn = A.Anti.Detected
    end
end

-- ─────────────────────────────────────────────────────────────
--  GUI
-- ─────────────────────────────────────────────────────────────
local Root = Instance.new("ScreenGui")
Root.Name = "Callum_AdonisTools"
Root.ResetOnSpawn = false
Root.ZIndexBehavior = Enum.ZIndexBehavior.Global
Root.Parent = (gethui and gethui()) or CoreGui

-- glow layers
local function GlowFrame(w,h,xo,yo,trans,z)
    local f = Instance.new("Frame", Root)
    f.Size = UDim2.new(0,w,0,h)
    f.Position = UDim2.new(0.5,xo,0.5,yo)
    f.BackgroundColor3 = Color3.fromRGB(255,255,255)
    f.BackgroundTransparency = trans
    f.BorderSizePixel = 0
    f.ZIndex = z
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
    return f
end
local G2 = GlowFrame(410,566,-205,-283,0.93,1)
local G1 = GlowFrame(396,550,-198,-275,0.82,2)

local Win = Instance.new("Frame", Root)
Win.Size = UDim2.new(0,378,0,530)
Win.Position = UDim2.new(0.5,-189,0.5,-265)
Win.BackgroundColor3 = Color3.fromRGB(16,16,16)
Win.BackgroundTransparency = 0.12
Win.BorderSizePixel = 0
Win.Active = true Win.Draggable = true Win.ZIndex = 3
Instance.new("UICorner",Win).CornerRadius = UDim.new(0,5)
Win.Parent = Root

do
    local g = Instance.new("UIGradient",Win)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16,16,16)),
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.88),
        NumberSequenceKeypoint.new(0.45, 0.96),
        NumberSequenceKeypoint.new(1, 1),
    })
    g.Rotation = 140
end

Win:GetPropertyChangedSignal("Position"):Connect(function()
    local p = Win.Position
    G1.Position = UDim2.new(p.X.Scale, p.X.Offset-9,  p.Y.Scale, p.Y.Offset-10)
    G2.Position = UDim2.new(p.X.Scale, p.X.Offset-16, p.Y.Scale, p.Y.Offset-18)
end)

-- title
local TitleBar = Instance.new("Frame", Win)
TitleBar.Size = UDim2.new(1,0,0,32)
TitleBar.BackgroundColor3 = Color3.fromRGB(28,18,42)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner",TitleBar).CornerRadius = UDim.new(0,5)

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(1,-80,1,0)
TitleLbl.Position = UDim2.new(0,10,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "★  adonis tools"
TitleLbl.TextColor3 = Color3.fromRGB(210,170,255)
TitleLbl.TextSize = 13 TitleLbl.Font = Enum.Font.Code
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

-- resolve + close buttons in title
local function TitleBtn(txt, col, xOff, w)
    local b = Instance.new("TextButton", TitleBar)
    b.Size = UDim2.new(0,w,0,22)
    b.Position = UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3 = col
    b.Text = txt b.TextColor3 = Color3.fromRGB(230,230,230)
    b.TextSize = 10 b.Font = Enum.Font.Code b.BorderSizePixel = 0
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,3)
    return b
end
local BtnResolve = TitleBtn("⟳ resolve", Color3.fromRGB(35,60,35), -76, 68)
local BtnClose   = TitleBtn("✕",         Color3.fromRGB(75,22,22), -4,  22)

-- main scroll
local MainSF = Instance.new("ScrollingFrame", Win)
MainSF.Size = UDim2.new(1,-8,1,-40)
MainSF.Position = UDim2.new(0,4,0,36)
MainSF.BackgroundTransparency = 1
MainSF.CanvasSize = UDim2.new(0,0,0,0)
MainSF.ScrollBarThickness = 3
MainSF.ScrollBarImageColor3 = Color3.fromRGB(130,80,200)
local MainLL = Instance.new("UIListLayout", MainSF)
MainLL.Padding = UDim.new(0,5)
MainLL.SortOrder = Enum.SortOrder.LayoutOrder

-- ── UI helpers ───────────────────────────────────────────────
local function RefreshCanvas()
    task.defer(function()
        MainSF.CanvasSize = UDim2.new(0,0,0, MainLL.AbsoluteContentSize.Y + 10)
    end)
end

-- section card
local function Card(title)
    local f = Instance.new("Frame", MainSF)
    f.Size = UDim2.new(1,-6,0,0)  -- height set after children
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.BackgroundColor3 = Color3.fromRGB(24,18,34)
    f.BorderSizePixel = 0
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,5)
    Instance.new("UIPadding",f).PaddingLeft = UDim.new(0,8)
    local ll = Instance.new("UIListLayout",f)
    ll.Padding = UDim.new(0,4)
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    -- header
    local h = Instance.new("TextLabel",f)
    h.Size = UDim2.new(1,-8,0,20)
    h.BackgroundTransparency = 1
    h.Text = title
    h.TextColor3 = Color3.fromRGB(195,155,255)
    h.TextSize = 10 h.Font = Enum.Font.Code
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.LayoutOrder = 0
    return f, ll
end

-- status pill inside a card
local function StatusPill(parent, label, lo)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,-8,0,18)
    f.BackgroundColor3 = Color3.fromRGB(20,20,30)
    f.BorderSizePixel = 0 f.LayoutOrder = lo or 99
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,3)
    local key = Instance.new("TextLabel",f)
    key.Size = UDim2.new(0.44,0,1,0)
    key.BackgroundTransparency = 1
    key.Text = label key.TextColor3 = Color3.fromRGB(155,155,175)
    key.TextSize = 10 key.Font = Enum.Font.Code
    key.TextXAlignment = Enum.TextXAlignment.Left
    local val = Instance.new("TextLabel",f)
    val.Size = UDim2.new(0.56,0,1,0)
    val.Position = UDim2.new(0.44,0,0,0)
    val.BackgroundTransparency = 1
    val.Text = "—" val.TextColor3 = Color3.fromRGB(120,120,140)
    val.TextSize = 10 val.Font = Enum.Font.Code
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.TextTruncate = Enum.TextTruncate.AtEnd
    return val  -- caller updates .Text and .TextColor3
end

-- small button
local function Btn(parent, txt, col, lo)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,-8,0,22)
    b.BackgroundColor3 = col b.Text = txt
    b.TextColor3 = Color3.fromRGB(225,225,225)
    b.TextSize = 10 b.Font = Enum.Font.Code b.BorderSizePixel = 0
    b.LayoutOrder = lo or 99
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,3)
    return b
end

-- result label
local function ResLbl(parent, lo)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1,-8,0,14)
    l.BackgroundTransparency = 1 l.Text = ""
    l.TextColor3 = Color3.fromRGB(140,200,140)
    l.TextSize = 9 l.Font = Enum.Font.Code
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = lo or 100
    return l
end

-- log box: returns (frame, append fn, clear fn)
local function LogBox(parent, h, lo)
    local bg = Instance.new("Frame", parent)
    bg.Size = UDim2.new(1,-8,0,h)
    bg.BackgroundColor3 = Color3.fromRGB(14,14,20)
    bg.BorderSizePixel = 0 bg.LayoutOrder = lo or 99
    Instance.new("UICorner",bg).CornerRadius = UDim.new(0,3)
    local sf = Instance.new("ScrollingFrame", bg)
    sf.Size = UDim2.new(1,-4,1,-4) sf.Position = UDim2.new(0,2,0,2)
    sf.BackgroundTransparency = 1 sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.ScrollBarThickness = 2
    local ll2 = Instance.new("UIListLayout",sf)
    ll2.Padding = UDim.new(0,1) ll2.SortOrder = Enum.SortOrder.LayoutOrder
    local function append(txt, col)
        local l = Instance.new("TextLabel",sf)
        l.Size = UDim2.new(1,0,0,13)
        l.BackgroundTransparency = 1 l.Text = txt
        l.TextColor3 = col or Color3.fromRGB(175,210,175)
        l.TextSize = 9 l.Font = Enum.Font.Code
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextTruncate = Enum.TextTruncate.AtEnd
        task.defer(function()
            sf.CanvasSize = UDim2.new(0,0,0, ll2.AbsoluteContentSize.Y+4)
            sf.CanvasPosition = Vector2.new(0, math.huge)
        end)
    end
    local function clear()
        for _,c in ipairs(sf:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        sf.CanvasSize = UDim2.new(0,0,0,0)
    end
    return bg, append, clear
end

-- text box input row
local function InputBox(parent, placeholder, lo)
    local bg = Instance.new("Frame", parent)
    bg.Size = UDim2.new(1,-8,0,22)
    bg.BackgroundColor3 = Color3.fromRGB(22,22,32)
    bg.BorderSizePixel = 0 bg.LayoutOrder = lo or 99
    Instance.new("UICorner",bg).CornerRadius = UDim.new(0,3)
    local tb = Instance.new("TextBox", bg)
    tb.Size = UDim2.new(1,-8,1,-4) tb.Position = UDim2.new(0,4,0,2)
    tb.BackgroundTransparency = 1
    tb.PlaceholderText = placeholder tb.PlaceholderColor3 = Color3.fromRGB(80,80,80)
    tb.Text = "" tb.TextColor3 = Color3.fromRGB(200,220,200)
    tb.TextSize = 10 tb.Font = Enum.Font.Code
    tb.ClearTextOnFocus = false tb.TextXAlignment = Enum.TextXAlignment.Left
    return tb
end

-- ─────────────────────────────────────────────────────────────
--  BUILD UI SECTIONS
-- ─────────────────────────────────────────────────────────────

-- ══ 1. STATUS ════════════════════════════════════════════════
local statCard = Card("◈  resolution status")
local refs = {"Core","Remote","Anti","Service","Variables","Functions","RemoteEvent","acliLogs","acliKickFn"}
local statPills = {}
for i, name in ipairs(refs) do
    statPills[name] = StatusPill(statCard, name, i)
end

local function UpdateStatus()
    local function pill(name, val)
        local p = statPills[name]
        if not p then return end
        if val then
            p.Text = "✓ found"
            p.TextColor3 = Color3.fromRGB(90,235,130)
        else
            p.Text = "✗ not found"
            p.TextColor3 = Color3.fromRGB(200,80,80)
        end
    end
    pill("Core",        A.Core ~= nil)
    pill("Remote",      A.Remote ~= nil)
    pill("Anti",        A.Anti ~= nil)
    pill("Service",     A.Service ~= nil)
    pill("Variables",   A.Variables ~= nil)
    pill("Functions",   A.Functions ~= nil)
    pill("RemoteEvent", A.RemoteEvent ~= nil)
    pill("acliLogs",    A.acliLogs ~= nil)
    pill("acliKickFn",  A.acliKickFn ~= nil)
    -- show key if available
    if A.key then
        statPills["Core"].Text = "key: "..tostring(A.key)
        statPills["Core"].TextColor3 = Color3.fromRGB(255,215,80)
    end
    RefreshCanvas()
end

-- ══ 2. ANTI-CHEAT NEUTRALISER ════════════════════════════════
local acCard = Card("🛡  anti-cheat neutraliser")

local neutDetBtn  = Btn(acCard, "⚡ neutralise Detected (v_u_44)",  Color3.fromRGB(65,35,12), 1)
local restDetBtn  = Btn(acCard, "↩ restore Detected",               Color3.fromRGB(22,42,22), 2)
local detLbl      = ResLbl(acCard, 3)

local neutAcliBtn = Btn(acCard, "⚡ neutralise ACLI kick (v_u_48)", Color3.fromRGB(65,35,12), 4)
local restAcliBtn = Btn(acCard, "↩ restore ACLI kick",              Color3.fromRGB(22,42,22), 5)
local acliLbl     = ResLbl(acCard, 6)

-- Detected hook state
local _detOrig, _detHooked = nil, false
neutDetBtn.MouseButton1Click:Connect(function()
    if _detHooked then detLbl.Text = "already neutralised" return end
    local fn = A._DetectedFn or (A.Anti and A.Anti.Detected)
    if type(fn) ~= "function" then
        detLbl.Text = "Detected not found — resolve first"
        detLbl.TextColor3 = Color3.fromRGB(255,100,100) return
    end
    _detOrig = fn
    local ok, err = pcall(function()
        hookfn(fn, newcc(function(action, reason, ...)
            print("[AdonisTools] Detected() blocked → "..tostring(action)..": "..tostring(reason))
            return true
        end))
    end)
    if ok then
        _detHooked = true
        detLbl.Text = "✓ kicks/crashes from Detected are blocked"
        detLbl.TextColor3 = Color3.fromRGB(90,235,130)
    else
        detLbl.Text = "hook failed: "..tostring(err)
        detLbl.TextColor3 = Color3.fromRGB(255,100,100)
    end
end)
restDetBtn.MouseButton1Click:Connect(function()
    if _detHooked and _detOrig then
        pcall(hookfn, _detOrig, _detOrig)
        _detHooked = false
        detLbl.Text = "restored"
        detLbl.TextColor3 = Color3.fromRGB(200,200,200)
    end
end)

-- ACLI kick hook state
local _acliOrig, _acliHooked = nil, false
neutAcliBtn.MouseButton1Click:Connect(function()
    if _acliHooked then acliLbl.Text = "already neutralised" return end
    local fn = A.acliKickFn
    if type(fn) ~= "function" then
        acliLbl.Text = "ACLI kick fn not found — resolve first"
        acliLbl.TextColor3 = Color3.fromRGB(255,100,100) return
    end
    _acliOrig = fn
    local ok, err = pcall(function()
        hookfn(fn, newcc(function(reason, ...)
            print("[AdonisTools] ACLI loader kick blocked: "..tostring(reason))
        end))
    end)
    if ok then
        _acliHooked = true
        acliLbl.Text = "✓ ACLI loader kicks blocked"
        acliLbl.TextColor3 = Color3.fromRGB(90,235,130)
    else
        acliLbl.Text = "hook failed: "..tostring(err)
        acliLbl.TextColor3 = Color3.fromRGB(255,100,100)
    end
end)
restAcliBtn.MouseButton1Click:Connect(function()
    if _acliHooked and _acliOrig then
        pcall(hookfn, _acliOrig, _acliOrig)
        _acliHooked = false
        acliLbl.Text = "restored"
        acliLbl.TextColor3 = Color3.fromRGB(200,200,200)
    end
end)

-- ══ 3. KEY INTERCEPT ═════════════════════════════════════════
local keyCard = Card("🔑  key intercept")

local startKeyBtn = Btn(keyCard, "▶ start intercept", Color3.fromRGB(30,50,30), 1)
local stopKeyBtn  = Btn(keyCard, "■ stop",             Color3.fromRGB(55,22,22), 2)
local keyLbl      = ResLbl(keyCard, 3)

local _keyOrig, _keyHooked = nil, false
startKeyBtn.MouseButton1Click:Connect(function()
    if _keyHooked then keyLbl.Text = "already active" return end
    if type(A.Remote) ~= "table" or type(A.Remote.Get) ~= "function" then
        keyLbl.Text = "Remote.Get not found — resolve first"
        keyLbl.TextColor3 = Color3.fromRGB(255,100,100) return
    end
    _keyOrig = A.Remote.Get
    local ok, err = pcall(function()
        hookfn(A.Remote.Get, newcc(function(...)
            local res = _keyOrig(...)
            local req = tostring(select(1,...) or "")
            if req:find("GET_KEY", 1, true) then
                A.key = res
                keyLbl.Text = "✓ key captured: "..tostring(res)
                keyLbl.TextColor3 = Color3.fromRGB(255,215,80)
                print("[AdonisTools] Key: "..tostring(res))
                UpdateStatus()
            end
            return res
        end))
    end)
    if ok then
        _keyHooked = true
        keyLbl.Text = "listening for key..."
        keyLbl.TextColor3 = Color3.fromRGB(90,235,130)
    else
        keyLbl.Text = "hook failed: "..tostring(err)
        keyLbl.TextColor3 = Color3.fromRGB(255,100,100)
    end
end)
stopKeyBtn.MouseButton1Click:Connect(function()
    if _keyHooked and _keyOrig then
        pcall(hookfn, A.Remote.Get, _keyOrig)
        _keyHooked = false
        keyLbl.Text = "stopped"
        keyLbl.TextColor3 = Color3.fromRGB(200,200,200)
    end
end)

-- ══ 4. TABLE DUMP ════════════════════════════════════════════
local dumpCard = Card("🗂  table dump")

local tableNames = {"Core","Remote","Anti","Functions","Variables","Service"}
local dumpSelect = Instance.new("Frame", dumpCard)
dumpSelect.Size = UDim2.new(1,-8,0,22)
dumpSelect.BackgroundColor3 = Color3.fromRGB(22,22,32)
dumpSelect.BorderSizePixel = 0 dumpSelect.LayoutOrder = 1
Instance.new("UICorner",dumpSelect).CornerRadius = UDim.new(0,3)
-- tab buttons across the selector
local tabLL = Instance.new("UIListLayout",dumpSelect)
tabLL.FillDirection = Enum.FillDirection.Horizontal
tabLL.Padding = UDim.new(0,2) tabLL.SortOrder = Enum.SortOrder.LayoutOrder
local selectedTable = "Core"
local tabBtns = {}
for i, name in ipairs(tableNames) do
    local tb = Instance.new("TextButton", dumpSelect)
    tb.Size = UDim2.new(0, 52, 1, -4)
    tb.BackgroundColor3 = (name=="Core") and Color3.fromRGB(60,40,90) or Color3.fromRGB(30,30,44)
    tb.Text = name tb.TextColor3 = Color3.fromRGB(200,200,220)
    tb.TextSize = 9 tb.Font = Enum.Font.Code tb.BorderSizePixel = 0
    tb.LayoutOrder = i
    Instance.new("UICorner",tb).CornerRadius = UDim.new(0,3)
    tabBtns[name] = tb
    tb.MouseButton1Click:Connect(function()
        selectedTable = name
        for n, b in pairs(tabBtns) do
            b.BackgroundColor3 = (n==name) and Color3.fromRGB(60,40,90) or Color3.fromRGB(30,30,44)
        end
    end)
end

local dumpBtn = Btn(dumpCard, "dump selected table", Color3.fromRGB(28,28,50), 2)
local _, dumpAppend, dumpClear = LogBox(dumpCard, 110, 3)

dumpBtn.MouseButton1Click:Connect(function()
    dumpClear()
    local tbl = A[selectedTable]
    if not tbl then
        dumpAppend(selectedTable.." not resolved — hit ⟳ resolve first", Color3.fromRGB(255,100,100))
        return
    end
    local n = 0
    pcall(function()
        for k, v in pairs(tbl) do
            local vt = typeof(v)
            local col = vt=="function" and Color3.fromRGB(150,215,150)
                or vt=="table"    and Color3.fromRGB(190,165,255)
                or Color3.fromRGB(195,205,200)
            dumpAppend("["..vt.."]  "..tostring(k).."  =  "..tostring(v), col)
            n = n + 1
            if n > 100 then dumpAppend("...truncated at 100") break end
        end
    end)
    if n == 0 then dumpAppend("empty or protected", Color3.fromRGB(110,110,110)) end
end)

-- ══ 5. FUNCTION HOOK EDITOR ══════════════════════════════════
local hookCard = Card("⚡  function hook editor")

-- table selector + function name input
local hookTableInput = InputBox(hookCard, "table name: Core / Remote / Anti / Service ...", 1)
local hookFnInput    = InputBox(hookCard, "function key e.g.  GetEvent  or  Send", 2)

-- code editor
local edBg = Instance.new("Frame", hookCard)
edBg.Size = UDim2.new(1,-8,0,120)
edBg.BackgroundColor3 = Color3.fromRGB(18,18,28) edBg.BorderSizePixel = 0 edBg.LayoutOrder = 3
Instance.new("UICorner",edBg).CornerRadius = UDim.new(0,3)
local edBox = Instance.new("TextBox", edBg)
edBox.Size = UDim2.new(1,-8,1,-8) edBox.Position = UDim2.new(0,4,0,4)
edBox.BackgroundTransparency = 1 edBox.MultiLine = true edBox.ClearTextOnFocus = false
edBox.Text = "-- 'original' = original function\n-- args passed as ...\nreturn original(...)"
edBox.TextColor3 = Color3.fromRGB(175,220,175) edBox.TextSize = 10 edBox.Font = Enum.Font.Code
edBox.TextXAlignment = Enum.TextXAlignment.Left edBox.TextYAlignment = Enum.TextYAlignment.Top

local applyHookBtn  = Btn(hookCard, "⚡ apply hook",  Color3.fromRGB(38,60,38), 4)
local removeHookBtn = Btn(hookCard, "✕ remove hook",  Color3.fromRGB(60,22,22), 5)
local hookResLbl    = ResLbl(hookCard, 6)

local _hookOrig, _hookHooked, _hookFnRef = nil, false, nil

applyHookBtn.MouseButton1Click:Connect(function()
    local tblName = hookTableInput.Text:gsub("%s","")
    local fnName  = hookFnInput.Text:gsub("%s","")
    if tblName == "" or fnName == "" then
        hookResLbl.Text = "enter both table and function name"
        hookResLbl.TextColor3 = Color3.fromRGB(255,180,80) return
    end
    local tbl = A[tblName]
    if type(tbl) ~= "table" then
        hookResLbl.Text = tblName.." not resolved"
        hookResLbl.TextColor3 = Color3.fromRGB(255,100,100) return
    end
    local fn = rawget(tbl, fnName)
    if type(fn) ~= "function" then
        -- try nested: "Sub.FnName"
        local sub,key = fnName:match("^(%w+)%.(%w+)$")
        if sub and key then
            local subtbl = rawget(tbl,sub)
            if type(subtbl)=="table" then fn=rawget(subtbl,key) end
        end
    end
    if type(fn) ~= "function" then
        hookResLbl.Text = "function '"..fnName.."' not found in "..tblName
        hookResLbl.TextColor3 = Color3.fromRGB(255,100,100) return
    end
    if _hookHooked then
        pcall(hookfn, _hookFnRef, _hookOrig)
        _hookHooked = false
    end
    local src = "return function(original) return function(...) "..edBox.Text.." end end"
    local ok, wrapper = pcall(loadstring, src)
    if not ok or not wrapper then
        hookResLbl.Text = "syntax error: "..tostring(wrapper)
        hookResLbl.TextColor3 = Color3.fromRGB(255,100,100) return
    end
    local ok2, factory = pcall(wrapper)
    if not ok2 or type(factory) ~= "function" then
        hookResLbl.Text = "compile error: "..tostring(factory)
        hookResLbl.TextColor3 = Color3.fromRGB(255,100,100) return
    end
    _hookFnRef = fn
    _hookOrig  = fn
    local ok3, err = pcall(function()
        hookfn(fn, newcc(factory(fn)))
    end)
    if ok3 then
        _hookHooked = true
        hookResLbl.Text = "✓ hooked "..tblName.."."..fnName
        hookResLbl.TextColor3 = Color3.fromRGB(90,235,130)
    else
        hookResLbl.Text = "hook failed: "..tostring(err)
        hookResLbl.TextColor3 = Color3.fromRGB(255,100,100)
    end
end)

removeHookBtn.MouseButton1Click:Connect(function()
    if _hookHooked and _hookFnRef and _hookOrig then
        pcall(hookfn, _hookFnRef, _hookOrig)
        _hookHooked = false
        hookResLbl.Text = "hook removed"
        hookResLbl.TextColor3 = Color3.fromRGB(200,200,200)
    else
        hookResLbl.Text = "nothing hooked"
    end
end)

-- ══ 6. ACLI LOGS ═════════════════════════════════════════════
local logsCard = Card("📋  acliLogs  (v_u_36)")

local dumpLogsBtn = Btn(logsCard, "dump logs", Color3.fromRGB(28,35,55), 1)
local clearLogsBtn = Btn(logsCard, "clear", Color3.fromRGB(35,28,28), 2)
local _, logsAppend, logsClear = LogBox(logsCard, 100, 3)

dumpLogsBtn.MouseButton1Click:Connect(function()
    logsClear()
    local logs = A.acliLogs
    if not logs then
        logsAppend("acliLogs not found — hit ⟳ resolve first", Color3.fromRGB(255,100,100))
        return
    end
    local n = 0
    for _, entry in ipairs(logs) do
        local col = entry:find("WARNING",1,true) and Color3.fromRGB(255,200,80)
            or entry:find("ACLI-0x",1,true)      and Color3.fromRGB(255,120,120)
            or Color3.fromRGB(175,210,175)
        logsAppend(entry, col)
        n = n + 1
    end
    if n == 0 then logsAppend("log table empty — module may not have initialised yet", Color3.fromRGB(140,140,140)) end
end)
clearLogsBtn.MouseButton1Click:Connect(logsClear)

-- ─────────────────────────────────────────────────────────────
--  RESOLVE BUTTON
-- ─────────────────────────────────────────────────────────────
BtnResolve.MouseButton1Click:Connect(function()
    BtnResolve.Text = "resolving..."
    BtnResolve.BackgroundColor3 = Color3.fromRGB(50,50,30)
    task.spawn(function()
        Resolve()
        UpdateStatus()
        BtnResolve.Text = "⟳ resolve"
        BtnResolve.BackgroundColor3 = Color3.fromRGB(35,60,35)
        print("[AdonisTools] Resolve complete — Core:"..tostring(A.Core~=nil)
            .." Remote:"..tostring(A.Remote~=nil)
            .." Anti:"..tostring(A.Anti~=nil)
            .." acliLogs:"..tostring(A.acliLogs~=nil)
            .." acliKickFn:"..tostring(A.acliKickFn~=nil))
    end)
end)

BtnClose.MouseButton1Click:Connect(function()
    Win.Visible=false G1.Visible=false G2.Visible=false
end)

UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightAlt then
        local v = not Win.Visible
        Win.Visible=v G1.Visible=v G2.Visible=v
    end
end)

-- ─────────────────────────────────────────────────────────────
--  AUTO RESOLVE ON LOAD
-- ─────────────────────────────────────────────────────────────
task.spawn(function()
    task.wait(0.5)  -- let Adonis finish its own init first
    Resolve()
    UpdateStatus()
    RefreshCanvas()
end)

print("[AdonisTools v1] loaded — RightAlt to toggle, ⟳ resolve to find internals")
