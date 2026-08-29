local vm = require(script.Parent);
vm.init("ServerScriptService.Test");
vm.execute_code([[
	local hook; hook = hookfunction(loadstring, function(...)
		local arg = ...;
		if (type(arg) == "string") then
			print(arg);
		end;
		return hook(...);
	end);
	local hook; hook = hookmetamethod(game, "__namecall", function(...)
		local method = getnamecallmethod();
		local self = ...;
		if (typeof(self) == "Instance") then
			print("__namecall", self, method);
		end;
		return hook(...);
	end);
	local hook; hook = hookmetamethod(game, "__index", function(...)
		local self, index = ...;
		if (typeof(self) == "Instance" and type(index) == "string") then
			print("__index", self, index);
		end;
		return hook(...);
	end);
	
	-- code below, u have all the tools u need including debug.setconstant, debug.getconstant, everything seen in executors
	print(game.CreatorId);
	
]]);