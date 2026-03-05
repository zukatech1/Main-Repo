-- namegenerators/mangled.lua
-- Generates short mangled variable names

local util = require("ZukaTech.util");
local chararray = util.chararray;

-- Charset reordered: digits and underscore mixed in, breaks alphabetical pattern
local VarDigits = chararray("aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ0123456789_");
local VarStartDigits = chararray("aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ");

return function(id, scope)
	local name = ''
	local d = id % #VarStartDigits
	id = (id - d) / #VarStartDigits
	name = name .. VarStartDigits[d + 1]
	while id > 0 do
		local d = id % #VarDigits
		id = (id - d) / #VarDigits
		name = name .. VarDigits[d + 1]
	end
	return name
end