-- Zukas Lifter - Enhanced Mercury UI Version
-- Advanced multi-stage deobfuscation system

-- Load Mercury Library
local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local Lifter = {
    State = {
        IsLifting = false,
        VFS_Cache = {},
        VFS_Loading = {},
        VFS_Base = "https://raw.githubusercontent.com/zukatech1/Lifter/main/src/",
        CurrentCode = "",
        ProcessingStage = 1
    },
    Config = {
        KEYWORDS = {"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "goto", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"},
        GLOBALS = {"getrawmetatable", "game", "Workspace", "script", "math", "string", "table", "print", "wait", "Instance", "Vector3", "CFrame", "Enum", "loadstring", "getgenv", "getrenv", "getreg", "getgc"},
    }
}

-- Virtual File System Require
function Lifter:_vRequire(modulePath)
    local state = self.State
    
    if state.VFS_Cache[modulePath] then
        return state.VFS_Cache[modulePath]
    end
    
    if state.VFS_Loading[modulePath] then
        return state.VFS_Loading[modulePath]
    end
    
    local internalPath = modulePath:gsub("%.", "/") .. ".lua"
    local url = state.VFS_Base .. internalPath
    
    local success, content = pcall(game.HttpGet, game, url)
    if not success or content:find("404: Not Found") then
        local fallbackUrl = "https://raw.githubusercontent.com/zukatech1/Lifter/main/" .. internalPath
        success, content = pcall(game.HttpGet, game, fallbackUrl)
    end

    if not success or content:find("404: Not Found") then
        warn("--> [VFS] Resolution Failed: " .. modulePath)
        return nil
    end
    
    local func, err = loadstring(content, "@VFS/" .. modulePath)
    if not func then
        warn("--> [VFS] Syntax Error in " .. modulePath .. ": " .. err)
        return nil
    end
    
    local modulePlaceholder = {}
    state.VFS_Loading[modulePath] = modulePlaceholder
    
    local env = getfenv(func)
    env.require = function(path) return self:_vRequire(path) end
    env.arg = {}
    env.print = function(...) print("[LIFTER]:", ...) end
    setfenv(func, env)
    
    local result = func()
    
    local finalData = result or modulePlaceholder
    state.VFS_Cache[modulePath] = finalData
    state.VFS_Loading[modulePath] = nil
    
    return finalData
end

-- Initialize Prometheus components
function Lifter:_initializeLifter()
    self.State.VFS_Cache = {}
    self.State.VFS_Loading = {}
    
    local Parser = self:_vRequire("prometheus.parser")
    local Ast = self:_vRequire("prometheus.ast")
    local VisitAst = self:_vRequire("prometheus.visitast")
    local Unparser = self:_vRequire("prometheus.unparser")
    
    return {
        Parser = Parser,
        Ast = Ast,
        VisitAst = VisitAst,
        Unparser = Unparser
    }
end

-- Stage 1: Decode escaped strings
function Lifter:DecodeStrings(code)
    GUI:notification{
        Title = "Stage 1",
        Text = "Decoding escaped strings...",
        Duration = 2
    }
    
    local decoded = code
    
    -- Decode octal escape sequences (3 digits: \000 to \377)
    decoded = decoded:gsub("\\(%d%d%d)", function(oct)
        local num = tonumber(oct, 8)
        if num and num >= 0 and num <= 255 then
            return string.char(num)
        end
        return "\\" .. oct -- Keep original if invalid
    end)
    
    -- Decode hex escape sequences (\xXX)
    decoded = decoded:gsub("\\x(%x%x)", function(hex)
        local num = tonumber(hex, 16)
        if num and num >= 0 and num <= 255 then
            return string.char(num)
        end
        return "\\x" .. hex -- Keep original if invalid
    end)
    
    -- Decode single/double digit octal if present
    decoded = decoded:gsub("\\(%d%d?)([^%d])", function(oct, next_char)
        local num = tonumber(oct, 8)
        if num and num >= 0 and num <= 255 then
            return string.char(num) .. next_char
        end
        return "\\" .. oct .. next_char
    end)
    
    return decoded
end

-- Stage 2: Simplify concatenated strings
function Lifter:SimplifyStrings(code)
    GUI:notification{
        Title = "Stage 2",
        Text = "Simplifying string concatenations...",
        Duration = 2
    }
    
    -- Merge simple string concatenations like "a" .. "b" -> "ab"
    local simplified = code
    local changed = true
    
    while changed do
        local newCode = simplified:gsub('"([^"]*)"%s*%.%.%s*"([^"]*)"', '"%1%2"')
        changed = (newCode ~= simplified)
        simplified = newCode
    end
    
    return simplified
end

-- Stage 3: Clean up formatting
function Lifter:CleanFormatting(code)
    GUI:notification{
        Title = "Stage 3",
        Text = "Cleaning up formatting...",
        Duration = 2
    }
    
    -- Remove excessive whitespace
    local cleaned = code:gsub("%s+", " ")
    
    -- Fix indentation (basic)
    local lines = {}
    local indent = 0
    
    for line in cleaned:gmatch("[^\n]+") do
        -- Decrease indent for end, else, elseif, until
        if line:match("^%s*end") or line:match("^%s*else") or 
           line:match("^%s*elseif") or line:match("^%s*until") then
            indent = math.max(0, indent - 1)
        end
        
        table.insert(lines, string.rep("\t", indent) .. line:match("^%s*(.-)%s*$"))
        
        -- Increase indent after function, if, for, while, repeat, else, elseif
        if line:match("function%s*%(") or line:match("^%s*if%s") or 
           line:match("^%s*for%s") or line:match("^%s*while%s") or
           line:match("^%s*repeat%s") or line:match("^%s*else%s*$") or
           line:match("^%s*elseif%s") then
            indent = indent + 1
        end
    end
    
    return table.concat(lines, "\n")
end

-- Stage 4: Try to execute and capture the real code
function Lifter:TryExecuteCapture(code)
    GUI:notification{
        Title = "Stage 4",
        Text = "Attempting runtime deobfuscation...",
        Duration = 2
    }
    
    local captured = nil
    local capturedMultiple = {}
    
    -- Hook loadstring to capture what the obfuscated code tries to load
    local oldLoadstring = loadstring or load
    local hookActive = true
    
    loadstring = function(str, ...)
        if hookActive and str and type(str) == "string" and #str > 100 then
            -- Capture all loadstring calls
            table.insert(capturedMultiple, str)
            if #str > (#captured or 0) then
                captured = str
            end
        end
        return oldLoadstring(str, ...)
    end
    
    if load then
        load = loadstring
    end
    
    -- Try to execute in a safe environment
    local success, result = pcall(function()
        local func, err = oldLoadstring(code)
        if func then
            -- Create isolated environment that prevents actual execution
            local blocked = function() return nil end
            local env = setmetatable({
                -- Block dangerous functions
                require = blocked,
                spawn = blocked,
                delay = blocked,
                wait = function() return 0 end,
                task = {spawn = blocked, defer = blocked, delay = blocked, wait = function() return 0 end},
                -- Allow necessary functions
                print = function(...) end,
                warn = function(...) end,
                type = type,
                typeof = typeof,
                tonumber = tonumber,
                tostring = tostring,
                string = string,
                math = math,
                table = table,
                pairs = pairs,
                ipairs = ipairs,
                next = next,
                select = select,
                unpack = unpack or table.unpack,
                getfenv = getfenv,
                setfenv = setfenv,
                pcall = pcall,
                xpcall = xpcall,
                newproxy = newproxy,
                getmetatable = getmetatable,
                setmetatable = setmetatable,
            }, {
                __index = function(t, k)
                    -- Return nil for unknown globals to prevent errors
                    return nil
                end
            })
            setfenv(func, env)
            
            -- Try to run it (will fail safely if it tries to do anything real)
            local s, r = pcall(func)
        end
    end)
    
    -- Restore loadstring
    loadstring = oldLoadstring
    if load then
        load = oldLoadstring
    end
    
    if captured and #captured > 100 then
        GUI:notification{
            Title = "Success!",
            Text = string.format("Captured %d code block(s)!", #capturedMultiple),
            Duration = 3
        }
        return captured
    end
    
    return code
end

-- Execute code from editor
function Lifter:ExecuteCode(code)
    local f, e = loadstring(code)
    if f then 
        task.spawn(f)
        GUI:notification{
            Title = "Execution",
            Text = "Code executed successfully!",
            Duration = 2
        }
    else 
        warn(e)
        GUI:notification{
            Title = "Error",
            Text = "Syntax error in code",
            Duration = 3
        }
    end
end

-- Enhanced multi-stage lifting
function Lifter:LiftCode(inputCode, callback)
    if self.State.IsLifting then 
        GUI:notification{
            Title = "Busy",
            Text = "Lifting already in progress...",
            Duration = 2
        }
        return 
    end
    
    self.State.IsLifting = true
    
    task.spawn(function()
        local function safeStage(stageName, stageFunc)
            local success, result = pcall(stageFunc)
            if success then
                return result
            else
                warn(string.format("[Lifter] %s failed: %s", stageName, tostring(result)))
                GUI:notification{
                    Title = stageName .. " Error",
                    Text = "Stage failed, continuing...",
                    Duration = 2
                }
                return nil
            end
        end
        
        -- Hook debug.getinfo to hide VFS traces
        local _old_info = debug.getinfo
        if getgenv then
            pcall(function()
                getgenv().debug.getinfo = function(f, ...)
                    local res = _old_info(f, ...)
                    if res and res.source and res.source:find("VFS") then
                        res.source = "=[C]"
                    end
                    return res
                end
            end)
        end
        
        local components = self:_initializeLifter()
        if not components.Parser then
            self.State.IsLifting = false
            GUI:notification{
                Title = "VFS Error",
                Text = "Failed to load Prometheus. Check console.",
                Duration = 3
            }
            return
        end
        
        if #inputCode == 0 then
            self.State.IsLifting = false
            GUI:notification{
                Title = "Empty",
                Text = "No code to lift!",
                Duration = 2
            }
            return
        end

        -- MULTI-STAGE DEOBFUSCATION
        local currentCode = inputCode
        
        -- Stage 1: Decode strings
        local decoded = safeStage("Stage 1: String Decode", function()
            return self:DecodeStrings(currentCode)
        end)
        if decoded then currentCode = decoded end
        wait(0.5)
        
        -- Stage 2: Prometheus AST parsing
        GUI:notification{
            Title = "Prometheus",
            Text = "Analyzing AST structure...",
            Duration = 2
        }
        
        local prometheusResult = safeStage("Stage 2: Prometheus", function()
            local p = components.Parser:new({ LuaVersion = "LuaU" })
            local ast = p:parse(currentCode)
            local u = components.Unparser:new({ 
                LuaVersion = "LuaU", 
                PrettyPrint = true, 
                IndentSpaces = 4 
            })
            return u:unparse(ast)
        end)
        
        if prometheusResult then
            currentCode = prometheusResult
        end
        
        wait(0.5)
        
        -- Stage 3: Simplify strings
        local simplified = safeStage("Stage 3: Simplify", function()
            return self:SimplifyStrings(currentCode)
        end)
        if simplified then currentCode = simplified end
        wait(0.5)
        
        -- Stage 4: Try runtime capture
        local runtimeCode = safeStage("Stage 4: Runtime Capture", function()
            return self:TryExecuteCapture(currentCode)
        end)
        
        if runtimeCode and runtimeCode ~= currentCode and #runtimeCode > 100 then
            currentCode = runtimeCode
            
            -- Re-run Prometheus on captured code
            prometheusResult = safeStage("Stage 4b: Re-Prometheus", function()
                local p = components.Parser:new({ LuaVersion = "LuaU" })
                local ast = p:parse(currentCode)
                local u = components.Unparser:new({ 
                    LuaVersion = "LuaU", 
                    PrettyPrint = true, 
                    IndentSpaces = 4 
                })
                return u:unparse(ast)
            end)
            
            if prometheusResult then
                currentCode = prometheusResult
            end
        end
        
        wait(0.5)
        
        -- Stage 5: Clean formatting
        local cleaned = safeStage("Stage 5: Format", function()
            return self:CleanFormatting(currentCode)
        end)
        if cleaned then currentCode = cleaned end
        
        self.State.CurrentCode = currentCode
        self.State.IsLifting = false
        
        GUI:notification{
            Title = "Complete!",
            Text = "Multi-stage lifting finished!",
            Duration = 3
        }
        
        if callback then callback(currentCode) end
        
        -- Restore original debug.getinfo
        if getgenv then
            pcall(function()
                getgenv().debug.getinfo = _old_info
            end)
        end
    end)
end

-- Simple string decoder utility
function Lifter:DecodeOctalString(str)
    return str:gsub("\\(%d%d%d)", function(oct)
        return string.char(tonumber(oct, 8))
    end)
end

-- Create the Mercury UI
GUI = Mercury:create{
    Name = "Zukas Lifter Pro",
    Size = UDim2.fromOffset(680, 480),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/zukatech1/Lifter"
}

-- Create main tab
local MainTab = GUI:tab{
    Name = "Multi-Stage Lifter",
    Icon = "rbxassetid://8569322835"
}

-- Code storage
local codeInput = ""
local codeOutput = ""

-- Editor Section
local EditorSection = MainTab:section{Name = "Code Editor"}

EditorSection:button{
    Name = "Instructions",
    Description = "How to use this advanced lifter",
    Callback = function()
        GUI:notification{
            Title = "Multi-Stage Lifting",
            Text = "This lifter uses 5 stages:\n1. String decoding\n2. AST parsing (Prometheus)\n3. String simplification\n4. Runtime capture\n5. Format cleanup",
            Duration = 6
        }
    end
}

-- Input code button
EditorSection:button{
    Name = "Paste Code",
    Description = "Click to enter your obfuscated code",
    Callback = function()
        local inputFrame = Instance.new("ScreenGui")
        inputFrame.Name = "LifterInput"
        inputFrame.Parent = game:GetService("CoreGui")
        inputFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local bg = Instance.new("Frame", inputFrame)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.5
        bg.BorderSizePixel = 0
        
        local container = Instance.new("Frame", bg)
        container.Size = UDim2.fromOffset(500, 350)
        container.Position = UDim2.fromScale(0.5, 0.5)
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        container.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner", container)
        corner.CornerRadius = UDim.new(0, 10)
        
        local title = Instance.new("TextLabel", container)
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.fromOffset(10, 10)
        title.BackgroundTransparency = 1
        title.Text = "Paste Obfuscated Code"
        title.TextColor3 = Color3.fromRGB(70, 130, 180)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 18
        title.TextXAlignment = Enum.TextXAlignment.Left
        
        local textBox = Instance.new("TextBox", container)
        textBox.Size = UDim2.new(1, -20, 1, -90)
        textBox.Position = UDim2.fromOffset(10, 45)
        textBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        textBox.BorderColor3 = Color3.fromRGB(70, 130, 180)
        textBox.BorderSizePixel = 1
        textBox.TextColor3 = Color3.fromRGB(220, 220, 220)
        textBox.Font = Enum.Font.Code
        textBox.TextSize = 14
        textBox.TextXAlignment = Enum.TextXAlignment.Left
        textBox.TextYAlignment = Enum.TextYAlignment.Top
        textBox.MultiLine = true
        textBox.ClearTextOnFocus = false
        textBox.PlaceholderText = "Paste your obfuscated Lua code here..."
        textBox.Text = codeInput
        
        local tbCorner = Instance.new("UICorner", textBox)
        tbCorner.CornerRadius = UDim.new(0, 5)
        
        local submitBtn = Instance.new("TextButton", container)
        submitBtn.Size = UDim2.fromOffset(100, 30)
        submitBtn.Position = UDim2.new(1, -110, 1, -35)
        submitBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        submitBtn.BorderSizePixel = 0
        submitBtn.Text = "Submit"
        submitBtn.TextColor3 = Color3.new(1, 1, 1)
        submitBtn.Font = Enum.Font.SourceSansBold
        submitBtn.TextSize = 14
        
        local sbCorner = Instance.new("UICorner", submitBtn)
        sbCorner.CornerRadius = UDim.new(0, 5)
        
        local cancelBtn = Instance.new("TextButton", container)
        cancelBtn.Size = UDim2.fromOffset(100, 30)
        cancelBtn.Position = UDim2.new(1, -220, 1, -35)
        cancelBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        cancelBtn.BorderSizePixel = 0
        cancelBtn.Text = "Cancel"
        cancelBtn.TextColor3 = Color3.new(1, 1, 1)
        cancelBtn.Font = Enum.Font.SourceSansBold
        cancelBtn.TextSize = 14
        
        local cbCorner = Instance.new("UICorner", cancelBtn)
        cbCorner.CornerRadius = UDim.new(0, 5)
        
        submitBtn.MouseButton1Click:Connect(function()
            codeInput = textBox.Text
            Lifter.State.CurrentCode = codeInput
            inputFrame:Destroy()
            GUI:notification{
                Title = "Code Loaded",
                Text = "Ready for multi-stage lifting!",
                Duration = 2
            }
        end)
        
        cancelBtn.MouseButton1Click:Connect(function()
            inputFrame:Destroy()
        end)
    end
}

EditorSection:button{
    Name = "Multi-Stage Lift",
    Description = "Advanced 5-stage deobfuscation",
    Callback = function()
        if #Lifter.State.CurrentCode == 0 then
            GUI:notification{
                Title = "No Code",
                Text = "Please paste code first!",
                Duration = 2
            }
            return
        end
        
        Lifter:LiftCode(Lifter.State.CurrentCode, function(lifted)
            codeOutput = lifted
        end)
    end
}

EditorSection:button{
    Name = "View Output",
    Description = "View the lifted code",
    Callback = function()
        if #codeOutput == 0 then
            GUI:notification{
                Title = "No Output",
                Text = "No lifted code available!",
                Duration = 2
            }
            return
        end
        
        local outputFrame = Instance.new("ScreenGui")
        outputFrame.Name = "LifterOutput"
        outputFrame.Parent = game:GetService("CoreGui")
        outputFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local bg = Instance.new("Frame", outputFrame)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.5
        bg.BorderSizePixel = 0
        
        local container = Instance.new("Frame", bg)
        container.Size = UDim2.fromOffset(650, 450)
        container.Position = UDim2.fromScale(0.5, 0.5)
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        container.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner", container)
        corner.CornerRadius = UDim.new(0, 10)
        
        local title = Instance.new("TextLabel", container)
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.fromOffset(10, 10)
        title.BackgroundTransparency = 1
        title.Text = "Deobfuscated Output"
        title.TextColor3 = Color3.fromRGB(70, 130, 180)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 18
        title.TextXAlignment = Enum.TextXAlignment.Left
        
        local scroll = Instance.new("ScrollingFrame", container)
        scroll.Size = UDim2.new(1, -20, 1, -90)
        scroll.Position = UDim2.fromOffset(10, 45)
        scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        scroll.BorderColor3 = Color3.fromRGB(70, 130, 180)
        scroll.BorderSizePixel = 1
        scroll.ScrollBarThickness = 4
        
        local scCorner = Instance.new("UICorner", scroll)
        scCorner.CornerRadius = UDim.new(0, 5)
        
        local textLabel = Instance.new("TextLabel", scroll)
        textLabel.Size = UDim2.new(1, -10, 1, 0)
        textLabel.Position = UDim2.fromOffset(5, 5)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
        textLabel.Font = Enum.Font.Code
        textLabel.TextSize = 14
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextYAlignment = Enum.TextYAlignment.Top
        textLabel.Text = codeOutput
        textLabel.TextWrapped = true
        
        textLabel.Size = UDim2.new(1, -10, 0, textLabel.TextBounds.Y + 10)
        scroll.CanvasSize = UDim2.new(0, 0, 0, textLabel.TextBounds.Y + 20)
        
        local copyBtn = Instance.new("TextButton", container)
        copyBtn.Size = UDim2.fromOffset(100, 30)
        copyBtn.Position = UDim2.new(1, -110, 1, -35)
        copyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        copyBtn.BorderSizePixel = 0
        copyBtn.Text = "Copy"
        copyBtn.TextColor3 = Color3.new(1, 1, 1)
        copyBtn.Font = Enum.Font.SourceSansBold
        copyBtn.TextSize = 14
        
        local cpCorner = Instance.new("UICorner", copyBtn)
        cpCorner.CornerRadius = UDim.new(0, 5)
        
        local closeBtn = Instance.new("TextButton", container)
        closeBtn.Size = UDim2.fromOffset(100, 30)
        closeBtn.Position = UDim2.new(1, -220, 1, -35)
        closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        closeBtn.BorderSizePixel = 0
        closeBtn.Text = "Close"
        closeBtn.TextColor3 = Color3.new(1, 1, 1)
        closeBtn.Font = Enum.Font.SourceSansBold
        closeBtn.TextSize = 14
        
        local clCorner = Instance.new("UICorner", closeBtn)
        clCorner.CornerRadius = UDim.new(0, 5)
        
        copyBtn.MouseButton1Click:Connect(function()
            setclipboard(codeOutput)
            GUI:notification{
                Title = "Copied",
                Text = "Code copied to clipboard!",
                Duration = 2
            }
        end)
        
        closeBtn.MouseButton1Click:Connect(function()
            outputFrame:Destroy()
        end)
    end
}

EditorSection:button{
    Name = "Execute Output",
    Description = "Run the deobfuscated code",
    Callback = function()
        if #codeOutput == 0 then
            GUI:notification{
                Title = "No Output",
                Text = "No code to execute!",
                Duration = 2
            }
            return
        end
        Lifter:ExecuteCode(codeOutput)
    end
}

EditorSection:button{
    Name = "Clear All",
    Description = "Reset everything",
    Callback = function()
        codeInput = ""
        codeOutput = ""
        Lifter.State.CurrentCode = ""
        GUI:notification{
            Title = "Cleared",
            Text = "All cleared!",
            Duration = 2
        }
    end
}

-- Utilities Tab
local UtilsTab = GUI:tab{
    Name = "Utilities",
    Icon = "rbxassetid://8559790237"
}

local QuickSection = UtilsTab:section{Name = "Quick Tools"}

QuickSection:button{
    Name = "Decode Octal Strings Only",
    Description = "Just decode \\xxx sequences",
    Callback = function()
        if #Lifter.State.CurrentCode > 0 then
            local decoded = Lifter:DecodeStrings(Lifter.State.CurrentCode)
            codeOutput = decoded
            GUI:notification{
                Title = "Decoded",
                Text = "Octal strings decoded!",
                Duration = 2
            }
        else
            GUI:notification{
                Title = "No Code",
                Text = "Paste code first!",
                Duration = 2
            }
        end
    end
}

QuickSection:button{
    Name = "Extract String Pool",
    Description = "Extract and decode constant arrays",
    Callback = function()
        if #Lifter.State.CurrentCode == 0 then
            GUI:notification{
                Title = "No Code",
                Text = "Paste code first!",
                Duration = 2
            }
            return
        end
        
        local code = Lifter.State.CurrentCode
        local strings = {}
        local count = 0
        
        -- First decode octal sequences
        code = Lifter:DecodeStrings(code)
        
        -- Extract string arrays (look for patterns like P = { "...", "...", ... })
        for arrayContent in code:gmatch('=%s*{([^}]+)}') do
            for str in arrayContent:gmatch('"([^"]*)"') do
                if #str > 0 then
                    count = count + 1
                    table.insert(strings, string.format('[%d] = "%s"', count, str))
                end
            end
        end
        
        if #strings > 0 then
            codeOutput = "-- Extracted String Pool (" .. count .. " strings)\n\n" .. table.concat(strings, "\n")
            GUI:notification{
                Title = "Extracted",
                Text = string.format("Found %d strings!", count),
                Duration = 3
            }
        else
            GUI:notification{
                Title = "None Found",
                Text = "No string pools detected",
                Duration = 2
            }
        end
    end
}

QuickSection:button{
    Name = "Copy Output",
    Description = "Quick copy to clipboard",
    Callback = function()
        if #codeOutput > 0 then
            setclipboard(codeOutput)
            GUI:notification{
                Title = "Copied",
                Text = "Copied!",
                Duration = 2
            }
        else
            GUI:notification{
                Title = "Empty",
                Text = "Nothing to copy!",
                Duration = 2
            }
        end
    end
}

-- Welcome
GUI:notification{
    Title = "Zukas Lifter Pro",
    Text = "Multi-stage deobfuscator ready!",
    Duration = 3
}

print("[LIFTER PRO] Enhanced Mercury version loaded!")
