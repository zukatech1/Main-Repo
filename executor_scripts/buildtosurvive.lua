local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Framework = ReplicatedStorage:WaitForChild("Framework")
local Library = require(Framework:WaitForChild("Library"))
local Network = Framework:WaitForChild("Modules"):WaitForChild("2 | Network")

local TARGET_WEAPON = "Sun Beam"
local lastEquipTime = 0
local equipCooldown = 2

local function applyModifications(statsTable: table)
    if not statsTable then return end
    statsTable.Cash = 999999999
    statsTable.Equipped = TARGET_WEAPON
    
    if statsTable.UpgradeSlots then statsTable.UpgradeSlots = 5 end
    
    if Library.Directory and Library.Directory.Upgrades and statsTable.Purchased then
        if not statsTable.Purchased.Upgrades then statsTable.Purchased.Upgrades = {} end
        for itemName, _ in pairs(Library.Directory.Upgrades) do
            if not table.find(statsTable.Purchased.Upgrades, itemName) then
                table.insert(statsTable.Purchased.Upgrades, itemName)
            end
        end
    end
end

local function forceEquip()
    local equipRemote = Network:FindFirstChild("equiplasergun")
    if equipRemote and (tick() - lastEquipTime > equipCooldown) then
        lastEquipTime = tick()
        if equipRemote:IsA("RemoteEvent") then
            equipRemote:FireServer(TARGET_WEAPON)
        elseif equipRemote:IsA("RemoteFunction") then
            equipRemote:InvokeServer(TARGET_WEAPON)
        end
    end
end

local function hookNetwork()
    local equipRemote = Network:FindFirstChild("equiplasergun")
    if not equipRemote then return end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if self == equipRemote and (method == "FireServer" or method == "InvokeServer") then
            if args[1] ~= TARGET_WEAPON then
                args[1] = TARGET_WEAPON
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
end

task.spawn(function()
    pcall(hookNetwork)
    
    local oldGet = Library.Stats.Get
    Library.Stats.Get = function(...)
        local stats = oldGet(...)
        if stats then
            applyModifications(stats)
        end
        return stats
    end

    RunService.Heartbeat:Connect(function()
        local currentStats = Library.Stats.Get(true)
        if currentStats and currentStats.Equipped ~= TARGET_WEAPON then
            forceEquip()
        end
        
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool or tool.Name ~= TARGET_WEAPON then
                forceEquip()
            end
        end
    end)
end)

function equip(name: string)
    TARGET_WEAPON = name
    forceEquip()
end

_G.equip = equip
equip(TARGET_WEAPON)