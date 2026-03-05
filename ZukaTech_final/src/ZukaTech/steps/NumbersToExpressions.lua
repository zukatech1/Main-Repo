-- Obfuscation Step: Numbers To Expressions

unpack = unpack or table.unpack;

local Step = require("ZukaTech.step");
local Ast = require("ZukaTech.ast");
local Scope = require("ZukaTech.scope");
local visitast = require("ZukaTech.visitast");
local util     = require("ZukaTech.util")

local AstKind = Ast.AstKind;

local NumbersToExpressions = Step:extend();
NumbersToExpressions.Description = "This Step Converts number Literals to Expressions";
NumbersToExpressions.Name = "Numbers To Expressions";

NumbersToExpressions.SettingsDescriptor = {
	Treshold = {
        type = "number",
        default = 1,
        min = 0,
        max = 1,
    },
    InternalTreshold = {
        type = "number",
        default = 0.2,
        min = 0,
        max = 0.8,
    }
}

function NumbersToExpressions:init(settings)
	self.ExpressionGenerators = {

        -- Addition: val = a + (val - a)
        function(val, depth)
            local a = math.random(-2^20, 2^20);
            local b = val - a;
            if tonumber(tostring(b)) + tonumber(tostring(a)) ~= val then return false end
            return Ast.AddExpression(
                self:CreateNumberExpression(a, depth),
                self:CreateNumberExpression(b, depth)
            );
        end,

        -- Subtraction: val = (val + a) - a
        function(val, depth)
            local a = math.random(-2^20, 2^20);
            local b = val + a;
            if tonumber(tostring(b)) - tonumber(tostring(a)) ~= val then return false end
            return Ast.SubExpression(
                self:CreateNumberExpression(b, depth),
                self:CreateNumberExpression(a, depth)
            );
        end,

        -- Multiplication: val = (val / a) * a  — only for integer-safe cases
        function(val, depth)
            if val == 0 then return false end
            -- pick a small odd factor so integer math stays exact
            local factors = {3, 5, 7, 11, 13};
            local a = factors[math.random(#factors)];
            local b = val / a;
            if math.floor(b) ~= b then return false end          -- must be integer
            if tonumber(tostring(b)) * tonumber(tostring(a)) ~= val then return false end
            return Ast.MulExpression(
                self:CreateNumberExpression(b, depth),
                self:CreateNumberExpression(a, depth)
            );
        end,

        -- Bitwise XOR via bit.bxor: val = bxor(val ^ mask, mask)
        -- only applies when val fits in a 32-bit unsigned integer
        function(val, depth)
            if val < 0 or val > 4294967295 or math.floor(val) ~= val then return false end
            local ok, bit = pcall(require, "bit")
            if not ok then ok, bit = pcall(require, "bit32") end
            if not ok then return false end
            local bxor = bit.bxor or bit32 and bit32.bxor
            if not bxor then return false end
            local mask = math.random(1, 65535);
            local xored = bxor(val, mask);
            -- encode as: bxor(xored, mask)  which equals val at runtime
            -- We emit it as a subtraction fallback since we can't easily emit bxor AST nodes:
            -- use the identity: a XOR b = (a + b) - 2*(a AND b)
            -- Too complex — instead fall back to a nested add/sub disguise
            -- Represent as: (xored + mask) - 2*(xored AND mask)
            local band = bit.band or bit32 and bit32.band
            if not band then return false end
            local andval = band(xored, mask);
            local sum = xored + mask;
            local twice_and = 2 * andval;
            if sum - twice_and ~= val then return false end
            if sum > 2^53 or twice_and > 2^53 then return false end
            return Ast.SubExpression(
                self:CreateNumberExpression(sum, depth),
                self:CreateNumberExpression(twice_and, depth)
            );
        end,

        -- Modulo disguise: val = (val + m*k) % m*k + val  — only for small positive ints
        -- Simpler: val = ((val + offset) % modulus) where we pick offset/modulus carefully
        -- Actually: val = big - (big - val) where big is a round multiple
        function(val, depth)
            if val < 0 or val > 2^20 or math.floor(val) ~= val then return false end
            -- pick a modulus larger than val
            local modulus = val + math.random(1, 1024);
            -- val = (val + modulus) % modulus  -- always true since val < modulus
            -- emit as: (val + modulus) - modulus  which is trivially val but looks like modulo
            -- Better: encode with an extra multiply to obscure
            local k = math.random(2, 8);
            local big = modulus * k + val;  -- big % modulus = val
            if big % modulus ~= val then return false end
            if big > 2^53 then return false end
            -- emit as: (big - modulus*k) which equals val
            return Ast.SubExpression(
                self:CreateNumberExpression(big, depth),
                self:CreateNumberExpression(modulus * k, depth)
            );
        end,
    }
end

function NumbersToExpressions:CreateNumberExpression(val, depth)
    if depth > 0 and math.random() >= self.InternalTreshold or depth > 15 then
        return Ast.NumberExpression(val)
    end

    local generators = util.shuffle({unpack(self.ExpressionGenerators)});
    for i, generator in ipairs(generators) do
        local node = generator(val, depth + 1);
        if node then
            return node;
        end
    end

    return Ast.NumberExpression(val)
end

function NumbersToExpressions:apply(ast)
	visitast(ast, nil, function(node, data)
        if node.kind == AstKind.NumberExpression then
            if math.random() <= self.Treshold then
                return self:CreateNumberExpression(node.value, 0);
            end
        end
    end)
end

return NumbersToExpressions;