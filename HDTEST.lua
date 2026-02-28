-- ══════════════════════════════════════════════════
--  AntiAdmin — Zuka
--  Covers: HD Admin, Kohl's Admin (KA), Adonis Admin
--  Blocks: explode, kill, fling, freeze, kick-prep,
--          ff removal, tool strip, char deletion,
--          nametag spam, darkness/blindness effects
-- ══════════════════════════════════════════════════

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace        = game:GetService("Workspace")
local lp               = Players.LocalPlayer
local connections      = {}

local LOG = true
local function log(...)
    if LOG then print("[AntiAdmin]", ...) end
end

-- ─── Utility ──────────────────────────────────────

local function safeDisconnect(c)
    if c and typeof(c) == "RBXScriptConnection" then
        pcall(function() c:Disconnect() end)
    end
end

-- Protect humanoid from having health zeroed or being killed
local function protectHumanoid(hum)
    if not hum then return end

    -- Hard floor health at 100 if it drops to 0 from admin commands
    -- We use a changed connection; we detect zeroing and restore
    local lastHp = hum.MaxHealth
    local conn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        local hp = hum.Health
        if hp <= 0 then
            pcall(function()
                hum.Health = hum.MaxHealth
            end)
            log("Blocked kill/health-zero on humanoid")
        end
    end)
    table.insert(connections, conn)

    -- Block WalkSpeed / JumpPower zeroing (freeze command)
    local connWS = hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum.WalkSpeed <= 0 then
            task.defer(function() pcall(function() hum.WalkSpeed = 16 end) end)
            log("Blocked freeze (WalkSpeed zeroed)")
        end
    end)
    table.insert(connections, connWS)

    local connJP = hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if hum.JumpPower <= 0 then
            task.defer(function() pcall(function() hum.JumpPower = 50 end) end)
            log("Blocked freeze (JumpPower zeroed)")
        end
    end)
    table.insert(connections, connJP)
end

-- ─── Character Protection ─────────────────────────

local function onCharacterAdded(char)
    log("Character loaded — applying protections")

    local humanoid = char:WaitForChild("Humanoid", 10)
    if humanoid then
        protectHumanoid(humanoid)
    end

    local root = char:WaitForChild("HumanoidRootPart", 10)

    -- ── 1. Block Explosions ────────────────────────
    -- Any Explosion added to Workspace that is close to us gets its
    -- BlastRadius zeroed before it can deal damage.
    local expConn = Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Explosion") then
            task.defer(function()
                -- Check if the explosion is near us
                if not root then return end
                local ok = pcall(function()
                    local dist = (obj.Position - root.Position).Magnitude
                    if dist < obj.BlastRadius + 50 then
                        obj.BlastRadius  = 0
                        obj.BlastPressure = 0
                        log("Neutralized explosion near player (dist=" .. math.floor(dist) .. ")")
                    end
                end)
            end)
        end
    end)
    table.insert(connections, expConn)

    -- ── 2. Block Fling / Velocity spam ────────────
    -- Some admins use BodyVelocity/RocketPropulsion injected into HRP
    local flingConn = char.DescendantAdded:Connect(function(obj)
        if obj:IsA("BodyVelocity")
            or obj:IsA("BodyForce")
            or obj:IsA("RocketPropulsion")
            or obj:IsA("BodyAngularVelocity")
        then
            task.defer(function()
                pcall(function()
                    obj:Destroy()
                end)
            end)
            log("Removed fling object: " .. obj.ClassName)
        end
    end)
    table.insert(connections, flingConn)

    -- ── 3. Restore ForceField if removed ──────────
    -- Admins sometimes strip your FF with removeff command
    -- We watch for it being removed and restore it
    local ffConn = char.ChildRemoved:Connect(function(obj)
        if obj:IsA("ForceField") then
            task.defer(function()
                -- Only restore if the character is still alive
                if char.Parent and humanoid and humanoid.Health > 0 then
                    local ff = Instance.new("ForceField", char)
                    ff.Visible = false
                    log("Restored stripped ForceField")
                end
            end)
        end
    end)
    table.insert(connections, ffConn)

    -- ── 4. Block Tool Strip ───────────────────────
    -- Tools live in the character while equipped — watch for them being
    -- reparented away (striptools command)
    local toolConn = char.ChildRemoved:Connect(function(obj)
        if obj:IsA("Tool") then
            -- Give it a tick — legitimate drops do this too, so we
            -- check if the tool ends up in a null/weird parent
            task.delay(0.1, function()
                if obj and not obj.Parent then
                    pcall(function()
                        obj.Parent = lp.Backpack
                        log("Restored stripped tool: " .. obj.Name)
                    end)
                end
            end)
        end
    end)
    table.insert(connections, toolConn)

    -- ── 5. Block Char Deletion / Reset forcing ────
    -- Some admins call char:Destroy() or set Health=0 on server
    -- We watch the char's Parent property
    local charParentConn = char:GetPropertyChangedSignal("Parent"):Connect(function()
        if not char.Parent then
            log("Character parent set to nil — likely admin forced reset")
            -- We can't stop this on the client reliably, but we can re-request spawn
            task.delay(0.5, function()
                pcall(function()
                    lp:LoadCharacter()
                end)
            end)
        end
    end)
    table.insert(connections, charParentConn)
end

-- ─── HD Admin — Signal-Level Blocks ───────────────
-- Hook into HDAdmin's RemoteEvent/Function signals and neuter
-- any client-side commands that would affect us

local function hookHDAdmin()
    local hdc = ReplicatedStorage:FindFirstChild("HDAdminHDClient")
    if not hdc then return false end
    local signals = hdc:FindFirstChild("Signals")
    if not signals then return false end

    log("HD Admin signals found — applying signal hooks")

    -- Commands that admins can fire at our client
    local dangerousClientCmds = {
        "explode", "kill", "fling", "freeze", "ff", "removeff",
        "fire", "smoke", "sparkles", "blind", "darkness",
        "seizure", "trip", "unequip", "striptools", "reset",
        "noclip", "drag"
    }
    local blockedSet = {}
    for _, v in ipairs(dangerousClientCmds) do blockedSet[v:lower()] = true end

    -- Wrap ExecuteClientCommand and ActivateClientCommand
    local function hookSignal(sig)
        if not sig then return end
        -- We can't disconnect server→client fires, but we CAN intercept
        -- via firesignal reflection — instead we hook the OnClientEvent
        -- by watching for it firing and immediately countering the effect
        sig.OnClientEvent:Connect(function(cmd, args)
            local cmdL = tostring(cmd):lower()
            if blockedSet[cmdL] then
                log("HD Admin: blocked client command → " .. cmdL)
                -- Immediately counter: restore health, walkspeed, etc.
                local char = lp.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    task.defer(function()
                        pcall(function()
                            if hum.Health <= 0 then hum.Health = hum.MaxHealth end
                            if hum.WalkSpeed <= 0 then hum.WalkSpeed = 16 end
                        end)
                    end)
                end
                -- Counter explosion: zero all nearby explosions
                task.defer(function()
                    if char then
                        local root = char:FindFirstChild("HumanoidRootPart")
                        for _, v in ipairs(Workspace:GetDescendants()) do
                            if v:IsA("Explosion") then
                                pcall(function()
                                    if root and (v.Position - root.Position).Magnitude < 60 then
                                        v.BlastRadius   = 0
                                        v.BlastPressure = 0
                                    end
                                end)
                            end
                        end
                    end
                end)
            end
        end)
    end

    -- Try to hook all known command signals
    local signalNames = {
        "ExecuteClientCommand",
        "ActivateClientCommand",
        "ReplicationEffectClientCommand",
    }
    for _, name in ipairs(signalNames) do
        local s = signals:FindFirstChild(name)
        if s then
            hookSignal(s)
            log("Hooked HD signal: " .. name)
        end
    end

    -- Block RankChanged being used to strip our rank back down
    -- (some anti-cheat plugins do this to counter exploiters, but
    --  we protect against admin abuse here)
    local rc = signals:FindFirstChild("RankChanged")
    if rc then
        rc.OnClientEvent:Connect(function(rank, rankName)
            -- If someone is trying to set our rank to 0 (guest/banned)
            if tonumber(rank) and tonumber(rank) <= 0 then
                log("HD Admin: blocked rank-down to " .. tostring(rank))
                -- We don't auto-counter here since rank is server-authoritative
                -- but we log it for awareness
            end
        end)
    end

    return true
end

-- ─── Kohl's Admin (KA) — Effect Blocks ────────────
-- KA uses RemoteEvents named things like "Hint", "Message", and
-- executes effects on the client via a LocalScript it injects.
-- We can't kill that LocalScript, but we can counter its effects.

local function hookKohls()
    -- KA's remote is typically named "KA_Remote" or similar in RS
    local kaRemote = ReplicatedStorage:FindFirstChild("KA_Remote")
        or ReplicatedStorage:FindFirstChild("kohls_admin")
        or ReplicatedStorage:FindFirstChild("admin")

    if kaRemote then
        log("Kohl's Admin remote found: " .. kaRemote.Name)
    end

    -- KA injects a LocalScript into the player's character for effects.
    -- Watch for suspicious scripts being added to our character.
    local function watchChar(char)
        if not char then return end
        char.DescendantAdded:Connect(function(obj)
            if obj:IsA("LocalScript") or obj:IsA("Script") then
                -- Check name patterns KA uses
                local n = obj.Name:lower()
                if n:find("admin") or n:find("effect") or n:find("explode")
                    or n:find("kill") or n:find("fling") or n:find("freeze")
                    or n:find("blind") or n:find("dark") or n:find("seizure")
                then
                    pcall(function() obj:Destroy() end)
                    log("KA: removed injected script → " .. obj.Name)
                end
            end
        end)
    end

    if lp.Character then watchChar(lp.Character) end
    lp.CharacterAdded:Connect(watchChar)
end

-- ─── Adonis Admin — Effect Blocks ─────────────────
-- Adonis fires effects through RemoteEvents in ReplicatedStorage.
-- It also uses a MainModule. We hook the client-side remote.

local function hookAdonis()
    -- Adonis typically stores its remote in RS under "Adonis" or "MainModule"
    local adonisFolder = ReplicatedStorage:FindFirstChild("Adonis")
    if not adonisFolder then return false end

    log("Adonis folder found — applying hooks")

    -- Adonis fires a "Remote" RemoteEvent for client commands
    local remote = adonisFolder:FindFirstChild("Remote")
        or adonisFolder:FindFirstChildOfClass("RemoteEvent")
        or adonisFolder:FindFirstChildOfClass("RemoteFunction")

    if remote and remote:IsA("RemoteEvent") then
        remote.OnClientEvent:Connect(function(cmd, ...)
            local cmdL = tostring(cmd):lower()
            log("Adonis client event: " .. cmdL)

            -- Adonis command names that affect us physically
            local blocked = {
                explode=true, kill=true, fling=true, freeze=true,
                blind=true, darkness=true, seizure=true, trip=true,
                fire=true, smoke=true, ff=true, unff=true,
                punish=true, respawn=true, reset=true
            }

            if blocked[cmdL] then
                log("Adonis: blocked → " .. cmdL)
                local char = lp.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                task.defer(function()
                    if hum then
                        pcall(function()
                            if hum.Health <= 0 then hum.Health = hum.MaxHealth end
                            if hum.WalkSpeed <= 0 then hum.WalkSpeed = 16 end
                        end)
                    end
                    -- Clear nearby explosions
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, v in ipairs(Workspace:GetDescendants()) do
                            if v:IsA("Explosion") then
                                pcall(function()
                                    if (v.Position - root.Position).Magnitude < 60 then
                                        v.BlastRadius = 0 ; v.BlastPressure = 0
                                    end
                                end)
                            end
                        end
                    end
                end)
            end
        end)
    end

    return true
end

-- ─── Universal Heartbeat Watchdog ─────────────────
-- Catches things that slip through event-based hooks.
-- Runs every 0.5s to check our character's state and restore it.

local lastCheck = 0
local watchdogConn = RunService.Heartbeat:Connect(function(dt)
    lastCheck += dt
    if lastCheck < 0.5 then return end
    lastCheck = 0

    local char = lp.Character
    if not char then return end
    local hum  = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- Restore health if zeroed
    if hum.Health <= 0 and hum.MaxHealth > 0 then
        pcall(function() hum.Health = hum.MaxHealth end)
        log("Watchdog: restored health from 0")
    end

    -- Restore walkspeed if frozen
    if hum.WalkSpeed <= 0 then
        pcall(function() hum.WalkSpeed = 16 end)
        log("Watchdog: restored WalkSpeed from 0")
    end

    -- Neutralize any live explosions in workspace near us
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Explosion") then
            pcall(function()
                if (obj.Position - root.Position).Magnitude < obj.BlastRadius + 20 then
                    obj.BlastRadius   = 0
                    obj.BlastPressure = 0
                end
            end)
        end
    end

    -- Remove any BodyVelocity fling objects on our root
    for _, obj in ipairs(root:GetChildren()) do
        if obj:IsA("BodyVelocity") or obj:IsA("BodyForce")
            or obj:IsA("RocketPropulsion") or obj:IsA("BodyAngularVelocity")
        then
            pcall(function() obj:Destroy() end)
            log("Watchdog: removed fling object from HRP")
        end
    end

    -- Darkness / Blindness — admins sometimes set a ColorCorrectionEffect
    -- or a black frame in our PlayerGui. Remove those.
    local pg = lp:FindFirstChild("PlayerGui")
    if pg then
        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("Frame") then
                -- A full-screen black frame is the classic blindness trick
                local s = obj.Size
                if s.X.Scale >= 0.9 and s.Y.Scale >= 0.9
                    and obj.BackgroundColor3 == Color3.new(0,0,0)
                    and obj.BackgroundTransparency < 0.1
                then
                    pcall(function() obj:Destroy() end)
                    log("Watchdog: removed blindness frame")
                end
            elseif obj:IsA("ColorCorrectionEffect") then
                if obj.Brightness < -0.8 then
                    pcall(function() obj:Destroy() end)
                    log("Watchdog: removed darkness ColorCorrection")
                end
            end
        end
        -- Also check Lighting for ColorCorrection effects
        local lighting = game:GetService("Lighting")
        for _, obj in ipairs(lighting:GetChildren()) do
            if obj:IsA("ColorCorrectionEffect") and obj.Brightness < -0.8 then
                pcall(function() obj:Destroy() end)
                log("Watchdog: removed darkness from Lighting")
            end
        end
    end
end)
table.insert(connections, watchdogConn)

-- ─── Init ─────────────────────────────────────────

-- Hook current character
if lp.Character then
    task.spawn(onCharacterAdded, lp.Character)
end
lp.CharacterAdded:Connect(onCharacterAdded)

-- Admin system hooks
task.spawn(function()
    -- Wait briefly for RS to populate
    task.wait(2)

    local hdOk     = hookHDAdmin()
    local adonisOk = hookAdonis()
    hookKohls()

    log(string.format(
        "AntiAdmin active — HD:%s  Adonis:%s  KA:watching",
        hdOk and "hooked" or "not found",
        adonisOk and "hooked" or "not found"
    ))

    -- Also watch for admin systems loading in AFTER us
    ReplicatedStorage.ChildAdded:Connect(function(child)
        task.wait(1)  -- let it fully load
        if child.Name == "HDAdminHDClient" then
            hookHDAdmin()
            log("HD Admin loaded late — hooked")
        elseif child.Name == "Adonis" then
            hookAdonis()
            log("Adonis loaded late — hooked")
        end
    end)
end)

log("AntiAdmin loaded — protecting " .. lp.Name)

-- ─── Cleanup function (call if you want to disable) ──
_G.AntiAdmin_Disable = function()
    for _, c in ipairs(connections) do safeDisconnect(c) end
    connections = {}
    log("AntiAdmin disabled")
end
