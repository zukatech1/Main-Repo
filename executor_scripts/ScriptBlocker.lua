--[[
    Script Blocker / GUI Remover
    Prevents certain GUIs and scripts from loading or removes them
    
    Features:
    - Block scripts by name or pattern
    - Remove existing GUIs
    - Prevent future GUIs from loading
    - Whitelist/Blacklist system
    - Real-time monitoring
]]

local ScriptBlocker = {
    Settings = {
        Enabled = true,
        AutoRemoveOnDetect = true,
        LogActions = true,
        MonitorPlayerGui = true,
        MonitorCoreGui = true,
        MonitorStarterGui = false
    },
    
    -- Scripts/GUIs to block (supports partial matching)
    Blacklist = {
        "AntiCheat",
        "AdminCommands",
        "ChatGui",
        "Leaderboard",
        -- Add more here
    },
    
    -- Scripts/GUIs to always keep (takes priority over blacklist)
    Whitelist = {
        -- Add protected GUIs here
    },
    
    -- Track removed items
    RemovedItems = {},
    
    -- Services
    Services = {
        Players = game:GetService("Players"),
        CoreGui = game:GetService("CoreGui"),
        StarterGui = game:GetService("StarterGui")
    }
}

-- Check if name matches any pattern in list
function ScriptBlocker:MatchesPattern(name, patternList)
    for _, pattern in ipairs(patternList) do
        if name:lower():find(pattern:lower(), 1, true) then
            return true, pattern
        end
    end
    return false
end

-- Check if item should be blocked
function ScriptBlocker:ShouldBlock(instance)
    if not instance then return false end
    
    local name = instance.Name
    
    -- Check whitelist first (priority)
    if self:MatchesPattern(name, self.Whitelist) then
        return false
    end
    
    -- Check blacklist
    local matches, pattern = self:MatchesPattern(name, self.Blacklist)
    return matches, pattern
end

-- Log action
function ScriptBlocker:Log(message, color)
    if not self.Settings.LogActions then return end
    
    local timestamp = os.date("%H:%M:%S")
    local prefix = "[ScriptBlocker " .. timestamp .. "]"
    
    if color then
        print(prefix .. " " .. message)
    else
        print(prefix .. " " .. message)
    end
end

-- Remove/block an instance
function ScriptBlocker:BlockInstance(instance, reason)
    if not instance or not instance.Parent then return end
    
    local name = instance.Name
    local className = instance.ClassName
    local path = instance:GetFullName()
    
    -- Track removal
    table.insert(self.RemovedItems, {
        Name = name,
        ClassName = className,
        Path = path,
        Reason = reason or "Blacklisted",
        Time = os.time()
    })
    
    -- Remove it
    pcall(function()
        instance:Destroy()
    end)
    
    self:Log("🚫 Blocked: " .. name .. " (" .. className .. ") - Reason: " .. (reason or "Blacklisted"))
end

-- Scan and remove existing instances
function ScriptBlocker:ScanAndRemove(parent, parentName)
    if not parent then return end
    
    local removed = 0
    
    for _, child in ipairs(parent:GetChildren()) do
        local shouldBlock, pattern = self:ShouldBlock(child)
        
        if shouldBlock then
            self:BlockInstance(child, "Matched pattern: " .. pattern)
            removed = removed + 1
        end
    end
    
    if removed > 0 then
        self:Log("✓ Scanned " .. parentName .. " - Removed " .. removed .. " items")
    end
end

-- Monitor for new instances
function ScriptBlocker:MonitorContainer(parent, parentName)
    if not parent then return end
    
    parent.ChildAdded:Connect(function(child)
        if not self.Settings.Enabled then return end
        
        local shouldBlock, pattern = self:ShouldBlock(child)
        
        if shouldBlock then
            if self.Settings.AutoRemoveOnDetect then
                task.wait() -- Wait a frame to let it fully load
                self:BlockInstance(child, "Auto-blocked (pattern: " .. pattern .. ")")
            else
                self:Log("⚠️ Detected (not removed): " .. child.Name .. " in " .. parentName)
            end
        end
    end)
    
    self:Log("👁️ Monitoring " .. parentName .. " for new instances")
end

-- Add to blacklist
function ScriptBlocker:AddToBlacklist(pattern)
    if not pattern or pattern == "" then return false end
    
    for _, existing in ipairs(self.Blacklist) do
        if existing:lower() == pattern:lower() then
            self:Log("⚠️ Pattern already in blacklist: " .. pattern)
            return false
        end
    end
    
    table.insert(self.Blacklist, pattern)
    self:Log("✓ Added to blacklist: " .. pattern)
    return true
end

-- Remove from blacklist
function ScriptBlocker:RemoveFromBlacklist(pattern)
    for i, existing in ipairs(self.Blacklist) do
        if existing:lower() == pattern:lower() then
            table.remove(self.Blacklist, i)
            self:Log("✓ Removed from blacklist: " .. pattern)
            return true
        end
    end
    self:Log("⚠️ Pattern not found in blacklist: " .. pattern)
    return false
end

-- Add to whitelist
function ScriptBlocker:AddToWhitelist(pattern)
    if not pattern or pattern == "" then return false end
    
    for _, existing in ipairs(self.Whitelist) do
        if existing:lower() == pattern:lower() then
            self:Log("⚠️ Pattern already in whitelist: " .. pattern)
            return false
        end
    end
    
    table.insert(self.Whitelist, pattern)
    self:Log("✓ Added to whitelist: " .. pattern)
    return true
end

-- Get stats
function ScriptBlocker:GetStats()
    local stats = {
        Enabled = self.Settings.Enabled,
        BlacklistCount = #self.Blacklist,
        WhitelistCount = #self.Whitelist,
        TotalRemoved = #self.RemovedItems,
        RecentlyRemoved = {}
    }
    
    -- Get last 5 removed items
    for i = math.max(1, #self.RemovedItems - 4), #self.RemovedItems do
        table.insert(stats.RecentlyRemoved, self.RemovedItems[i])
    end
    
    return stats
end

-- Print stats
function ScriptBlocker:PrintStats()
    local stats = self:GetStats()
    
    print("\n========== Script Blocker Stats ==========")
    print("Status: " .. (stats.Enabled and "✓ Enabled" or "✗ Disabled"))
    print("Blacklist Patterns: " .. stats.BlacklistCount)
    print("Whitelist Patterns: " .. stats.WhitelistCount)
    print("Total Items Removed: " .. stats.TotalRemoved)
    
    if #stats.RecentlyRemoved > 0 then
        print("\nRecently Removed:")
        for _, item in ipairs(stats.RecentlyRemoved) do
            print("  - " .. item.Name .. " (" .. item.Reason .. ")")
        end
    end
    
    print("==========================================\n")
end

-- List blacklist
function ScriptBlocker:ListBlacklist()
    print("\n========== Blacklist ==========")
    if #self.Blacklist == 0 then
        print("(Empty)")
    else
        for i, pattern in ipairs(self.Blacklist) do
            print(i .. ". " .. pattern)
        end
    end
    print("================================\n")
end

-- List whitelist
function ScriptBlocker:ListWhitelist()
    print("\n========== Whitelist ==========")
    if #self.Whitelist == 0 then
        print("(Empty)")
    else
        for i, pattern in ipairs(self.Whitelist) do
            print(i .. ". " .. pattern)
        end
    end
    print("================================\n")
end

-- Clear all removed items from history
function ScriptBlocker:ClearHistory()
    self.RemovedItems = {}
    self:Log("✓ Cleared removal history")
end

-- Start the blocker
function ScriptBlocker:Start()
    local player = self.Services.Players.LocalPlayer
    
    if not player then
        warn("[ScriptBlocker] LocalPlayer not found!")
        return
    end
    
    self:Log("🚀 Starting Script Blocker...")
    
    -- Wait for PlayerGui to load
    local playerGui = player:WaitForChild("PlayerGui", 10)
    
    if playerGui and self.Settings.MonitorPlayerGui then
        -- Scan existing GUIs
        self:ScanAndRemove(playerGui, "PlayerGui")
        
        -- Monitor for new GUIs
        self:MonitorContainer(playerGui, "PlayerGui")
    end
    
    -- Monitor CoreGui if enabled
    if self.Settings.MonitorCoreGui then
        pcall(function()
            self:ScanAndRemove(self.Services.CoreGui, "CoreGui")
            self:MonitorContainer(self.Services.CoreGui, "CoreGui")
        end)
    end
    
    -- Monitor StarterGui if enabled
    if self.Settings.MonitorStarterGui then
        self:ScanAndRemove(self.Services.StarterGui, "StarterGui")
        self:MonitorContainer(self.Services.StarterGui, "StarterGui")
    end
    
    self:Log("✓ Script Blocker is now active!")
    self:PrintStats()
end

-- Stop the blocker
function ScriptBlocker:Stop()
    self.Settings.Enabled = false
    self:Log("🛑 Script Blocker stopped")
end

-- Toggle blocker
function ScriptBlocker:Toggle()
    self.Settings.Enabled = not self.Settings.Enabled
    self:Log(self.Settings.Enabled and "✓ Enabled" or "✗ Disabled")
end

-- Quick setup function
function ScriptBlocker:QuickSetup(blacklistPatterns)
    if blacklistPatterns then
        self.Blacklist = blacklistPatterns
    end
    self:Start()
end

-- ============================================
-- USAGE EXAMPLES (commented out)
-- ============================================

--[[
    BASIC USAGE:
    
    -- Start with default settings
    ScriptBlocker:Start()
    
    -- Add items to blacklist
    ScriptBlocker:AddToBlacklist("AdminGui")
    ScriptBlocker:AddToBlacklist("ChatFrame")
    
    -- Remove from blacklist
    ScriptBlocker:RemoveFromBlacklist("ChatFrame")
    
    -- Add to whitelist (protected)
    ScriptBlocker:AddToWhitelist("MyCustomGui")
    
    -- View stats
    ScriptBlocker:PrintStats()
    
    -- List patterns
    ScriptBlocker:ListBlacklist()
    ScriptBlocker:ListWhitelist()
    
    -- Toggle on/off
    ScriptBlocker:Toggle()
    
    -- Stop completely
    ScriptBlocker:Stop()
    
    -- Quick setup with custom blacklist
    ScriptBlocker:QuickSetup({
        "AdminPanel",
        "Leaderboard",
        "Chat",
        "AntiCheat"
    })
]]

-- ============================================
-- AUTO-START (uncomment to enable)
-- ============================================

-- ScriptBlocker:Start()

return ScriptBlocker
