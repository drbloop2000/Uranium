--!nonstrict
--!native
--!nolint DeprecatedApi
return function(self: {[string]: any}): {[string]: any}
	self.tostring_fix = {};
	const replacements: {[string]: any} = {
		getfenv = function(...: any): any
			const arg: any? = (... or 1);
			if (type(arg) == "function") then
				const proto: {[string]: any} = self.Fiu.get_function_proto(arg);
				return proto.env;
			elseif (type(arg) == "number") then
				if (arg < 0) then
					return getfenv(...);
				elseif (arg == 0) then -- thread env, this is prob incorrect but wutever
					return self.genv;
				end;
				const call_frame: {[string]: any}? = self.Fiu.fetch_from_callstack(arg);
				if (call_frame) then
					return call_frame.proto.env;
				end;
				return getfenv(9999) :: never;
			end;
			return getfenv(...);
		end,
		setfenv = function(...: any): any
			const arg: any?, new_env: {[string]: any} = ...;
			if (type(new_env) ~= "table") then 
				return setfenv(...);
			elseif (type(arg) == "number" and arg < 0) then
				return setfenv(...);
			end;
			if (type(arg) == "function") then
				const proto: {[string]: any} = self.Fiu.get_function_proto(arg);
				if (proto and not proto.CClosure) then
					proto.env = new_env;
					return proto.wrapped;
				end;
				return setfenv(xpcall, {}) :: never;
			elseif type(arg) == "number" then
				if (arg == 0) then -- thread env, this is prob incorrect but wutever
					self.genv = new_env;
					return;
				end;
				const call_frame: {[string]: any}? = self.Fiu.fetch_from_callstack(arg);
				if (call_frame) then
					call_frame.proto.env = new_env;
					return call_frame.proto.wrapped;
				end;
				return setfenv(9999, {}) :: never;
			end;
			return setfenv(...);
		end,
		setmetatable = function(obj: any, mt: {[string]: any}): {[string]: any}
			const setmt_result = setmetatable(obj, mt);
			self.metatables[setmt_result] = mt;
			self.tostring_fix[setmt_result] = true;
			return setmt_result;
		end,
		newproxy = function(include_mt: boolean): any
			const newproxy_result: any = newproxy(include_mt);
			if (include_mt) then
				const metatable: {[string]: any}? = getmetatable(newproxy_result);
				self.metatables[newproxy_result] = metatable;
				self.tostring_fix[metatable] = true;
			end;
			return newproxy_result;
		end,
		loadstring = function(...: any): (...any) -> (...any)
			const source_str: string = ...;
			assert(source_str and type(source_str) == "string", `invalid argument #1 to 'loadstring' (string expected, got {typeof(source_str)})`);
			return function()
				return self.execute_code(source_str);
			end;
		end,
		--[[Instance = {
			new = @native function(...: any): ...any
				const result: any = Instance.new(...);
				return self.proxy(result);
			end,
			fromExisting = @native function(...: any): ...any
				const result: any = Instance.fromExisting(...);
				return self.proxy(result)
			end,
		};]]
		debug = {
			info = function(...: any): ...any -- TODO: duplicate option check, how did i miss this??
				local first_arg: any, options_or_level: any, thread_options: any = ...;
				const first_arg_type_str: string = type(first_arg);
				const result: {[number]: any} = {debug.info(...)};
				if (type(options_or_level) == "string") then
					const duplicate: number = options_or_level:match("(.).*%1");
					if (duplicate) then
						return debug.info(xpcall, options_or_level);
					end;
				end;
				if (type(thread_options) == "string") then
					const duplicate: number = thread_options:match("(.).*%1");
					if (duplicate) then
						return debug.info(xpcall, thread_options);
					end;
				end;
				if (first_arg_type_str == "thread") then -- TODO: pain
					-- im probably never gonna do this, make a pr or something idk
					return error("debug.info thread arugment is not currently supported yet");
				elseif (first_arg_type_str == "function" and type(options_or_level) == "string") then
					const func_proto: {[string]: any} = self.Fiu.get_function_proto(first_arg);
					const iscclosure: boolean = func_proto.CClosure;
					const source: number? = string.find(options_or_level, "s");
					const line_defined: number? = string.find(options_or_level, "l");
					const func_name: number? = string.find(options_or_level, "n");
					const num_of_parameters: number? = string.find(options_or_level, "a");
					if (source) then
						rawset(result, source, (iscclosure and "[C]" or self.script_name_str));
					end;
					if (line_defined) then
						rawset(result, line_defined, (iscclosure and -1 or func_proto.linedefined));
					end;
					if (func_name) then
						rawset(result, func_name, func_proto.debugname);
					end;
					if (num_of_parameters) then
						rawset(result, num_of_parameters, func_proto.numparams); -- numparams
						rawset(result, (num_of_parameters + 1), func_proto.isvararg); -- isvararg
					end;
					return table.unpack(result);
				elseif (first_arg_type_str == "number" and type(options_or_level) == "string") then
					if (first_arg == 0) then
						return self.debug_info_replacement(self.renv.debug.info, options_or_level);
					end;
					const call_frame: {[string]: any}? = self.Fiu.fetch_from_callstack(first_arg);
					if (not call_frame) then
						return debug.info(5000, options_or_level);
					end;
					const call_proto: {[string]: any} = call_frame.proto;
					const func: (...any) -> (...any) = self.Fiu.find_wrapped_by_unwrapped[call_frame.func] or call_frame.func;
					const func_proto: {[string]: any} = self.Fiu.get_function_proto(func);
					const results: {[number]: any} = {self.debug_info_replacement(func_proto.wrapped, options_or_level)};
					const pos: number? = string.find(options_or_level, "l");
					if (pos) then -- TODO: this is a mess
						if (call_proto.CClosure) then
							results[pos] = -1;
						elseif (call_frame.debugging and call_proto.instructionlineinfo) then
							results[pos] = (call_proto.instructionlineinfo[call_frame.debugging.pc] or -1);
						else
							results[pos] = -1;
						end;
					end;
					return table.unpack(results);
				end;
				return table.unpack(result);
			end;
		};	
		table = {
			freeze = function(...: any): ()
				const arg: any = ...;
				if (type(arg) ~= "table") then
					return table.freeze(...) :: never;
				elseif (rawget(self.readonly_tables, arg)) then
					return table.freeze(table.freeze({})) :: never;
				end;
				const arg_metatable: any? = self.getrawmetatable(arg);
				if (type(arg_metatable) == "table" and rawget(arg_metatable, "__metatable")) then
					return table.freeze(setmetatable({}, {__metatable = "xd"}));
				end;
				self.internal_set_read_only(arg, true);
				return;
			end,
			isfrozen = function(...: any): boolean
				const arg: any = ...;
				if (type(arg) ~= "table") then
					return table.isfrozen(...);
				end;
				return (self.readonly_tables[arg] ~= nil);
			end,
		};
	};
	for i: any, v: any in debug do
		if (replacements.debug[i]) then
			continue;
		end;
		replacements.debug[i] = v;
	end;
	for i: any, v: any in table do
		if (replacements.table[i]) then
			continue;
		end;
		replacements.table[i] = v;
	end;
	self.internal_set_read_only(replacements.debug, true);
	self.internal_set_read_only(replacements.table, true);
	for i: string, v: (...any) -> (...any) in replacements do
		self.push_global("roblox_env", i, v);
	end;
	self.debug_info_replacement = replacements.debug.info;
	return {};
end;
