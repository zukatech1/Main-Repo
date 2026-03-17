-- ============================================================
--  Callum_AdonisTools  v2.0
--  RightAlt = toggle UI
--  ⟳ = re-link to Adonis
-- ============================================================

local Players  = game:GetService("Players")
local UIS      = game:GetService("UserInputService")
local CoreGui  = game:GetService("CoreGui")
local lp       = Players.LocalPlayer

-- exploit
local hookfn  = hookfunction
local newcc   = newcclosure
local chkcall = checkcaller

-- ─────────────────────────────────────────────────────────────
--  LINK TO ADONIS
--  The client table always has both "Remote" and "Core" as keys.
--  This is the most reliable way to find it — no upvalue walking,
--  no module scanning, just a direct GC search.
-- ─────────────────────────────────────────────────────────────
local adonis = nil  -- the client table

local function FindAdonis()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table"
            and rawget(v, "Remote") ~= nil
            and rawget(v, "Core")   ~= nil
            and type(rawget(v, "Remote")) == "table"
            and type(rawget(v, "Core"))   == "table"
        then
            return v
        end
    end
    return nil
end

-- ─────────────────────────────────────────────────────────────
--  STATE
-- ─────────────────────────────────────────────────────────────
local State = {
    linked          = false,
    key             = nil,
    remoteName      = nil,
    -- hook handles / originals
    getMitm         = false,  _getOrig    = nil,
    sendMitm        = false,  _sendOrig   = nil,
    bytecodeHooked  = false,  _byteOrig   = nil,
    detNeutd        = false,  _detOrig    = nil,
    remoteDestHooked= false,  _destroyOrig= nil,
    globalProxied   = false,
    -- log buffer for MITM
    getLog  = {},
    sendLog = {},
}

-- ─────────────────────────────────────────────────────────────
--  GUI
-- ─────────────────────────────────────────────────────────────
local Root = Instance.new("ScreenGui")
Root.Name = "Callum_AdonisTools_v2"
Root.ResetOnSpawn = false
Root.ZIndexBehavior = Enum.ZIndexBehavior.Global
Root.Parent = (gethui and gethui()) or CoreGui

-- glow
local function MkGlow(w, h, xo, yo, tr, z)
    local f = Instance.new("Frame", Root)
    f.Size = UDim2.new(0,w,0,h)
    f.Position = UDim2.new(0.5,xo,0.5,yo)
    f.BackgroundColor3 = Color3.fromRGB(255,255,255)
    f.BackgroundTransparency = tr
    f.BorderSizePixel = 0 f.ZIndex = z
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,10)
    return f
end
local G2 = MkGlow(408,562,-204,-281,0.93,1)
local G1 = MkGlow(394,548,-197,-274,0.82,2)

local Win = Instance.new("Frame", Root)
Win.Size = UDim2.new(0,376,0,526)
Win.Position = UDim2.new(0.5,-188,0.5,-263)
Win.BackgroundColor3 = Color3.fromRGB(15,15,15)
Win.BackgroundTransparency = 0.1
Win.BorderSizePixel = 0
Win.Active = true Win.Draggable = true Win.ZIndex = 3
Instance.new("UICorner",Win).CornerRadius = UDim.new(0,5)
Win.Parent = Root

do
    local g = Instance.new("UIGradient", Win)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15,15,15)),
    })
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.88),
        NumberSequenceKeypoint.new(0.4, 0.95),
        NumberSequenceKeypoint.new(1,   1.0),
    })
    g.Rotation = 140
end

Win:GetPropertyChangedSignal("Position"):Connect(function()
    local p = Win.Position
    G1.Position = UDim2.new(p.X.Scale,p.X.Offset-9,  p.Y.Scale,p.Y.Offset-11)
    G2.Position = UDim2.new(p.X.Scale,p.X.Offset-16, p.Y.Scale,p.Y.Offset-18)
end)

-- title bar
local TBar = Instance.new("Frame", Win)
TBar.Size = UDim2.new(1,0,0,32)
TBar.BackgroundColor3 = Color3.fromRGB(26,16,40)
TBar.BorderSizePixel = 0
Instance.new("UICorner",TBar).CornerRadius = UDim.new(0,5)

local TLbl = Instance.new("TextLabel", TBar)
TLbl.Size = UDim2.new(1,-100,1,0)
TLbl.Position = UDim2.new(0,10,0,0)
TLbl.BackgroundTransparency = 1
TLbl.Text = "★  adonis tools  v2"
TLbl.TextColor3 = Color3.fromRGB(205,165,255)
TLbl.TextSize = 13 TLbl.Font = Enum.Font.Code
TLbl.TextXAlignment = Enum.TextXAlignment.Left

local LinkLbl = Instance.new("TextLabel", TBar)
LinkLbl.Size = UDim2.new(0,90,1,0)
LinkLbl.Position = UDim2.new(1,-170,0,0)
LinkLbl.BackgroundTransparency = 1
LinkLbl.Text = "not linked"
LinkLbl.TextColor3 = Color3.fromRGB(200,80,80)
LinkLbl.TextSize = 10 LinkLbl.Font = Enum.Font.Code
LinkLbl.TextXAlignment = Enum.TextXAlignment.Right

local function TBtn(txt, col, xo, w)
    local b = Instance.new("TextButton", TBar)
    b.Size = UDim2.new(0,w,0,22)
    b.Position = UDim2.new(1,xo,0.5,-11)
    b.BackgroundColor3 = col b.Text = txt
    b.TextColor3 = Color3.fromRGB(230,230,230)
    b.TextSize = 10 b.Font = Enum.Font.Code b.BorderSizePixel = 0
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,3)
    return b
end
local BtnLink  = TBtn("⟳ link",  Color3.fromRGB(35,55,35), -76, 68)
local BtnClose = TBtn("✕",       Color3.fromRGB(70,20,20), -4,  22)

-- main scroll area
local SF = Instance.new("ScrollingFrame", Win)
SF.Size = UDim2.new(1,-8,1,-40)
SF.Position = UDim2.new(0,4,0,36)
SF.BackgroundTransparency = 1
SF.CanvasSize = UDim2.new(0,0,0,0)
SF.ScrollBarThickness = 3
SF.ScrollBarImageColor3 = Color3.fromRGB(120,70,190)
local SFL = Instance.new("UIListLayout", SF)
SFL.Padding = UDim.new(0,6) SFL.SortOrder = Enum.SortOrder.LayoutOrder

local function RefreshCanvas()
    task.defer(function()
        SF.CanvasSize = UDim2.new(0,0,0, SFL.AbsoluteContentSize.Y + 12)
    end)
end

-- ── widget helpers ───────────────────────────────────────────
-- card container
local function Card(title)
    local f = Instance.new("Frame", SF)
    f.Size = UDim2.new(1,-4,0,0)
    f.AutomaticSize = Enum.AutomaticSize.Y
    f.BackgroundColor3 = Color3.fromRGB(22,16,32)
    f.BorderSizePixel = 0
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,5)
    local pad = Instance.new("UIPadding",f)
    pad.PaddingLeft=UDim.new(0,8) pad.PaddingRight=UDim.new(0,8)
    pad.PaddingTop=UDim.new(0,4)  pad.PaddingBottom=UDim.new(0,6)
    local ll = Instance.new("UIListLayout",f)
    ll.Padding=UDim.new(0,4) ll.SortOrder=Enum.SortOrder.LayoutOrder
    local hdr = Instance.new("TextLabel",f)
    hdr.Size=UDim2.new(1,0,0,18) hdr.BackgroundTransparency=1
    hdr.Text=title hdr.TextColor3=Color3.fromRGB(190,150,255)
    hdr.TextSize=10 hdr.Font=Enum.Font.Code
    hdr.TextXAlignment=Enum.TextXAlignment.Left hdr.LayoutOrder=0
    return f
end

local function Btn(parent, txt, col, lo)
    local b = Instance.new("TextButton", parent)
    b.Size=UDim2.new(1,0,0,22) b.BackgroundColor3=col b.Text=txt
    b.TextColor3=Color3.fromRGB(225,225,225) b.TextSize=10 b.Font=Enum.Font.Code
    b.BorderSizePixel=0 b.LayoutOrder=lo or 99
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    return b
end

local function Lbl(parent, txt, col, lo, h)
    local l = Instance.new("TextLabel", parent)
    l.Size=UDim2.new(1,0,0,h or 14) l.BackgroundTransparency=1
    l.Text=txt l.TextColor3=col or Color3.fromRGB(170,170,170)
    l.TextSize=10 l.Font=Enum.Font.Code
    l.TextXAlignment=Enum.TextXAlignment.Left l.TextWrapped=true
    l.LayoutOrder=lo or 99
    return l
end

local function LogBox(parent, h, lo)
    local bg = Instance.new("Frame", parent)
    bg.Size=UDim2.new(1,0,0,h) bg.BackgroundColor3=Color3.fromRGB(12,12,20)
    bg.BorderSizePixel=0 bg.LayoutOrder=lo or 99
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,3)
    local sf2 = Instance.new("ScrollingFrame", bg)
    sf2.Size=UDim2.new(1,-4,1,-4) sf2.Position=UDim2.new(0,2,0,2)
    sf2.BackgroundTransparency=1 sf2.CanvasSize=UDim2.new(0,0,0,0)
    sf2.ScrollBarThickness=2
    local ll2 = Instance.new("UIListLayout",sf2)
    ll2.Padding=UDim.new(0,1) ll2.SortOrder=Enum.SortOrder.LayoutOrder
    local function append(txt, col)
        local l = Instance.new("TextLabel",sf2)
        l.Size=UDim2.new(1,0,0,13) l.BackgroundTransparency=1
        l.Text=txt l.TextColor3=col or Color3.fromRGB(175,210,175)
        l.TextSize=9 l.Font=Enum.Font.Code
        l.TextXAlignment=Enum.TextXAlignment.Left l.TextTruncate=Enum.TextTruncate.AtEnd
        task.defer(function()
            sf2.CanvasSize=UDim2.new(0,0,0,ll2.AbsoluteContentSize.Y+4)
            sf2.CanvasPosition=Vector2.new(0,math.huge)
        end)
    end
    local function clear()
        for _,c in ipairs(sf2:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        sf2.CanvasSize=UDim2.new(0,0,0,0)
    end
    return append, clear
end

local function InputBox(parent, placeholder, lo)
    local bg = Instance.new("Frame", parent)
    bg.Size=UDim2.new(1,0,0,22) bg.BackgroundColor3=Color3.fromRGB(20,20,30)
    bg.BorderSizePixel=0 bg.LayoutOrder=lo or 99
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,3)
    local tb = Instance.new("TextBox", bg)
    tb.Size=UDim2.new(1,-8,1,-4) tb.Position=UDim2.new(0,4,0,2)
    tb.BackgroundTransparency=1 tb.PlaceholderText=placeholder
    tb.PlaceholderColor3=Color3.fromRGB(75,75,75) tb.Text=""
    tb.TextColor3=Color3.fromRGB(200,220,200) tb.TextSize=10 tb.Font=Enum.Font.Code
    tb.ClearTextOnFocus=false tb.TextXAlignment=Enum.TextXAlignment.Left
    return tb
end

-- ─────────────────────────────────────────────────────────────
--  SECTION 1 — STATUS
-- ─────────────────────────────────────────────────────────────
local statCard = Card("◈  status")
local statLinked  = Lbl(statCard, "not linked",                      Color3.fromRGB(200,80,80),  1)
local statKey     = Lbl(statCard, "key:  waiting...",                Color3.fromRGB(150,150,150),2)
local statRemote  = Lbl(statCard, "remote:  —",                      Color3.fromRGB(150,150,150),3)
local statGet     = Lbl(statCard, "Remote.Get MITM:  off",           Color3.fromRGB(150,150,150),4)
local statSend    = Lbl(statCard, "Remote.Send MITM:  off",          Color3.fromRGB(150,150,150),5)
local statDet     = Lbl(statCard, "Detected neutralised:  no",       Color3.fromRGB(150,150,150),6)
local statByte    = Lbl(statCard, "LoadBytecode hooked:  no",        Color3.fromRGB(150,150,150),7)
local statProxy   = Lbl(statCard, "_G.Adonis proxy:  no",            Color3.fromRGB(150,150,150),8)
local statRemDest = Lbl(statCard, "remote destroy trap:  off",       Color3.fromRGB(150,150,150),9)

local function UpdateStatus()
    if not adonis then
        statLinked.Text="not linked" statLinked.TextColor3=Color3.fromRGB(200,80,80)
        LinkLbl.Text="not linked"    LinkLbl.TextColor3=Color3.fromRGB(200,80,80)
        return
    end
    statLinked.Text="✓ linked to Adonis client table" statLinked.TextColor3=Color3.fromRGB(90,235,130)
    LinkLbl.Text="✓ linked" LinkLbl.TextColor3=Color3.fromRGB(90,235,130)

    local key = State.key or rawget(adonis.Core, "Key")
    statKey.Text = "key:  "..(key and tostring(key) or "not yet received")
    statKey.TextColor3 = key and Color3.fromRGB(255,215,80) or Color3.fromRGB(150,150,150)

    local rname = adonis.RemoteName or rawget(adonis,"RemoteName")
    statRemote.Text = "remote:  "..(rname and tostring(rname) or "—")
    statRemote.TextColor3 = rname and Color3.fromRGB(130,200,255) or Color3.fromRGB(150,150,150)

    local function pill(lbl, on, onTxt, offTxt)
        lbl.Text = on and onTxt or offTxt
        lbl.TextColor3 = on and Color3.fromRGB(90,235,130) or Color3.fromRGB(150,150,150)
    end
    pill(statGet,     State.getMitm,        "Remote.Get MITM:  ✓ active",    "Remote.Get MITM:  off")
    pill(statSend,    State.sendMitm,       "Remote.Send MITM:  ✓ active",   "Remote.Send MITM:  off")
    pill(statDet,     State.detNeutd,       "Detected neutralised:  ✓ yes",  "Detected neutralised:  no")
    pill(statByte,    State.bytecodeHooked, "LoadBytecode hooked:  ✓ yes",   "LoadBytecode hooked:  no")
    pill(statProxy,   State.globalProxied,  "_G.Adonis proxy:  ✓ active",    "_G.Adonis proxy:  no")
    pill(statRemDest, State.remoteDestHooked,"remote destroy trap:  ✓ active","remote destroy trap:  off")
    RefreshCanvas()
end

-- poll for key in background once linked
local function StartKeyPoll()
    task.spawn(function()
        while adonis and not (State.key or rawget(adonis.Core,"Key")) do
            task.wait(0.1)
        end
        if adonis then
            State.key = rawget(adonis.Core,"Key")
            UpdateStatus()
            print("[AdonisTools] Key received: "..tostring(State.key))
        end
    end)
end

-- ─────────────────────────────────────────────────────────────
--  SECTION 2 — MITM  (Remote.Get + Remote.Send)
-- ─────────────────────────────────────────────────────────────
local mitmCard = Card("🔀  remote MITM  (Get + Send)")
local getLogAppend, getLogClear = LogBox(mitmCard, 90, 1)
local sendLogAppend, sendLogClear = LogBox(mitmCard, 70, 2)

local mitmGetBtn  = Btn(mitmCard, "▶ hook Remote.Get",  Color3.fromRGB(28,48,28), 3)
local mitmSendBtn = Btn(mitmCard, "▶ hook Remote.Send", Color3.fromRGB(28,40,55), 4)
local mitmOffBtn  = Btn(mitmCard, "■ remove all MITM",  Color3.fromRGB(55,20,20), 5)
local mitmLbl     = Lbl(mitmCard, "", Color3.fromRGB(140,200,140), 6)

mitmGetBtn.MouseButton1Click:Connect(function()
    if not adonis then mitmLbl.Text="not linked" mitmLbl.TextColor3=Color3.fromRGB(255,100,100) return end
    if State.getMitm then mitmLbl.Text="Get already hooked" return end
    State._getOrig = adonis.Remote.Get
    adonis.Remote.Get = function(key, ...)
        local args = {...}
        local line = "[GET] "..tostring(key)
        if #args > 0 then line = line.."  args: "..table.concat(args,", ") end
        table.insert(State.getLog, line)
        getLogAppend(line,
            tostring(key):find("GET_KEY",1,true) and Color3.fromRGB(255,215,80)
            or tostring(key)=="ExecutePermission" and Color3.fromRGB(255,140,80)
            or Color3.fromRGB(130,210,255))
        if tostring(key) == "ExecutePermission" then
            warn("[AdonisTools] ExecutePermission → FiOne bytecode incoming")
        end
        return State._getOrig(key, ...)
    end
    State.getMitm = true
    mitmLbl.Text="✓ Get hooked" mitmLbl.TextColor3=Color3.fromRGB(90,235,130)
    UpdateStatus()
end)

mitmSendBtn.MouseButton1Click:Connect(function()
    if not adonis then mitmLbl.Text="not linked" mitmLbl.TextColor3=Color3.fromRGB(255,100,100) return end
    if State.sendMitm then mitmLbl.Text="Send already hooked" return end
    State._sendOrig = adonis.Remote.Send
    adonis.Remote.Send = function(key, ...)
        local args = {...}
        -- silently drop detection reports
        if tostring(key)=="Detected" or tostring(args[1])=="Detected" then
            local reason = tostring(args[2] or args[1] or "?")
            local line = "[SEND-SILENCED] "..tostring(key).."  "..reason
            table.insert(State.sendLog, line)
            sendLogAppend(line, Color3.fromRGB(255,120,120))
            warn("[AdonisTools] Dropped detection report: "..reason)
            return nil
        end
        local line = "[SEND] "..tostring(key)
        if #args>0 then line=line.."  args: "..table.concat(args,", ") end
        table.insert(State.sendLog, line)
        sendLogAppend(line, Color3.fromRGB(200,200,130))
        return State._sendOrig(key, ...)
    end
    State.sendMitm = true
    mitmLbl.Text="✓ Send hooked" mitmLbl.TextColor3=Color3.fromRGB(90,235,130)
    UpdateStatus()
end)

mitmOffBtn.MouseButton1Click:Connect(function()
    if not adonis then return end
    if State.getMitm and State._getOrig then
        adonis.Remote.Get = State._getOrig
        State.getMitm=false State._getOrig=nil
    end
    if State.sendMitm and State._sendOrig then
        adonis.Remote.Send = State._sendOrig
        State.sendMitm=false State._sendOrig=nil
    end
    mitmLbl.Text="MITM removed" mitmLbl.TextColor3=Color3.fromRGB(200,200,200)
    UpdateStatus()
end)

Btn(mitmCard,"clear Get log",  Color3.fromRGB(30,30,30),7).MouseButton1Click:Connect(getLogClear)
Btn(mitmCard,"clear Send log", Color3.fromRGB(30,30,30),8).MouseButton1Click:Connect(sendLogClear)

-- ─────────────────────────────────────────────────────────────
--  SECTION 3 — ANTI-CHEAT NEUTRALISER
-- ─────────────────────────────────────────────────────────────
local acCard = Card("🛡  anti-cheat neutraliser")
Lbl(acCard,"hooks Anti.Detected — every kick/crash call is swallowed",Color3.fromRGB(110,110,110),1)
local neutBtn = Btn(acCard,"⚡ neutralise Detected", Color3.fromRGB(62,32,10),2)
local restBtn = Btn(acCard,"↩ restore Detected",     Color3.fromRGB(20,40,20),3)
local acLbl   = Lbl(acCard,"",Color3.fromRGB(140,200,140),4)

neutBtn.MouseButton1Click:Connect(function()
    if not adonis then acLbl.Text="not linked" acLbl.TextColor3=Color3.fromRGB(255,100,100) return end
    if State.detNeutd then acLbl.Text="already neutralised" return end
    local anti = rawget(adonis,"Anti")
    if type(anti)~="table" then acLbl.Text="Anti table not found in adonis" acLbl.TextColor3=Color3.fromRGB(255,100,100) return end
    local det = rawget(anti,"Detected")
    if type(det)~="function" then acLbl.Text="Detected fn not found" acLbl.TextColor3=Color3.fromRGB(255,100,100) return end
    State._detOrig = det
    local ok,err=pcall(function()
        hookfn(det, newcc(function(action, reason, ...)
            warn("[AdonisTools] Detected() swallowed — action="..tostring(action).." reason="..tostring(reason))
            return true
        end))
    end)
    if ok then
        State.detNeutd=true
        acLbl.Text="✓ all kicks/crashes from Detected are blocked"
        acLbl.TextColor3=Color3.fromRGB(90,235,130)
    else
        acLbl.Text="hookfunction failed: "..tostring(err)
        acLbl.TextColor3=Color3.fromRGB(255,100,100)
    end
    UpdateStatus()
end)

restBtn.MouseButton1Click:Connect(function()
    if State.detNeutd and State._detOrig then
        pcall(hookfn, State._detOrig, State._detOrig)
        State.detNeutd=false
        acLbl.Text="restored" acLbl.TextColor3=Color3.fromRGB(200,200,200)
        UpdateStatus()
    end
end)

-- ─────────────────────────────────────────────────────────────
--  SECTION 4 — BYTECODE INTERCEPT
-- ─────────────────────────────────────────────────────────────
local byteCard = Card("🔬  bytecode intercept  (LoadBytecode)")
Lbl(byteCard,"logs every time Adonis pushes a custom script through FiOne",Color3.fromRGB(110,110,110),1)
local byteAppend, byteClear = LogBox(byteCard, 80, 2)
local startByteBtn = Btn(byteCard,"▶ hook LoadBytecode", Color3.fromRGB(28,45,55),3)
local stopByteBtn  = Btn(byteCard,"■ remove hook",       Color3.fromRGB(55,20,20),4)
local byteLbl      = Lbl(byteCard,"",Color3.fromRGB(140,200,140),5)

startByteBtn.MouseButton1Click:Connect(function()
    if not adonis then byteLbl.Text="not linked" byteLbl.TextColor3=Color3.fromRGB(255,100,100) return end
    if State.bytecodeHooked then byteLbl.Text="already hooked" return end
    local core = rawget(adonis,"Core")
    if type(core)~="table" or type(rawget(core,"LoadBytecode"))~="function" then
        byteLbl.Text="LoadBytecode not found in Core"
        byteLbl.TextColor3=Color3.fromRGB(255,100,100) return
    end
    State._byteOrig = rawget(core,"LoadBytecode")
    core.LoadBytecode = function(bytecode, env)
        local preview = type(bytecode)=="string" and bytecode:sub(1,60) or tostring(bytecode)
        local line = "[BYTECODE] len="..(type(bytecode)=="string" and #bytecode or "?").."  preview: "..preview
        byteAppend(line, Color3.fromRGB(255,175,80))
        warn("[AdonisTools] LoadBytecode intercepted — "..line)
        return State._byteOrig(bytecode, env)
    end
    State.bytecodeHooked=true
    byteLbl.Text="✓ hooked — scripts will be logged"
    byteLbl.TextColor3=Color3.fromRGB(90,235,130)
    UpdateStatus()
end)

stopByteBtn.MouseButton1Click:Connect(function()
    if State.bytecodeHooked and State._byteOrig and adonis then
        rawget(adonis,"Core").LoadBytecode = State._byteOrig
        State.bytecodeHooked=false
        byteLbl.Text="removed" byteLbl.TextColor3=Color3.fromRGB(200,200,200)
        UpdateStatus()
    end
end)

Btn(byteCard,"clear log",Color3.fromRGB(30,30,30),6).MouseButton1Click:Connect(byteClear)

-- ─────────────────────────────────────────────────────────────
--  SECTION 5 — REMOTE DESTROY TRAP
-- ─────────────────────────────────────────────────────────────
local rdCard = Card("🔒  remote destroy trap")
Lbl(rdCard,"blocks Adonis from destroying its own RemoteEvent during handshake",Color3.fromRGB(110,110,110),1)
local rdOnBtn  = Btn(rdCard,"▶ activate trap", Color3.fromRGB(28,45,28),2)
local rdOffBtn = Btn(rdCard,"■ remove trap",   Color3.fromRGB(55,20,20),3)
local rdLbl    = Lbl(rdCard,"",Color3.fromRGB(140,200,140),4)

rdOnBtn.MouseButton1Click:Connect(function()
    if not adonis then rdLbl.Text="not linked" rdLbl.TextColor3=Color3.fromRGB(255,100,100) return end
    if State.remoteDestHooked then rdLbl.Text="already active" return end
    local ok,err=pcall(function()
        State._destroyOrig = hookfn(game.Destroy, newcc(function(self, ...)
            if not chkcall() then
                local re = adonis.RemoteEvent
                local reObj = re and (rawget(re,"Object") or re)
                if reObj and self == reObj then
                    warn("[AdonisTools] Blocked RemoteEvent:Destroy() — handshake trap prevented")
                    return nil
                end
            end
            return State._destroyOrig(self, ...)
        end))
    end)
    if ok then
        State.remoteDestHooked=true
        rdLbl.Text="✓ trap active — RemoteEvent destroy blocked"
        rdLbl.TextColor3=Color3.fromRGB(90,235,130)
    else
        rdLbl.Text="hookfunction failed: "..tostring(err)
        rdLbl.TextColor3=Color3.fromRGB(255,100,100)
    end
    UpdateStatus()
end)

rdOffBtn.MouseButton1Click:Connect(function()
    if State.remoteDestHooked and State._destroyOrig then
        pcall(hookfn, game.Destroy, State._destroyOrig)
        State.remoteDestHooked=false
        rdLbl.Text="removed" rdLbl.TextColor3=Color3.fromRGB(200,200,200)
        UpdateStatus()
    end
end)

-- ─────────────────────────────────────────────────────────────
--  SECTION 6 — _G.Adonis PROXY
-- ─────────────────────────────────────────────────────────────
local gpCard = Card("🌐  _G.Adonis proxy")
Lbl(gpCard,"wraps _G.Adonis so every API access is logged",Color3.fromRGB(110,110,110),1)
local gpAppend, gpClear = LogBox(gpCard, 70, 2)
local gpOnBtn  = Btn(gpCard,"▶ install proxy", Color3.fromRGB(28,40,55),3)
local gpOffBtn = Btn(gpCard,"■ remove proxy",  Color3.fromRGB(55,20,20),4)
local gpLbl    = Lbl(gpCard,"",Color3.fromRGB(140,200,140),5)
local _realAPI = nil

gpOnBtn.MouseButton1Click:Connect(function()
    if State.globalProxied then gpLbl.Text="already proxied" return end
    local api = rawget(_G,"Adonis")
    if not api then gpLbl.Text="_G.Adonis not set yet — try after Adonis loads" gpLbl.TextColor3=Color3.fromRGB(255,150,80) return end
    _realAPI = api
    local fakeAPI = newproxy(true)
    local mt = getmetatable(fakeAPI)
    mt.__index = function(_, index)
        local line = "[G-API] accessed: "..tostring(index)
        gpAppend(line, Color3.fromRGB(195,165,255))
        print("[AdonisTools] "..line)
        return _realAPI[index]
    end
    mt.__newindex = function(_, index, value)
        gpAppend("[G-API] write attempt: "..tostring(index).." = "..tostring(value), Color3.fromRGB(255,170,100))
    end
    mt.__metatable = "API"
    rawset(_G, "Adonis", fakeAPI)
    State.globalProxied=true
    gpLbl.Text="✓ proxy installed — all _G.Adonis accesses logged"
    gpLbl.TextColor3=Color3.fromRGB(90,235,130)
    UpdateStatus()
end)

gpOffBtn.MouseButton1Click:Connect(function()
    if State.globalProxied and _realAPI then
        rawset(_G,"Adonis",_realAPI)
        State.globalProxied=false
        gpLbl.Text="removed" gpLbl.TextColor3=Color3.fromRGB(200,200,200)
        UpdateStatus()
    end
end)

Btn(gpCard,"clear log",Color3.fromRGB(30,30,30),6).MouseButton1Click:Connect(gpClear)

-- ─────────────────────────────────────────────────────────────
--  SECTION 7 — TABLE DUMP
-- ─────────────────────────────────────────────────────────────
local tdCard = Card("🗂  table dump")

-- tab selector
local tdTabBar = Instance.new("Frame",tdCard)
tdTabBar.Size=UDim2.new(1,0,0,22) tdTabBar.BackgroundColor3=Color3.fromRGB(18,18,28)
tdTabBar.BorderSizePixel=0 tdTabBar.LayoutOrder=1
Instance.new("UICorner",tdTabBar).CornerRadius=UDim.new(0,3)
local tdTabLL = Instance.new("UIListLayout",tdTabBar)
tdTabLL.FillDirection=Enum.FillDirection.Horizontal
tdTabLL.Padding=UDim.new(0,2) tdTabLL.SortOrder=Enum.SortOrder.LayoutOrder

local tdSelected = "Core"
local tdBtns = {}
for i, name in ipairs({"Core","Remote","Anti","Functions","Variables","Service"}) do
    local b = Instance.new("TextButton",tdTabBar)
    b.Size=UDim2.new(0,54,1,-4) b.LayoutOrder=i
    b.BackgroundColor3=(name=="Core") and Color3.fromRGB(55,35,85) or Color3.fromRGB(28,28,40)
    b.Text=name b.TextColor3=Color3.fromRGB(195,195,215)
    b.TextSize=9 b.Font=Enum.Font.Code b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    tdBtns[name]=b
    b.MouseButton1Click:Connect(function()
        tdSelected=name
        for n,tb in pairs(tdBtns) do
            tb.BackgroundColor3=(n==name) and Color3.fromRGB(55,35,85) or Color3.fromRGB(28,28,40)
        end
    end)
end

local tdAppend, tdClear = LogBox(tdCard, 110, 2)
local tdDumpBtn = Btn(tdCard,"dump",Color3.fromRGB(28,28,50),3)
Btn(tdCard,"clear",Color3.fromRGB(30,30,30),4).MouseButton1Click:Connect(tdClear)

tdDumpBtn.MouseButton1Click:Connect(function()
    tdClear()
    if not adonis then tdAppend("not linked",Color3.fromRGB(255,100,100)) return end
    local tbl = rawget(adonis, tdSelected)
    if type(tbl)~="table" then tdAppend(tdSelected.." not found in adonis table",Color3.fromRGB(255,100,100)) return end
    local n=0
    pcall(function()
        for k,v in pairs(tbl) do
            local vt=typeof(v)
            tdAppend("["..vt.."]  "..tostring(k).."  =  "..tostring(v),
                vt=="function" and Color3.fromRGB(145,210,145)
                or vt=="table" and Color3.fromRGB(185,160,255)
                or Color3.fromRGB(195,205,200))
            n=n+1 if n>120 then tdAppend("...truncated") break end
        end
    end)
    if n==0 then tdAppend("empty or protected",Color3.fromRGB(110,110,110)) end
end)

-- ─────────────────────────────────────────────────────────────
--  SECTION 8 — FUNCTION HOOK EDITOR
-- ─────────────────────────────────────────────────────────────
local fhCard = Card("⚡  function hook editor")
Lbl(fhCard,"table + key to hook, write your replacement below",Color3.fromRGB(110,110,110),1)

local fhTblBox = InputBox(fhCard,"table:  Core  Remote  Anti  Service ...",2)
local fhFnBox  = InputBox(fhCard,"function key:  GetEvent  Send  Detected ...",3)

local fhEdBg = Instance.new("Frame",fhCard)
fhEdBg.Size=UDim2.new(1,0,0,110) fhEdBg.BackgroundColor3=Color3.fromRGB(16,16,26)
fhEdBg.BorderSizePixel=0 fhEdBg.LayoutOrder=4
Instance.new("UICorner",fhEdBg).CornerRadius=UDim.new(0,3)
local fhEd = Instance.new("TextBox",fhEdBg)
fhEd.Size=UDim2.new(1,-8,1,-8) fhEd.Position=UDim2.new(0,4,0,4)
fhEd.BackgroundTransparency=1 fhEd.MultiLine=true fhEd.ClearTextOnFocus=false
fhEd.Text="-- 'original' = original fn\n-- args passed as ...\nreturn original(...)"
fhEd.TextColor3=Color3.fromRGB(170,215,170) fhEd.TextSize=10 fhEd.Font=Enum.Font.Code
fhEd.TextXAlignment=Enum.TextXAlignment.Left fhEd.TextYAlignment=Enum.TextYAlignment.Top

local fhApply  = Btn(fhCard,"⚡ apply",  Color3.fromRGB(35,58,35),5)
local fhRemove = Btn(fhCard,"✕ remove", Color3.fromRGB(58,20,20),6)
local fhLbl    = Lbl(fhCard,"",Color3.fromRGB(140,200,140),7)

local _fhOrig, _fhRef, _fhHooked = nil, nil, false

fhApply.MouseButton1Click:Connect(function()
    if not adonis then fhLbl.Text="not linked" fhLbl.TextColor3=Color3.fromRGB(255,100,100) return end
    local tblName = fhTblBox.Text:gsub("%s","")
    local fnName  = fhFnBox.Text:gsub("%s","")
    if tblName=="" or fnName=="" then fhLbl.Text="fill both fields" fhLbl.TextColor3=Color3.fromRGB(255,180,80) return end

    local tbl = rawget(adonis, tblName)
    if type(tbl)~="table" then fhLbl.Text=tblName.." not found" fhLbl.TextColor3=Color3.fromRGB(255,100,100) return end

    local fn = rawget(tbl, fnName)
    if type(fn)~="function" then
        fhLbl.Text=fnName.." not found in "..tblName
        fhLbl.TextColor3=Color3.fromRGB(255,100,100) return
    end

    -- remove previous hook if any
    if _fhHooked and _fhRef and _fhOrig then
        pcall(hookfn, _fhRef, _fhOrig) _fhHooked=false
    end

    local src = "return function(original) return function(...) "..fhEd.Text.." end end"
    local ok,w = pcall(loadstring,src)
    if not ok or not w then fhLbl.Text="syntax: "..tostring(w) fhLbl.TextColor3=Color3.fromRGB(255,100,100) return end
    local ok2,fac = pcall(w)
    if not ok2 or type(fac)~="function" then fhLbl.Text="compile: "..tostring(fac) fhLbl.TextColor3=Color3.fromRGB(255,100,100) return end

    _fhRef=fn _fhOrig=fn
    local ok3,err = pcall(function() hookfn(fn, newcc(fac(fn))) end)
    if ok3 then
        _fhHooked=true
        fhLbl.Text="✓ hooked "..tblName.."."..fnName
        fhLbl.TextColor3=Color3.fromRGB(90,235,130)
    else
        fhLbl.Text="hookfunction failed: "..tostring(err)
        fhLbl.TextColor3=Color3.fromRGB(255,100,100)
    end
end)

fhRemove.MouseButton1Click:Connect(function()
    if _fhHooked and _fhRef and _fhOrig then
        pcall(hookfn,_fhRef,_fhOrig) _fhHooked=false
        fhLbl.Text="hook removed" fhLbl.TextColor3=Color3.fromRGB(200,200,200)
    else
        fhLbl.Text="nothing hooked"
    end
end)

-- ─────────────────────────────────────────────────────────────
--  SECTION 9 — ACLI LOGS
-- ─────────────────────────────────────────────────────────────
local alCard = Card("📋  acliLogs  (v_u_36)")
Lbl(alCard,"scans GC for the loader log table — contains all ACLI: prefixed entries",Color3.fromRGB(110,110,110),1)
local alAppend, alClear = LogBox(alCard, 100, 2)
local alDumpBtn  = Btn(alCard,"dump acliLogs",Color3.fromRGB(28,35,55),3)
local alClearBtn = Btn(alCard,"clear",        Color3.fromRGB(30,30,30),4)
local alLbl      = Lbl(alCard,"",Color3.fromRGB(140,200,140),5)

alDumpBtn.MouseButton1Click:Connect(function()
    alClear()
    -- find acliLogs via getgc each time (in case it wasn't populated at link time)
    local logs = nil
    pcall(function()
        for _, v in ipairs(getgc(true)) do
            if type(v)=="table" then
                local hasACLI,allStr,n=false,true,0
                for k,val in pairs(v) do
                    n=n+1
                    if type(k)~="number" or type(val)~="string" then allStr=false break end
                    if val:find("ACLI:",1,true) then hasACLI=true end
                    if n>500 then allStr=false break end
                end
                if allStr and hasACLI then logs=v break end
            end
        end
    end)
    if not logs then
        alAppend("not found — Adonis may not have fully loaded yet",Color3.fromRGB(255,120,120))
        alLbl.Text="not found" alLbl.TextColor3=Color3.fromRGB(255,120,120)
        return
    end
    local n=0
    for _,entry in ipairs(logs) do
        local col = entry:find("WARNING",1,true) and Color3.fromRGB(255,200,80)
            or entry:find("ACLI-0x",1,true)      and Color3.fromRGB(255,120,120)
            or Color3.fromRGB(175,210,175)
        alAppend(entry,col) n=n+1
    end
    alLbl.Text=n.." entries" alLbl.TextColor3=Color3.fromRGB(90,235,130)
    if n==0 then alAppend("table found but empty",Color3.fromRGB(140,140,140)) end
end)

alClearBtn.MouseButton1Click:Connect(alClear)

-- ─────────────────────────────────────────────────────────────
--  LINK BUTTON
-- ─────────────────────────────────────────────────────────────
BtnLink.MouseButton1Click:Connect(function()
    BtnLink.Text="linking..."
    task.spawn(function()
        adonis = FindAdonis()
        if adonis then
            State.linked = true
            print("[AdonisTools] Linked — RemoteName: "..tostring(adonis.RemoteName))
            StartKeyPoll()
        else
            warn("[AdonisTools] Could not find Adonis client table in GC")
        end
        UpdateStatus()
        BtnLink.Text="⟳ link"
    end)
end)

BtnClose.MouseButton1Click:Connect(function()
    Win.Visible=false G1.Visible=false G2.Visible=false
end)

UIS.InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode==Enum.KeyCode.RightAlt then
        local v=not Win.Visible
        Win.Visible=v G1.Visible=v G2.Visible=v
    end
end)

-- ─────────────────────────────────────────────────────────────
--  AUTO LINK ON LOAD
-- ─────────────────────────────────────────────────────────────
task.spawn(function()
    task.wait(0.5)
    adonis = FindAdonis()
    if adonis then
        State.linked=true
        print("[AdonisTools] Auto-linked — "..tostring(adonis.RemoteName))
        StartKeyPoll()
    else
        warn("[AdonisTools] Auto-link failed — hit ⟳ link once Adonis loads")
    end
    UpdateStatus()
    RefreshCanvas()
end)

print("[AdonisTools v2] RightAlt = toggle  |  ⟳ link = find Adonis")
