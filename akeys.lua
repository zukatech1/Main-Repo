local players = game:GetService("Players")
local repl_storage = game:GetService("ReplicatedStorage")
local l_plr = players.LocalPlayer
local function find_adonis_client()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Remote") and rawget(v, "Core") then
            return v
        end
    end
end
local adonis = find_adonis_client()
if adonis then
    print("Linked")
    task.spawn(function()
        while not adonis.Core.Key do 
            task.wait(0.1) 
        end
        print("[DATA] Master Key Extracted: " .. tostring(adonis.Core.Key))
        print("[DATA] Remote Name: " .. tostring(adonis.RemoteName))
    end)
    local old_get = adonis.Remote.Get
    adonis.Remote.Get = function(key, ...)
        local args = {...}
        print("[MITM-GET] Key: " .. tostring(key) .. " | Args: " .. table.concat(args, ", "))
        if key == "ExecutePermission" then
            warn("[ANALYSIS] Adonis is attempting to push bytecode to the FiOne VM.")
        end
        return old_get(key, ...)
    end
    local old_send = adonis.Remote.Send
    adonis.Remote.Send = function(key, ...)
        local args = {...}
        if key == "Detected" or args[1] == "Detected" then
            print("[SILENCED] Dropped detection report: " .. tostring(args[2]))
            return nil
        end
        return old_send(key, ...)
    end
    if _G.Adonis then
        local real_api = _G.Adonis
        local fake_api = newproxy(true)
        local mt = getmetatable(fake_api)
        mt.__index = function(self, index)
            print("[GLOBAL-API] Access on: " .. tostring(index))
            return real_api[index]
        end
        mt.__metatable = "API"
        print("[SYSTEM] Global API Proxy established.")
    end
    if adonis.Core.LoadBytecode then
        local old_load = adonis.Core.LoadBytecode
        adonis.Core.LoadBytecode = function(bytecode, env)
            warn("[BYTECODE] Adonis is loading a custom script. Intercepting...")
            return old_load(bytecode, env)
        end
    end
else
    warn("[ERROR]: Could not locate Adonis table in GC.")
end
local old_destroy
old_destroy = hookfunction(game.Destroy, function(self)
    if not checkcaller() and adonis and self == adonis.RemoteEvent.Object then
        warn("[PREVENTION] Blocked Adonis logic from destroying its own remote (Handshake Trap).")
        return nil
    end
    return old_destroy(self)
end)
