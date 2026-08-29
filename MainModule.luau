--!nocheck
--!native
const self = {renv = {}; genv = {}} :: {[string]: any};
self.metatable_locked_str = getmetatable(game) :: string;
for i: string, v: Instance in script:GetDescendants() do
	if (v:IsA("ModuleScript") and not v:GetAttribute("Ignored")) then
		const required_result = require(v) :: (...any) -> (...any)
		if (type(required_result) == "function" and debug.info(required_result, "s") ~= "[C]") then
			for i: any, v: any in required_result(self) do
				self[i] = v :: any;
			end;
		end;
	end;
end;
return self;
