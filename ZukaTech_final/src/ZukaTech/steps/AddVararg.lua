-- Obfuscation Step: Add Vararg

local Step = require("ZukaTech.step");
local Ast = require("ZukaTech.ast");
local visitast = require("ZukaTech.visitast");
local AstKind = Ast.AstKind;

local AddVararg = Step:extend();
AddVararg.Description = "This Step Adds Vararg to all Functions";
AddVararg.Name = "Add Vararg";

AddVararg.SettingsDescriptor = {
	Treshold = {
		name = "Treshold",
		description = "The relative amount of functions that will have vararg added",
		type = "number",
		default = 1,
		min = 0,
		max = 1,
	},
}

function AddVararg:init(settings)

end

function AddVararg:apply(ast)
	local treshold = self.Treshold or 1;
	visitast(ast, nil, function(node)
		if node.kind == AstKind.FunctionDeclaration
		or node.kind == AstKind.LocalFunctionDeclaration
		or node.kind == AstKind.FunctionLiteralExpression then
			-- Only apply to functions that pass the treshold roll
			if math.random() <= treshold then
				local args = node.args;
				local last = args[#args];
				-- Only add vararg if not already present
				if not last or last.kind ~= AstKind.VarargExpression then
					args[#args + 1] = Ast.VarargExpression();
				end
			end
		end
	end)
end

return AddVararg;