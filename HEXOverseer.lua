local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

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
        GCScanResults = {},
        RegistryScanResults = {},
        NamecallLogs = {},
        UpvalueWatchers = {},
        InstructionProfiles = {},
        WatchList = {},
        XREFCache = {},
        HexViewData = nil,
        ProtoCache = {},
        AdvancedHooks = {},
        DependencyMap = {},
        UpvalueForceList = {},
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
        HEADER_HEIGHT = 24,
        ROW_HEIGHT = 20,
        BUTTON_HEIGHT = 23,
        PADDING = 4,
        ANIM_SPEED = 0.15,
        HOVER_BRIGHTNESS = 1.1
    }
}

function Modules.OverseerCE:_setClipboard(text)
    if setclipboard then
        pcall(setclipboard, text)
        return true
    elseif toclipboard then
        pcall(toclipboard, text)
        return true
    end
    return false
end

function Modules.OverseerCE:_showNotification(text, type)
    print("[Overseer CE] " .. text)
end

function Modules.OverseerCE:_createBorder(element, inset)
    local topBorder = Instance.new("Frame", element)
    topBorder.Name = "TopBorder"
    topBorder.Size = UDim2.new(1, 0, 0, 1)
    topBorder.Position = UDim2.new(0, 0, 0, 0)
    topBorder.BackgroundColor3 = inset and self.Config.BORDER_DARK or self.Config.BORDER_LIGHT
    topBorder.BorderSizePixel = 0
    topBorder.ZIndex = element.ZIndex + 1

    local leftBorder = Instance.new("Frame", element)
    leftBorder.Name = "LeftBorder"
    leftBorder.Size = UDim2.new(0, 1, 1, 0)
    leftBorder.Position = UDim2.new(0, 0, 0, 0)
    leftBorder.BackgroundColor3 = inset and self.Config.BORDER_DARK or self.Config.BORDER_LIGHT
    leftBorder.BorderSizePixel = 0
    leftBorder.ZIndex = element.ZIndex + 1

    local bottomBorder = Instance.new("Frame", element)
    bottomBorder.Name = "BottomBorder"
    bottomBorder.Size = UDim2.new(1, 0, 0, 1)
    bottomBorder.Position = UDim2.new(0, 0, 1, -1)
    bottomBorder.BackgroundColor3 = inset and self.Config.BORDER_LIGHT or self.Config.BORDER_DARK
    bottomBorder.BorderSizePixel = 0
    bottomBorder.ZIndex = element.ZIndex + 1

    local rightBorder = Instance.new("Frame", element)
    rightBorder.Name = "RightBorder"
    rightBorder.Size = UDim2.new(0, 1, 1, 0)
    rightBorder.Position = UDim2.new(1, -1, 0, 0)
    rightBorder.BackgroundColor3 = inset and self.Config.BORDER_LIGHT or self.Config.BORDER_DARK
    rightBorder.BorderSizePixel = 0
    rightBorder.ZIndex = element.ZIndex + 1
end

function Modules.OverseerCE:_createButton(parent, text, size, position, callback)
    local button = Instance.new("TextButton", parent)
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = self.Config.BG_PANEL
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = self.Config.TEXT_BLACK
    button.Font = Enum.Font.SourceSans
    button.TextSize = 12
    button.AutoButtonColor = false

    self:_createBorder(button, false)

    button.MouseButton1Click:Connect(callback)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = self.Config.BG_LIGHT
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = self.Config.BG_PANEL
    end)

    return button
end

function Modules.OverseerCE:ScanForModules()
    self.State.ModuleList = {}
    local targets = {
        ReplicatedStorage,
        Players.LocalPlayer,
        Workspace,
        game:GetService("StarterGui"),
        game:GetService("StarterPlayer")
    }

    for _, service in ipairs(targets) do
        if service then
            for _, obj in ipairs(service:GetDescendants()) do
                if obj:IsA("ModuleScript") then
                    table.insert(self.State.ModuleList, {
                        Instance = obj,
                        Name = obj.Name,
                        ParentName = obj.Parent and obj.Parent.Name or "N/A",
                        Path = obj:GetFullName()
                    })
                end
            end
        end
    end

    self:_showNotification("Discovered " .. #self.State.ModuleList .. " modules", "success")
end

function Modules.OverseerCE:LoadAndInspectModule(moduleScript)
    local success, result = pcall(function()
        return require(moduleScript)
    end)

    if success then
        self.State.SelectedModule = moduleScript
        self.State.CurrentTable = result
        self.State.PathStack = {}
        self:_showNotification("Poisoning context set: " .. moduleScript.Name, "success")
    else
        self:_showNotification("Failed to require module: " .. tostring(result), "error")
    end
end

function Modules.OverseerCE:ScanGarbageCollector(options)
    if not getgc then
        return {Success = false, Error = "getgc not available"}
    end

    local results = {}
    local scanned = 0
    local maxResults = options.MaxResults or 100

    self:_showNotification("Scanning GC... This may take a moment", "info")

    local gcObjects = getgc(true)
    for _, obj in ipairs(gcObjects) do
        if #results >= maxResults then
            break
        end

        scanned = scanned + 1
        local objType = type(obj)

        if options.ReturnType and objType ~= options.ReturnType then
            continue
        end

        if objType == "function" then
            local matched = false
            local matchInfo = {}

            if options.UpvalueName and debug and debug.getupvalues then
                local success, upvalues = pcall(debug.getupvalues, obj)
                if success and upvalues then
                    for upvName, upvValue in pairs(upvalues) do
                        if string.find(tostring(upvName), options.UpvalueName, 1, true) then
                            matched = true
                            table.insert(matchInfo, {Type = "Upvalue", Name = upvName, Value = upvValue})
                        end
                    end
                end
            end

            if options.ConstantValue and debug and debug.getconstants then
                local success, constants = pcall(debug.getconstants, obj)
                if success and constants then
                    for i, const in ipairs(constants) do
                        if tostring(const) == tostring(options.ConstantValue) then
                            matched = true
                            table.insert(matchInfo, {Type = "Constant", Index = i, Value = const})
                        end
                    end
                end
            end

            if options.FunctionName and debug and debug.getinfo then
                local success, info = pcall(debug.getinfo, obj)
                if success and info and info.name then
                    if string.find(info.name, options.FunctionName, 1, true) then
                        matched = true
                        table.insert(matchInfo, {Type = "FunctionName", Name = info.name})
                    end
                end
            end

            if matched or not (options.UpvalueName or options.ConstantValue or options.FunctionName) then
                table.insert(results, {
                    Object = obj,
                    Type = "function",
                    MatchInfo = matchInfo,
                    Scanned = scanned
                })
            end
        elseif objType == "table" then
            if not options.ReturnType or options.ReturnType == "table" then
                table.insert(results, {
                    Object = obj,
                    Type = "table",
                    MatchInfo = {},
                    Scanned = scanned
                })
            end
        end
    end

    self.State.GCScanResults = results
    self:_showNotification("GC Scan complete: " .. #results .. " results (scanned " .. scanned .. " objects)", "success")

    return {
        Success = true,
        Results = results,
        TotalScanned = scanned
    }
end

function Modules.OverseerCE:ScanRegistry(searchTerm)
    if not getreg then
        return {Success = false, Error = "getreg not available"}
    end

    local results = {}
    local registry = getreg()
    local scanned = 0

    self:_showNotification("Scanning Registry...", "info")

    for key, value in pairs(registry) do
        scanned = scanned + 1
        local keyStr = tostring(key)
        local valueStr = tostring(value)

        if not searchTerm or string.find(keyStr, searchTerm, 1, true) or string.find(valueStr, searchTerm, 1, true) then
            table.insert(results, {
                Key = key,
                Value = value,
                KeyType = type(key),
                ValueType = type(value)
            })
        end
    end

    self.State.RegistryScanResults = results
    self:_showNotification("Registry Scan complete: " .. #results .. " results", "success")

    return {
        Success = true,
        Results = results,
        TotalScanned = scanned
    }
end

function Modules.OverseerCE:InstallNamecallInterceptor(options)
    if not hookmetamethod then
        return {Success = false, Error = "hookmetamethod not available"}
    end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = self.Name

            if not options.FilterRemote or remoteName == options.FilterRemote then
                local logEntry = {
                    Remote = remoteName,
                    Method = method,
                    Arguments = args,
                    Timestamp = tick(),
                    CallerInfo = debug.info(2, "sl")
                }

                table.insert(Modules.OverseerCE.State.NamecallLogs, logEntry)

                if options.OnIntercept then
                    local success, result = pcall(options.OnIntercept, self, method, args)
                    if not success then
                        warn("[Namecall Interceptor] Callback error:", result)
                    end
                end

                if not options.LogOnly then
                    print(string.format("[Namecall] %s:%s with %d args", remoteName, method, #args))
                end
            end
        end

        return oldNamecall(self, ...)
    end)

    self:_showNotification("Namecall interceptor installed", "success")
    return {Success = true}
end

function Modules.OverseerCE:CreateUpvalueWatcher(func, upvalueName, onChange)
    if not debug or not debug.getupvalues then
        return {Success = false, Error = "debug.getupvalues not available"}
    end

    local watcherId = HttpService:GenerateGUID(false)

    self.State.UpvalueWatchers[watcherId] = {
        Function = func,
        UpvalueName = upvalueName,
        LastValue = nil,
        OnChange = onChange,
        Active = true
    }

    self:_showNotification("Upvalue watcher created for: " .. upvalueName, "success")
    return {Success = true, WatcherId = watcherId}
end

function Modules.OverseerCE:ForceUpvalue(func, upvalueName, value, persistent)
    if not debug or not debug.setupvalue then
        return {Success = false, Error = "debug.setupvalue not available"}
    end

    local success, result = pcall(function()
        local upvalues = debug.getupvalues(func)
        for name, val in pairs(upvalues) do
            if name == upvalueName then
                debug.setupvalue(func, name, value)

                if persistent then
                    local forceId = HttpService:GenerateGUID(false)
                    self.State.UpvalueForceList[forceId] = {
                        Function = func,
                        UpvalueName = upvalueName,
                        Value = value,
                        Active = true
                    }
                end

                return true
            end
        end
        return false
    end)

    if success and result then
        self:_showNotification("Upvalue forced: " .. upvalueName, "success")
        return {Success = true}
    else
        return {Success = false, Error = "Failed to set upvalue"}
    end
end

function Modules.OverseerCE:ProfileFunction(func, duration)
    if not debug or not debug.sethook then
        return {Success = false, Error = "debug.sethook not available"}
    end

    local profile = {
        Function = func,
        LineCounts = {},
        CallCount = 0,
        StartTime = tick(),
        Duration = duration or 5
    }

    local funcInfo = debug.getinfo(func)
    local targetSource = funcInfo.source
    local oldHook = debug.gethook()

    debug.sethook(function(event)
        if event == "line" then
            local info = debug.getinfo(2, "Sl")
            if info.source == targetSource then
                local line = info.currentline
                profile.LineCounts[line] = (profile.LineCounts[line] or 0) + 1
            end
        elseif event == "call" then
            local info = debug.getinfo(2, "S")
            if info.source == targetSource then
                profile.CallCount = profile.CallCount + 1
            end
        end
    end, "lc")

    task.delay(duration or 5, function()
        debug.sethook(oldHook)

        local sortedLines = {}
        for line, count in pairs(profile.LineCounts) do
            table.insert(sortedLines, {Line = line, Count = count})
        end

        table.sort(sortedLines, function(a, b)
            return a.Count > b.Count
        end)

        profile.TopLines = sortedLines
        profile.EndTime = tick()

        local profileId = HttpService:GenerateGUID(false)
        self.State.InstructionProfiles[profileId] = profile

        self:_showNotification("Profile complete: " .. #sortedLines .. " lines executed", "success")
    end)

    self:_showNotification("Profiling started for " .. (duration or 5) .. " seconds...", "info")
    return {Success = true, Profile = profile}
end

function Modules.OverseerCE:AddWatch(table, key, options)
    local watchId = HttpService:GenerateGUID(false)

    self.State.WatchList[watchId] = {
        Table = table,
        Key = key,
        LastValue = table[key],
        Options = options or {},
        Active = true,
        ChangeCount = 0
    }

    self:_showNotification("Watch added for: " .. tostring(key), "success")
    return {Success = true, WatchId = watchId}
end

function Modules.OverseerCE:RemoveWatch(watchId)
    if self.State.WatchList[watchId] then
        self.State.WatchList[watchId] = nil
        self:_showNotification("Watch removed", "success")
        return {Success = true}
    end

    return {Success = false, Error = "Watch not found"}
end

function Modules.OverseerCE:FindXREFs(targetFunc)
    if not getgc or not debug then
        return {Success = false, Error = "getgc or debug library not available"}
    end

    local xrefs = {
        Callers = {},
        SharedUpvalues = {},
        UpvalueUsers = {}
    }

    self:_showNotification("Scanning for XREFs...", "info")

    local targetUpvalues = {}
    if debug.getupvalues then
        local success, upvals = pcall(debug.getupvalues, targetFunc)
        if success and upvals then
            targetUpvalues = upvals
        end
    end

    local gcFuncs = getgc(false)
    for _, func in ipairs(gcFuncs) do
        if type(func) == "function" and func ~= targetFunc then
            if debug.getupvalues then
                local success, upvals = pcall(debug.getupvalues, func)
                if success and upvals then
                    for upvName, upvValue in pairs(upvals) do
                        if upvValue == targetFunc then
                            table.insert(xrefs.Callers, {
                                Function = func,
                                UpvalueName = upvName,
                                Type = "DirectReference"
                            })
                        end

                        for targetUpvName, targetUpvValue in pairs(targetUpvalues) do
                            if upvValue == targetUpvValue and type(upvValue) == "table" then
                                table.insert(xrefs.SharedUpvalues, {
                                    Function = func,
                                    SharedUpvalue = upvName,
                                    OriginalName = targetUpvName
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    local xrefId = HttpService:GenerateGUID(false)
    self.State.XREFCache[xrefId] = xrefs

    self:_showNotification(
        string.format("XREF scan complete: %d callers, %d shared upvalues", #xrefs.Callers, #xrefs.SharedUpvalues),
        "success"
    )

    return {
        Success = true,
        XREFs = xrefs,
        XREFId = xrefId
    }
end

function Modules.OverseerCE:CreateHexView(data)
    local hexData = {
        Raw = data,
        Type = type(data),
        Bytes = {},
        ASCII = {}
    }

    if type(data) == "string" then
        for i = 1, #data do
            local byte = string.byte(data, i)
            table.insert(hexData.Bytes, byte)

            if byte >= 32 and byte <= 126 then
                table.insert(hexData.ASCII, string.char(byte))
            else
                table.insert(hexData.ASCII, ".")
            end
        end
    else
        hexData.Error = "Only strings can be viewed in hex mode"
    end

    self.State.HexViewData = hexData
    return hexData
end

function Modules.OverseerCE:FormatHexView(hexData, bytesPerLine)
    bytesPerLine = bytesPerLine or 16
    local lines = {}

    for i = 1, #hexData.Bytes, bytesPerLine do
        local offset = string.format("%08X", i - 1)
        local hexPart = {}
        local asciiPart = {}

        for j = 0, bytesPerLine - 1 do
            local idx = i + j
            if hexData.Bytes[idx] then
                table.insert(hexPart, string.format("%02X", hexData.Bytes[idx]))
                table.insert(asciiPart, hexData.ASCII[idx])
            else
                table.insert(hexPart, "  ")
                table.insert(asciiPart, " ")
            end

            if j == 7 then
                table.insert(hexPart, " ")
            end
        end

        local line = string.format("%s  %s  %s",
            offset,
            table.concat(hexPart, " "),
            table.concat(asciiPart, "")
        )

        table.insert(lines, line)
    end

    return table.concat(lines, "\n")
end

function Modules.OverseerCE:AnalyzeProtos(func)
    if not debug or not debug.getprotos then
        return {Success = false, Error = "debug.getprotos not available"}
    end

    local analysis = {
        Function = func,
        Protos = {},
        Constants = {},
        Upvalues = {},
        Info = {}
    }

    if debug.getinfo then
        analysis.Info = debug.getinfo(func)
    end

    local success, protos = pcall(debug.getprotos, func)
    if success and protos then
        for i, proto in ipairs(protos) do
            local protoInfo = {
                Index = i,
                Function = proto,
                Constants = {},
                Upvalues = {}
            }

            if debug.getconstants then
                local protoConstants = debug.getconstants(proto)
                protoInfo.Constants = protoConstants or {}
            end

            if debug.getupvalues then
                local protoUpvalues = debug.getupvalues(proto)
                protoInfo.Upvalues = protoUpvalues or {}
            end

            table.insert(analysis.Protos, protoInfo)
        end
    end

    if debug.getconstants then
        local success, constants = pcall(debug.getconstants, func)
        if success and constants then
            analysis.Constants = constants
        end
    end

    if debug.getupvalues then
        local success, upvalues = pcall(debug.getupvalues, func)
        if success and upvalues then
            analysis.Upvalues = upvalues
        end
    end

    local protoId = HttpService:GenerateGUID(false)
    self.State.ProtoCache[protoId] = analysis

    self:_showNotification(string.format("Proto analysis complete: %d nested functions", #analysis.Protos), "success")

    return {
        Success = true,
        Analysis = analysis,
        ProtoId = protoId
    }
end

function Modules.OverseerCE:MapDependencies(rootModule)
    local depMap = {
        Root = rootModule,
        Dependencies = {},
        SharedReferences = {}
    }

    local visited = {}

    local function scanTable(tbl, path, depth)
        if depth > 10 or visited[tbl] then
            return
        end

        visited[tbl] = true

        for key, value in pairs(tbl) do
            local newPath = path .. "." .. tostring(key)

            if type(value) == "table" then
                table.insert(depMap.Dependencies, {
                    Path = newPath,
                    Type = "table",
                    Value = value
                })
                scanTable(value, newPath, depth + 1)
            elseif type(value) == "function" then
                table.insert(depMap.Dependencies, {
                    Path = newPath,
                    Type = "function",
                    Value = value
                })

                if debug and debug.getupvalues then
                    local upvals = debug.getupvalues(value)
                    if upvals then
                        for upvName, upvVal in pairs(upvals) do
                            if type(upvVal) == "table" or type(upvVal) == "function" then
                                table.insert(depMap.SharedReferences, {
                                    FunctionPath = newPath,
                                    UpvalueName = upvName,
                                    UpvalueType = type(upvVal)
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    if type(rootModule) == "table" then
        scanTable(rootModule, "root", 0)
    end

    self:_showNotification(string.format("Dependency map created: %d dependencies", #depMap.Dependencies), "success")

    return {
        Success = true,
        DependencyMap = depMap
    }
end

function Modules.OverseerCE:StartMonitoring()
    -- Monitor upvalue watchers
    RunService.Heartbeat:Connect(function()
        for watcherId, watcher in pairs(self.State.UpvalueWatchers) do
            if watcher.Active then
                local success, currentValue = pcall(function()
                    local upvals = debug.getupvalues(watcher.Function)
                    return upvals[watcher.UpvalueName]
                end)

                if success and currentValue ~= watcher.LastValue then
                    if watcher.OnChange then
                        pcall(watcher.OnChange, watcher.LastValue, currentValue)
                    end
                    watcher.LastValue = currentValue
                end
            end
        end
    end)

    -- Monitor watch list
    RunService.Heartbeat:Connect(function()
        for watchId, watch in pairs(self.State.WatchList) do
            if watch.Active then
                local success, currentValue = pcall(function()
                    return watch.Table[watch.Key]
                end)

                if success and currentValue ~= watch.LastValue then
                    watch.ChangeCount = watch.ChangeCount + 1

                    if watch.Options.OnChange then
                        pcall(watch.Options.OnChange, watch.LastValue, currentValue)
                    end

                    if watch.Options.Alert then
                        self:_showNotification(
                            string.format("Watch alert: %s changed!", tostring(watch.Key)),
                            "warning"
                        )
                    end

                    if watch.Options.PlaySound then
                        pcall(function()
                            local sound = Instance.new("Sound")
                            sound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
                            sound.Volume = 0.5
                            sound.Parent = game:GetService("SoundService")
                            sound:Play()
                            game:GetService("Debris"):AddItem(sound, 1)
                        end)
                    end

                    watch.LastValue = currentValue
                end
            end
        end
    end)

    -- Monitor forced upvalues
    RunService.Heartbeat:Connect(function()
        for forceId, force in pairs(self.State.UpvalueForceList) do
            if force.Active then
                pcall(function()
                    debug.setupvalue(force.Function, force.UpvalueName, force.Value)
                end)
            end
        end
    end)

    -- Monitor frozen values
    RunService.Heartbeat:Connect(function()
        for patchId, patch in pairs(self.State.FreezeList) do
            pcall(function()
                if setreadonly then
                    setreadonly(patch.Table, false)
                elseif make_writeable then
                    make_writeable(patch.Table)
                end

                rawset(patch.Table, patch.Key, patch.NewValue)

                if setreadonly then
                    setreadonly(patch.Table, true)
                end
            end)
        end
    end)
end

function Modules.OverseerCE:CreateEnhancedUI()
    if self.State.UI then
        self.State.UI:Destroy()
    end

    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "OverseerCE_Enhanced"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.fromOffset(900, 600)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = self.Config.BG_PANEL
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 100

    self:_createBorder(mainFrame, false)

    -- Title Bar
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 24)
    titleBar.BackgroundColor3 = self.Config.ACCENT_BLUE
    titleBar.BorderSizePixel = 0
    titleBar.ZIndex = 100

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -60, 1, 0)
    titleLabel.Position = UDim2.fromOffset(8, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "CEOverseer Enhanced - Advanced Module Poisoner"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 13
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 101

    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.fromOffset(20, 20)
    closeBtn.Position = UDim2.new(1, -22, 0, 2)
    closeBtn.BackgroundColor3 = self.Config.BG_PANEL
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = self.Config.TEXT_BLACK
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.TextSize = 12
    closeBtn.ZIndex = 101

    self:_createBorder(closeBtn, false)

    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Tab Container
    local tabContainer = Instance.new("Frame", mainFrame)
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 0, 30)
    tabContainer.Position = UDim2.fromOffset(0, 24)
    tabContainer.BackgroundColor3 = self.Config.BG_DARK
    tabContainer.BorderSizePixel = 0
    tabContainer.ZIndex = 100

    self:_createBorder(tabContainer, true)

    local tabs = {
        {Name = "Module Explorer", Panel = nil},
        {Name = "GC Scanner", Panel = nil},
        {Name = "Registry", Panel = nil},
        {Name = "Namecall", Panel = nil},
        {Name = "Watch List", Panel = nil},
        {Name = "XREF", Panel = nil},
        {Name = "Hex Editor", Panel = nil},
        {Name = "Proto Analysis", Panel = nil},
    }

    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -8, 1, -62)
    contentFrame.Position = UDim2.fromOffset(4, 58)
    contentFrame.BackgroundColor3 = self.Config.BG_LIGHT
    contentFrame.BorderSizePixel = 0
    contentFrame.ZIndex = 100

    self:_createBorder(contentFrame, true)

    for i, tab in ipairs(tabs) do
        local tabBtn = self:_createButton(
            tabContainer,
            tab.Name,
            UDim2.fromOffset(110, 26),
            UDim2.fromOffset(2 + (i - 1) * 112, 2),
            function()
                for _, t in ipairs(tabs) do
                    if t.Panel then
                        t.Panel.Visible = false
                    end
                end

                if tab.Panel then
                    tab.Panel.Visible = true
                end
            end
        )
        tabBtn.ZIndex = 101
        tabBtn.TextSize = 10

        local panel = Instance.new("Frame", contentFrame)
        panel.Name = tab.Name .. "Panel"
        panel.Size = UDim2.new(1, -8, 1, -8)
        panel.Position = UDim2.fromOffset(4, 4)
        panel.BackgroundTransparency = 1
        panel.Visible = (i == 1)
        panel.ZIndex = 101

        tab.Panel = panel
    end

    self:CreateModuleExplorerPanel(tabs[1].Panel)
    self:CreateGCScannerPanel(tabs[2].Panel)
    self:CreateRegistryPanel(tabs[3].Panel)
    self:CreateNamecallPanel(tabs[4].Panel)
    self:CreateWatchListPanel(tabs[5].Panel)
    self:CreateXREFPanel(tabs[6].Panel)
    self:CreateHexEditorPanel(tabs[7].Panel)
    self:CreateProtoPanel(tabs[8].Panel)

    self.State.UI = screenGui

    -- Dragging functionality
    local dragging, dragInput, dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Modules.OverseerCE:CreateModuleExplorerPanel(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Game Hierarchy Module Explorer"
    title.TextColor3 = self.Config.TEXT_BLACK
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102

    local searchBar = Instance.new("TextBox", parent)
    searchBar.Size = UDim2.new(1, -110, 0, 24)
    searchBar.Position = UDim2.fromOffset(0, 30)
    searchBar.PlaceholderText = "Search for high-value modules..."
    searchBar.BackgroundColor3 = self.Config.BG_WHITE
    searchBar.Text = ""
    searchBar.TextColor3 = self.Config.TEXT_BLACK
    searchBar.Font = Enum.Font.SourceSans
    searchBar.TextSize = 11
    searchBar.ZIndex = 102

    self:_createBorder(searchBar, true)

    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1, 0, 1, -70)
    scroll.Position = UDim2.fromOffset(0, 65)
    scroll.BackgroundColor3 = self.Config.BG_WHITE
    scroll.BorderSizePixel = 0
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollBarThickness = 8
    scroll.ZIndex = 102

    self:_createBorder(scroll, true)

    local list = Instance.new("UIListLayout", scroll)
    list.Padding = UDim.new(0, 2)

    local function populate(filter)
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, mod in ipairs(self.State.ModuleList) do
            if filter == "" or mod.Name:lower():find(filter:lower()) or mod.ParentName:lower():find(filter:lower()) then
                local btn = self:_createButton(
                    scroll,
                    " [" .. mod.ParentName .. "] " .. mod.Name,
                    UDim2.new(1, -10, 0, 20),
                    UDim2.new(0, 0, 0, 0),
                    function()
                        self:LoadAndInspectModule(mod.Instance)
                    end
                )
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.TextSize = 11
                btn.ZIndex = 103
            end
        end
    end

    local refreshBtn = self:_createButton(
        parent,
        "Scan Hierarchy",
        UDim2.fromOffset(100, 24),
        UDim2.new(1, -100, 0, 30),
        function()
            self:ScanForModules()
            populate(searchBar.Text)
        end
    )
    refreshBtn.ZIndex = 102

    searchBar:GetPropertyChangedSignal("Text"):Connect(function()
        populate(searchBar.Text)
    end)

    self:ScanForModules()
    populate("")
end

function Modules.OverseerCE:CreateGCScannerPanel(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Garbage Collector Scanner"
    title.TextColor3 = self.Config.TEXT_BLACK
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102

    local upvalueInput = Instance.new("TextBox", parent)
    upvalueInput.Size = UDim2.fromOffset(200, 22)
    upvalueInput.Position = UDim2.fromOffset(0, 30)
    upvalueInput.BackgroundColor3 = self.Config.BG_WHITE
    upvalueInput.BorderSizePixel = 0
    upvalueInput.PlaceholderText = "Upvalue name filter..."
    upvalueInput.Text = ""
    upvalueInput.TextColor3 = self.Config.TEXT_BLACK
    upvalueInput.Font = Enum.Font.SourceSans
    upvalueInput.TextSize = 11
    upvalueInput.ZIndex = 102

    self:_createBorder(upvalueInput, true)

    local constantInput = Instance.new("TextBox", parent)
    constantInput.Size = UDim2.fromOffset(200, 22)
    constantInput.Position = UDim2.fromOffset(210, 30)
    constantInput.BackgroundColor3 = self.Config.BG_WHITE
    constantInput.BorderSizePixel = 0
    constantInput.PlaceholderText = "Constant value filter..."
    constantInput.Text = ""
    constantInput.TextColor3 = self.Config.TEXT_BLACK
    constantInput.Font = Enum.Font.SourceSans
    constantInput.TextSize = 11
    constantInput.ZIndex = 102

    self:_createBorder(constantInput, true)

    local scanBtn = self:_createButton(
        parent,
        "Scan GC",
        UDim2.fromOffset(100, 22),
        UDim2.fromOffset(420, 30),
        function()
            local options = {
                UpvalueName = upvalueInput.Text ~= "" and upvalueInput.Text or nil,
                ConstantValue = constantInput.Text ~= "" and constantInput.Text or nil,
                ReturnType = "function",
                MaxResults = 50
            }

            local result = self:ScanGarbageCollector(options)

            if result.Success then
                for _, child in ipairs(parent:GetChildren()) do
                    if child.Name == "ResultsScroll" then
                        child:Destroy()
                    end
                end

                local resultsScroll = Instance.new("ScrollingFrame", parent)
                resultsScroll.Name = "ResultsScroll"
                resultsScroll.Size = UDim2.new(1, 0, 1, -60)
                resultsScroll.Position = UDim2.fromOffset(0, 60)
                resultsScroll.BackgroundColor3 = self.Config.BG_WHITE
                resultsScroll.BorderSizePixel = 0
                resultsScroll.ScrollBarThickness = 8
                resultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                resultsScroll.ZIndex = 102

                self:_createBorder(resultsScroll, true)

                local listLayout = Instance.new("UIListLayout", resultsScroll)
                listLayout.Padding = UDim.new(0, 2)

                for i, res in ipairs(result.Results) do
                    local row = Instance.new("TextLabel", resultsScroll)
                    row.Size = UDim2.new(1, -4, 0, 20)
                    row.BackgroundColor3 = i % 2 == 0 and self.Config.BG_LIGHT or self.Config.BG_WHITE
                    row.BorderSizePixel = 0
                    row.Text = string.format("[%d] Function - %d matches", i, #res.MatchInfo)
                    row.TextColor3 = self.Config.TEXT_BLACK
                    row.Font = Enum.Font.SourceSans
                    row.TextSize = 10
                    row.TextXAlignment = Enum.TextXAlignment.Left
                    row.ZIndex = 103
                end
            end
        end
    )
    scanBtn.ZIndex = 102
end

function Modules.OverseerCE:CreateRegistryPanel(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Lua Registry Scanner"
    title.TextColor3 = self.Config.TEXT_BLACK
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102

    local searchInput = Instance.new("TextBox", parent)
    searchInput.Size = UDim2.fromOffset(300, 22)
    searchInput.Position = UDim2.fromOffset(0, 30)
    searchInput.BackgroundColor3 = self.Config.BG_WHITE
    searchInput.BorderSizePixel = 0
    searchInput.PlaceholderText = "Search registry..."
    searchInput.Text = ""
    searchInput.TextColor3 = self.Config.TEXT_BLACK
    searchInput.Font = Enum.Font.SourceSans
    searchInput.TextSize = 11
    searchInput.ZIndex = 102

    self:_createBorder(searchInput, true)

    local scanBtn = self:_createButton(
        parent,
        "Scan Registry",
        UDim2.fromOffset(120, 22),
        UDim2.fromOffset(310, 30),
        function()
            local result = self:ScanRegistry(searchInput.Text ~= "" and searchInput.Text or nil)

            if result.Success then
                for _, child in ipairs(parent:GetChildren()) do
                    if child.Name == "ResultsScroll" then
                        child:Destroy()
                    end
                end

                local resultsScroll = Instance.new("ScrollingFrame", parent)
                resultsScroll.Name = "ResultsScroll"
                resultsScroll.Size = UDim2.new(1, 0, 1, -60)
                resultsScroll.Position = UDim2.fromOffset(0, 60)
                resultsScroll.BackgroundColor3 = self.Config.BG_WHITE
                resultsScroll.BorderSizePixel = 0
                resultsScroll.ScrollBarThickness = 8
                resultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                resultsScroll.ZIndex = 102

                self:_createBorder(resultsScroll, true)

                local listLayout = Instance.new("UIListLayout", resultsScroll)
                listLayout.Padding = UDim.new(0, 2)

                for i, res in ipairs(result.Results) do
                    local row = Instance.new("TextLabel", resultsScroll)
                    row.Size = UDim2.new(1, -4, 0, 20)
                    row.BackgroundColor3 = i % 2 == 0 and self.Config.BG_LIGHT or self.Config.BG_WHITE
                    row.BorderSizePixel = 0
                    row.Text = string.format("[%s] %s = %s", res.KeyType, tostring(res.Key), tostring(res.Value))
                    row.TextColor3 = self.Config.TEXT_BLACK
                    row.Font = Enum.Font.SourceSans
                    row.TextSize = 10
                    row.TextXAlignment = Enum.TextXAlignment.Left
                    row.ZIndex = 103
                end
            end
        end
    )
    scanBtn.ZIndex = 102
end

function Modules.OverseerCE:HookVMT(object, method, hook)
    if not hookmetamethod then
        return {Success = false, Error = "hookmetamethod not available"}
    end

    local hookId = HttpService:GenerateGUID(false)
    local originalMethod

    originalMethod = hookmetamethod(object, method, function(...)
        local args = {...}
        local hookResult = hook(originalMethod, unpack(args))

        if hookResult == nil then
            return originalMethod(...)
        else
            return hookResult
        end
    end)

    self.State.AdvancedHooks[hookId] = {
        Object = object,
        Method = method,
        Original = originalMethod,
        Hook = hook,
        Type = "VMT"
    }

    return {Success = true, HookId = hookId, Original = originalMethod}
end

function Modules.OverseerCE:InstallNamecallRedirector(options)
    if not hookmetamethod or not getnamecallmethod then
        return {Success = false, Error = "Required functions not available"}
    end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()

        if (method == "FireServer" or method == "InvokeServer") then
            local remoteName = self.Name

            if not options.FilterRemote or remoteName == options.FilterRemote then
                if options.LogCalls then
                    local logEntry = {
                        Remote = remoteName,
                        Method = method,
                        Arguments = args,
                        Timestamp = tick(),
                        FullPath = self:GetFullName()
                    }
                    table.insert(Modules.OverseerCE.State.NamecallLogs, logEntry)
                end

                if options.BlockCall then
                    return nil
                end

                if options.OnBeforeCall then
                    local modifiedArgs = options.OnBeforeCall(self, method, args)
                    if modifiedArgs then
                        args = modifiedArgs
                    end
                end

                local results = {oldNamecall(self, unpack(args))}

                if options.OnAfterCall and method == "InvokeServer" then
                    local modifiedResult = options.OnAfterCall(self, method, results[1])
                    if modifiedResult ~= nil then
                        return modifiedResult
                    end
                end

                return unpack(results)
            end
        end

        return oldNamecall(self, ...)
    end)

    self:_showNotification("Namecall redirector installed", "success")
    return {Success = true, OriginalNamecall = oldNamecall}
end

function Modules.OverseerCE:PatchProtoConstant(func, constantIndex, newValue)
    if not debug or not debug.setconstant then
        return {Success = false, Error = "debug.setconstant not available"}
    end

    local success, err = pcall(function()
        debug.setconstant(func, constantIndex, newValue)
    end)

    if success then
        local patchId = HttpService:GenerateGUID(false)
        self.State.ConstantPatches[patchId] = {
            Function = func,
            ConstantIndex = constantIndex,
            NewValue = newValue,
            Timestamp = tick()
        }

        self:_showNotification("Constant patched successfully", "success")
        return {Success = true, PatchId = patchId}
    else
        return {Success = false, Error = tostring(err)}
    end
end

function Modules.OverseerCE:ReplaceProto(func, protoIndex, newProto)
    if not debug or not debug.setproto then
        return {Success = false, Error = "debug.setproto not available"}
    end

    local success, err = pcall(function()
        debug.setproto(func, protoIndex, newProto)
    end)

    if success then
        self:_showNotification("Proto replaced successfully", "success")
        return {Success = true}
    else
        return {Success = false, Error = tostring(err)}
    end
end

function Modules.OverseerCE:ReplaceClosure(originalFunc, newFunc, stealthy)
    if not hookfunction and not replaceclosure then
        return {Success = false, Error = "hookfunction/replaceclosure not available"}
    end

    local original

    if hookfunction then
        original = hookfunction(originalFunc, newFunc)
    elseif replaceclosure then
        original = replaceclosure(originalFunc, newFunc)
    end

    local hookId = HttpService:GenerateGUID(false)
    self.State.AdvancedHooks[hookId] = {
        Original = original,
        Replacement = newFunc,
        Type = "ClosureReplacement",
        Stealthy = stealthy
    }

    self:_showNotification("Closure replaced", "success")
    return {Success = true, HookId = hookId, Original = original}
end

function Modules.OverseerCE:CreateShadowEnvironment(moduleScript)
    local detectionLog = {}
    local realEnv = getfenv(0)

    local shadowEnv = setmetatable({}, {
        __index = function(t, k)
            table.insert(detectionLog, {
                Type = "Read",
                Key = k,
                Timestamp = tick(),
                Traceback = debug.traceback()
            })
            return realEnv[k]
        end,
        __newindex = function(t, k, v)
            table.insert(detectionLog, {
                Type = "Write",
                Key = k,
                Value = v,
                Timestamp = tick()
            })
            realEnv[k] = v
        end
    })

    return {
        Environment = shadowEnv,
        Log = detectionLog
    }
end

function Modules.OverseerCE:InjectDependency(targetModule, dependencyName, customImplementation)
    if type(targetModule) ~= "table" then
        return {Success = false, Error = "Target must be a table"}
    end

    local injected = false

    for key, value in pairs(targetModule) do
        if type(value) == "function" then
            if debug and debug.getupvalues and debug.setupvalue then
                local upvalues = debug.getupvalues(value)
                if upvalues and upvalues[dependencyName] then
                    debug.setupvalue(value, dependencyName, customImplementation)
                    injected = true
                end
            end
        end
    end

    if targetModule[dependencyName] then
        targetModule[dependencyName] = customImplementation
        injected = true
    end

    if injected then
        local injectionId = HttpService:GenerateGUID(false)
        table.insert(self.State.InjectionHistory, {
            Id = injectionId,
            Module = targetModule,
            DependencyName = dependencyName,
            CustomImpl = customImplementation,
            Timestamp = tick()
        })

        self:_showNotification("Dependency injected: " .. dependencyName, "success")
        return {Success = true, InjectionId = injectionId}
    else
        return {Success = false, Error = "Dependency not found in module"}
    end
end

function Modules.OverseerCE:DumpBytecode(func)
    if not debug or not debug.getinfo then
        return {Success = false, Error = "Debug library not available"}
    end

    local info = debug.getinfo(func)

    local dump = {
        Source = info.source,
        LineDefined = info.linedefined,
        LastLineDefined = info.lastlinedefined,
        NumParams = info.numparams,
        IsVararg = info.is_vararg,
        Constants = {},
        Upvalues = {},
        Protos = {}
    }

    if debug.getconstants then
        local constants = debug.getconstants(func)
        if constants then
            for i, const in ipairs(constants) do
                dump.Constants[i] = {
                    Index = i,
                    Type = type(const),
                    Value = const
                }
            end
        end
    end

    if debug.getupvalues then
        local upvalues = debug.getupvalues(func)
        if upvalues then
            for name, value in pairs(upvalues) do
                table.insert(dump.Upvalues, {
                    Name = name,
                    Type = type(value),
                    Value = value
                })
            end
        end
    end

    if debug.getprotos then
        local protos = debug.getprotos(func)
        if protos then
            for i, proto in ipairs(protos) do
                local protoDump = self:DumpBytecode(proto)
                if protoDump.Success then
                    dump.Protos[i] = protoDump.Dump
                end
            end
        end
    end

    return {Success = true, Dump = dump}
end

function Modules.OverseerCE:TraceFunction(func, options)
    options = options or {}
    local callLog = {}
    local callCount = 0
    local maxCalls = options.MaxCalls or 100

    local original = hookfunction(func, function(...)
        if callCount >= maxCalls then
            return original(...)
        end

        callCount = callCount + 1
        local args = {...}

        local logEntry = {
            CallNumber = callCount,
            Timestamp = tick(),
            Arguments = options.LogArguments and args or nil,
            Traceback = debug.traceback()
        }

        local results = {original(...)}

        if options.LogReturns then
            logEntry.Returns = results
        end

        table.insert(callLog, logEntry)

        return unpack(results)
    end)

    local traceId = HttpService:GenerateGUID(false)
    self.State.CallTrackers[traceId] = {
        Function = func,
        Original = original,
        Log = callLog,
        Options = options
    }

    self:_showNotification("Function tracing started", "success")
    return {Success = true, TraceId = traceId, Log = callLog}
end

function Modules.OverseerCE:CreateRemoteBuffer(remoteName)
    local buffer = {
        Remote = remoteName,
        CapturedCalls = {},
        Paused = false
    }

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()

        if method == "FireServer" and self.Name == remoteName then
            local args = {...}

            if buffer.Paused then
                table.insert(buffer.CapturedCalls, {
                    Remote = self,
                    Arguments = args,
                    Timestamp = tick()
                })
                return nil
            end
        end

        return oldNamecall(self, ...)
    end)

    buffer.Release = function(modifiedArgs)
        for _, call in ipairs(buffer.CapturedCalls) do
            if modifiedArgs then
                call.Remote:FireServer(unpack(modifiedArgs))
            else
                call.Remote:FireServer(unpack(call.Arguments))
            end
        end
        buffer.CapturedCalls = {}
    end

    buffer.Clear = function()
        buffer.CapturedCalls = {}
    end

    buffer.Pause = function()
        buffer.Paused = true
    end

    buffer.Resume = function()
        buffer.Paused = false
    end

    return buffer
end

function Modules.OverseerCE:SpoofRemoteReturn(remoteName, spoofedReturn)
    if not hookmetamethod or not getnamecallmethod then
        return {Success = false, Error = "Required functions not available"}
    end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()

        if method == "InvokeServer" and self.Name == remoteName then
            table.insert(Modules.OverseerCE.State.NamecallLogs, {
                Remote = remoteName,
                Method = "InvokeServer",
                Arguments = {...},
                Spoofed = true,
                SpoofedReturn = spoofedReturn,
                Timestamp = tick()
            })
            return spoofedReturn
        end

        return oldNamecall(self, ...)
    end)

    self:_showNotification("Return spoofing installed for: " .. remoteName, "success")
    return {Success = true}
end

function Modules.OverseerCE:CreateNamecallPanel(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Namecall Interceptor & Redirection"
    title.TextColor3 = self.Config.TEXT_BLACK
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102

    local filterInput = Instance.new("TextBox", parent)
    filterInput.Size = UDim2.fromOffset(200, 22)
    filterInput.Position = UDim2.fromOffset(0, 30)
    filterInput.BackgroundColor3 = self.Config.BG_WHITE
    filterInput.BorderSizePixel = 0
    filterInput.PlaceholderText = "Filter by remote name..."
    filterInput.Text = ""
    filterInput.TextColor3 = self.Config.TEXT_BLACK
    filterInput.Font = Enum.Font.SourceSans
    filterInput.TextSize = 11
    filterInput.ZIndex = 102

    self:_createBorder(filterInput, true)

    local installBtn = self:_createButton(
        parent,
        "Install Interceptor",
        UDim2.fromOffset(140, 22),
        UDim2.fromOffset(210, 30),
        function()
            self:InstallNamecallRedirector({
                FilterRemote = filterInput.Text ~= "" and filterInput.Text or nil,
                LogCalls = true,
                BlockCall = false
            })
        end
    )
    installBtn.ZIndex = 102

    local spoofBtn = self:_createButton(
        parent,
        "Spoof Return",
        UDim2.fromOffset(120, 22),
        UDim2.fromOffset(360, 30),
        function()
            if filterInput.Text ~= "" then
                self:SpoofRemoteReturn(filterInput.Text, true)
            else
                self:_showNotification("Enter a remote name first", "warning")
            end
        end
    )
    spoofBtn.ZIndex = 102

    local bufferBtn = self:_createButton(
        parent,
        "Create Buffer",
        UDim2.fromOffset(120, 22),
        UDim2.fromOffset(490, 30),
        function()
            if filterInput.Text ~= "" then
                local buffer = self:CreateRemoteBuffer(filterInput.Text)
                buffer.Pause()
                self:_showNotification("Buffer created and paused for: " .. filterInput.Text, "success")
            else
                self:_showNotification("Enter a remote name first", "warning")
            end
        end
    )
    bufferBtn.ZIndex = 102

    local logScroll = Instance.new("ScrollingFrame", parent)
    logScroll.Name = "LogScroll"
    logScroll.Size = UDim2.new(1, 0, 1, -60)
    logScroll.Position = UDim2.fromOffset(0, 60)
    logScroll.BackgroundColor3 = self.Config.BG_WHITE
    logScroll.BorderSizePixel = 0
    logScroll.ScrollBarThickness = 8
    logScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    logScroll.ZIndex = 102

    self:_createBorder(logScroll, true)

    local listLayout = Instance.new("UIListLayout", logScroll)
    listLayout.Padding = UDim.new(0, 2)

    task.spawn(function()
        while true do
            task.wait(1)

            for _, child in ipairs(logScroll:GetChildren()) do
                if child:IsA("TextLabel") then
                    child:Destroy()
                end
            end

            local displayCount = math.min(#self.State.NamecallLogs, 50)
            for i = #self.State.NamecallLogs - displayCount + 1, #self.State.NamecallLogs do
                if i > 0 then
                    local log = self.State.NamecallLogs[i]
                    local row = Instance.new("TextLabel", logScroll)
                    row.Size = UDim2.new(1, -4, 0, 20)
                    row.BackgroundColor3 = i % 2 == 0 and self.Config.BG_LIGHT or self.Config.BG_WHITE
                    row.BorderSizePixel = 0
                    row.Text = string.format(
                        "[%.2f] %s:%s - %d args%s",
                        log.Timestamp % 1000,
                        log.Remote,
                        log.Method,
                        #log.Arguments,
                        log.Spoofed and " [SPOOFED]" or ""
                    )
                    row.TextColor3 = log.Spoofed and self.Config.WARNING_ORANGE or self.Config.TEXT_BLACK
                    row.Font = Enum.Font.SourceSans
                    row.TextSize = 10
                    row.TextXAlignment = Enum.TextXAlignment.Left
                    row.ZIndex = 103
                end
            end
        end
    end)
end

function Modules.OverseerCE:CreateWatchListPanel(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Watch List & Memory Monitoring"
    title.TextColor3 = self.Config.TEXT_BLACK
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102

    local infoLabel = Instance.new("TextLabel", parent)
    infoLabel.Size = UDim2.new(1, 0, 0, 40)
    infoLabel.Position = UDim2.fromOffset(0, 30)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Watches are added programmatically using:\nModules.OverseerCE:AddWatch(table, key, {OnChange = function, PlaySound = true})"
    infoLabel.TextColor3 = self.Config.TEXT_GRAY
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.ZIndex = 102

    local watchScroll = Instance.new("ScrollingFrame", parent)
    watchScroll.Size = UDim2.new(1, 0, 1, -80)
    watchScroll.Position = UDim2.fromOffset(0, 75)
    watchScroll.BackgroundColor3 = self.Config.BG_WHITE
    watchScroll.BorderSizePixel = 0
    watchScroll.ScrollBarThickness = 8
    watchScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    watchScroll.ZIndex = 102

    self:_createBorder(watchScroll, true)

    local listLayout = Instance.new("UIListLayout", watchScroll)
    listLayout.Padding = UDim.new(0, 2)

    task.spawn(function()
        while true do
            task.wait(0.5)

            for _, child in ipairs(watchScroll:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            for watchId, watch in pairs(self.State.WatchList) do
                if watch.Active then
                    local row = Instance.new("Frame", watchScroll)
                    row.Size = UDim2.new(1, -4, 0, 30)
                    row.BackgroundColor3 = self.Config.BG_LIGHT
                    row.BorderSizePixel = 0
                    row.ZIndex = 103

                    self:_createBorder(row, true)

                    local keyLabel = Instance.new("TextLabel", row)
                    keyLabel.Size = UDim2.new(0.3, 0, 1, 0)
                    keyLabel.Position = UDim2.fromOffset(4, 0)
                    keyLabel.BackgroundTransparency = 1
                    keyLabel.Text = tostring(watch.Key)
                    keyLabel.TextColor3 = self.Config.TEXT_BLACK
                    keyLabel.Font = Enum.Font.SourceSansBold
                    keyLabel.TextSize = 10
                    keyLabel.TextXAlignment = Enum.TextXAlignment.Left
                    keyLabel.ZIndex = 104

                    local valueLabel = Instance.new("TextLabel", row)
                    valueLabel.Size = UDim2.new(0.4, 0, 1, 0)
                    valueLabel.Position = UDim2.new(0.3, 0, 0, 0)
                    valueLabel.BackgroundTransparency = 1
                    valueLabel.Text = tostring(watch.LastValue)
                    valueLabel.TextColor3 = self.Config.TEXT_BLACK
                    valueLabel.Font = Enum.Font.SourceSans
                    valueLabel.TextSize = 10
                    valueLabel.TextXAlignment = Enum.TextXAlignment.Left
                    valueLabel.ZIndex = 104

                    local changesLabel = Instance.new("TextLabel", row)
                    changesLabel.Size = UDim2.new(0.2, 0, 1, 0)
                    changesLabel.Position = UDim2.new(0.7, 0, 0, 0)
                    changesLabel.BackgroundTransparency = 1
                    changesLabel.Text = watch.ChangeCount .. " changes"
                    changesLabel.TextColor3 = self.Config.TEXT_GRAY
                    changesLabel.Font = Enum.Font.SourceSans
                    changesLabel.TextSize = 9
                    changesLabel.TextXAlignment = Enum.TextXAlignment.Right
                    changesLabel.ZIndex = 104

                    local removeBtn = Instance.new("TextButton", row)
                    removeBtn.Size = UDim2.fromOffset(20, 20)
                    removeBtn.Position = UDim2.new(1, -24, 0, 5)
                    removeBtn.BackgroundColor3 = self.Config.FROZEN_RED
                    removeBtn.BorderSizePixel = 0
                    removeBtn.Text = "X"
                    removeBtn.TextColor3 = Color3.new(1, 1, 1)
                    removeBtn.Font = Enum.Font.SourceSansBold
                    removeBtn.TextSize = 10
                    removeBtn.ZIndex = 104

                    removeBtn.MouseButton1Click:Connect(function()
                        self:RemoveWatch(watchId)
                    end)
                end
            end
        end
    end)
end

function Modules.OverseerCE:CreateXREFPanel(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Cross-Reference (XREF) Tool"
    title.TextColor3 = self.Config.TEXT_BLACK
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102

    local infoLabel = Instance.new("TextLabel", parent)
    infoLabel.Size = UDim2.new(1, 0, 0, 60)
    infoLabel.Position = UDim2.fromOffset(0, 30)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "XREF finds all functions that reference a target function.\n\nUsage: Store your target function, then call:\nModules.OverseerCE:FindXREFs(targetFunction)\n\nResults show: Direct callers, shared upvalue users"
    infoLabel.TextColor3 = self.Config.TEXT_GRAY
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.ZIndex = 102

    local resultsScroll = Instance.new("ScrollingFrame", parent)
    resultsScroll.Size = UDim2.new(1, 0, 1, -100)
    resultsScroll.Position = UDim2.fromOffset(0, 95)
    resultsScroll.BackgroundColor3 = self.Config.BG_WHITE
    resultsScroll.BorderSizePixel = 0
    resultsScroll.ScrollBarThickness = 8
    resultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    resultsScroll.ZIndex = 102

    self:_createBorder(resultsScroll, true)

    local listLayout = Instance.new("UIListLayout", resultsScroll)
    listLayout.Padding = UDim.new(0, 2)
end

function Modules.OverseerCE:CreateHexEditorPanel(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Hex Editor / Binary Viewer"
    title.TextColor3 = self.Config.TEXT_BLACK
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102

    local inputBox = Instance.new("TextBox", parent)
    inputBox.Size = UDim2.new(1, -100, 0, 22)
    inputBox.Position = UDim2.fromOffset(0, 30)
    inputBox.BackgroundColor3 = self.Config.BG_WHITE
    inputBox.BorderSizePixel = 0
    inputBox.PlaceholderText = "Paste string data to view in hex..."
    inputBox.Text = ""
    inputBox.TextColor3 = self.Config.TEXT_BLACK
    inputBox.Font = Enum.Font.SourceSans
    inputBox.TextSize = 11
    inputBox.ZIndex = 102

    self:_createBorder(inputBox, true)

    local viewBtn = self:_createButton(
        parent,
        "View Hex",
        UDim2.fromOffset(90, 22),
        UDim2.new(1, -95, 0, 30),
        function()
            if inputBox.Text ~= "" then
                local hexData = self:CreateHexView(inputBox.Text)

                if hexData.Error then
                    self:_showNotification(hexData.Error, "error")
                    return
                end

                for _, child in ipairs(parent:GetChildren()) do
                    if child.Name == "HexDisplay" then
                        child:Destroy()
                    end
                end

                local hexDisplay = Instance.new("ScrollingFrame", parent)
                hexDisplay.Name = "HexDisplay"
                hexDisplay.Size = UDim2.new(1, 0, 1, -60)
                hexDisplay.Position = UDim2.fromOffset(0, 58)
                hexDisplay.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                hexDisplay.BorderSizePixel = 0
                hexDisplay.ScrollBarThickness = 8
                hexDisplay.AutomaticCanvasSize = Enum.AutomaticSize.Y
                hexDisplay.ZIndex = 102

                self:_createBorder(hexDisplay, true)

                local hexText = Instance.new("TextLabel", hexDisplay)
                hexText.Size = UDim2.new(1, -8, 1, 0)
                hexText.Position = UDim2.fromOffset(4, 4)
                hexText.BackgroundTransparency = 1
                hexText.Text = self:FormatHexView(hexData, 16)
                hexText.TextColor3 = Color3.fromRGB(0, 255, 0)
                hexText.Font = Enum.Font.Code
                hexText.TextSize = 9
                hexText.TextXAlignment = Enum.TextXAlignment.Left
                hexText.TextYAlignment = Enum.TextYAlignment.Top
                hexText.ZIndex = 103
                hexText.AutomaticSize = Enum.AutomaticSize.Y
            end
        end
    )
    viewBtn.ZIndex = 102
end

function Modules.OverseerCE:CreateProtoPanel(parent)
    local title = Instance.new("TextLabel", parent)
    title.Size = UDim2.new(1, 0, 0, 24)
    title.BackgroundTransparency = 1
    title.Text = "Proto Analysis & Function Patching"
    title.TextColor3 = self.Config.TEXT_BLACK
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102

    local infoLabel = Instance.new("TextLabel", parent)
    infoLabel.Size = UDim2.new(1, 0, 0, 80)
    infoLabel.Position = UDim2.fromOffset(0, 30)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = [[Proto Analysis examines function internals without decompiling.
Store target: _G.targetFunc = someFunction
Analyze: Modules.OverseerCE:AnalyzeProtos(_G.targetFunc)

Patching Tools:
- PatchProtoConstant(func, index, newValue)
- ReplaceProto(func, index, newProto) 
- ReplaceClosure(oldFunc, newFunc)]]
    infoLabel.TextColor3 = self.Config.TEXT_GRAY
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.TextWrapped = true
    infoLabel.ZIndex = 102

    local resultsScroll = Instance.new("ScrollingFrame", parent)
    resultsScroll.Size = UDim2.new(1, 0, 1, -120)
    resultsScroll.Position = UDim2.fromOffset(0, 115)
    resultsScroll.BackgroundColor3 = self.Config.BG_WHITE
    resultsScroll.BorderSizePixel = 0
    resultsScroll.ScrollBarThickness = 8
    resultsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    resultsScroll.ZIndex = 102

    self:_createBorder(resultsScroll, true)

    local listLayout = Instance.new("UIListLayout", resultsScroll)
    listLayout.Padding = UDim.new(0, 2)

    -- Refresh results every 2 seconds
    task.spawn(function()
        while true do
            task.wait(2)

            for _, child in ipairs(resultsScroll:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end

            -- Display recent proto analyses
            local protoCount = 0
            for protoId, analysis in pairs(self.State.ProtoCache) do
                protoCount = protoCount + 1

                local row = Instance.new("Frame", resultsScroll)
                row.Size = UDim2.new(1, -4, 0, 35)
                row.BackgroundColor3 = self.Config.BG_LIGHT
                row.BorderSizePixel = 0
                row.ZIndex = 103

                self:_createBorder(row, true)

                local header = Instance.new("TextLabel", row)
                header.Size = UDim2.new(0.7, 0, 0.6, 0)
                header.Position = UDim2.fromOffset(4, 2)
                header.BackgroundTransparency = 1
                header.Text = string.format(
                    "Proto #%d: %d nested, %d consts",
                    analysis.Index or protoCount,
                    #analysis.Protos or 0,
                    #analysis.Constants or 0
                )
                header.TextColor3 = self.Config.TEXT_BLACK
                header.Font = Enum.Font.SourceSansBold
                header.TextSize = 11
                header.TextXAlignment = Enum.TextXAlignment.Left
                header.ZIndex = 104

                local copyBtn = self:_createButton(
                    row,
                    "Copy",
                    UDim2.fromOffset(40, 18),
                    UDim2.new(0.72, 0, 0.2, 0),
                    function()
                        self:_setClipboard("Modules.OverseerCE.State.ProtoCache['" .. protoId .. "']")
                    end
                )
                copyBtn.ZIndex = 104
            end

            if protoCount == 0 then
                local emptyLabel = Instance.new("TextLabel", resultsScroll)
                emptyLabel.Size = UDim2.new(1, 0, 0, 30)
                emptyLabel.BackgroundTransparency = 1
                emptyLabel.Text = "No proto analyses yet. Run AnalyzeProtos(targetFunc)"
                emptyLabel.TextColor3 = self.Config.TEXT_GRAY
                emptyLabel.Font = Enum.Font.SourceSans
                emptyLabel.TextSize = 11
                emptyLabel.ZIndex = 103
            end
        end
    end)
end

-- Initialization
function Modules.OverseerCE:Init()
    self:ScanForModules()
    self:StartMonitoring()

    -- F10 to toggle UI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if input.KeyCode == Enum.KeyCode.F10 then
            self.State.IsEnabled = not self.State.IsEnabled

            if self.State.IsEnabled then
                self:CreateEnhancedUI()
                self:_showNotification("Overseer CE Enhanced - Loaded ✓", "success")
            else
                if self.State.UI then
                    self.State.UI:Destroy()
                    self.State.UI = nil
                end
            end
        elseif input.KeyCode == Enum.KeyCode.F11 then
            self:ScanForModules()
            self:_showNotification("Full hierarchy scan complete", "success")
        end
    end)

    print("[OverseerCE] Initialized. Press F10 to open, F11 to rescan modules")
end

-- Auto-init when loaded
if _G.OverseerCE_Loaded ~= true then
    _G.OverseerCE_Loaded = true
    Modules.OverseerCE:Init()
end

return Modules.OverseerCE
