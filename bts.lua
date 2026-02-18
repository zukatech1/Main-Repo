local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Framework = ReplicatedStorage:WaitForChild("Framework")
local Library = require(Framework:WaitForChild("Library"))
local Network = Framework:WaitForChild("Modules"):WaitForChild("2 | Network")
local function applyModifications(statsTable)
    if not statsTable then return end
    statsTable.Cash = 999999999
    if statsTable.UpgradeSlots then statsTable.UpgradeSlots = 5 end
    if Library.Directory and Library.Directory.Upgrades and statsTable.Purchased and statsTable.Purchased.Upgrades then
        for itemName, _ in pairs(Library.Directory.Upgrades) do
            if not table.find(statsTable.Purchased.Upgrades, itemName) then
                table.insert(statsTable.Purchased.Upgrades, itemName)
            end
        end
    end
    if Library.Directory and Library.Directory.Products and statsTable.Purchased then
        if not statsTable.Purchased.Materials then statsTable.Purchased.Materials = {} end
        for productName, _ in pairs(Library.Directory.Products) do
            if productName:sub(1, 11) == "Material - " then
                local materialName = productName:sub(12)
                if not table.find(statsTable.Purchased.Materials, materialName) then
                    table.insert(statsTable.Purchased.Materials, materialName)
                end
            end
        end
    end
    if Library.Directory and Library.Directory.Gamepasses and statsTable.Gamepasses then
        for name, data in pairs(Library.Directory.Gamepasses) do
            local passId = data.ID or data.id
            if passId and not table.find(statsTable.Gamepasses, tostring(passId)) then
                table.insert(statsTable.Gamepasses, tostring(passId))
            end
        end
    end
end
task.spawn(function()
    task.wait(3)
    local initialStats = Library.Stats.Get(true)
    if initialStats then
        print("Performing initial comprehensive unlock.")
        applyModifications(initialStats)
    else
        warn("Could not find initial stats to apply unlock.")
    end
end)
RunService.RenderStepped:Connect(function()
    local currentStats = Library.Stats.Get(true)
    if not currentStats or not currentStats.Purchased or not currentStats.Purchased.Upgrades then
        return
    end
    local isWiped = not table.find(currentStats.Purchased.Upgrades, "Shoop Da Whoop")
    if isWiped then
        print("Callum's Core V7: Server wipe detected! Re-enforcing unlocks immediately.")
        applyModifications(currentStats)
    end
end)
print("Callum's Core V7: Guardian loop is now active. Unlocks are permanently enforced.")
task.spawn(function()
    if Library.Admin and Library.Admin.IsAdmin then
        if hookfunction then hookfunction(Library.Admin.IsAdmin, function() return true end)
        else Library.Admin.IsAdmin = function() return true end end
        print("Callum's Core V7: Client-side admin status granted.")
    end
end)
function equipWeapon(weaponName)
    local equipRemote = Network:FindFirstChild("equiplasergun")
    if equipRemote and (equipRemote:IsA("RemoteEvent") or equipRemote:IsA("RemoteFunction")) then
        equipRemote:FireServer(weaponName)
    else warn("Callum's Core V7: 'equiplasergun' remote not found.") end
end
_G.equip = equipWeapon
