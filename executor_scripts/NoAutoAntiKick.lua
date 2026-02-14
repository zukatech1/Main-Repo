--demonstration
local AntiKick = {}
AntiKick.__index = AntiKick

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    UserInputService = game:GetService("UserInputService"),
    TeleportService = game:GetService("TeleportService")
}

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local CONFIG = {
    enabled = true,
    logKicks = false,
    autoRejoin = true,
    heartbeatInterval = 0.1,
    proxyRemotes = true,
    blockKickMethods = true,
    spoofUserId = false
}

local OBFUSCATED = {
    kick = string.char(107,105,99,107),
    kickPlayer = string.char(107,105,99,107,80,108,97,121,101,114),
    ban = string.char(98,97,110),
    destroy = string.char(100,101,115,116,114,111,121),
    remove = string.char(114,101,109,111,118,101)
}

local ProxyRemotes = {}
local RealRemotes = {}

function AntiKick.new()
    local self = setmetatable({}, AntiKick)
    self.connections = {}
    self.proxies = {}
    self.isKicking = false
    self.metatableBackup = nil
    self.fireServerHooked = false
    self:safeInit()
    return self
end

function AntiKick:protectPlayerGui()
    pcall(function()
        local mt = getrawmetatable(game)
        if not self.metatableBackup then
            self.metatableBackup = mt.__namecall
        end
        
        local oldDestroy = self.metatableBackup
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(selfObj, ...)
            local method = getnamecallmethod()
            
            if (method == OBFUSCATED.destroy or method == OBFUSCATED.remove) then
                if selfObj == PlayerGui or (selfObj.Parent and selfObj.Parent:IsDescendantOf(PlayerGui)) then
                    return nil
                end
            end
            
            return oldDestroy(selfObj, ...)
        end)
        
        setreadonly(mt, true)
    end)
end

function AntiKick:proxyRemotes()
    if not CONFIG.proxyRemotes then return end
    
    pcall(function()
        for _, remote in pairs(Services.ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local success, remoteName = pcall(function() 
                    return remote.Name and remote.Name:lower() 
                end)
                
                if success and remoteName and remoteName:find(OBFUSCATED.kick) then
                    local proxySuccess, proxy = pcall(Instance.new, "RemoteEvent")
                    if proxySuccess then
                        proxy.Name = "Remote_" .. tostring(math.random(100000, 999999))
                        proxy.Parent = Services.ReplicatedStorage
                        
                        local oldFire = remote.FireServer
                        remote.FireServer = function(...)
                            if CONFIG.logKicks then
                                warn("[AntiKick] Blocked:", remote.Name)
                            end
                            return nil
                        end
                        
                        ProxyRemotes[remote] = proxy
                        RealRemotes[proxy] = remote
                    end
                end
            end
        end
    end)
end

function AntiKick:heartbeatRecovery()
    if self.heartbeatConnection then return end
    
    self.heartbeatConnection = spawn(function()
        while CONFIG.enabled do
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character.Parent == nil then
                    if not self.isKicking then
                        self.isKicking = true
                        self:recover()
                    end
                else
                    self.isKicking = false
                end
            end)
            wait(CONFIG.heartbeatInterval)
        end
    end)
end

function AntiKick:recover()
    pcall(function()
        LocalPlayer.CharacterAdded:Wait()
        wait(0.5)
        self:protectPlayerGui()
        self:proxyRemotes()
        if CONFIG.logKicks then
            print("[AntiKick] Recovered ✓")
        end
    end)
    self.isKicking = false
end

local function safeHookFireServer(antiKickInstance)
    pcall(function()
        local mt = getrawmetatable(game)
        local oldFireServer = mt.__namecall
        setreadonly(mt, false)
        
        mt.__namecall = newcclosure(function(selfObj, ...)
            local method = getnamecallmethod()
            
            if method == "FireServer" then
                local success, name = pcall(function() 
                    return selfObj.Name and tostring(selfObj.Name):lower() 
                end)
                
                if success and name and (
                    name:find(OBFUSCATED.kick) or 
                    name:find(OBFUSCATED.ban) or
                    name:find("admin") or
                    name:find("moderator")
                ) then
                    return nil
                end
            end
            
            return oldFireServer(selfObj, ...)
        end)
        
        setreadonly(mt, true)
        antiKickInstance.fireServerHooked = true
    end)
end

function AntiKick:bypassAdonis()
    local adonisPatterns = {
        "kickPlayer", "banPlayer", "forceLeave", "adminKick",
        "KohlsAdminKick", "HDAdminKick", "InfiniteYieldKick"
    }
    
    pcall(function()
        for _, pattern in ipairs(adonisPatterns) do
            for _, obj in pairs(Services.ReplicatedStorage:GetDescendants()) do
                local success, objName = pcall(function() return obj.Name end)
                if success and objName == pattern and obj:IsA("RemoteEvent") then
                    obj.FireServer = function() end
                end
            end
        end
    end)
end

function AntiKick:spoofUserId()
    if not CONFIG.spoofUserId then return end
    
    pcall(function()
        local mt = getrawmetatable(LocalPlayer)
        local oldIndex = mt.__index
        setreadonly(mt, false)
        
        mt.__index = newcclosure(function(selfObj, key)
            if key == "UserId" then
                return math.random(1000000, 9999999)
            end
            return oldIndex(selfObj, key)
        end)
        
        setreadonly(mt, true)
    end)
end

function AntiKick:antiRejoinKick()
    pcall(function()
        if LocalPlayer.OnClientKick then
            LocalPlayer.OnClientKick = function()
                if CONFIG.autoRejoin then
                    pcall(function()
                        Services.TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end)
                end
            end
        end
    end)
end

function AntiKick:safeInit()
    pcall(function()
        safeHookFireServer(self)
        self:protectPlayerGui()
        self:proxyRemotes()
        self:bypassAdonis()
        self:heartbeatRecovery()
        self:antiRejoinKick()
        
        if not self.remoteMonitor then
            self.remoteMonitor = Services.ReplicatedStorage.DescendantAdded:Connect(function(obj)
                if obj:IsA("RemoteEvent") then
                    self:proxyRemotes()
                end
            end)
        end
        
        print("[AntiKick] ✓ Initialized - Zero nil errors")
    end)
end

function AntiKick:toggle()
    CONFIG.enabled = not CONFIG.enabled
    print("AntiKick:", CONFIG.enabled and "ON" or "OFF")
end

function AntiKick:status()
    return {
        enabled = CONFIG.enabled,
        protectedRemotes = 0,
        heartbeatActive = CONFIG.enabled,
        fireServerHooked = self.fireServerHooked or false
    }
end

local antiKick = AntiKick.new()
_G.AntiKick = antiKick

Services.UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F9 then
        antiKick:toggle()
    end
end)

return antiKick