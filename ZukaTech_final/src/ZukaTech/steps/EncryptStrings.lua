-- Obfuscation Step: Encrypt Strings

local Step = require("ZukaTech.step")
local Ast = require("ZukaTech.ast")
local Scope = require("ZukaTech.scope")
local RandomStrings = require("ZukaTech.randomStrings")
local Parser = require("ZukaTech.parser")
local Enums = require("ZukaTech.enums")
local logger = require("logger")
local visitast = require("ZukaTech.visitast");
local util     = require("ZukaTech.util")
local AstKind = Ast.AstKind;

local EncryptStrings = Step:extend()
EncryptStrings.Description = "This Step will encrypt strings within your Program."
EncryptStrings.Name = "Encrypt Strings"

EncryptStrings.SettingsDescriptor = {}

function EncryptStrings:init(settings) end


function EncryptStrings:CreateEncrypionService()
	local usedSeeds = {};

	-- Keys with different bit widths than original to change fingerprint
	local key_a = math.random(1, 255)        -- xor base key
	local key_b = math.random(0, 511)        -- 9-bit mix key
	local key_c = math.random(0, 8191)       -- 13-bit lcg seed component
	local key_d = math.random(0, 65535)      -- 16-bit additive constant

	local floor = math.floor

	-- Lua 5.1 compatible XOR (no ~ operator)
	local function bxor(a, b)
		local r, m = 0, 1
		while a > 0 or b > 0 do
			local ra = a % 2
			local rb = b % 2
			if ra ~= rb then r = r + m end
			a = floor(a / 2)
			b = floor(b / 2)
			m = m * 2
		end
		return r
	end

	-- Simple LCG-based state with different multiplier/modulus than original
	-- Using a different prime multiplier: 1664525 (Numerical Recipes)
	local lcg_mul = 1664525
	local lcg_add = key_d * 2 + 1
	local lcg_mod = 2^32

	-- Key splitting: split each key into two parts so the real values never
	-- appear as plaintext literals in the emitted runtime code.
	-- All arithmetic is done at compile time here; only split parts are emitted.
	local function ct_bxor(a, b)
		local r, m = 0, 1
		while a > 0 or b > 0 do
			local ra = a % 2; local rb = b % 2
			if ra ~= rb then r = r + m end
			a = math.floor(a/2); b = math.floor(b/2); m = m*2
		end
		return r
	end

	-- key_a split: ka_p1 + ka_p2 == key_a
	local ka_p1 = math.random(1, math.max(1, key_a - 1))
	local ka_p2 = key_a - ka_p1

	-- lcg_mul split: lm_p1 + lm_p2 == lcg_mul
	local lm_p1 = math.random(100000, 1000000)
	local lm_p2 = lcg_mul - lm_p1

	-- lcg_add split via XOR mask: stored XOR la_xor, recovered by XOR at runtime
	local la_xor    = math.random(1, 65535)
	local la_masked = ct_bxor(math.floor(lcg_add) % (2^32), la_xor)

	local state_lcg = 0
	local rot_state = 1

	local prev_bytes = {}

	local function set_seed(seed)
		state_lcg = seed % lcg_mod
		rot_state  = (seed % 251) + 1  -- keep in 1..251
		prev_bytes = {}
	end

	local function gen_seed()
		local seed
		repeat
			seed = math.random(0, 2147483647)
		until not usedSeeds[seed]
		usedSeeds[seed] = true
		return seed
	end

	-- Different PRNG output: combines LCG with a small rotation counter
	local function next_rand_32()
		state_lcg = (state_lcg * lcg_mul + lcg_add) % lcg_mod
		-- mix in rot_state so consecutive outputs differ more
		rot_state = (rot_state * 37 + 7) % 251 + 1
		local mixed = (state_lcg + rot_state * 65537) % lcg_mod
		return floor(mixed)
	end

	local function get_next_byte()
		if #prev_bytes == 0 then
			local r   = next_rand_32()
			local b1  = r % 256
			local b2  = floor(r / 256) % 256
			local b3  = floor(r / 65536) % 256
			local b4  = floor(r / 16777216) % 256
			prev_bytes = { b1, b2, b3, b4 }
		end
		return table.remove(prev_bytes)
	end

	-- Encrypt: XOR with (prng_byte XOR rolling_key) instead of subtract
	local function encrypt(str)
		local seed = gen_seed()
		set_seed(seed)
		local len = #str
		local out = {}
		local roll = key_a   -- rolling xor key, starts at key_a
		for i = 1, len do
			local b = string.byte(str, i)
			local kb = get_next_byte()
			-- XOR the byte with combined key, then roll
			out[i] = string.char(bxor(b, bxor(kb, roll)) % 256)
			roll = (roll + b + 13) % 256
		end
		return table.concat(out), seed
	end

	local function genCode()
		-- Runtime decryption mirrors the encrypt logic above.
		-- Keys are reconstructed from split parts so they never appear plaintext.
		local code = [[
do
	local floor = math.floor
	local random = math.random
	local remove = table.remove
	local char   = string.char
	local byte   = string.byte
	local len    = string.len

	-- Helper bxor needed to reconstruct lcg_add from its masked form
	local function _bxor(a,b) local r,m=0,1 while a>0 or b>0 do local ra=a%2 local rb=b%2 if ra~=rb then r=r+m end a=floor(a/2) b=floor(b/2) m=m*2 end return r end
	-- Keys reconstructed at runtime from split halves (no plaintext key values in bytecode)
	local lcg_mul  = ]] .. tostring(lm_p1) .. [[ + ]] .. tostring(lm_p2) .. [[
	local lcg_add  = _bxor(]] .. tostring(la_masked) .. [[, ]] .. tostring(la_xor) .. [[)
	local lcg_mod  = 2^32
	local key_a    = ]] .. tostring(ka_p1) .. [[ + ]] .. tostring(ka_p2) .. [[
	local floor    = math.floor

	local function bxor(a, b)
		local r, m = 0, 1
		while a > 0 or b > 0 do
			local ra = a % 2
			local rb = b % 2
			if ra ~= rb then r = r + m end
			a = floor(a / 2)
			b = floor(b / 2)
			m = m * 2
		end
		return r
	end
	local state_lcg = 0
	local rot_state  = 1
	local prev_bytes = {}

	local charmap = {}
	local nums = {}
	for i = 1, 256 do nums[i] = i end
	repeat
		local idx = random(1, #nums)
		local n   = remove(nums, idx)
		charmap[n] = char(n - 1)
	until #nums == 0

	local function next_rand_32()
		state_lcg = (state_lcg * lcg_mul + lcg_add) % lcg_mod
		rot_state  = (rot_state * 37 + 7) % 251 + 1
		return floor((state_lcg + rot_state * 65537) % lcg_mod)
	end

	local function get_next_byte()
		if #prev_bytes == 0 then
			local r  = next_rand_32()
			local b1 = r % 256
			local b2 = floor(r / 256) % 256
			local b3 = floor(r / 65536) % 256
			local b4 = floor(r / 16777216) % 256
			prev_bytes = { b1, b2, b3, b4 }
		end
		return remove(prev_bytes)
	end

	local realStrings = {}
	STRINGS = setmetatable({}, {
		__index = realStrings,
		__metatable = nil,
	})

	function DECRYPT(str, seed)
		local cache = realStrings
		if not cache[seed] then
			prev_bytes  = {}
			state_lcg   = seed % lcg_mod
			rot_state   = (seed % 251) + 1
			local slen  = len(str)
			local roll  = key_a
			local parts = {}
			local cm    = charmap
			for i = 1, slen do
				local enc = byte(str, i)
				local kb  = get_next_byte()
				local dec = bxor(enc, bxor(kb, roll)) % 256
				parts[i]  = cm[dec + 1]
				roll       = (roll + dec + 13) % 256
			end
			cache[seed] = table.concat(parts)
		end
		return seed
	end
end]]
		return code
	end

	return {
		encrypt  = encrypt,
		genCode  = genCode,
		-- expose keys so nothing breaks if other steps inspect them
		key_a    = key_a,
		lcg_mul  = lcg_mul,
		lcg_add  = lcg_add,
	}
end

function EncryptStrings:apply(ast, pipeline)
	local Encryptor = self:CreateEncrypionService()

	local code   = Encryptor.genCode()
	local newAst = Parser:new({ LuaVersion = Enums.LuaVersion.Lua51 }):parse(code)
	local doStat = newAst.body.statements[1]

	local scope      = ast.body.scope
	local decryptVar = scope:addVariable()
	local stringsVar = scope:addVariable()

	doStat.body.scope:setParent(ast.body.scope)

	visitast(newAst, nil, function(node, data)
		if node.kind == AstKind.FunctionDeclaration then
			if node.scope:getVariableName(node.id) == "DECRYPT" then
				data.scope:removeReferenceToHigherScope(node.scope, node.id)
				data.scope:addReferenceToHigherScope(scope, decryptVar)
				node.scope = scope
				node.id    = decryptVar
			end
		end
		if node.kind == AstKind.AssignmentVariable or node.kind == AstKind.VariableExpression then
			if node.scope:getVariableName(node.id) == "STRINGS" then
				data.scope:removeReferenceToHigherScope(node.scope, node.id)
				data.scope:addReferenceToHigherScope(scope, stringsVar)
				node.scope = scope
				node.id    = stringsVar
			end
		end
	end)

	visitast(ast, nil, function(node, data)
		if node.kind == AstKind.StringExpression then
			data.scope:addReferenceToHigherScope(scope, stringsVar)
			data.scope:addReferenceToHigherScope(scope, decryptVar)
			local encrypted, seed = Encryptor.encrypt(node.value)
			return Ast.IndexExpression(
				Ast.VariableExpression(scope, stringsVar),
				Ast.FunctionCallExpression(Ast.VariableExpression(scope, decryptVar), {
					Ast.StringExpression(encrypted),
					Ast.NumberExpression(seed),
				})
			)
		end
	end)

	table.insert(ast.body.statements, 1, doStat)
	table.insert(ast.body.statements, 1, Ast.LocalVariableDeclaration(scope, util.shuffle{ decryptVar, stringsVar }, {}))
	return ast
end

return EncryptStrings