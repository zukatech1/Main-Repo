-- ============================================================
--  Callum_ModuleExplorer  v2.0
--  Scans: ReplicatedStorage, LocalPlayer, CoreGui/RobloxGui
--  Features:
--    - Tree view: Container > Module > Functions
--    - pcall-requires hidden/obfuscated modules
--    - Upvalue count per function
--    - Hook with custom function body (live inject)
--    - Deep metatable unlock + edit
--    - ★ context tab: Adonis-aware upvalue fingerprinting
--    - ★ Adonis panel (dedicated):
--        · resolve Core/Remote/Anti/Functions/Variables/Service
--        · key interceptor (hooks Remote.Get)
--        · RemoteEvent live logger (OnClientEvent tap)
--        · anti-cheat neutraliser (hooks Detected/v_u_44)
--        · _G.Adonis API reader
--        · DebugMode bridge (RunEnvFunc/GetEnvTableMeta)
--        · client table walker (dump any sub-table)
--        · TrackTask/thread viewer
--        · ACLI loader section (ClientMover):
--            - acliLogs (v_u_36) dump
--            - integrity flag (v_u_14) scanner
--            - loader kick fn (v_u_16/v_u_48) neutraliser
--            - ACLI error code reference table
--    - RightAlt to toggle
-- ============================================================

local Players           = game:GetService("Players")
local UserInputService  = game:GetService("UserInputService")
local CoreGui           = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local lp                = Players.LocalPlayer

-- ── EXPLOIT UTILS ───────────────────────────────────────────
local getupvalues     = getupvalues     or function() return {} end
local setupvalue      = setupvalue      or function() end
local hookfunction    = hookfunction    or function() end
local newcclosure     = newcclosure     or function(f) return f end
local iscclosure      = iscclosure      or function() return false end
local islclosure      = islclosure      or function() return false end
local getrawmetatable = getrawmetatable or getmetatable

-- ── GUI ROOT ────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "Callum_ModuleExplorer"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent         = (gethui and gethui()) or CoreGui

local GlowFrame2 = Instance.new("Frame")
GlowFrame2.Size = UDim2.new(0,616,0,556)
GlowFrame2.Position = UDim2.new(0.5,-308,0.5,-278)
GlowFrame2.BackgroundColor3 = Color3.fromRGB(255,255,255)
GlowFrame2.BackgroundTransparency = 0.93
GlowFrame2.BorderSizePixel = 0
GlowFrame2.ZIndex = 1
GlowFrame2.Parent = ScreenGui
Instance.new("UICorner",GlowFrame2).CornerRadius = UDim.new(0,10)

local GlowFrame = Instance.new("Frame")
GlowFrame.Size = UDim2.new(0,600,0,540)
GlowFrame.Position = UDim2.new(0.5,-300,0.5,-270)
GlowFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
GlowFrame.BackgroundTransparency = 0.82
GlowFrame.BorderSizePixel = 0
GlowFrame.ZIndex = 2
GlowFrame.Parent = ScreenGui
Instance.new("UICorner",GlowFrame).CornerRadius = UDim.new(0,8)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,580,0,520)
MainFrame.Position = UDim2.new(0.5,-290,0.5,-260)
MainFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
MainFrame.BackgroundTransparency = 0.18
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 3
MainFrame.Parent = ScreenGui
Instance.new("UICorner",MainFrame).CornerRadius = UDim.new(0,4)

local Grad = Instance.new("UIGradient")
Grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(18,18,18)),
})
Grad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,0.88),
    NumberSequenceKeypoint.new(0.4,0.96),
    NumberSequenceKeypoint.new(1,1.0),
})
Grad.Rotation = 135
Grad.Parent = MainFrame

MainFrame:GetPropertyChangedSignal("Position"):Connect(function()
    local p = MainFrame.Position
    GlowFrame.Position  = UDim2.new(p.X.Scale,p.X.Offset-10,p.Y.Scale,p.Y.Offset-10)
    GlowFrame2.Position = UDim2.new(p.X.Scale,p.X.Offset-18,p.Y.Scale,p.Y.Offset-18)
end)

-- ── TITLE ───────────────────────────────────────────────────
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,30)
Title.BackgroundColor3 = Color3.fromRGB(30,30,30)
Title.Text = "module explorer  v2"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 13
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame
Instance.new("UICorner",Title).CornerRadius = UDim.new(0,4)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.5,0,0,16)
StatusLabel.Position = UDim2.new(0,5,0,33)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "idle"
StatusLabel.TextColor3 = Color3.fromRGB(140,160,255)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

local function MakeTopBtn(txt,color,xOff,w)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,w,0,18)
    b.Position = UDim2.new(1,xOff,0,32)
    b.BackgroundColor3 = color
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(220,220,220)
    b.TextSize = 10
    b.Font = Enum.Font.Code
    b.BorderSizePixel = 0
    b.Parent = MainFrame
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,3)
    return b
end
local AdonisBtn = MakeTopBtn("★ adonis",Color3.fromRGB(60,30,80),-196,72)
local ScanBtn   = MakeTopBtn("⟳ scan",  Color3.fromRGB(40,80,60),-120,60)
local CloseBtn  = MakeTopBtn("✕",       Color3.fromRGB(80,30,30),-56, 50)

-- ── SEARCH ──────────────────────────────────────────────────
local SearchBar = Instance.new("Frame")
SearchBar.Size = UDim2.new(1,-10,0,22)
SearchBar.Position = UDim2.new(0,5,0,53)
SearchBar.BackgroundColor3 = Color3.fromRGB(28,28,36)
SearchBar.BorderSizePixel = 0
SearchBar.Parent = MainFrame
Instance.new("UICorner",SearchBar).CornerRadius = UDim.new(0,3)
local _sil = Instance.new("TextLabel",SearchBar)
_sil.Size=UDim2.new(0,22,1,0) _sil.BackgroundTransparency=1
_sil.Text="🔍" _sil.TextSize=11 _sil.Font=Enum.Font.Code
local SearchBox = Instance.new("TextBox",SearchBar)
SearchBox.Size = UDim2.new(1,-26,1,0)
SearchBox.Position = UDim2.new(0,22,0,0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "search modules or functions..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(90,90,90)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(200,200,200)
SearchBox.TextSize = 11
SearchBox.Font = Enum.Font.Code
SearchBox.ClearTextOnFocus = false
SearchBox.TextXAlignment = Enum.TextXAlignment.Left

-- ── SPLIT ───────────────────────────────────────────────────
local LeftPane = Instance.new("ScrollingFrame")
LeftPane.Size = UDim2.new(0,200,1,-82)
LeftPane.Position = UDim2.new(0,5,0,79)
LeftPane.BackgroundTransparency = 1
LeftPane.CanvasSize = UDim2.new(0,0,0,0)
LeftPane.ScrollBarThickness = 2
LeftPane.Parent = MainFrame
local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0,2)
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.Parent = LeftPane

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0,1,1,-82)
Divider.Position = UDim2.new(0,208,0,79)
Divider.BackgroundColor3 = Color3.fromRGB(50,50,70)
Divider.BorderSizePixel = 0
Divider.Parent = MainFrame

local RightPane = Instance.new("Frame")
RightPane.Size = UDim2.new(1,-218,1,-82)
RightPane.Position = UDim2.new(0,213,0,79)
RightPane.BackgroundTransparency = 1
RightPane.ClipsDescendants = true
RightPane.Parent = MainFrame

-- placeholder
local Placeholder = Instance.new("TextLabel")
Placeholder.Size = UDim2.new(1,0,1,0)
Placeholder.BackgroundTransparency = 1
Placeholder.Text = "select a function\nfrom the tree"
Placeholder.TextColor3 = Color3.fromRGB(60,60,80)
Placeholder.TextSize = 12
Placeholder.Font = Enum.Font.Code
Placeholder.Parent = RightPane

-- detail frame
local DetailFrame = Instance.new("Frame")
DetailFrame.Size = UDim2.new(1,0,1,0)
DetailFrame.BackgroundTransparency = 1
DetailFrame.Visible = false
DetailFrame.Parent = RightPane

local FnHeader = Instance.new("TextLabel")
FnHeader.Size = UDim2.new(1,0,0,22)
FnHeader.BackgroundColor3 = Color3.fromRGB(30,30,46)
FnHeader.Text = ""
FnHeader.TextColor3 = Color3.fromRGB(180,200,255)
FnHeader.TextSize = 11
FnHeader.Font = Enum.Font.Code
FnHeader.TextXAlignment = Enum.TextXAlignment.Left
FnHeader.TextTruncate = Enum.TextTruncate.AtEnd
FnHeader.Parent = DetailFrame
Instance.new("UICorner",FnHeader).CornerRadius = UDim.new(0,3)

local MetaRow = Instance.new("TextLabel")
MetaRow.Size = UDim2.new(1,0,0,16)
MetaRow.Position = UDim2.new(0,0,0,25)
MetaRow.BackgroundTransparency = 1
MetaRow.Text = ""
MetaRow.TextColor3 = Color3.fromRGB(120,140,120)
MetaRow.TextSize = 10
MetaRow.Font = Enum.Font.Code
MetaRow.TextXAlignment = Enum.TextXAlignment.Left
MetaRow.Parent = DetailFrame

local function MakeTab(lbl,xScale,wScale)
    local b = Instance.new("TextButton",DetailFrame)
    b.Size = UDim2.new(wScale or 0.25,-2,0,20)
    b.Position = UDim2.new(xScale,2,0,44)
    b.BackgroundColor3 = Color3.fromRGB(30,30,40)
    b.Text = lbl
    b.TextColor3 = Color3.fromRGB(160,160,200)
    b.TextSize = 10
    b.Font = Enum.Font.Code
    b.BorderSizePixel = 0
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,3)
    return b
end
local TabHook   = MakeTab("⚡ hook",   0,    0.25)
local TabUpvals = MakeTab("📦 upvals", 0.25, 0.25)
local TabMeta   = MakeTab("🔬 meta",   0.5,  0.25)
local TabCtx    = MakeTab("★ context", 0.75, 0.25)

local ContentScroll = Instance.new("ScrollingFrame")
ContentScroll.Size = UDim2.new(1,0,1,-68)
ContentScroll.Position = UDim2.new(0,0,0,68)
ContentScroll.BackgroundTransparency = 1
ContentScroll.CanvasSize = UDim2.new(0,0,0,0)
ContentScroll.ScrollBarThickness = 2
ContentScroll.Parent = DetailFrame

-- adonis panel
local AdonisPanel = Instance.new("Frame")
AdonisPanel.Size = UDim2.new(1,0,1,0)
AdonisPanel.BackgroundTransparency = 1
AdonisPanel.Visible = false
AdonisPanel.ClipsDescendants = true
AdonisPanel.Parent = RightPane

local APScroll = Instance.new("ScrollingFrame")
APScroll.Size = UDim2.new(1,0,1,0)
APScroll.BackgroundTransparency = 1
APScroll.CanvasSize = UDim2.new(0,0,0,0)
APScroll.ScrollBarThickness = 2
APScroll.Parent = AdonisPanel
local APLayout = Instance.new("UIListLayout")
APLayout.Padding = UDim.new(0,4)
APLayout.SortOrder = Enum.SortOrder.LayoutOrder
APLayout.Parent = APScroll

-- ── STATE ───────────────────────────────────────────────────
local ScannedModules = {}
local AllTreeItems   = {}
local ActiveFn, ActiveFnName, ActiveModIdx = nil, nil, nil
local ActiveTab  = "hook"
local AdonisOpen = false

local AC = {
    Core=nil, Remote=nil, Anti=nil, Functions=nil,
    Variables=nil, Service=nil, DetectedFn=nil,
    remoteObj=nil, remoteHook=nil, keyHook=nil,
    key=nil, logLines={},
    -- ACLI (ClientLoader) specific
    acliLogs=nil,       -- v_u_36: internal loader log table
    acliKickFn=nil,     -- v_u_16 / v_u_48: loader-level kick fn
    acliIntegrity=nil,  -- v_u_14: integrity flag (must be true)
    acliLoader=nil,     -- the ClientMover LocalScript itself
    acliFolder=nil,     -- the Client folder passed to the module
}

-- ── GENERIC HELPERS ─────────────────────────────────────────
local function SetStatus(txt,col)
    StatusLabel.Text = txt
    StatusLabel.TextColor3 = col or Color3.fromRGB(140,160,255)
end

local function ClearContent()
    for _,c in pairs(ContentScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    ContentScroll.CanvasSize = UDim2.new(0,0,0,0)
end

local function ContentLayout()
    local l = Instance.new("UIListLayout",ContentScroll)
    l.Padding = UDim.new(0,3)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    return l
end

local function RefreshCanvas(sf,layout)
    task.defer(function()
        local l = layout or sf:FindFirstChildWhichIsA("UIListLayout")
        if l then sf.CanvasSize = UDim2.new(0,0,0,l.AbsoluteContentSize.Y+6) end
    end)
end

local INDENT = {container=0,module=8,fn=18}

local function MakeTreeLabel(text,color,indent,bgColor)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,-4,0,22)
    f.BackgroundColor3 = bgColor or Color3.fromRGB(24,24,24)
    f.BorderSizePixel = 0
    f.Parent = LeftPane
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,3)
    local lbl = Instance.new("TextLabel",f)
    lbl.Size = UDim2.new(1,-(indent+4),1,0)
    lbl.Position = UDim2.new(0,indent+4,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    return f, lbl
end

local function HighlightTab(which)
    ActiveTab = which
    local map = {hook=TabHook,upvalues=TabUpvals,meta=TabMeta,context=TabCtx}
    for k,btn in pairs(map) do
        btn.BackgroundColor3 = (k==which) and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,40)
        btn.TextColor3 = (k==which) and Color3.fromRGB(200,220,255) or Color3.fromRGB(140,140,180)
    end
end

-- ── HOOK TAB ────────────────────────────────────────────────
local function BuildHookTab(fnRef,fnName)
    ClearContent() ContentLayout()
    local info = Instance.new("TextLabel",ContentScroll)
    info.Size=UDim2.new(1,-4,0,24) info.BackgroundTransparency=1
    info.Text="write replacement. 'original' = original fn." info.TextColor3=Color3.fromRGB(120,140,120)
    info.TextSize=10 info.Font=Enum.Font.Code info.TextXAlignment=Enum.TextXAlignment.Left info.TextWrapped=true

    local EdBg = Instance.new("Frame",ContentScroll)
    EdBg.Size=UDim2.new(1,-4,0,160) EdBg.BackgroundColor3=Color3.fromRGB(22,22,32) EdBg.BorderSizePixel=0
    Instance.new("UICorner",EdBg).CornerRadius=UDim.new(0,3)
    local EdBox = Instance.new("TextBox",EdBg)
    EdBox.Size=UDim2.new(1,-6,1,-6) EdBox.Position=UDim2.new(0,3,0,3)
    EdBox.BackgroundTransparency=1 EdBox.Text="-- args: ...\n-- call original: original(...)\nreturn original(...)"
    EdBox.TextColor3=Color3.fromRGB(180,220,180) EdBox.TextSize=10 EdBox.Font=Enum.Font.Code
    EdBox.ClearTextOnFocus=false EdBox.MultiLine=true
    EdBox.TextXAlignment=Enum.TextXAlignment.Left EdBox.TextYAlignment=Enum.TextYAlignment.Top

    local function MkBtn(txt,col)
        local b=Instance.new("TextButton",ContentScroll)
        b.Size=UDim2.new(1,-4,0,24) b.BackgroundColor3=col b.Text=txt
        b.TextColor3=Color3.fromRGB(220,220,220) b.TextSize=11 b.Font=Enum.Font.Code b.BorderSizePixel=0
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
        return b
    end
    local HookBtn   = MkBtn("⚡  apply hook",  Color3.fromRGB(40,70,50))
    local UnhookBtn = MkBtn("✕  remove hook",  Color3.fromRGB(70,30,30))
    local ResLbl = Instance.new("TextLabel",ContentScroll)
    ResLbl.Size=UDim2.new(1,-4,0,20) ResLbl.BackgroundTransparency=1 ResLbl.Text=""
    ResLbl.TextColor3=Color3.fromRGB(140,200,140) ResLbl.TextSize=10 ResLbl.Font=Enum.Font.Code
    ResLbl.TextXAlignment=Enum.TextXAlignment.Left

    local orig=fnRef local hooked,handle=false,nil
    HookBtn.MouseButton1Click:Connect(function()
        local src="return function(original) return function(...) "..EdBox.Text.." end end"
        local ok,w=pcall(loadstring,src)
        if not ok or not w then ResLbl.Text="syntax: "..tostring(w) ResLbl.TextColor3=Color3.fromRGB(255,100,100) return end
        local ok2,fac=pcall(w)
        if not ok2 or type(fac)~="function" then ResLbl.Text="compile: "..tostring(fac) ResLbl.TextColor3=Color3.fromRGB(255,100,100) return end
        local rep=fac(orig)
        local ok3,err=pcall(function() handle=hookfunction(fnRef,newcclosure(rep)) end)
        if ok3 then hooked=true ResLbl.Text="✓ hooked "..fnName ResLbl.TextColor3=Color3.fromRGB(100,255,150)
        else ResLbl.Text="failed: "..tostring(err) ResLbl.TextColor3=Color3.fromRGB(255,100,100) end
    end)
    UnhookBtn.MouseButton1Click:Connect(function()
        if hooked and handle then
            pcall(hookfunction,fnRef,orig) hooked,handle=false,nil
            ResLbl.Text="✓ removed" ResLbl.TextColor3=Color3.fromRGB(255,180,80)
        else ResLbl.Text="not hooked" ResLbl.TextColor3=Color3.fromRGB(160,160,160) end
    end)
    RefreshCanvas(ContentScroll)
end

-- ── UPVALUE TAB ─────────────────────────────────────────────
local function BuildUpvalueTab(fnRef,fnName)
    ClearContent() ContentLayout()
    local uvs={} pcall(function() uvs=getupvalues(fnRef) end)
    if #uvs==0 then
        local l=Instance.new("TextLabel",ContentScroll)
        l.Size=UDim2.new(1,-4,0,22) l.BackgroundTransparency=1 l.Text="no upvalues accessible"
        l.TextColor3=Color3.fromRGB(80,80,100) l.TextSize=10 l.Font=Enum.Font.Code
        l.TextXAlignment=Enum.TextXAlignment.Left
        RefreshCanvas(ContentScroll) return
    end
    for i,v in ipairs(uvs) do
        local vt=typeof(v)
        local Row=Instance.new("Frame",ContentScroll)
        Row.Size=UDim2.new(1,-4,0,26) Row.BackgroundColor3=Color3.fromRGB(26,26,36) Row.BorderSizePixel=0
        Instance.new("UICorner",Row).CornerRadius=UDim.new(0,3)
        local il=Instance.new("TextLabel",Row)
        il.Size=UDim2.new(0,22,1,0) il.BackgroundTransparency=1 il.Text=tostring(i)
        il.TextColor3=Color3.fromRGB(100,100,140) il.TextSize=9 il.Font=Enum.Font.Code
        local tl=Instance.new("TextLabel",Row)
        tl.Size=UDim2.new(0,36,1,0) tl.Position=UDim2.new(0,22,0,0) tl.BackgroundTransparency=1
        tl.Text=vt:sub(1,3):upper() tl.TextColor3=Color3.fromRGB(140,160,255) tl.TextSize=9 tl.Font=Enum.Font.Code
        local vb=Instance.new("TextBox",Row)
        vb.Size=UDim2.new(1,-62,0.85,0) vb.Position=UDim2.new(0,58,0.075,0)
        vb.BackgroundColor3=Color3.fromRGB(32,32,44) vb.Text=tostring(v)
        vb.TextColor3=Color3.fromRGB(200,230,200) vb.TextSize=10 vb.Font=Enum.Font.Code
        vb.ClearTextOnFocus=false vb.TextXAlignment=Enum.TextXAlignment.Left vb.TextTruncate=Enum.TextTruncate.AtEnd
        Instance.new("UICorner",vb).CornerRadius=UDim.new(0,3)
        local ui=i
        vb.FocusLost:Connect(function(enter)
            if not enter then return end
            local nv
            if vt=="number" then nv=tonumber(vb.Text)
            elseif vt=="boolean" then nv=vb.Text:lower()=="true"
            else nv=vb.Text end
            if nv~=nil then pcall(setupvalue,fnRef,ui,nv) end
        end)
    end
    RefreshCanvas(ContentScroll)
end

-- ── META TAB ────────────────────────────────────────────────
local function BuildMetaTab(modTable)
    ClearContent() ContentLayout()
    local mt=nil pcall(function() mt=getrawmetatable(modTable) end)
    if not mt then
        local l=Instance.new("TextLabel",ContentScroll)
        l.Size=UDim2.new(1,-4,0,22) l.BackgroundTransparency=1 l.Text="no metatable"
        l.TextColor3=Color3.fromRGB(80,80,100) l.TextSize=10 l.Font=Enum.Font.Code
        l.TextXAlignment=Enum.TextXAlignment.Left
        RefreshCanvas(ContentScroll) return
    end
    pcall(function() if setreadonly then setreadonly(mt,false) end end)
    local count=0
    for k,v in pairs(mt) do
        local vt=typeof(v)
        local Row=Instance.new("Frame",ContentScroll)
        Row.Size=UDim2.new(1,-4,0,26) Row.BackgroundColor3=Color3.fromRGB(28,24,36) Row.BorderSizePixel=0
        Instance.new("UICorner",Row).CornerRadius=UDim.new(0,3)
        local kl=Instance.new("TextLabel",Row)
        kl.Size=UDim2.new(0.38,0,1,0) kl.BackgroundTransparency=1 kl.Text=tostring(k)
        kl.TextColor3=Color3.fromRGB(200,160,255) kl.TextSize=10 kl.Font=Enum.Font.Code
        kl.TextXAlignment=Enum.TextXAlignment.Left kl.TextTruncate=Enum.TextTruncate.AtEnd
        local tt=Instance.new("TextLabel",Row)
        tt.Size=UDim2.new(0,28,1,0) tt.Position=UDim2.new(0.38,0,0,0) tt.BackgroundTransparency=1
        tt.Text=vt:sub(1,3):upper() tt.TextColor3=Color3.fromRGB(140,160,255) tt.TextSize=9 tt.Font=Enum.Font.Code
        local vb=Instance.new("TextBox",Row)
        vb.Size=UDim2.new(0.62,-32,0.85,0) vb.Position=UDim2.new(0.38,30,0.075,0)
        vb.BackgroundColor3=Color3.fromRGB(32,28,44) vb.Text=tostring(v)
        vb.TextColor3=Color3.fromRGB(220,180,255) vb.TextSize=10 vb.Font=Enum.Font.Code
        vb.ClearTextOnFocus=false vb.TextXAlignment=Enum.TextXAlignment.Left vb.TextTruncate=Enum.TextTruncate.AtEnd
        Instance.new("UICorner",vb).CornerRadius=UDim.new(0,3)
        local mk=k
        vb.FocusLost:Connect(function(enter)
            if not enter then return end
            local nv
            if vt=="number" then nv=tonumber(vb.Text)
            elseif vt=="boolean" then nv=vb.Text:lower()=="true"
            else nv=vb.Text end
            if nv~=nil then pcall(function() mt[mk]=nv end) end
        end)
        count=count+1
    end
    if count==0 then
        local l=Instance.new("TextLabel",ContentScroll)
        l.Size=UDim2.new(1,-4,0,22) l.BackgroundTransparency=1 l.Text="empty metatable"
        l.TextColor3=Color3.fromRGB(80,80,100) l.TextSize=10 l.Font=Enum.Font.Code
        l.TextXAlignment=Enum.TextXAlignment.Left
    end
    RefreshCanvas(ContentScroll)
end

-- ── CONTEXT TAB ─────────────────────────────────────────────
local function BuildContextTab(fnRef,fnName)
    ClearContent() ContentLayout()
    local uvs={} pcall(function() uvs=getupvalues(fnRef) end)

    local function AddRow(lbl,val,col)
        local Row=Instance.new("Frame",ContentScroll)
        Row.Size=UDim2.new(1,-4,0,22) Row.BackgroundColor3=Color3.fromRGB(24,24,34) Row.BorderSizePixel=0
        Instance.new("UICorner",Row).CornerRadius=UDim.new(0,3)
        local ll=Instance.new("TextLabel",Row)
        ll.Size=UDim2.new(0.44,0,1,0) ll.BackgroundTransparency=1 ll.Text=lbl
        ll.TextColor3=Color3.fromRGB(160,160,200) ll.TextSize=10 ll.Font=Enum.Font.Code
        ll.TextXAlignment=Enum.TextXAlignment.Left
        local vl=Instance.new("TextLabel",Row)
        vl.Size=UDim2.new(0.56,0,1,0) vl.Position=UDim2.new(0.44,0,0,0) vl.BackgroundTransparency=1
        vl.Text=tostring(val) vl.TextColor3=col or Color3.fromRGB(200,230,200) vl.TextSize=10 vl.Font=Enum.Font.Code
        vl.TextXAlignment=Enum.TextXAlignment.Left vl.TextTruncate=Enum.TextTruncate.AtEnd
    end

    local ctype="unknown"
    pcall(function()
        if iscclosure(fnRef) then ctype="C closure"
        elseif islclosure(fnRef) then ctype="Lua closure" end
    end)
    AddRow("closure type", ctype)
    AddRow("upvalue count", #uvs)

    -- fingerprint upvalues for Adonis sub-tables
    local found=0
    for i,v in ipairs(uvs) do
        if type(v)=="table" then
            local sig=""
            if v.GetEvent and v.StartAPI then sig="Core"
            elseif v.Send and v.Get and v.Fire then sig="Remote"
            elseif v.Detected and v.AddDetector then sig="Anti"
            elseif v.Wrap and v.UnWrap and v.ReadOnly then sig="Service"
            elseif v.G_Access_Key~=nil then sig="Variables"
            elseif v.SHA256 or v.MakeAdmin then sig="Functions"
            end
            if sig~="" then
                AddRow("upval["..i.."]","★ Adonis."..sig, Color3.fromRGB(220,180,255))
                found=found+1
            end
        elseif type(v)=="function" then
            local uvs2={} pcall(function() uvs2=getupvalues(v) end)
            for _,uv in ipairs(uvs2) do
                if type(uv)=="string" and (uv:find("Kick") or uv:find("crash") or uv:find("Detected")) then
                    AddRow("upval["..i.."]","⚠ possible Detected/anti fn", Color3.fromRGB(255,180,80))
                    found=found+1 break
                end
            end
        end
    end
    if found==0 then AddRow("adonis refs","none in upvalues",Color3.fromRGB(100,100,100)) end
    RefreshCanvas(ContentScroll)
end

-- ── SELECT FUNCTION ─────────────────────────────────────────
local function SelectFunction(fnRef,fnName,modIdx)
    ActiveFn,ActiveFnName,ActiveModIdx = fnRef,fnName,modIdx
    if AdonisOpen then
        AdonisOpen=false AdonisPanel.Visible=false
        AdonisBtn.BackgroundColor3=Color3.fromRGB(60,30,80)
    end
    Placeholder.Visible=false DetailFrame.Visible=true
    FnHeader.Text="  fn  "..fnName
    local ctype="unknown"
    pcall(function()
        if iscclosure(fnRef) then ctype="C closure"
        elseif islclosure(fnRef) then ctype="Lua closure" end
    end)
    local uvc=0 pcall(function() uvc=#getupvalues(fnRef) end)
    MetaRow.Text=ctype.."   upvalues: "..uvc
    HighlightTab(ActiveTab)
    if ActiveTab=="hook" then BuildHookTab(fnRef,fnName)
    elseif ActiveTab=="upvalues" then BuildUpvalueTab(fnRef,fnName)
    elseif ActiveTab=="meta" and ScannedModules[modIdx] then BuildMetaTab(ScannedModules[modIdx].module)
    elseif ActiveTab=="context" then BuildContextTab(fnRef,fnName)
    end
end

TabHook.MouseButton1Click:Connect(function()
    HighlightTab("hook") if ActiveFn then BuildHookTab(ActiveFn,ActiveFnName) end
end)
TabUpvals.MouseButton1Click:Connect(function()
    HighlightTab("upvalues") if ActiveFn then BuildUpvalueTab(ActiveFn,ActiveFnName) end
end)
TabMeta.MouseButton1Click:Connect(function()
    HighlightTab("meta")
    if ActiveFn and ActiveModIdx and ScannedModules[ActiveModIdx] then BuildMetaTab(ScannedModules[ActiveModIdx].module) end
end)
TabCtx.MouseButton1Click:Connect(function()
    HighlightTab("context") if ActiveFn then BuildContextTab(ActiveFn,ActiveFnName) end
end)

-- ════════════════════════════════════════════════════════════
--  ★  ADONIS PANEL
-- ════════════════════════════════════════════════════════════

-- resolve Adonis internals from every available source
local function TryResolveAdonis()
    -- _G.Adonis proxy
    local gapi = rawget(_G,"Adonis")
    if gapi then AC.gAPI = gapi end

    -- getfenv scan over PlayerScripts modules
    local ps = lp:FindFirstChild("PlayerScripts")
    if ps then
        for _,desc in ipairs(ps:GetDescendants()) do
            if desc:IsA("ModuleScript") and not AC.Core then
                pcall(function()
                    local env = getfenv and getfenv(require(desc))
                    if env and env.client and env.client.Core then
                        local c = env.client
                        AC.Core=c.Core AC.Remote=c.Remote AC.Anti=c.Anti
                        AC.Functions=c.Functions AC.Variables=c.Variables
                        AC.Service=env.service
                        if AC.Anti then AC.DetectedFn=AC.Anti.Detected end
                    end
                end)
            end
        end
    end

    -- upvalue walk across all scanned modules
    for _,m in ipairs(ScannedModules) do
        for _,fn in pairs(m.functions) do
            if AC.Core and AC.Remote and AC.Anti and AC.Service then break end
            local uvs={} pcall(function() uvs=getupvalues(fn) end)
            for _,uv in ipairs(uvs) do
                if type(uv)=="table" then
                    if not AC.Core and uv.GetEvent and uv.StartAPI then AC.Core=uv end
                    if not AC.Remote and uv.Send and uv.Get then AC.Remote=uv end
                    if not AC.Anti and uv.Detected and uv.AddDetector then
                        AC.Anti=uv AC.DetectedFn=uv.Detected
                    end
                    if not AC.Service and uv.Wrap and uv.UnWrap and uv.ReadOnly then AC.Service=uv end
                    if not AC.Variables and uv.G_Access_Key~=nil then AC.Variables=uv end
                end
            end
        end
    end

    -- grab remote object from Core
    if AC.Core and AC.Core.RemoteEvent and not AC.remoteObj then
        pcall(function()
            local re=AC.Core.RemoteEvent
            AC.remoteObj = re.Object or re
        end)
    end

    -- fallback: scan RepStorage for RemoteEvent with __FUNCTION child
    if not AC.remoteObj then
        for _,desc in ipairs(ReplicatedStorage:GetDescendants()) do
            if desc:IsA("RemoteEvent") and desc:FindFirstChild("__FUNCTION") then
                AC.remoteObj=desc break
            end
        end
    end

    -- ── ACLI (ClientLoader) resolution ──────────────────────
    -- Look for the ClientMover script via game:GetService("Folder")
    -- It lives as a LocalScript named "ClientMover" inside a Folder service
    pcall(function()
        local folder = game:GetService("Folder")
        if folder then
            local mover = folder:FindFirstChild("ClientMover")
            if mover and mover:IsA("LocalScript") then
                AC.acliLoader = mover
            end
        end
    end)

    -- Walk upvalues of scanned functions to find ACLI internals:
    -- v_u_36 = acliLogs (table of strings), v_u_16/v_u_48 = kick fns, v_u_14 = integrity bool
    for _,m in ipairs(ScannedModules) do
        for _,fn in pairs(m.functions) do
            if AC.acliLogs then break end
            local uvs={} pcall(function() uvs=getupvalues(fn) end)
            for _,uv in ipairs(uvs) do
                -- acliLogs: a plain table of strings (log accumulator)
                if not AC.acliLogs and type(uv)=="table" then
                    local isLogTable=true local strCount=0
                    for _,v in pairs(uv) do
                        if type(v)~="string" then isLogTable=false break end
                        strCount=strCount+1
                    end
                    if isLogTable and strCount>0 then
                        -- check if any entry contains "ACLI:"
                        for _,v in pairs(uv) do
                            if type(v)=="string" and v:find("ACLI") then
                                AC.acliLogs=uv break
                            end
                        end
                    end
                end
            end
        end
    end

    return AC.Core~=nil
end

-- AP ui helpers
local function APClear()
    for _,c in pairs(APScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
end

local function APHeader(txt)
    local f=Instance.new("Frame",APScroll)
    f.Size=UDim2.new(1,-4,0,20) f.BackgroundColor3=Color3.fromRGB(40,30,60) f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-6,1,0) l.Position=UDim2.new(0,6,0,0) l.BackgroundTransparency=1
    l.Text=txt l.TextColor3=Color3.fromRGB(200,160,255) l.TextSize=10 l.Font=Enum.Font.Code
    l.TextXAlignment=Enum.TextXAlignment.Left
    return f
end

local function APBtn(txt,color)
    local b=Instance.new("TextButton",APScroll)
    b.Size=UDim2.new(1,-4,0,22) b.BackgroundColor3=color b.Text=txt
    b.TextColor3=Color3.fromRGB(220,220,220) b.TextSize=10 b.Font=Enum.Font.Code b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    return b
end

local function APInfo(txt,color)
    local l=Instance.new("TextLabel",APScroll)
    l.Size=UDim2.new(1,-4,0,16) l.BackgroundTransparency=1 l.Text=txt
    l.TextColor3=color or Color3.fromRGB(180,180,180) l.TextSize=10 l.Font=Enum.Font.Code
    l.TextXAlignment=Enum.TextXAlignment.Left l.TextWrapped=true
    return l
end

local function APLogBox(height)
    local bg=Instance.new("Frame",APScroll)
    bg.Size=UDim2.new(1,-4,0,height) bg.BackgroundColor3=Color3.fromRGB(20,20,28) bg.BorderSizePixel=0
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,3)
    local sf=Instance.new("ScrollingFrame",bg)
    sf.Size=UDim2.new(1,-4,1,-4) sf.Position=UDim2.new(0,2,0,2)
    sf.BackgroundTransparency=1 sf.CanvasSize=UDim2.new(0,0,0,0) sf.ScrollBarThickness=2
    local ll=Instance.new("UIListLayout",sf)
    ll.Padding=UDim.new(0,1) ll.SortOrder=Enum.SortOrder.LayoutOrder
    return sf,ll
end

local function LogLine(sf,ll,txt,color)
    local l=Instance.new("TextLabel",sf)
    l.Size=UDim2.new(1,0,0,14) l.BackgroundTransparency=1 l.Text=txt
    l.TextColor3=color or Color3.fromRGB(180,200,180) l.TextSize=9 l.Font=Enum.Font.Code
    l.TextXAlignment=Enum.TextXAlignment.Left l.TextTruncate=Enum.TextTruncate.AtEnd
    task.defer(function()
        sf.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+4)
        sf.CanvasPosition=Vector2.new(0,math.huge)
    end)
end

-- ── BUILD ADONIS PANEL ──────────────────────────────────────
local function BuildAdonisPanel()
    APClear()
    local resolved = TryResolveAdonis()

    -- ── overview
    APHeader("★  adonis internals")
    APInfo(resolved and "✓ resolved" or "✗ not resolved — scan first",
        resolved and Color3.fromRGB(100,255,150) or Color3.fromRGB(255,100,100))
    APInfo("Core: "..tostring(AC.Core~=nil).."  Remote: "..tostring(AC.Remote~=nil)
        .."  Anti: "..tostring(AC.Anti~=nil))
    APInfo("Key: "..(AC.key or (AC.Core and AC.Core.Key and tostring(AC.Core.Key)) or "not retrieved"),
        Color3.fromRGB(255,220,100))

    -- ── key intercept
    APHeader("🔑  key intercept")
    APInfo("hooks Remote.Get to catch the key as it arrives from the server",Color3.fromRGB(140,140,140))
    local startKeyBtn = APBtn("▶  start intercept", Color3.fromRGB(40,60,40))
    local stopKeyBtn  = APBtn("■  stop intercept",  Color3.fromRGB(60,30,30))
    local keyLbl      = APInfo("idle")
    local _keyOrig, _keyHooked = nil, false

    startKeyBtn.MouseButton1Click:Connect(function()
        if _keyHooked then keyLbl.Text="already active" return end
        if not AC.Remote or not AC.Remote.Get then
            keyLbl.Text="Remote.Get not found" keyLbl.TextColor3=Color3.fromRGB(255,100,100) return
        end
        _keyOrig = AC.Remote.Get
        local ok,err=pcall(function()
            hookfunction(AC.Remote.Get, newcclosure(function(...)
                local res = _keyOrig(...)
                local req = tostring(select(1,...) or "")
                if req:find("GET_KEY") then
                    AC.key = res
                    keyLbl.Text="✓ key: "..tostring(res)
                    keyLbl.TextColor3=Color3.fromRGB(100,255,150)
                    print("[ModuleExplorer] Adonis key: "..tostring(res))
                end
                return res
            end))
        end)
        if ok then _keyHooked=true keyLbl.Text="listening..." keyLbl.TextColor3=Color3.fromRGB(255,220,80)
        else keyLbl.Text="hook failed: "..tostring(err) keyLbl.TextColor3=Color3.fromRGB(255,100,100) end
    end)
    stopKeyBtn.MouseButton1Click:Connect(function()
        if _keyHooked and _keyOrig then
            pcall(hookfunction,AC.Remote.Get,_keyOrig)
            _keyHooked=false keyLbl.Text="stopped" keyLbl.TextColor3=Color3.fromRGB(160,160,160)
        end
    end)

    -- ── remote logger
    APHeader("📡  remote event logger")
    APInfo("taps OnClientEvent — logs every server→client call",Color3.fromRGB(140,140,140))
    local startLogBtn = APBtn("▶  start",  Color3.fromRGB(30,50,70))
    local stopLogBtn  = APBtn("■  stop",   Color3.fromRGB(60,30,30))
    local clearLogBtn = APBtn("✕  clear",  Color3.fromRGB(40,40,40))
    local logStatus   = APInfo("idle")
    local logSF,logLL = APLogBox(90)

    startLogBtn.MouseButton1Click:Connect(function()
        if AC.remoteHook then logStatus.Text="already logging" return end
        if not AC.remoteObj then
            logStatus.Text="RemoteEvent not found" logStatus.TextColor3=Color3.fromRGB(255,100,100) return
        end
        AC.remoteHook = AC.remoteObj.OnClientEvent:Connect(function(...)
            local args={...} local parts={}
            for i,a in ipairs(args) do parts[i]=tostring(a) end
            local line="→ "..table.concat(parts," | ")
            table.insert(AC.logLines,line)
            LogLine(logSF,logLL,line,Color3.fromRGB(140,220,255))
        end)
        logStatus.Text="✓ logging "..AC.remoteObj.Name
        logStatus.TextColor3=Color3.fromRGB(100,255,150)
    end)
    stopLogBtn.MouseButton1Click:Connect(function()
        if AC.remoteHook then
            AC.remoteHook:Disconnect() AC.remoteHook=nil
            logStatus.Text="stopped" logStatus.TextColor3=Color3.fromRGB(160,160,160)
        end
    end)
    clearLogBtn.MouseButton1Click:Connect(function()
        AC.logLines={}
        for _,c in pairs(logSF:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
        logSF.CanvasSize=UDim2.new(0,0,0,0)
    end)

    -- ── anti-cheat neutraliser
    APHeader("🛡  anti-cheat neutraliser")
    APInfo("hooks Detected (v_u_44) so all kicks/crashes from the anti loop are swallowed",Color3.fromRGB(140,140,140))
    local neutBtn    = APBtn("⚡  neutralise Detected", Color3.fromRGB(70,40,20))
    local restoreBtn = APBtn("↩  restore Detected",    Color3.fromRGB(30,50,30))
    local antiLbl    = APInfo("idle")
    local _antOrig,_antHooked=nil,false

    neutBtn.MouseButton1Click:Connect(function()
        if _antHooked then antiLbl.Text="already neutralised" return end
        local detFn = AC.DetectedFn or (AC.Anti and AC.Anti.Detected)
        if not detFn then
            antiLbl.Text="Detected fn not found" antiLbl.TextColor3=Color3.fromRGB(255,100,100) return
        end
        _antOrig=detFn
        local ok,err=pcall(function()
            hookfunction(detFn, newcclosure(function(action,reason,...)
                print("[ModuleExplorer] Detected() blocked → "..tostring(action)..": "..tostring(reason))
                return true
            end))
        end)
        if ok then _antHooked=true antiLbl.Text="✓ neutralised — kicks/crashes blocked" antiLbl.TextColor3=Color3.fromRGB(100,255,150)
        else antiLbl.Text="hook failed: "..tostring(err) antiLbl.TextColor3=Color3.fromRGB(255,100,100) end
    end)
    restoreBtn.MouseButton1Click:Connect(function()
        if _antHooked and _antOrig then
            pcall(hookfunction,_antOrig,_antOrig) _antHooked=false
            antiLbl.Text="restored" antiLbl.TextColor3=Color3.fromRGB(200,200,200)
        end
    end)

    -- ── _G API reader
    APHeader("🔍  _G.Adonis API reader")
    APInfo("probes known keys through the proxy's __index guard",Color3.fromRGB(140,140,140))
    local readBtn  = APBtn("▶  read _G.Adonis", Color3.fromRGB(30,40,70))
    local apiSF,apiLL = APLogBox(80)
    readBtn.MouseButton1Click:Connect(function()
        for _,c in pairs(apiSF:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
        local api=rawget(_G,"Adonis")
        if not api then LogLine(apiSF,apiLL,"_G.Adonis not set yet",Color3.fromRGB(255,120,120)) return end
        for _,k in ipairs({"Access","Scripts","Debug","Service","API_Specific"}) do
            local ok,v=pcall(function() return api[k] end)
            LogLine(apiSF,apiLL,k.." = "..(ok and typeof(v).." "..tostring(v) or "protected"),
                ok and Color3.fromRGB(200,180,255) or Color3.fromRGB(120,120,120))
        end
        local ok2,s=pcall(function() return api.Scripts end)
        if ok2 and s then
            LogLine(apiSF,apiLL,"Scripts.ExecutePermission = "..type(s.ExecutePermission),Color3.fromRGB(180,220,180))
        end
    end)

    -- ── debug bridge
    APHeader("🧪  DebugMode bridge")
    APInfo("requires DebugMode=true and Adonis_Debug_API in ReplicatedStorage",Color3.fromRGB(140,140,140))
    local dbBg=Instance.new("Frame",APScroll)
    dbBg.Size=UDim2.new(1,-4,0,22) dbBg.BackgroundColor3=Color3.fromRGB(26,26,36) dbBg.BorderSizePixel=0
    Instance.new("UICorner",dbBg).CornerRadius=UDim.new(0,3)
    local dbBox=Instance.new("TextBox",dbBg)
    dbBox.Size=UDim2.new(1,-6,1,-2) dbBox.Position=UDim2.new(0,3,0,1)
    dbBox.BackgroundTransparency=1 dbBox.PlaceholderText="env path e.g. Client.Core.Key"
    dbBox.PlaceholderColor3=Color3.fromRGB(70,70,70) dbBox.Text=""
    dbBox.TextColor3=Color3.fromRGB(200,220,200) dbBox.TextSize=10 dbBox.Font=Enum.Font.Code
    dbBox.ClearTextOnFocus=false dbBox.TextXAlignment=Enum.TextXAlignment.Left
    local runEnvBtn  = APBtn("RunEnvFunc",          Color3.fromRGB(40,50,30))
    local getMetaBtn = APBtn("GetEnvTableMeta",     Color3.fromRGB(30,40,50))
    local dbLbl      = APInfo("idle")

    local function GetDbgAPI() return ReplicatedStorage:FindFirstChild("Adonis_Debug_API") end
    runEnvBtn.MouseButton1Click:Connect(function()
        local dbg=GetDbgAPI()
        if not dbg then dbLbl.Text="Adonis_Debug_API not found (DebugMode off?)" dbLbl.TextColor3=Color3.fromRGB(255,100,100) return end
        if dbBox.Text=="" then dbLbl.Text="enter a path" return end
        local ok,res=pcall(function() return dbg:InvokeServer("RunEnvFunc",{dbBox.Text}) end)
        dbLbl.Text=(ok and tostring(res) or "error: "..tostring(res))
        dbLbl.TextColor3=ok and Color3.fromRGB(180,255,180) or Color3.fromRGB(255,100,100)
    end)
    getMetaBtn.MouseButton1Click:Connect(function()
        local dbg=GetDbgAPI()
        if not dbg then dbLbl.Text="not found" return end
        if dbBox.Text=="" then dbLbl.Text="enter a path" return end
        local ok,res=pcall(function() return dbg:InvokeServer("GetEnvTableMeta",{dbBox.Text}) end)
        dbLbl.Text=(ok and tostring(res) or "error: "..tostring(res))
        dbLbl.TextColor3=ok and Color3.fromRGB(180,255,180) or Color3.fromRGB(255,100,100)
    end)

    -- ── table walker
    APHeader("🗂  client table walker")
    APInfo("dumps keys from any resolved Adonis sub-table",Color3.fromRGB(140,140,140))
    for _,tname in ipairs({"Core","Remote","Anti","Functions","Variables","Service"}) do
        local btn=APBtn("dump "..tname, Color3.fromRGB(30,30,50))
        local dSF,dLL=APLogBox(60)
        btn.MouseButton1Click:Connect(function()
            for _,c in pairs(dSF:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
            local tbl=AC[tname]
            if not tbl then LogLine(dSF,dLL,tname.." not resolved",Color3.fromRGB(255,120,120)) return end
            local count=0
            pcall(function()
                for k,v in pairs(tbl) do
                    local vt=typeof(v)
                    local col=vt=="function" and Color3.fromRGB(160,220,160)
                        or vt=="table" and Color3.fromRGB(200,180,255)
                        or Color3.fromRGB(200,210,200)
                    LogLine(dSF,dLL,"["..vt.."] "..tostring(k).." = "..tostring(v),col)
                    count=count+1
                    if count>80 then LogLine(dSF,dLL,"...truncated",Color3.fromRGB(100,100,100)) break end
                end
            end)
            if count==0 then LogLine(dSF,dLL,"empty or protected",Color3.fromRGB(120,120,120)) end
        end)
    end

    -- ── task viewer
    APHeader("⏱  TrackTask viewer")
    APInfo("reads Service.GetTasks() for running tracked threads",Color3.fromRGB(140,140,140))
    local refreshBtn=APBtn("↺  refresh tasks",Color3.fromRGB(30,50,50))
    local taskSF,taskLL=APLogBox(80)
    refreshBtn.MouseButton1Click:Connect(function()
        for _,c in pairs(taskSF:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
        local svc=AC.Service
        if not svc then LogLine(taskSF,taskLL,"Service not resolved",Color3.fromRGB(255,120,120)) return end
        local ok,tasks=pcall(function() return svc.GetTasks() end)
        if not ok or type(tasks)~="table" then
            LogLine(taskSF,taskLL,"GetTasks() unavailable: "..tostring(tasks),Color3.fromRGB(255,120,120)) return
        end
        local count=0
        for _,t in pairs(tasks) do
            local isThread=t.isThread and " [thread]" or ""
            LogLine(taskSF,taskLL,tostring(t.Name or "?").." | "..tostring(t.Status or "?")..isThread,Color3.fromRGB(180,220,180))
            count=count+1
        end
        if count==0 then LogLine(taskSF,taskLL,"no tasks",Color3.fromRGB(120,120,120)) end
    end)

    -- ── ACLI loader section
    APHeader("📦  ACLI loader (ClientMover)")
    APInfo("internals of the ClientLoader script — v_u_36 logs, integrity flag, kick fn",Color3.fromRGB(140,140,140))

    -- loader status row
    local loaderLbl = APInfo(
        AC.acliLoader and ("✓ ClientMover found: "..AC.acliLoader:GetFullName())
            or "ClientMover not located (Folder service may be inaccessible)",
        AC.acliLoader and Color3.fromRGB(100,255,150) or Color3.fromRGB(180,180,100)
    )

    -- acliLogs dump
    local logsBtn = APBtn("📋  dump acliLogs (v_u_36)", Color3.fromRGB(30,40,60))
    local logsDumpSF, logsDumpLL = APLogBox(80)
    logsBtn.MouseButton1Click:Connect(function()
        for _,c in pairs(logsDumpSF:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
        -- try to get acliLogs from the loaded module's upvalues first
        local logs = AC.acliLogs
        -- fallback: scan all scanned module fns for it again
        if not logs then
            for _,m in ipairs(ScannedModules) do
                for _,fn in pairs(m.functions) do
                    if logs then break end
                    local uvs={} pcall(function() uvs=getupvalues(fn) end)
                    for _,uv in ipairs(uvs) do
                        if type(uv)=="table" then
                            for _,v in pairs(uv) do
                                if type(v)=="string" and v:find("ACLI") then
                                    logs=uv AC.acliLogs=uv break
                                end
                            end
                        end
                    end
                end
            end
        end
        if not logs then
            LogLine(logsDumpSF,logsDumpLL,"acliLogs not found — try scanning first",Color3.fromRGB(255,120,120))
            return
        end
        local count=0
        for _,entry in ipairs(logs) do
            local col = entry:find("WARNING") and Color3.fromRGB(255,200,80)
                or entry:find("ACLI-0x") and Color3.fromRGB(255,120,120)
                or Color3.fromRGB(180,220,180)
            LogLine(logsDumpSF,logsDumpLL,entry,col)
            count=count+1
        end
        if count==0 then LogLine(logsDumpSF,logsDumpLL,"log table is empty",Color3.fromRGB(120,120,120)) end
        print("[ModuleExplorer] acliLogs dump: "..count.." entries")
    end)

    -- integrity flag reader
    APInfo("integrity flag (v_u_14) — must be true after proxy require check passes",Color3.fromRGB(140,140,140))
    local integrityBtn = APBtn("🔎  scan for integrity flag (v_u_14)", Color3.fromRGB(30,30,50))
    local integrityLbl = APInfo("idle")
    integrityBtn.MouseButton1Click:Connect(function()
        -- v_u_14 is a boolean upvalue that starts false, set to true only if the
        -- proxy require check passes. We scan all fns for a boolean upvalue
        -- sitting alongside v_u_16-style kick functions.
        local found=false
        for _,m in ipairs(ScannedModules) do
            for _,fn in pairs(m.functions) do
                if found then break end
                local uvs={} pcall(function() uvs=getupvalues(fn) end)
                local hasBool,hasKick=false,false
                local boolIdx=nil
                for i,uv in ipairs(uvs) do
                    if type(uv)=="boolean" then hasBool=true boolIdx=i end
                    if type(uv)=="function" then
                        local uvs2={} pcall(function() uvs2=getupvalues(uv) end)
                        for _,uv2 in ipairs(uvs2) do
                            if type(uv2)=="string" and uv2:find("ACLI") then hasKick=true break end
                        end
                    end
                end
                if hasBool and hasKick and boolIdx then
                    local val=uvs[boolIdx]
                    integrityLbl.Text="v_u_14 = "..tostring(val).." (upval["..boolIdx.."] of "..m.name..")"
                    integrityLbl.TextColor3 = val and Color3.fromRGB(100,255,150) or Color3.fromRGB(255,120,120)
                    AC.acliIntegrity = val
                    found=true
                end
            end
        end
        if not found then
            integrityLbl.Text="not found in scanned modules"
            integrityLbl.TextColor3=Color3.fromRGB(160,160,160)
        end
    end)

    -- loader kick fn neutraliser (v_u_16 / v_u_48)
    APInfo("hooks the loader-level kick fn (v_u_16/v_u_48) — separate from Anti.Detected",Color3.fromRGB(140,140,140))
    local neutLoaderBtn  = APBtn("⚡  neutralise loader kick (v_u_16)", Color3.fromRGB(70,40,20))
    local restLoaderBtn  = APBtn("↩  restore loader kick",             Color3.fromRGB(30,50,30))
    local loaderKickLbl  = APInfo("idle")
    local _lkOrig, _lkHooked = nil, false

    neutLoaderBtn.MouseButton1Click:Connect(function()
        if _lkHooked then loaderKickLbl.Text="already neutralised" return end
        -- Find v_u_48 (the public kick wrapper) by scanning upvalues for a function
        -- that itself has v_u_31 (Player.Kick) as an upvalue
        local kickFn=nil
        for _,m in ipairs(ScannedModules) do
            if kickFn then break end
            for _,fn in pairs(m.functions) do
                if kickFn then break end
                local uvs={} pcall(function() uvs=getupvalues(fn) end)
                for _,uv in ipairs(uvs) do
                    if type(uv)=="function" then
                        local uvs2={} pcall(function() uvs2=getupvalues(uv) end)
                        local hasKickStr,hasPlayerRef=false,false
                        for _,uv2 in ipairs(uvs2) do
                            if type(uv2)=="string" and uv2:find("ACLI") then hasKickStr=true end
                            -- v_u_31 is Player.Kick — a C function
                            if type(uv2)=="function" then
                                local ok,n=pcall(debug.info,uv2,"n")
                                if ok and n=="Kick" then hasPlayerRef=true end
                            end
                        end
                        if hasKickStr and hasPlayerRef then kickFn=uv end
                    end
                end
            end
        end
        if not kickFn then
            loaderKickLbl.Text="loader kick fn not found in upvalues"
            loaderKickLbl.TextColor3=Color3.fromRGB(255,120,120)
            return
        end
        _lkOrig=kickFn
        local ok,err=pcall(function()
            hookfunction(kickFn, newcclosure(function(reason,...)
                print("[ModuleExplorer] ACLI loader kick blocked → "..tostring(reason))
                -- do NOT call original — swallow it entirely
            end))
        end)
        if ok then
            _lkHooked=true
            loaderKickLbl.Text="✓ loader kick neutralised"
            loaderKickLbl.TextColor3=Color3.fromRGB(100,255,150)
            AC.acliKickFn=kickFn
            print("[ModuleExplorer] ACLI v_u_48 neutralised")
        else
            loaderKickLbl.Text="hook failed: "..tostring(err)
            loaderKickLbl.TextColor3=Color3.fromRGB(255,100,100)
        end
    end)
    restLoaderBtn.MouseButton1Click:Connect(function()
        if _lkHooked and _lkOrig then
            pcall(hookfunction,_lkOrig,_lkOrig)
            _lkHooked=false
            loaderKickLbl.Text="restored"
            loaderKickLbl.TextColor3=Color3.fromRGB(200,200,200)
        end
    end)

    -- ACLI error code reference
    APHeader("🗒  ACLI error code reference")
    local errorCodes = {
        {"0x6E2FA164","Environment integrity violation (env tampered)"},
        {"0xEC7E1",   "Proxy __index triggered"},
        {"0x28AEC",   "Proxy __newindex triggered"},
        {"0x36F14",   "Proxy __tostring triggered"},
        {"0x213A7768D","CallCheck: Instance locked"},
        {"0xBC34ADD8","CallCheck: caller fenv mismatch"},
        {"0x20D21CEE7","Module failed to load (require error)"},
        {"0x102134B1E","Bad module return (not SUCCESS)"},
        {"0xCE8CEF67","Bad module return (invalid metatable)"},
    }
    local ecSF,ecLL=APLogBox(110)
    for _,pair in ipairs(errorCodes) do
        LogLine(ecSF,ecLL,pair[1].."  →  "..pair[2], Color3.fromRGB(255,180,100))
    end

    RefreshCanvas(APScroll,APLayout)
end

-- ── Adonis toggle ────────────────────────────────────────────
AdonisBtn.MouseButton1Click:Connect(function()
    AdonisOpen = not AdonisOpen
    if AdonisOpen then
        TryResolveAdonis()
        BuildAdonisPanel()
        AdonisPanel.Visible=true
        Placeholder.Visible=false
        DetailFrame.Visible=false
        AdonisBtn.BackgroundColor3=Color3.fromRGB(100,40,140)
    else
        AdonisPanel.Visible=false
        Placeholder.Visible=true
        AdonisBtn.BackgroundColor3=Color3.fromRGB(60,30,80)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible=false GlowFrame.Visible=false GlowFrame2.Visible=false
end)

-- ════════════════════════════════════════════════════════════
--  TREE BUILD
-- ════════════════════════════════════════════════════════════
local function BuildTree()
    for _,c in pairs(LeftPane:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    AllTreeItems={}

    local groups,containerGroups={},{}
    for _,m in ipairs(ScannedModules) do
        local g=m.source
        if not groups[g] then groups[g]={label=g,modules={}} table.insert(containerGroups,groups[g]) end
        table.insert(groups[g].modules,m)
    end

    for _,grp in ipairs(containerGroups) do
        local cf,_=MakeTreeLabel("▾ "..grp.label,Color3.fromRGB(140,160,255),INDENT.container,Color3.fromRGB(30,30,50))
        cf.LayoutOrder=#AllTreeItems
        table.insert(AllTreeItems,{kind="container",label=grp.label,frame=cf})
        local expanded=true local moduleFrames={}
        cf.InputBegan:Connect(function(inp)
            if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            expanded=not expanded
            for _,mf in pairs(moduleFrames) do mf.Visible=expanded end
            local l=cf:FindFirstChildWhichIsA("TextLabel")
            if l then l.Text=(expanded and "▾ " or "▸ ")..grp.label end
        end)

        for mIdx,m in ipairs(grp.modules) do
            local mf,_=MakeTreeLabel("  ◆ "..m.name,Color3.fromRGB(200,200,255),INDENT.module,Color3.fromRGB(26,26,40))
            mf.LayoutOrder=#AllTreeItems
            table.insert(AllTreeItems,{kind="module",label=m.name,frame=mf,modIdx=mIdx})
            table.insert(moduleFrames,mf)
            local fnFrames,modExpanded={},false
            mf.InputBegan:Connect(function(inp)
                if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
                modExpanded=not modExpanded
                for _,ff in pairs(fnFrames) do ff.Visible=modExpanded end
                local l=mf:FindFirstChildWhichIsA("TextLabel")
                if l then l.Text=(modExpanded and "  ▾ " or "  ◆ ")..m.name end
            end)

            local fnNames={}
            for k in pairs(m.functions) do table.insert(fnNames,k) end
            table.sort(fnNames)

            for _,fnName in ipairs(fnNames) do
                local fnRef=m.functions[fnName]
                local uvc=0 pcall(function() uvc=#getupvalues(fnRef) end)
                local uvcStr=uvc>0 and (" +"..uvc) or ""
                local ff,_=MakeTreeLabel("    ƒ "..fnName..uvcStr,Color3.fromRGB(160,220,160),INDENT.fn,Color3.fromRGB(24,28,24))
                ff.LayoutOrder=#AllTreeItems ff.Visible=false
                table.insert(AllTreeItems,{kind="fn",label=fnName,frame=ff,modIdx=mIdx,fnRef=fnRef})
                table.insert(fnFrames,ff)
                ff.InputBegan:Connect(function(inp)
                    if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
                    SelectFunction(fnRef,fnName,mIdx)
                end)
            end
        end
    end

    task.defer(function()
        LeftPane.CanvasSize=UDim2.new(0,0,0,LeftLayout.AbsoluteContentSize.Y+5)
    end)
end

-- ── SEARCH ──────────────────────────────────────────────────
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q=SearchBox.Text:lower():gsub("%s+","")
    for _,item in ipairs(AllTreeItems) do
        if q=="" then item.frame.Visible=(item.kind=="container" or item.kind=="module")
        else item.frame.Visible=item.label:lower():find(q,1,true)~=nil end
    end
    task.defer(function()
        LeftPane.CanvasSize=UDim2.new(0,0,0,LeftLayout.AbsoluteContentSize.Y+5)
    end)
end)

-- ── SCANNER ─────────────────────────────────────────────────
local function ScanContainer(container,sourceName)
    local found={}
    for _,desc in ipairs(container:GetDescendants()) do
        if desc:IsA("ModuleScript") then
            local ok,result=pcall(require,desc)
            if ok and type(result)=="table" then
                local fns={}
                for k,v in pairs(result) do
                    if type(v)=="function" then fns[tostring(k)]=v end
                end
                for k,v in pairs(result) do
                    if type(v)=="table" then
                        for k2,v2 in pairs(v) do
                            if type(v2)=="function" then fns[tostring(k).."."..tostring(k2)]=v2 end
                        end
                    end
                end
                if next(fns) then
                    table.insert(found,{name=desc.Name,path=desc:GetFullName(),module=result,source=sourceName,functions=fns})
                end
            end
        end
    end
    return found
end

local function RunScan()
    SetStatus("scanning...",Color3.fromRGB(255,180,0))
    ScannedModules={}
    if not AdonisOpen then Placeholder.Visible=true DetailFrame.Visible=false end

    task.spawn(function()
        local total=0
        for _,m in ipairs(ScanContainer(ReplicatedStorage,"ReplicatedStorage")) do
            table.insert(ScannedModules,m) total=total+1
        end
        for _,c in ipairs({
            lp:FindFirstChild("Backpack"),lp.Character,
            lp:FindFirstChild("PlayerScripts"),lp:FindFirstChild("PlayerGui")
        }) do
            if c then
                for _,m in ipairs(ScanContainer(c,"LocalPlayer."..c.Name)) do
                    table.insert(ScannedModules,m) total=total+1
                end
            end
        end
        local cg={CoreGui}
        local rg=CoreGui:FindFirstChild("RobloxGui")
        if rg then table.insert(cg,rg) end
        for _,c in ipairs(cg) do
            pcall(function()
                for _,m in ipairs(ScanContainer(c,c.Name)) do
                    table.insert(ScannedModules,m) total=total+1
                end
            end)
        end
        TryResolveAdonis()
        BuildTree()
        SetStatus(total.." modules found",Color3.fromRGB(0,255,150))
        -- refresh panel if open
        if AdonisOpen then BuildAdonisPanel() end
    end)
end

ScanBtn.MouseButton1Click:Connect(RunScan)

-- ── TOGGLE ──────────────────────────────────────────────────
UserInputService.InputBegan:Connect(function(input,gpe)
    if not gpe and input.KeyCode==Enum.KeyCode.RightAlt then
        local v=not MainFrame.Visible
        MainFrame.Visible=v GlowFrame.Visible=v GlowFrame2.Visible=v
    end
end)

RunScan()

print("[ModuleExplorer v2] Loaded.")
print("  RightAlt  → toggle")
print("  ★ adonis  → dedicated Adonis panel")
print("  ⟳ scan   → rescan all containers")
