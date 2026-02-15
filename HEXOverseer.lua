local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
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
        ScanResults = {},
        ScanInProgress = false,
        DumpedModules = {},
        InjectionHistory = {},
        AntiTamperActive = false,
        OriginalFunctions = {},
        HookedFunctions = {},
        Base64DecoderEnabled = true,
        ShowRawValues = false,
        ModuleTypeCache = {},
        DecompiledFunctions = {},
        FunctionPatches = {},
        UpvalueMonitors = {},
        CallTrackers = {},
        ReturnHooks = {},
        ConstantPatches = {},
        DecompilerCache = {},
	   ActivePoisons = {},
        PoisonTemplates = {},
        PoisonHistory = {},
        RequireHooks = {},
        CoroutineHijacks = {},
        MetatableTraps = {},
        CascadeTriggers = {},
        PoisonValidationResults = {},
        PoisonTypes = {
            "ReturnOverride", "TableHijack", "FunctionWrapper", 
            "ConstantPatch", "UpvalueInject", "MetatableTrap",
            "PrototypePoison", "RequireHook", "YieldSpoof",
            "CoroutineHijack", "ErrorInducer", "DataExfil",
            "AntiDetection", "SelfHeal", "CascadeTrigger"
        }
    },
    Config = {
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
        SUCCESS_GREEN = Color3.fromRGB(0, 180, 0),
        WARNING_ORANGE = Color3.fromRGB(255, 165, 0),
		POISON_PURPLE = Color3.fromRGB(138, 43, 226),
        HEADER_HEIGHT = 24,
        ROW_HEIGHT = 20,
        BUTTON_HEIGHT = 23,
        PADDING = 4,
        ANIM_SPEED = 0.15,
        HOVER_BRIGHTNESS = 1.1
    }
}
function Modules.OverseerCE:Initialize()
    if self.State.Base64DecoderEnabled then
        self:InitializeBase64Decoder()
    end
    if self.State.AntiTamperActive then
        self:SetupAntiTamper()
    end
    if self.State.AutoRefresh then
        self:SetupAutoRefresh()
    end
    print("[HEX Overseer] Initialized successfully")
    print("[HEX Overseer] Version 1.0 - Advanced Module Editor & Poison System")
end
function Modules.OverseerCE:InitializeBase64Decoder()
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    self.Base64Decode = function(data)
        local bits = ''
        local chars = {}
        for i = 1, #data do
            local c = data:sub(i, i)
            local index = b64chars:find(c, 1, true)
            if index then
                bits = bits .. string.format('%06d', tonumber(string.format('%b', index - 1):sub(3)))
            end
        end
        for i = 1, #bits, 8 do
            local byte = bits:sub(i, i + 7)
            if #byte == 8 then
                table.insert(chars, string.char(tonumber(byte, 2)))
            end
        end
        return table.concat(chars)
    end
    self.Base64Encode = function(data)
        local bytes = {}
        for i = 1, #data do
            table.insert(bytes, string.format('%08d', tonumber(string.format('%b', data:byte(i)):sub(3))))
        end
        local bits = table.concat(bytes)
        local result = {}
        for i = 1, #bits, 6 do
            local six = bits:sub(i, i + 5)
            if #six == 6 then
                table.insert(result, b64chars:sub(tonumber(six, 2) + 1, tonumber(six, 2) + 1))
            end
        end
        while #result % 4 ~= 0 do
            table.insert(result, '=')
        end
        return table.concat(result)
    end
end
function Modules.OverseerCE:SetupAntiTamper()
    local protectedFunctions = {
        "RemovePoison",
        "ClearAllPoisons",
        "Initialize",
        "SetupAntiTamper"
    }
    for _, funcName in ipairs(protectedFunctions) do
        local func = self[funcName]
        if type(func) == "function" then
            self.State.OriginalFunctions[funcName] = func
        end
    end
    self.AntiTamperConnection = RunService.Heartbeat:Connect(function()
        for funcName, originalFunc in pairs(self.State.OriginalFunctions) do
            if self[funcName] ~= originalFunc then
                warn("[HEX Overseer] TAMPERING DETECTED: Function " .. funcName .. " was modified!")
                self[funcName] = originalFunc
            end
        end
    end)
    self.State.AntiTamperActive = true
end
function Modules.OverseerCE:DisableAntiTamper()
    if self.AntiTamperConnection then
        self.AntiTamperConnection:Disconnect()
        self.AntiTamperConnection = nil
    end
    self.State.AntiTamperActive = false
end
function Modules.OverseerCE:SetupAutoRefresh()
    if self.AutoRefreshConnection then
        self.AutoRefreshConnection:Disconnect()
    end
    self.AutoRefreshConnection = RunService.Heartbeat:Connect(function()
        if self.State.AutoRefresh and self.State.UI then
            if self.State.CurrentTable then
                task.spawn(function()
                    self:RefreshInspector()
                end)
            end
        end
    end)
end
function Modules.OverseerCE:ToggleAutoRefresh()
    self.State.AutoRefresh = not self.State.AutoRefresh
    if self.State.AutoRefresh then
        self:SetupAutoRefresh()
    elseif self.AutoRefreshConnection then
        self.AutoRefreshConnection:Disconnect()
        self.AutoRefreshConnection = nil
    end
    return self.State.AutoRefresh
end
function Modules.OverseerCE:FreezeValue(tbl, key, frozenValue)
    if type(tbl) ~= "table" then
        return false, "Target is not a table"
    end
    local freezeId = tostring(tbl) .. "_" .. tostring(key)
    if self.State.FreezeList[freezeId] then
        return false, "Value already frozen"
    end
    self.State.FreezeList[freezeId] = {
        Table = tbl,
        Key = key,
        FrozenValue = frozenValue,
        OriginalValue = tbl[key],
        Connection = nil
    }
    if setreadonly then pcall(setreadonly, tbl, false) end
    tbl[key] = frozenValue
    if setreadonly then pcall(setreadonly, tbl, true) end
    self.State.FreezeList[freezeId].Connection = RunService.Heartbeat:Connect(function()
        if tbl[key] ~= frozenValue then
            if setreadonly then pcall(setreadonly, tbl, false) end
            tbl[key] = frozenValue
            if setreadonly then pcall(setreadonly, tbl, true) end
        end
    end)
    return true, freezeId
end
function Modules.OverseerCE:UnfreezeValue(freezeId)
    local freeze = self.State.FreezeList[freezeId]
    if not freeze then
        return false, "Freeze not found"
    end
    if freeze.Connection then
        freeze.Connection:Disconnect()
    end
    if setreadonly then pcall(setreadonly, freeze.Table, false) end
    freeze.Table[freeze.Key] = freeze.OriginalValue
    if setreadonly then pcall(setreadonly, freeze.Table, true) end
    self.State.FreezeList[freezeId] = nil
    return true
end
function Modules.OverseerCE:UnfreezeAll()
    local count = 0
    for freezeId in pairs(self.State.FreezeList) do
        if self:UnfreezeValue(freezeId) then
            count = count + 1
        end
    end
    return count
end
function Modules.OverseerCE:ScanForModules(pattern, scanDepth)
    scanDepth = scanDepth or 3
    self.State.ScanInProgress = true
    self.State.ScanResults = {}
    local function scanTable(tbl, path, depth)
        if depth > scanDepth then return end
        if type(tbl) ~= "table" then return end
        for key, value in pairs(tbl) do
            local newPath = path .. "." .. tostring(key)
            if pattern then
                if string.find(tostring(key):lower(), pattern:lower()) or 
                   string.find(newPath:lower(), pattern:lower()) then
                    table.insert(self.State.ScanResults, {
                        Path = newPath,
                        Value = value,
                        Type = type(value),
                        Key = key
                    })
                end
            else
                table.insert(self.State.ScanResults, {
                    Path = newPath,
                    Value = value,
                    Type = type(value),
                    Key = key
                })
            end
            if type(value) == "table" and depth < scanDepth then
                scanTable(value, newPath, depth + 1)
            end
        end
    end
    local scanLocations = {
        {name = "ReplicatedStorage", obj = ReplicatedStorage},
        {name = "Workspace", obj = Workspace},
        {name = "Players.LocalPlayer", obj = Players.LocalPlayer},
        {name = "_G", obj = _G}
    }
    for _, location in ipairs(scanLocations) do
        scanTable(location.obj, location.name, 0)
    end
    self.State.ScanInProgress = false
    return self.State.ScanResults
end
function Modules.OverseerCE:GetScanResults()
    return self.State.ScanResults
end
function Modules.OverseerCE:TraceMetatableChain(tbl)
    self.State.MetatableChain = {}
    local current = tbl
    local depth = 0
    local maxDepth = 20
    while depth < maxDepth do
        local mt, method = self:GetRawMetatable(current)
        if not mt then break end
        table.insert(self.State.MetatableChain, {
            Depth = depth,
            Metatable = mt,
            Method = method,
            HasIndex = mt.__index ~= nil,
            HasNewIndex = mt.__newindex ~= nil,
            IsLocked = pcall(getmetatable, current) == false
        })
        if type(mt.__index) == "table" then
            current = mt.__index
            depth = depth + 1
        else
            break
        end
    end
    return self.State.MetatableChain
end
function Modules.OverseerCE:PoisonYieldSpoof(func, fakeYieldTime)
    if type(func) ~= "function" then
        return false, "Target must be a function"
    end
    if not hookfunction then
        return false, "hookfunction not available"
    end
    fakeYieldTime = fakeYieldTime or 0.1
    local success, originalFunc = pcall(function()
        return hookfunction(func, function(...)
            local startTime = tick()
            local results = {pcall(func, ...)}
            local elapsed = tick() - startTime
            if elapsed < fakeYieldTime then
                task.wait(fakeYieldTime - elapsed)
            end
            if results[1] then
                return select(2, unpack(results))
            else
                error(results[2], 2)
            end
        end)
    end)
    if not success then
        return false, "Failed to hook function"
    end
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "YieldSpoof",
        TargetFunction = func,
        OriginalFunction = originalFunc,
        FakeYieldTime = fakeYieldTime,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    return true, poisonData.Id
end
function Modules.OverseerCE:PoisonCoroutineHijack(callback)
    if not hookfunction then
        return false, "hookfunction not available"
    end
    local originalCreate = coroutine.create
    local originalWrap = coroutine.wrap
    local originalResume = coroutine.resume
    local hijackedCreate = function(func)
        if callback then
            callback("create", func)
        end
        return originalCreate(func)
    end
    local hijackedWrap = function(func)
        if callback then
            callback("wrap", func)
        end
        return originalWrap(func)
    end
    local hijackedResume = function(co, ...)
        if callback then
            callback("resume", co, ...)
        end
        return originalResume(co, ...)
    end
    coroutine.create = hijackedCreate
    coroutine.wrap = hijackedWrap
    coroutine.resume = hijackedResume
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "CoroutineHijack",
        OriginalCreate = originalCreate,
        OriginalWrap = originalWrap,
        OriginalResume = originalResume,
        Callback = callback,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    table.insert(self.State.CoroutineHijacks, poisonData)
    return true, poisonData.Id
end
function Modules.OverseerCE:PoisonErrorInducer(func, condition, errorMsg)
    if type(func) ~= "function" then
        return false, "Target must be a function"
    end
    if not hookfunction then
        return false, "hookfunction not available"
    end
    errorMsg = errorMsg or "Induced error"
    local success, originalFunc = pcall(function()
        return hookfunction(func, function(...)
            local shouldError = false
            if type(condition) == "function" then
                shouldError = condition(...)
            elseif condition == true then
                shouldError = true
            end
            if shouldError then
                error(errorMsg, 2)
            end
            return func(...)
        end)
    end)
    if not success then
        return false, "Failed to hook function"
    end
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "ErrorInducer",
        TargetFunction = func,
        OriginalFunction = originalFunc,
        Condition = condition,
        ErrorMessage = errorMsg,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    return true, poisonData.Id
end
function Modules.OverseerCE:PoisonDataExfil(func, storageTable)
    if type(func) ~= "function" then
        return false, "Target must be a function"
    end
    if not hookfunction then
        return false, "hookfunction not available"
    end
    storageTable = storageTable or {}
    local success, originalFunc = pcall(function()
        return hookfunction(func, function(...)
            local callData = {
                Timestamp = tick(),
                Arguments = {...},
                Stacktrace = debug.traceback()
            }
            table.insert(storageTable, callData)
            local results = {func(...)}
            callData.Returns = results
            return unpack(results)
        end)
    end)
    if not success then
        return false, "Failed to hook function"
    end
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "DataExfil",
        TargetFunction = func,
        OriginalFunction = originalFunc,
        StorageTable = storageTable,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    return true, poisonData.Id, storageTable
end
function Modules.OverseerCE:PoisonAntiDetection(func, legitimateSignature)
    if type(func) ~= "function" then
        return false, "Target must be a function"
    end
    local signature = legitimateSignature or {
        source = "=[C]",
        what = "C",
        name = "legitimate_function"
    }
    if debug and debug.getinfo then
        local originalGetInfo = debug.getinfo
        debug.getinfo = function(target, ...)
            if target == func then
                return signature
            end
            return originalGetInfo(target, ...)
        end
    end
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "AntiDetection",
        TargetFunction = func,
        FakeSignature = signature,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    return true, poisonData.Id
end
function Modules.OverseerCE:PoisonSelfHeal(poisonId, checkInterval)
    local poison = self.State.ActivePoisons[poisonId]
    if not poison then
        return false, "Poison not found"
    end
    checkInterval = checkInterval or 1
    local selfHealFunc
    selfHealFunc = function()
        if not poison.Active then return end
        local isValid = false
        if poison.Type == "TableHijack" then
            local testKey = next(poison.Overrides)
            if testKey then
                isValid = poison.Target[testKey] == poison.Overrides[testKey]
            end
        elseif poison.Type == "UpvalueInject" then
            local success, currentValue = pcall(getupvalue, poison.TargetFunction, poison.UpvalueIndex)
            isValid = success and currentValue == poison.NewValue
        end
        if not isValid then
            warn("[HEX Overseer] Self-heal: Restoring poison #" .. poisonId)
            if poison.Type == "TableHijack" then
                for key, value in pairs(poison.Overrides) do
                    poison.Target[key] = value
                end
            elseif poison.Type == "UpvalueInject" then
                pcall(setupvalue, poison.TargetFunction, poison.UpvalueIndex, poison.NewValue)
            end
        end
        task.wait(checkInterval)
        selfHealFunc()
    end
    poison.SelfHealConnection = task.spawn(selfHealFunc)
    return true
end
function Modules.OverseerCE:PoisonCascadeTrigger(triggerFunc, poisonSequence, delay)
    if type(triggerFunc) ~= "function" then
        return false, "Trigger must be a function"
    end
    if not hookfunction then
        return false, "hookfunction not available"
    end
    delay = delay or 0.1
    local success, originalFunc = pcall(function()
        return hookfunction(triggerFunc, function(...)
            local results = {triggerFunc(...)}
            task.spawn(function()
                for i, poisonId in ipairs(poisonSequence) do
                    task.wait(delay)
                    local poison = self.State.ActivePoisons[poisonId]
                    if poison and not poison.Active then
                        poison.Active = true
                        warn("[HEX Overseer] Cascade: Activated poison #" .. poisonId)
                    end
                end
            end)
            return unpack(results)
        end)
    end)
    if not success then
        return false, "Failed to hook trigger function"
    end
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "CascadeTrigger",
        TriggerFunction = triggerFunc,
        OriginalFunction = originalFunc,
        PoisonSequence = poisonSequence,
        Delay = delay,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    table.insert(self.State.CascadeTriggers, poisonData)
    return true, poisonData.Id
end
function Modules.OverseerCE:GetRawMetatable(tbl)
    local mt = nil
    local success, result = pcall(getmetatable, tbl)
    if success and result then
        return result, "standard"
    end
    if getrawmetatable then
        success, result = pcall(getrawmetatable, tbl)
        if success and result then
            return result, "getrawmetatable"
        end
    end
    if debug and debug.getmetatable then
        success, result = pcall(debug.getmetatable, tbl)
        if success and result then
            return result, "debug.getmetatable"
        end
    end
    if hookmetamethod then
        local old
        success, result = pcall(function()
            old = hookmetamethod(game, "__index", function() end)
            hookmetamethod(game, "__index", old)
            return getmetatable(tbl)
        end)
        if success and result then
            return result, "hookmetamethod"
        end
    end
    return nil, "failed"
end
function Modules.OverseerCE:UnlockMetatable(tbl)
    if type(tbl) ~= "table" then
        return false, "Not a table"
    end
    local mt, method = self:GetRawMetatable(tbl)
    if not mt then
        return false, "No metatable found"
    end
    local isLocked = false
    local lockCheckSuccess, lockCheckResult = pcall(function()
        return getmetatable(tbl)
    end)
    if not lockCheckSuccess or lockCheckResult == nil then
        isLocked = true
    end
    local unlocked = false
    local unlockMethod = nil
    if setrawmetatable and isLocked then
        local success = pcall(function()
            setrawmetatable(tbl, mt)
        end)
        if success then
            unlocked = true
            unlockMethod = "setrawmetatable"
        end
    end
    if not unlocked and mt then
        local success = pcall(function()
            if setreadonly then setreadonly(mt, false) end
            rawset(mt, "__metatable", nil)
            if setreadonly then setreadonly(mt, true) end
        end)
        if success then
            unlocked = true
            unlockMethod = "removed __metatable"
        end
    end
    if not unlocked and mt then
        local newMt = {}
        for k, v in pairs(mt) do
            newMt[k] = v
        end
        newMt.__metatable = nil
        local success = pcall(function()
            if setreadonly then setreadonly(tbl, false) end
            if setmetatable then
                setmetatable(tbl, newMt)
            end
            if setreadonly then setreadonly(tbl, true) end
        end)
        if success then
            unlocked = true
            unlockMethod = "replaced metatable"
        end
    end
    if unlocked then
        return true, "Unlocked using: " .. (unlockMethod or "unknown")
    else
        return true, "Readonly access via: " .. method
    end
end
function Modules.OverseerCE:DecompileFunction(func)
    if type(func) ~= "function" then
        return nil, "Not a function"
    end
    local funcStr = tostring(func)
    if self.State.DecompilerCache[funcStr] then
        return self.State.DecompilerCache[funcStr]
    end
    local decompiled = {
        Address = funcStr,
        Info = {},
        Constants = {},
        Upvalues = {},
        Protos = {},
        SourceCode = nil,
        AccessMethod = "basic"
    }
    if debug and debug.getinfo then
        local success, info = pcall(debug.getinfo, func)
        if success then
            decompiled.Info = {
                Source = info.source or "?",
                ShortSource = info.short_src or "?",
                LineDefined = info.linedefined or -1,
                LastLineDefined = info.lastlinedefined or -1,
                NumParams = info.nparams or 0,
                IsVararg = info.isvararg or false,
                What = info.what or "?",
                Name = info.name or "<anonymous>"
            }
            decompiled.AccessMethod = "debug.getinfo"
        end
    elseif getinfo then
        local success, info = pcall(getinfo, func)
        if success then
            decompiled.Info = info
            decompiled.AccessMethod = "getinfo"
        end
    end
    if getconstants then
        local success, constants = pcall(getconstants, func)
        if success and constants then
            decompiled.Constants = constants
        end
    elseif debug and debug.getconstants then
        local success, constants = pcall(debug.getconstants, func)
        if success and constants then
            decompiled.Constants = constants
        end
    end
    if getupvalues then
        local success, upvalues = pcall(getupvalues, func)
        if success and upvalues then
            decompiled.Upvalues = upvalues
        end
    elseif debug and debug.getupvalues then
        local success, upvalues = pcall(debug.getupvalues, func)
        if success and upvalues then
            decompiled.Upvalues = upvalues
        end
    end
    if getprotos then
        local success, protos = pcall(getprotos, func)
        if success and protos then
            decompiled.Protos = protos
        end
    end
    if decompile then
        local success, source = pcall(decompile, func)
        if success and source then
            decompiled.SourceCode = source
        end
    end
    self.State.DecompilerCache[funcStr] = decompiled
    return decompiled
end
function Modules.OverseerCE:PatchFunctionReturn(func, returnValue)
    if type(func) ~= "function" then
        return false, "Not a function"
    end
    local patchId = tostring(func) .. "_return"
    if not hookfunction then
        return false, "hookfunction not available"
    end
    local success, originalFunc = pcall(function()
        return hookfunction(func, function(...)
            return returnValue
        end)
    end)
    if success then
        self.State.ReturnHooks[patchId] = {
            Original = originalFunc,
            ReturnValue = returnValue,
            Function = func,
            Timestamp = os.time()
        }
        return true, "Return value hooked"
    else
        return false, "Hook failed: " .. tostring(originalFunc)
    end
end
function Modules.OverseerCE:PatchFunctionUpvalue(func, upvalueName, newValue)
    if type(func) ~= "function" then
        return false, "Not a function"
    end
    if not setupvalue then
        return false, "setupvalue not available"
    end
    local upvalues = {}
    if getupvalues then
        local success, uvs = pcall(getupvalues, func)
        if success then upvalues = uvs end
    end
    local uvIndex = nil
    for i, name in pairs(upvalues) do
        if name == upvalueName or i == tonumber(upvalueName) then
            uvIndex = i
            break
        end
    end
    if not uvIndex then
        return false, "Upvalue not found: " .. upvalueName
    end
    local success, result = pcall(setupvalue, func, uvIndex, newValue)
    if success then
        local patchId = tostring(func) .. "_uv_" .. upvalueName
        self.State.UpvalueMonitors[patchId] = {
            Function = func,
            UpvalueName = upvalueName,
            UpvalueIndex = uvIndex,
            NewValue = newValue,
            Timestamp = os.time()
        }
        return true, "Upvalue patched"
    else
        return false, "Failed to set upvalue"
    end
end
function Modules.OverseerCE:PatchFunctionConstant(func, constantIndex, newValue)
    if type(func) ~= "function" then
        return false, "Not a function"
    end
    if not setconstant then
        return false, "setconstant not available"
    end
    local success, result = pcall(setconstant, func, constantIndex, newValue)
    if success then
        local patchId = tostring(func) .. "_const_" .. constantIndex
        self.State.ConstantPatches[patchId] = {
            Function = func,
            ConstantIndex = constantIndex,
            NewValue = newValue,
            Timestamp = os.time()
        }
        return true, "Constant patched"
    else
        return false, "Failed to set constant: " .. tostring(result)
    end
end
function Modules.OverseerCE:HookFunctionCalls(func, callback)
    if type(func) ~= "function" then
        return false, "Not a function"
    end
    if not hookfunction then
        return false, "hookfunction not available"
    end
    local callCount = 0
    local patchId = tostring(func) .. "_tracker"
    local success, originalFunc = pcall(function()
        return hookfunction(func, function(...)
            callCount = callCount + 1
            if self.State.CallTrackers[patchId] then
                table.insert(self.State.CallTrackers[patchId].Calls, {
                    Timestamp = tick(),
                    Args = {...}
                })
            end
            if callback then
                callback(callCount, ...)
            end
            return originalFunc(...)
        end)
    end)
    if success then
        self.State.CallTrackers[patchId] = {
            Original = originalFunc,
            Function = func,
            CallCount = callCount,
            Calls = {},
            Callback = callback,
            Timestamp = os.time()
        }
        return true, "Call tracker installed"
    else
        return false, "Hook failed"
    end
end
function Modules.OverseerCE:ReplaceClosure(oldFunc, newFunc)
    if type(oldFunc) ~= "function" or type(newFunc) ~= "function" then
        return false, "Both arguments must be functions"
    end
    if replaceclosure then
        local success = pcall(replaceclosure, oldFunc, newFunc)
        if success then
            return true, "Closure replaced using replaceclosure"
        end
    end
    if hookfunction then
        local success = pcall(hookfunction, oldFunc, newFunc)
        if success then
            return true, "Closure replaced using hookfunction"
        end
    end
    return false, "No closure replacement method available"
end
function Modules.OverseerCE:GetFunctionCallstack(func)
    if type(func) ~= "function" then
        return nil, "Not a function"
    end
    local callstack = {}
    if debug and debug.traceback then
        local trace = debug.traceback()
        for line in trace:gmatch("[^\r\n]+") do
            table.insert(callstack, line)
        end
    end
    return callstack
end
function Modules.OverseerCE:PopulateFunctionList(panel)
    if not self.State.CurrentTable then 
        self:_showNotification("No module loaded to scan", "warning")
        return 
    end
    local listArea = panel:FindFirstChild("FunctionListScroll", true)
    if not listArea then 
        warn("[Decompiler] Could not find FunctionListScroll")
        self:_showNotification("Error: Function list area not found", "error")
        return 
    end
    for _, child in ipairs(listArea:GetChildren()) do
        if not child:IsA("UIListLayout") then 
            child:Destroy() 
        end
    end
    local foundFunctions = {}
    local successCount = 0
    local errorCount = 0
    for k, v in pairs(self.State.CurrentTable) do
        if type(v) == "function" then
            table.insert(foundFunctions, {Name = tostring(k), Func = v, Source = "Module"})
            successCount = successCount + 1
        end
    end
    local mt = self:GetRawMetatable(self.State.CurrentTable)
    if mt and mt.__index then
        local target = mt.__index
        if type(target) == "table" then
            for k, v in pairs(target) do
                if type(v) == "function" then
                    table.insert(foundFunctions, {Name = "[MT] "..tostring(k), Func = v, Source = "Metatable"})
                    successCount = successCount + 1
                end
            end
        end
    end
    if #foundFunctions == 0 then
        self:_showNotification("No functions found in this module", "warning")
        local noFuncLabel = Instance.new("TextLabel", listArea)
        noFuncLabel.Size = UDim2.new(1, -4, 0, 40)
        noFuncLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 220)
        noFuncLabel.Text = "No functions found.\n\nThis module may only\ncontain data or tables."
        noFuncLabel.TextColor3 = self.Config.TEXT_BLACK
        noFuncLabel.Font = Enum.Font.SourceSans
        noFuncLabel.TextSize = 9
        noFuncLabel.TextWrapped = true
        noFuncLabel.BorderSizePixel = 0
        self:_createBorder(noFuncLabel, true)
        return
    end
    for _, data in ipairs(foundFunctions) do
        local btn = self:_createButton(listArea, data.Name, UDim2.new(1, -4, 0, 20), UDim2.new(0,0,0,0), function()
            self:_showNotification("Analyzing: " .. data.Name, "info")
            print("[Decompiler] Decompiling function:", data.Name)
            local decomp = self:DecompileFunction(data.Func)
            if decomp then
                self.State.CurrentDecompiledFunction = decomp
                self.State.CurrentDecompiledFunctionRef = data.Func
                self.State.CurrentDecompiledName = data.Name
                self:SwitchDecompilerTab("Info", panel)
                self:_showNotification("Function decompiled: " .. data.Name, "success")
            else
                self:_showNotification("Failed to decompile function", "error")
            end
        end)
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextSize = 9
        btn.TextWrapped = false
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.ZIndex = 103
        local btnPadding = Instance.new("UIPadding", btn)
        btnPadding.PaddingLeft = UDim.new(0, 4)
        if data.Source == "Metatable" then
            btn.TextColor3 = Color3.fromRGB(0, 120, 215)
        end
    end
    self:_showNotification(string.format("Found %d functions", #foundFunctions), "success")
    print(string.format("[Decompiler] Found %d functions in module", #foundFunctions))
end
function Modules.OverseerCE:CreateDecompilerPanel(parent)
    local panel = self:_createPanel(parent, UDim2.fromOffset(4, 4), UDim2.new(1, -8, 1, -8), "Function Decompiler & Browser")
    panel.ZIndex = 100
    panel.ClipsDescendants = true
    local browserFrame = Instance.new("Frame", panel)
    browserFrame.Size = UDim2.new(0.25, -6, 1, -35)
    browserFrame.Position = UDim2.fromOffset(4, 28)
    browserFrame.BackgroundColor3 = self.Config.BG_DARK
    browserFrame.BorderSizePixel = 0
    browserFrame.ZIndex = 101
    self:_createBorder(browserFrame, true)
    local browserLabel = Instance.new("TextLabel", browserFrame)
    browserLabel.Size = UDim2.new(1, 0, 0, 18)
    browserLabel.Position = UDim2.fromOffset(0, 0)
    browserLabel.Text = "Functions in Module"
    browserLabel.Font = Enum.Font.SourceSansBold
    browserLabel.TextSize = 10
    browserLabel.BackgroundColor3 = self.Config.BG_PANEL
    browserLabel.TextColor3 = self.Config.TEXT_BLACK
    browserLabel.BorderSizePixel = 0
    browserLabel.ZIndex = 102
    local listScroll = Instance.new("ScrollingFrame", browserFrame)
    listScroll.Name = "FunctionListScroll"
    listScroll.Size = UDim2.new(1, -4, 1, -45)
    listScroll.Position = UDim2.fromOffset(2, 20)
    listScroll.BackgroundColor3 = self.Config.BG_WHITE
    listScroll.BorderSizePixel = 0
    listScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    listScroll.ScrollBarThickness = 4
    listScroll.ZIndex = 102
    self:_createBorder(listScroll, true)
    local listLayout = Instance.new("UIListLayout", listScroll)
    listLayout.Padding = UDim.new(0, 1)
    local scanBtn = self:_createButton(browserFrame, "Scan Module", UDim2.new(1, -4, 0, 20), UDim2.new(0, 2, 1, -22), function()
        if not self.State.CurrentTable then
            self:_showNotification("No module loaded. Select a module from the left panel first.", "warning")
            return
        end
        self:PopulateFunctionList(panel)
        self:_showNotification("Scanning for functions...", "info")
    end)
    scanBtn.ZIndex = 102
    scanBtn.TextSize = 9
    local contentContainer = Instance.new("Frame", panel)
    contentContainer.Size = UDim2.new(0.75, -6, 1, -35)
    contentContainer.Position = UDim2.new(0.25, 2, 0, 28)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ZIndex = 100
    local tabContainer = Instance.new("Frame", contentContainer)
    tabContainer.Size = UDim2.new(1, 0, 0, 26)
    tabContainer.Position = UDim2.fromOffset(0, 0)
    tabContainer.BackgroundColor3 = self.Config.BG_DARK
    tabContainer.BorderSizePixel = 0
    tabContainer.ZIndex = 101
    self:_createBorder(tabContainer, true)
    local tabs = {"Info", "Constants", "Upvalues", "Protos", "Source"}
    local tabButtons = {}
    local tabWidth = (tabContainer.AbsoluteSize.X - 12) / #tabs
    for i, tabName in ipairs(tabs) do
        local tabBtn = self:_createButton(tabContainer, tabName, UDim2.new(0, tabWidth - 2, 0, 22), UDim2.fromOffset(2 + (i-1) * tabWidth, 2), function()
            self:SwitchDecompilerTab(tabName, panel)
            for _, btn in pairs(tabButtons) do
                if btn and btn.Parent then
                    btn.BackgroundColor3 = self.Config.BG_PANEL
                    btn.TextColor3 = self.Config.TEXT_BLACK
                end
            end
            if tabBtn and tabBtn.Parent then
                tabBtn.BackgroundColor3 = self.Config.ACCENT_BLUE
                tabBtn.TextColor3 = self.Config.BG_WHITE
            end
        end)
        tabBtn.ZIndex = 102
        tabBtn.TextSize = 9
        tabButtons[tabName] = tabBtn
    end
    local contentArea = Instance.new("ScrollingFrame", contentContainer)
    contentArea.Name = "DecompilerContent"
    contentArea.Size = UDim2.new(1, 0, 1, -106)
    contentArea.Position = UDim2.fromOffset(0, 28)
    contentArea.BackgroundColor3 = self.Config.BG_WHITE
    contentArea.BorderSizePixel = 0
    contentArea.ScrollBarThickness = 12
    contentArea.ScrollBarImageColor3 = self.Config.BG_DARK
    contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
    contentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentArea.ZIndex = 101
    contentArea.ClipsDescendants = true
    self:_createBorder(contentArea, true)
    local emptyLabel = Instance.new("TextLabel", contentArea)
    emptyLabel.Name = "EmptyMessage"
    emptyLabel.Size = UDim2.new(1, -16, 0, 80)
    emptyLabel.Position = UDim2.fromOffset(8, 8)
    emptyLabel.BackgroundTransparency = 1
    emptyLabel.Text = [[HOW TO USE DECOMPILER:
1. Select a module from the Module List (left panel)
2. Click "Scan Module" in the function browser
3. Click any function name to decompile it
4. Use tabs above to view Info/Constants/Upvalues/Source
5. Use Quick Actions below to patch/hook functions]]
    emptyLabel.TextColor3 = self.Config.TEXT_GRAY
    emptyLabel.Font = Enum.Font.SourceSans
    emptyLabel.TextSize = 11
    emptyLabel.TextWrapped = true
    emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
    emptyLabel.TextYAlignment = Enum.TextYAlignment.Top
    emptyLabel.ZIndex = 102
    local actionFrame = Instance.new("Frame", contentContainer)
    actionFrame.Size = UDim2.new(1, 0, 0, 76)
    actionFrame.Position = UDim2.new(0, 0, 1, -76)
    actionFrame.BackgroundColor3 = self.Config.BG_PANEL
    actionFrame.BorderSizePixel = 0
    actionFrame.ZIndex = 101
    self:_createBorder(actionFrame, true)
    local actionTitle = Instance.new("TextLabel", actionFrame)
    actionTitle.Size = UDim2.new(1, -8, 0, 16)
    actionTitle.Position = UDim2.fromOffset(4, 2)
    actionTitle.BackgroundTransparency = 1
    actionTitle.Text = "Quick Actions (select a function first)"
    actionTitle.TextColor3 = self.Config.TEXT_BLACK
    actionTitle.Font = Enum.Font.SourceSansBold
    actionTitle.TextSize = 9
    actionTitle.TextXAlignment = Enum.TextXAlignment.Left
    actionTitle.ZIndex = 102
    local buttonStartY = 20
    local buttonHeight = 22
    local buttonSpacing = 2
    local buttonsPerRow = 4
    local actionButtons = {
        {label = "Hook Return", func = function() self:ShowReturnHookDialog(panel) end},
        {label = "Patch Upvalue", func = function() self:ShowUpvaluePatchDialog(panel) end},
        {label = "Patch Constant", func = function() self:ShowConstantPatchDialog(panel) end},
        {label = "Track Calls", func = function() self:ShowCallTrackerDialog(panel) end},
        {label = "Replace Closure", func = function() self:ShowClosureReplaceDialog(panel) end},
        {label = "View Patches", func = function() self:ShowFunctionPatchList(panel) end},
        {label = "Clear All Patches", func = function() 
            self:ClearAllFunctionPatches()
            self:_showNotification("All function patches cleared", "success")
        end},
        {label = "Export Info", func = function()
            if self.State.CurrentDecompiledFunction then
                self:ExportFunctionInfo(self.State.CurrentDecompiledFunction)
            else
                self:_showNotification("No function decompiled yet", "warning")
            end
        end}
    }
    for i, btnData in ipairs(actionButtons) do
        local row = math.floor((i - 1) / buttonsPerRow)
        local col = (i - 1) % buttonsPerRow
        local btn = self:_createButton(
            actionFrame, 
            btnData.label, 
            UDim2.new(0.25, -3, 0, buttonHeight), 
            UDim2.new(col * 0.25, 2, 0, buttonStartY + row * (buttonHeight + buttonSpacing)),
            btnData.func
        )
        btn.ZIndex = 102
        btn.TextSize = 8
        btn.TextWrapped = true
    end
    return panel
end
function Modules.OverseerCE:DecompileFunctionFromPath(path, panel)
    local func = self:GetValueFromPath(path)
    if type(func) ~= "function" then
        self:_showNotification("Path does not point to a function", "error")
        return
    end
    self:_showNotification("Decompiling function...", "info")
    local decompiled = self:DecompileFunction(func)
    if not decompiled then
        self:_showNotification("Decompilation failed", "error")
        return
    end
    self.State.CurrentDecompiledFunction = decompiled
    self.State.CurrentDecompiledFunctionRef = func
    self.State.CurrentDecompiledPath = path
    self:SwitchDecompilerTab("Info", panel)
    self:_showNotification("Function decompiled successfully", "success")
end
function Modules.OverseerCE:SwitchDecompilerTab(tabName, panel)
    local contentArea = panel:FindFirstChild("DecompilerContent")
    if not contentArea then return end
    for _, child in ipairs(contentArea:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    if not self.State.CurrentDecompiledFunction then
        local emptyLabel = Instance.new("TextLabel", contentArea)
        emptyLabel.Size = UDim2.new(1, -8, 0, 30)
        emptyLabel.Position = UDim2.fromOffset(4, 4)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "No function decompiled yet"
        emptyLabel.TextColor3 = self.Config.TEXT_GRAY
        emptyLabel.Font = Enum.Font.SourceSans
        emptyLabel.TextSize = 11
        emptyLabel.ZIndex = 102
        return
    end
    local decomp = self.State.CurrentDecompiledFunction
    if tabName == "Info" then
        self:ShowDecompilerInfo(contentArea, decomp)
    elseif tabName == "Constants" then
        self:ShowDecompilerConstants(contentArea, decomp)
    elseif tabName == "Upvalues" then
        self:ShowDecompilerUpvalues(contentArea, decomp)
    elseif tabName == "Protos" then
        self:ShowDecompilerProtos(contentArea, decomp)
    elseif tabName == "Source" then
        self:ShowDecompilerSource(contentArea, decomp)
    end
end
function Modules.OverseerCE:ShowDecompilerInfo(parent, decomp)
    local yPos = 4
    local infoText = string.format([[Function Information:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Address: %s
Access Method: %s
Source: %s
Short Source: %s
Line Defined: %d
Last Line Defined: %d
Number of Parameters: %d
Is Vararg: %s
What: %s
Name: %s
Constants: %d found
Upvalues: %d found
Protos: %d found
]], 
        decomp.Address,
        decomp.AccessMethod,
        decomp.Info.Source or "?",
        decomp.Info.ShortSource or "?",
        decomp.Info.LineDefined or -1,
        decomp.Info.LastLineDefined or -1,
        decomp.Info.NumParams or 0,
        decomp.Info.IsVararg and "Yes" or "No",
        decomp.Info.What or "?",
        decomp.Info.Name or "<anonymous>",
        #decomp.Constants,
        #decomp.Upvalues,
        #decomp.Protos
    )
    local infoLabel = Instance.new("TextLabel", parent)
    infoLabel.Size = UDim2.new(1, -8, 0, 280)
    infoLabel.Position = UDim2.fromOffset(4, yPos)
    infoLabel.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
    infoLabel.Text = infoText
    infoLabel.TextColor3 = self.Config.TEXT_BLACK
    infoLabel.Font = Enum.Font.Code
    infoLabel.TextSize = 9
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.ZIndex = 102
    self:_createBorder(infoLabel, true)
    local infoPadding = Instance.new("UIPadding", infoLabel)
    infoPadding.PaddingLeft = UDim.new(0, 6)
    infoPadding.PaddingTop = UDim.new(0, 6)
    infoPadding.PaddingRight = UDim.new(0, 6)
end
function Modules.OverseerCE:ShowDecompilerConstants(parent, decomp)
    local yPos = 4
    local headerLabel = Instance.new("TextLabel", parent)
    headerLabel.Size = UDim2.new(1, -8, 0, 20)
    headerLabel.Position = UDim2.fromOffset(4, yPos)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = string.format("Constants (%d found)", #decomp.Constants)
    headerLabel.TextColor3 = self.Config.TEXT_BLACK
    headerLabel.Font = Enum.Font.SourceSansBold
    headerLabel.TextSize = 11
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.ZIndex = 102
    yPos = yPos + 24
    if #decomp.Constants == 0 then
        local emptyLabel = Instance.new("TextLabel", parent)
        emptyLabel.Size = UDim2.new(1, -8, 0, 20)
        emptyLabel.Position = UDim2.fromOffset(4, yPos)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "No constants found"
        emptyLabel.TextColor3 = self.Config.TEXT_GRAY
        emptyLabel.Font = Enum.Font.SourceSans
        emptyLabel.TextSize = 10
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
        emptyLabel.ZIndex = 102
        return
    end
    for i, constant in ipairs(decomp.Constants) do
        local constFrame = Instance.new("Frame", parent)
        constFrame.Size = UDim2.new(1, -8, 0, 24)
        constFrame.Position = UDim2.fromOffset(4, yPos)
        constFrame.BackgroundColor3 = i % 2 == 0 and self.Config.BG_WHITE or Color3.fromRGB(245, 245, 245)
        constFrame.BorderSizePixel = 0
        constFrame.ZIndex = 102
        self:_createBorder(constFrame, true)
        local indexLabel = Instance.new("TextLabel", constFrame)
        indexLabel.Size = UDim2.new(0, 40, 1, 0)
        indexLabel.Position = UDim2.fromOffset(4, 0)
        indexLabel.BackgroundTransparency = 1
        indexLabel.Text = tostring(i)
        indexLabel.TextColor3 = self.Config.TEXT_GRAY
        indexLabel.Font = Enum.Font.Code
        indexLabel.TextSize = 10
        indexLabel.TextXAlignment = Enum.TextXAlignment.Left
        indexLabel.ZIndex = 103
        local typeLabel = Instance.new("TextLabel", constFrame)
        typeLabel.Size = UDim2.new(0, 60, 1, 0)
        typeLabel.Position = UDim2.fromOffset(48, 0)
        typeLabel.BackgroundTransparency = 1
        typeLabel.Text = type(constant)
        typeLabel.TextColor3 = self.Config.ACCENT_BLUE
        typeLabel.Font = Enum.Font.Code
        typeLabel.TextSize = 10
        typeLabel.TextXAlignment = Enum.TextXAlignment.Left
        typeLabel.ZIndex = 103
        local valueLabel = Instance.new("TextLabel", constFrame)
        valueLabel.Size = UDim2.new(1, -200, 1, 0)
        valueLabel.Position = UDim2.fromOffset(112, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(constant)
        valueLabel.TextColor3 = self.Config.TEXT_BLACK
        valueLabel.Font = Enum.Font.Code
        valueLabel.TextSize = 9
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
        valueLabel.ZIndex = 103
        local patchBtn = self:_createButton(constFrame, "Patch", UDim2.fromOffset(60, 18), UDim2.new(1, -64, 0, 3), function()
            self:ShowConstantPatchDialogWithIndex(i, constant)
        end)
        patchBtn.ZIndex = 104
        patchBtn.TextSize = 8
        yPos = yPos + 26
    end
end
function Modules.OverseerCE:ShowDecompilerUpvalues(parent, decomp)
    local yPos = 4
    local headerLabel = Instance.new("TextLabel", parent)
    headerLabel.Size = UDim2.new(1, -8, 0, 20)
    headerLabel.Position = UDim2.fromOffset(4, yPos)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = string.format("Upvalues (%d found)", #decomp.Upvalues)
    headerLabel.TextColor3 = self.Config.TEXT_BLACK
    headerLabel.Font = Enum.Font.SourceSansBold
    headerLabel.TextSize = 11
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.ZIndex = 102
    yPos = yPos + 24
    if #decomp.Upvalues == 0 then
        local emptyLabel = Instance.new("TextLabel", parent)
        emptyLabel.Size = UDim2.new(1, -8, 0, 20)
        emptyLabel.Position = UDim2.fromOffset(4, yPos)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "No upvalues found"
        emptyLabel.TextColor3 = self.Config.TEXT_GRAY
        emptyLabel.Font = Enum.Font.SourceSans
        emptyLabel.TextSize = 10
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
        emptyLabel.ZIndex = 102
        return
    end
    for name, value in pairs(decomp.Upvalues) do
        local uvFrame = Instance.new("Frame", parent)
        uvFrame.Size = UDim2.new(1, -8, 0, 24)
        uvFrame.Position = UDim2.fromOffset(4, yPos)
        uvFrame.BackgroundColor3 = yPos % 48 == 4 and self.Config.BG_WHITE or Color3.fromRGB(245, 245, 245)
        uvFrame.BorderSizePixel = 0
        uvFrame.ZIndex = 102
        self:_createBorder(uvFrame, true)
        local nameLabel = Instance.new("TextLabel", uvFrame)
        nameLabel.Size = UDim2.new(0, 120, 1, 0)
        nameLabel.Position = UDim2.fromOffset(4, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = tostring(name)
        nameLabel.TextColor3 = self.Config.ACCENT_BLUE
        nameLabel.Font = Enum.Font.Code
        nameLabel.TextSize = 10
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.ZIndex = 103
        local typeLabel = Instance.new("TextLabel", uvFrame)
        typeLabel.Size = UDim2.new(0, 60, 1, 0)
        typeLabel.Position = UDim2.fromOffset(128, 0)
        typeLabel.BackgroundTransparency = 1
        typeLabel.Text = type(value)
        typeLabel.TextColor3 = self.Config.TEXT_GRAY
        typeLabel.Font = Enum.Font.Code
        typeLabel.TextSize = 10
        typeLabel.TextXAlignment = Enum.TextXAlignment.Left
        typeLabel.ZIndex = 103
        local valueLabel = Instance.new("TextLabel", uvFrame)
        valueLabel.Size = UDim2.new(1, -280, 1, 0)
        valueLabel.Position = UDim2.fromOffset(192, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(value)
        valueLabel.TextColor3 = self.Config.TEXT_BLACK
        valueLabel.Font = Enum.Font.Code
        valueLabel.TextSize = 9
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
        valueLabel.ZIndex = 103
        local patchBtn = self:_createButton(uvFrame, "Patch", UDim2.fromOffset(60, 18), UDim2.new(1, -64, 0, 3), function()
            self:ShowUpvaluePatchDialogWithName(name, value)
        end)
        patchBtn.ZIndex = 104
        patchBtn.TextSize = 8
        yPos = yPos + 26
    end
end
function Modules.OverseerCE:ShowDecompilerProtos(parent, decomp)
    local yPos = 4
    local headerLabel = Instance.new("TextLabel", parent)
    headerLabel.Size = UDim2.new(1, -8, 0, 20)
    headerLabel.Position = UDim2.fromOffset(4, yPos)
    headerLabel.BackgroundTransparency = 1
    headerLabel.Text = string.format("Nested Functions/Protos (%d found)", #decomp.Protos)
    headerLabel.TextColor3 = self.Config.TEXT_BLACK
    headerLabel.Font = Enum.Font.SourceSansBold
    headerLabel.TextSize = 11
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.ZIndex = 102
    yPos = yPos + 24
    if #decomp.Protos == 0 then
        local emptyLabel = Instance.new("TextLabel", parent)
        emptyLabel.Size = UDim2.new(1, -8, 0, 20)
        emptyLabel.Position = UDim2.fromOffset(4, yPos)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "No nested functions found"
        emptyLabel.TextColor3 = self.Config.TEXT_GRAY
        emptyLabel.Font = Enum.Font.SourceSans
        emptyLabel.TextSize = 10
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
        emptyLabel.ZIndex = 102
        return
    end
    for i, proto in ipairs(decomp.Protos) do
        local protoFrame = Instance.new("Frame", parent)
        protoFrame.Size = UDim2.new(1, -8, 0, 30)
        protoFrame.Position = UDim2.fromOffset(4, yPos)
        protoFrame.BackgroundColor3 = i % 2 == 0 and self.Config.BG_WHITE or Color3.fromRGB(245, 245, 245)
        protoFrame.BorderSizePixel = 0
        protoFrame.ZIndex = 102
        self:_createBorder(protoFrame, true)
        local indexLabel = Instance.new("TextLabel", protoFrame)
        indexLabel.Size = UDim2.new(0, 40, 1, 0)
        indexLabel.Position = UDim2.fromOffset(4, 0)
        indexLabel.BackgroundTransparency = 1
        indexLabel.Text = "Proto " .. i
        indexLabel.TextColor3 = self.Config.ACCENT_BLUE
        indexLabel.Font = Enum.Font.Code
        indexLabel.TextSize = 10
        indexLabel.TextXAlignment = Enum.TextXAlignment.Left
        indexLabel.ZIndex = 103
        local addrLabel = Instance.new("TextLabel", protoFrame)
        addrLabel.Size = UDim2.new(1, -140, 1, 0)
        addrLabel.Position = UDim2.fromOffset(50, 0)
        addrLabel.BackgroundTransparency = 1
        addrLabel.Text = tostring(proto)
        addrLabel.TextColor3 = self.Config.TEXT_BLACK
        addrLabel.Font = Enum.Font.Code
        addrLabel.TextSize = 9
        addrLabel.TextXAlignment = Enum.TextXAlignment.Left
        addrLabel.TextTruncate = Enum.TextTruncate.AtEnd
        addrLabel.ZIndex = 103
        local decompileBtn = self:_createButton(protoFrame, "Decompile", UDim2.fromOffset(80, 20), UDim2.new(1, -84, 0, 5), function()
            if type(proto) == "function" then
                local protoDecomp = self:DecompileFunction(proto)
                if protoDecomp then
                    self.State.CurrentDecompiledFunction = protoDecomp
                    self.State.CurrentDecompiledFunctionRef = proto
                    self:SwitchDecompilerTab("Info", parent:GetParent())
                    self:_showNotification("Proto decompiled", "success")
                end
            end
        end)
        decompileBtn.ZIndex = 104
        decompileBtn.TextSize = 8
        yPos = yPos + 32
    end
end
function Modules.OverseerCE:ShowDecompilerSource(parent, decomp)
    local yPos = 4
    local sourceBox = Instance.new("TextBox", parent)
    sourceBox.Size = UDim2.new(1, -8, 1, -8)
    sourceBox.Position = UDim2.fromOffset(4, yPos)
    sourceBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sourceBox.TextColor3 = Color3.fromRGB(220, 220, 220)
    sourceBox.Font = Enum.Font.Code
    sourceBox.TextSize = 9
    sourceBox.TextXAlignment = Enum.TextXAlignment.Left
    sourceBox.TextYAlignment = Enum.TextYAlignment.Top
    sourceBox.TextWrapped = true
    sourceBox.ClearTextOnFocus = false
    sourceBox.MultiLine = true
    sourceBox.ZIndex = 102
    if decomp.SourceCode then
        sourceBox.Text = decomp.SourceCode
    else
        sourceBox.Text = "-- Source code not available\n-- Decompiler not found or function is native\n\n-- Use the other tabs to view function details"
    end
    self:_createBorder(sourceBox, true)
    local sourcePadding = Instance.new("UIPadding", sourceBox)
    sourcePadding.PaddingLeft = UDim.new(0, 6)
    sourcePadding.PaddingTop = UDim.new(0, 6)
    sourcePadding.PaddingRight = UDim.new(0, 6)
    sourcePadding.PaddingBottom = UDim.new(0, 6)
end
function Modules.OverseerCE:ShowReturnHookDialog(panel)
    if not self.State.CurrentDecompiledFunctionRef then
        self:_showNotification("No function selected", "warning")
        return
    end
    self:_showNotification("Return hook feature - Enter value in console", "info")
    print("[Decompiler] Enter return value to hook:")
    print("[Decompiler] Example: Modules.OverseerCE:PatchFunctionReturn(<function>, <returnValue>)")
end
function Modules.OverseerCE:ShowUpvaluePatchDialog(panel)
    if not self.State.CurrentDecompiledFunctionRef then
        self:_showNotification("No function selected", "warning")
        return
    end
    self:_showNotification("Upvalue patch feature - See upvalues tab", "info")
end
function Modules.OverseerCE:ShowUpvaluePatchDialogWithName(name, currentValue)
    if not self.State.CurrentDecompiledFunctionRef then
        self:_showNotification("No function selected", "warning")
        return
    end
    local func = self.State.CurrentDecompiledFunctionRef
    print(string.format("[Decompiler] Patch upvalue '%s'", name))
    print(string.format("[Decompiler] Current value: %s", tostring(currentValue)))
    print("[Decompiler] To patch, use:")
    print(string.format("    Modules.OverseerCE:PatchFunctionUpvalue(<function>, '%s', <newValue>)", name))
end
function Modules.OverseerCE:ShowConstantPatchDialog(panel)
    if not self.State.CurrentDecompiledFunctionRef then
        self:_showNotification("No function selected", "warning")
        return
    end
    self:_showNotification("Constant patch feature - See constants tab", "info")
end
function Modules.OverseerCE:ShowConstantPatchDialogWithIndex(index, currentValue)
    if not self.State.CurrentDecompiledFunctionRef then
        self:_showNotification("No function selected", "warning")
        return
    end
    print(string.format("[Decompiler] Patch constant #%d", index))
    print(string.format("[Decompiler] Current value: %s", tostring(currentValue)))
    print("[Decompiler] To patch, use:")
    print(string.format("    Modules.OverseerCE:PatchFunctionConstant(<function>, %d, <newValue>)", index))
end
function Modules.OverseerCE:ShowCallTrackerDialog(panel)
    if not self.State.CurrentDecompiledFunctionRef then
        self:_showNotification("No function selected", "warning")
        return
    end
    local func = self.State.CurrentDecompiledFunctionRef
    local success, msg = self:HookFunctionCalls(func, function(count, ...)
        print(string.format("[Call Tracker] Function called #%d with args:", count))
        local args = {...}
        for i, arg in ipairs(args) do
            print(string.format("  [%d] = %s", i, tostring(arg)))
        end
    end)
    if success then
        self:_showNotification("Call tracking enabled", "success")
    else
        self:_showNotification("Failed to enable tracking: " .. msg, "error")
    end
end
function Modules.OverseerCE:ShowClosureReplaceDialog(panel)
    if not self.State.CurrentDecompiledFunctionRef then
        self:_showNotification("No function selected", "warning")
        return
    end
    self:_showNotification("Closure replacement - Use console", "info")
    print("[Decompiler] To replace this function's closure, use:")
    print("    Modules.OverseerCE:ReplaceClosure(<oldFunc>, <newFunc>)")
end
function Modules.OverseerCE:ShowFunctionPatchList(panel)
    print("=== ACTIVE FUNCTION PATCHES ===")
    print("\n[Return Hooks]")
    for id, patch in pairs(self.State.ReturnHooks) do
        print(string.format("  %s -> returns %s", id, tostring(patch.ReturnValue)))
    end
    print("\n[Upvalue Patches]")
    for id, patch in pairs(self.State.UpvalueMonitors) do
        print(string.format("  %s[%s] = %s", id, patch.UpvalueName, tostring(patch.NewValue)))
    end
    print("\n[Constant Patches]")
    for id, patch in pairs(self.State.ConstantPatches) do
        print(string.format("  %s[%d] = %s", id, patch.ConstantIndex, tostring(patch.NewValue)))
    end
    print("\n[Call Trackers]")
    for id, tracker in pairs(self.State.CallTrackers) do
        print(string.format("  %s - %d calls tracked", id, #tracker.Calls))
    end
    self:_showNotification("Patch list printed to console", "info")
end
function Modules.OverseerCE:ClearAllFunctionPatches()
    for id, patch in pairs(self.State.ReturnHooks) do
        if patch.Original and hookfunction then
            pcall(hookfunction, patch.Function, patch.Original)
        end
    end
    self.State.ReturnHooks = {}
    for id, tracker in pairs(self.State.CallTrackers) do
        if tracker.Original and hookfunction then
            pcall(hookfunction, tracker.Function, tracker.Original)
        end
    end
    self.State.CallTrackers = {}
    self.State.UpvalueMonitors = {}
    self.State.ConstantPatches = {}
    self.State.FunctionPatches = {}
end
function Modules.OverseerCE:RefreshDecompilerView(panel)
    if self.State.CurrentDecompiledPath then
        self:DecompileFunctionFromPath(self.State.CurrentDecompiledPath, panel)
    end
end
function Modules.OverseerCE:ExportFunctionInfo(decomp)
    local export = {
        Address = decomp.Address,
        Info = decomp.Info,
        Constants = {},
        Upvalues = {},
        ProtosCount = #decomp.Protos,
        HasSourceCode = decomp.SourceCode ~= nil,
        SourceCode = decomp.SourceCode
    }
    for i, const in ipairs(decomp.Constants) do
        export.Constants[i] = {
            Index = i,
            Type = type(const),
            Value = tostring(const)
        }
    end
    for name, value in pairs(decomp.Upvalues) do
        table.insert(export.Upvalues, {
            Name = tostring(name),
            Type = type(value),
            Value = tostring(value)
        })
    end
    local success, exportText = pcall(function()
        return game:GetService("HttpService"):JSONEncode(export)
    end)
    if success then
        local copied = self:_setClipboard(exportText)
        if copied then
            self:_showNotification("Function info exported to clipboard", "success")
        else
            print("[Decompiler Export]")
            print(exportText)
            self:_showNotification("Export printed to console", "info")
        end
    else
        self:_showNotification("Export failed", "error")
    end
end
function Modules.OverseerCE:GetValueFromPath(path)
    local parts = {}
    for part in path:gmatch("[^%.]+") do
        table.insert(parts, part)
    end
    if #parts == 0 then return nil end
    local current = _G
    for i, part in ipairs(parts) do
        if current[part] ~= nil then
            current = current[part]
        else
            current = game
            for j = i, #parts do
                local suc, res = pcall(function() return current[parts[j]] end)
                if suc and res then
                    current = res
                else
                    return nil
                end
            end
            break
        end
    end
    return current
end
function Modules.OverseerCE:GetTableWithMetatable(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local mt, method = self:GetRawMetatable(tbl)
    if mt then
        local unlocked, unlockMsg = self:UnlockMetatable(tbl)
        local combined = {}
        for k, v in pairs(tbl) do
            combined[k] = v
        end
        combined["[METATABLE]"] = mt
        combined["[METATABLE_INFO]"] = {
            Locked = not unlocked,
            AccessMethod = method,
            UnlockMessage = unlockMsg
        }
        return combined
    end
    return tbl
end
function Modules.OverseerCE:DecodeBase64(data)
    local success, result = pcall(function()
        local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        data = string.gsub(data, '[^'..b..'=]', '')
        return (data:gsub('.', function(x)
            if x == '=' then return '' end
            local r,f='',(b:find(x)-1)
            for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
            return r;
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if #x ~= 8 then return '' end
            local c=0
            for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end)
    if success and result then
        return result
    end
    return nil
end
function Modules.OverseerCE:IsBase64(str)
    if type(str) ~= "string" then return false end
    if #str < 4 or #str % 4 ~= 0 then return false end
    return str:match("^[A-Za-z0-9+/]*=*$") ~= nil
end
function Modules.OverseerCE:GetDisplayValue(value, key)
    local valueType = type(value)
    if valueType == "string" then
        if self.State.Base64DecoderEnabled and self:IsBase64(value) and #value >= 8 then
            local decoded = self:DecodeBase64(value)
            if decoded and decoded ~= value then
                return string.format('"%s" [Base64: %s]', 
                    value:sub(1, 20)..(#value > 20 and "..." or ""), 
                    decoded:sub(1, 40)..(#decoded > 40 and "..." or ""))
            end
        end
        return '"' .. tostring(value) .. '"'
    elseif valueType == "number" then
        if value == math.floor(value) and value >= 0 and value < 2^32 then
            return string.format("%d (0x%X)", value, value)
        end
        return tostring(value)
    elseif valueType == "boolean" then
        return tostring(value)
    elseif valueType == "table" then
        local size = 0
        for _ in pairs(value) do size = size + 1 end
        local mt = getmetatable(value)
        if mt and mt.__tostring then
            local success, str = pcall(function() return tostring(value) end)
            if success and str ~= "table" and not str:find("table: 0x") then
                return str .. " [table: " .. size .. " entries]"
            end
        end
        return "{table: " .. size .. " entries}"
    elseif valueType == "function" then
        local info = debug and debug.getinfo and debug.getinfo(value)
        if info then
            local source = info.source or "?"
            local line = info.linedefined or "?"
            return string.format("function (%s:%s)", source:sub(1, 20), line)
        end
        return "function"
    elseif valueType == "userdata" then
        local success, str = pcall(function() return tostring(value) end)
        if success then
            return str .. " [userdata]"
        end
        return "[userdata]"
    else
        return tostring(value)
    end
end
function Modules.OverseerCE:GetModuleContent(module)
    if module == nil then
        return {
            ["[Error]"] = "Module returned nil",
            ["[Type]"] = "nil",
            ["[Info]"] = "This module doesn't return a value"
        }
    end
    local moduleType = type(module)
    if module ~= nil then
        self.State.ModuleTypeCache[module] = moduleType
    end
    if moduleType == "table" then
        return module
    elseif moduleType == "function" then
        local success, result = pcall(module)
        if success then
            if type(result) == "table" then
                return result
            else
                return {
                    ["[Return Value]"] = result,
                    ["[Type]"] = type(result),
                    ["[Function Info]"] = debug and debug.getinfo and debug.getinfo(module) or "unavailable"
                }
            end
        else
            return {
                ["[Error]"] = tostring(result),
                ["[Type]"] = "function (failed to execute)",
                ["[Function Info]"] = debug and debug.getinfo and debug.getinfo(module) or "unavailable"
            }
        end
    elseif moduleType == "userdata" or moduleType == "string" or moduleType == "number" or moduleType == "boolean" then
        local wrapper = {
            ["[Value]"] = module,
            ["[Type]"] = moduleType,
            ["[String Representation]"] = tostring(module)
        }
        local success, mt = pcall(getmetatable, module)
        if success and mt then
            wrapper["[Metatable]"] = mt
        end
        if moduleType == "string" and self.State.Base64DecoderEnabled and self:IsBase64(module) then
            local decoded = self:DecodeBase64(module)
            if decoded then
                wrapper["[Base64 Decoded]"] = decoded
            end
        end
        return wrapper
    else
        return {
            ["[Value]"] = tostring(module),
            ["[Type]"] = moduleType,
            ["[Raw]"] = module
        }
    end
end
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
    return {top, left, bottom, right}
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
    btn.AutoButtonColor = false
    btn.ClipsDescendants = true
    self:_createBorder(btn, false)
    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
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
    btn.MouseEnter:Connect(function()
        if btn.BackgroundColor3 ~= self.Config.BG_DARK then
            local tween = TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = self.Config.BG_LIGHT
            })
            tween:Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 ~= self.Config.BG_DARK then
            local tween = TweenService:Create(btn, TweenInfo.new(0.1), {
                BackgroundColor3 = self.Config.BG_PANEL
            })
            tween:Play()
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
    panel.ClipsDescendants = false
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
        return true
    elseif toclipboard then
        toclipboard(txt)
        return true
    end
    return false
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
function Modules.OverseerCE:_showNotification(message, messageType)
    if not self.State.UI or not self.State.UI.Main then return end
    local notif = Instance.new("Frame", self.State.UI.Main)
    notif.Size = UDim2.fromOffset(300, 60)
    notif.Position = UDim2.new(1, -310, 1, 10)
    notif.BackgroundColor3 = messageType == "success" and Color3.fromRGB(220, 255, 220)
        or messageType == "error" and Color3.fromRGB(255, 220, 220)
        or messageType == "warning" and Color3.fromRGB(255, 245, 220)
        or self.Config.BG_LIGHT
    notif.BorderSizePixel = 0
    notif.ZIndex = 1000
    self:_createBorder(notif, true)
    local icon = Instance.new("TextLabel", notif)
    icon.Size = UDim2.fromOffset(40, 40)
    icon.Position = UDim2.fromOffset(10, 10)
    icon.BackgroundTransparency = 1
    icon.Text = messageType == "success" and "✓" 
        or messageType == "error" and "✗" 
        or messageType == "warning" and "⚠"
        or "ℹ"
    icon.TextColor3 = messageType == "success" and self.Config.SUCCESS_GREEN
        or messageType == "error" and self.Config.FROZEN_RED
        or messageType == "warning" and self.Config.WARNING_ORANGE
        or self.Config.ACCENT_BLUE
    icon.Font = Enum.Font.SourceSansBold
    icon.TextSize = 24
    icon.ZIndex = 1001
    local msg = Instance.new("TextLabel", notif)
    msg.Size = UDim2.new(1, -60, 1, -4)
    msg.Position = UDim2.fromOffset(54, 2)
    msg.BackgroundTransparency = 1
    msg.Text = message
    msg.TextColor3 = self.Config.TEXT_BLACK
    msg.Font = Enum.Font.SourceSans
    msg.TextSize = 10
    msg.TextXAlignment = Enum.TextXAlignment.Left
    msg.TextYAlignment = Enum.TextYAlignment.Center
    msg.TextWrapped = true
    msg.ZIndex = 1001
    local slideTween = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(1, -310, 1, -70)
    })
    slideTween:Play()
    task.delay(3, function()
        local fadeOut = TweenService:Create(notif, TweenInfo.new(0.3), {
            Position = UDim2.new(1, -310, 1, 10)
        })
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            notif:Destroy()
        end)
    end)
end
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
            if searchType == "any" or type(value) == searchType then
                if exactMatch then
                    matches = (value == searchValue)
                else
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
            if type(value) == "table" and depth < 20 then
                scanTable(value, path .. "." .. tostring(key), depth + 1)
            end
        end
        local mt = getmetatable(tbl)
        if mt and type(mt) == "table" then
            scanTable(mt, path .. ".[MT]", depth + 1)
        end
    end
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
            return {Type = valueType, Value = value:sub(1, 100)}
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
            for k, v in pairs(value) do
                tableDump.Fields[tostring(k)] = dumpValue(v, depth + 1)
            end
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
    table.insert(self.State.DumpedModules, dump)
    return {Success = true, Dump = dump}
end
function Modules.OverseerCE:ExportDump(dump)
    local HttpService = game:GetService("HttpService")
    local success, json = pcall(function()
        return HttpService:JSONEncode(dump)
    end)
    if success then
        local copied = self:_setClipboard(json)
        if copied then
            self:_showNotification("Dump exported to clipboard!", "success")
        else
            self:_showNotification("Failed to copy to clipboard", "error")
        end
        return {Success = true, JSON = json}
    else
        self:_showNotification("JSON encoding failed", "error")
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
function Modules.OverseerCE:InjectCode(code, targetModule, withUpvalues)
    local success, result = pcall(function()
        local func = loadstring(code)
        if not func then
            return {Success = false, Error = "Failed to compile code"}
        end
        local env = {}
        local envMeta = {}
        if targetModule then
            local moduleTable = require(targetModule)
            envMeta.__index = function(_, key)
                if moduleTable[key] ~= nil then
                    return moduleTable[key]
                end
                return _G[key]
            end
            envMeta.__newindex = function(_, key, value)
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
        local execResult = {func()}
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
function Modules.OverseerCE:EnableAntiTamper()
    if self.State.AntiTamperActive then
        return {Success = false, Error = "Anti-tamper already active"}
    end
    self.State.OriginalFunctions = {
        getmetatable = getmetatable,
        setmetatable = setmetatable,
        rawget = rawget,
        rawset = rawset,
        rawequal = rawequal,
        type = type,
        typeof = typeof
    }
    local originalGetmetatable = getmetatable
    getmetatable = function(tbl)
        local mt = originalGetmetatable(tbl)
        if mt and self.State.ActivePatches[mt] then
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
    local originalSetmetatable = setmetatable
    setmetatable = function(tbl, mt)
        print("[Anti-Tamper] setmetatable called on:", tostring(tbl))
        return originalSetmetatable(tbl, mt)
    end
    local originalRawset = rawset
    rawset = function(tbl, key, value)
        for patchId, patch in pairs(self.State.FreezeList) do
            if patch.Table == tbl and patch.Key == key then
                print("[Anti-Tamper] Blocked rawset on frozen patch:", key)
                return
            end
        end
        return originalRawset(tbl, key, value)
    end
    local originalType = type
    type = function(value)
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
    local detections = {}
    local patterns = {
        {Name = "getfenv Hook", Check = function()
            return getfenv ~= debug.getfenv
        end},
        {Name = "Protected Metatables", Check = function()
            local test = {}
            local success = pcall(function()
                setmetatable(test, {__metatable = "Locked"})
                getmetatable(test)
            end)
            return not success
        end},
        {Name = "Debug Library Available", Check = function()
            return debug ~= nil
        end},
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
function Modules.OverseerCE:AnalyzeMetatableChain(tbl)
    local chain = {}
    local current = tbl
    local depth = 0
    local visited = {}
    while current and depth < 20 do
        if visited[current] then break end
        visited[current] = true
        local mt, method = self:GetRawMetatable(current)
        if not mt then break end
        local unlocked, unlockMsg = self:UnlockMetatable(current)
        local chainEntry = {
            Depth = depth,
            Metatable = mt,
            Fields = {},
            HasIndex = false,
            IndexType = nil,
            IndexValue = nil,
            Locked = not unlocked,
            AccessMethod = method,
            UnlockMessage = unlockMsg
        }
        local fieldSuccess, fieldErr = pcall(function()
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
        end)
        if not fieldSuccess then
            table.insert(chainEntry.Fields, {
                Key = "[ERROR]",
                Value = "Cannot iterate metatable: " .. tostring(fieldErr),
                Type = "error"
            })
        end
        table.insert(chain, chainEntry)
        if chainEntry.HasIndex and chainEntry.IndexType == "table" then
            current = chainEntry.IndexValue
        else
            break
        end
        depth = depth + 1
    end
    return chain
end
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
    rawset(tbl, key, newValue)
    self.State.ActivePatches[patchId] = patch
    if freeze then
        self.State.FreezeList[patchId] = patch
    end
    pcall(function()
        if setreadonly then setreadonly(tbl, true) end
    end)
    self:RefreshPatchList()
    self:_showNotification("Patch applied to: " .. tostring(key), "success")
    return patchId
end
function Modules.OverseerCE:CreateQuickHook(func, parentTable, key, hookType, customValue)
    if type(func) ~= "function" then
        self:_showNotification("Can only hook functions", "error")
        return false
    end
    local hookId = self:_generateUID()
    local originalFunc = func
    local hookFunc
    if hookType == "return_true" then
        hookFunc = function(...)
            return true
        end
    elseif hookType == "return_false" then
        hookFunc = function(...)
            return false
        end
    elseif hookType == "return_nil" then
        hookFunc = function(...)
            return nil
        end
    elseif hookType == "return_zero" then
        hookFunc = function(...)
            return 0
        end
    elseif hookType == "return_one" then
        hookFunc = function(...)
            return 1
        end
    elseif hookType == "return_empty_table" then
        hookFunc = function(...)
            return {}
        end
    elseif hookType == "return_empty_string" then
        hookFunc = function(...)
            return ""
        end
    elseif hookType == "block" then
        hookFunc = function(...)
        end
    elseif hookType == "log_passthrough" then
        hookFunc = function(...)
            local args = {...}
            print("[Hook Log]", key, "called with", #args, "arguments")
            for i, arg in ipairs(args) do
                print("  Arg " .. i .. ":", tostring(arg))
            end
            local results = {originalFunc(...)}
            print("[Hook Log]", key, "returned", #results, "values")
            for i, result in ipairs(results) do
                print("  Result " .. i .. ":", tostring(result))
            end
            return table.unpack(results)
        end
    elseif hookType == "custom" then
        hookFunc = function(...)
            return customValue
        end
    else
        self:_showNotification("Unknown hook type", "error")
        return false
    end
    pcall(function()
        if setreadonly then setreadonly(parentTable, false) 
        elseif make_writeable then make_writeable(parentTable) end
    end)
    rawset(parentTable, key, hookFunc)
    pcall(function()
        if setreadonly then setreadonly(parentTable, true) end
    end)
    self.State.HookedFunctions[hookId] = {
        ID = hookId,
        Table = parentTable,
        Key = key,
        Original = originalFunc,
        HookFunction = hookFunc,
        HookType = hookType,
        CustomValue = customValue,
        Enabled = true,
        CallCount = 0,
        Timestamp = tick()
    }
    self.State.ActivePatches[hookId] = {
        ID = hookId,
        Table = parentTable,
        Key = key,
        Original = originalFunc,
        NewValue = hookFunc,
        Type = "function_hook",
        Frozen = false,
        Timestamp = tick(),
        Active = true,
        HookType = hookType
    }
    self:RefreshPatchList()
    self:RefreshHookList()
    local hookName = self:GetHookTypeName(hookType, customValue)
    self:_showNotification("Hooked: " .. tostring(key) .. " → " .. hookName, "success")
    return hookId
end
function Modules.OverseerCE:GetHookTypeName(hookType, customValue)
    local names = {
        return_true = "return true",
        return_false = "return false",
        return_nil = "return nil",
        return_zero = "return 0",
        return_one = "return 1",
        return_empty_table = "return {}",
        return_empty_string = 'return ""',
        block = "block (no return)",
        log_passthrough = "log & passthrough",
        custom = "return " .. tostring(customValue)
    }
    return names[hookType] or hookType
end
function Modules.OverseerCE:RemoveHook(hookId)
    local hook = self.State.HookedFunctions[hookId]
    if not hook then return false end
    pcall(function()
        if setreadonly then setreadonly(hook.Table, false) 
        elseif make_writeable then make_writeable(hook.Table) end
        rawset(hook.Table, hook.Key, hook.Original)
        if setreadonly then setreadonly(hook.Table, true) end
    end)
    self.State.HookedFunctions[hookId] = nil
    self.State.ActivePatches[hookId] = nil
    self:RefreshPatchList()
    self:RefreshHookList()
    self:_showNotification("Hook removed", "success")
    return true
end
function Modules.OverseerCE:ToggleHook(hookId)
    local hook = self.State.HookedFunctions[hookId]
    if not hook then return end
    pcall(function()
        if setreadonly then setreadonly(hook.Table, false) 
        elseif make_writeable then make_writeable(hook.Table) end
    end)
    if hook.Enabled then
        rawset(hook.Table, hook.Key, hook.Original)
        hook.Enabled = false
    else
        rawset(hook.Table, hook.Key, hook.HookFunction)
        hook.Enabled = true
    end
    pcall(function()
        if setreadonly then setreadonly(hook.Table, true) end
    end)
    self:RefreshHookList()
end
function Modules.OverseerCE:ShowQuickHookMenu(func, parentTable, key, buttonPosition)
    if not self.State.UI then return end
    local existingMenu = self.State.UI.Main:FindFirstChild("QuickHookMenu")
    if existingMenu then existingMenu:Destroy() end
    local menu = Instance.new("Frame", self.State.UI.Main)
    menu.Name = "QuickHookMenu"
    menu.Size = UDim2.fromOffset(200, 260)
    menu.Position = buttonPosition or UDim2.fromOffset(400, 300)
    menu.BackgroundColor3 = self.Config.BG_PANEL
    menu.BorderSizePixel = 0
    menu.ZIndex = 500
    self:_createBorder(menu, false)
    local title = Instance.new("TextLabel", menu)
    title.Size = UDim2.new(1, -4, 0, 20)
    title.Position = UDim2.fromOffset(2, 2)
    title.BackgroundColor3 = self.Config.ACCENT_BLUE
    title.Text = "Quick Hook: " .. tostring(key)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 10
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.BorderSizePixel = 0
    title.ZIndex = 501
    local titlePadding = Instance.new("UIPadding", title)
    titlePadding.PaddingLeft = UDim.new(0, 4)
    self:_createBorder(title, true)
    local hookOptions = {
        {label = "Return true", hookType = "return_true"},
        {label = "Return false", hookType = "return_false"},
        {label = "Return nil", hookType = "return_nil"},
        {label = "Return 0", hookType = "return_zero"},
        {label = "Return 1", hookType = "return_one"},
        {label = "Return {}", hookType = "return_empty_table"},
        {label = 'Return ""', hookType = "return_empty_string"},
        {label = "Block (no return)", hookType = "block"},
        {label = "Log & Passthrough", hookType = "log_passthrough"}
    }
    local yPos = 26
    for _, option in ipairs(hookOptions) do
        local btn = self:_createButton(menu, option.label, UDim2.new(1, -8, 0, 22), UDim2.fromOffset(4, yPos), function()
            self:CreateQuickHook(func, parentTable, key, option.hookType, nil)
            menu:Destroy()
        end)
        btn.ZIndex = 501
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        local btnPadding = Instance.new("UIPadding", btn)
        btnPadding.PaddingLeft = UDim.new(0, 4)
        yPos = yPos + 24
    end
    local customLabel = Instance.new("TextLabel", menu)
    customLabel.Size = UDim2.new(1, -8, 0, 16)
    customLabel.Position = UDim2.fromOffset(4, yPos)
    customLabel.BackgroundTransparency = 1
    customLabel.Text = "Custom Return Value:"
    customLabel.TextColor3 = self.Config.TEXT_BLACK
    customLabel.Font = Enum.Font.SourceSansBold
    customLabel.TextSize = 9
    customLabel.TextXAlignment = Enum.TextXAlignment.Left
    customLabel.ZIndex = 501
    yPos = yPos + 18
    local customInput = Instance.new("TextBox", menu)
    customInput.Size = UDim2.new(1, -48, 0, 22)
    customInput.Position = UDim2.fromOffset(4, yPos)
    customInput.BackgroundColor3 = self.Config.BG_WHITE
    customInput.PlaceholderText = "Enter value..."
    customInput.Text = ""
    customInput.TextColor3 = self.Config.TEXT_BLACK
    customInput.Font = Enum.Font.Code
    customInput.TextSize = 9
    customInput.TextXAlignment = Enum.TextXAlignment.Left
    customInput.BorderSizePixel = 0
    customInput.ClearTextOnFocus = false
    customInput.ZIndex = 501
    self:_createBorder(customInput, true)
    local customBtn = self:_createButton(menu, "OK", UDim2.fromOffset(38, 22), UDim2.new(1, -42, 0, yPos), function()
        local value = self:ParseValue(customInput.Text, "any")
        if value ~= nil then
            self:CreateQuickHook(func, parentTable, key, "custom", value)
            menu:Destroy()
        else
            self:_showNotification("Invalid value", "error")
        end
    end)
    customBtn.ZIndex = 501
    customBtn.TextSize = 9
    local closeDetector = Instance.new("TextButton", self.State.UI.Main)
    closeDetector.Size = UDim2.new(1, 0, 1, 0)
    closeDetector.BackgroundTransparency = 1
    closeDetector.Text = ""
    closeDetector.ZIndex = 499
    closeDetector.MouseButton1Click:Connect(function()
        menu:Destroy()
        closeDetector:Destroy()
    end)
    local dragging, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = menu.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            menu.Position = UDim2.fromOffset(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
function Modules.OverseerCE:ParseValue(text, expectedType)
    if expectedType == "string" or text:match('^".*"$') or text:match("^'.*'$") then
        return text:gsub('^["\']', ''):gsub('["\']$', '')
    elseif text == "true" then
        return true
    elseif text == "false" then
        return false
    elseif text == "nil" then
        return nil
    elseif text == "{}" then
        return {}
    elseif tonumber(text) then
        return tonumber(text)
    else
        if expectedType == "any" then
            return text
        end
        return nil
    end
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
    self:_showNotification("Patch removed", "success")
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
    title.Text = "Overseer CE 7.5 Enhanced - Module Inspector & Patcher"
    title.TextColor3 = self.Config.BG_WHITE
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = 3
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
    local resizeHandle = Instance.new("Frame", main)
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(16, 16)
    resizeHandle.Position = UDim2.new(1, -16, 1, -16)
    resizeHandle.BackgroundColor3 = self.Config.BG_DARK
    resizeHandle.BorderSizePixel = 0
    resizeHandle.ZIndex = 10
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
    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -4, 1, -28)
    content.Position = UDim2.fromOffset(2, 26)
    content.BackgroundColor3 = self.Config.BG_PANEL
    content.BorderSizePixel = 0
    local menuBar = Instance.new("Frame", content)
    menuBar.Size = UDim2.new(1, 0, 0, 22)
    menuBar.Position = UDim2.fromOffset(0, 0)
    menuBar.BackgroundColor3 = self.Config.BG_PANEL
    menuBar.BorderSizePixel = 0
    self:_createBorder(menuBar, false)
    local menuItems = {"Tools", "Scanner", "Dumper", "Injector", "Anti-Tamper", "Hooks", "Decompiler", "Poisons"}
    local menuX = 4
    for _, menuName in ipairs(menuItems) do
        local menuBtn = self:_createButton(menuBar, menuName, UDim2.fromOffset(75, 18), UDim2.fromOffset(menuX, 2), function()
            self:OpenToolWindow(menuName)
        end)
        menuBtn.TextSize = 10
        menuX = menuX + 77
    end
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
    moduleSearch.ClearTextOnFocus = false
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
    moduleScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self:_createBorder(moduleScroll, true)
    local moduleList = Instance.new("UIListLayout", moduleScroll)
    moduleList.Padding = UDim.new(0, 1)
    local inspectorPanel = self:_createPanel(content, UDim2.fromOffset(292, 26), UDim2.new(1, -596, 1, -30), "Table Inspector")
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
    local inspectorScroll = Instance.new("ScrollingFrame", inspectorPanel)
    inspectorScroll.Size = UDim2.new(1, -8, 1, -84)
    inspectorScroll.Position = UDim2.fromOffset(4, 76)
    inspectorScroll.BackgroundColor3 = self.Config.BG_WHITE
    inspectorScroll.BorderSizePixel = 0
    inspectorScroll.ScrollBarThickness = 12
    inspectorScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    inspectorScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    inspectorScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self:_createBorder(inspectorScroll, true)
    local inspectorList = Instance.new("UIListLayout", inspectorScroll)
    inspectorList.Padding = UDim.new(0, 0)
    local patchPanel = self:_createPanel(content, UDim2.new(1, -304, 0, 26), UDim2.new(0, 296, 1, -30), "Active Patches")
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
    local patchScroll = Instance.new("ScrollingFrame", patchPanel)
    patchScroll.Size = UDim2.new(1, -8, 1, -84)
    patchScroll.Position = UDim2.fromOffset(4, 76)
    patchScroll.BackgroundColor3 = self.Config.BG_WHITE
    patchScroll.BorderSizePixel = 0
    patchScroll.ScrollBarThickness = 12
    patchScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    patchScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    patchScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    self:_createBorder(patchScroll, true)
    local patchList = Instance.new("UIListLayout", patchScroll)
    patchList.Padding = UDim.new(0, 0)
    self.State.UI = {
        ScreenGui = screenGui,
        Main = main,
        ModuleScroll = moduleScroll,
        ModuleSearch = moduleSearch,
        InspectorScroll = inspectorScroll,
        PathLabel = pathLabel,
        PatchScroll = patchScroll,
        PatchCount = patchCount,
        ResizeHandle = resizeHandle,
        HookScroll = nil
    }
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
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    local searchDebounce = nil
    moduleSearch.Changed:Connect(function(property)
        if property == "Text" then
            if searchDebounce then
                task.cancel(searchDebounce)
            end
            searchDebounce = task.delay(0.3, function()
                self:FilterModules(moduleSearch.Text)
            end)
        end
    end)
function Modules.OverseerCE:CreateHookManagerPanel(parent)
    local panel = self:_createPanel(parent, UDim2.fromOffset(4, 4), UDim2.new(1, -8, 1, -8), "Hook Manager")
    panel.ZIndex = 100
    local info = Instance.new("TextLabel", panel)
    info.Size = UDim2.new(1, -8, 0, 32)
    info.Position = UDim2.fromOffset(4, 24)
    info.BackgroundColor3 = Color3.fromRGB(220, 240, 255)
    info.Text = "Active function hooks. Toggle enabled/disabled or remove hooks below."
    info.TextColor3 = self.Config.TEXT_BLACK
    info.Font = Enum.Font.SourceSans
    info.TextSize = 10
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.TextYAlignment = Enum.TextYAlignment.Top
    info.TextWrapped = true
    info.BorderSizePixel = 0
    info.ZIndex = 101
    local infoPadding = Instance.new("UIPadding", info)
    infoPadding.PaddingLeft = UDim.new(0, 4)
    infoPadding.PaddingTop = UDim.new(0, 4)
    self:_createBorder(info, true)
    local clearAllBtn = self:_createButton(panel, "Clear All Hooks", UDim2.fromOffset(120, 24), UDim2.fromOffset(4, 60), function()
        for hookId in pairs(self.State.HookedFunctions) do
            self:RemoveHook(hookId)
        end
        self:_showNotification("All hooks removed", "success")
    end)
    clearAllBtn.ZIndex = 101
    local headerFrame = Instance.new("Frame", panel)
    headerFrame.Size = UDim2.new(1, -8, 0, self.Config.ROW_HEIGHT)
    headerFrame.Position = UDim2.fromOffset(4, 88)
    headerFrame.BackgroundColor3 = self.Config.BG_DARK
    headerFrame.BorderSizePixel = 0
    headerFrame.ZIndex = 101
    self:_createBorder(headerFrame, true)
    local headers = {"On", "Function", "Hook Type", "Calls", "Remove"}
    local headerWidths = {0.08, 0.35, 0.35, 0.12, 0.1}
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
        header.ZIndex = 102
        local headerPadding = Instance.new("UIPadding", header)
        headerPadding.PaddingLeft = UDim.new(0, 4)
        xPos = xPos + headerWidths[i]
    end
    local hookScroll = Instance.new("ScrollingFrame", panel)
    hookScroll.Name = "HookScroll"
    hookScroll.Size = UDim2.new(1, -8, 1, -116)
    hookScroll.Position = UDim2.fromOffset(4, 108)
    hookScroll.BackgroundColor3 = self.Config.BG_WHITE
    hookScroll.BorderSizePixel = 0
    hookScroll.ScrollBarThickness = 12
    hookScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    hookScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    hookScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    hookScroll.ZIndex = 101
    self:_createBorder(hookScroll, true)
    local hookList = Instance.new("UIListLayout", hookScroll)
    hookList.Padding = UDim.new(0, 0)
    self.State.UI.HookScroll = hookScroll
    return panel
end
function Modules.OverseerCE:RefreshHookList()
    if not self.State.UI or not self.State.UI.HookScroll then return end
    for _, child in ipairs(self.State.UI.HookScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    for hookId, hook in pairs(self.State.HookedFunctions) do
        self:CreateHookRow(hookId, hook)
    end
end
function Modules.OverseerCE:CreateHookRow(hookId, hook)
    if not self.State.UI or not self.State.UI.HookScroll then return end
    local row = Instance.new("Frame", self.State.UI.HookScroll)
    row.Size = UDim2.new(1, -2, 0, self.Config.ROW_HEIGHT)
    row.BackgroundColor3 = hook.Enabled and self.Config.BG_WHITE or Color3.fromRGB(240, 240, 240)
    row.BorderSizePixel = 0
    row.ZIndex = 102
    local enabledBox = Instance.new("TextButton", row)
    enabledBox.Size = UDim2.fromOffset(12, 12)
    enabledBox.Position = UDim2.new(0.04, -6, 0.5, -6)
    enabledBox.BackgroundColor3 = self.Config.BG_WHITE
    enabledBox.Text = hook.Enabled and "✓" or ""
    enabledBox.TextColor3 = self.Config.SUCCESS_GREEN
    enabledBox.Font = Enum.Font.SourceSansBold
    enabledBox.TextSize = 10
    enabledBox.BorderSizePixel = 0
    enabledBox.AutoButtonColor = false
    enabledBox.ZIndex = 103
    self:_createBorder(enabledBox, true)
    enabledBox.MouseButton1Click:Connect(function()
        self:ToggleHook(hookId)
    end)
    local funcLabel = Instance.new("TextLabel", row)
    funcLabel.Size = UDim2.new(0.35, -4, 1, 0)
    funcLabel.Position = UDim2.new(0.08, 2, 0, 0)
    funcLabel.BackgroundTransparency = 1
    funcLabel.Text = tostring(hook.Key)
    funcLabel.TextColor3 = self.Config.TEXT_BLACK
    funcLabel.Font = Enum.Font.Code
    funcLabel.TextSize = 10
    funcLabel.TextXAlignment = Enum.TextXAlignment.Left
    funcLabel.TextTruncate = Enum.TextTruncate.AtEnd
    funcLabel.ZIndex = 103
    local hookTypeLabel = Instance.new("TextLabel", row)
    hookTypeLabel.Size = UDim2.new(0.35, -4, 1, 0)
    hookTypeLabel.Position = UDim2.new(0.43, 2, 0, 0)
    hookTypeLabel.BackgroundTransparency = 1
    hookTypeLabel.Text = self:GetHookTypeName(hook.HookType, hook.CustomValue)
    hookTypeLabel.TextColor3 = Color3.fromRGB(0, 100, 200)
    hookTypeLabel.Font = Enum.Font.SourceSans
    hookTypeLabel.TextSize = 9
    hookTypeLabel.TextXAlignment = Enum.TextXAlignment.Left
    hookTypeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    hookTypeLabel.ZIndex = 103
    local callLabel = Instance.new("TextLabel", row)
    callLabel.Size = UDim2.new(0.12, -4, 1, 0)
    callLabel.Position = UDim2.new(0.78, 2, 0, 0)
    callLabel.BackgroundTransparency = 1
    callLabel.Text = tostring(hook.CallCount or 0)
    callLabel.TextColor3 = self.Config.TEXT_GRAY
    callLabel.Font = Enum.Font.SourceSans
    callLabel.TextSize = 9
    callLabel.TextXAlignment = Enum.TextXAlignment.Center
    callLabel.ZIndex = 103
    local removeBtn = self:_createButton(row, "×", UDim2.fromOffset(16, 16), UDim2.new(0.90, 2, 0.5, -8), function()
        self:RemoveHook(hookId)
    end)
    removeBtn.ZIndex = 103
    removeBtn.TextSize = 12
    row.MouseEnter:Connect(function()
        row.BackgroundColor3 = Color3.fromRGB(230, 240, 255)
    end)
    row.MouseLeave:Connect(function()
        row.BackgroundColor3 = hook.Enabled and self.Config.BG_WHITE or Color3.fromRGB(240, 240, 240)
    end)
end
    self:ScanModules()
end
function Modules.OverseerCE:ScanModules()
    if not self.State.UI then return end
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
        self:_showNotification("Scanned " .. #self.State.ModuleList .. " modules", "success")
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
        for _, child in ipairs(self.State.UI.ModuleScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = self.Config.BG_WHITE
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
    local success, result
    local completed = false
    task.spawn(function()
        success, result = pcall(function()
            return require(moduleScript)
        end)
        completed = true
    end)
    local timeout = 2
    local elapsed = 0
    while not completed and elapsed < timeout do
        task.wait(0.1)
        elapsed = elapsed + 0.1
    end
    if not completed then
        self:_showNotification("Module load timeout: " .. moduleScript.Name .. " (may use WaitForChild)", "warning")
        print("[Overseer CE] Module took too long to load:", moduleScript.Name)
        return
    end
    if not success then
        self:_showNotification("Failed to load module: " .. moduleScript.Name, "error")
        print("[Overseer CE] Module load error:", result)
        return
    end
    if result == nil then
        self:_showNotification("Module returned nil: " .. moduleScript.Name, "warning")
        result = {
            ["[Module Name]"] = moduleScript.Name,
            ["[Return Value]"] = "nil",
            ["[Info]"] = "This module doesn't return a value"
        }
    end
    local moduleContent = self:GetModuleContent(result)
    if type(moduleContent) ~= "table" then
        self:_showNotification("Module could not be displayed as table", "warning")
        return
    end
    self.State.SelectedModule = moduleScript
    self.State.CurrentTable = moduleContent
    self.State.PathStack = {}
    self.State.VisitedTables = {}
    self:RefreshInspector()
    local originalType = type(result)
    if originalType == "nil" then
        self:_showNotification("Loaded: " .. moduleScript.Name .. " [returns nil]", "info")
    elseif originalType ~= "table" then
        self:_showNotification("Loaded: " .. moduleScript.Name .. " [" .. originalType .. " → table wrapper]", "success")
    else
        self:_showNotification("Loaded: " .. moduleScript.Name, "success")
    end
end
function Modules.OverseerCE:RefreshInspector()
    if not self.State.UI or not self.State.CurrentTable then return end
    for _, child in ipairs(self.State.UI.InspectorScroll:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    local pathText = "Root"
    if #self.State.PathStack > 0 then
        pathText = table.concat(self.State.PathStack, " > ")
    end
    self.State.UI.PathLabel.Text = pathText
    self:PopulateTable(self.State.CurrentTable)
    local chain = self:AnalyzeMetatableChain(self.State.CurrentTable)
    self.State.MetatableChain = chain
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
    local displayValue = self:GetDisplayValue(value, key)
    local row = Instance.new("Frame", self.State.UI.InspectorScroll)
    row.Size = UDim2.new(1, -2, 0, self.Config.ROW_HEIGHT)
    row.BackgroundColor3 = isMetatable and self.Config.BG_LIGHT or self.Config.BG_WHITE
    row.BorderSizePixel = 0
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
    local activeBox = Instance.new("TextButton", row)
    activeBox.Size = UDim2.fromOffset(12, 12)
    activeBox.Position = UDim2.new(0.04, -6, 0.5, -6)
    activeBox.BackgroundColor3 = self.Config.BG_WHITE
    activeBox.Text = isPatched and "X" or ""
    activeBox.TextColor3 = self.Config.TEXT_BLACK
    activeBox.Font = Enum.Font.SourceSansBold
    activeBox.TextSize = 10
    activeBox.BorderSizePixel = 0
    activeBox.AutoButtonColor = false
    self:_createBorder(activeBox, true)
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
    local typeLabel = Instance.new("TextLabel", row)
    typeLabel.Size = UDim2.new(0.12, -4, 1, 0)
    typeLabel.Position = UDim2.new(0.33, 2, 0, 0)
    typeLabel.BackgroundTransparency = 1
    typeLabel.Text = valueType
    typeLabel.TextColor3 = self.Config.TEXT_GRAY
    typeLabel.Font = Enum.Font.SourceSans
    typeLabel.TextSize = 9
    typeLabel.TextXAlignment = Enum.TextXAlignment.Left
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
    local patchBtn = self:_createButton(row, "Patch", UDim2.fromOffset(45, 16), UDim2.new(0.80, 2, 0.5, -8), function()
        if valueType == "table" then
            self:DrillDown(key, value)
        elseif valueType == "function" then
            self:ShowFunctionInfo(key, value, parentTable)
        else
            local newVal = self:ParseValue(valueBox.Text, valueType)
            if newVal ~= nil then
                self:CreatePatch(parentTable, key, newVal, false)
            else
                self:_showNotification("Invalid value for type: " .. valueType, "error")
            end
        end
    end)
    patchBtn.TextSize = 9
    local freezeBtn = self:_createButton(row, "Freeze", UDim2.fromOffset(45, 16), UDim2.new(0.88, 2, 0.5, -8), function()
        local newVal = self:ParseValue(valueBox.Text, valueType)
        if newVal ~= nil then
            local patchId = self:CreatePatch(parentTable, key, newVal, true)
        else
            self:_showNotification("Invalid value for type: " .. valueType, "error")
        end
    end)
    freezeBtn.TextSize = 9
    if valueType == "table" then
        patchBtn.Text = "Dive"
    elseif valueType == "function" then
        patchBtn.Text = "Hook"
    end
    valueBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and valueType ~= "table" and valueType ~= "function" then
            local newVal = self:ParseValue(valueBox.Text, valueType)
            if newVal ~= nil then
                self:CreatePatch(parentTable, key, newVal, false)
            else
                self:_showNotification("Invalid value for type: " .. valueType, "error")
            end
        end
    end)
end
function Modules.OverseerCE:DisplayMetatableChain(chain)
    if not self.State.UI or not chain or #chain == 0 then return end
    for i, entry in ipairs(chain) do
        local separator = Instance.new("Frame", self.State.UI.InspectorScroll)
        separator.Size = UDim2.new(1, -2, 0, self.Config.ROW_HEIGHT)
        separator.BackgroundColor3 = entry.Locked and Color3.fromRGB(200, 100, 100) or self.Config.ACCENT_BLUE
        separator.BorderSizePixel = 0
        local lockIcon = entry.Locked and "🔒 " or "🔓 "
        local statusText = entry.Locked and " [LOCKED]" or " [Unlocked]"
        local sepLabel = Instance.new("TextLabel", separator)
        sepLabel.Size = UDim2.new(1, -8, 1, 0)
        sepLabel.Position = UDim2.fromOffset(4, 0)
        sepLabel.BackgroundTransparency = 1
        sepLabel.Text = lockIcon .. "METATABLE #" .. i .. " (Depth: " .. entry.Depth .. ")" .. statusText
        sepLabel.TextColor3 = self.Config.BG_WHITE
        sepLabel.Font = Enum.Font.SourceSansBold
        sepLabel.TextSize = 10
        sepLabel.TextXAlignment = Enum.TextXAlignment.Left
        if entry.AccessMethod or entry.UnlockMessage then
            local infoRow = Instance.new("Frame", self.State.UI.InspectorScroll)
            infoRow.Size = UDim2.new(1, -2, 0, self.Config.ROW_HEIGHT)
            infoRow.BackgroundColor3 = Color3.fromRGB(240, 240, 200)
            infoRow.BorderSizePixel = 0
            local infoLabel = Instance.new("TextLabel", infoRow)
            infoLabel.Size = UDim2.new(1, -8, 1, 0)
            infoLabel.Position = UDim2.fromOffset(4, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Text = "  ℹ️ " .. (entry.UnlockMessage or ("Access: " .. entry.AccessMethod))
            infoLabel.TextColor3 = Color3.fromRGB(100, 100, 0)
            infoLabel.Font = Enum.Font.SourceSansItalic
            infoLabel.TextSize = 9
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        end
        for _, field in ipairs(entry.Fields) do
            self:CreateInspectorRow(field.Key, field.Value, entry.Metatable, true)
        end
    end
end
function Modules.OverseerCE:RefreshPatchList()
    if not self.State.UI then return end
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
    local freezeBox = Instance.new("TextButton", row)
    freezeBox.Size = UDim2.fromOffset(12, 12)
    freezeBox.Position = UDim2.new(0.075, -6, 0.5, -6)
    freezeBox.BackgroundColor3 = self.Config.BG_WHITE
    freezeBox.Text = patch.Frozen and "X" or ""
    freezeBox.TextColor3 = self.Config.FROZEN_RED
    freezeBox.Font = Enum.Font.SourceSansBold
    freezeBox.TextSize = 10
    freezeBox.BorderSizePixel = 0
    freezeBox.AutoButtonColor = false
    self:_createBorder(freezeBox, true)
    freezeBox.MouseButton1Click:Connect(function()
        self:ToggleFreeze(patchId)
    end)
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
    local delBtn = self:_createButton(row, "X", UDim2.fromOffset(16, 16), UDim2.new(0.88, 0, 0.5, -8), function()
        self:RemovePatch(patchId)
    end)
    delBtn.TextSize = 10
    delBtn.Font = Enum.Font.SourceSansBold
    delBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 200)
end
function Modules.OverseerCE:DrillDown(name, tbl)
    if type(tbl) ~= "table" then return end
    table.insert(self.State.PathStack, tostring(name))
    self.State.CurrentTable = tbl
    self.State.VisitedTables = {}
    self:RefreshInspector()
end
function Modules.OverseerCE:GoBack()
    if #self.State.PathStack == 0 then return end
    table.remove(self.State.PathStack)
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
        local num = tonumber(text)
        return num
    elseif targetType == "boolean" then
        return text:lower() == "true"
    elseif targetType == "string" then
        return text:match('^"(.*)"$') or text
    end
    return text
end
function Modules.OverseerCE:ShowFunctionInfo(key, func, parentTable)
    self:ShowQuickHookMenu(func, parentTable, key)
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
    if self.State.UI and self.State.UI.ScreenGui then
        for _, child in ipairs(self.State.UI.ScreenGui:GetChildren()) do
            if child.Name:match("Window$") and child ~= self.State.UI.Main then
                child:Destroy()
            end
        end
    end
    local popup = Instance.new("Frame", self.State.UI.ScreenGui)
    popup.Name = toolName .. "Window"
    popup.Size = UDim2.fromOffset(500, 400)
    popup.Position = UDim2.new(0.5, -250, 0.5, -200)
    popup.BackgroundColor3 = self.Config.BG_PANEL
    popup.BorderSizePixel = 0
    popup.ZIndex = 100
    self:_createBorder(popup, false)
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
    local contentArea = Instance.new("Frame", popup)
    contentArea.Size = UDim2.new(1, -8, 1, -32)
    contentArea.Position = UDim2.fromOffset(4, 28)
    contentArea.BackgroundColor3 = self.Config.BG_PANEL
    contentArea.BorderSizePixel = 0
    contentArea.ZIndex = 100
    if toolName == "Scanner" then
        self:CreateScannerUI(contentArea)
    elseif toolName == "Dumper" then
        self:CreateDumperUI(contentArea)
    elseif toolName == "Injector" then
        self:CreateInjectorUI(contentArea)
    elseif toolName == "Anti-Tamper" then
        self:CreateAntiTamperUI(contentArea)
    elseif toolName == "Hooks" then
        self:CreateHookManagerPanel(contentArea)
    elseif toolName == "Decompiler" then
        self:CreateDecompilerPanel(contentArea)
    elseif toolName == "Tools" then
        self:CreateToolsMenuUI(contentArea)
	elseif toolname == "Posions" then
		self:CreatePoisonMenuUI(ContentArea)					
    end
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
    searchBox.ClearTextOnFocus = false
    local searchPadding = Instance.new("UIPadding", searchBox)
    searchPadding.PaddingLeft = UDim.new(0, 4)
    self:_createBorder(searchBox, true)
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
    typeDropdown.AutoButtonColor = false
    self:_createBorder(typeDropdown, true)
    local selectedType = "any"
    local types = {"any", "string", "number", "boolean", "table", "function"}
    local typeIndex = 1
    typeDropdown.MouseButton1Click:Connect(function()
        typeIndex = (typeIndex % #types) + 1
        selectedType = types[typeIndex]
        typeDropdown.Text = selectedType
    end)
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
    exactCheckbox.AutoButtonColor = false
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
    local header = Instance.new("TextLabel", parent)
    header.Name = "ResultsHeader"
    header.Size = UDim2.new(1, -8, 0, 20)
    header.Position = UDim2.fromOffset(4, 66)
    header.BackgroundColor3 = self.Config.BG_DARK
    header.Text = "Results: 0"
    header.TextColor3 = self.Config.TEXT_BLACK
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 11
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.BorderSizePixel = 0
    header.ZIndex = 101
    local headerPadding = Instance.new("UIPadding", header)
    headerPadding.PaddingLeft = UDim.new(0, 4)
    self:_createBorder(header, true)
    local resultsScroll = Instance.new("ScrollingFrame", parent)
    resultsScroll.Name = "ResultsScroll"
    resultsScroll.Size = UDim2.new(1, -8, 1, -120)
    resultsScroll.Position = UDim2.fromOffset(4, 88)
    resultsScroll.BackgroundColor3 = self.Config.BG_WHITE
    resultsScroll.BorderSizePixel = 0
    resultsScroll.ScrollBarThickness = 12
    resultsScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    resultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    resultsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    resultsScroll.ZIndex = 101
    self:_createBorder(resultsScroll, true)
    local resultsList = Instance.new("UIListLayout", resultsScroll)
    resultsList.Padding = UDim.new(0, 1)
    local scanBtn = self:_createButton(parent, "Scan All Modules", UDim2.fromOffset(120, 24), UDim2.fromOffset(4, 58), function()
        local searchValue = searchBox.Text
        if searchValue == "" then
            self:_showNotification("Please enter a search value", "warning")
            return
        end
        if selectedType == "number" then
            searchValue = tonumber(searchValue)
            if not searchValue then
                self:_showNotification("Invalid number format", "error")
                return
            end
        elseif selectedType == "boolean" then
            searchValue = searchBox.Text:lower() == "true"
        end
        self:_showNotification("Scanning modules...", "info")
        task.spawn(function()
            local results = self:ScanForConstant(searchValue, selectedType, exactMatch)
            for _, child in ipairs(resultsScroll:GetChildren()) do
                if not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
            header.Text = "Results: " .. #results
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
                    print("[Scanner] Selected:", result.Path)
                    self:_setClipboard(result.Path)
                    self:_showNotification("Path copied to clipboard", "success")
                end)
                resultRow.MouseEnter:Connect(function()
                    resultRow.BackgroundColor3 = self.Config.BG_LIGHT
                end)
                resultRow.MouseLeave:Connect(function()
                    resultRow.BackgroundColor3 = self.Config.BG_WHITE
                end)
            end
            self:_showNotification("Scan complete: " .. #results .. " results", "success")
        end)
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
    mtCheckbox.AutoButtonColor = false
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
    funcCheckbox.AutoButtonColor = false
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
    depthBox.ClearTextOnFocus = false
    self:_createBorder(depthBox, true)
    depthBox.FocusLost:Connect(function()
        local num = tonumber(depthBox.Text)
        if num then
            maxDepth = math.clamp(num, 1, 20)
            depthBox.Text = tostring(maxDepth)
        else
            depthBox.Text = "10"
            maxDepth = 10
        end
    end)
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
    local dumpSelectedBtn = self:_createButton(parent, "Dump Selected Module", UDim2.fromOffset(150, 24), UDim2.fromOffset(4, 122), function()
        if not self.State.SelectedModule then
            self:_showNotification("No module selected", "warning")
            statusLabel.Text = "ERROR: No module selected.\nPlease select a module from the module list first."
            return
        end
        statusLabel.Text = "Dumping module: " .. self.State.SelectedModule.Name .. "\nPlease wait..."
        task.spawn(function()
            local result = self:DumpModule(self.State.SelectedModule, includeMetatables, includeFunctions, maxDepth)
            if result.Success then
                self:ExportDump(result.Dump)
                statusLabel.Text = "SUCCESS!\nExported: " .. self.State.SelectedModule.Name .. "\nCopied to clipboard."
            else
                self:_showNotification("Dump failed: " .. result.Error, "error")
                statusLabel.Text = "ERROR: " .. result.Error
            end
        end)
    end)
    dumpSelectedBtn.ZIndex = 101
    dumpSelectedBtn.TextSize = 10
    local dumpAllBtn = self:_createButton(parent, "Dump All Modules", UDim2.fromOffset(150, 24), UDim2.fromOffset(158, 122), function()
        statusLabel.Text = "Dumping all modules...\nThis may take a while..."
        task.spawn(function()
            local result = self:DumpAllModules()
            if result.Success then
                self:ExportDump(result)
                statusLabel.Text = "SUCCESS!\nExported " .. result.TotalModules .. " modules\nCopied to clipboard."
            else
                self:_showNotification("Dump failed", "error")
                statusLabel.Text = "ERROR: Failed to dump modules."
            end
        end)
    end)
    dumpAllBtn.ZIndex = 101
    dumpAllBtn.TextSize = 10
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
    local codeScroll = Instance.new("ScrollingFrame", parent)
    codeScroll.Size = UDim2.new(1, -8, 1, -80)
    codeScroll.Position = UDim2.fromOffset(4, 38)
    codeScroll.BackgroundColor3 = self.Config.BG_WHITE
    codeScroll.BorderSizePixel = 0
    codeScroll.ScrollBarThickness = 12
    codeScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    codeScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
    codeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
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
    local btnContainer = Instance.new("Frame", parent)
    btnContainer.Size = UDim2.new(1, -8, 0, 28)
    btnContainer.Position = UDim2.new(0, 4, 1, -32)
    btnContainer.BackgroundTransparency = 1
    btnContainer.ZIndex = 101
    local executeBtn = self:_createButton(btnContainer, "Execute", UDim2.fromOffset(100, 24), UDim2.fromOffset(0, 0), function()
        local code = codeBox.Text
        if code == "" or code == "-- Enter code here\nprint('Injected!')\nreturn true" then
            self:_showNotification("Please enter code to execute", "warning")
            return
        end
        local targetModule = self.State.SelectedModule
        local result = self:InjectCode(code, targetModule, true)
        if result.Success then
            self:_showNotification("Code executed successfully!", "success")
            print("[Injector] Success! Result:", unpack(result.Result or {}))
        else
            self:_showNotification("Execution failed: " .. (result.Error or "Unknown error"), "error")
            warn("[Injector] Error:", result.Error)
        end
    end)
    executeBtn.ZIndex = 101
    executeBtn.TextSize = 10
    local clearBtn = self:_createButton(btnContainer, "Clear", UDim2.fromOffset(80, 24), UDim2.fromOffset(104, 0), function()
        codeBox.Text = "-- Enter code here\n"
    end)
    clearBtn.ZIndex = 101
    clearBtn.TextSize = 10
    local templateBtn = self:_createButton(btnContainer, "Load Template", UDim2.fromOffset(100, 24), UDim2.fromOffset(188, 0), function()
        codeBox.Text = [[
print("Current module:", self.State.SelectedModule.Name)
if moduleTable then
    for k, v in pairs(moduleTable) do
        print(k, "=", v)
    end
end
return "Template loaded"]]
    end)
    templateBtn.ZIndex = 101
    templateBtn.TextSize = 10
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
    local statusLabel = Instance.new("TextLabel", parent)
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(1, -8, 0, 30)
    statusLabel.Position = UDim2.fromOffset(4, 60)
    statusLabel.BackgroundColor3 = self.State.AntiTamperActive and Color3.fromRGB(220, 255, 220) or Color3.fromRGB(255, 220, 220)
    statusLabel.Text = self.State.AntiTamperActive and "Status: ACTIVE ✓" or "Status: INACTIVE ✗"
    statusLabel.TextColor3 = self.Config.TEXT_BLACK
    statusLabel.Font = Enum.Font.SourceSansBold
    statusLabel.TextSize = 12
    statusLabel.BorderSizePixel = 0
    statusLabel.ZIndex = 101
    self:_createBorder(statusLabel, true)
    local toggleBtn = self:_createButton(parent, self.State.AntiTamperActive and "Disable Protection" or "Enable Protection", UDim2.fromOffset(150, 28), UDim2.fromOffset(4, 96), function()
        if self.State.AntiTamperActive then
            self:DisableAntiTamper()
            toggleBtn.Text = "Enable Protection"
            statusLabel.Text = "Status: INACTIVE ✗"
            statusLabel.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
            self:_showNotification("Anti-tamper disabled", "info")
        else
            self:EnableAntiTamper()
            toggleBtn.Text = "Disable Protection"
            statusLabel.Text = "Status: ACTIVE ✓"
            statusLabel.BackgroundColor3 = Color3.fromRGB(220, 255, 220)
            self:_showNotification("Anti-tamper enabled", "success")
        end
    end)
    toggleBtn.ZIndex = 101
    toggleBtn.TextSize = 11
    local detectBtn = self:_createButton(parent, "Scan for Anti-Cheat", UDim2.fromOffset(150, 28), UDim2.fromOffset(158, 96), function()
        self:_showNotification("Scanning for anti-cheat...", "info")
        task.spawn(function()
            local result = self:DetectAntiCheat()
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
            detectionScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
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
            local detectedCount = 0
            for _, d in ipairs(result.Detections) do
                if d.Detected then detectedCount = detectedCount + 1 end
            end
            self:_showNotification("Scan complete: " .. detectedCount .. " detections", detectedCount > 0 and "warning" or "success")
        end)
    end)
    detectBtn.ZIndex = 101
    detectBtn.TextSize = 11
end
function Modules.OverseerCE:CreatePoisonMenuUI(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, -8, 0, 24)
    title.Position = UDim2.fromOffset(4, 4)
    title.BackgroundTransparency = 1
    title.Text = "⚠ Poison System Manager"
    title.TextColor3 = self.Config.POISON_PURPLE or Color3.fromRGB(138, 43, 226)
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 101
    local statsFrame = Instance.new("Frame", parent)
    statsFrame.Size = UDim2.new(1, -8, 0, 60)
    statsFrame.Position = UDim2.fromOffset(4, 32)
    statsFrame.BackgroundColor3 = self.Config.BG_PANEL
    statsFrame.BorderSizePixel = 0
    statsFrame.ZIndex = 101
    self:_createBorder(statsFrame, true)
    local function updateStats()
        local stats = self:GetPoisonStats()
        local statsText = string.format([[Active Poisons: %d / %d Total
By Type:]], stats.Active, stats.Total)
        local typeList = {}
        for pType, count in pairs(stats.ByType) do
            table.insert(typeList, string.format("  • %s: %d", pType, count))
        end
        if #typeList > 0 then
            statsText = statsText .. "\n" .. table.concat(typeList, "\n")
        end
        local statsLabel = statsFrame:FindFirstChild("StatsLabel")
        if not statsLabel then
            statsLabel = Instance.new("TextLabel", statsFrame)
            statsLabel.Name = "StatsLabel"
            statsLabel.Size = UDim2.new(1, -8, 1, -8)
            statsLabel.Position = UDim2.fromOffset(4, 4)
            statsLabel.BackgroundTransparency = 1
            statsLabel.TextColor3 = self.Config.TEXT_BLACK
            statsLabel.Font = Enum.Font.SourceSans
            statsLabel.TextSize = 10
            statsLabel.TextXAlignment = Enum.TextXAlignment.Left
            statsLabel.TextYAlignment = Enum.TextYAlignment.Top
            statsLabel.ZIndex = 102
        end
        statsLabel.Text = statsText
    end
    updateStats()
    local clearBtn = self:_createButton(parent, "Clear All Poisons", UDim2.fromOffset(150, 24), UDim2.fromOffset(4, 96), function()
        local count = self:ClearAllPoisons()
        updateStats()
        self:_showNotification(string.format("Cleared %d poisons", count), "success")
    end)
    clearBtn.ZIndex = 101
    local infoLabel = Instance.new("TextLabel", parent)
    infoLabel.Size = UDim2.new(1, -8, 1, -130)
    infoLabel.Position = UDim2.fromOffset(4, 124)
    infoLabel.BackgroundColor3 = self.Config.BG_WHITE
    infoLabel.Text = [[POISON SYSTEM READY
Use console to apply poisons:
Examples:
  Modules.OverseerCE:PoisonTableHijack(module, {key = value})
  Modules.OverseerCE.PoisonTemplates.AdminPoison(Modules.OverseerCE, module)
See PoisonExamples.lua for full documentation.
All 15 poison types are available!]]
    infoLabel.TextColor3 = self.Config.TEXT_BLACK
    infoLabel.Font = Enum.Font.Code
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.ZIndex = 101
    self:_createBorder(infoLabel, true)
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
• Supports string, number, boolean, table, and function searches
• Exact match or fuzzy matching
• Deep recursive scanning through metatables
• Click results to copy path to clipboard
Dumper: Export module structures to JSON
• Complete memory dumps with metatables
• Function information and upvalue detection
• Configurable depth for large modules
• Results automatically copied to clipboard
Injector: Execute code with module context
• Full access to module environments
• Upvalue modification support
• Injection history tracking
• Template code available for quick start
Anti-Tamper: Hide modifications from detection
• Hooks getmetatable/setmetatable
• Spoofs type checking functions
• Protects frozen patches from overwrites
• Anti-cheat pattern detection & scanning
Hooks: Quick function hooking system
• Hook functions to return custom values
• Block function execution
• Log and passthrough for debugging
• Enable/disable hooks without removing them
Decompiler: Advanced function analysis & patching
• Decompile functions to view source code
• Inspect constants, upvalues, and nested functions
• Patch function return values
• Modify upvalues and constants
• Track function calls with arguments
• Replace entire closures
• Export complete function information
Metatable Unlocking: Automatic bypass for locked metatables
! Locked metatables are shown in RED
! Unlocked metatables are shown in BLUE
• Automatically uses getrawmetatable when available
• Tries multiple unlock methods (setrawmetatable, etc.)
• Even locked metatables are readable via enhanced access
• Shows access method used for each metatable
Tips:
• Use the scanner to find specific values before patching
• Export dumps for offline reverse engineering
• Enable anti-tamper before applying critical patches
• Frozen patches are automatically refreshed every frame
• Locked metatables can still be viewed and patched!
• Use Decompiler for advanced function-level modifications
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
            Frozen = patch.Frozen,
            Timestamp = patch.Timestamp
        })
    end
    if #export == 0 then
        self:_showNotification("No patches to export", "warning")
        return
    end
    local success, exportText = pcall(function()
        return game:GetService("HttpService"):JSONEncode(export)
    end)
    if success then
        local copied = self:_setClipboard(exportText)
        if copied then
            self:_showNotification("Exported " .. #export .. " patches to clipboard", "success")
        else
            self:_showNotification("Failed to copy to clipboard", "error")
        end
    else
        self:_showNotification("JSON encoding failed", "error")
    end
end
function Modules.OverseerCE:Initialize()
    local module = self
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
    print("[Overseer CE] Initializing Enhanced Edition...")
    self:CreateUI()
    print("[Overseer CE] Ready! Module inspector and patcher active.")
    self:_showNotification("Overseer CE Enhanced initialized!", "success")
end
function Modules.OverseerCE:PoisonReturnOverride(module, newValue)
    local success, moduleRef = pcall(function()
        return typeof(module) == "Instance" and require(module) or module
    end)
    if not success then
        return false, "Failed to load module: " .. tostring(moduleRef)
    end
    local poisonId = #self.State.ActivePoisons + 1
    local originalModule = moduleRef
    local poisonedFunc = function(...)
        return newValue
    end
    local poisonData = {
        Id = poisonId,
        Type = "ReturnOverride",
        Target = module,
        OriginalModule = originalModule,
        NewValue = newValue,
        PoisonedFunction = poisonedFunc,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    table.insert(self.State.PoisonHistory, {
        Type = "ReturnOverride",
        Target = tostring(module),
        Timestamp = os.time()
    })
    return true, poisonId, poisonedFunc
end
function Modules.OverseerCE:PoisonTableHijack(moduleTable, overrides)
    if type(moduleTable) ~= "table" then
        return false, "Target must be a table"
    end
    local mt = self:GetRawMetatable(moduleTable) or {}
    local oldIndex = mt.__index
    local oldNewIndex = mt.__newindex
    local originalMT = {
        __index = oldIndex,
        __newindex = oldNewIndex
    }
    local hijackedMT = {
        __index = function(t, k)
            if overrides[k] ~= nil then
                return overrides[k]
            end
            if type(oldIndex) == "function" then
                return oldIndex(t, k)
            elseif type(oldIndex) == "table" then
                return oldIndex[k]
            end
            return rawget(t, k)
        end,
        __newindex = function(t, k, v)
            if overrides.Protect and overrides.Protect[k] then
                return
            end
            if type(oldNewIndex) == "function" then
                return oldNewIndex(t, k, v)
            end
            return rawset(t, k, v)
        end,
        __metatable = "Locked"
    }
    local applySuccess = pcall(function()
        if setrawmetatable then
            setrawmetatable(moduleTable, hijackedMT)
        elseif setreadonly then
            setreadonly(moduleTable, false)
            setmetatable(moduleTable, hijackedMT)
            setreadonly(moduleTable, true)
        else
            setmetatable(moduleTable, hijackedMT)
        end
    end)
    if not applySuccess then
        return false, "Failed to apply metatable hijack"
    end
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "TableHijack",
        Target = moduleTable,
        Overrides = overrides,
        OriginalMetatable = originalMT,
        HijackedMetatable = hijackedMT,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    return true, poisonData.Id
end
function Modules.OverseerCE:PoisonFunctionWrapper(func, wrapper)
    if type(func) ~= "function" then
        return false, "Target must be a function"
    end
    if type(wrapper) ~= "function" then
        return false, "Wrapper must be a function"
    end
    local wrappedFunc = function(...)
        local args = {...}
        local results = {wrapper(func, args)}
        return unpack(results)
    end
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "FunctionWrapper",
        OriginalFunction = func,
        Wrapper = wrapper,
        WrappedFunction = wrappedFunc,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    return true, poisonData.Id, wrappedFunc
end
function Modules.OverseerCE:PoisonConstantPatch(func, constantMap)
    if type(func) ~= "function" then
        return false, "Target must be a function"
    end
    if not getconstants then
        return false, "getconstants not available in executor"
    end
    if not setconstant then
        return false, "setconstant not available in executor"
    end
    local success, constants = pcall(getconstants, func)
    if not success then
        return false, "Failed to get constants"
    end
    local patchedConstants = {}
    for oldValue, newValue in pairs(constantMap) do
        for i, const in ipairs(constants) do
            if const == oldValue then
                local patchSuccess = pcall(setconstant, func, i, newValue)
                if patchSuccess then
                    table.insert(patchedConstants, {
                        Index = i,
                        Old = oldValue,
                        New = newValue
                    })
                end
            end
        end
    end
    if #patchedConstants == 0 then
        return false, "No constants matched for patching"
    end
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "ConstantPatch",
        TargetFunction = func,
        ConstantMap = constantMap,
        PatchedConstants = patchedConstants,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    table.insert(self.State.ConstantPatches, poisonData)
    return true, poisonData.Id, patchedConstants
end
function Modules.OverseerCE:PoisonUpvalueInject(func, upvalueIndex, newValue)
    if type(func) ~= "function" then
        return false, "Target must be a function"
    end
    if not setupvalue then
        return false, "setupvalue not available in executor"
    end
    if not getupvalue then
        return false, "getupvalue not available in executor"
    end
    local success, originalValue = pcall(getupvalue, func, upvalueIndex)
    if not success then
        return false, "Failed to get upvalue at index " .. upvalueIndex
    end
    local setSuccess = pcall(setupvalue, func, upvalueIndex, newValue)
    if not setSuccess then
        return false, "Failed to set upvalue"
    end
    local poisonData = {
        Id = #self.State.ActivePoisons + 1,
        Type = "UpvalueInject",
        TargetFunction = func,
        UpvalueIndex = upvalueIndex,
        OriginalValue = originalValue,
        NewValue = newValue,
        Timestamp = os.time(),
        Active = true
    }
    table.insert(self.State.ActivePoisons, poisonData)
    table.insert(self.State.UpvalueMonitors, poisonData)
    return true, poisonData.Id
end
function Modules.OverseerCE:GetPoisonStats()
    local stats = {
        Total = #self.State.ActivePoisons,
        Active = 0,
        ByType = {}
    }
    for _, poison in pairs(self.State.ActivePoisons) do
        if poison.Active then
            stats.Active = stats.Active + 1
            stats.ByType[poison.Type] = (stats.ByType[poison.Type] or 0) + 1
        end
    end
    return stats
end
function Modules.OverseerCE:RemovePoison(poisonId)
    local poison = self.State.ActivePoisons[poisonId]
    if not poison then
        return false, "Poison not found"
    end
    if poison.Type == "TableHijack" and poison.OriginalMetatable then
        pcall(function()
            if setrawmetatable then
                setrawmetatable(poison.Target, poison.OriginalMetatable)
            else
                setmetatable(poison.Target, poison.OriginalMetatable)
            end
        end)
    elseif poison.Type == "UpvalueInject" and poison.OriginalValue then
        pcall(setupvalue, poison.TargetFunction, poison.UpvalueIndex, poison.OriginalValue)
    elseif poison.Type == "RequireHook" and poison.OriginalRequire then
        _G.require = poison.OriginalRequire
    elseif poison.Type == "SelfHeal" and poison.SelfHealConnection then
        poison.SelfHealConnection:Disconnect()
    end
    poison.Active = false
    return true, "Poison removed"
end
function Modules.OverseerCE:ClearAllPoisons()
    local count = 0
    for id, poison in pairs(self.State.ActivePoisons) do
        if poison.Active then
            self:RemovePoison(id)
            count = count + 1
        end
    end
    self.State.ActivePoisons = {}
    self.State.RequireHooks = {}
    self.State.CoroutineHijacks = {}
    self.State.MetatableTraps = {}
    self.State.CascadeTriggers = {}
    return count
end
function Modules.OverseerCE:ValidatePoison(poisonId, testFunc)
    local poison = self.State.ActivePoisons[poisonId]
    if not poison then
        return false, "Poison not found"
    end
    if not poison.Active then
        return false, "Poison is inactive"
    end
    local validationResult = {
        PoisonId = poisonId,
        Type = poison.Type,
        Timestamp = os.time()
    }
    if poison.Type == "TableHijack" then
        local testKey = next(poison.Overrides)
        if testKey then
            local success, value = pcall(function()
                return poison.Target[testKey]
            end)
            validationResult.Success = success and value == poison.Overrides[testKey]
            validationResult.TestedKey = testKey
            validationResult.ExpectedValue = poison.Overrides[testKey]
            validationResult.ActualValue = value
        end
    elseif poison.Type == "UpvalueInject" then
        local success, currentValue = pcall(getupvalue, poison.TargetFunction, poison.UpvalueIndex)
        validationResult.Success = success and currentValue == poison.NewValue
        validationResult.ExpectedValue = poison.NewValue
        validationResult.ActualValue = currentValue
    elseif testFunc and type(testFunc) == "function" then
        local success, result = pcall(testFunc, poison)
        validationResult.Success = success and result
        validationResult.CustomResult = result
    else
        validationResult.Success = poison.Active
    end
    table.insert(self.State.PoisonValidationResults, validationResult)
    return validationResult.Success, validationResult
end
function Modules.OverseerCE:ExportPoisonConfig()
    local export = {
        Poisons = {},
        Templates = {},
        Timestamp = os.time()
    }
    for id, poison in pairs(self.State.ActivePoisons) do
        if poison.Active then
            table.insert(export.Poisons, {
                Id = id,
                Type = poison.Type,
                Active = poison.Active,
                Timestamp = poison.Timestamp
            })
        end
    end
    local success, jsonData = pcall(function()
        return game:GetService("HttpService"):JSONEncode(export)
    end)
    if success then
        return jsonData
    else
        return nil, "Failed to encode poison config"
    end
end
Modules.OverseerCE.PoisonTemplates = {
    AdminPoison = function(self, adminModule)
        if type(adminModule) ~= "table" then
            return false, "Admin module must be a table"
        end
        local poisons = {
            Kick = function() return true end,
            Ban = function() return true end,
            Shutdown = function() end,
            Kill = function() end,
            Teleport = function() end
        }
        return self:PoisonTableHijack(adminModule, poisons)
    end,
    AntiCheatPoison = function(self, anticheatModule)
        if type(anticheatModule) ~= "table" then
            return false, "Anti-cheat module must be a table"
        end
        anticheatModule.Enabled = false
        local disablePoisons = {
            CheckPlayer = function() return true end,
            Scan = function() return {} end,
            Detect = function() return false end,
            Ban = function() end,
            Kick = function() end
        }
        return self:PoisonTableHijack(anticheatModule, disablePoisons)
    end,
    CurrencyPoison = function(self, currencyModule, amount)
        amount = amount or math.huge
        local currencyPoisons = {
            GetBalance = function() return amount end,
            CanAfford = function() return true end,
            Deduct = function() return true end,
            Add = function() return true end
        }
        return self:PoisonTableHijack(currencyModule, currencyPoisons)
    end,
    UnlockAllPoison = function(self, unlockModule)
        local unlockPoisons = {
            IsUnlocked = function() return true end,
            HasAccess = function() return true end,
            CanUse = function() return true end,
            IsOwned = function() return true end
        }
        return self:PoisonTableHijack(unlockModule, unlockPoisons)
    end
}
Modules.OverseerCE:Initialize()
return Modules.OverseerCE
