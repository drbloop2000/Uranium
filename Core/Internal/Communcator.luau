--!nonstrict
--!native
return function(self: {[string]: any}): {[string]: any}
	self.readonly_tables = {} :: {[{[any]: any}]: boolean};
	self.current_namecall_method = "";
	self.setnamecall_method_hook = nil :: string?;
	self.newccloured = {};
	const replicated_types: {[number]: string} = {
		"Vector3",
		"CFrame",
		"Instance",
		"Enums",
		"Ray",
		"Vector2",
		"UDim",
		"UDim2",
		"BrickColor",
		"Color3",
		"NumberRange",
		"PhysicalProperties",
		"Axes",
		"TweenInfo",
		"NumberSequence",
		"NumberSequenceKeypoint",
		"ColorSequence",
		"ColorSequenceKeypoint",
		"Rect",
		"Faces",
		"PathWaypoint",
		"RaycastParams",
		"RBXScriptSignal"
	};
	const cached_closures: {[(...any) -> (...any)]: (...any) -> (...any)} = {};
	const wrapped_cached_closures: {[(...any) -> (...any)]: (...any) -> (...any)} = {};
	return {
		mk_closure = function(func: (...any) -> (...any), proto_settings: {[string]: any}?): (...any) -> (...any)
			const already_wrapped: (...any) -> (...any)? = cached_closures[func];
			if (already_wrapped) then
				return already_wrapped;
			end;
			const wrapped: (...any) -> (...any) = self.Fiu.register_closure(func, getfenv(xpcall), self.luau_settings, proto_settings);
			self.newccloured[wrapped] = wrapped;
			wrapped_cached_closures[func] = wrapped;
			return wrapped;
		end,
		namecall_handler = function(namecall_method_str: string, obj: any, ...: any): (boolean, ...any)
			const arugments: {[number]: any} = {...};
			const raw_metatable: {[string]: any}? = self.getrawmetatable(obj);
			if (raw_metatable and type(raw_metatable) == "table" and rawget(raw_metatable, "__namecall")) then
				const __namecall: (...any) -> (...any)? = rawget(raw_metatable, "__namecall");
				if (type(__namecall) ~= "function") then
					return false;
				end;
				namecall_method_str = (self.setnamecall_method_hook or namecall_method_str);
				self.setnamecall_method_hook = nil :: never;
				self.current_namecall_method = namecall_method_str;
				const loc: number = self.Fiu.push_call_stack({
					what = "C";
					source = "[C]";
					currentline = -1;
					name = "";
					isvararg = true;
					func = __namecall;
				});
				const result: any = __namecall(obj, table.unpack(arugments));
				self.Fiu.pop_call_stack(loc);
				return true, result;
			end;
			return false;
		end,
		write_luau_settings = function(): ()
			const settings_table: {[string]: any} = self.Fiu.luau_newsettings();
			self.luau_settings = settings_table;
			self.luau_settings.useNativeNamecall = true;
			self.luau_settings.namecallHandler = self.namecall_handler;
			return;
		end,
		encode_arugments = function(...: any): ...any
			const arguments: {[number]: any} = {...};
			for i: number, v: any in arguments do
				const type_str: string = typeof(v)
				if (table.find(replicated_types, type_str)) then
					rawset(arguments, i, self.proxy(v));
				elseif (type_str == "function" and debug.info(v, "s") == "[C]") then
					local closure: (...any) -> (...any)? = cached_closures[v];
					if (not closure) then
						closure = self.mk_closure(function(...: any): ...any
							const args: {[any]: any} = table.pack(self.decode_arugments(...));
							const results: {[any]: any} = table.pack(v(table.unpack(args, 1, args.n)));
							const encoded: {[any]: any} = table.pack(self.encode_arugments(table.unpack(results, 1, results.n)));
							return table.unpack(encoded, 1, encoded.n);
						end, {debugname = debug.info(v, "n")});
						cached_closures[v] = closure;
					end;
					rawset(arguments, i, closure);
				elseif (type_str == "table") then
					if (rawget(self.tostring_fix, v)) then
						continue;
					end;
					const arg: {[any]: any} = {};
					for i: any, v: any in next, v do -- next so we dont fall for a metatable trap
						local a: {[number]: any} = {(self.encode_arugments(i))};
						local b: {[number]: any} = {(self.encode_arugments(v))};
						arg[a[1]] = b[1];
					end;
					rawset(arguments, i, arg);
				end;
			end;
			return table.unpack(arguments);
		end,
		decode_arugments = function(...: any): ...any
			const arguments: {[number]: any} = {...};
			for i: number, v: any in arguments do
				if (self.fake_to_real[v]) then
					rawset(arguments, i, self.fake_to_real[v]);
				elseif (type(v) == "table") then
					const arg: {[any]: any} = {};
					for i: any, v: any in next, v do -- next so we dont fall for a metatable trap
						local a: {[number]: any} = {(self.decode_arugments(i))};
						local b: {[number]: any} = {(self.decode_arugments(v))};
						arg[a[1]] = b[1];
					end;
					rawset(arguments, i, arg);
				end;
			end;
			return table.unpack(arguments);
		end,
		execute_code = function(code_str: string): ()
			local func: () -> () = self.internal_execute(code_str, self.genv, self.luau_settings, false);
			return func();			
		end,
		internal_set_read_only = function(tbl: {[any]: any}, state: boolean): ()
			self.readonly_tables[tbl] = (state and true or nil);
			return;
		end,
	};
end;
