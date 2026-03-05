-- namegenerators/confuse.lua
-- Generates confusing but plausible variable names

local util = require("ZukaTech.util");
local chararray = util.chararray;

-- Word list replaced entirely - avoids ZukaTech fingerprint words
-- (no roblox, gmod, isWindows etc.)
local prefixes = {
	"get", "set", "has", "is", "do", "on", "to", "of",
	"make", "build", "find", "seek", "init", "run",
	"try", "use", "map", "bind", "emit", "send",
}

local nouns = {
	"node", "item", "list", "pool", "heap", "slot",
	"task", "unit", "port", "pipe", "flag", "mode",
	"page", "view", "form", "grid", "cell", "edge",
	"root", "leaf", "link", "path", "span", "zone",
	"step", "pass", "mark", "clip", "fill", "trim",
	"wrap", "pack", "seal", "lock", "mask", "hash",
	"chunk", "block", "frame", "patch", "token", "field",
	"entry", "limit", "quota", "ratio", "delta", "sigma",
	"alpha", "gamma", "kappa", "omega", "theta", "zeta",
	"pivot", "proxy", "guard", "cache", "store", "depot",
	"queue", "stack", "deque", "trie", "graph", "tuple",
}

local suffixes = {
	"_t", "_v", "_n", "_k", "_x", "_z",
	"0", "1", "2",
	"", "", "", "", "", "", -- weighted toward no suffix
}

-- Short single-letter names mixed in for realism
local singles = { "a", "b", "c", "d", "e", "f", "g", "h",
                  "i", "j", "k", "l", "m", "n", "o", "p",
                  "r", "s", "t", "u", "v", "w", "x", "y" }

local function generateName(id, scope)
	-- Every ~8th name is a short single to keep things varied
	if id % 8 == 0 then
		local idx = (id / 8) % #singles
		return singles[idx + 1]
	end

	-- Build a compound name from prefix + noun + suffix
	local pi = id % #prefixes
	id = (id - pi) / #prefixes
	local ni = id % #nouns
	id = (id - ni) / #nouns
	local si = id % #suffixes

	local prefix = prefixes[pi + 1]
	local noun   = nouns[ni + 1]
	local suffix = suffixes[si + 1]

	-- Randomly decide whether to include the prefix (adds variation)
	-- Use id-derived determinism so same id always gives same name
	if (pi + ni) % 3 == 0 then
		return noun .. suffix
	end

	return prefix .. noun:sub(1,1):upper() .. noun:sub(2) .. suffix
end

local function prepare(ast)
	-- Shuffle all three tables so each obfuscation run produces different names
	util.shuffle(prefixes)
	util.shuffle(nouns)
	util.shuffle(suffixes)
	util.shuffle(singles)
end

return {
	generateName = generateName,
	prepare      = prepare,
}