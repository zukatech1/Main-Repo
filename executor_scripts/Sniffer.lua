local Players: Players = game:GetService("Players")

-- This represents the 'Goldmine' logic you found
local base64_chars: string = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- A standard Base64 decoder we can use once we've intercepted the data
local function Decode(data: string): string
    data = string.gsub(data, '[^'..base64_chars..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(base64_chars:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- The Hook: Intercepting the 'Goldmine'
local mt: any = getrawmetatable(game)
local oldNamecall: (any, ...any) -> ...any = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self: any, ...: any): ...any
    local args: {any} = {...}
    local method: string = getnamecallmethod()

    if method == "FireServer" then
        for i: number, arg: any in pairs(args) do
            if type(arg) == "string" and #arg > 8 then
                -- Check if the string matches Base64 entropy
                local isBase64: boolean = arg:match("^([A-Za-z0-9+/=]+)$") ~= nil
                
                if isBase64 then
                    local decoded: string = Decode(arg)
                    print("--- ENCODED PACKET DETECTED ---")
                    print("Remote: ", self.Name)
                    print("Raw: ", arg)
                    print("Decoded: ", decoded)
                    
                    -- The "Poison": If we find 'Damage' in the decoded string, we manipulate it
                    -- and then RE-ENCODE it (using the game's own logic) before sending.
                end
            end
        end
    end

    return oldNamecall(self, ...)
end)

setreadonly(mt, true)