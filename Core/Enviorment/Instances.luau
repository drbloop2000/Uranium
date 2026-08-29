--!nonstrict
--!native
return function(self: {[string]: any}): {[string]: any}
	const real_to_fake: any = setmetatable({}, {__mode = "v"});
	const fake_to_real: any = setmetatable({}, {__mode = "k"});
	const existing_methods: {[string]: {[string]: any}} = {};
	self.metatables = {};
	self.real_to_fake = real_to_fake;
	self.fake_to_real = fake_to_real;
	self.connections = setmetatable({}, {__mode = "k"});
	self.getconnection_objects = {};
	self.replicated_signals = {};
	self.signal_functions = {};
	self.get_callback_values = {};
	const disabled_connections: {[RBXScriptConnection]: boolean} = {};
	const write_only_properties: {[string]: {[string]: boolean}} = {
		["AdService"] = {
			["OnImmersiveBrandedAdDisclosureButtonActivated"] = true,
			["onDemandVideoPlayInUI"] = true,
		},
		["BindableFunction"] = {
			["OnInvoke"] = true,
		},
		["AdGui"] = {
			["OnAdEvent"] = true,
		},
		["GuiService"] = {
			["SendCoreUiNotification"] = true,
		},
		["MarketplaceService"] = {
			["ProcessReceipt"] = true,
		},
		["Plugin"] = {
			["ProcessAssetInsertionDrag"] = true,
			["ProcessAssetInsertionDrop"] = true,
		},
		["RemoteFunction"] = {
			["OnClientInvoke"] = true,
			["OnServerInvoke"] = true,
		},
		["DataModel"] = {
			["OnClose"] = true,
		},
		["SocialService"] = {
			["OnCallInviteInvoked"] = true,
		},
		["TextChannel"] = {
			["OnIncomingMessage"] = true,
			["ShouldDeliverCallback"] = true,
		},
		["TextChatService"] = {
			["OnBubbleAdded"] = true,
			["OnChatWindowAdded"] = true,
			["OnIncomingMessage"] = true,
		},
	}; -- sorry for not automating this, thought about automating this but then thought about how this VM can be used on the client or other situations may occur
	self.scriptables = {};
	const scriptable_hook = function(object: any, member_str: string): ()
		const object_classname_str: string = object.ClassName;
		const entry: {[string]: boolean}? = self.scriptables[object_classname_str];
		if (not entry) then
			return;
		elseif (type(entry[member_str]) == "boolean") then
			return error(`{member_str} is not a valid member of {object_classname_str} "{tostring(object)}"`);
		end;
		print(entry)
		return;
	end;
	const get_callback_member_hook = function(object: any, member_str: string, value: any): ()
		const object_class_str: string = object.ClassName;
		const props: {[string]: boolean}? = write_only_properties[object_class_str];
		if (not props or not props[member_str]) then
			return;
		end;
		const entry: {[string]: any} = (self.get_callback_values[object] or {});
		entry[member_str] = value;
		self.get_callback_values[object] = entry;
		return;
	end;
	const proxy_instance = function(entry: any, called_from_cloneref: boolean?): any
		const already_exists: any? = real_to_fake[entry];
		for i: RBXScriptSignal, v: any in self.replicated_signals do -- shit patch for signals, i've tried everything before hand
			if (typeof(i) == "RBXScriptSignal" and i == entry) then
				return v;
			end;
		end;
		if (already_exists and not called_from_cloneref) then
			return already_exists;
		end;
		const type_str: string = typeof(entry);
		const proxy: any = newproxy(true);
		if (type_str == "RBXScriptSignal") then
			self.replicated_signals[entry] = proxy;
		end;
		self.Fiu.insert_gc(proxy);
		const metatable: {[string]: any} = getmetatable(proxy);
		self.internal_set_read_only(metatable, true);
		fake_to_real[proxy] = entry;
		real_to_fake[entry] = proxy;
		self.metatables[proxy] = metatable;
		const exists_already: {[string]: any}? = existing_methods[type_str];
		if (exists_already) then
			for i: string, v: any in exists_already do
				metatable[i] = v;
			end;
			return proxy;
		end;
		const real_methods: {[string]: any} = {};
		const get_mt_result: ({[string]: any} | any)? = getmetatable(entry);
		if (type(get_mt_result) ~= "table") then
			real_methods.__metatable = get_mt_result;
		end;
		real_methods.__type = type_str;
		xpcall(function()
			return entry.__;
		end, function()
			real_methods.__index = debug.info(2, "f") :: (any, string) -> any;
		end);
		xpcall(function()
			entry.__ = error;
		end, function()
			real_methods.__newindex = debug.info(2, "f") :: (any, string, any) -> any;
		end);
		xpcall(function()
			return entry:_meow();
		end, function()
			real_methods.__namecall = debug.info(2, "f");
		end);
		xpcall(function()
			return entry.."hi";	
		end, function()
			real_methods.__concat = debug.info(2, "f");
		end);
		xpcall(function()
			return -entry;	
		end, function()
			real_methods.__unm = debug.info(2, "f");
		end);
		xpcall(function()
			return entry + 1;	
		end, function()
			real_methods.__add = debug.info(2, "f");
		end);
		xpcall(function()
			return entry - 1;	
		end, function()
			real_methods.__sub = debug.info(2, "f");
		end);
		xpcall(function()
			return entry * 1;	
		end, function()
			real_methods.__mul = debug.info(2, "f");
		end);
		xpcall(function()
			return entry / 1;	
		end, function()
			real_methods.__div = debug.info(2, "f");
		end);
		xpcall(function()
			return entry // 1;	
		end, function()
			real_methods.__idiv = debug.info(2, "f");
		end);
		xpcall(function()
			return entry % 1;	
		end, function()
			real_methods.__mod = debug.info(2, "f");
		end);
		xpcall(function()
			return entry <= 1;	
		end, function()
			real_methods.__le = debug.info(2, "f");
		end);
		xpcall(function()
			return entry < 1;	
		end, function()
			real_methods.__lt = debug.info(2, "f");
		end);
		xpcall(function()
			return #entry;
		end, function()
			real_methods.__len = debug.info(2, "f");
		end);
		xpcall(function()
			return entry();
		end, function()
			real_methods.__call = debug.info(2, "f");
		end);
		xpcall(function()
			for _: never, _: never in entry do

			end
		end, function()
			real_methods.__iter = debug.info(2, "f");
		end);
		real_methods.__tostring = self.mk_closure(function(...: any): string
			local self: any = ...;
			local entry: any = (fake_to_real[self] or self);
			return tostring(entry);
		end);
		const fake_methods: {[string]: any} = {};
		for i: string, v: any in real_methods do
			if (type(v) == "function") then
				if (i == "__namecall") then -- custom namecall handler, since it is actually impossible to set the namecall method in pure luau
					fake_methods[i] = self.mk_closure(function(...: any): ...any
						const args: {[any]: any} = table.pack(self.decode_arugments(...));
						const obj: any = args[1];
						const namecall_method_str: string = self.getnamecallmethod();
						const index: any = obj[namecall_method_str];
						const results: {[any]: any} = table.pack(index(table.unpack(args, 1, args.n)));
						if (typeof(obj) == "RBXScriptSignal" and namecall_method_str == "Connect" or namecall_method_str == "connect" and debug.info(index, "s") == "[C]" and debug.info(index, "n") == "Connect") then
							const func = rawget(args, 2) :: (...any) -> (...any);
							const connection_object: RBXScriptConnection = results[1];
							const entry: {[string]: any} = {
								Enabled = true;
								ForeignState = true;
								LuaConnection = true;
								Function = func;
								Thread = coroutine.running() --TODO
							};
							self.getconnection_objects[entry] = true;
							const __index: {[string]: (...any) -> (...any)} = {
								Fire = self.mk_closure(function(...: any): any
									const _self: {[string]: any} = ...;
									if (type(_self) ~= "table" or not rawget(self.getconnection_objects, _self)) then
										return error("Expected ':' not '.' calling member function Fire", 2);
									end;
									if (not rawget(_self, "Enabled") or not rawget(_self, "Function") or type(rawget(_self, "Function")) ~= "function") then
										return error("Illegal connection", 2);
									end;
									return _self.Function(select(2, ...));
								end, {debugname = "Fire"}),
								Defer = self.mk_closure(function(...: any): any
									const _self: {[string]: any} = ...;
									if (type(_self) ~= "table" or not rawget(self.getconnection_objects, _self)) then
										return error("Expected ':' not '.' calling member function Fire", 2);
									end;
									if (not rawget(_self, "Enabled") or not rawget(_self, "Function") or type(rawget(_self, "Function")) ~= "function") then
										return error("Illegal connection", 2);
									end;
									return _self.Function(select(2, ...));
								end, {debugname = "Defer"}),
								Disconnect = self.mk_closure(function(...: any): ()
									const _self: {[string]: any} = ...;
									if (type(_self) ~= "table" or not rawget(self.getconnection_objects, _self)) then
										return error("Expected ':' not '.' calling member function Disconnect", 2);
									end;
									connection_object:Disconnect();
									_self.Enabled = false;
									return;
								end, {debugname = "Disconnect"}),
								Enable = self.mk_closure(function(...: any): ()
									const _self: {[string]: any} = ...;
									if (type(_self) ~= "table" or not rawget(self.getconnection_objects, _self)) then
										return error("Expected ':' not '.' calling member function Disable", 2);
									end;
									disabled_connections[connection_object] = nil;
									return;
								end);
								Disable = self.mk_closure(function(...: any): ()
									const _self: {[string]: any} = ...;
									if (type(_self) ~= "table" or not rawget(self.getconnection_objects, _self)) then
										return error("Expected ':' not '.' calling member function Disable", 2);
									end;
									disabled_connections[connection_object] = true;
									_self.Enabled = false;
									return;
								end, {debugname = "Disable"}),
							};
							const metatable: {[string]: any} = {
								__index = __index;
								__tostring = self.mk_closure(function(...: any): string
									return "SignalProxy";
								end, {debugname = ""}),
								__metatable = "The metatable is locked";
							};
							self.internal_set_read_only(__index, true);
							self.internal_set_read_only(metatable, true);
							self.metatables[entry] = metatable;
							setmetatable(entry, metatable);
							self.connections[obj] = (self.connections[obj] or {});
							table.insert(self.connections[obj], entry);
							table.insert(self.signal_functions, func);
						end;
						const encoded: {[any]: any} = table.pack(self.encode_arugments(table.unpack(results, 1, results.n)));
						return table.unpack(encoded, 1, encoded.n);
					end);
					continue;
				end;
				fake_methods[i] = self.mk_closure(function(...: any): ...any
					const args: {[any]: any} = table.pack(self.decode_arugments(...));
					do
						if (i == "__index") then
							local object: any = rawget(args, 1);
							local index_by_str: string? = rawget(args, 2);
							const index_type_str: string = type(index_by_str);
							const object_typeof_str: string = typeof(object);
							if (index_type_str == "string" and object_typeof_str == "Instance") then
								scriptable_hook(object, index_type_str);
							end;
							if (index_type_str == "string" and object_typeof_str == "RBXScriptConnection" and rawget(disabled_connections, object) and index_by_str == "connected" or index_by_str == "Connected") then
								return true;
							end;
							object = nil :: never;
							index_by_str = nil :: never;
						end;
					end;
					const results: {[any]: any} = table.pack(v(table.unpack(args, 1, args.n)));
					do
						if (i == "__newindex") then
							local obj: any? = rawget(args, 1);
							local method_str: string? = rawget(args, 2);
							local value: any? = rawget(args, 3);
							if (typeof(obj) == "Instance" and type(method_str) == "string") then
								scriptable_hook(obj, method_str);
								get_callback_member_hook(obj, method_str, value);
							end;
							obj = nil :: never;
							value = nil :: never;
							method_str = nil :: never;
						end;
					end;
					const encoded: {[any]: any} = table.pack(self.encode_arugments(table.unpack(results, 1, results.n)));
					return table.unpack(encoded, 1, encoded.n);
				end);
			else
				fake_methods[i] = v;
			end;
		end;
		for i: any, v: any in fake_methods do
			metatable[i] = v;
		end;
		existing_methods[type_str] = fake_methods;
		return proxy;
	end;
	return {proxy = proxy_instance};
end;