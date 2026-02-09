-- Overseer CE - Cheat Engine Style Module Inspector
-- Focus: Deep metatable inspection & live patching

-- Service References
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

-- Initialize Modules table
if not _G.Modules then
    _G.Modules = {}
end

local Modules = _G.Modules

Modules.OverseerCE = {
    State = {
        IsEnabled = false,
        ActivePatches = {},
        SelectedModule = nil,
        CurrentTable = nil,
        PathStack = {},
        UI = nil,
        ModuleList = {},
        PatchList = {},
        VisitedTables = {},
        MetatableChain = {},
        FreezeList = {},
        EditingRow = nil,
        SearchFilter = "",
        ShowMetatables = true,
        ShowFunctions = true,
        AutoRefresh = false,
        -- New features
        ScanResults = {},
        ScanInProgress = false,
        DumpedModules = {},
        InjectionHistory = {},
        AntiTamperActive = false,
        OriginalFunctions = {},
        HookedFunctions = {}
    },
    Config = {
        -- Cheat Engine Color Scheme
        BG_LIGHT = Color3.fromRGB(240, 240, 240),
        BG_PANEL = Color3.fromRGB(236, 233, 216),
        BG_DARK = Color3.fromRGB(212, 208, 200),
        BG_WHITE = Color3.fromRGB(255, 255, 255),
        BORDER_DARK = Color3.fromRGB(128, 128, 128),
        BORDER_LIGHT = Color3.fromRGB(255, 255, 255),
        TEXT_BLACK = Color3.fromRGB(0, 0, 0),
        TEXT_GRAY = Color3.fromRGB(128, 128, 128),
        ACCENT_BLUE = Color3.fromRGB(49, 106, 197),
        HIGHLIGHT = Color3.fromRGB(51, 153, 255),
        FROZEN_RED = Color3.fromRGB(255, 0, 0),
        
        HEADER_HEIGHT = 24,
        ROW_HEIGHT = 20,
        BUTTON_HEIGHT = 23,
        PADDING = 4
    }
}

-- Utility Functions
function Modules.OverseerCE:_createBorder(parent, inset)
    local topColor = inset and self.Config.BORDER_DARK or self.Config.BORDER_LIGHT
    local bottomColor = inset and self.Config.BORDER_LIGHT or self.Config.BORDER_DARK
    
    local top = Instance.new("Frame", parent)
    top.Name = "BorderTop"
    top.Size = UDim2.new(1, 0, 0, 1)
    top.Position = UDim2.new(0, 0, 0, 0)
    top.BackgroundColor3 = topColor
    top.BorderSizePixel = 0
    top.ZIndex = parent.ZIndex + 1
    
    local left = Instance.new("Frame", parent)
    left.Name = "BorderLeft"
    left.Size = UDim2.new(0, 1, 1, 0)
    left.Position = UDim2.new(0, 0, 0, 0)
    left.BackgroundColor3 = topColor
    left.BorderSizePixel = 0
    left.ZIndex = parent.ZIndex + 1
    
    local bottom = Instance.new("Frame", parent)
    bottom.Name = "BorderBottom"
    bottom.Size = UDim2.new(1, 0, 0, 1)
    bottom.Position = UDim2.new(0, 0, 1, -1)
    bottom.BackgroundColor3 = bottomColor
    bottom.BorderSizePixel = 0
    bottom.ZIndex = parent.ZIndex + 1
    
    local right = Instance.new("Frame", parent)
    right.Name = "BorderRight"
    right.Size = UDim2.new(0, 1, 1, 0)
    right.Position = UDim2.new(1, -1, 0, 0)
    right.BackgroundColor3 = bottomColor
    right.BorderSizePixel = 0
    right.ZIndex = parent.ZIndex + 1
end

function Modules.OverseerCE:_createButton(parent, text, size, position, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = self.Config.BG_PANEL
    btn.Text = text
    btn.TextColor3 = self.Config.TEXT_BLACK
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    
    self:_createBorder(btn, false)
    
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    
    -- Button press effect
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundColor3 = self.Config.BG_DARK
        for _, child in ipairs(btn:GetChildren()) do
            if child.Name == "BorderTop" or child.Name == "BorderLeft" then
                child.BackgroundColor3 = self.Config.BORDER_DARK
            elseif child.Name == "BorderBottom" or child.Name == "BorderRight" then
                child.BackgroundColor3 = self.Config.BORDER_LIGHT
            end
        end
    end)
    
    btn.MouseButton1Up:Connect(function()
        btn.BackgroundColor3 = self.Config.BG_PANEL
        for _, child in ipairs(btn:GetChildren()) do
            if child.Name == "BorderTop" or child.Name == "BorderLeft" then
                child.BackgroundColor3 = self.Config.BORDER_LIGHT
            elseif child.Name == "BorderBottom" or child.Name == "BorderRight" then
                child.BackgroundColor3 = self.Config.BORDER_DARK
            end
        end
    end)
    
    return btn
end

function Modules.OverseerCE:_createPanel(parent, position, size, title)
    local panel = Instance.new("Frame", parent)
    panel.Position = position
    panel.Size = size
    panel.BackgroundColor3 = self.Config.BG_PANEL
    panel.BorderSizePixel = 0
    
    self:_createBorder(panel, false)
    
    if title then
        local titleLabel = Instance.new("TextLabel", panel)
        titleLabel.Size = UDim2.new(1, -4, 0, 18)
        titleLabel.Position = UDim2.new(0, 2, 0, 2)
        titleLabel.BackgroundColor3 = self.Config.BG_DARK
        titleLabel.Text = title
        titleLabel.TextColor3 = self.Config.TEXT_BLACK
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextSize = 11
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.BorderSizePixel = 0
        
        local titlePadding = Instance.new("UIPadding", titleLabel)
        titlePadding.PaddingLeft = UDim.new(0, 4)
        
        self:_createBorder(titleLabel, true)
    end
    
    return panel
end

function Modules.OverseerCE:_setClipboard(txt)
    if setclipboard then 
        setclipboard(txt) 
    elseif toclipboard then
        toclipboard(txt)
    end
end

function Modules.OverseerCE:_generateUID()
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, 12 do
        local rand = math.random(1, #charset)
        result = result .. charset:sub(rand, rand)
    end
    return result
end

-- ========================
-- CONSTANT SCANNING SYSTEM
-- ========================

function Modules.OverseerCE:ScanForConstant(searchValue, searchType, exactMatch)
    self.State.ScanResults = {}
    self.State.ScanInProgress = true
    
    local results = {}
    local scanned = {}
    
    local function scanTable(tbl, path, depth)
        if depth > 20 then return end
        if scanned[tbl] then return end
        scanned[tbl] = true
        
        for key, value in pairs(tbl) do
            local matches = false
            
            -- Type matching
            if searchType == "any" or type(value) == searchType then
                if exactMatch then
                    matches = (value == searchValue)
                else
                    -- Fuzzy matching for strings
                    if type(value) == "string" and type(searchValue) == "string" then
                        matches = value:lower():find(searchValue:lower(), 1, true) ~= nil
                    elseif type(value) == "number" and type(searchValue) == "number" then
                        matches = math.abs(value - searchValue) < 0.0001
                    else
                        matches = (tostring(value):lower():find(tostring(searchValue):lower(), 1, true) ~= nil)
                    end
                end
            end
            
            if matches then
                table.insert(results, {
                    Path = path .. "." .. tostring(key),
                    Key = key,
                    Value = value,
                    Type = type(value),
                    Table = tbl,
                    Depth = depth
                })
            end
            
            -- Recurse into tables
            if type(value) == "table" and depth < 20 then
                scanTable(value, path .. "." .. tostring(key), depth + 1)
            end
        end
        
        -- Scan metatable
        local mt = getmetatable(tbl)
        if mt and type(mt) == "table" then
            scanTable(mt, path .. ".[MT]", depth + 1)
        end
    end
    
    -- Scan all loaded modules
    for _, moduleData in ipairs(self.State.ModuleList) do
        local success, moduleTable = pcall(function()
            return require(moduleData.Script)
        end)
        
        if success and type(moduleTable) == "table" then
            scanTable(moduleTable, moduleData.Name, 0)
        end
    end
    
    self.State.ScanResults = results
    self.State.ScanInProgress = false
    
    return results
end

function Modules.OverseerCE:FindReferences(targetValue)
    -- Find all references to a specific value/table/function
    local references = {}
    local scanned = {}
    
    local function findRefs(tbl, path, depth)
        if depth > 20 then return end
        if scanned[tbl] then return end
        scanned[tbl] = true
        
        for key, value in pairs(tbl) do
            if value == targetValue or rawequal(value, targetValue) then
                table.insert(references, {
                    Path = path .. "." .. tostring(key),
                    Key = key,
                    Table = tbl,
                    Depth = depth
                })
            end
            
            if type(value) == "table" then
                findRefs(value, path .. "." .. tostring(key), depth + 1)
            end
        end
        
        local mt = getmetatable(tbl)
        if mt and type(mt) == "table" then
            findRefs(mt, path .. ".[MT]", depth + 1)
        end
    end
    
    for _, moduleData in ipairs(self.State.ModuleList) do
        local success, moduleTable = pcall(function()
            return require(moduleData.Script)
        end)
        
        if success and type(moduleTable) == "table" then
            findRefs(moduleTable, moduleData.Name, 0)
        end
    end
    
    return references
end

-- ========================
-- MEMORY DUMPING SYSTEM
-- ========================

function Modules.OverseerCE:DumpModule(moduleScript, includeMetatables, includeFunctions, maxDepth)
    maxDepth = maxDepth or 10
    
    local success, moduleTable = pcall(function()
        return require(moduleScript)
    end)
    
    if not success then
        return {Success = false, Error = "Failed to require module"}
    end
    
    local dump = {
        Name = moduleScript.Name,
        Path = moduleScript:GetFullName(),
        Timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        Structure = {}
    }
    
    local visited = {}
    
    local function dumpValue(value, depth)
        if depth > maxDepth then
            return {Type = type(value), Value = "[MAX DEPTH]"}
        end
        
        local valueType = type(value)
        
        if valueType == "nil" or valueType == "boolean" or valueType == "number" then
            return {Type = valueType, Value = value}
        elseif valueType == "string" then
            return {Type = valueType, Value = value:sub(1, 100)} -- Truncate long strings
        elseif valueType == "function" then
            if not includeFunctions then
                return {Type = "function", Value = "[FUNCTION]"}
            end
            
            local info = {}
            pcall(function()
                if debug and debug.getinfo then
                    local dbgInfo = debug.getinfo(value)
                    info = {
                        Source = dbgInfo.source,
                        LineDefined = dbgInfo.linedefined,
                        NumParams = dbgInfo.nparams,
                        NumUpvalues = dbgInfo.nups
                    }
                end
            end)
            
            return {
                Type = "function",
                Value = tostring(value),
                DebugInfo = info
            }
        elseif valueType == "table" then
            if visited[value] then
                return {Type = "table", Value = "[CIRCULAR:" .. tostring(value) .. "]"}
            end
            
            visited[value] = true
            
            local tableDump = {
                Type = "table",
                Address = tostring(value),
                Fields = {}
            }
            
            -- Dump fields
            for k, v in pairs(value) do
                tableDump.Fields[tostring(k)] = dumpValue(v, depth + 1)
            end
            
            -- Dump metatable
            if includeMetatables then
                local mt = getmetatable(value)
                if mt then
                    tableDump.Metatable = dumpValue(mt, depth + 1)
                end
            end
            
            return tableDump
        else
            return {Type = valueType, Value = tostring(value)}
        end
    end
    
    dump.Structure = dumpValue(moduleTable, 0)
    
    -- Store dump
    table.insert(self.State.DumpedModules, dump)
    
    return {Success = true, Dump = dump}
end

function Modules.OverseerCE:ExportDump(dump)
    local HttpService = game:GetService("HttpService")
    
    local success, json = pcall(function()
        return HttpService:JSONEncode(dump)
    end)
    
    if success then
        self:_setClipboard(json)
        return {Success = true, JSON = json}
    else
        return {Success = false, Error = "JSON encoding failed: " .. tostring(json)}
    end
end

function Modules.OverseerCE:DumpAllModules()
    local allDumps = {}
    
    for _, moduleData in ipairs(self.State.ModuleList) do
        local result = self:DumpModule(moduleData.Script, true, true, 8)
        if result.Success then
            table.insert(allDumps, result.Dump)
        end
    end
    
    return {
        Success = true,
        Timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        TotalModules = #allDumps,
        Dumps = allDumps
    }
end

-- ========================
-- LIVE CODE INJECTION
-- ========================

function Modules.OverseerCE:InjectCode(code, targetModule, withUpvalues)
    local success, result = pcall(function()
        local func = loadstring(code)
        if not func then
            return {Success = false, Error = "Failed to compile code"}
        end
        
        -- Create custom environment
        local env = {}
        local envMeta = {}
        
        if targetModule then
            -- Get module's environment
            local moduleTable = require(targetModule)
            
            envMeta.__index = function(_, key)
                -- Try module table first
                if moduleTable[key] ~= nil then
                    return moduleTable[key]
                end
                -- Fall back to global
                return _G[key]
            end
            
            envMeta.__newindex = function(_, key, value)
                -- Write to module table if it exists there, otherwise global
                if moduleTable[key] ~= nil then
                    moduleTable[key] = value
                else
                    _G[key] = value
                end
            end
        else
            envMeta.__index = _G
            envMeta.__newindex = _G
        end
        
        setmetatable(env, envMeta)
        
        if setfenv then
            setfenv(func, env)
        end
        
        -- Execute
        local execResult = {func()}
        
        -- Log injection
        table.insert(self.State.InjectionHistory, {
            Code = code,
            Target = targetModule and targetModule.Name or "Global",
            Timestamp = tick(),
            Result = execResult
        })
        
        return {Success = true, Result = execResult}
    end)
    
    if success then
        return result
    else
        return {Success = false, Error = tostring(result)}
    end
end

function Modules.OverseerCE:GetUpvalues(func)
    if type(func) ~= "function" then
        return {Success = false, Error = "Not a function"}
    end
    
    local upvalues = {}
    
    if debug and debug.getupvalue then
        local i = 1
        while true do
            local name, value = debug.getupvalue(func, i)
            if not name then break end
            
            table.insert(upvalues, {
                Index = i,
                Name = name,
                Value = value,
                Type = type(value)
            })
            
            i = i + 1
        end
    end
    
    return {Success = true, Upvalues = upvalues}
end

function Modules.OverseerCE:SetUpvalue(func, index, newValue)
    if type(func) ~= "function" then
        return {Success = false, Error = "Not a function"}
    end
    
    if debug and debug.setupvalue then
        local name = debug.setupvalue(func, index, newValue)
        if name then
            return {Success = true, UpvalueName = name}
        else
            return {Success = false, Error = "Invalid upvalue index"}
        end
    end
    
    return {Success = false, Error = "debug.setupvalue not available"}
end

-- ========================
-- ANTI-TAMPER BYPASS
-- ========================

function Modules.OverseerCE:EnableAntiTamper()
    if self.State.AntiTamperActive then
        return {Success = false, Error = "Anti-tamper already active"}
    end
    
    -- Store original functions
    self.State.OriginalFunctions = {
        getmetatable = getmetatable,
        setmetatable = setmetatable,
        rawget = rawget,
        rawset = rawset,
        rawequal = rawequal,
        type = type,
        typeof = typeof
    }
    
    -- Hook getmetatable to hide our modifications
    local originalGetmetatable = getmetatable
    getmetatable = function(tbl)
        local mt = originalGetmetatable(tbl)
        
        -- Check if we've modified this metatable
        if mt and self.State.ActivePatches[mt] then
            -- Return clean version
            local cleanMt = {}
            for k, v in pairs(mt) do
                if not self.State.ActivePatches[mt][k] then
                    cleanMt[k] = v
                else
                    cleanMt[k] = self.State.ActivePatches[mt][k].Original
                end
            end
            return cleanMt
        end
        
        return mt
    end
    
    -- Hook setmetatable to detect anti-cheat setters
    local originalSetmetatable = setmetatable
    setmetatable = function(tbl, mt)
        -- Log metatable changes
        print("[Anti-Tamper] setmetatable called on:", tostring(tbl))
        
        -- Allow it through
        return originalSetmetatable(tbl, mt)
    end
    
    -- Hook rawset to detect write protection checks
    local originalRawset = rawset
    rawset = function(tbl, key, value)
        -- Check if this is a protected patch
        for patchId, patch in pairs(self.State.FreezeList) do
            if patch.Table == tbl and patch.Key == key then
                print("[Anti-Tamper] Blocked rawset on frozen patch:", key)
                return -- Block the write
            end
        end
        
        return originalRawset(tbl, key, value)
    end
    
    -- Hook type/typeof to spoof our modifications
    local originalType = type
    type = function(value)
        -- If value is a hooked function, return "function"
        if self.State.HookedFunctions[value] then
            return "function"
        end
        return originalType(value)
    end
    
    if typeof then
        local originalTypeof = typeof
        typeof = function(value)
            if self.State.HookedFunctions[value] then
                return "function"
            end
            return originalTypeof(value)
        end
    end
    
    self.State.AntiTamperActive = true
    
    print("[Anti-Tamper] Protection enabled")
    return {Success = true}
end

function Modules.OverseerCE:DisableAntiTamper()
    if not self.State.AntiTamperActive then
        return {Success = false, Error = "Anti-tamper not active"}
    end
    
    -- Restore original functions
    getmetatable = self.State.OriginalFunctions.getmetatable
    setmetatable = self.State.OriginalFunctions.setmetatable
    rawget = self.State.OriginalFunctions.rawget
    rawset = self.State.OriginalFunctions.rawset
    rawequal = self.State.OriginalFunctions.rawequal
    type = self.State.OriginalFunctions.type
    if typeof then
        typeof = self.State.OriginalFunctions.typeof
    end
    
    self.State.AntiTamperActive = false
    self.State.OriginalFunctions = {}
    
    print("[Anti-Tamper] Protection disabled")
    return {Success = true}
end

function Modules.OverseerCE:DetectAntiCheat()
    -- Scan for common anti-cheat patterns
    local detections = {}
    
    local patterns = {
        -- Check for environment scanning
        {Name = "getfenv Hook", Check = function()
            return getfenv ~= debug.getfenv
        end},
        
        -- Check for metatable protection
        {Name = "Protected Metatables", Check = function()
            local test = {}
            local success = pcall(function()
                setmetatable(test, {__metatable = "Locked"})
                getmetatable(test)
            end)
            return not success
        end},
        
        -- Check for debug library
        {Name = "Debug Library Available", Check = function()
            return debug ~= nil
        end},
        
        -- Check for common global hooks
        {Name = "Global Hooks", Check = function()
            return _G.__HOOKED or _G.__PROTECTED or _G.__ANTICHEAT
        end}
    }
    
    for _, pattern in ipairs(patterns) do
        local success, result = pcall(pattern.Check)
        if success then
            table.insert(detections, {
                Name = pattern.Name,
                Detected = result,
                Timestamp = tick()
            })
        end
    end
    
    return {Success = true, Detections = detections}
end

-- Deep Metatable Analysis
function Modules.OverseerCE:AnalyzeMetatableChain(tbl)
    local chain = {}
    local current = tbl
    local depth = 0
    local visited = {}
    
    while current and depth < 20 do
        if visited[current] then break end
        visited[current] = true
        
        local mt = getmetatable(current)
        if not mt then break end
        
        local chainEntry = {
            Depth = depth,
            Metatable = mt,
            Fields = {},
            HasIndex = false,
            IndexType = nil,
            IndexValue = nil
        }
        
        -- Analyze metatable fields
        for k, v in pairs(mt) do
            table.insert(chainEntry.Fields, {
                Key = k,
                Value = v,
                Type = type(v)
            })
            
            if k == "__index" then
                chainEntry.HasIndex = true
                chainEntry.IndexType = type(v)
                chainEntry.IndexValue = v
            end
        end
        
        table.insert(chain, chainEntry)
        
        -- Follow __index chain if it's a table
        if chainEntry.HasIndex and chainEntry.IndexType == "table" then
            current = chainEntry.IndexValue
        else
            break
        end
        
        depth = depth + 1
    end
    
    return chain
end

-- Patch Management
function Modules.OverseerCE:CreatePatch(tbl, key, newValue, freeze)
    if not tbl or key == nil then return false end
    
    local patchId = self:_generateUID()
    
    pcall(function()
        if setreadonly then setreadonly(tbl, false) 
        elseif make_writeable then make_writeable(tbl) end
    end)
    
    local originalValue = rawget(tbl, key)
    
    local patch = {
        ID = patchId,
        Table = tbl,
        Key = key,
        Original = originalValue,
        NewValue = newValue,
        Frozen = freeze or false,
        Type = type(newValue),
        Timestamp = tick(),
        Active = true
    }
    
    -- Apply patch
    rawset(tbl, key, newValue)
    
    self.State.ActivePatches[patchId] = patch
    
    if freeze then
        self.State.FreezeList[patchId] = patch
    end
    
    pcall(function()
        if setreadonly then setreadonly(tbl, true) end
    end)
    
    self:RefreshPatchList()
    return patchId
end

function Modules.OverseerCE:RemovePatch(patchId)
    local patch = self.State.ActivePatches[patchId]
    if not patch then return false end
    
    pcall(function()
        if setreadonly then setreadonly(patch.Table, false) 
        elseif make_writeable then make_writeable(patch.Table) end
        rawset(patch.Table, patch.Key, patch.Original)
        if setreadonly then setreadonly(patch.Table, true) end
    end)
    
    self.State.ActivePatches[patchId] = nil
    self.State.FreezeList[patchId] = nil
    
    self:RefreshPatchList()
    return true
end

function Modules.OverseerCE:ToggleFreeze(patchId)
    local patch = self.State.ActivePatches[patchId]
    if not patch then return end
    
    patch.Frozen = not patch.Frozen
    
    if patch.Frozen then
        self.State.FreezeList[patchId] = patch
    else
        self.State.FreezeList[patchId] = nil
    end
    
    self:RefreshPatchList()
end

-- UI Creation
function Modules.OverseerCE:CreateUI()
    if self.State.UI and self.State.UI.Main then 
        self.State.UI.Main.Visible = true 
        return 
    end

    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "OverseerCE"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local main = Instance.new("Frame", screenGui)
    main.Size = UDim2.fromOffset(900, 600)
    main.Position = UDim2.new(0.5, -450, 0.5, -300)
    main.BackgroundColor3 = self.Config.BG_PANEL
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    
    self:_createBorder(main, false)

    -- Title Bar
    local titleBar = Instance.new("Frame", main)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, -2, 0, 24)
    titleBar.Position = UDim2.fromOffset(1, 1)
    titleBar.BackgroundColor3 = self.Config.ACCENT_BLUE
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    
    local titleGradient = Instance.new("UIGradient", titleBar)
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 106, 197)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 190, 230))
    }
    titleGradient.Rotation = 90

    local titleIcon = Instance.new("TextLabel", titleBar)
    titleIcon.Size = UDim2.fromOffset(20, 20)
    titleIcon.Position = UDim2.fromOffset(2, 2)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = "🔧"
    titleIcon.TextColor3 = self.Config.BG_WHITE
    titleIcon.Font = Enum.Font.SourceSansBold
    titleIcon.TextSize = 14
    titleIcon.ZIndex = 3

    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.fromOffset(24, 0)
    title.Text = "Overseer CE 7.1 - Module Inspector & Patcher"
    title.TextColor3 = self.Config.BG_WHITE
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = 3

    -- Window control buttons
    local closeBtn = self:_createButton(titleBar, "×", UDim2.fromOffset(20, 20), UDim2.new(1, -22, 0, 2), function()
        main.Visible = false
    end)
    closeBtn.ZIndex = 4
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.BackgroundColor3 = self.Config.BG_LIGHT

    local minBtn = self:_createButton(titleBar, "_", UDim2.fromOffset(20, 20), UDim2.new(1, -44, 0, 2), function()
        main.Visible = false
    end)
    minBtn.ZIndex = 4
    minBtn.TextYAlignment = Enum.TextYAlignment.Top
    minBtn.BackgroundColor3 = self.Config.BG_LIGHT

    -- Resize handle (bottom-right corner)
    local resizeHandle = Instance.new("Frame", main)
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(16, 16)
    resizeHandle.Position = UDim2.new(1, -16, 1, -16)
    resizeHandle.BackgroundColor3 = self.Config.BG_DARK
    resizeHandle.BorderSizePixel = 0
    resizeHandle.ZIndex = 10
    
    -- Resize handle visual indicator
    local resizeLine1 = Instance.new("Frame", resizeHandle)
    resizeLine1.Size = UDim2.fromOffset(2, 12)
    resizeLine1.Position = UDim2.fromOffset(10, 2)
    resizeLine1.BackgroundColor3 = self.Config.BORDER_LIGHT
    resizeLine1.BorderSizePixel = 0
    resizeLine1.Rotation = 45
    
    local resizeLine2 = Instance.new("Frame", resizeHandle)
    resizeLine2.Size = UDim2.fromOffset(2, 12)
    resizeLine2.Position = UDim2.fromOffset(6, 2)
    resizeLine2.BackgroundColor3 = self.Config.BORDER_LIGHT
    resizeLine2.BorderSizePixel = 0
    resizeLine2.Rotation = 45
    
    local resizeLine3 = Instance.new("Frame", resizeHandle)
    resizeLine3.Size = UDim2.fromOffset(2, 8)
    resizeLine3.Position = UDim2.fromOffset(2, 4)
    resizeLine3.BackgroundColor3 = self.Config.BORDER_LIGHT
    resizeLine3.BorderSizePixel = 0
    resizeLine3.Rotation = 45

    -- Content area
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -4, 1, -28)
    content.Position = UDim2.fromOffset(2, 26)
    content.BackgroundColor3 = self.Config.BG_PANEL
    content.BorderSizePixel = 0

    -- Menu bar
    local menuBar = Instance.new("Frame", content)
    menuBar.Size = UDim2.new(1, 0, 0, 22)
    menuBar.Position = UDim2.fromOffset(0, 0)
    menuBar.BackgroundColor3 = self.Config.BG_PANEL
    menuBar.BorderSizePixel = 0
    
    self:_createBorder(menuBar, false)
    
    -- Menu items
    local menuItems = {"Tools", "Scanner", "Dumper", "Injector", "Anti-Tamper"}
    local menuX = 4
    
    for _, menuName in ipairs(menuItems) do
        local menuBtn = self:_createButton(menuBar, menuName, UDim2.fromOffset(75, 18), UDim2.fromOffset(menuX, 2), function()
            self:OpenToolWindow(menuName)
        end)
        menuBtn.TextSize = 10
        menuX = menuX + 77
    end

    -- Left panel: Module list
    local modulePanel = self:_createPanel(content, UDim2.fromOffset(4, 26), UDim2.new(0, 280, 1, -30), "Module List")
    
    local moduleSearch = Instance.new("TextBox", modulePanel)
    moduleSearch.Size = UDim2.new(1, -8, 0, 22)
    moduleSearch.Position = UDim2.fromOffset(4, 24)
    moduleSearch.BackgroundColor3 = self.Config.BG_WHITE
    moduleSearch.Text = ""
    moduleSearch.PlaceholderText = "Search modules..."
    moduleSearch.TextColor3 = self.Config.TEXT_BLACK
    moduleSearch.Font = Enum.Font.SourceSans
    moduleSearch.TextSize = 11
    moduleSearch.TextXAlignment = Enum.TextXAlignment.Left
    moduleSearch.BorderSizePixel = 0
    
    local searchPadding = Instance.new("UIPadding", moduleSearch)
    searchPadding.PaddingLeft = UDim.new(0, 4)
    
    self:_createBorder(moduleSearch, true)
    
    local moduleScroll = Instance.new("ScrollingFrame", modulePanel)
    moduleScroll.Size = UDim2.new(1, -8, 1, -54)
    moduleScroll.Position = UDim2.fromOffset(4, 50)
    moduleScroll.BackgroundColor3 = self.Config.BG_WHITE
    moduleScroll.BorderSizePixel = 0
    moduleScroll.ScrollBarThickness = 12
    moduleScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    moduleScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    self:_createBorder(moduleScroll, true)
    
    local moduleList = Instance.new("UIListLayout", moduleScroll)
    moduleList.Padding = UDim.new(0, 1)

    -- Middle panel: Table inspector
    local inspectorPanel = self:_createPanel(content, UDim2.fromOffset(292, 26), UDim2.new(1, -596, 1, -30), "Table Inspector")
    
    -- Toolbar
    local toolbar = Instance.new("Frame", inspectorPanel)
    toolbar.Size = UDim2.new(1, -8, 0, 28)
    toolbar.Position = UDim2.fromOffset(4, 24)
    toolbar.BackgroundColor3 = self.Config.BG_DARK
    toolbar.BorderSizePixel = 0
    
    self:_createBorder(toolbar, true)
    
    local backBtn = self:_createButton(toolbar, "< Back", UDim2.fromOffset(60, 22), UDim2.fromOffset(2, 2), function()
        self:GoBack()
    end)
    
    local refreshBtn = self:_createButton(toolbar, "Refresh", UDim2.fromOffset(60, 22), UDim2.fromOffset(64, 2), function()
        self:RefreshInspector()
    end)
    
    local pathLabel = Instance.new("TextLabel", toolbar)
    pathLabel.Size = UDim2.new(1, -130, 1, -4)
    pathLabel.Position = UDim2.fromOffset(128, 2)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = "Root"
    pathLabel.TextColor3 = self.Config.TEXT_BLACK
    pathLabel.Font = Enum.Font.Code
    pathLabel.TextSize = 10
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left
    pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Column headers
    local headerFrame = Instance.new("Frame", inspectorPanel)
    headerFrame.Size = UDim2.new(1, -8, 0, self.Config.ROW_HEIGHT)
    headerFrame.Position = UDim2.fromOffset(4, 56)
    headerFrame.BackgroundColor3 = self.Config.BG_DARK
    headerFrame.BorderSizePixel = 0
    
    self:_createBorder(headerFrame, true)
    
    local headers = {"Active", "Key", "Type", "Value", "Actions"}
    local headerWidths = {0.08, 0.25, 0.12, 0.35, 0.2}
    local xPos = 0
    
    for i, headerText in ipairs(headers) do
        local header = Instance.new("TextLabel", headerFrame)
        header.Size = UDim2.new(headerWidths[i], -2, 1, 0)
        header.Position = UDim2.new(xPos, 1, 0, 0)
        header.BackgroundTransparency = 1
        header.Text = headerText
        header.TextColor3 = self.Config.TEXT_BLACK
        header.Font = Enum.Font.SourceSansBold
        header.TextSize = 10
        header.TextXAlignment = Enum.TextXAlignment.Left
        
        local headerPadding = Instance.new("UIPadding", header)
        headerPadding.PaddingLeft = UDim.new(0, 4)
        
        xPos = xPos + headerWidths[i]
    end
    
    -- Inspector scroll
    local inspectorScroll = Instance.new("ScrollingFrame", inspectorPanel)
    inspectorScroll.Size = UDim2.new(1, -8, 1, -84)
    inspectorScroll.Position = UDim2.fromOffset(4, 76)
    inspectorScroll.BackgroundColor3 = self.Config.BG_WHITE
    inspectorScroll.BorderSizePixel = 0
    inspectorScroll.ScrollBarThickness = 12
    inspectorScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    inspectorScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    self:_createBorder(inspectorScroll, true)
    
    local inspectorList = Instance.new("UIListLayout", inspectorScroll)
    inspectorList.Padding = UDim.new(0, 0)

    -- Right panel: Patch manager
    local patchPanel = self:_createPanel(content, UDim2.new(1, -304, 0, 26), UDim2.fromOffset(296, 570), "Active Patches")
    
    -- Patch controls
    local patchControls = Instance.new("Frame", patchPanel)
    patchControls.Size = UDim2.new(1, -8, 0, 28)
    patchControls.Position = UDim2.fromOffset(4, 24)
    patchControls.BackgroundColor3 = self.Config.BG_DARK
    patchControls.BorderSizePixel = 0
    
    self:_createBorder(patchControls, true)
    
    local clearAllBtn = self:_createButton(patchControls, "Clear All", UDim2.fromOffset(70, 22), UDim2.fromOffset(2, 2), function()
        for patchId in pairs(self.State.ActivePatches) do
            self:RemovePatch(patchId)
        end
    end)
    
    local exportBtn = self:_createButton(patchControls, "Export", UDim2.fromOffset(60, 22), UDim2.fromOffset(74, 2), function()
        self:ExportPatches()
    end)
    
    local patchCount = Instance.new("TextLabel", patchControls)
    patchCount.Size = UDim2.new(1, -140, 1, 0)
    patchCount.Position = UDim2.fromOffset(138, 0)
    patchCount.BackgroundTransparency = 1
    patchCount.Text = "Patches: 0"
    patchCount.TextColor3 = self.Config.TEXT_BLACK
    patchCount.Font = Enum.Font.SourceSans
    patchCount.TextSize = 10
    patchCount.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Patch list headers
    local patchHeaderFrame = Instance.new("Frame", patchPanel)
    patchHeaderFrame.Size = UDim2.new(1, -8, 0, self.Config.ROW_HEIGHT)
    patchHeaderFrame.Position = UDim2.fromOffset(4, 56)
    patchHeaderFrame.BackgroundColor3 = self.Config.BG_DARK
    patchHeaderFrame.BorderSizePixel = 0
    
    self:_createBorder(patchHeaderFrame, true)
    
    local patchHeaders = {"Frozen", "Key", "Value", "Del"}
    local patchHeaderWidths = {0.15, 0.35, 0.35, 0.15}
    local patchXPos = 0
    
    for i, patchHeaderText in ipairs(patchHeaders) do
        local patchHeader = Instance.new("TextLabel", patchHeaderFrame)
        patchHeader.Size = UDim2.new(patchHeaderWidths[i], -2, 1, 0)
        patchHeader.Position = UDim2.new(patchXPos, 1, 0, 0)
        patchHeader.BackgroundTransparency = 1
        patchHeader.Text = patchHeaderText
        patchHeader.TextColor3 = self.Config.TEXT_BLACK
        patchHeader.Font = Enum.Font.SourceSansBold
        patchHeader.TextSize = 10
        patchHeader.TextXAlignment = Enum.TextXAlignment.Left
        
        local patchHeaderPadding = Instance.new("UIPadding", patchHeader)
        patchHeaderPadding.PaddingLeft = UDim.new(0, 4)
        
        patchXPos = patchXPos + patchHeaderWidths[i]
    end
    
    -- Patch scroll
    local patchScroll = Instance.new("ScrollingFrame", patchPanel)
    patchScroll.Size = UDim2.new(1, -8, 1, -84)
    patchScroll.Position = UDim2.fromOffset(4, 76)
    patchScroll.BackgroundColor3 = self.Config.BG_WHITE
    patchScroll.BorderSizePixel = 0
    patchScroll.ScrollBarThickness = 12
    patchScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    patchScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    self:_createBorder(patchScroll, true)
    
    local patchList = Instance.new("UIListLayout", patchScroll)
    patchList.Padding = UDim.new(0, 0)

    -- Store UI references
    self.State.UI = {
        ScreenGui = screenGui,
        Main = main,
        ModuleScroll = moduleScroll,
        ModuleSearch = moduleSearch,
        InspectorScroll = inspectorScroll,
        PathLabel = pathLabel,
        PatchScroll = patchScroll,
        PatchCount = patchCount,
        ResizeHandle = resizeHandle
    }

    -- Dragging functionality
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Resize functionality
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = main.Size
        end
    end)
    
    -- Visual feedback for resize handle
    resizeHandle.MouseEnter:Connect(function()
        resizeHandle.BackgroundColor3 = self.Config.BORDER_DARK
    end)
    
    resizeHandle.MouseLeave:Connect(function()
        resizeHandle.BackgroundColor3 = self.Config.BG_DARK
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = math.max(700, startSize.X.Offset + delta.X)
            local newHeight = math.max(400, startSize.Y.Offset + delta.Y)
            main.Size = UDim2.fromOffset(newWidth, newHeight)
            
            -- Update position to keep centered if needed
            main.Position = UDim2.new(
                main.Position.X.Scale,
                main.Position.X.Offset,
                main.Position.Y.Scale,
                main.Position.Y.Offset
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    
    -- Search functionality
    moduleSearch.FocusLost:Connect(function()
        self:FilterModules(moduleSearch.Text)
    end)

    -- Initial scan
    self:ScanModules()
end

function Modules.OverseerCE:ScanModules()
    if not self.State.UI then return end
    
    -- Clear module list
    for _, child in ipairs(self.State.UI.ModuleScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    self.State.ModuleList = {}
    
    task.spawn(function()
        local paths = {ReplicatedStorage, Players.LocalPlayer, Workspace}
        for _, parent in ipairs(paths) do
            if parent then
                for _, obj in ipairs(parent:GetDescendants()) do
                    if obj:IsA("ModuleScript") then
                        self:AddModuleToList(obj)
                    end
                end
                task.wait()
            end
        end
    end)
end

function Modules.OverseerCE:AddModuleToList(moduleScript)
    if not moduleScript or not moduleScript.Parent then return end
    if not self.State.UI then return end
    
    local moduleName = moduleScript.Name
    local modulePath = moduleScript:GetFullName()
    
    local row = Instance.new("TextButton", self.State.UI.ModuleScroll)
    row.Size = UDim2.new(1, -2, 0, self.Config.ROW_HEIGHT)
    row.BackgroundColor3 = self.Config.BG_WHITE
    row.Text = ""
    row.BorderSizePixel = 0
    row.AutoButtonColor = false
    
    local nameLabel = Instance.new("TextLabel", row)
    nameLabel.Size = UDim2.new(1, -8, 1, 0)
    nameLabel.Position = UDim2.fromOffset(4, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = moduleName
    nameLabel.TextColor3 = self.Config.TEXT_BLACK
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 10
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    row.MouseButton1Click:Connect(function()
        self:LoadModule(moduleScript)
        
        -- Highlight selected
        for _, child in ipairs(self.State.UI.ModuleScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = self.Config.BG_WHITE
                -- Reset text color for all rows
                for _, label in ipairs(child:GetChildren()) do
                    if label:IsA("TextLabel") then
                        label.TextColor3 = self.Config.TEXT_BLACK
                    end
                end
            end
        end
        row.BackgroundColor3 = self.Config.HIGHLIGHT
        nameLabel.TextColor3 = self.Config.BG_WHITE
    end)
    
    row.MouseEnter:Connect(function()
        if row.BackgroundColor3 ~= self.Config.HIGHLIGHT then
            row.BackgroundColor3 = self.Config.BG_LIGHT
        end
    end)
    
    row.MouseLeave:Connect(function()
        if row.BackgroundColor3 ~= self.Config.HIGHLIGHT then
            row.BackgroundColor3 = self.Config.BG_WHITE
        end
    end)
    
    table.insert(self.State.ModuleList, {
        Script = moduleScript,
        Row = row,
        Name = moduleName,
        Path = modulePath
    })
end

function Modules.OverseerCE:LoadModule(moduleScript)
    local success, result = pcall(function()
        return require(moduleScript)
    end)
    
    if not success then
        warn("[Overseer CE] Failed to load module:", result)
        return
    end
    
    if type(result) ~= "table" then
        warn("[Overseer CE] Module did not return a table")
        return
    end
    
    self.State.SelectedModule = moduleScript
    self.State.CurrentTable = result
    self.State.PathStack = {}
    self.State.VisitedTables = {}
    
    self:RefreshInspector()
end

function Modules.OverseerCE:RefreshInspector()
    if not self.State.UI or not self.State.CurrentTable then return end
    
    -- Clear inspector
    for _, child in ipairs(self.State.UI.InspectorScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    -- Update path label
    local pathText = "Root"
    if #self.State.PathStack > 0 then
        pathText = table.concat(self.State.PathStack, " > ")
    end
    self.State.UI.PathLabel.Text = pathText
    
    -- Populate entries
    self:PopulateTable(self.State.CurrentTable)
    
    -- Analyze metatable chain
    local chain = self:AnalyzeMetatableChain(self.State.CurrentTable)
    self.State.MetatableChain = chain
    
    -- Display metatable info
    if #chain > 0 then
        self:DisplayMetatableChain(chain)
    end
end

function Modules.OverseerCE:PopulateTable(tbl, isMetatable)
    if not tbl or type(tbl) ~= "table" then return end
    if self.State.VisitedTables[tbl] then return end
    
    self.State.VisitedTables[tbl] = true
    
    local entries = {}
    for key, value in pairs(tbl) do
        table.insert(entries, {Key = key, Value = value})
    end
    
    table.sort(entries, function(a, b)
        return tostring(a.Key) < tostring(b.Key)
    end)
    
    for _, entry in ipairs(entries) do
        self:CreateInspectorRow(entry.Key, entry.Value, tbl, isMetatable)
    end
end

function Modules.OverseerCE:CreateInspectorRow(key, value, parentTable, isMetatable)
    if not self.State.UI then return end
    
    local valueType = type(value)
    local displayValue = tostring(value)
    
    if valueType == "string" then
        displayValue = '"' .. value:sub(1, 50) .. '"'
    elseif valueType == "table" then
        displayValue = "table: " .. tostring(value):sub(8)
    elseif valueType == "function" then
        displayValue = "function"
    end
    
    local row = Instance.new("Frame", self.State.UI.InspectorScroll)
    row.Size = UDim2.new(1, -2, 0, self.Config.ROW_HEIGHT)
    row.BackgroundColor3 = isMetatable and self.Config.BG_LIGHT or self.Config.BG_WHITE
    row.BorderSizePixel = 0
    
    -- Check if patched
    local isPatched = false
    for _, patch in pairs(self.State.ActivePatches) do
        if patch.Table == parentTable and patch.Key == key then
            isPatched = true
            if patch.Frozen then
                row.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
            end
            break
        end
    end
    
    -- Active checkbox
    local activeBox = Instance.new("TextButton", row)
    activeBox.Size = UDim2.fromOffset(12, 12)
    activeBox.Position = UDim2.new(0.04, -6, 0.5, -6)
    activeBox.BackgroundColor3 = self.Config.BG_WHITE
    activeBox.Text = isPatched and "X" or ""
    activeBox.TextColor3 = self.Config.TEXT_BLACK
    activeBox.Font = Enum.Font.SourceSansBold
    activeBox.TextSize = 10
    activeBox.BorderSizePixel = 0
    
    self:_createBorder(activeBox, true)
    
    -- Key label
    local keyLabel = Instance.new("TextLabel", row)
    keyLabel.Size = UDim2.new(0.25, -4, 1, 0)
    keyLabel.Position = UDim2.new(0.08, 2, 0, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = tostring(key)
    keyLabel.TextColor3 = isMetatable and Color3.fromRGB(0, 0, 128) or self.Config.TEXT_BLACK
    keyLabel.Font = isMetatable and Enum.Font.Code or Enum.Font.SourceSans
    keyLabel.TextSize = 10
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
    keyLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Type label
    local typeLabel = Instance.new("TextLabel", row)
    typeLabel.Size = UDim2.new(0.12, -4, 1, 0)
    typeLabel.Position = UDim2.new(0.33, 2, 0, 0)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = valueType
    typeLabel.TextColor3 = self.Config.TEXT_GRAY
    typeLabel.Font = Enum.Font.SourceSans
    typeLabel.TextSize = 9
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Value label/edit box
    local valueBox = Instance.new("TextBox", row)
    valueBox.Size = UDim2.new(0.35, -4, 1, 0)
    valueBox.Position = UDim2.new(0.45, 2, 0, 0)
    valueBox.BackgroundTransparency = 1
    valueBox.Text = displayValue
    valueBox.TextColor3 = self.Config.TEXT_BLACK
    valueBox.Font = Enum.Font.Code
    valueBox.TextSize = 9
    valueBox.TextXAlignment = Enum.TextXAlignment.Left
    valueBox.TextTruncate = Enum.TextTruncate.AtEnd
    valueBox.TextEditable = valueType ~= "table" and valueType ~= "function"
    valueBox.ClearTextOnFocus = false
    
    -- Patch button
    local patchBtn = self:_createButton(row, "Patch", UDim2.fromOffset(45, 16), UDim2.new(0.80, 2, 0.5, -8), function()
        if valueType == "table" then
            self:DrillDown(key, value)
        elseif valueType == "function" then
            self:ShowFunctionInfo(key, value, parentTable)
        else
            -- Apply patch from value box
            local newVal = self:ParseValue(valueBox.Text, valueType)
            if newVal ~= nil then
                self:CreatePatch(parentTable, key, newVal, false)
            end
        end
    end)
    patchBtn.TextSize = 9
    
    -- Freeze button
    local freezeBtn = self:_createButton(row, "Freeze", UDim2.fromOffset(45, 16), UDim2.new(0.88, 2, 0.5, -8), function()
        local newVal = self:ParseValue(valueBox.Text, valueType)
        if newVal ~= nil then
            local patchId = self:CreatePatch(parentTable, key, newVal, true)
        end
    end)
    freezeBtn.TextSize = 9
    
    -- Change button text for tables/functions
    if valueType == "table" then
        patchBtn.Text = "Dive"
    elseif valueType == "function" then
        patchBtn.Text = "Hook"
    end
    
    -- Double-click to edit
    valueBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and valueType ~= "table" and valueType ~= "function" then
            local newVal = self:ParseValue(valueBox.Text, valueType)
            if newVal ~= nil then
                self:CreatePatch(parentTable, key, newVal, false)
            end
        end
    end)
end

function Modules.OverseerCE:DisplayMetatableChain(chain)
    if not self.State.UI or not chain or #chain == 0 then return end
    
    for i, entry in ipairs(chain) do
        -- Separator
        local separator = Instance.new("Frame", self.State.UI.InspectorScroll)
        separator.Size = UDim2.new(1, -2, 0, self.Config.ROW_HEIGHT)
        separator.BackgroundColor3 = self.Config.ACCENT_BLUE
        separator.BorderSizePixel = 0
        
        local sepLabel = Instance.new("TextLabel", separator)
        sepLabel.Size = UDim2.new(1, -8, 1, 0)
        sepLabel.Position = UDim2.fromOffset(4, 0)
        sepLabel.BackgroundTransparency = 1
        sepLabel.Text = "=== METATABLE #" .. i .. " (Depth: " .. entry.Depth .. ") ==="
        sepLabel.TextColor3 = self.Config.BG_WHITE
        sepLabel.Font = Enum.Font.SourceSansBold
        sepLabel.TextSize = 10
        sepLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Show metatable fields
        for _, field in ipairs(entry.Fields) do
            self:CreateInspectorRow(field.Key, field.Value, entry.Metatable, true)
        end
    end
end

function Modules.OverseerCE:RefreshPatchList()
    if not self.State.UI then return end
    
    -- Clear patch list
    for _, child in ipairs(self.State.UI.PatchScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    local patchCount = 0
    for patchId, patch in pairs(self.State.ActivePatches) do
        patchCount = patchCount + 1
        self:CreatePatchRow(patchId, patch)
    end
    
    self.State.UI.PatchCount.Text = "Patches: " .. patchCount
end

function Modules.OverseerCE:CreatePatchRow(patchId, patch)
    if not self.State.UI then return end
    
    local row = Instance.new("Frame", self.State.UI.PatchScroll)
    row.Size = UDim2.new(1, -2, 0, self.Config.ROW_HEIGHT)
    row.BackgroundColor3 = patch.Frozen and Color3.fromRGB(255, 220, 220) or self.Config.BG_WHITE
    row.BorderSizePixel = 0
    
    -- Freeze checkbox
    local freezeBox = Instance.new("TextButton", row)
    freezeBox.Size = UDim2.fromOffset(12, 12)
    freezeBox.Position = UDim2.new(0.075, -6, 0.5, -6)
    freezeBox.BackgroundColor3 = self.Config.BG_WHITE
    freezeBox.Text = patch.Frozen and "X" or ""
    freezeBox.TextColor3 = self.Config.FROZEN_RED
    freezeBox.Font = Enum.Font.SourceSansBold
    freezeBox.TextSize = 10
    freezeBox.BorderSizePixel = 0
    
    self:_createBorder(freezeBox, true)
    
    freezeBox.MouseButton1Click:Connect(function()
        self:ToggleFreeze(patchId)
    end)
    
    -- Key label
    local keyLabel = Instance.new("TextLabel", row)
    keyLabel.Size = UDim2.new(0.35, -4, 1, 0)
    keyLabel.Position = UDim2.new(0.15, 2, 0, 0)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Text = tostring(patch.Key)
    keyLabel.TextColor3 = self.Config.TEXT_BLACK
    keyLabel.Font = Enum.Font.SourceSans
    keyLabel.TextSize = 9
    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
    keyLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Value label
    local valueLabel = Instance.new("TextLabel", row)
    valueLabel.Size = UDim2.new(0.35, -4, 1, 0)
    valueLabel.Position = UDim2.new(0.50, 2, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(patch.NewValue):sub(1, 20)
    valueLabel.TextColor3 = self.Config.TEXT_BLACK
    valueLabel.Font = Enum.Font.Code
    valueLabel.TextSize = 9
    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
    valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    
    -- Delete button
    local delBtn = self:_createButton(row, "X", UDim2.fromOffset(16, 16), UDim2.new(0.88, 0, 0.5, -8), function()
        self:RemovePatch(patchId)
    end)
    delBtn.TextSize = 10
    delBtn.Font = Enum.Font.SourceSansBold
    delBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
end

function Modules.OverseerCE:DrillDown(name, tbl)
    if type(tbl) ~= "table" then return end
    
    table.insert(self.State.PathStack, name)
    self.State.CurrentTable = tbl
    self.State.VisitedTables = {}
    
    self:RefreshInspector()
end

function Modules.OverseerCE:GoBack()
    if #self.State.PathStack == 0 then return end
    
    table.remove(self.State.PathStack)
    
    -- Navigate back to parent
    local tbl = self.State.SelectedModule and require(self.State.SelectedModule) or nil
    if not tbl then return end
    
    for _, pathPart in ipairs(self.State.PathStack) do
        tbl = tbl[pathPart]
        if not tbl then return end
    end
    
    self.State.CurrentTable = tbl
    self.State.VisitedTables = {}
    
    self:RefreshInspector()
end

function Modules.OverseerCE:ParseValue(text, targetType)
    if targetType == "number" then
        return tonumber(text)
    elseif targetType == "boolean" then
        return text:lower() == "true"
    elseif targetType == "string" then
        -- Remove quotes if present
        return text:match('^"(.*)"$') or text
    end
    return text
end

function Modules.OverseerCE:ShowFunctionInfo(key, func, parentTable)
    -- Create hook editor window
    print("[Overseer CE] Function hook editor for:", key)
    -- TODO: Implement function hook editor
end

function Modules.OverseerCE:FilterModules(query)
    if not self.State.UI then return end
    
    query = query:lower()
    
    for _, moduleData in ipairs(self.State.ModuleList) do
        if query == "" or moduleData.Name:lower():find(query, 1, true) then
            moduleData.Row.Visible = true
        else
            moduleData.Row.Visible = false
        end
    end
end

function Modules.OverseerCE:OpenToolWindow(toolName)
    -- Create popup window
    local popup = Instance.new("Frame", self.State.UI.ScreenGui)
    popup.Name = toolName .. "Window"
    popup.Size = UDim2.fromOffset(500, 400)
    popup.Position = UDim2.new(0.5, -250, 0.5, -200)
    popup.BackgroundColor3 = self.Config.BG_PANEL
    popup.BorderSizePixel = 0
    popup.ZIndex = 100
    
    self:_createBorder(popup, false)
    
    -- Title bar
    local titleBar = Instance.new("Frame", popup)
    titleBar.Size = UDim2.new(1, -2, 0, 24)
    titleBar.Position = UDim2.fromOffset(1, 1)
    titleBar.BackgroundColor3 = self.Config.ACCENT_BLUE
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 101
    
    local titleGradient = Instance.new("UIGradient", titleBar)
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(49, 106, 197)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 190, 230))
    }
    titleGradient.Rotation = 90
    
    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.fromOffset(4, 0)
    title.Text = toolName
    title.TextColor3 = self.Config.BG_WHITE
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = 102
    
    local closeBtn = self:_createButton(titleBar, "×", UDim2.fromOffset(20, 20), UDim2.new(1, -22, 0, 2), function()
        popup:Destroy()
    end)
    closeBtn.ZIndex = 103
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.BackgroundColor3 = self.Config.BG_LIGHT
    
    -- Content area
    local contentArea = Instance.new("Frame", popup)
    contentArea.Size = UDim2.new(1, -8, 1, -32)
    contentArea.Position = UDim2.fromOffset(4, 28)
    contentArea.BackgroundColor3 = self.Config.BG_PANEL
    contentArea.BorderSizePixel = 0
    contentArea.ZIndex = 100
    
    -- Create tool-specific content
    if toolName == "Scanner" then
        self:CreateScannerUI(contentArea)
    elseif toolName == "Dumper" then
        self:CreateDumperUI(contentArea)
    elseif toolName == "Injector" then
        self:CreateInjectorUI(contentArea)
    elseif toolName == "Anti-Tamper" then
        self:CreateAntiTamperUI(contentArea)
    elseif toolName == "Tools" then
        self:CreateToolsMenuUI(contentArea)
    end
    
    -- Make draggable
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = popup.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            popup.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Modules.OverseerCE:CreateScannerUI(parent)
    -- Search input
    local searchLabel = Instance.new("TextLabel", parent)
    searchLabel.Size = UDim2.new(0, 100, 0, 22)
    searchLabel.Position = UDim2.fromOffset(4, 4)
    searchLabel.BackgroundTransparency = 1
    searchLabel.Text = "Search Value:"
    searchLabel.TextColor3 = self.Config.TEXT_BLACK
    searchLabel.Font = Enum.Font.SourceSans
    searchLabel.TextSize = 11
    searchLabel.TextXAlignment = Enum.TextXAlignment.Left
    searchLabel.ZIndex = 101
    
    local searchBox = Instance.new("TextBox", parent)
    searchBox.Size = UDim2.new(1, -110, 0, 22)
    searchBox.Position = UDim2.fromOffset(106, 4)
    searchBox.BackgroundColor3 = self.Config.BG_WHITE
    searchBox.Text = ""
    searchBox.PlaceholderText = "Enter value to search..."
    searchBox.TextColor3 = self.Config.TEXT_BLACK
    searchBox.Font = Enum.Font.SourceSans
    searchBox.TextSize = 11
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.BorderSizePixel = 0
    searchBox.ZIndex = 101
    
    local searchPadding = Instance.new("UIPadding", searchBox)
    searchPadding.PaddingLeft = UDim.new(0, 4)
    
    self:_createBorder(searchBox, true)
    
    -- Type selector
    local typeLabel = Instance.new("TextLabel", parent)
    typeLabel.Size = UDim2.new(0, 100, 0, 22)
    typeLabel.Position = UDim2.fromOffset(4, 30)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = "Value Type:"
    typeLabel.TextColor3 = self.Config.TEXT_BLACK
    typeLabel.Font = Enum.Font.SourceSans
    typeLabel.TextSize = 11
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
    typeLabel.ZIndex = 101
    
    local typeDropdown = Instance.new("TextButton", parent)
    typeDropdown.Size = UDim2.new(0, 150, 0, 22)
    typeDropdown.Position = UDim2.fromOffset(106, 30)
    typeDropdown.BackgroundColor3 = self.Config.BG_WHITE
    typeDropdown.Text = "any"
    typeDropdown.TextColor3 = self.Config.TEXT_BLACK
    typeDropdown.Font = Enum.Font.SourceSans
    typeDropdown.TextSize = 11
    typeDropdown.BorderSizePixel = 0
    typeDropdown.ZIndex = 101
    
    self:_createBorder(typeDropdown, true)
    
    local selectedType = "any"
    local types = {"any", "string", "number", "boolean", "table", "function"}
    local typeIndex = 1
    
    typeDropdown.MouseButton1Click:Connect(function()
        typeIndex = (typeIndex % #types) + 1
        selectedType = types[typeIndex]
        typeDropdown.Text = selectedType
    end)
    
    -- Exact match checkbox
    local exactMatch = false
    local exactCheckbox = Instance.new("TextButton", parent)
    exactCheckbox.Size = UDim2.fromOffset(16, 16)
    exactCheckbox.Position = UDim2.fromOffset(262, 33)
    exactCheckbox.BackgroundColor3 = self.Config.BG_WHITE
    exactCheckbox.Text = ""
    exactCheckbox.TextColor3 = self.Config.TEXT_BLACK
    exactCheckbox.Font = Enum.Font.SourceSansBold
    exactCheckbox.TextSize = 10
    exactCheckbox.BorderSizePixel = 0
    exactCheckbox.ZIndex = 101
    
    self:_createBorder(exactCheckbox, true)
    
    exactCheckbox.MouseButton1Click:Connect(function()
        exactMatch = not exactMatch
        exactCheckbox.Text = exactMatch and "X" or ""
    end)
    
    local exactLabel = Instance.new("TextLabel", parent)
    exactLabel.Size = UDim2.new(0, 100, 0, 16)
    exactLabel.Position = UDim2.fromOffset(282, 33)
    exactLabel.BackgroundTransparency = 1
    exactLabel.Text = "Exact Match"
    exactLabel.TextColor3 = self.Config.TEXT_BLACK
    exactLabel.Font = Enum.Font.SourceSans
    exactLabel.TextSize = 10
    exactLabel.TextXAlignment = Enum.TextXAlignment.Left
    exactLabel.ZIndex = 101
    
    -- Scan button
    local scanBtn = self:_createButton(parent, "Scan All Modules", UDim2.fromOffset(120, 24), UDim2.fromOffset(4, 58), function()
        local searchValue = searchBox.Text
        
        -- Parse value based on type
        if selectedType == "number" then
            searchValue = tonumber(searchValue) or 0
        elseif selectedType == "boolean" then
            searchValue = searchBox.Text:lower() == "true"
        end
        
        local results = self:ScanForConstant(searchValue, selectedType, exactMatch)
        
        -- Display results
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name == "ResultsScroll" then
                child:Destroy()
            end
        end
        
        local resultsScroll = Instance.new("ScrollingFrame", parent)
        resultsScroll.Name = "ResultsScroll"
        resultsScroll.Size = UDim2.new(1, -8, 1, -120)
        resultsScroll.Position = UDim2.fromOffset(4, 88)
        resultsScroll.BackgroundColor3 = self.Config.BG_WHITE
        resultsScroll.BorderSizePixel = 0
        resultsScroll.ScrollBarThickness = 12
        resultsScroll.ScrollBarImageColor3 = self.Config.BG_DARK
        resultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        resultsScroll.ZIndex = 101
        
        self:_createBorder(resultsScroll, true)
        
        local resultsList = Instance.new("UIListLayout", resultsScroll)
        resultsList.Padding = UDim.new(0, 1)
        
        -- Results header
        local header = Instance.new("TextLabel", parent)
        header.Size = UDim2.new(1, -8, 0, 20)
        header.Position = UDim2.fromOffset(4, 66)
        header.BackgroundColor3 = self.Config.BG_DARK
        header.Text = "Results: " .. #results
        header.TextColor3 = self.Config.TEXT_BLACK
        header.Font = Enum.Font.SourceSansBold
        header.TextSize = 11
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.BorderSizePixel = 0
        header.ZIndex = 101
        
        local headerPadding = Instance.new("UIPadding", header)
        headerPadding.PaddingLeft = UDim.new(0, 4)
        
        self:_createBorder(header, true)
        
        for _, result in ipairs(results) do
            local resultRow = Instance.new("TextButton", resultsScroll)
            resultRow.Size = UDim2.new(1, -2, 0, 20)
            resultRow.BackgroundColor3 = self.Config.BG_WHITE
            resultRow.Text = ""
            resultRow.BorderSizePixel = 0
            resultRow.AutoButtonColor = false
            resultRow.ZIndex = 102
            
            local pathLabel = Instance.new("TextLabel", resultRow)
            pathLabel.Size = UDim2.new(0.6, 0, 1, 0)
            pathLabel.Position = UDim2.fromOffset(4, 0)
            pathLabel.BackgroundTransparency = 1
            pathLabel.Text = result.Path
            pathLabel.TextColor3 = self.Config.TEXT_BLACK
            pathLabel.Font = Enum.Font.Code
            pathLabel.TextSize = 9
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
            pathLabel.ZIndex = 103
            
            local valueLabel = Instance.new("TextLabel", resultRow)
            valueLabel.Size = UDim2.new(0.4, -8, 1, 0)
            valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(result.Value):sub(1, 30)
            valueLabel.TextColor3 = self.Config.ACCENT_BLUE
            valueLabel.Font = Enum.Font.SourceSans
            valueLabel.TextSize = 9
            valueLabel.TextXAlignment = Enum.TextXAlignment.Left
            valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
            valueLabel.ZIndex = 103
            
            resultRow.MouseButton1Click:Connect(function()
                -- Jump to this value in inspector
                print("[Scanner] Selected:", result.Path)
            end)
            
            resultRow.MouseEnter:Connect(function()
                resultRow.BackgroundColor3 = self.Config.BG_LIGHT
            end)
            
            resultRow.MouseLeave:Connect(function()
                resultRow.BackgroundColor3 = self.Config.BG_WHITE
            end)
        end
    end)
    scanBtn.ZIndex = 101
end

function Modules.OverseerCE:CreateDumperUI(parent)
    local infoLabel = Instance.new("TextLabel", parent)
    infoLabel.Size = UDim2.new(1, -8, 0, 40)
    infoLabel.Position = UDim2.fromOffset(4, 4)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Export module structures to JSON for offline analysis.\nIncludes tables, metatables, functions, and upvalues."
    infoLabel.TextColor3 = self.Config.TEXT_BLACK
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.ZIndex = 101
    
    -- Options
    local includeMetatables = true
    local includeFunctions = true
    local maxDepth = 10
    
    local mtCheckbox = Instance.new("TextButton", parent)
    mtCheckbox.Size = UDim2.fromOffset(16, 16)
    mtCheckbox.Position = UDim2.fromOffset(4, 50)
    mtCheckbox.BackgroundColor3 = self.Config.BG_WHITE
    mtCheckbox.Text = "X"
    mtCheckbox.TextColor3 = self.Config.TEXT_BLACK
    mtCheckbox.Font = Enum.Font.SourceSansBold
    mtCheckbox.TextSize = 10
    mtCheckbox.BorderSizePixel = 0
    mtCheckbox.ZIndex = 101
    
    self:_createBorder(mtCheckbox, true)
    
    mtCheckbox.MouseButton1Click:Connect(function()
        includeMetatables = not includeMetatables
        mtCheckbox.Text = includeMetatables and "X" or ""
    end)
    
    local mtLabel = Instance.new("TextLabel", parent)
    mtLabel.Size = UDim2.new(0, 150, 0, 16)
    mtLabel.Position = UDim2.fromOffset(24, 50)
    mtLabel.BackgroundTransparency = 1
    mtLabel.Text = "Include Metatables"
    mtLabel.TextColor3 = self.Config.TEXT_BLACK
    mtLabel.Font = Enum.Font.SourceSans
    mtLabel.TextSize = 10
    mtLabel.TextXAlignment = Enum.TextXAlignment.Left
    mtLabel.ZIndex = 101
    
    local funcCheckbox = Instance.new("TextButton", parent)
    funcCheckbox.Size = UDim2.fromOffset(16, 16)
    funcCheckbox.Position = UDim2.fromOffset(4, 72)
    funcCheckbox.BackgroundColor3 = self.Config.BG_WHITE
    funcCheckbox.Text = "X"
    funcCheckbox.TextColor3 = self.Config.TEXT_BLACK
    funcCheckbox.Font = Enum.Font.SourceSansBold
    funcCheckbox.TextSize = 10
    funcCheckbox.BorderSizePixel = 0
    funcCheckbox.ZIndex = 101
    
    self:_createBorder(funcCheckbox, true)
    
    funcCheckbox.MouseButton1Click:Connect(function()
        includeFunctions = not includeFunctions
        funcCheckbox.Text = includeFunctions and "X" or ""
    end)
    
    local funcLabel = Instance.new("TextLabel", parent)
    funcLabel.Size = UDim2.new(0, 150, 0, 16)
    funcLabel.Position = UDim2.fromOffset(24, 72)
    funcLabel.BackgroundTransparency = 1
    funcLabel.Text = "Include Functions"
    funcLabel.TextColor3 = self.Config.TEXT_BLACK
    funcLabel.Font = Enum.Font.SourceSans
    funcLabel.TextSize = 10
    funcLabel.TextXAlignment = Enum.TextXAlignment.Left
    funcLabel.ZIndex = 101
    
    -- Depth input
    local depthLabel = Instance.new("TextLabel", parent)
    depthLabel.Size = UDim2.new(0, 100, 0, 22)
    depthLabel.Position = UDim2.fromOffset(4, 94)
    depthLabel.BackgroundTransparency = 1
    depthLabel.Text = "Max Depth:"
    depthLabel.TextColor3 = self.Config.TEXT_BLACK
    depthLabel.Font = Enum.Font.SourceSans
    depthLabel.TextSize = 10
    depthLabel.TextXAlignment = Enum.TextXAlignment.Left
    depthLabel.ZIndex = 101
    
    local depthBox = Instance.new("TextBox", parent)
    depthBox.Size = UDim2.fromOffset(60, 22)
    depthBox.Position = UDim2.fromOffset(106, 94)
    depthBox.BackgroundColor3 = self.Config.BG_WHITE
    depthBox.Text = "10"
    depthBox.TextColor3 = self.Config.TEXT_BLACK
    depthBox.Font = Enum.Font.SourceSans
    depthBox.TextSize = 10
    depthBox.BorderSizePixel = 0
    depthBox.ZIndex = 101
    
    self:_createBorder(depthBox, true)
    
    depthBox.FocusLost:Connect(function()
        maxDepth = tonumber(depthBox.Text) or 10
        depthBox.Text = tostring(maxDepth)
    end)
    
    -- Buttons
    local dumpSelectedBtn = self:_createButton(parent, "Dump Selected Module", UDim2.fromOffset(150, 24), UDim2.fromOffset(4, 122), function()
        if not self.State.SelectedModule then
            warn("[Dumper] No module selected")
            return
        end
        
        local result = self:DumpModule(self.State.SelectedModule, includeMetatables, includeFunctions, maxDepth)
        
        if result.Success then
            self:ExportDump(result.Dump)
            print("[Dumper] Exported to clipboard:", self.State.SelectedModule.Name)
        else
            warn("[Dumper] Failed:", result.Error)
        end
    end)
    dumpSelectedBtn.ZIndex = 101
    dumpSelectedBtn.TextSize = 10
    
    local dumpAllBtn = self:_createButton(parent, "Dump All Modules", UDim2.fromOffset(150, 24), UDim2.fromOffset(158, 122), function()
        local result = self:DumpAllModules()
        
        if result.Success then
            self:ExportDump(result)
            print("[Dumper] Exported " .. result.TotalModules .. " modules to clipboard")
        end
    end)
    dumpAllBtn.ZIndex = 101
    dumpAllBtn.TextSize = 10
    
    -- Status
    local statusLabel = Instance.new("TextLabel", parent)
    statusLabel.Size = UDim2.new(1, -8, 1, -152)
    statusLabel.Position = UDim2.fromOffset(4, 152)
    statusLabel.BackgroundColor3 = self.Config.BG_WHITE
    statusLabel.Text = "Ready to dump.\nResults will be copied to clipboard."
    statusLabel.TextColor3 = self.Config.TEXT_BLACK
    statusLabel.Font = Enum.Font.Code
    statusLabel.TextSize = 9
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextYAlignment = Enum.TextYAlignment.Top
    statusLabel.TextWrapped = true
    statusLabel.BorderSizePixel = 0
    statusLabel.ZIndex = 101
    
    self:_createBorder(statusLabel, true)
end

function Modules.OverseerCE:CreateInjectorUI(parent)
    local infoLabel = Instance.new("TextLabel", parent)
    infoLabel.Size = UDim2.new(1, -8, 0, 30)
    infoLabel.Position = UDim2.fromOffset(4, 4)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Execute code with access to module context and upvalues."
    infoLabel.TextColor3 = self.Config.TEXT_BLACK
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.ZIndex = 101
    
    -- Code editor
    local codeScroll = Instance.new("ScrollingFrame", parent)
    codeScroll.Size = UDim2.new(1, -8, 1, -80)
    codeScroll.Position = UDim2.fromOffset(4, 38)
    codeScroll.BackgroundColor3 = self.Config.BG_WHITE
    codeScroll.BorderSizePixel = 0
    codeScroll.ScrollBarThickness = 12
    codeScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    codeScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
    codeScroll.ZIndex = 101
    
    self:_createBorder(codeScroll, true)
    
    local codeBox = Instance.new("TextBox", codeScroll)
    codeBox.Size = UDim2.new(1, -4, 1, -4)
    codeBox.Position = UDim2.fromOffset(2, 2)
    codeBox.BackgroundTransparency = 1
    codeBox.Text = "-- Enter code here\nprint('Injected!')\nreturn true"
    codeBox.TextColor3 = self.Config.TEXT_BLACK
    codeBox.Font = Enum.Font.Code
    codeBox.TextSize = 10
    codeBox.TextXAlignment = Enum.TextXAlignment.Left
    codeBox.TextYAlignment = Enum.TextYAlignment.Top
    codeBox.MultiLine = true
    codeBox.ClearTextOnFocus = false
    codeBox.TextEditable = true
    codeBox.AutomaticSize = Enum.AutomaticSize.XY
    codeBox.ZIndex = 102
    
    -- Execute button
    local executeBtn = self:_createButton(parent, "Execute", UDim2.fromOffset(100, 24), UDim2.fromOffset(4, parent.AbsoluteSize.Y - 32), function()
        local code = codeBox.Text
        local targetModule = self.State.SelectedModule
        
        local result = self:InjectCode(code, targetModule, true)
        
        if result.Success then
            print("[Injector] Success! Result:", unpack(result.Result))
        else
            warn("[Injector] Error:", result.Error)
        end
    end)
    executeBtn.ZIndex = 101
    executeBtn.TextSize = 10
    
    local clearBtn = self:_createButton(parent, "Clear", UDim2.fromOffset(80, 24), UDim2.fromOffset(108, parent.AbsoluteSize.Y - 32), function()
        codeBox.Text = ""
    end)
    clearBtn.ZIndex = 101
    clearBtn.TextSize = 10
end

function Modules.OverseerCE:CreateAntiTamperUI(parent)
    local infoLabel = Instance.new("TextLabel", parent)
    infoLabel.Size = UDim2.new(1, -8, 0, 50)
    infoLabel.Position = UDim2.fromOffset(4, 4)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Anti-tamper protection hides your modifications from detection.\nHooks getmetatable, setmetatable, rawset, type, and typeof to spoof normal behavior."
    infoLabel.TextColor3 = self.Config.TEXT_BLACK
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.ZIndex = 101
    
    -- Status
    local statusLabel = Instance.new("TextLabel", parent)
    statusLabel.Size = UDim2.new(1, -8, 0, 30)
    statusLabel.Position = UDim2.fromOffset(4, 60)
    statusLabel.BackgroundColor3 = self.State.AntiTamperActive and Color3.fromRGB(220, 255, 220) or Color3.fromRGB(255, 220, 220)
    statusLabel.Text = self.State.AntiTamperActive and "Status: ACTIVE" or "Status: INACTIVE"
    statusLabel.TextColor3 = self.Config.TEXT_BLACK
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextSize = 12
    statusLabel.BorderSizePixel = 0
    statusLabel.ZIndex = 101
    
    self:_createBorder(statusLabel, true)
    
    -- Toggle button
    local toggleBtn = self:_createButton(parent, self.State.AntiTamperActive and "Disable Protection" or "Enable Protection", UDim2.fromOffset(150, 28), UDim2.fromOffset(4, 96), function()
        if self.State.AntiTamperActive then
            self:DisableAntiTamper()
            toggleBtn.Text = "Enable Protection"
            statusLabel.Text = "Status: INACTIVE"
            statusLabel.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
        else
            self:EnableAntiTamper()
            toggleBtn.Text = "Disable Protection"
            statusLabel.Text = "Status: ACTIVE"
            statusLabel.BackgroundColor3 = Color3.fromRGB(220, 255, 220)
        end
    end)
    toggleBtn.ZIndex = 101
    toggleBtn.TextSize = 11
    
    -- Detect anti-cheat button
    local detectBtn = self:_createButton(parent, "Scan for Anti-Cheat", UDim2.fromOffset(150, 28), UDim2.fromOffset(158, 96), function()
        local result = self:DetectAntiCheat()
        
        -- Clear previous results
        for _, child in ipairs(parent:GetChildren()) do
            if child.Name == "DetectionScroll" then
                child:Destroy()
            end
        end
        
        local detectionScroll = Instance.new("ScrollingFrame", parent)
        detectionScroll.Name = "DetectionScroll"
        detectionScroll.Size = UDim2.new(1, -8, 1, -134)
        detectionScroll.Position = UDim2.fromOffset(4, 130)
        detectionScroll.BackgroundColor3 = self.Config.BG_WHITE
        detectionScroll.BorderSizePixel = 0
        detectionScroll.ScrollBarThickness = 12
        detectionScroll.ScrollBarImageColor3 = self.Config.BG_DARK
        detectionScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        detectionScroll.ZIndex = 101
        
        self:_createBorder(detectionScroll, true)
        
        local detectionList = Instance.new("UIListLayout", detectionScroll)
        detectionList.Padding = UDim.new(0, 2)
        
        for _, detection in ipairs(result.Detections) do
            local detectionRow = Instance.new("Frame", detectionScroll)
            detectionRow.Size = UDim2.new(1, -4, 0, 24)
            detectionRow.BackgroundColor3 = detection.Detected and Color3.fromRGB(255, 200, 200) or Color3.fromRGB(200, 255, 200)
            detectionRow.BorderSizePixel = 0
            detectionRow.ZIndex = 102
            
            self:_createBorder(detectionRow, true)
            
            local nameLabel = Instance.new("TextLabel", detectionRow)
            nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
            nameLabel.Position = UDim2.fromOffset(4, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = detection.Name
            nameLabel.TextColor3 = self.Config.TEXT_BLACK
            nameLabel.Font = Enum.Font.SourceSans
            nameLabel.TextSize = 10
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.ZIndex = 103
            
            local statusText = Instance.new("TextLabel", detectionRow)
            statusText.Size = UDim2.new(0.3, -4, 1, 0)
            statusText.Position = UDim2.new(0.7, 0, 0, 0)
            statusText.BackgroundTransparency = 1
            statusText.Text = detection.Detected and "DETECTED" or "Not Found"
            statusText.TextColor3 = detection.Detected and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(0, 150, 0)
            statusText.Font = Enum.Font.SourceSansBold
            statusText.TextSize = 10
            statusText.TextXAlignment = Enum.TextXAlignment.Right
            statusText.ZIndex = 103
        end
    end)
    detectBtn.ZIndex = 101
    detectBtn.TextSize = 11
end

function Modules.OverseerCE:CreateToolsMenuUI(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, -8, 0, 30)
    title.Position = UDim2.fromOffset(4, 4)
    title.BackgroundTransparency = 1
    title.Text = "Advanced Tools Overview"
    title.TextColor3 = self.Config.TEXT_BLACK
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101
    
    local description = Instance.new("TextLabel", parent)
    description.Size = UDim2.new(1, -8, 1, -40)
    description.Position = UDim2.fromOffset(4, 38)
    description.BackgroundTransparency = 1
    description.Text = [[
Scanner: Search for specific values across all loaded modules
- Supports string, number, boolean, table, and function searches
- Exact match or fuzzy matching
- Deep recursive scanning through metatables

Dumper: Export module structures to JSON
- Complete memory dumps with metatables
- Function information and upvalue detection
- Configurable depth for large modules
- Results copied to clipboard

Injector: Execute code with module context
- Full access to module environments
- Upvalue modification support
- Injection history tracking
- Real-time code execution

Anti-Tamper: Hide modifications from detection
- Hooks getmetatable/setmetatable
- Spoofs type checking functions
- Protects frozen patches
- Anti-cheat pattern detection
    ]]
    description.TextColor3 = self.Config.TEXT_BLACK
    description.Font = Enum.Font.SourceSans
    description.TextSize = 10
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.TextWrapped = true
    description.ZIndex = 101
end

function Modules.OverseerCE:ExportPatches()
    local export = {}
    
    for patchId, patch in pairs(self.State.ActivePatches) do
        table.insert(export, {
            Key = tostring(patch.Key),
            Original = tostring(patch.Original),
            NewValue = tostring(patch.NewValue),
            Type = patch.Type,
            Frozen = patch.Frozen
        })
    end
    
    local exportText = game:GetService("HttpService"):JSONEncode(export)
    self:_setClipboard(exportText)
    print("[Overseer CE] Exported " .. #export .. " patches to clipboard")
end

function Modules.OverseerCE:Initialize()
    local module = self

    -- Freeze heartbeat
    RunService.Heartbeat:Connect(function()
        for patchId, patch in pairs(module.State.FreezeList) do
            pcall(function()
                if setreadonly then setreadonly(patch.Table, false) 
                elseif make_writeable then make_writeable(patch.Table) end
                
                rawset(patch.Table, patch.Key, patch.NewValue)
                
                if setreadonly then setreadonly(patch.Table, true) end
            end)
        end
    end)

    print("[Overseer CE] Initializing Cheat Engine Edition...")
    self:CreateUI()
    print("[Overseer CE] Ready! Module inspector and patcher active.")
end

-- Initialize automatically
Modules.OverseerCE:Initialize()

return Modules.OverseerCE
