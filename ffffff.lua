-- ============================================================
--  Callum_ModuleExplorer  v3.0  (clean rewrite)
--  RightAlt = toggle UI
--  ★ adonis button = dedicated Adonis panel
-- ============================================================

local Players          = game:GetService("Players")
local UIS              = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RepStore         = game:GetService("ReplicatedStorage")
local lp               = Players.LocalPlayer

-- exploit funcs (safe fallbacks so script loads even in studio)
local getupvalues  = getupvalues  or function() return {} end
local setupvalue   = setupvalue   or function() end
local hookfn       = hookfunction or function() end
local newcc        = newcclosure  or function(f) return f end
local isluaclosure = islclosure   or function() return false end
local getgc        = getgc        or nil   -- may be nil, checked before use
local getrawmt     = getrawmetatable or getmetatable

-- ─────────────────────────────────────────────────────────────
--  GUI
-- ─────────────────────────────────────────────────────────────
local Root = Instance.new("ScreenGui")
Root.Name = "Callum_ModuleExplorer_v3"
Root.ResetOnSpawn = false
Root.ZIndexBehavior = Enum.ZIndexBehavior.Global
Root.Parent = (gethui and gethui()) or CoreGui

-- outer glow
local function Glow(w,h,xOff,yOff,t,z)
    local f=Instance.new("Frame",Root)
    f.Size=UDim2.new(0,w,0,h)
    f.Position=UDim2.new(0.5,xOff,0.5,yOff)
    f.BackgroundColor3=Color3.fromRGB(255,255,255)
    f.BackgroundTransparency=t f.BorderSizePixel=0 f.ZIndex=z
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,10)
    return f
end
local G2=Glow(616,556,-308,-278,0.93,1)
local G1=Glow(600,540,-300,-270,0.82,2)

local Win=Instance.new("Frame",Root)
Win.Size=UDim2.new(0,580,0,520)
Win.Position=UDim2.new(0.5,-290,0.5,-260)
Win.BackgroundColor3=Color3.fromRGB(18,18,18)
Win.BackgroundTransparency=0.15
Win.BorderSizePixel=0 Win.Active=true Win.Draggable=true Win.ZIndex=3
Win.Parent=Root
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,4)
do
    local g=Instance.new("UIGradient",Win)
    g.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,18,18))})
    g.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0.88),NumberSequenceKeypoint.new(0.4,0.96),NumberSequenceKeypoint.new(1,1)})
    g.Rotation=135
end
Win:GetPropertyChangedSignal("Position"):Connect(function()
    local p=Win.Position
    G1.Position=UDim2.new(p.X.Scale,p.X.Offset-10,p.Y.Scale,p.Y.Offset-10)
    G2.Position=UDim2.new(p.X.Scale,p.X.Offset-18,p.Y.Scale,p.Y.Offset-18)
end)

-- title bar
local TitleBar=Instance.new("TextLabel",Win)
TitleBar.Size=UDim2.new(1,0,0,30) TitleBar.BackgroundColor3=Color3.fromRGB(30,30,30)
TitleBar.Text="  module explorer  v3" TitleBar.TextColor3=Color3.fromRGB(255,255,255)
TitleBar.TextSize=13 TitleBar.Font=Enum.Font.Code TitleBar.TextXAlignment=Enum.TextXAlignment.Left
Instance.new("UICorner",TitleBar).CornerRadius=UDim.new(0,4)

local StatusLbl=Instance.new("TextLabel",Win)
StatusLbl.Size=UDim2.new(0.5,0,0,16) StatusLbl.Position=UDim2.new(0,5,0,33)
StatusLbl.BackgroundTransparency=1 StatusLbl.Text="idle"
StatusLbl.TextColor3=Color3.fromRGB(140,160,255) StatusLbl.TextSize=11
StatusLbl.Font=Enum.Font.Code StatusLbl.TextXAlignment=Enum.TextXAlignment.Left

local function TopBtn(lbl,col,xOff,w)
    local b=Instance.new("TextButton",Win)
    b.Size=UDim2.new(0,w,0,18) b.Position=UDim2.new(1,xOff,0,32)
    b.BackgroundColor3=col b.Text=lbl b.TextColor3=Color3.fromRGB(230,230,230)
    b.TextSize=10 b.Font=Enum.Font.Code b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    return b
end
local BtnAdonis = TopBtn("★ adonis", Color3.fromRGB(60,25,80),  -200, 76)
local BtnScan   = TopBtn("⟳ scan",   Color3.fromRGB(35,75,50),  -120, 60)
local BtnClose  = TopBtn("✕",        Color3.fromRGB(80,25,25),  -56,  50)

-- search bar
local SBar=Instance.new("Frame",Win)
SBar.Size=UDim2.new(1,-10,0,22) SBar.Position=UDim2.new(0,5,0,53)
SBar.BackgroundColor3=Color3.fromRGB(26,26,34) SBar.BorderSizePixel=0
Instance.new("UICorner",SBar).CornerRadius=UDim.new(0,3)
local SIcon=Instance.new("TextLabel",SBar)
SIcon.Size=UDim2.new(0,22,1,0) SIcon.BackgroundTransparency=1
SIcon.Text="🔍" SIcon.TextSize=11 SIcon.Font=Enum.Font.Code
local SBox=Instance.new("TextBox",SBar)
SBox.Size=UDim2.new(1,-26,1,0) SBox.Position=UDim2.new(0,22,0,0)
SBox.BackgroundTransparency=1 SBox.PlaceholderText="search..." SBox.PlaceholderColor3=Color3.fromRGB(80,80,80)
SBox.Text="" SBox.TextColor3=Color3.fromRGB(200,200,200) SBox.TextSize=11 SBox.Font=Enum.Font.Code
SBox.ClearTextOnFocus=false SBox.TextXAlignment=Enum.TextXAlignment.Left

-- left tree pane
local LeftSF=Instance.new("ScrollingFrame",Win)
LeftSF.Size=UDim2.new(0,198,1,-82) LeftSF.Position=UDim2.new(0,5,0,79)
LeftSF.BackgroundTransparency=1 LeftSF.CanvasSize=UDim2.new(0,0,0,0) LeftSF.ScrollBarThickness=2
local LeftLL=Instance.new("UIListLayout",LeftSF)
LeftLL.Padding=UDim.new(0,2) LeftLL.SortOrder=Enum.SortOrder.LayoutOrder

-- divider
local Div=Instance.new("Frame",Win)
Div.Size=UDim2.new(0,1,1,-82) Div.Position=UDim2.new(0,206,0,79)
Div.BackgroundColor3=Color3.fromRGB(50,50,70) Div.BorderSizePixel=0

-- right pane
local RPane=Instance.new("Frame",Win)
RPane.Size=UDim2.new(1,-216,1,-82) RPane.Position=UDim2.new(0,211,0,79)
RPane.BackgroundTransparency=1 RPane.ClipsDescendants=true

-- placeholder
local Hint=Instance.new("TextLabel",RPane)
Hint.Size=UDim2.new(1,0,1,0) Hint.BackgroundTransparency=1
Hint.Text="select a function from the tree" Hint.TextColor3=Color3.fromRGB(55,55,75)
Hint.TextSize=12 Hint.Font=Enum.Font.Code

-- ─────────────────────────────────────────────────────────────
--  DETAIL FRAME (function view)
-- ─────────────────────────────────────────────────────────────
local DFrame=Instance.new("Frame",RPane)
DFrame.Size=UDim2.new(1,0,1,0) DFrame.BackgroundTransparency=1 DFrame.Visible=false

local DHeader=Instance.new("TextLabel",DFrame)
DHeader.Size=UDim2.new(1,0,0,22) DHeader.BackgroundColor3=Color3.fromRGB(28,28,46)
DHeader.TextColor3=Color3.fromRGB(180,200,255) DHeader.TextSize=11 DHeader.Font=Enum.Font.Code
DHeader.TextXAlignment=Enum.TextXAlignment.Left DHeader.TextTruncate=Enum.TextTruncate.AtEnd
Instance.new("UICorner",DHeader).CornerRadius=UDim.new(0,3)

local DMeta=Instance.new("TextLabel",DFrame)
DMeta.Size=UDim2.new(1,0,0,15) DMeta.Position=UDim2.new(0,0,0,25)
DMeta.BackgroundTransparency=1 DMeta.TextColor3=Color3.fromRGB(110,130,110)
DMeta.TextSize=10 DMeta.Font=Enum.Font.Code DMeta.TextXAlignment=Enum.TextXAlignment.Left

local function MkTab(lbl,xS,wS)
    local b=Instance.new("TextButton",DFrame)
    b.Size=UDim2.new(wS,-2,0,20) b.Position=UDim2.new(xS,2,0,43)
    b.BackgroundColor3=Color3.fromRGB(28,28,40) b.Text=lbl
    b.TextColor3=Color3.fromRGB(150,150,190) b.TextSize=10 b.Font=Enum.Font.Code b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    return b
end
local TbHook  = MkTab("⚡ hook",    0,    0.25)
local TbUpval = MkTab("📦 upvals",  0.25, 0.25)
local TbMeta  = MkTab("🔬 meta",    0.5,  0.25)
local TbCtx   = MkTab("★ context",  0.75, 0.25)

local CSF=Instance.new("ScrollingFrame",DFrame)
CSF.Size=UDim2.new(1,0,1,-66) CSF.Position=UDim2.new(0,0,0,66)
CSF.BackgroundTransparency=1 CSF.CanvasSize=UDim2.new(0,0,0,0) CSF.ScrollBarThickness=2

-- ─────────────────────────────────────────────────────────────
--  ADONIS PANEL
-- ─────────────────────────────────────────────────────────────
local APanel=Instance.new("Frame",RPane)
APanel.Size=UDim2.new(1,0,1,0) APanel.BackgroundTransparency=1
APanel.Visible=false APanel.ClipsDescendants=true

local ASF=Instance.new("ScrollingFrame",APanel)
ASF.Size=UDim2.new(1,0,1,0) ASF.BackgroundTransparency=1
ASF.CanvasSize=UDim2.new(0,0,0,0) ASF.ScrollBarThickness=2
local ALL=Instance.new("UIListLayout",ASF)
ALL.Padding=UDim.new(0,3) ALL.SortOrder=Enum.SortOrder.LayoutOrder

-- ─────────────────────────────────────────────────────────────
--  STATE
-- ─────────────────────────────────────────────────────────────
local Modules    = {}   -- scanned module list
local TreeItems  = {}   -- flat list for search
local CurFn      = nil
local CurFnName  = ""
local CurModIdx  = nil
local CurTab     = "hook"
local AdonisOpen = false
local Scanning   = false

-- Adonis cache
local AC={
    Core=nil,Remote=nil,Anti=nil,Functions=nil,
    Variables=nil,Service=nil,DetectedFn=nil,
    remoteObj=nil,remoteHook=nil,
    acliLogs=nil,acliKickFn=nil,
    key=nil,logLines={},
}

-- ─────────────────────────────────────────────────────────────
--  HELPERS
-- ─────────────────────────────────────────────────────────────
local function SetStatus(t,c)
    StatusLbl.Text=t StatusLbl.TextColor3=c or Color3.fromRGB(140,160,255)
end

local function RefreshSF(sf)
    task.defer(function()
        local l=sf:FindFirstChildWhichIsA("UIListLayout")
        if l then sf.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+6) end
    end)
end

local function ClearSF(sf)
    for _,c in ipairs(sf:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    sf.CanvasSize=UDim2.new(0,0,0,0)
end

-- make a list layout inside a scrollframe
local function MkLL(sf)
    local l=Instance.new("UIListLayout",sf)
    l.Padding=UDim.new(0,3) l.SortOrder=Enum.SortOrder.LayoutOrder
    return l
end

-- simple text row
local function Row(parent,txt,col,h)
    local l=Instance.new("TextLabel",parent)
    l.Size=UDim2.new(1,-4,0,h or 18) l.BackgroundTransparency=1
    l.Text=txt l.TextColor3=col or Color3.fromRGB(190,190,190)
    l.TextSize=10 l.Font=Enum.Font.Code
    l.TextXAlignment=Enum.TextXAlignment.Left l.TextWrapped=true
    return l
end

-- button
local function Btn(parent,txt,col,h)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,-4,0,h or 22) b.BackgroundColor3=col
    b.Text=txt b.TextColor3=Color3.fromRGB(225,225,225)
    b.TextSize=10 b.Font=Enum.Font.Code b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    return b
end

-- section header
local function Hdr(parent,txt)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,-4,0,20) f.BackgroundColor3=Color3.fromRGB(38,28,58) f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-6,1,0) l.Position=UDim2.new(0,6,0,0) l.BackgroundTransparency=1
    l.Text=txt l.TextColor3=Color3.fromRGB(195,155,255) l.TextSize=10 l.Font=Enum.Font.Code
    l.TextXAlignment=Enum.TextXAlignment.Left
    return f
end

-- mini log box: returns (scrollframe, append function)
local function LogBox(parent,h)
    local bg=Instance.new("Frame",parent)
    bg.Size=UDim2.new(1,-4,0,h) bg.BackgroundColor3=Color3.fromRGB(18,18,26) bg.BorderSizePixel=0
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,3)
    local sf=Instance.new("ScrollingFrame",bg)
    sf.Size=UDim2.new(1,-4,1,-4) sf.Position=UDim2.new(0,2,0,2)
    sf.BackgroundTransparency=1 sf.CanvasSize=UDim2.new(0,0,0,0) sf.ScrollBarThickness=2
    local ll=Instance.new("UIListLayout",sf)
    ll.Padding=UDim.new(0,1) ll.SortOrder=Enum.SortOrder.LayoutOrder
    local function append(txt,col)
        local l=Instance.new("TextLabel",sf)
        l.Size=UDim2.new(1,0,0,13) l.BackgroundTransparency=1
        l.Text=txt l.TextColor3=col or Color3.fromRGB(175,210,175)
        l.TextSize=9 l.Font=Enum.Font.Code
        l.TextXAlignment=Enum.TextXAlignment.Left l.TextTruncate=Enum.TextTruncate.AtEnd
        task.defer(function()
            sf.CanvasSize=UDim2.new(0,0,0,ll.AbsoluteContentSize.Y+4)
            sf.CanvasPosition=Vector2.new(0,math.huge)
        end)
    end
    local function clear()
        for _,c in ipairs(sf:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
        sf.CanvasSize=UDim2.new(0,0,0,0)
    end
    return bg,append,clear
end

-- ─────────────────────────────────────────────────────────────
--  CONTENT TABS
-- ─────────────────────────────────────────────────────────────
local function ActivateTab(which)
    CurTab=which
    local map={hook=TbHook,upvalues=TbUpval,meta=TbMeta,context=TbCtx}
    for k,b in pairs(map) do
        b.BackgroundColor3=(k==which) and Color3.fromRGB(46,46,76) or Color3.fromRGB(28,28,40)
        b.TextColor3=(k==which) and Color3.fromRGB(200,215,255) or Color3.fromRGB(150,150,190)
    end
end

-- HOOK TAB
local function ShowHook(fnRef,fnName)
    ClearSF(CSF) MkLL(CSF)
    Row(CSF,"replacement body — 'original' = original fn",Color3.fromRGB(110,130,110))
    local ebg=Instance.new("Frame",CSF)
    ebg.Size=UDim2.new(1,-4,0,155) ebg.BackgroundColor3=Color3.fromRGB(20,20,30) ebg.BorderSizePixel=0
    Instance.new("UICorner",ebg).CornerRadius=UDim.new(0,3)
    local eb=Instance.new("TextBox",ebg)
    eb.Size=UDim2.new(1,-6,1,-6) eb.Position=UDim2.new(0,3,0,3)
    eb.BackgroundTransparency=1 eb.MultiLine=true eb.ClearTextOnFocus=false
    eb.Text="-- args: ...\nreturn original(...)"
    eb.TextColor3=Color3.fromRGB(175,220,175) eb.TextSize=10 eb.Font=Enum.Font.Code
    eb.TextXAlignment=Enum.TextXAlignment.Left eb.TextYAlignment=Enum.TextYAlignment.Top
    local applyBtn=Btn(CSF,"⚡ apply hook",Color3.fromRGB(35,65,45))
    local removeBtn=Btn(CSF,"✕ remove hook",Color3.fromRGB(65,25,25))
    local resLbl=Row(CSF,"",Color3.fromRGB(130,190,130))
    local orig=fnRef local hooked,handle=false,nil
    applyBtn.MouseButton1Click:Connect(function()
        local src="return function(original) return function(...) "..eb.Text.." end end"
        local ok,w=pcall(loadstring,src)
        if not ok or not w then resLbl.Text="syntax: "..tostring(w) resLbl.TextColor3=Color3.fromRGB(255,100,100) return end
        local ok2,fac=pcall(w) if not ok2 or type(fac)~="function" then resLbl.Text="compile: "..tostring(fac) resLbl.TextColor3=Color3.fromRGB(255,100,100) return end
        local ok3,err=pcall(function() handle=hookfn(fnRef,newcc(fac(orig))) end)
        if ok3 then hooked=true resLbl.Text="✓ hooked" resLbl.TextColor3=Color3.fromRGB(100,255,140)
        else resLbl.Text="failed: "..tostring(err) resLbl.TextColor3=Color3.fromRGB(255,100,100) end
    end)
    removeBtn.MouseButton1Click:Connect(function()
        if hooked then pcall(hookfn,fnRef,orig) hooked=false resLbl.Text="removed" resLbl.TextColor3=Color3.fromRGB(200,180,100)
        else resLbl.Text="not hooked" end
    end)
    RefreshSF(CSF)
end

-- UPVALUE TAB
local function ShowUpvals(fnRef)
    ClearSF(CSF) MkLL(CSF)
    local uvs={} pcall(function() uvs=getupvalues(fnRef) end)
    if #uvs==0 then Row(CSF,"no upvalues accessible",Color3.fromRGB(80,80,100)) RefreshSF(CSF) return end
    for i,v in ipairs(uvs) do
        local vt=typeof(v)
        local rf=Instance.new("Frame",CSF)
        rf.Size=UDim2.new(1,-4,0,24) rf.BackgroundColor3=Color3.fromRGB(24,24,34) rf.BorderSizePixel=0
        Instance.new("UICorner",rf).CornerRadius=UDim.new(0,3)
        local il=Instance.new("TextLabel",rf) il.Size=UDim2.new(0,20,1,0) il.BackgroundTransparency=1
        il.Text=tostring(i) il.TextColor3=Color3.fromRGB(90,90,130) il.TextSize=9 il.Font=Enum.Font.Code
        local tl=Instance.new("TextLabel",rf) tl.Size=UDim2.new(0,34,1,0) tl.Position=UDim2.new(0,20,0,0)
        tl.BackgroundTransparency=1 tl.Text=vt:sub(1,3):upper() tl.TextColor3=Color3.fromRGB(130,150,240) tl.TextSize=9 tl.Font=Enum.Font.Code
        local vb=Instance.new("TextBox",rf) vb.Size=UDim2.new(1,-58,0.82,0) vb.Position=UDim2.new(0,54,0.09,0)
        vb.BackgroundColor3=Color3.fromRGB(30,30,42) vb.Text=tostring(v) vb.TextColor3=Color3.fromRGB(195,225,195)
        vb.TextSize=10 vb.Font=Enum.Font.Code vb.ClearTextOnFocus=false
        vb.TextXAlignment=Enum.TextXAlignment.Left vb.TextTruncate=Enum.TextTruncate.AtEnd
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
    RefreshSF(CSF)
end

-- META TAB
local function ShowMeta(modTbl)
    ClearSF(CSF) MkLL(CSF)
    local mt=nil pcall(function() mt=getrawmt(modTbl) end)
    if not mt then Row(CSF,"no metatable",Color3.fromRGB(80,80,100)) RefreshSF(CSF) return end
    pcall(function() if setreadonly then setreadonly(mt,false) end end)
    local n=0
    for k,v in pairs(mt) do
        local vt=typeof(v)
        local rf=Instance.new("Frame",CSF)
        rf.Size=UDim2.new(1,-4,0,24) rf.BackgroundColor3=Color3.fromRGB(26,22,34) rf.BorderSizePixel=0
        Instance.new("UICorner",rf).CornerRadius=UDim.new(0,3)
        local kl=Instance.new("TextLabel",rf) kl.Size=UDim2.new(0.38,0,1,0) kl.BackgroundTransparency=1
        kl.Text=tostring(k) kl.TextColor3=Color3.fromRGB(195,155,245) kl.TextSize=10 kl.Font=Enum.Font.Code
        kl.TextXAlignment=Enum.TextXAlignment.Left kl.TextTruncate=Enum.TextTruncate.AtEnd
        local tt=Instance.new("TextLabel",rf) tt.Size=UDim2.new(0,26,1,0) tt.Position=UDim2.new(0.38,0,0,0)
        tt.BackgroundTransparency=1 tt.Text=vt:sub(1,3):upper() tt.TextColor3=Color3.fromRGB(130,150,240) tt.TextSize=9 tt.Font=Enum.Font.Code
        local vb=Instance.new("TextBox",rf) vb.Size=UDim2.new(0.62,-30,0.82,0) vb.Position=UDim2.new(0.38,28,0.09,0)
        vb.BackgroundColor3=Color3.fromRGB(30,26,42) vb.Text=tostring(v) vb.TextColor3=Color3.fromRGB(215,175,255)
        vb.TextSize=10 vb.Font=Enum.Font.Code vb.ClearTextOnFocus=false
        vb.TextXAlignment=Enum.TextXAlignment.Left vb.TextTruncate=Enum.TextTruncate.AtEnd
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
        n=n+1
    end
    if n==0 then Row(CSF,"empty metatable",Color3.fromRGB(80,80,100)) end
    RefreshSF(CSF)
end

-- CONTEXT TAB
local function ShowContext(fnRef)
    ClearSF(CSF) MkLL(CSF)
    local uvs={} pcall(function() uvs=getupvalues(fnRef) end)
    local ctype="unknown"
    pcall(function() if isluaclosure(fnRef) then ctype="Lua closure" else ctype="C closure" end end)
    Row(CSF,"type: "..ctype.."   upvalues: "..#uvs)
    local found=0
    for i,v in ipairs(uvs) do
        if type(v)=="table" then
            local sig=""
            if type(v.GetEvent)=="function" and (v.ScriptCache~=nil or type(v.LoadPlugin)=="function") then sig="Adonis.Core"
            elseif type(v.Send)=="function" and type(v.Get)=="function" and type(v.Fire)=="function" then sig="Adonis.Remote"
            elseif type(v.Detected)=="function" and type(v.AddDetector)=="function" then sig="Adonis.Anti"
            elseif type(v.Wrap)=="function" and type(v.UnWrap)=="function" and type(v.TrackTask)=="function" then sig="Adonis.Service"
            elseif rawget(v,"G_Access_Key")~=nil then sig="Adonis.Variables"
            end
            if sig~="" then Row(CSF,"upval["..i.."] ★ "..sig,Color3.fromRGB(210,170,255)) found=found+1 end
        end
    end
    if found==0 then Row(CSF,"no Adonis refs found in upvalues",Color3.fromRGB(90,90,110)) end
    RefreshSF(CSF)
end

-- ─────────────────────────────────────────────────────────────
--  FUNCTION SELECTION
-- ─────────────────────────────────────────────────────────────
local function SelectFn(fnRef,fnName,modIdx)
    CurFn,CurFnName,CurModIdx=fnRef,fnName,modIdx
    if AdonisOpen then
        AdonisOpen=false APanel.Visible=false
        BtnAdonis.BackgroundColor3=Color3.fromRGB(60,25,80)
    end
    Hint.Visible=false DFrame.Visible=true
    DHeader.Text="  fn  "..fnName
    local uvc=0 pcall(function() uvc=#getupvalues(fnRef) end)
    local ctype="?" pcall(function() ctype=isluaclosure(fnRef) and "lua" or "C" end)
    DMeta.Text=ctype.."  upvalues: "..uvc
    ActivateTab(CurTab)
    if CurTab=="hook" then ShowHook(fnRef,fnName)
    elseif CurTab=="upvalues" then ShowUpvals(fnRef)
    elseif CurTab=="meta" and Modules[modIdx] then ShowMeta(Modules[modIdx].module)
    elseif CurTab=="context" then ShowContext(fnRef)
    end
end

TbHook.MouseButton1Click:Connect(function()
    ActivateTab("hook") if CurFn then ShowHook(CurFn,CurFnName) end
end)
TbUpval.MouseButton1Click:Connect(function()
    ActivateTab("upvalues") if CurFn then ShowUpvals(CurFn) end
end)
TbMeta.MouseButton1Click:Connect(function()
    ActivateTab("meta")
    if CurFn and CurModIdx and Modules[CurModIdx] then ShowMeta(Modules[CurModIdx].module) end
end)
TbCtx.MouseButton1Click:Connect(function()
    ActivateTab("context") if CurFn then ShowContext(CurFn) end
end)

-- ─────────────────────────────────────────────────────────────
--  ADONIS RESOLVER
-- ─────────────────────────────────────────────────────────────
local function Resolve()
    -- 1. _G.Adonis
    pcall(function() AC.gAPI=rawget(_G,"Adonis") end)

    -- 2. getfenv on scanned functions → look for client env
    if not AC.Core then
        for _,m in ipairs(Modules) do
            if AC.Core then break end
            for _,fn in pairs(m.functions) do
                if AC.Core then break end
                pcall(function()
                    local env=getfenv(fn)
                    if type(env)~="table" then return end
                    local c=rawget(env,"client")
                    if type(c)=="table" and type(c.Core)=="table" then
                        AC.Core=c.Core AC.Remote=c.Remote AC.Anti=c.Anti
                        AC.Functions=c.Functions AC.Variables=c.Variables
                        local s=rawget(env,"service") if type(s)=="table" then AC.Service=s end
                        if AC.Anti then AC.DetectedFn=AC.Anti.Detected end
                    end
                end)
            end
        end
    end

    -- 3. upvalue walk (2 levels)
    local function chk(t)
        if not AC.Core and type(t.GetEvent)=="function"
            and (t.ScriptCache~=nil or type(t.LoadPlugin)=="function") then AC.Core=t end
        if not AC.Remote and type(t.Send)=="function" and type(t.Get)=="function" then AC.Remote=t end
        if not AC.Anti and type(t.Detected)=="function" and type(t.AddDetector)=="function" then
            AC.Anti=t AC.DetectedFn=t.Detected end
        if not AC.Service and type(t.Wrap)=="function" and type(t.TrackTask)=="function" then AC.Service=t end
        if not AC.Variables and rawget(t,"G_Access_Key")~=nil then AC.Variables=t end
    end
    for _,m in ipairs(Modules) do
        if AC.Core and AC.Remote and AC.Anti and AC.Service then break end
        for _,fn in pairs(m.functions) do
            local uvs={} pcall(function() uvs=getupvalues(fn) end)
            for _,uv in ipairs(uvs) do
                if type(uv)=="table" then chk(uv)
                elseif type(uv)=="function" then
                    local uvs2={} pcall(function() uvs2=getupvalues(uv) end)
                    for _,uv2 in ipairs(uvs2) do if type(uv2)=="table" then chk(uv2) end end
                end
            end
        end
    end

    -- 4. RemoteEvent
    if AC.Core and not AC.remoteObj then
        pcall(function()
            local re=rawget(AC.Core,"RemoteEvent")
            if re then AC.remoteObj=rawget(re,"Object") or re end
        end)
    end
    if not AC.remoteObj then
        pcall(function()
            for _,d in ipairs(RepStore:GetDescendants()) do
                if d:IsA("RemoteEvent") and d:FindFirstChild("__FUNCTION") then
                    AC.remoteObj=d break
                end
            end
        end)
    end

    -- 5. getgc for acliLogs and kick fn
    if getgc then
        -- acliLogs: sequential string table with "ACLI:" entries
        if not AC.acliLogs then
            pcall(function()
                for _,obj in ipairs(getgc(true)) do
                    if type(obj)=="table" then
                        local hasACLI,allStr,n=false,true,0
                        for k,v in pairs(obj) do
                            n=n+1
                            if type(k)~="number" or type(v)~="string" then allStr=false break end
                            if v:find("ACLI:",1,true) then hasACLI=true end
                            if n>500 then allStr=false break end
                        end
                        if allStr and hasACLI then AC.acliLogs=obj break end
                    end
                end
            end)
        end
        -- acliKickFn: Lua closure with boolean upvalue AND C-function "Kick" upvalue
        if not AC.acliKickFn then
            pcall(function()
                for _,obj in ipairs(getgc(false)) do
                    if type(obj)=="function" and isluaclosure(obj) then
                        local uvs={} pcall(function() uvs=getupvalues(obj) end)
                        local hasBool,hasKick=false,false
                        for _,uv in ipairs(uvs) do
                            if type(uv)=="boolean" then hasBool=true end
                            if type(uv)=="function" and not isluaclosure(uv) then
                                local ok,n=pcall(debug.info,uv,"n")
                                if ok and n=="Kick" then hasKick=true end
                            end
                        end
                        if hasBool and hasKick then AC.acliKickFn=obj break end
                    end
                end
            end)
        end
    end

    return AC.Core~=nil
end

-- ─────────────────────────────────────────────────────────────
--  ADONIS PANEL BUILD
-- ─────────────────────────────────────────────────────────────
local function BuildAdonis()
    ClearSF(ASF)
    local ll=MkLL(ASF)
    local resolved=Resolve()

    -- overview
    Hdr(ASF,"★  adonis  —  resolution status")
    Row(ASF,
        (AC.Core and "✓" or "✗").." Core  "..(AC.Remote and "✓" or "✗").." Remote  "
        ..(AC.Anti and "✓" or "✗").." Anti  "..(AC.Service and "✓" or "✗").." Service",
        resolved and Color3.fromRGB(100,255,140) or Color3.fromRGB(255,120,120))
    Row(ASF,"RemoteEvent: "..(AC.remoteObj and AC.remoteObj.Name or "not found"),Color3.fromRGB(140,200,255))
    Row(ASF,"Key: "..(AC.key or (AC.Core and tostring(rawget(AC.Core,"Key")) or "not retrieved")),Color3.fromRGB(255,215,90))
    Row(ASF,"acliLogs: "..(AC.acliLogs and tostring(#AC.acliLogs).." entries" or "not found"),Color3.fromRGB(180,180,180))
    Row(ASF,"acliKickFn: "..(AC.acliKickFn and "found" or "not found"),Color3.fromRGB(180,180,180))

    -- ── KEY INTERCEPT ──
    Hdr(ASF,"🔑  key intercept")
    Row(ASF,"hooks Remote.Get to catch the key as it arrives",Color3.fromRGB(130,130,130))
    local startK=Btn(ASF,"▶  start",Color3.fromRGB(35,55,35))
    local stopK=Btn(ASF,"■  stop", Color3.fromRGB(55,25,25))
    local keyLbl=Row(ASF,"idle")
    local _korig,_khooked=nil,false
    startK.MouseButton1Click:Connect(function()
        if _khooked then keyLbl.Text="already active" return end
        if not AC.Remote or type(AC.Remote.Get)~="function" then
            keyLbl.Text="Remote.Get not found" keyLbl.TextColor3=Color3.fromRGB(255,100,100) return end
        _korig=AC.Remote.Get
        local ok,err=pcall(function()
            hookfn(AC.Remote.Get,newcc(function(...)
                local res=_korig(...)
                local req=tostring(select(1,...) or "")
                if req:find("GET_KEY",1,true) then
                    AC.key=res keyLbl.Text="✓ key: "..tostring(res) keyLbl.TextColor3=Color3.fromRGB(100,255,140)
                    print("[ModExp] key: "..tostring(res))
                end
                return res
            end))
        end)
        if ok then _khooked=true keyLbl.Text="listening..." keyLbl.TextColor3=Color3.fromRGB(255,215,80)
        else keyLbl.Text="hook fail: "..tostring(err) keyLbl.TextColor3=Color3.fromRGB(255,100,100) end
    end)
    stopK.MouseButton1Click:Connect(function()
        if _khooked and _korig then pcall(hookfn,AC.Remote.Get,_korig) _khooked=false keyLbl.Text="stopped" end
    end)

    -- ── REMOTE LOGGER ──
    Hdr(ASF,"📡  remote event logger")
    Row(ASF,"taps OnClientEvent — logs all server→client calls",Color3.fromRGB(130,130,130))
    local startL=Btn(ASF,"▶  start",Color3.fromRGB(25,45,65))
    local stopL=Btn(ASF,"■  stop", Color3.fromRGB(55,25,25))
    local clearL=Btn(ASF,"✕  clear",Color3.fromRGB(35,35,35))
    local logStat=Row(ASF,"idle")
    local _,logAppend,logClear=LogBox(ASF,90)
    startL.MouseButton1Click:Connect(function()
        if AC.remoteHook then logStat.Text="already logging" return end
        if not AC.remoteObj then logStat.Text="RemoteEvent not found" logStat.TextColor3=Color3.fromRGB(255,100,100) return end
        AC.remoteHook=AC.remoteObj.OnClientEvent:Connect(function(...)
            local parts={} for i,a in ipairs({...}) do parts[i]=tostring(a) end
            local line="→ "..table.concat(parts," | ")
            table.insert(AC.logLines,line)
            logAppend(line,Color3.fromRGB(130,215,255))
        end)
        logStat.Text="✓ logging "..AC.remoteObj.Name logStat.TextColor3=Color3.fromRGB(100,255,140)
    end)
    stopL.MouseButton1Click:Connect(function()
        if AC.remoteHook then AC.remoteHook:Disconnect() AC.remoteHook=nil logStat.Text="stopped" end
    end)
    clearL.MouseButton1Click:Connect(function() AC.logLines={} logClear() end)

    -- ── ANTI NEUTRALISER ──
    Hdr(ASF,"🛡  anti-cheat neutraliser")
    Row(ASF,"hooks Detected (v_u_44) — swallows all kicks/crashes",Color3.fromRGB(130,130,130))
    local neutBtn=Btn(ASF,"⚡  neutralise",Color3.fromRGB(65,38,15))
    local restBtn=Btn(ASF,"↩  restore",   Color3.fromRGB(25,45,25))
    local antiLbl=Row(ASF,"idle")
    local _aorig,_ahooked=nil,false
    neutBtn.MouseButton1Click:Connect(function()
        if _ahooked then antiLbl.Text="already neutralised" return end
        local det=AC.DetectedFn or (AC.Anti and AC.Anti.Detected)
        if type(det)~="function" then antiLbl.Text="Detected not found" antiLbl.TextColor3=Color3.fromRGB(255,100,100) return end
        _aorig=det
        local ok,err=pcall(function()
            hookfn(det,newcc(function(action,reason)
                print("[ModExp] Detected() blocked: "..tostring(action).." / "..tostring(reason))
                return true
            end))
        end)
        if ok then _ahooked=true antiLbl.Text="✓ kicks/crashes blocked" antiLbl.TextColor3=Color3.fromRGB(100,255,140)
        else antiLbl.Text="hook fail: "..tostring(err) antiLbl.TextColor3=Color3.fromRGB(255,100,100) end
    end)
    restBtn.MouseButton1Click:Connect(function()
        if _ahooked and _aorig then pcall(hookfn,_aorig,_aorig) _ahooked=false antiLbl.Text="restored" end
    end)

    -- ── ACLI KICK NEUTRALISER ──
    Hdr(ASF,"📦  ACLI loader kick (v_u_48)")
    Row(ASF,"separate from Anti.Detected — hooks the loader-level kick fn",Color3.fromRGB(130,130,130))
    local neutAcli=Btn(ASF,"⚡  neutralise loader kick",Color3.fromRGB(65,38,15))
    local restAcli=Btn(ASF,"↩  restore",                Color3.fromRGB(25,45,25))
    local acliLbl=Row(ASF,AC.acliKickFn and "kick fn found" or "kick fn not found (run scan first)",
        AC.acliKickFn and Color3.fromRGB(255,215,80) or Color3.fromRGB(160,160,160))
    local _lkorig,_lkhooked=nil,false
    neutAcli.MouseButton1Click:Connect(function()
        if _lkhooked then acliLbl.Text="already neutralised" return end
        local fn=AC.acliKickFn
        if type(fn)~="function" then acliLbl.Text="not found — try re-scanning" acliLbl.TextColor3=Color3.fromRGB(255,100,100) return end
        _lkorig=fn
        local ok,err=pcall(function()
            hookfn(fn,newcc(function(reason)
                print("[ModExp] ACLI kick blocked: "..tostring(reason))
            end))
        end)
        if ok then _lkhooked=true acliLbl.Text="✓ loader kick blocked" acliLbl.TextColor3=Color3.fromRGB(100,255,140)
        else acliLbl.Text="hook fail: "..tostring(err) acliLbl.TextColor3=Color3.fromRGB(255,100,100) end
    end)
    restAcli.MouseButton1Click:Connect(function()
        if _lkhooked and _lkorig then pcall(hookfn,_lkorig,_lkorig) _lkhooked=false acliLbl.Text="restored" end
    end)

    -- ── ACLI LOGS ──
    Hdr(ASF,"📋  acliLogs (v_u_36)")
    local dumpBtn=Btn(ASF,"dump logs",Color3.fromRGB(28,38,58))
    local _,dumpAppend,dumpClear=LogBox(ASF,80)
    dumpBtn.MouseButton1Click:Connect(function()
        dumpClear()
        local logs=AC.acliLogs
        if not logs then dumpAppend("not found — run scan",Color3.fromRGB(255,120,120)) return end
        local n=0
        for _,v in ipairs(logs) do
            local col=v:find("WARNING",1,true) and Color3.fromRGB(255,200,80)
                or v:find("ACLI-0x",1,true) and Color3.fromRGB(255,120,120)
                or Color3.fromRGB(175,210,175)
            dumpAppend(v,col) n=n+1
        end
        if n==0 then dumpAppend("log table is empty — may not have loaded yet",Color3.fromRGB(140,140,140)) end
    end)

    -- ── _G API READER ──
    Hdr(ASF,"🔍  _G.Adonis reader")
    local readBtn=Btn(ASF,"read _G.Adonis",Color3.fromRGB(28,35,60))
    local _,apiAppend,apiClear=LogBox(ASF,70)
    readBtn.MouseButton1Click:Connect(function()
        apiClear()
        local api=rawget(_G,"Adonis")
        if not api then apiAppend("_G.Adonis not set yet",Color3.fromRGB(255,120,120)) return end
        for _,k in ipairs({"Access","Scripts","Debug","Service","API_Specific"}) do
            local ok,v=pcall(function() return api[k] end)
            apiAppend(k.." = "..(ok and typeof(v).." "..tostring(v) or "protected"),
                ok and Color3.fromRGB(195,170,255) or Color3.fromRGB(110,110,110))
        end
    end)

    -- ── TABLE WALKER ──
    Hdr(ASF,"🗂  table walker")
    for _,name in ipairs({"Core","Remote","Anti","Functions","Variables","Service"}) do
        local b=Btn(ASF,"dump "..name,Color3.fromRGB(28,28,48))
        local _,da,dc=LogBox(ASF,60)
        b.MouseButton1Click:Connect(function()
            dc()
            local tbl=AC[name]
            if not tbl then da(name.." not resolved",Color3.fromRGB(255,120,120)) return end
            local n=0
            pcall(function()
                for k,v in pairs(tbl) do
                    local vt=typeof(v)
                    da("["..vt.."] "..tostring(k).." = "..tostring(v),
                        vt=="function" and Color3.fromRGB(155,215,155) or
                        vt=="table" and Color3.fromRGB(195,170,255) or Color3.fromRGB(195,205,195))
                    n=n+1 if n>80 then da("...truncated") break end
                end
            end)
            if n==0 then da("empty or protected",Color3.fromRGB(110,110,110)) end
        end)
    end

    -- ── TASK VIEWER ──
    Hdr(ASF,"⏱  task viewer")
    local taskBtn=Btn(ASF,"↺  refresh",Color3.fromRGB(28,48,48))
    local _,ta,tc=LogBox(ASF,80)
    taskBtn.MouseButton1Click:Connect(function()
        tc()
        local svc=AC.Service
        if not svc then ta("Service not resolved",Color3.fromRGB(255,120,120)) return end
        local ok,tasks=pcall(function() return svc.GetTasks() end)
        if not ok or type(tasks)~="table" then ta("GetTasks() failed: "..tostring(tasks),Color3.fromRGB(255,120,120)) return end
        local n=0
        for _,t in pairs(tasks) do
            ta(tostring(t.Name or "?").." | "..tostring(t.Status or "?")..(t.isThread and " [thread]" or ""),
                Color3.fromRGB(175,215,175)) n=n+1
        end
        if n==0 then ta("no tasks running") end
    end)

    -- ── ERROR CODE REF ──
    Hdr(ASF,"🗒  ACLI error codes")
    local _,ea,_=LogBox(ASF,110)
    for _,p in ipairs({
        {"0x6E2FA164","env integrity violation"},
        {"0xEC7E1",   "proxy __index triggered"},
        {"0x28AEC",   "proxy __newindex triggered"},
        {"0x213A7768D","CallCheck: instance locked"},
        {"0xBC34ADD8","CallCheck: fenv mismatch"},
        {"0x20D21CEE7","module load fail"},
        {"0x102134B1E","bad module return (not SUCCESS)"},
        {"0xCE8CEF67","bad metatable on module return"},
    }) do ea(p[1].."  →  "..p[2],Color3.fromRGB(255,175,90)) end

    RefreshSF(ASF)
end

-- ─────────────────────────────────────────────────────────────
--  TREE BUILD
-- ─────────────────────────────────────────────────────────────
local function BuildTree()
    ClearSF(LeftSF) MkLL(LeftSF) TreeItems={}

    -- group by source
    local order,groups={},{}
    for _,m in ipairs(Modules) do
        if not groups[m.source] then
            groups[m.source]={} table.insert(order,m.source)
        end
        table.insert(groups[m.source],m)
    end

    local function MkLabel(txt,col,bg,indent)
        local f=Instance.new("Frame",LeftSF)
        f.Size=UDim2.new(1,-4,0,21) f.BackgroundColor3=bg or Color3.fromRGB(22,22,22) f.BorderSizePixel=0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,3)
        local l=Instance.new("TextLabel",f)
        l.Size=UDim2.new(1,-(indent+4),1,0) l.Position=UDim2.new(0,indent+4,0,0)
        l.BackgroundTransparency=1 l.Text=txt l.TextColor3=col
        l.TextSize=10 l.Font=Enum.Font.Code
        l.TextXAlignment=Enum.TextXAlignment.Left l.TextTruncate=Enum.TextTruncate.AtEnd
        return f,l
    end

    for _,src in ipairs(order) do
        local cf,cl=MkLabel("▾ "..src,Color3.fromRGB(135,155,255),Color3.fromRGB(28,28,48),0)
        cf.LayoutOrder=#TreeItems
        table.insert(TreeItems,{kind="container",label=src,frame=cf})
        local expanded=true local modFrames={}
        cf.InputBegan:Connect(function(i)
            if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            expanded=not expanded
            for _,mf in pairs(modFrames) do mf.Visible=expanded end
            cl.Text=(expanded and "▾ " or "▸ ")..src
        end)

        for mIdx,m in ipairs(groups[src]) do
            -- find real index in Modules table
            local realIdx=0
            for ri,rm in ipairs(Modules) do if rm==m then realIdx=ri break end end
            local mf,ml=MkLabel("  ◆ "..m.name,Color3.fromRGB(195,195,255),Color3.fromRGB(24,24,38),0)
            mf.LayoutOrder=#TreeItems
            table.insert(TreeItems,{kind="module",label=m.name,frame=mf})
            table.insert(modFrames,mf)
            local fnExpanded=false local fnFrames={}
            mf.InputBegan:Connect(function(i)
                if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
                fnExpanded=not fnExpanded
                for _,ff in pairs(fnFrames) do ff.Visible=fnExpanded end
                ml.Text=(fnExpanded and "  ▾ " or "  ◆ ")..m.name
            end)

            local fnNames={}
            for k in pairs(m.functions) do table.insert(fnNames,k) end
            table.sort(fnNames)

            for _,fnName in ipairs(fnNames) do
                local fnRef=m.functions[fnName]
                local uvc=0 pcall(function() uvc=#getupvalues(fnRef) end)
                local ff,_=MkLabel("    ƒ "..fnName..(uvc>0 and " +"..uvc or ""),
                    Color3.fromRGB(155,215,155),Color3.fromRGB(22,26,22),0)
                ff.LayoutOrder=#TreeItems ff.Visible=false
                table.insert(TreeItems,{kind="fn",label=fnName,frame=ff})
                table.insert(fnFrames,ff)
                ff.InputBegan:Connect(function(i)
                    if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
                    SelectFn(fnRef,fnName,realIdx)
                end)
            end
        end
    end

    task.defer(function()
        LeftSF.CanvasSize=UDim2.new(0,0,0,LeftLL.AbsoluteContentSize.Y+5)
    end)
end

-- ─────────────────────────────────────────────────────────────
--  SEARCH
-- ─────────────────────────────────────────────────────────────
SBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q=SBox.Text:lower():gsub("%s+","")
    for _,item in ipairs(TreeItems) do
        if q=="" then item.frame.Visible=(item.kind~="fn")
        else item.frame.Visible=(item.label:lower():find(q,1,true)~=nil) end
    end
    task.defer(function()
        LeftSF.CanvasSize=UDim2.new(0,0,0,LeftLL.AbsoluteContentSize.Y+5)
    end)
end)

-- ─────────────────────────────────────────────────────────────
--  SCANNER
-- ─────────────────────────────────────────────────────────────
local function SafeRequire(ms)
    local done,ok,res=false,false,nil
    task.spawn(function() ok,res=pcall(require,ms) done=true end)
    local t=0
    while not done and t<2 do task.wait(0.05) t=t+0.05 end
    if not done then return false,"timeout" end
    return ok,res
end

local function ScanInto(container,source,out)
    local descs={}
    pcall(function() descs=container:GetDescendants() end)
    local n=0
    for _,d in ipairs(descs) do
        if d:IsA("ModuleScript") then
            local ok,res=SafeRequire(d)
            if ok and type(res)=="table" then
                local fns={}
                pcall(function()
                    for k,v in pairs(res) do
                        if type(v)=="function" then fns[tostring(k)]=v end
                    end
                    for k,v in pairs(res) do
                        if type(v)=="table" then
                            for k2,v2 in pairs(v) do
                                if type(v2)=="function" then fns[tostring(k).."."..tostring(k2)]=v2 end
                            end
                        end
                    end
                end)
                if next(fns) then
                    table.insert(out,{name=d.Name,path=d:GetFullName(),module=res,source=source,functions=fns})
                end
            end
        end
        n=n+1
        if n%8==0 then task.wait() end
    end
end

local function RunScan()
    if Scanning then return end
    Scanning=true
    Modules={}
    if not AdonisOpen then Hint.Visible=true DFrame.Visible=false end
    SetStatus("scanning RepStore...",Color3.fromRGB(255,175,50))
    task.spawn(function()
        ScanInto(RepStore,"ReplicatedStorage",Modules)
        SetStatus("scanning LocalPlayer...",Color3.fromRGB(255,175,50))
        for _,n in ipairs({"Backpack","PlayerScripts","PlayerGui"}) do
            local c=lp:FindFirstChild(n)
            if c then ScanInto(c,"LocalPlayer."..n,Modules) end
        end
        if lp.Character then ScanInto(lp.Character,"LocalPlayer.Character",Modules) end
        SetStatus("scanning CoreGui...",Color3.fromRGB(255,175,50))
        pcall(function() ScanInto(CoreGui,"CoreGui",Modules) end)
        local rg=CoreGui:FindFirstChild("RobloxGui")
        if rg then pcall(function() ScanInto(rg,"RobloxGui",Modules) end) end
        SetStatus("building tree...",Color3.fromRGB(255,175,50))
        Resolve()
        BuildTree()
        SetStatus(#Modules.." modules",Color3.fromRGB(80,255,130))
        if AdonisOpen then BuildAdonis() end
        Scanning=false
    end)
end

-- ─────────────────────────────────────────────────────────────
--  BUTTON WIRING
-- ─────────────────────────────────────────────────────────────
BtnScan.MouseButton1Click:Connect(RunScan)

BtnAdonis.MouseButton1Click:Connect(function()
    AdonisOpen=not AdonisOpen
    if AdonisOpen then
        Resolve()
        BuildAdonis()
        APanel.Visible=true
        Hint.Visible=false DFrame.Visible=false
        BtnAdonis.BackgroundColor3=Color3.fromRGB(95,38,130)
    else
        APanel.Visible=false
        Hint.Visible=true
        BtnAdonis.BackgroundColor3=Color3.fromRGB(60,25,80)
    end
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
RunScan()
print("[ModuleExplorer v3] RightAlt = toggle  |  ★ adonis = panel")
