local Vanguard = {}
Vanguard.__index = Vanguard
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end
local CONFIG = {
    Enabled = true,
    Silent = false,
    DetectionKeys = {
        "kick", "ban", "unauthorized", "suspicious", "detected", 
        "integrity", "acli", "0x", "environment", "checkcaller"
    }
}
function Vanguard.new()
    local self = setmetatable({}, Vanguard)
    self:DeployGhostHooks()
    if not CONFIG.Silent then
        print("[Vanguard] Ghost-Stream Shield Active. Heartbeat is preserved.")
    end
    return self
end
function Vanguard:DeployGhostHooks()
    local oldKick
    oldKick = hookfunction(game.Players.LocalPlayer.Kick, newcclosure(function(selfObj, reason)
        if not checkcaller() and selfObj == LocalPlayer then
            warn("[Vanguard] Blocked Kick Attempt: " .. tostring(reason))
            return nil 
        end
        return oldKick(selfObj, reason)
    end))
    local oldDestroy
    oldDestroy = hookfunction(game.Destroy, newcclosure(function(selfObj)
        if not checkcaller() and selfObj == LocalPlayer then
            warn("[Vanguard] Blocked Destroy Attempt.")
            return nil
        end
        return oldDestroy(selfObj)
    end))
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(selfObj, ...)
        local method = getnamecallmethod()
        local args = {...}
        if not checkcaller() and CONFIG.Enabled then
            if (method == "Destroy" or method == "Remove") and selfObj.Name == "PlayerGui" then
                return nil
            end
            if method == "FireServer" then
                local remoteName = tostring(selfObj):lower()
                local isDetectionPacket = false
                for _, arg in pairs(args) do
                    if type(arg) == "string" then
                        local lowArg = arg:lower()
                        for _, key in ipairs(CONFIG.DetectionKeys) do
                            if lowArg:find(key) then
                                isDetectionPacket = true
                                break
                            end
                        end
                    end
                    if isDetectionPacket then break end
                end
                if isDetectionPacket then
                    warn("[Vanguard] Swallowed Detection Remote: " .. remoteName)
                    return nil
                end
            end
        end
        return oldNamecall(selfObj, ...)
    end))
end
if getgenv().VanguardInstance then
end
getgenv().VanguardInstance = Vanguard.new()
return getgenv().VanguardInstance
