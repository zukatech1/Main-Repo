print("made by zuka hooking into the adonis core.client")
print("updated on march 13 fri 10:35pm")
if getgenv().__ZUKA_BYPASS_LOADED then return end
getgenv().__ZUKA_BYPASS_LOADED = true
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
repeat task.wait(0.1) until Players.LocalPlayer
local LocalPlayer = Players.LocalPlayer
local newcc = newcclosure or function(f) return f end
local hookf = hookfunction
local get_mt = getrawmetatable
local set_ro = setreadonly
local gc = getgc or get_gc_objects
local Stats = {
    KickAttempts = 0,
    RemotesBlocked = 0,
    DetectionsCaught = 0,
    FunctionsHooked = 0,
    ClientChecksBlocked = 0,
}
local HookedFunctions = {}
local function safeHook(fn, replacement)
    if type(fn) ~= "function" then return false end
    hookf(fn, newcc(replacement))
    table.insert(HookedFunctions, fn)
    Stats.FunctionsHooked += 1
    return true
end
local function findACTable()
    for _, v in gc(true) do
        if type(v) == "table" then
            local hasDetected = type(rawget(v, "Detected")) == "function"
            local hasRemovePlayer = type(rawget(v, "RemovePlayer")) == "function"
            local hasCheckAllClients = type(rawget(v, "CheckAllClients")) == "function"
            local hasKickedPlayers = rawget(v, "KickedPlayers") ~= nil
            local hasSpoofCache = rawget(v, "SpoofCheckCache") ~= nil
            local hasTimeoutLimit = rawget(v, "ClientTimeoutLimit") ~= nil
            local score = (hasDetected and 1 or 0)
                + (hasRemovePlayer and 1 or 0)
                + (hasCheckAllClients and 1 or 0)
                + (hasKickedPlayers and 1 or 0)
                + (hasSpoofCache and 1 or 0)
                + (hasTimeoutLimit and 1 or 0)
            if score >= 3 then
                return v
            end
        end
    end
    return nil
end
local function hookACTable(tbl)
    if not tbl then return end
    if type(tbl.Detected) == "function" then
        safeHook(tbl.Detected, function(player, action, info)
            Stats.DetectionsCaught += 1
        end)
    end
    if type(tbl.RemovePlayer) == "function" then
        safeHook(tbl.RemovePlayer, function(p, info)
            Stats.KickAttempts += 1
        end)
    end
    if type(tbl.CheckAllClients) == "function" then
        safeHook(tbl.CheckAllClients, function()
            Stats.ClientChecksBlocked += 1
        end)
    end
    if type(tbl.UserSpoofCheck) == "function" then
        safeHook(tbl.UserSpoofCheck, function(p, ...)
            return nil
        end)
    end
    if type(tbl.CharacterCheck) == "function" then
        safeHook(tbl.CharacterCheck, function(player, ...)
        end)
    end
    if type(tbl.KickedPlayers) == "table" then
        local mt = getmetatable(tbl.KickedPlayers) or {}
        rawset(mt, "__index", function() return false end)
        rawset(mt, "__newindex", function() end)
        setmetatable(tbl.KickedPlayers, mt)
    end
    if type(tbl.SpoofCheckCache) == "table" then
        local mt = {}
        rawset(mt, "__index", function(t, k)
            return {{
                Id = k,
                Username = LocalPlayer.Name,
                DisplayName = LocalPlayer.DisplayName
            }}
        end)
        setmetatable(tbl.SpoofCheckCache, mt)
    end
    tbl.ClientTimeoutLimit = math.huge
end
local function findAndPatchRemoteClients()
    local userId = tostring(LocalPlayer.UserId)
    for _, v in gc(true) do
        if type(v) == "table" then
            local client = rawget(v, userId)
            if type(client) == "table" and
               rawget(client, "LastUpdate") ~= nil and
               rawget(v, "MaxLen") ~= nil then
                task.spawn(function()
                    while task.wait(10) do
                        local c = v[userId]
                        if c then
                            c.LastUpdate = os.time()
                            c.PlayerLoaded = true
                        end
                    end
                end)
                return v
            end
        end
    end
end
local function installNamecallHook()
    local mt = get_mt(game)
    if not mt then return end
    local oldNamecall = mt.__namecall
    set_ro(mt, false)
    mt.__namecall = newcc(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if checkcaller() then
            return oldNamecall(self, ...)
        end
        if method == "Kick" and self == LocalPlayer then
            local msg = tostring(args[1] or ""):lower()
            if msg:find("adonis") or msg:find("anti cheat") or
               msg:find("detected") or msg:find("exploit") or
               msg:find("acli") then
                Stats.KickAttempts += 1
                return nil
            end
        end
        if method == "FireServer" or method == "InvokeServer" then
            local name = self.Name
            local blocked = {
                ["__FUNCTION"] = true,
                ["_FUNCTION"] = true,
                ["ClientCheck"] = true,
                ["ProcessCommand"] = true,
                ["LogError"] = true,
                ["ClientLoaded"] = true,
            }
            if blocked[name] then
                Stats.RemotesBlocked += 1
                if method == "InvokeServer" then
                    return "Pong"
                end
                return nil
            end
        end
        return oldNamecall(self, ...)
    end)
    set_ro(mt, true)
end
local function installDebugHooks()
    local oldInfo = debug.info or debug.getinfo
    if oldInfo then
        hookf(oldInfo, newcc(function(fn, ...)
            for _, hooked in ipairs(HookedFunctions) do
                if fn == hooked then return nil end
            end
            return oldInfo(fn, ...)
        end))
    end
    if debug.getupvalues then
        hookf(debug.getupvalues, newcc(function(fn, ...)
            for _, hooked in ipairs(HookedFunctions) do
                if fn == hooked then return {} end
            end
            return debug.getupvalues(fn, ...)
        end))
    end
    if debug.getlocals then
        hookf(debug.getlocals, newcc(function(fn, ...)
            for _, hooked in ipairs(HookedFunctions) do
                if fn == hooked then return {} end
            end
            return debug.getlocals(fn, ...)
        end))
    end
end
local function protectKick()
    local origKick = LocalPlayer.Kick
    safeHook(origKick, function(self, reason, ...)
        local msg = tostring(reason or ""):lower()
        if msg:find("adonis") or msg:find("anti cheat") or
           msg:find("exploit") or msg:find("acli") or
           msg:find("cheat") then
            Stats.KickAttempts += 1
            return nil
        end
        return origKick(self, reason, ...)
    end)
    task.spawn(function()
        while task.wait(5) do
            if LocalPlayer and LocalPlayer.Parent then
            end
        end
    end)
end
local oldRequire
oldRequire = hookf(getrenv().require, newcc(function(module)
    if not checkcaller() and typeof(module) == "Instance" then
        local name = module.Name:lower()
        if name:find("topbar") or name:find("icon") then
            return {}
        end
    end
    return oldRequire(module)
end))
local cachedACTable = nil
local function rescan()
    local tbl = findACTable()
    if tbl and tbl ~= cachedACTable then
        cachedACTable = tbl
        hookACTable(tbl)
    end
    findAndPatchRemoteClients()
end
local function initialize()
    installNamecallHook()
    installDebugHooks()
    protectKick()
    local tbl = findACTable()
    if tbl then
        cachedACTable = tbl
        hookACTable(tbl)
        warn("[AntiAdonis] Loaded")
    else
        warn("[AntiAdonis] Adonis has been removed.")
    end
    findAndPatchRemoteClients()
    task.spawn(function()
        while task.wait(20) do
            rescan()
        end
    end)
    task.spawn(function()
        while task.wait(60) do
            print(string.format(
                "[AntiAdonis] Runtime stats — Kicks blocked: %d | Remotes blocked: %d | Detections caught: %d | Client checks blocked: %d | Functions hooked: %d",
                Stats.KickAttempts, Stats.RemotesBlocked, Stats.DetectionsCaught, Stats.ClientChecksBlocked, Stats.FunctionsHooked
            ))
        end
    end)
end
getgenv().AntiAdonis = {
    Version = "1.0",
    Stats = Stats,
    Rescan = function()
        rescan()
        warn("[AntiAdonis] rescan complete")
    end,
    GetStats = function()
        return Stats
    end
}
initialize()
