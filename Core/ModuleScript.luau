--!strict
--!native
return function(self: {[string]: any}): {[string]: any}
	self.func_name_data = {};
	self.renv = {replacements = {}};
	self.globals = {};
	return {
		push_global = function(global_str: string, name_str: string, entry: any): ()
			local entry_type_str: string = type(entry);
			if (entry_type_str == "function") then
				entry = self.mk_closure(entry, {debugname = name_str});
			elseif (entry_type_str == "table") then
				for i: string, v: any in entry do
					if (type(v) == "function") then
						const wrapped: (...any) -> (...any) = self.mk_closure(v, {debugname = i});
						entry[i] = wrapped;
						self.globals[wrapped] = true;
					end;
				end;
			end;
			if (global_str == "exploit_env") then
				self.genv[name_str] = entry;
				if (entry_type_str == "function") then
					self.globals[entry] = true;
				end;
			elseif (global_str == "roblox_env") then
				self.renv.replacements[name_str] = entry;
			else
				error("retard")
			end;
			return;
		end,
		init = function(script_name_str: string): ()
			self.script_name_str = script_name_str;
			const init_script_source_str: string = [[
				
			]];
			self.build_env();
			self.write_luau_settings();
			for i: string, v: any in self.renv.replacements do
				rawset(self.renv, i, v);
			end;
			--rawset(self.renv.debug, "info", self.debug_info_replacement);
			rawset(self.renv, "replacements", nil);
			do
				const rbx_debug_lib: {[string]: any} = self.renv.debug;
				const exploit_debug_lib: {[string]: any} = self.genv.debug;
				for i: string, v: any in rbx_debug_lib do
					exploit_debug_lib[i] = v;
				end;
			end;
			self.execute_code(init_script_source_str);
			return;
		end,
	};
end;
