-- This Script is Part of the ZukaTech Obfuscator by Levno_710
--
-- cli.lua
-- This script contains the Code for the ZukaTech CLI

-- Configure package.path for requiring ZukaTech
local function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)
	return str:match("(.*[/%\\])")
end
package.path = script_path() .. "?.lua;" .. package.path;
---@diagnostic disable-next-line: different-requires
local ZukaTech = require("ZukaTech");
ZukaTech.Logger.logLevel = ZukaTech.Logger.LogLevel.Info;

-- Check if the file exists
local function file_exists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

string.split = function(str, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
local function lines_from(file)
    if not file_exists(file) then return {} end
    local lines = {}
    for line in io.lines(file) do
      lines[#lines + 1] = line
    end
    return lines
  end

-- CLI
local config;
local sourceFile;
local outFile;
local luaVersion;
local prettyPrint;

ZukaTech.colors.enabled = true;

-- Parse Arguments
local i = 1;
while i <= #arg do
    local curr = arg[i];
    if curr:sub(1, 2) == "--" then
        if curr == "--preset" or curr == "--p" then
            if config then
                ZukaTech.Logger:warn("The config was set multiple times");
            end

            i = i + 1;
            local preset = ZukaTech.Presets[arg[i]];
            if not preset then
                ZukaTech.Logger:error(string.format("A Preset with the name \"%s\" was not found!", tostring(arg[i])));
            end

            config = preset;
        elseif curr == "--config" or curr == "--c" then
            i = i + 1;
            local filename = tostring(arg[i]);
            if not file_exists(filename) then
                ZukaTech.Logger:error(string.format("The config file \"%s\" was not found!", filename));
            end

            local content = table.concat(lines_from(filename), "\n");
            -- Load Config from File
            local func = loadstring(content);
            -- Sandboxing
            setfenv(func, {});
            config = func();
        elseif curr == "--out" or curr == "--o" then
            i = i + 1;
            if(outFile) then
                ZukaTech.Logger:warn("The output file was specified multiple times!");
            end
            outFile = arg[i];
        elseif curr == "--nocolors" then
            ZukaTech.colors.enabled = false;
        elseif curr == "--Lua51" then
            luaVersion = "Lua51";
        elseif curr == "--LuaU" then
            luaVersion = "LuaU";
        elseif curr == "--pretty" then
            prettyPrint = true;
        elseif curr == "--saveerrors" then
            -- Override error callback
            ZukaTech.Logger.errorCallback =  function(...)
                print(ZukaTech.colors(ZukaTech.Config.NameUpper .. ": " .. ..., "red"))
                
                local args = {...};
                local message = table.concat(args, " ");
                
                local fileName = sourceFile:sub(-4) == ".lua" and sourceFile:sub(0, -5) .. ".error.txt" or sourceFile .. ".error.txt";
                local handle = io.open(fileName, "w");
                handle:write(message);
                handle:close();

                os.exit(1);
            end;
        else
            ZukaTech.Logger:warn(string.format("The option \"%s\" is not valid and therefore ignored", curr));
        end
    else
        if sourceFile then
            ZukaTech.Logger:error(string.format("Unexpected argument \"%s\"", arg[i]));
        end
        sourceFile = tostring(arg[i]);
    end
    i = i + 1;
end

if not sourceFile then
    ZukaTech.Logger:error("No input file was specified!")
end

if not config then
    ZukaTech.Logger:warn("No config was specified, falling back to Minify preset");
    config = ZukaTech.Presets.Minify;
end

-- Add Option to override Lua Version
-- Default to LuaU so compound operators (+=, -=, etc.) are always supported.
-- Pass --Lua51 explicitly on the command line to opt into strict Lua 5.1 mode.
config.LuaVersion = luaVersion or "LuaU";
config.PrettyPrint = prettyPrint ~= nil and prettyPrint or config.PrettyPrint;

if not file_exists(sourceFile) then
    ZukaTech.Logger:error(string.format("The File \"%s\" was not found!", sourceFile));
end

if not outFile then
    if sourceFile:sub(-4) == ".lua" then
        outFile = sourceFile:sub(0, -5) .. ".obfuscated.lua";
    else
        outFile = sourceFile .. ".obfuscated.lua";
    end
end

local source = table.concat(lines_from(sourceFile), "\n");
local pipeline = ZukaTech.Pipeline:fromConfig(config);
local out = pipeline:apply(source, sourceFile);
ZukaTech.Logger:info(string.format("Writing output to \"%s\"", outFile));

-- Write Output
local handle = io.open(outFile, "w");
handle:write(out);
handle:close();