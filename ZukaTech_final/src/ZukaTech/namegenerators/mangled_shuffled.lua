-- namegenerators/mangled_shuffled.lua
-- Generates short mangled variable names with shuffled character order

local util = require("ZukaTech.util");
local chararray = util.chararray;

-- Interleaved case order makes the charset less obviously sequential
local VarDigits      = chararray("aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ0123456789_");
local VarStartDigits = chararray("aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ");

-- Optional unicode lookalike characters that are valid Lua identifiers.
-- When mixed into names they are visually indistinguishable from ASCII,
-- making manual analysis significantly harder.
-- Comment this table out if your target environment doesn't support unicode idents.
local lookalikes = {
	["a"] = "\xD0\xB0",  -- Cyrillic а (looks like Latin a)
	["c"] = "\xD1\x81",  -- Cyrillic с (looks like Latin c)
	["e"] = "\xD0\xB5",  -- Cyrillic е (looks like Latin e)
	["o"] = "\xD0\xBE",  -- Cyrillic о (looks like Latin o)
	["p"] = "\xD1\x80",  -- Cyrillic р (looks like Latin p)
	["x"] = "\xD1\x85",  -- Cyrillic х (looks like Latin x)
}
local useLookalikes = false  -- set to true to enable unicode mixing

local function generateName(id, scope)
	local name = ''
	local d = id % #VarStartDigits
	id = (id - d) / #VarStartDigits
	local startChar = VarStartDigits[d + 1]
	if useLookalikes and lookalikes[startChar] and math.random() < 0.3 then
		startChar = lookalikes[startChar]
	end
	name = name .. startChar
	while id > 0 do
		local d = id % #VarDigits
		id = (id - d) / #VarDigits
		local ch = VarDigits[d + 1]
		if useLookalikes and lookalikes[ch] and math.random() < 0.3 then
			ch = lookalikes[ch]
		end
		name = name .. ch
	end
	return name
end

local function prepare(ast)
	util.shuffle(VarDigits)
	util.shuffle(VarStartDigits)
end

return {
	generateName = generateName,
	prepare      = prepare,
}