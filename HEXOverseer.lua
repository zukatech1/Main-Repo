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
        CurrentModuleDecompiled = nil,
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
        ROW_HEIGHT = 22,
        BUTTON_HEIGHT = 25,
        PADDING = 4,
        ANIM_SPEED = 0.15,
        HOVER_BRIGHTNESS = 1.1
    }
}
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
-- Note: DisableHeartbeatAntiTamper is the legacy simple version.
-- The full DisableAntiTamper (which restores hooked globals) is defined below.
function Modules.OverseerCE:DisableHeartbeatAntiTamper()
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
        return false, "Readonly access via: " .. (method or "unknown")
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
function Modules.OverseerCE:DecompileModuleScript(moduleScript)
    if not moduleScript or not moduleScript:IsA("ModuleScript") then
        return nil, "Not a ModuleScript"
    end
    local decompiled = {
        Name = moduleScript.Name,
        FullName = moduleScript:GetFullName(),
        SourceCode = nil,
        DecompileMethod = "none",
        Functions = {},
        RequireSuccess = false,
        ModuleContent = nil
    }
    if decompile then
        local success, source = pcall(decompile, moduleScript)
        if success and source then
            decompiled.SourceCode = source
            decompiled.DecompileMethod = "decompile(ModuleScript)"
            print("[Decompiler] ✓ Decompiled module via decompile()")
        end
    end
    if not decompiled.SourceCode then
        local success, moduleFunc = pcall(function()
            return require(moduleScript)
        end)
        if success then
            decompiled.RequireSuccess = true
            decompiled.ModuleContent = moduleFunc
            if type(moduleFunc) == "function" and decompile then
                local funcSuccess, funcSource = pcall(decompile, moduleFunc)
                if funcSuccess and funcSource then
                    decompiled.SourceCode = funcSource
                    decompiled.DecompileMethod = "decompile(require(module))"
                    print("[Decompiler] ✓ Decompiled via require() return")
                end
            end
            if type(moduleFunc) == "table" then
                local functionCount = 0
                for key, value in pairs(moduleFunc) do
                    if type(value) == "function" then
                        local funcDecomp = self:DecompileFunction(value)
                        if funcDecomp and funcDecomp.SourceCode then
                            table.insert(decompiled.Functions, {
                                Name = tostring(key),
                                Decompiled = funcDecomp
                            })
                            functionCount = functionCount + 1
                        end
                    end
                end
                if functionCount > 0 then
                    local compositeParts = {
                        "-- Module: " .. decompiled.Name,
                        "-- Decompiled " .. functionCount .. " functions",
                        "-- Original module returns a table",
                        "",
                        "local module = {}",
                        ""
                    }
                    for _, funcData in ipairs(decompiled.Functions) do
                        table.insert(compositeParts, "-- Function: " .. funcData.Name)
                        table.insert(compositeParts, "function module." .. funcData.Name .. "()")
                        if funcData.Decompiled.SourceCode then
                            table.insert(compositeParts, funcData.Decompiled.SourceCode)
                        else
                            table.insert(compositeParts, "    -- Could not decompile")
                        end
                        table.insert(compositeParts, "end")
                        table.insert(compositeParts, "")
                    end
                    table.insert(compositeParts, "return module")
                    decompiled.SourceCode = table.concat(compositeParts, "\n")
                    decompiled.DecompileMethod = "reconstructed from table functions"
                    print("[Decompiler] ✓ Reconstructed from " .. functionCount .. " functions")
                end
            end
        end
    end
    if not decompiled.SourceCode then
        local infoParts = {
            "-- Module: " .. decompiled.Name,
            "-- Path: " .. decompiled.FullName,
            "-- Status: Could not decompile source code",
            "",
            "-- This can happen because:",
            "-- 1. Your executor doesn't have a decompiler",
            "-- 2. The module uses bytecode protection",
            "-- 3. The module is a native C module",
            "",
            "-- However, you can still:",
            "-- • View the module structure in the Table Inspector",
            "-- • Decompile individual functions from the function browser",
            "-- • Use the Scanner to find specific values",
            "",
        }
        if decompiled.RequireSuccess and decompiled.ModuleContent then
            table.insert(infoParts, "-- Module loaded successfully!")
            table.insert(infoParts, "-- Type: " .. type(decompiled.ModuleContent))
            if type(decompiled.ModuleContent) == "table" then
                table.insert(infoParts, "")
                table.insert(infoParts, "-- Module Structure:")
                local count = 0
                for k, v in pairs(decompiled.ModuleContent) do
                    if count < 20 then
                        table.insert(infoParts, "-- " .. tostring(k) .. " = " .. type(v))
                        count = count + 1
                    end
                end
                if count >= 20 then
                    table.insert(infoParts, "-- ... and more entries")
                end
            end
        else
            table.insert(infoParts, "-- Module could not be required")
        end
        decompiled.SourceCode = table.concat(infoParts, "\n")
        decompiled.DecompileMethod = "fallback info"
    end
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
    local decompileModuleBtn = self:_createButton(browserFrame, "Decompile Module", UDim2.new(1, -4, 0, 20), UDim2.new(0, 2, 1, -44), function()
        if not self.State.SelectedModule then
            self:_showNotification("No module selected. Select one from the main Module List first.", "warning")
            return
        end
        self:_showNotification("Decompiling entire module...", "info")
        local moduleDecomp = self:DecompileModuleScript(self.State.SelectedModule)
        if moduleDecomp then
            self.State.CurrentModuleDecompiled = moduleDecomp
            self:SwitchDecompilerTab("ModuleSource", panel)
            self:_showNotification("Module decompiled: " .. moduleDecomp.Name, "success")
        else
            self:_showNotification("Failed to decompile module", "error")
        end
    end)
    decompileModuleBtn.ZIndex = 102
    decompileModuleBtn.TextSize = 9
    decompileModuleBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
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
    local tabs = {"Info", "Constants", "Upvalues", "Protos", "Source", "ModuleSource"}
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
    if tabName == "ModuleSource" then
        self:ShowModuleSource(contentArea)
        return
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
function Modules.OverseerCE:ShowModuleSource(parent)
    local yPos = 4
    if not self.State.CurrentModuleDecompiled then
        local infoLabel = Instance.new("TextLabel", parent)
        infoLabel.Size = UDim2.new(1, -8, 0, 80)
        infoLabel.Position = UDim2.fromOffset(4, yPos)
        infoLabel.BackgroundColor3 = Color3.fromRGB(255, 250, 220)
        infoLabel.Text = [[MODULE SOURCE VIEWER
To view the full module source code:
1. Select a module from the Module List (left panel)
2. Click "Decompile Module" button in the function browser
3. The full module source will appear here
Note: Individual function source is in the "Source" tab]]
        infoLabel.TextColor3 = self.Config.TEXT_BLACK
        infoLabel.Font = Enum.Font.SourceSans
        infoLabel.TextSize = 11
        infoLabel.TextXAlignment = Enum.TextXAlignment.Left
        infoLabel.TextYAlignment = Enum.TextYAlignment.Top
        infoLabel.TextWrapped = true
        infoLabel.ZIndex = 102
        self:_createBorder(infoLabel, true)
        local labelPadding = Instance.new("UIPadding", infoLabel)
        labelPadding.PaddingLeft = UDim.new(0, 8)
        labelPadding.PaddingTop = UDim.new(0, 8)
        return
    end
    local moduleDecomp = self.State.CurrentModuleDecompiled
    local headerLabel = Instance.new("TextLabel", parent)
    headerLabel.Size = UDim2.new(1, -8, 0, 24)
    headerLabel.Position = UDim2.fromOffset(4, yPos)
    headerLabel.BackgroundColor3 = self.Config.ACCENT_BLUE
    headerLabel.Text = "📄 " .. moduleDecomp.Name .. " - " .. moduleDecomp.DecompileMethod
    headerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerLabel.Font = Enum.Font.SourceSansBold
    headerLabel.TextSize = 11
    headerLabel.TextXAlignment = Enum.TextXAlignment.Left
    headerLabel.ZIndex = 102
    self:_createBorder(headerLabel, true)
    local headerPadding = Instance.new("UIPadding", headerLabel)
    headerPadding.PaddingLeft = UDim.new(0, 6)
    yPos = yPos + 28
    local btnContainer = Instance.new("Frame", parent)
    btnContainer.Size = UDim2.new(1, -8, 0, 26)
    btnContainer.Position = UDim2.fromOffset(4, yPos)
    btnContainer.BackgroundTransparency = 1
    btnContainer.ZIndex = 102
    local copyBtn = self:_createButton(btnContainer, "Copy Source", UDim2.fromOffset(100, 22), UDim2.fromOffset(0, 0), function()
        local copied = self:_setClipboard(moduleDecomp.SourceCode)
        if copied then
            self:_showNotification("Source copied to clipboard!", "success")
        else
            self:_showNotification("Clipboard not available", "error")
        end
    end)
    copyBtn.ZIndex = 103
    copyBtn.TextSize = 9
    local refreshBtn = self:_createButton(btnContainer, "Re-Decompile", UDim2.fromOffset(100, 22), UDim2.fromOffset(104, 0), function()
        if self.State.SelectedModule then
            self:_showNotification("Re-decompiling...", "info")
            local newDecomp = self:DecompileModuleScript(self.State.SelectedModule)
            if newDecomp then
                self.State.CurrentModuleDecompiled = newDecomp
                self:SwitchDecompilerTab("ModuleSource", parent:GetParent())
                self:_showNotification("Module re-decompiled!", "success")
            end
        end
    end)
    refreshBtn.ZIndex = 103
    refreshBtn.TextSize = 9
    local exportBtn = self:_createButton(btnContainer, "Export Info", UDim2.fromOffset(100, 22), UDim2.fromOffset(208, 0), function()
        local exportData = {
            Name = moduleDecomp.Name,
            FullName = moduleDecomp.FullName,
            Method = moduleDecomp.DecompileMethod,
            SourceCode = moduleDecomp.SourceCode,
            FunctionCount = #moduleDecomp.Functions
        }
        local success, json = pcall(function()
            return game:GetService("HttpService"):JSONEncode(exportData)
        end)
        if success then
            self:_setClipboard(json)
            self:_showNotification("Module info exported!", "success")
        end
    end)
    exportBtn.ZIndex = 103
    exportBtn.TextSize = 9
    yPos = yPos + 30
    local sourceBox = Instance.new("TextBox", parent)
    sourceBox.Size = UDim2.new(1, -8, 1, -yPos - 4)
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
    sourceBox.Text = moduleDecomp.SourceCode or "-- No source code available"
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

    -- ── Taskbar (always visible, bottom of screen) ──────────────
    -- This is how the window reopens after minimize/close.
    local taskbar = Instance.new("Frame", screenGui)
    taskbar.Name = "Taskbar"
    taskbar.Size = UDim2.fromOffset(280, 28)
    taskbar.Position = UDim2.new(0.5, -140, 1, -32)
    taskbar.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
    taskbar.BorderSizePixel = 0
    taskbar.ZIndex = 200
    -- Win95 raised border on taskbar
    local function tbEdge(sz, pos, col)
        local f = Instance.new("Frame", taskbar)
        f.Size=sz; f.Position=pos; f.BackgroundColor3=col
        f.BorderSizePixel=0; f.ZIndex=201
    end
    tbEdge(UDim2.new(1,0,0,2), UDim2.new(0,0,0,0),   Color3.fromRGB(255,255,255))
    tbEdge(UDim2.new(0,2,1,0), UDim2.new(0,0,0,0),   Color3.fromRGB(255,255,255))
    tbEdge(UDim2.new(1,0,0,2), UDim2.new(0,0,1,-2),  Color3.fromRGB(128,128,128))
    tbEdge(UDim2.new(0,2,1,0), UDim2.new(1,-2,0,0),  Color3.fromRGB(128,128,128))

    local taskbarBtn = Instance.new("TextButton", taskbar)
    taskbarBtn.Size = UDim2.new(1, -8, 1, -6)
    taskbarBtn.Position = UDim2.fromOffset(4, 3)
    taskbarBtn.BackgroundColor3 = Color3.fromRGB(192, 192, 192)
    taskbarBtn.BorderSizePixel = 0
    taskbarBtn.Font = Enum.Font.SourceSansBold
    taskbarBtn.Text = "🔧  Overseer CE 7.5"
    taskbarBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    taskbarBtn.TextSize = 12
    taskbarBtn.TextXAlignment = Enum.TextXAlignment.Left
    taskbarBtn.ZIndex = 202
    taskbarBtn.AutoButtonColor = false
    -- Raised border on the button itself
    local function tbBtnEdge(sz, pos, col)
        local f = Instance.new("Frame", taskbarBtn)
        f.Size=sz; f.Position=pos; f.BackgroundColor3=col
        f.BorderSizePixel=0; f.ZIndex=203
    end
    tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,0,0),  Color3.fromRGB(255,255,255))
    tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(0,0,0,0),  Color3.fromRGB(255,255,255))
    tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), Color3.fromRGB(128,128,128))
    tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), Color3.fromRGB(128,128,128))

    local main = Instance.new("Frame", screenGui)
    main.Size = UDim2.fromOffset(1100, 600)
    main.Position = UDim2.new(0.5, -550, 0.5, -300)
    main.BackgroundColor3 = self.Config.BG_PANEL
    main.BorderSizePixel = 0
    main.ClipsDescendants = false
    self:_createBorder(main, false)

    -- Taskbar button toggles window visibility
    local minimized = false
    taskbarBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        main.Visible = not minimized
        -- Sunken effect when window is open
        for _, c in ipairs(taskbarBtn:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        if minimized then
            -- Raised (window hidden)
            tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,0,0),  Color3.fromRGB(255,255,255))
            tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(0,0,0,0),  Color3.fromRGB(255,255,255))
            tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), Color3.fromRGB(128,128,128))
            tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), Color3.fromRGB(128,128,128))
        else
            -- Sunken (window visible)
            tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,0,0),  Color3.fromRGB(128,128,128))
            tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(0,0,0,0),  Color3.fromRGB(128,128,128))
            tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), Color3.fromRGB(255,255,255))
            tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), Color3.fromRGB(255,255,255))
        end
    end)

    -- ── Title bar ───────────────────────────────────────────────
    local titleBar = Instance.new("Frame", main)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, -2, 0, 24)
    titleBar.Position = UDim2.fromOffset(1, 1)
    titleBar.BackgroundColor3 = self.Config.ACCENT_BLUE
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 2
    local titleGradient = Instance.new("UIGradient", titleBar)
    titleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 168)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 132, 208))
    }
    titleGradient.Rotation = 90
    local titleIcon = Instance.new("TextLabel", titleBar)
    titleIcon.Size = UDim2.fromOffset(20, 20)
    titleIcon.Position = UDim2.fromOffset(4, 2)
    titleIcon.BackgroundTransparency = 1
    titleIcon.Text = "🔧"
    titleIcon.TextColor3 = self.Config.BG_WHITE
    titleIcon.Font = Enum.Font.SourceSansBold
    titleIcon.TextSize = 14
    titleIcon.ZIndex = 3
    local title = Instance.new("TextLabel", titleBar)
    title.Size = UDim2.new(1, -110, 1, 0)
    title.Position = UDim2.fromOffset(26, 0)
    title.Text = "Overseer CE 7.5  —  Module Inspector & Patcher"
    title.TextColor3 = self.Config.BG_WHITE
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.ZIndex = 3

    -- Close button (hides window, taskbar still visible to reopen)
    local closeBtn = self:_createButton(titleBar, "×", UDim2.fromOffset(20, 20), UDim2.new(1, -22, 0, 2), function()
        main.Visible = false
        minimized = true
        -- Flip taskbar to raised
        for _, c in ipairs(taskbarBtn:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,0,0),  Color3.fromRGB(255,255,255))
        tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(0,0,0,0),  Color3.fromRGB(255,255,255))
        tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), Color3.fromRGB(128,128,128))
        tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), Color3.fromRGB(128,128,128))
    end)
    closeBtn.ZIndex = 4
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.BackgroundColor3 = self.Config.BG_LIGHT

    -- Minimize button (same as close, taskbar reopens it)
    local minBtn = self:_createButton(titleBar, "_", UDim2.fromOffset(20, 20), UDim2.new(1, -44, 0, 2), function()
        main.Visible = false
        minimized = true
        for _, c in ipairs(taskbarBtn:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,0,0),  Color3.fromRGB(255,255,255))
        tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(0,0,0,0),  Color3.fromRGB(255,255,255))
        tbBtnEdge(UDim2.new(1,0,0,1), UDim2.new(0,0,1,-1), Color3.fromRGB(128,128,128))
        tbBtnEdge(UDim2.new(0,1,1,0), UDim2.new(1,-1,0,0), Color3.fromRGB(128,128,128))
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
    local menuItems = {"Tools", "Scanner", "Dumper", "Injector", "Anti-Tamper", "Hooks", "Decompiler", "Poisons", "Proto Tree", "Str Grep", "Arg Log", "Bytecode", "UV Diff", "MT Mon", "Env Dump", "Notepad"}
    local menuX = 4
    for _, menuName in ipairs(menuItems) do
        local menuBtn = self:_createButton(menuBar, menuName, UDim2.fromOffset(75, 18), UDim2.fromOffset(menuX, 2), function()
            self:OpenToolWindow(menuName)
        end)
        menuBtn.TextSize = 12
        menuBtn.Size = UDim2.fromOffset(82, 20)
        menuX = menuX + 84
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
    moduleSearch.TextSize = 13
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
    local inspectorPanel = self:_createPanel(content, UDim2.fromOffset(292, 26), UDim2.new(1, -836, 1, -30), "Table Inspector")
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
    pathLabel.TextSize = 12
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
        header.TextSize = 12
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
    local patchPanel = self:_createPanel(content, UDim2.new(1, -540, 0, 26), UDim2.new(0, 200, 1, -30), "Active Patches")
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
    patchCount.TextSize = 13
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
        patchHeader.TextSize = 12
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

    -- ============================================================
    -- EXPLORER PANEL (Dex-style game tree, right of patch panel)
    -- ============================================================
    local explorerPanel = self:_createPanel(content,
        UDim2.new(1, -336, 0, 26),
        UDim2.new(0, 180, 1, -30),
        "Explorer")
    explorerPanel.Size = UDim2.new(0, 180, 1, -30)
    explorerPanel.Position = UDim2.new(1, -336, 0, 26)
    explorerPanel.ZIndex = 10

    -- Properties panel sits directly to the right of explorer
    local propsPanel = self:_createPanel(content,
        UDim2.new(1, -152, 0, 26),
        UDim2.new(0, 148, 1, -30),
        "Properties")
    propsPanel.Size = UDim2.new(0, 148, 1, -30)
    propsPanel.Position = UDim2.new(1, -152, 0, 26)
    propsPanel.ZIndex = 10

    -- Properties instance label
    local propsInstanceLbl = Instance.new("TextLabel", propsPanel)
    propsInstanceLbl.Name = "PropsInstanceLabel"
    propsInstanceLbl.Size = UDim2.new(1, -8, 0, 20)
    propsInstanceLbl.Position = UDim2.fromOffset(4, 24)
    propsInstanceLbl.BackgroundColor3 = self.Config.BG_DARK
    propsInstanceLbl.BorderSizePixel = 0
    propsInstanceLbl.Font = Enum.Font.SourceSansBold
    propsInstanceLbl.TextSize = 12
    propsInstanceLbl.TextColor3 = self.Config.TEXT_BLACK
    propsInstanceLbl.Text = "  Select an instance"
    propsInstanceLbl.TextXAlignment = Enum.TextXAlignment.Left
    propsInstanceLbl.ZIndex = 11
    self:_createBorder(propsInstanceLbl, true)

    -- Column headers
    local propsHeader = Instance.new("Frame", propsPanel)
    propsHeader.Size = UDim2.new(1, -8, 0, 18)
    propsHeader.Position = UDim2.fromOffset(4, 46)
    propsHeader.BackgroundColor3 = self.Config.BG_DARK
    propsHeader.BorderSizePixel = 0
    propsHeader.ZIndex = 11
    self:_createBorder(propsHeader, true)
    local function propsHdrLbl(txt, xScale, wScale)
        local l = Instance.new("TextLabel", propsHeader)
        l.Size = UDim2.new(wScale, -2, 1, 0)
        l.Position = UDim2.new(xScale, 2, 0, 0)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.SourceSansBold
        l.TextSize = 12
        l.TextColor3 = self.Config.TEXT_BLACK
        l.Text = txt
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 12
        local p = Instance.new("UIPadding", l); p.PaddingLeft = UDim.new(0, 3)
    end
    propsHdrLbl("Property", 0, 0.5)
    propsHdrLbl("Value", 0.5, 0.5)

    -- Scrollable property list
    local propsScroll = Instance.new("ScrollingFrame", propsPanel)
    propsScroll.Name = "PropsScroll"
    propsScroll.Size = UDim2.new(1, -8, 1, -70)
    propsScroll.Position = UDim2.fromOffset(4, 66)
    propsScroll.BackgroundColor3 = self.Config.BG_WHITE
    propsScroll.BorderSizePixel = 0
    propsScroll.ScrollBarThickness = 8
    propsScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    propsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    propsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    propsScroll.ZIndex = 11
    self:_createBorder(propsScroll, true)
    local propsLayout = Instance.new("UIListLayout", propsScroll)
    propsLayout.Padding = UDim.new(0, 0)
    propsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    self.State.UI.PropsPanel        = propsPanel
    self.State.UI.PropsScroll       = propsScroll
    self.State.UI.PropsInstanceLbl  = propsInstanceLbl

    local explorerSearch = Instance.new("TextBox", explorerPanel)
    explorerSearch.Name = "ExplorerSearch"
    explorerSearch.Size = UDim2.new(1, -26, 0, 20)
    explorerSearch.Position = UDim2.fromOffset(4, 24)
    explorerSearch.BackgroundColor3 = self.Config.BG_WHITE
    explorerSearch.Text = ""
    explorerSearch.PlaceholderText = "Search workspace..."
    explorerSearch.TextColor3 = self.Config.TEXT_BLACK
    explorerSearch.Font = Enum.Font.SourceSans
    explorerSearch.TextSize = 10
    explorerSearch.BorderSizePixel = 0
    explorerSearch.ClearTextOnFocus = false
    explorerSearch.ZIndex = 11
    self:_createBorder(explorerSearch, true)
    local explorerSearchPad = Instance.new("UIPadding", explorerSearch)
    explorerSearchPad.PaddingLeft = UDim.new(0, 3)

    local refreshExplorerBtn = Instance.new("TextButton", explorerPanel)
    refreshExplorerBtn.Size = UDim2.fromOffset(20, 20)
    refreshExplorerBtn.Position = UDim2.new(1, -24, 0, 24)
    refreshExplorerBtn.BackgroundColor3 = self.Config.BG_DARK
    refreshExplorerBtn.Text = "⟳"
    refreshExplorerBtn.TextColor3 = self.Config.TEXT_BLACK
    refreshExplorerBtn.Font = Enum.Font.SourceSansBold
    refreshExplorerBtn.TextSize = 12
    refreshExplorerBtn.BorderSizePixel = 0
    refreshExplorerBtn.ZIndex = 11
    self:_createBorder(refreshExplorerBtn, true)

    local explorerScroll = Instance.new("ScrollingFrame", explorerPanel)
    explorerScroll.Name = "ExplorerScroll"
    explorerScroll.Size = UDim2.new(1, -8, 1, -52)
    explorerScroll.Position = UDim2.fromOffset(4, 48)
    explorerScroll.BackgroundColor3 = self.Config.BG_WHITE
    explorerScroll.BorderSizePixel = 0
    explorerScroll.ScrollBarThickness = 8
    explorerScroll.ScrollBarImageColor3 = self.Config.BG_DARK
    explorerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    explorerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    explorerScroll.ZIndex = 11
    self:_createBorder(explorerScroll, true)
    local explorerList = Instance.new("UIListLayout", explorerScroll)
    explorerList.Padding = UDim.new(0, 0)
    explorerList.SortOrder = Enum.SortOrder.LayoutOrder

    self.State.UI.ExplorerScroll = explorerScroll
    self.State.UI.ExplorerSearch = explorerSearch
    self.State.UI.ExplorerPanel = explorerPanel
    self.State._ExplorerExpanded = {}
    -- shift notepad placeholder (already removed) — props registered above

    -- ============================================================
    -- NOTEPAD PANEL (source viewer / executor, far right)
    -- ============================================================
    -- Notepad is now a menu tab — opened via OpenToolWindow("Notepad")
    -- State.UI.NotepadSource / NotepadGutter are populated when the window opens

    -- Wire refresh button for explorer
    refreshExplorerBtn.MouseButton1Click:Connect(function()
        self:_ExplorerPopulate(explorerScroll, explorerSearch.Text)
    end)
    explorerSearch.Changed:Connect(function(prop)
        if prop == "Text" then
            task.delay(0.25, function()
                self:_ExplorerPopulate(explorerScroll, explorerSearch.Text)
            end)
        end
    end)

    -- Initial populate
    task.delay(0.5, function()
        self:_ExplorerPopulate(explorerScroll, "")
    end)
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
            local newWidth = math.max(1100, startSize.X.Offset + delta.X)
            local newHeight = math.max(450, startSize.Y.Offset + delta.Y)
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
    self:ScanModules()
end
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

    -- Blacklisted base Roblox modules — hide from list
    local ROBLOX_BLACKLIST = {
        ["BaseCamera"]               = true,
        ["MouseLockController"]      = true,
        ["OrbitalCamera"]            = true,
        ["ControlModule"]            = true,
        ["ClickToMoveController"]    = true,
        ["TouchJump"]                = true,
        ["Keyboard"]                 = true,
        ["TouchThumbstick"]          = true,
        ["VehicleController"]        = true,
        ["ClickToMoveDisplay"]       = true,
        ["BaseCharacterController"]  = true,
        ["Gamepad"]                  = true,
        ["DynamicThumbstick"]        = true,
        ["VRNavigation"]             = true,
        ["PathDisplay"]              = true,
        ["CharacterUtil"]            = true,
        ["FlagUtil"]                 = true,
        ["ConnectionUtil"]           = true,
        ["ConnectionUtil.spec"]      = true,
        ["CameraWrapper"]            = true,
        ["CameraWrapper.spec"]       = true,
        ["AtomicBinding"]            = true,
        -- camera system modules
        ["CameraModule"]              = true,
        ["ClassicCamera"]             = true,
        ["VRBaseCamera"]              = true,
        ["VRCamera"]                  = true,
        ["VehicleCameraConfig"]       = true,
        ["VehicleCameraCore"]         = true,
        ["Popper"]                    = true,
        ["VRVehicleCamera"]           = true,
        ["BaseOcclusion"]             = true,
        ["CameraUI"]                  = true,
        ["LegacyCamera"]              = true,
        ["CameraToggleStateController"] = true,
        -- common additional Roblox internals
        ["CameraInput"]              = true,
        ["CameraUtils"]              = true,
        ["ZoomController"]           = true,
        ["Poppercam"]                = true,
        ["TransparencyController"]   = true,
        ["RootCamera"]               = true,
        ["PlayerModule"]             = true,
        ["RigidBodyController"]      = true,
        ["FollowCamera"]             = true,
        ["VehicleCamera"]            = true,
        ["LockFirstPerson"]          = true,
        ["BaseOcclusionCamera"]      = true,
        ["EditableCamera"]           = true,
        ["SmoothLockedFirstPersonCamera"] = true,
        ["ShiftLockController"]      = true,
        ["Invisicam"]                = true,
    }
    if ROBLOX_BLACKLIST[moduleScript.Name] then return end
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
    nameLabel.TextSize = 12
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
    if not tbl or type(tbl) ~= "table" then 
        warn("[Overseer] PopulateTable: invalid input")
        return 
    end
    if self.State.VisitedTables[tbl] then 
        return 
    end
    local entries = {}
    local success, error = pcall(function()
        for key, value in pairs(tbl) do
            table.insert(entries, {Key = key, Value = value})
        end
    end)
    if not success then
        print("[Overseer] Cannot iterate table:", error)
        self:CreateInspectorRow("[ERROR]", "Cannot read table: " .. tostring(error), tbl, isMetatable)
        return
    end
    if #entries == 0 then
        self:CreateInspectorRow("[EMPTY]", "This table has no entries", tbl, isMetatable)
        self.State.VisitedTables[tbl] = true
        return
    end
    self.State.VisitedTables[tbl] = true
    table.sort(entries, function(a, b)
        local aStr = tostring(a.Key)
        local bStr = tostring(b.Key)
        local aSpecial = aStr:match("^%[")
        local bSpecial = bStr:match("^%[")
        if aSpecial and not bSpecial then return false end
        if bSpecial and not aSpecial then return true end
        local aNum = tonumber(a.Key)
        local bNum = tonumber(b.Key)
        if aNum and bNum then return aNum < bNum end
        if aNum then return true end
        if bNum then return false end
        return aStr < bStr
    end)
    for _, entry in ipairs(entries) do
        self:CreateInspectorRow(entry.Key, entry.Value, tbl, isMetatable)
    end
    print(string.format("[Overseer] ✓ Populated table: %d entries", #entries))
end
function Modules.OverseerCE:CreateInspectorRow(key, value, parentTable, isMetatable)
    if not self.State.UI then return end
    local valueType = type(value)
    local displayValue = self:GetDisplayValue(value, key)
	if valueType == "table" then
        local tableInfo = ""
        local success, size = pcall(function()
            local count = 0
            for k, v in pairs(value) do 
                count = count + 1
                if count > 100 then break end
            end
            return count
        end)
        if success and size then
            tableInfo = " (" .. size .. (size > 100 and "+" or "") .. " entries)"
            displayValue = "{table" .. tableInfo .. "}"
        else
            displayValue = "{table: protected}"
        end
    end
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
            local success, err = pcall(function()
                self:DrillDown(key, value)
            end)
            if not success then
                self:_showNotification("Dive failed: " .. tostring(err), "error")
                warn("[Overseer] Dive error:", err, debug.traceback())
            end
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
    if valueType == "table" then
        patchBtn.Text = "Dive"
        patchBtn.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    elseif valueType == "function" then
        patchBtn.Text = "Hook"
        patchBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 100)
    end
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
        local lastClick = 0
        row.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local now = tick()
                if now - lastClick < 0.5 then
                    pcall(function()
                        self:DrillDown(key, value)
                    end)
                end
                lastClick = now
            end
        end)
    end
    row.MouseEnter:Connect(function()
        if row.BackgroundColor3 ~= self.Config.HIGHLIGHT then
            row.BackgroundColor3 = Color3.fromRGB(230, 240, 255)
        end
    end)
    row.MouseLeave:Connect(function()
        if isPatched then
            -- Re-check patch state at time of leave (patch may have changed)
            local currentPatch = nil
            for _, p in pairs(self.State.ActivePatches) do
                if p.Table == parentTable and p.Key == key then
                    currentPatch = p
                    break
                end
            end
            if currentPatch and currentPatch.Frozen then
                row.BackgroundColor3 = Color3.fromRGB(255, 220, 220)
            else
                row.BackgroundColor3 = Color3.fromRGB(240, 255, 240)
            end
        else
            row.BackgroundColor3 = isMetatable and self.Config.BG_LIGHT or self.Config.BG_WHITE
        end
    end)
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
    if type(tbl) ~= "table" then 
        self:_showNotification("Cannot dive: " .. tostring(name) .. " is " .. type(tbl), "warning")
        return 
    end
    local canIterate, iterError = pcall(function()
        local test = next(tbl)
        return test ~= nil
    end)
    if not canIterate then
        self:_showNotification("Table is protected or empty: " .. tostring(name), "error")
        print("[Overseer] DrillDown blocked:", iterError)
        return
    end
    table.insert(self.State.PathStack, tostring(name))
    self.State.CurrentTable = tbl
    self.State.VisitedTables = {}
    print("[Overseer] ✓ Dove into:", name)
    self:RefreshInspector()
    self:_showNotification("Viewing: " .. tostring(name), "info")
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
        -- Clear notepad state refs if the notepad window is being closed
        if toolName == "Notepad" and self.State.UI then
            self.State.UI.NotepadSource = nil
            self.State.UI.NotepadGutter = nil
            self.State.UI.NotepadPanel  = nil
            self.State.UI.NotepadModLabel = nil
        end
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
	elseif toolName == "Poisons" then
		self:CreatePoisonMenuUI(contentArea)
    elseif toolName == "Proto Tree" then
        self:CreateProtoTreeUI(contentArea)
    elseif toolName == "Str Grep" then
        self:CreateStrGrepUI(contentArea)
    elseif toolName == "Arg Log" then
        self:CreateArgLogUI(contentArea)
    elseif toolName == "Bytecode" then
        self:CreateBytecodeUI(contentArea)
    elseif toolName == "UV Diff" then
        self:CreateUVDiffUI(contentArea)
    elseif toolName == "MT Mon" then
        self:CreateMTMonitorUI(contentArea)
    elseif toolName == "Env Dump" then
        self:CreateEnvDumpUI(contentArea)
    elseif toolName == "Notepad" then
        -- Bigger window for the notepad
        popup.Size = UDim2.fromOffset(860, 620)
        popup.Position = UDim2.new(0.5, -430, 0.5, -310)
        self:CreateNotepadUI(contentArea)
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

-- ============================================================
-- EXPLORER METHODS
-- ============================================================
local EXPLORER_ICONS = {
    ModuleScript = "📄", Script = "📜", LocalScript = "📝",
    Folder = "📁", Model = "🧊", Part = "🟦",
    ReplicatedStorage = "🗄", Players = "👤", Workspace = "🌐",
    StarterGui = "🖥", ServerScriptService = "⚙", default = "▸",
}

function Modules.OverseerCE:_ExplorerIcon(inst)
    if not inst then return "▸" end
    return EXPLORER_ICONS[inst.ClassName] or EXPLORER_ICONS.default
end

function Modules.OverseerCE:_PropertiesPopulate(instance)
    if not self.State.UI or not self.State.UI.PropsScroll then return end
    local scroll = self.State.UI.PropsScroll
    local instLbl = self.State.UI.PropsInstanceLbl

    -- Clear existing rows
    for _, c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end

    if not instance then
        if instLbl then instLbl.Text = "  Select an instance" end
        return
    end

    local className = instance.ClassName
    local fullName  = instance:GetFullName()
    if instLbl then
        instLbl.Text = "  " .. className .. "  —  " .. instance.Name
    end

    -- Properties to read — try all known readable props via pcall
    local COMMON_PROPS = {
        "Name","ClassName","Parent","Archivable",
        -- BasePart
        "Position","Rotation","Size","CFrame","Anchored","CanCollide",
        "CanTouch","CanQuery","Transparency","Color","BrickColor",
        "Material","CastShadow","Locked","Massless",
        -- Humanoid
        "Health","MaxHealth","WalkSpeed","JumpPower","DisplayName",
        "AutoRotate","AutoJumpEnabled","RigType",
        -- Model
        "LevelOfDetail","ModelLod",
        -- Script/Module
        "Disabled","LinkedSource",
        -- GUI
        "Visible","ZIndex","BackgroundColor3","BackgroundTransparency",
        "BorderSizePixel","TextColor3","Text","Font","TextSize",
        -- Light
        "Brightness","Range","Enabled","Color",
        -- Sound
        "SoundId","Volume","Looped","Playing","TimePosition",
        -- General
        "Value",
    }

    local seen = {}
    local rowCount = 0

    local function addPropRow(propName, value)
        if seen[propName] then return end
        seen[propName] = true
        rowCount = rowCount + 1

        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1, -2, 0, 18)
        row.BackgroundColor3 = rowCount % 2 == 0 and self.Config.BG_WHITE or Color3.fromRGB(245, 245, 252)
        row.BorderSizePixel = 0
        row.LayoutOrder = rowCount
        row.ZIndex = 12

        local keyLbl = Instance.new("TextLabel", row)
        keyLbl.Size = UDim2.new(0.48, -1, 1, 0)
        keyLbl.BackgroundTransparency = 1
        keyLbl.Font = Enum.Font.SourceSans
        keyLbl.TextSize = 11
        keyLbl.TextColor3 = self.Config.TEXT_BLACK
        keyLbl.Text = propName
        keyLbl.TextXAlignment = Enum.TextXAlignment.Left
        keyLbl.TextTruncate = Enum.TextTruncate.AtEnd
        keyLbl.ZIndex = 13
        local kp = Instance.new("UIPadding", keyLbl); kp.PaddingLeft = UDim.new(0, 3)

        -- Divider
        local div = Instance.new("Frame", row)
        div.Size = UDim2.new(0, 1, 1, 0)
        div.Position = UDim2.new(0.48, 0, 0, 0)
        div.BackgroundColor3 = self.Config.BG_DARK
        div.BorderSizePixel = 0
        div.ZIndex = 13

        local valLbl = Instance.new("TextLabel", row)
        valLbl.Size = UDim2.new(0.52, -2, 1, 0)
        valLbl.Position = UDim2.new(0.48, 2, 0, 0)
        valLbl.BackgroundTransparency = 1
        valLbl.Font = Enum.Font.Code
        valLbl.TextSize = 11
        valLbl.TextXAlignment = Enum.TextXAlignment.Left
        valLbl.TextTruncate = Enum.TextTruncate.AtEnd
        valLbl.ZIndex = 13

        -- Format value nicely
        local t = type(value)
        local displayVal, color
        if t == "boolean" then
            displayVal = tostring(value)
            color = value and self.Config.SUCCESS_GREEN or self.Config.FROZEN_RED
        elseif t == "number" then
            displayVal = string.format("%.4g", value)
            color = Color3.fromRGB(0, 100, 200)
        elseif t == "string" then
            displayVal = '"' .. value:sub(1, 40) .. (value:len() > 40 and '…"' or '"')
            color = Color3.fromRGB(180, 80, 0)
        elseif t == "userdata" then
            local s = tostring(value)
            -- Prettify common Roblox types
            if value and typeof then
                local vtype = typeof(value)
                if vtype == "Vector3" then
                    displayVal = string.format("(%.2f, %.2f, %.2f)", value.X, value.Y, value.Z)
                elseif vtype == "Color3" then
                    displayVal = string.format("rgb(%d,%d,%d)", value.R*255, value.G*255, value.B*255)
                elseif vtype == "CFrame" then
                    displayVal = string.format("(%.1f, %.1f, %.1f)", value.X, value.Y, value.Z)
                elseif vtype == "UDim2" then
                    displayVal = string.format("{%.0f,%.0f}", value.X.Offset, value.Y.Offset)
                elseif vtype == "Enum" or vtype == "EnumItem" then
                    displayVal = tostring(value)
                elseif vtype == "BrickColor" then
                    displayVal = value.Name
                else
                    displayVal = s:sub(1, 35)
                end
            else
                displayVal = s:sub(1, 35)
            end
            color = Color3.fromRGB(100, 60, 160)
        elseif value == nil then
            displayVal = "nil"
            color = self.Config.TEXT_GRAY
        else
            displayVal = tostring(value):sub(1, 35)
            color = self.Config.TEXT_BLACK
        end

        valLbl.Text = displayVal
        valLbl.TextColor3 = color or self.Config.TEXT_BLACK
    end

    -- Read known common properties
    for _, prop in ipairs(COMMON_PROPS) do
        local ok, val = pcall(function() return (instance :: any)[prop] end)
        if ok then
            addPropRow(prop, val)
        end
    end

    -- Also try to read all properties via __index if getproperties is available
    if getproperties then
        local ok2, props = pcall(getproperties, instance)
        if ok2 and type(props) == "table" then
            for propName, val in pairs(props) do
                addPropRow(tostring(propName), val)
            end
        end
    end

    -- Fallback: iterate via game descriptor if nothing worked
    if rowCount == 0 then
        addPropRow("Name",      instance.Name)
        addPropRow("ClassName", instance.ClassName)
        pcall(function() addPropRow("Parent", tostring(instance.Parent)) end)
    end
end

function Modules.OverseerCE:_ExplorerPopulate(scroll, filter)
    for _, c in ipairs(scroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    self.State._ExplorerExpanded = self.State._ExplorerExpanded or {}
    filter = filter and filter:lower() or ""

    local roots = {}
    local rootNames = {
        "ReplicatedStorage","Players","StarterGui","ServerScriptService",
        "StarterPack","Teams","SoundService","Chat","TextChatService",
        "VoiceChatService","LocalizationService","TestService","VRService",
        "AchievementService","AdService","AnalyticsService","AnimationClipProvider",
        "AppLifecycleService","AppStorageService","AssetService",
        "AudioFocusService","AvatarChatService","AvatarCreationService",
    }
    for _, n in ipairs(rootNames) do
        pcall(function() table.insert(roots, game:GetService(n)) end)
    end
    table.insert(roots, workspace)

    local order = 0
    local function addRow(instance, depth)
        if not instance then return end
        local ok, kids = pcall(function() return instance:GetChildren() end)
        local hasKids = ok and #kids > 0
        local name = instance.Name
        local className = instance.ClassName
        local fullId = tostring(instance)
        local isExpanded = self.State._ExplorerExpanded[fullId] == true

        -- Filter check
        local visible = filter == ""
            or name:lower():find(filter, 1, true)
            or className:lower():find(filter, 1, true)
        if not visible then
            -- Still recurse children so matches deeper in tree show
            if hasKids then
                for _, child in ipairs(kids) do
                    addRow(child, depth + 1)
                end
            end
            return
        end

        order = order + 1
        local row = Instance.new("TextButton", scroll)
        row.Size = UDim2.new(1, -2, 0, 18)
        row.BackgroundColor3 = order % 2 == 0 and self.Config.BG_WHITE or Color3.fromRGB(245,245,250)
        row.Text = ""
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.LayoutOrder = order
        row.ZIndex = 11

        local arrow = Instance.new("TextLabel", row)
        arrow.Size = UDim2.fromOffset(14, 18)
        arrow.Position = UDim2.fromOffset(depth * 10, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = hasKids and (isExpanded and "▾" or "▸") or " "
        arrow.TextColor3 = self.Config.ACCENT_BLUE
        arrow.Font = Enum.Font.SourceSansBold
        arrow.TextSize = 10
        arrow.ZIndex = 12

        local iconL = Instance.new("TextLabel", row)
        iconL.Size = UDim2.fromOffset(16, 18)
        iconL.Position = UDim2.fromOffset(depth * 10 + 14, 0)
        iconL.BackgroundTransparency = 1
        iconL.Text = self:_ExplorerIcon(instance)
        iconL.Font = Enum.Font.SourceSans
        iconL.TextSize = 11
        iconL.ZIndex = 12

        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(1, -(depth * 10 + 32), 1, 0)
        nameLabel.Position = UDim2.fromOffset(depth * 10 + 30, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = name
        nameLabel.TextColor3 = className == "ModuleScript" and self.Config.ACCENT_BLUE or self.Config.TEXT_BLACK
        nameLabel.Font = className == "ModuleScript" and Enum.Font.SourceSansBold or Enum.Font.SourceSans
        nameLabel.TextSize = 10
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.ZIndex = 12

        local capturedOrder = order
        row.MouseButton1Click:Connect(function()
            -- Always highlight the clicked row
            for _, c in ipairs(scroll:GetChildren()) do
                if c:IsA("TextButton") then
                    c.BackgroundColor3 = c.LayoutOrder % 2 == 0 and self.Config.BG_WHITE or Color3.fromRGB(245,245,250)
                    for _, lbl in ipairs(c:GetChildren()) do
                        if lbl:IsA("TextLabel") and lbl.Name == "" then
                            lbl.TextColor3 = lbl.Font == Enum.Font.SourceSansBold
                                and self.Config.ACCENT_BLUE or self.Config.TEXT_BLACK
                        end
                    end
                end
            end
            row.BackgroundColor3 = self.Config.HIGHLIGHT
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

            -- Always populate properties panel for any selected instance
            self:_PropertiesPopulate(instance)

            if className == "ModuleScript" then
                -- Load module into inspector
                self:LoadModule(instance)
                -- Decompile + push to notepad
                self:_showNotification("Decompiling " .. name .. "...", "info")
                task.spawn(function()
                    local decomp = self:DecompileModuleScript(instance)
                    if decomp then
                        self.State.CurrentModuleDecompiled = decomp
                        self:_NotepadDisplay(decomp.SourceCode, decomp.Name)
                        self:_showNotification("Loaded: " .. name, "success")
                    else
                        self:_showNotification("Could not decompile " .. name, "warning")
                    end
                end)
            elseif hasKids then
                self.State._ExplorerExpanded[fullId] = not isExpanded
                self:_ExplorerPopulate(scroll, filter)
            end
        end)
        row.MouseEnter:Connect(function()
            if row.BackgroundColor3 ~= self.Config.HIGHLIGHT then
                row.BackgroundColor3 = self.Config.BG_LIGHT
            end
        end)
        row.MouseLeave:Connect(function()
            if row.BackgroundColor3 ~= self.Config.HIGHLIGHT then
                row.BackgroundColor3 = capturedOrder % 2 == 0 and self.Config.BG_WHITE or Color3.fromRGB(245,245,250)
            end
        end)

        if isExpanded and hasKids then
            local sortedKids = {}
            for _, k in ipairs(kids) do table.insert(sortedKids, k) end
            table.sort(sortedKids, function(a, b)
                local aS = a:IsA("ModuleScript") or a:IsA("Script") or a:IsA("LocalScript")
                local bS = b:IsA("ModuleScript") or b:IsA("Script") or b:IsA("LocalScript")
                if aS ~= bS then return aS end
                return a.Name < b.Name
            end)
            for _, child in ipairs(sortedKids) do
                addRow(child, depth + 1)
            end
        end
    end

    for _, root in ipairs(roots) do
        pcall(addRow, root, 0)
    end
end

-- ============================================================
-- NOTEPAD METHODS
-- ============================================================

function Modules.OverseerCE:CreateNotepadUI(parent)
    -- Top toolbar
    local npToolbar = Instance.new("Frame", parent)
    npToolbar.Size = UDim2.new(1, -8, 0, 28)
    npToolbar.Position = UDim2.fromOffset(4, 4)
    npToolbar.BackgroundColor3 = self.Config.BG_DARK
    npToolbar.BorderSizePixel = 0
    npToolbar.ZIndex = 101
    self:_createBorder(npToolbar, true)

    local npCopyBtn = self:_createButton(npToolbar, "Copy to Clipboard",
        UDim2.fromOffset(120, 22), UDim2.fromOffset(2, 3), function()
        local txt = self.State.UI.NotepadSource and self.State.UI.NotepadSource.Text or ""
        if txt == "" then
            self:_showNotification("Nothing to copy", "warning")
        else
            local ok = self:_setClipboard(txt)
            self:_showNotification(ok and "Source copied!" or "Clipboard unavailable", ok and "success" or "error")
        end
    end)
    npCopyBtn.ZIndex = 102; npCopyBtn.TextSize = 11

    local npSaveBtn = self:_createButton(npToolbar, "Save to File",
        UDim2.fromOffset(90, 22), UDim2.fromOffset(124, 3), function()
        local txt = self.State.UI.NotepadSource and self.State.UI.NotepadSource.Text or ""
        local name = (self.State.SelectedModule and self.State.SelectedModule.Name or "source") .. ".lua"
        if writefile then
            local ok, err = pcall(writefile, name, txt)
            self:_showNotification(ok and ("Saved: " .. name) or ("Save failed: " .. tostring(err)), ok and "success" or "error")
        else
            self:_showNotification("writefile not available in executor", "error")
        end
    end)
    npSaveBtn.ZIndex = 102; npSaveBtn.TextSize = 11

    local npDumpBtn = self:_createButton(npToolbar, "Dump Functions",
        UDim2.fromOffset(100, 22), UDim2.fromOffset(216, 3), function()
        if not self.State.SelectedModule then
            self:_showNotification("No module selected", "warning")
            return
        end
        self:_showNotification("Dumping functions...", "info")
        task.spawn(function()
            local decomp = self:DecompileModuleScript(self.State.SelectedModule)
            if decomp then
                self.State.CurrentModuleDecompiled = decomp
                self:_NotepadDisplay(decomp.SourceCode, decomp.Name)
                self:_showNotification("Dumped: " .. decomp.Name, "success")
            else
                self:_showNotification("Decompile failed", "error")
            end
        end)
    end)
    npDumpBtn.ZIndex = 102; npDumpBtn.TextSize = 11

    -- Module name label on the right of toolbar
    local npModLabel = Instance.new("TextLabel", npToolbar)
    npModLabel.Name = "NotepadModLabel"
    npModLabel.Size = UDim2.new(1, -330, 1, 0)
    npModLabel.Position = UDim2.fromOffset(322, 0)
    npModLabel.BackgroundTransparency = 1
    npModLabel.Font = Enum.Font.Code
    npModLabel.TextSize = 11
    npModLabel.TextColor3 = self.Config.TEXT_GRAY
    npModLabel.Text = "No module loaded"
    npModLabel.TextXAlignment = Enum.TextXAlignment.Left
    npModLabel.ZIndex = 102
    self.State.UI.NotepadModLabel = npModLabel

    -- Editor body: gutter + source
    local npBody = Instance.new("Frame", parent)
    npBody.Name = "NotepadBody"
    npBody.Size = UDim2.new(1, -8, 1, -72)
    npBody.Position = UDim2.fromOffset(4, 36)
    npBody.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    npBody.BorderSizePixel = 0
    npBody.ClipsDescendants = true
    npBody.ZIndex = 101
    self:_createBorder(npBody, true)

    local npGutter = Instance.new("ScrollingFrame", npBody)
    npGutter.Name = "NotepadGutter"
    npGutter.Size = UDim2.new(0, 40, 1, 0)
    npGutter.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    npGutter.BorderSizePixel = 0
    npGutter.ScrollBarThickness = 0
    npGutter.AutomaticCanvasSize = Enum.AutomaticSize.Y
    npGutter.CanvasSize = UDim2.new(0, 0, 0, 0)
    npGutter.ScrollingEnabled = false
    npGutter.ZIndex = 102

    local npSource = Instance.new("TextBox", npBody)
    npSource.Name = "NotepadSource"
    npSource.Size = UDim2.new(1, -42, 1, 0)
    npSource.Position = UDim2.fromOffset(42, 0)
    npSource.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    npSource.TextColor3 = Color3.fromRGB(220, 220, 220)
    npSource.Font = Enum.Font.Code
    npSource.TextSize = 13
    npSource.TextXAlignment = Enum.TextXAlignment.Left
    npSource.TextYAlignment = Enum.TextYAlignment.Top
    npSource.TextWrapped = false
    npSource.ClearTextOnFocus = false
    npSource.MultiLine = true
    npSource.PlaceholderText = "-- Source will appear here after decompile\n-- Select a module from the left panel, then click Dump Functions"
    npSource.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
    npSource.Text = ""
    npSource.BorderSizePixel = 0
    npSource.ZIndex = 102
    local npSourcePad = Instance.new("UIPadding", npSource)
    npSourcePad.PaddingLeft = UDim.new(0, 6)
    npSourcePad.PaddingTop = UDim.new(0, 4)

    npSource:GetPropertyChangedSignal("CursorPosition"):Connect(function()
        task.defer(function()
            local lines = 0
            for _ in npSource.Text:gmatch("\n") do lines += 1 end
            npGutter.CanvasSize = UDim2.fromOffset(0, (lines + 2) * 16)
        end)
    end)

    -- Bottom bar: Execute | Clear
    local npExecBar = Instance.new("Frame", parent)
    npExecBar.Size = UDim2.new(1, -8, 0, 28)
    npExecBar.Position = UDim2.new(0, 4, 1, -32)
    npExecBar.BackgroundColor3 = self.Config.BG_DARK
    npExecBar.BorderSizePixel = 0
    npExecBar.ZIndex = 101
    self:_createBorder(npExecBar, true)

    local npExecBtn = self:_createButton(npExecBar, "Execute",
        UDim2.fromOffset(90, 22), UDim2.new(0.5, -45, 0, 3), function()
        local code = self.State.UI.NotepadSource and self.State.UI.NotepadSource.Text or ""
        if code == "" then self:_showNotification("Nothing to execute", "warning") return end
        local fn, err = loadstring(code)
        if not fn then
            self:_showNotification("Compile error: " .. tostring(err), "error")
            return
        end
        local ok, result = pcall(fn)
        self:_showNotification(ok and "Executed successfully" or ("Runtime error: " .. tostring(result)), ok and "success" or "error")
    end)
    npExecBtn.ZIndex = 102; npExecBtn.TextSize = 12

    local npClearBtn = self:_createButton(npExecBar, "Clear",
        UDim2.fromOffset(70, 22), UDim2.new(1, -74, 0, 3), function()
        if self.State.UI.NotepadSource then self.State.UI.NotepadSource.Text = "" end
        for _, c in ipairs(npGutter:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        if self.State.UI.NotepadModLabel then
            self.State.UI.NotepadModLabel.Text = "No module loaded"
        end
        self:_showNotification("Notepad cleared", "info")
    end)
    npClearBtn.ZIndex = 102; npClearBtn.TextSize = 12

    -- Register into State.UI so _NotepadDisplay can find them
    self.State.UI.NotepadSource = npSource
    self.State.UI.NotepadGutter = npGutter
    self.State.UI.NotepadPanel  = parent
end

function Modules.OverseerCE:_NotepadDisplay(source, moduleName)
    -- Auto-open the notepad tool window if it isn't already open
    if not self.State.UI or not self.State.UI.NotepadSource then
        self:OpenToolWindow("Notepad")
        task.defer(function()
            self:_NotepadDisplay(source, moduleName)
        end)
        return
    end
    source = source or ("-- No source available for: " .. tostring(moduleName))
    self.State.UI.NotepadSource.Text = source
    -- Update the module name label in the toolbar
    if self.State.UI.NotepadModLabel then
        self.State.UI.NotepadModLabel.Text = "  " .. tostring(moduleName or "unknown")
    end

    local gutter = self.State.UI.NotepadGutter
    if not gutter then return end
    for _, c in ipairs(gutter:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end

    local lineH = 14
    local lines = 1
    for _ in source:gmatch("\n") do lines = lines + 1 end

    if not gutter:FindFirstChildOfClass("UIListLayout") then
        local gl = Instance.new("UIListLayout", gutter)
        gl.Padding = UDim.new(0, 0)
        gl.SortOrder = Enum.SortOrder.LayoutOrder
    end

    local function addBatch(s, e)
        for i = s, e do
            local n = Instance.new("TextLabel", gutter)
            n.Size = UDim2.new(1, 0, 0, lineH)
            n.BackgroundTransparency = 1
            n.Text = tostring(i)
            n.TextColor3 = Color3.fromRGB(100,100,100)
            n.Font = Enum.Font.Code
            n.TextSize = 10
            n.TextXAlignment = Enum.TextXAlignment.Right
            n.LayoutOrder = i
            n.ZIndex = 13
            local p = Instance.new("UIPadding", n)
            p.PaddingRight = UDim.new(0, 3)
        end
    end

    local batch = 100
    local first = math.min(batch, lines)
    addBatch(1, first)
    if lines > first then
        task.spawn(function()
            local i = first + 1
            while i <= lines do
                addBatch(i, math.min(i + batch - 1, lines))
                i = i + batch
                task.wait()
            end
        end)
    end
end


-- ══════════════════════════════════════════════════════════════════════════════
-- [GHIDRA] 1. PROTO TREE — recursive closure/proto walker
-- ══════════════════════════════════════════════════════════════════════════════
function Modules.OverseerCE:WalkProtoTree(func, depth, visited, results)
    depth   = depth   or 0
    visited = visited or {}
    results = results or {}
    if depth > 12 then return results end
    local faddr = tostring(func)
    if visited[faddr] then return results end
    visited[faddr] = true

    local entry = {
        Depth    = depth,
        Address  = faddr,
        Constants = {},
        Upvalues  = {},
        Info      = {},
        Children  = {}
    }

    -- info
    pcall(function()
        local fn = (debug and debug.getinfo) or getinfo
        if fn then
            local info = fn(func)
            entry.Info = {
                Source      = tostring(info.source or "?"),
                LineDefined = tostring(info.linedefined or "?"),
                NumParams   = tostring(info.nparams or "?"),
                NumUpvalues = tostring(info.nups or "?"),
                What        = tostring(info.what or "?"),
            }
        end
    end)

    -- constants
    pcall(function()
        local fn = getconstants or (debug and debug.getconstants)
        if fn then
            local ok, consts = pcall(fn, func)
            if ok and consts then
                for i, v in pairs(consts) do
                    table.insert(entry.Constants, {Index=i, Type=type(v), Value=tostring(v):sub(1,80)})
                end
            end
        end
    end)

    -- upvalues
    pcall(function()
        local fn = getupvalues or (debug and debug.getupvalues)
        if fn then
            local ok, uvs = pcall(fn, func)
            if ok and uvs then
                for i, v in pairs(uvs) do
                    table.insert(entry.Upvalues, {Index=i, Type=type(v), Value=tostring(v):sub(1,80)})
                end
            end
        end
    end)

    -- recurse into protos
    pcall(function()
        local fn = getprotos or (debug and debug.getprotos)
        if fn then
            local ok, protos = pcall(fn, func)
            if ok and protos then
                for _, proto in pairs(protos) do
                    if type(proto) == "function" then
                        local child = self:WalkProtoTree(proto, depth+1, visited, {})
                        if child and child[1] then
                            table.insert(entry.Children, child[1])
                        end
                    end
                end
            end
        end
    end)

    table.insert(results, entry)
    return results
end

function Modules.OverseerCE:CreateProtoTreeUI(parent)
    local C = self.Config
    local results = {}

    local pathLabel = Instance.new("TextLabel", parent)
    pathLabel.Size = UDim2.new(1, -8, 0, 18)
    pathLabel.Position = UDim2.fromOffset(4, 4)
    pathLabel.BackgroundTransparency = 1
    pathLabel.Text = "Proto Tree — select a module then click Walk"
    pathLabel.TextColor3 = C.TEXT_GRAY
    pathLabel.Font = Enum.Font.SourceSans
    pathLabel.TextSize = 10
    pathLabel.TextXAlignment = Enum.TextXAlignment.Left

    local walkBtn = self:_createButton(parent, "Walk Selected Module", UDim2.fromOffset(160, 22), UDim2.fromOffset(4, 24), function()
        if not self.State.SelectedModule then
            self:_showNotification("Select a module first", "warning")
            return
        end
        local ok, mod = pcall(require, self.State.SelectedModule)
        if not ok then self:_showNotification("require() failed", "error") return end
        results = {}
        local function walkTable(tbl, depth)
            if depth > 3 then return end
            for k, v in pairs(tbl) do
                if type(v) == "function" then
                    local tree = self:WalkProtoTree(v, 0, {}, {})
                    for _, e in ipairs(tree) do
                        e._label = tostring(k)
                        table.insert(results, e)
                    end
                elseif type(v) == "table" then
                    walkTable(v, depth+1)
                end
            end
        end
        if type(mod) == "function" then
            results = self:WalkProtoTree(mod, 0, {}, {})
        elseif type(mod) == "table" then
            walkTable(mod, 0)
        end
        pathLabel.Text = "Found " .. #results .. " proto entries in: " .. self.State.SelectedModule.Name
        -- rebuild scroll
        for _, c in ipairs(parent:GetChildren()) do
            if c.Name == "ProtoScroll" then c:Destroy() end
        end
        local scroll = Instance.new("ScrollingFrame", parent)
        scroll.Name = "ProtoScroll"
        scroll.Size = UDim2.new(1, -8, 1, -56)
        scroll.Position = UDim2.fromOffset(4, 52)
        scroll.BackgroundColor3 = C.BG_WHITE
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 10
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        self:_createBorder(scroll, true)
        Instance.new("UIListLayout", scroll).Padding = UDim.new(0,1)

        local function addRow(text, depth, clr)
            local row = Instance.new("Frame", scroll)
            row.Size = UDim2.new(1,0,0,18)
            row.BackgroundColor3 = clr or C.BG_LIGHT
            row.BorderSizePixel = 0
            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1,-6,1,0)
            lbl.Position = UDim2.fromOffset(4 + depth*10, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = text
            lbl.TextColor3 = C.TEXT_BLACK
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
        end

        local function renderEntry(e)
            local indent = e.Depth
            local label = e._label and ("[fn: "..e._label.."]") or "[proto]"
            addRow(string.rep("  ",indent)..label.."  @"..e.Address:sub(-8).."  L"..e.Info.LineDefined.."  params:"..e.Info.NumParams.."  upvals:"..e.Info.NumUpvalues, indent, C.BG_DARK)
            -- constants
            for _, c in ipairs(e.Constants) do
                addRow(string.rep("  ",indent+1).."K["..c.Index.."] ("..c.Type..") "..c.Value, indent+1, C.BG_WHITE)
            end
            -- upvalues
            for _, u in ipairs(e.Upvalues) do
                addRow(string.rep("  ",indent+1).."UV["..u.Index.."] ("..u.Type..") "..u.Value, indent+1, C.BG_LIGHT)
            end
            -- children
            for _, child in ipairs(e.Children) do
                renderEntry(child)
            end
        end
        for _, e in ipairs(results) do renderEntry(e) end
    end)

    local copyBtn = self:_createButton(parent, "Copy All", UDim2.fromOffset(80, 22), UDim2.fromOffset(168, 24), function()
        if #results == 0 then return end
        local lines = {}
        local function dump(e, indent)
            table.insert(lines, string.rep("  ",indent).."["..tostring(e._label or "proto").."] @"..e.Address.." L"..e.Info.LineDefined)
            for _, c in ipairs(e.Constants) do
                table.insert(lines, string.rep("  ",indent+1).."K["..c.Index.."] "..c.Type.." = "..c.Value)
            end
            for _, u in ipairs(e.Upvalues) do
                table.insert(lines, string.rep("  ",indent+1).."UV["..u.Index.."] "..u.Type.." = "..u.Value)
            end
            for _, child in ipairs(e.Children) do dump(child, indent+1) end
        end
        for _, e in ipairs(results) do dump(e, 0) end
        self:_setClipboard(table.concat(lines, "\n"))
        self:_showNotification("Proto tree copied!", "success")
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- [GHIDRA] 2. STRING CONSTANT GREP — scan every constant in every function
-- ══════════════════════════════════════════════════════════════════════════════
function Modules.OverseerCE:GrepStringConstants(mod, pattern, results, visited, path)
    results = results or {}
    visited = visited or {}
    path    = path    or "root"
    if type(mod) == "function" then
        local addr = tostring(mod)
        if visited[addr] then return results end
        visited[addr] = true
        pcall(function()
            local fn = getconstants or (debug and debug.getconstants)
            if not fn then return end
            local ok, consts = pcall(fn, mod)
            if ok and consts then
                for i, v in pairs(consts) do
                    if type(v) == "string" then
                        local match = (pattern == "" or v:lower():find(pattern:lower(), 1, true))
                        if match then
                            table.insert(results, {Path=path, Index=i, Value=v})
                        end
                    end
                end
            end
        end)
        -- recurse into protos
        pcall(function()
            local fn = getprotos or (debug and debug.getprotos)
            if not fn then return end
            local ok, protos = pcall(fn, mod)
            if ok and protos then
                for pi, proto in pairs(protos) do
                    if type(proto) == "function" then
                        self:GrepStringConstants(proto, pattern, results, visited, path.."[P"..pi.."]")
                    end
                end
            end
        end)
    elseif type(mod) == "table" then
        if visited[mod] then return results end
        visited[mod] = true
        for k, v in pairs(mod) do
            local subpath = path.."."..tostring(k)
            if type(v) == "function" or type(v) == "table" then
                self:GrepStringConstants(v, pattern, results, visited, subpath)
            end
        end
    end
    return results
end

function Modules.OverseerCE:CreateStrGrepUI(parent)
    local C = self.Config
    local grepResults = {}

    local searchBox = Instance.new("TextBox", parent)
    searchBox.Size = UDim2.fromOffset(260, 22)
    searchBox.Position = UDim2.fromOffset(4, 4)
    searchBox.BackgroundColor3 = C.BG_WHITE
    searchBox.Text = ""
    searchBox.PlaceholderText = "Filter string (blank = all strings)..."
    searchBox.TextColor3 = C.TEXT_BLACK
    searchBox.Font = Enum.Font.SourceSans
    searchBox.TextSize = 11
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.BorderSizePixel = 0
    self:_createBorder(searchBox, true)
    local sp = Instance.new("UIPadding", searchBox)
    sp.PaddingLeft = UDim.new(0,4)

    local countLabel = Instance.new("TextLabel", parent)
    countLabel.Size = UDim2.fromOffset(120, 22)
    countLabel.Position = UDim2.fromOffset(270, 4)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "Results: 0"
    countLabel.TextColor3 = C.TEXT_GRAY
    countLabel.Font = Enum.Font.SourceSans
    countLabel.TextSize = 10
    countLabel.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1,-8,1,-56)
    scroll.Position = UDim2.fromOffset(4, 52)
    scroll.BackgroundColor3 = C.BG_WHITE
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 10
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    self:_createBorder(scroll, true)
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,1)

    local function populateScroll()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        for _, r in ipairs(grepResults) do
            local row = Instance.new("Frame", scroll)
            row.Size = UDim2.new(1,0,0,18)
            row.BackgroundColor3 = C.BG_WHITE
            row.BorderSizePixel = 0
            local lbl = Instance.new("TextLabel", row)
            lbl.Size = UDim2.new(1,-60,1,0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "["..r.Path.."] K"..r.Index.." = \""..r.Value.."\""
            lbl.TextColor3 = C.TEXT_BLACK
            lbl.Font = Enum.Font.Code
            lbl.TextSize = 10
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            local pad = Instance.new("UIPadding", lbl)
            pad.PaddingLeft = UDim.new(0,4)
            lbl.TextTruncate = Enum.TextTruncate.AtEnd
            local cpBtn = self:_createButton(row, "Copy", UDim2.fromOffset(50,16), UDim2.new(1,-52,0,1), function()
                self:_setClipboard(r.Value)
                self:_showNotification("Copied: "..r.Value:sub(1,40), "success")
            end)
            cpBtn.TextSize = 9
        end
    end

    local grepBtn = self:_createButton(parent, "Grep Module", UDim2.fromOffset(90,22), UDim2.fromOffset(4,28), function()
        if not self.State.SelectedModule then
            self:_showNotification("Select a module first", "warning") return
        end
        local ok, mod = pcall(require, self.State.SelectedModule)
        if not ok then self:_showNotification("require() failed","error") return end
        local pat = searchBox.Text
        grepResults = self:GrepStringConstants(mod, pat, {}, {}, self.State.SelectedModule.Name)
        countLabel.Text = "Results: "..#grepResults
        populateScroll()
        self:_showNotification("Found "..#grepResults.." strings", "success")
    end)

    local grepAllBtn = self:_createButton(parent, "Grep All Modules", UDim2.fromOffset(110,22), UDim2.fromOffset(98,28), function()
        local pat = searchBox.Text
        grepResults = {}
        local visited = {}
        for _, md in ipairs(self.State.ModuleList) do
            local ok, mod = pcall(require, md.Script)
            if ok then
                self:GrepStringConstants(mod, pat, grepResults, visited, md.Name)
            end
        end
        countLabel.Text = "Results: "..#grepResults
        populateScroll()
        self:_showNotification("Grepped "..#self.State.ModuleList.." modules — "..#grepResults.." hits", "success")
    end)

    local copyAllBtn = self:_createButton(parent, "Copy All", UDim2.fromOffset(70,22), UDim2.fromOffset(212,28), function()
        if #grepResults == 0 then return end
        local lines = {}
        for _, r in ipairs(grepResults) do
            table.insert(lines, r.Path.." K"..r.Index.." = \""..r.Value.."\"")
        end
        self:_setClipboard(table.concat(lines, "\n"))
        self:_showNotification("All strings copied!", "success")
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- [GHIDRA] 3. ARG LOG — live call recorder with pretty-printed args
-- ══════════════════════════════════════════════════════════════════════════════
function Modules.OverseerCE:PrettyArg(v, depth)
    depth = depth or 0
    if depth > 3 then return "..." end
    local t = type(v)
    if t == "nil" then return "nil"
    elseif t == "boolean" or t == "number" then return tostring(v)
    elseif t == "string" then return '"'..v:sub(1,60)..'"'
    elseif t == "function" then return "fn@"..tostring(v):sub(-6)
    elseif t == "table" then
        local parts = {}
        local n = 0
        for k, val in pairs(v) do
            n = n + 1
            if n > 6 then table.insert(parts, "...") break end
            table.insert(parts, tostring(k).."="..self:PrettyArg(val, depth+1))
        end
        return "{"..table.concat(parts,", ").."}"
    else
        -- Roblox types
        local s = tostring(v)
        if typeof then
            local ty = typeof(v)
            if ty == "Vector3" then return string.format("V3(%.2f,%.2f,%.2f)",v.X,v.Y,v.Z)
            elseif ty == "CFrame" then return string.format("CF(%.1f,%.1f,%.1f)",v.X,v.Y,v.Z)
            elseif ty == "Instance" then return "["..v.ClassName.." "..v.Name.."]"
            elseif ty == "Color3" then return string.format("C3(%d,%d,%d)",v.R*255,v.G*255,v.B*255)
            elseif ty == "UDim2" then return string.format("UD2(%.2f,%d,%.2f,%d)",v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset)
            end
        end
        return s:sub(1,40)
    end
end

function Modules.OverseerCE:CreateArgLogUI(parent)
    local C = self.Config
    local log = {}
    local activeHooks = {}
    local maxEntries = 200

    local pathBox = Instance.new("TextBox", parent)
    pathBox.Size = UDim2.fromOffset(260,22)
    pathBox.Position = UDim2.fromOffset(4,4)
    pathBox.BackgroundColor3 = C.BG_WHITE
    pathBox.PlaceholderText = "path e.g. _G.Combat.Attack"
    pathBox.Text = ""
    pathBox.TextColor3 = C.TEXT_BLACK
    pathBox.Font = Enum.Font.Code
    pathBox.TextSize = 10
    pathBox.ClearTextOnFocus = false
    pathBox.BorderSizePixel = 0
    self:_createBorder(pathBox, true)
    local pp = Instance.new("UIPadding",pathBox)
    pp.PaddingLeft=UDim.new(0,4)

    local statusLbl = Instance.new("TextLabel", parent)
    statusLbl.Size = UDim2.fromOffset(200,22)
    statusLbl.Position = UDim2.fromOffset(270,4)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Hooks active: 0"
    statusLbl.TextColor3 = C.TEXT_GRAY
    statusLbl.Font = Enum.Font.SourceSans
    statusLbl.TextSize = 10
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Name = "ArgLogScroll"
    scroll.Size = UDim2.new(1,-8,1,-56)
    scroll.Position = UDim2.fromOffset(4,52)
    scroll.BackgroundColor3 = Color3.fromRGB(18,18,18)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 10
    scroll.ScrollBarImageColor3 = C.ACCENT_BLUE
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    self:_createBorder(scroll, true)
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,1)

    local function addLogRow(entry)
        if #log >= maxEntries then
            local oldest = scroll:FindFirstChildWhichIsA("Frame")
            if oldest then oldest:Destroy() end
            table.remove(log,1)
        end
        table.insert(log, entry)
        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1,0,0,18)
        row.BackgroundColor3 = entry.isReturn and Color3.fromRGB(20,35,20) or Color3.fromRGB(20,20,35)
        row.BorderSizePixel = 0
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-60,1,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.format("[%s][#%d] %s(%s)",
            entry.isReturn and "RET" or "CALL",
            entry.n,
            entry.name,
            entry.argStr)
        lbl.TextColor3 = entry.isReturn and Color3.fromRGB(100,220,100) or Color3.fromRGB(100,180,255)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local lpad = Instance.new("UIPadding",lbl)
    lpad.PaddingLeft=UDim.new(0,4)
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        local cpb = self:_createButton(row,"CP",UDim2.fromOffset(28,16),UDim2.new(1,-58,0,1),function()
            self:_setClipboard(lbl.Text)
        end)
        cpb.TextSize = 9
        -- auto-scroll to bottom
        scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
    end

    local callCount = 0
    local function hookFunc(path, name)
        if not hookfunction then
            self:_showNotification("hookfunction not available","error") return
        end
        -- resolve path
        local parts = {}
        for p in path:gmatch("[^%.]+") do table.insert(parts,p) end
        local tbl = _G
        local key = parts[#parts]
        for i=1,#parts-1 do
            local nxt = tbl[parts[i]]
            if type(nxt) ~= "table" then
                self:_showNotification("Path not found: "..parts[i],"error") return
            end
            tbl = nxt
        end
        local target = tbl[key]
        if type(target) ~= "function" then
            self:_showNotification("Not a function: "..path,"error") return
        end
        local origFunc
        local ok, orig = pcall(hookfunction, target, newcclosure and newcclosure(function(...)
            callCount = callCount + 1
            local args = {...}
            local parts2 = {}
            for _, a in ipairs(args) do table.insert(parts2, self:PrettyArg(a)) end
            local rets = {origFunc(...)}
            local retParts = {}
            for _, r in ipairs(rets) do table.insert(retParts, self:PrettyArg(r)) end
            task.defer(function()
                addLogRow({n=callCount, name=name or key, argStr=table.concat(parts2,", "), isReturn=false})
                if #rets > 0 then
                    addLogRow({n=callCount, name=name or key, argStr=table.concat(retParts,", "), isReturn=true})
                end
            end)
            return table.unpack(rets)
        end) or function(...)
            callCount = callCount + 1
            local args = {...}
            local parts2 = {}
            for _, a in ipairs(args) do table.insert(parts2, self:PrettyArg(a)) end
            local rets = {origFunc(...)}
            local retParts = {}
            for _, r in ipairs(rets) do table.insert(retParts, self:PrettyArg(r)) end
            task.defer(function()
                addLogRow({n=callCount, name=name or key, argStr=table.concat(parts2,", "), isReturn=false})
                if #rets > 0 then
                    addLogRow({n=callCount, name=name or key, argStr=table.concat(retParts,", "), isReturn=true})
                end
            end)
            return table.unpack(rets)
        end)
        if ok then
            origFunc = orig
            table.insert(activeHooks, {Path=path, Original=orig, Table=tbl, Key=key})
            statusLbl.Text = "Hooks active: "..#activeHooks
            self:_showNotification("Hooked: "..path, "success")
        else
            self:_showNotification("Hook failed: "..tostring(orig), "error")
        end
    end

    local hookBtn = self:_createButton(parent,"Hook Path",UDim2.fromOffset(80,22),UDim2.fromOffset(4,28),function()
        hookFunc(pathBox.Text, nil)
    end)

    local clearBtn = self:_createButton(parent,"Clear Log",UDim2.fromOffset(70,22),UDim2.fromOffset(88,28),function()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        log = {}
        callCount = 0
    end)

    local unhookBtn = self:_createButton(parent,"Unhook All",UDim2.fromOffset(80,22),UDim2.fromOffset(162,28),function()
        for _, h in ipairs(activeHooks) do
            pcall(function() h.Table[h.Key] = h.Original end)
        end
        activeHooks = {}
        statusLbl.Text = "Hooks active: 0"
        self:_showNotification("All hooks removed", "success")
    end)

    local copyBtn = self:_createButton(parent,"Copy Log",UDim2.fromOffset(70,22),UDim2.fromOffset(246,28),function()
        local lines = {}
        for _, e in ipairs(log) do
            table.insert(lines, string.format("[%s][#%d] %s(%s)", e.isReturn and "RET" or "CALL", e.n, e.name, e.argStr))
        end
        self:_setClipboard(table.concat(lines,"\n"))
        self:_showNotification("Log copied!", "success")
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- [GHIDRA] 4. BYTECODE VIEWER — hex + ASCII dump of script bytecode
-- ══════════════════════════════════════════════════════════════════════════════
function Modules.OverseerCE:CreateBytecodeUI(parent)
    local C = self.Config

    local infoLbl = Instance.new("TextLabel", parent)
    infoLbl.Size = UDim2.new(1,-8,0,18)
    infoLbl.Position = UDim2.fromOffset(4,4)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Text = "Requires getscriptbytecode. Select a script/module then click Dump."
    infoLbl.TextColor3 = C.TEXT_GRAY
    infoLbl.Font = Enum.Font.SourceSans
    infoLbl.TextSize = 10
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left

    local filterBox = Instance.new("TextBox", parent)
    filterBox.Size = UDim2.fromOffset(160,22)
    filterBox.Position = UDim2.fromOffset(4,26)
    filterBox.BackgroundColor3 = C.BG_WHITE
    filterBox.PlaceholderText = "ASCII filter (optional)"
    filterBox.Text = ""
    filterBox.TextColor3 = C.TEXT_BLACK
    filterBox.Font = Enum.Font.Code
    filterBox.TextSize = 10
    filterBox.ClearTextOnFocus = false
    filterBox.BorderSizePixel = 0
    self:_createBorder(filterBox, true)
    local fp = Instance.new("UIPadding",filterBox)
    fp.PaddingLeft=UDim.new(0,4)

    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1,-8,1,-58)
    scroll.Position = UDim2.fromOffset(4,54)
    scroll.BackgroundColor3 = Color3.fromRGB(14,14,14)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 10
    scroll.ScrollBarImageColor3 = C.ACCENT_BLUE
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    self:_createBorder(scroll, true)
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,0)

    local function addHexRow(offset, bytes, ascii)
        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1,0,0,14)
        row.BackgroundColor3 = offset % 32 == 0 and Color3.fromRGB(22,22,22) or Color3.fromRGB(14,14,14)
        row.BorderSizePixel = 0
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-6,1,0)
        lbl.Position = UDim2.fromOffset(4,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.format("%06X  %-47s  %s", offset, bytes, ascii)
        lbl.TextColor3 = Color3.fromRGB(180,220,180)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
    end

    local rawBytecode = nil

    local dumpBtn = self:_createButton(parent,"Dump Bytecode",UDim2.fromOffset(100,22),UDim2.fromOffset(168,26),function()
        if not getscriptbytecode then
            self:_showNotification("getscriptbytecode not available","error") return
        end
        if not self.State.SelectedModule then
            self:_showNotification("Select a script first","warning") return
        end
        local ok, bc = pcall(getscriptbytecode, self.State.SelectedModule)
        if not ok or not bc then
            self:_showNotification("Failed to get bytecode","error") return
        end
        rawBytecode = bc
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        local filter = filterBox.Text:lower()
        local COLS = 16
        for i = 1, #bc, COLS do
            local hexParts = {}
            local ascParts = {}
            for j = i, math.min(i+COLS-1, #bc) do
                local byte = bc:byte(j)
                table.insert(hexParts, string.format("%02X", byte))
                local ch = (byte >= 32 and byte < 127) and string.char(byte) or "."
                table.insert(ascParts, ch)
            end
            local hexStr = table.concat(hexParts," ")
            local ascStr = table.concat(ascParts)
            if filter == "" or ascStr:lower():find(filter,1,true) or hexStr:lower():find(filter,1,true) then
                addHexRow(i-1, hexStr, ascStr)
            end
        end
        self:_showNotification("Bytecode: "..#bc.." bytes", "success")
    end)

    local copyRawBtn = self:_createButton(parent,"Copy Hex",UDim2.fromOffset(70,22),UDim2.fromOffset(272,26),function()
        if not rawBytecode then return end
        local parts = {}
        for i=1,#rawBytecode do table.insert(parts, string.format("%02X",rawBytecode:byte(i))) end
        self:_setClipboard(table.concat(parts," "))
        self:_showNotification("Hex copied!", "success")
    end)

    -- string extractor button
    local strBtn = self:_createButton(parent,"Extract Strings",UDim2.fromOffset(100,22),UDim2.fromOffset(346,26),function()
        if not rawBytecode then
            self:_showNotification("Dump bytecode first","warning") return
        end
        local strings = {}
        local current = {}
        for i=1,#rawBytecode do
            local b = rawBytecode:byte(i)
            if b >= 32 and b < 127 then
                table.insert(current, string.char(b))
            else
                if #current >= 4 then
                    table.insert(strings, table.concat(current))
                end
                current = {}
            end
        end
        if #current >= 4 then table.insert(strings, table.concat(current)) end
        local out = "-- Strings extracted from bytecode ("..#strings.." found)\n"
        for i, s in ipairs(strings) do
            out = out .. string.format('[%d] "%s"\n', i, s)
        end
        self:_setClipboard(out)
        self:_showNotification("Extracted "..#strings.." strings, copied!", "success")
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- [GHIDRA] 5. UPVALUE DIFF — snapshot then compare to detect mutations
-- ══════════════════════════════════════════════════════════════════════════════
function Modules.OverseerCE:SnapshotUpvalues(func, path)
    local snapshot = {}
    local fn = getupvalues or (debug and debug.getupvalues)
    if not fn then return snapshot end
    local ok, uvs = pcall(fn, func)
    if not ok or not uvs then return snapshot end
    for i, v in pairs(uvs) do
        snapshot[i] = {Value=v, Type=type(v), Str=tostring(v):sub(1,80), Path=path, Index=i}
    end
    -- also recurse into protos
    local pfn = getprotos or (debug and debug.getprotos)
    if pfn then
        local pok, protos = pcall(pfn, func)
        if pok and protos then
            for pi, proto in pairs(protos) do
                if type(proto) == "function" then
                    local sub = self:SnapshotUpvalues(proto, path.."[P"..pi.."]")
                    for k, v in pairs(sub) do
                        snapshot[path.."[P"..pi.."]["..k.."]"] = v
                    end
                end
            end
        end
    end
    return snapshot
end

function Modules.OverseerCE:CreateUVDiffUI(parent)
    local C = self.Config
    local snapshots = {}  -- {label, data}
    local diffs = {}

    local snapLabel = Instance.new("TextLabel", parent)
    snapLabel.Size = UDim2.new(1,-8,0,18)
    snapLabel.Position = UDim2.fromOffset(4,4)
    snapLabel.BackgroundTransparency = 1
    snapLabel.Text = "Snapshots: 0  —  Select module, snap, wait, snap again, then diff."
    snapLabel.TextColor3 = C.TEXT_GRAY
    snapLabel.Font = Enum.Font.SourceSans
    snapLabel.TextSize = 10
    snapLabel.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1,-8,1,-56)
    scroll.Position = UDim2.fromOffset(4,52)
    scroll.BackgroundColor3 = C.BG_WHITE
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 10
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    self:_createBorder(scroll, true)
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,1)

    local function addRow(text, clr)
        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1,0,0,18)
        row.BackgroundColor3 = clr or C.BG_WHITE
        row.BorderSizePixel = 0
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-6,1,0)
        lbl.Position = UDim2.fromOffset(4,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = C.TEXT_BLACK
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
    end

    local function collectSnap(label)
        if not self.State.SelectedModule then
            self:_showNotification("Select a module first","warning") return
        end
        local ok, mod = pcall(require, self.State.SelectedModule)
        if not ok then self:_showNotification("require() failed","error") return end
        local combined = {}
        local function walk(v, path, visited)
            if visited[v] then return end
            visited[v] = true
            if type(v) == "function" then
                local s = self:SnapshotUpvalues(v, path)
                for k, entry in pairs(s) do combined[path.."["..tostring(k).."]"] = entry end
            elseif type(v) == "table" then
                for k, child in pairs(v) do
                    walk(child, path.."."..tostring(k), visited)
                end
            end
        end
        walk(mod, self.State.SelectedModule.Name, {})
        table.insert(snapshots, {Label=label, Data=combined, Time=os.time()})
        snapLabel.Text = "Snapshots: "..#snapshots.."  —  last: "..label
        self:_showNotification("Snapshot "..label.." captured ("..self:_tableLen(combined).." upvalues)", "success")
    end

    local snapABtn = self:_createButton(parent,"Snap A",UDim2.fromOffset(65,22),UDim2.fromOffset(4,28),function()
        collectSnap("A")
    end)
    local snapBBtn = self:_createButton(parent,"Snap B",UDim2.fromOffset(65,22),UDim2.fromOffset(72,28),function()
        collectSnap("B")
    end)
    local diffBtn = self:_createButton(parent,"Diff A→B",UDim2.fromOffset(70,22),UDim2.fromOffset(140,28),function()
        if #snapshots < 2 then
            self:_showNotification("Need at least 2 snapshots","warning") return
        end
        local A = snapshots[#snapshots-1].Data
        local B = snapshots[#snapshots].Data
        diffs = {}
        -- changed / new
        for k, bEntry in pairs(B) do
            local aEntry = A[k]
            if not aEntry then
                table.insert(diffs, {Key=k, Kind="NEW", OldVal="(nil)", NewVal=bEntry.Str, Type=bEntry.Type})
            elseif aEntry.Str ~= bEntry.Str then
                table.insert(diffs, {Key=k, Kind="CHANGED", OldVal=aEntry.Str, NewVal=bEntry.Str, Type=bEntry.Type})
            end
        end
        -- removed
        for k, aEntry in pairs(A) do
            if not B[k] then
                table.insert(diffs, {Key=k, Kind="REMOVED", OldVal=aEntry.Str, NewVal="(nil)", Type=aEntry.Type})
            end
        end
        -- render
        for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        if #diffs == 0 then
            addRow("No upvalue changes detected between snapshots.", C.BG_LIGHT)
        else
            addRow(string.format("=== %d upvalue change(s) detected ===", #diffs), C.BG_DARK)
            for _, d in ipairs(diffs) do
                local clr = d.Kind=="NEW" and Color3.fromRGB(200,240,200)
                    or d.Kind=="REMOVED" and Color3.fromRGB(255,200,200)
                    or Color3.fromRGB(200,220,255)
                addRow(string.format("[%s] %s  (%s)  %s → %s", d.Kind, d.Key, d.Type, d.OldVal, d.NewVal), clr)
            end
        end
        self:_showNotification("Diff complete: "..#diffs.." change(s)", "success")
    end)

    local clearBtn = self:_createButton(parent,"Clear",UDim2.fromOffset(55,22),UDim2.fromOffset(214,28),function()
        snapshots = {}
        diffs = {}
        for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        snapLabel.Text = "Snapshots: 0"
    end)

    local copyBtn = self:_createButton(parent,"Copy Diffs",UDim2.fromOffset(75,22),UDim2.fromOffset(272,28),function()
        if #diffs == 0 then return end
        local lines = {}
        for _, d in ipairs(diffs) do
            table.insert(lines, string.format("[%s] %s (%s) %s → %s", d.Kind, d.Key, d.Type, d.OldVal, d.NewVal))
        end
        self:_setClipboard(table.concat(lines,"\n"))
        self:_showNotification("Diffs copied!", "success")
    end)
end

-- helper used by UV Diff
function Modules.OverseerCE:_tableLen(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

-- ══════════════════════════════════════════════════════════════════════════════
-- [GHIDRA] 6. METATABLE MONITOR — hook __index / __newindex on a table
-- ══════════════════════════════════════════════════════════════════════════════
function Modules.OverseerCE:CreateMTMonitorUI(parent)
    local C = self.Config
    local log = {}
    local activeMonitors = {}

    local pathBox = Instance.new("TextBox", parent)
    pathBox.Size = UDim2.fromOffset(260,22)
    pathBox.Position = UDim2.fromOffset(4,4)
    pathBox.BackgroundColor3 = C.BG_WHITE
    pathBox.PlaceholderText = "path e.g. _G.SomeModule or leave blank = selected module"
    pathBox.Text = ""
    pathBox.TextColor3 = C.TEXT_BLACK
    pathBox.Font = Enum.Font.Code
    pathBox.TextSize = 10
    pathBox.ClearTextOnFocus = false
    pathBox.BorderSizePixel = 0
    self:_createBorder(pathBox, true)
    local mpp = Instance.new("UIPadding",pathBox)
    mpp.PaddingLeft=UDim.new(0,4)

    local statusLbl = Instance.new("TextLabel", parent)
    statusLbl.Size = UDim2.fromOffset(160,22)
    statusLbl.Position = UDim2.fromOffset(270,4)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text = "Monitors: 0  |  Events: 0"
    statusLbl.TextColor3 = C.TEXT_GRAY
    statusLbl.Font = Enum.Font.SourceSans
    statusLbl.TextSize = 10
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1,-8,1,-56)
    scroll.Position = UDim2.fromOffset(4,52)
    scroll.BackgroundColor3 = Color3.fromRGB(14,14,14)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 10
    scroll.ScrollBarImageColor3 = C.ACCENT_BLUE
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    self:_createBorder(scroll, true)
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,1)

    local evCount = 0
    local function addEvent(kind, key, val, extra)
        evCount = evCount + 1
        table.insert(log, {kind=kind,key=key,val=val,extra=extra,n=evCount})
        statusLbl.Text = "Monitors: "..#activeMonitors.."  |  Events: "..evCount
        local row = Instance.new("Frame", scroll)
        row.Size = UDim2.new(1,0,0,14)
        row.BackgroundColor3 = kind=="__newindex" and Color3.fromRGB(35,18,18) or Color3.fromRGB(18,18,35)
        row.BorderSizePixel = 0
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-6,1,0)
        lbl.Position = UDim2.fromOffset(4,0)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.format("[#%d][%s] key=%s  val=%s  %s", evCount, kind, tostring(key), tostring(val):sub(1,40), extra or "")
        lbl.TextColor3 = kind=="__newindex" and Color3.fromRGB(255,120,120) or Color3.fromRGB(120,180,255)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd
        scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
    end

    local function installMonitor(tbl, label)
        if not rawequal then rawequal = function(a,b) return a==b end end
        local mt, method = self:GetRawMetatable(tbl)
        local existingIndex    = mt and mt.__index
        local existingNewindex = mt and mt.__newindex
        local newMt = mt or {}

        newMt.__index = function(t, k)
            local v = existingIndex and (type(existingIndex)=="function" and existingIndex(t,k) or existingIndex[k]) or rawget(t,k)
            addEvent("__index", k, v, label)
            return v
        end
        newMt.__newindex = function(t, k, v)
            addEvent("__newindex", k, v, label.."  (was: "..tostring(rawget(t,k)):sub(1,30)..")")
            if existingNewindex and type(existingNewindex)=="function" then
                existingNewindex(t,k,v)
            else
                rawset(t,k,v)
            end
        end
        local ok = pcall(setmetatable, tbl, newMt)
        if not ok then
            -- try rawsetmetatable
            if rawsetmetatable then
                rawsetmetatable(tbl, newMt)
                ok = true
            end
        end
        if ok then
            table.insert(activeMonitors, {Label=label, Table=tbl, OldMt=mt})
            statusLbl.Text = "Monitors: "..#activeMonitors.."  |  Events: "..evCount
            self:_showNotification("Monitor installed on: "..label, "success")
        else
            self:_showNotification("Could not set metatable on: "..label, "error")
        end
    end

    local monBtn = self:_createButton(parent,"Monitor Path",UDim2.fromOffset(90,22),UDim2.fromOffset(4,28),function()
        local path = pathBox.Text
        if path == "" then
            -- use selected module
            if not self.State.SelectedModule then
                self:_showNotification("Enter a path or select a module","warning") return
            end
            local ok, mod = pcall(require, self.State.SelectedModule)
            if not ok or type(mod) ~= "table" then
                self:_showNotification("Module must return a table","error") return
            end
            installMonitor(mod, self.State.SelectedModule.Name)
        else
            -- resolve path
            local parts = {}
            for p in path:gmatch("[^%.]+") do table.insert(parts,p) end
            local tbl = _G
            for _, p in ipairs(parts) do
                if type(tbl) ~= "table" then
                    self:_showNotification("Invalid path segment: "..p,"error") return
                end
                tbl = tbl[p]
            end
            if type(tbl) ~= "table" then
                self:_showNotification("Resolved value is not a table","error") return
            end
            installMonitor(tbl, path)
        end
    end)

    local clearBtn = self:_createButton(parent,"Clear Log",UDim2.fromOffset(70,22),UDim2.fromOffset(98,28),function()
        for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        log = {}
        evCount = 0
        statusLbl.Text = "Monitors: "..#activeMonitors.."  |  Events: 0"
    end)

    local removeBtn = self:_createButton(parent,"Remove All Monitors",UDim2.fromOffset(130,22),UDim2.fromOffset(172,28),function()
        for _, m in ipairs(activeMonitors) do
            pcall(setmetatable, m.Table, m.OldMt)
        end
        activeMonitors = {}
        statusLbl.Text = "Monitors: 0  |  Events: "..evCount
        self:_showNotification("All monitors removed", "success")
    end)

    local copyBtn = self:_createButton(parent,"Copy Log",UDim2.fromOffset(65,22),UDim2.fromOffset(306,28),function()
        if #log == 0 then return end
        local lines = {}
        for _, e in ipairs(log) do
            table.insert(lines, string.format("[#%d][%s] key=%s val=%s %s", e.n, e.kind, tostring(e.key), tostring(e.val):sub(1,60), e.extra or ""))
        end
        self:_setClipboard(table.concat(lines,"\n"))
        self:_showNotification("Log copied!", "success")
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- [GHIDRA] 7. ENV DUMP — getfenv / getreg / getsenv sweep
-- ══════════════════════════════════════════════════════════════════════════════
function Modules.OverseerCE:CreateEnvDumpUI(parent)
    local C = self.Config
    local dumpData = {}

    local modeLbl = Instance.new("TextLabel", parent)
    modeLbl.Size = UDim2.new(1,-8,0,18)
    modeLbl.Position = UDim2.fromOffset(4,4)
    modeLbl.BackgroundTransparency = 1
    modeLbl.Text = "Dump script environment, registry tables, or custom env path."
    modeLbl.TextColor3 = C.TEXT_GRAY
    modeLbl.Font = Enum.Font.SourceSans
    modeLbl.TextSize = 10
    modeLbl.TextXAlignment = Enum.TextXAlignment.Left

    local filterBox = Instance.new("TextBox", parent)
    filterBox.Size = UDim2.fromOffset(180,22)
    filterBox.Position = UDim2.fromOffset(4,26)
    filterBox.BackgroundColor3 = C.BG_WHITE
    filterBox.PlaceholderText = "Filter key name..."
    filterBox.Text = ""
    filterBox.TextColor3 = C.TEXT_BLACK
    filterBox.Font = Enum.Font.Code
    filterBox.TextSize = 10
    filterBox.ClearTextOnFocus = false
    filterBox.BorderSizePixel = 0
    self:_createBorder(filterBox, true)
    local efp = Instance.new("UIPadding",filterBox)
    efp.PaddingLeft=UDim.new(0,4)

    local countLbl = Instance.new("TextLabel", parent)
    countLbl.Size = UDim2.fromOffset(100,22)
    countLbl.Position = UDim2.fromOffset(188,26)
    countLbl.BackgroundTransparency = 1
    countLbl.Text = "Keys: 0"
    countLbl.TextColor3 = C.TEXT_GRAY
    countLbl.Font = Enum.Font.SourceSans
    countLbl.TextSize = 10
    countLbl.TextXAlignment = Enum.TextXAlignment.Left

    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1,-8,1,-60)
    scroll.Position = UDim2.fromOffset(4,56)
    scroll.BackgroundColor3 = C.BG_WHITE
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 10
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    self:_createBorder(scroll, true)
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,1)

    local function renderDump(data)
        for _, c in ipairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        local filter = filterBox.Text:lower()
        local shown = 0
        local sorted = {}
        for k, v in pairs(data) do table.insert(sorted, {k=k,v=v}) end
        table.sort(sorted, function(a,b) return tostring(a.k) < tostring(b.k) end)
        for _, entry in ipairs(sorted) do
            local keyStr = tostring(entry.k)
            if filter == "" or keyStr:lower():find(filter,1,true) then
                shown = shown + 1
                local row = Instance.new("Frame", scroll)
                row.Size = UDim2.new(1,0,0,18)
                row.BackgroundColor3 = shown%2==0 and C.BG_LIGHT or C.BG_WHITE
                row.BorderSizePixel = 0
                local lbl = Instance.new("TextLabel", row)
                lbl.Size = UDim2.new(1,-60,1,0)
                lbl.Position = UDim2.fromOffset(4,0)
                lbl.BackgroundTransparency = 1
                local vt = type(entry.v)
                local vs = (vt == "function") and ("fn@"..tostring(entry.v):sub(-6))
                    or (vt == "table") and ("{table #"..tostring(self:_tableLen(entry.v)).."}")
                    or tostring(entry.v):sub(1,60)
                lbl.Text = string.format("%-30s  %-10s  %s", keyStr:sub(1,30), vt, vs)
                lbl.TextColor3 = vt=="function" and C.ACCENT_BLUE or vt=="table" and C.WARNING_ORANGE or C.TEXT_BLACK
                lbl.Font = Enum.Font.Code
                lbl.TextSize = 10
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                local cpb = self:_createButton(row,"CP",UDim2.fromOffset(30,16),UDim2.new(1,-50,0,1),function()
                    self:_setClipboard(keyStr.." = "..vs)
                end)
                cpb.TextSize = 9
                local drillBtn = self:_createButton(row,"->",UDim2.fromOffset(18,16),UDim2.new(1,-18,0,1),function()
                    if vt == "table" then
                        dumpData = entry.v
                        renderDump(dumpData)
                        modeLbl.Text = "Drilled into: "..keyStr
                    end
                end)
                drillBtn.TextSize = 9
            end
        end
        countLbl.Text = "Keys: "..shown
    end

    local function doFenvDump()
        if not self.State.SelectedModule then
            self:_showNotification("Select a script first","warning") return
        end
        local fenvFn = getsenv or getfenv
        if not fenvFn then
            self:_showNotification("getsenv/getfenv not available","error") return
        end
        local ok, env = pcall(fenvFn, self.State.SelectedModule)
        if not ok or type(env) ~= "table" then
            self:_showNotification("Could not get script env","error") return
        end
        dumpData = env
        modeLbl.Text = "Script env: "..self.State.SelectedModule.Name.." ("..self:_tableLen(env).." keys)"
        renderDump(env)
        self:_showNotification("Script env dumped", "success")
    end

    local function doRegDump()
        if not getreg then
            self:_showNotification("getreg not available","error") return
        end
        local ok, reg = pcall(getreg)
        if not ok or type(reg) ~= "table" then
            self:_showNotification("getreg failed","error") return
        end
        -- flatten: getreg returns a list of values; we want the table entries
        local flat = {}
        for i, v in ipairs(reg) do
            if type(v) == "table" then
                for k, val in pairs(v) do
                    flat["reg["..i.."]."..tostring(k)] = val
                end
            else
                flat["reg["..i.."]"] = v
            end
        end
        dumpData = flat
        modeLbl.Text = "Registry dump ("..self:_tableLen(flat).." entries)"
        renderDump(flat)
        self:_showNotification("Registry dumped", "success")
    end

    local function doGEnvDump()
        dumpData = getgenv and getgenv() or getfenv and getfenv(0) or _G
        modeLld = "Global env dump"
        modeLbl.Text = "Global env ("..self:_tableLen(dumpData).." keys)"
        renderDump(dumpData)
        self:_showNotification("Global env dumped", "success")
    end

    local fenvBtn  = self:_createButton(parent,"Script Env",UDim2.fromOffset(80,22),UDim2.fromOffset(290,26),function() doFenvDump() end)
    local regBtn   = self:_createButton(parent,"Registry",UDim2.fromOffset(70,22),UDim2.fromOffset(374,26),function() doRegDump() end)
    local genvBtn  = self:_createButton(parent,"Global Env",UDim2.fromOffset(80,22),UDim2.fromOffset(448,26),function() doGEnvDump() end)

    local copyBtn = self:_createButton(parent,"Copy All",UDim2.fromOffset(65,22),UDim2.fromOffset(532,26),function()
        if not dumpData or self:_tableLen(dumpData)==0 then return end
        local lines = {}
        for k, v in pairs(dumpData) do
            local vt = type(v)
            local vs = vt=="function" and "fn@"..tostring(v):sub(-6)
                or vt=="table" and "{table}"
                or tostring(v):sub(1,80)
            table.insert(lines, string.format("%-35s  %-10s  %s", tostring(k):sub(1,35), vt, vs))
        end
        table.sort(lines)
        self:_setClipboard(table.concat(lines,"\n"))
        self:_showNotification("Env dump copied!", "success")
    end)

    filterBox:GetPropertyChangedSignal("Text"):Connect(function()
        if dumpData and next(dumpData) then
            renderDump(dumpData)
        end
    end)
end

function Modules.OverseerCE:Initialize()
    local module = self
    -- Base64 decoder setup (was in the old stub Initialize)
    if self.State.Base64DecoderEnabled then
        self:InitializeBase64Decoder()
    end
    -- Auto refresh setup (was in the old stub Initialize)
    if self.State.AutoRefresh then
        self:SetupAutoRefresh()
    end
    -- Freeze heartbeat loop
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
    local mt = (self:GetRawMetatable(moduleTable)) or {}
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
