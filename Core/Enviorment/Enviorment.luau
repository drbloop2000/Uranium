--!nonstrict
--!native
--!nolint LocalShadow
return function(self: {[string]: any}): {[string]: any}	
	return {
		build_instances = function(): ()
			const fake_game = self.proxy(game) :: any;
			const fake_workspace = self.proxy(workspace) :: any;
			self.renv.game = fake_game;
			self.renv.Game = fake_game;
			self.renv.workspace = fake_workspace;
			self.renv.Workspace = fake_workspace;
			return;
		end,
		build_env = function(): ()
			const real_enviorment: {[string]: any} = getfenv(xpcall);
			const roblox_enviorment: {[string]: any} = {_G = {}, shared = {}};
			const el_globals: {[string]: number} = {["DockWidgetPluginGuiInfo"] = 1, ["warn"] = 2, ["tostring"] = 3, ["gcinfo"] = 4, ["os"] = 5, ["tick"] = 6, ["task"] = 7, ["getfenv"] = 8, ["debug"] = 9, ["NumberSequence"] = 10, ["assert"] = 11, ["rawlen"] = 12, ["tonumber"] = 13, ["CommandData"] = 14, ["Color3"] = 15, ["Enum"] = 16, ["Delay"] = 17, ["OverlapParams"] = 18, ["Path2DControlPoint"] = 19, ["SecurityCapabilities"] = 20, ["AdReward"] = 21, ["vector"] = 22, ["ypcall"] = 23, ["coroutine"] = 24, ["DateTime"] = 25, ["NumberRange"] = 26, ["buffer"] = 27, ["PhysicalProperties"] = 28, ["elapsedTime"] = 29, ["version"] = 30, ["PluginManager"] = 31, ["Stats"] = 32, ["stats"] = 33, ["Ray"] = 34, ["NumberSequenceKeypoint"] = 35, ["Version"] = 36, ["Vector2"] = 37, ["UserSettings"] = 38, ["Game"] = 39, ["Content"] = 40, ["spawn"] = 41, ["settings"] = 42, ["string"] = 43, ["xpcall"] = 44, ["loadstring"] = 45, ["printidentity"] = 46, ["FloatCurveKey"] = 47, ["print"] = 48, ["delay"] = 49, ["Wait"] = 50, ["wait"] = 51, ["RaycastParams"] = 52, ["unpack"] = 53, ["TweenInfo"] = 54, ["ElapsedTime"] = 55, ["require"] = 56, ["Vector3"] = 57, ["time"] = 58, ["Vector3int16"] = 59, ["setmetatable"] = 60, ["next"] = 61, ["Workspace"] = 62, ["UDim2"] = 63, ["RotationCurveKey"] = 64, ["ipairs"] = 65, ["Font"] = 66, ["CatalogSearchParams"] = 67, ["rawequal"] = 68, ["Region3int16"] = 69, ["collectgarbage"] = 70, ["game"] = 71, ["getmetatable"] = 72, ["Spawn"] = 73, ["PluginDrag"] = 74, ["Region3"] = 75, ["utf8"] = 76, ["Random"] = 77, ["CellId"] = 78, ["rawset"] = 79, ["PathWaypoint"] = 80, ["CFrame"] = 81, ["_VERSION"] = 82, ["UDim"] = 83, ["workspace"] = 84, ["table"] = 85, ["math"] = 86, ["bit32"] = 87, ["pcall"] = 88, ["pairs"] = 89, ["ColorSequenceKeypoint"] = 90, ["type"] = 91, ["typeof"] = 92, ["SharedTable"] = 93, ["select"] = 94, ["Vector2int16"] = 95, ["ColorSequence"] = 96, ["rawget"] = 97, ["newproxy"] = 98, ["Rect"] = 99, ["BrickColor"] = 100, ["setfenv"] = 101, ["Instance"] = 102, ["Axes"] = 103, ["error"] = 104, ["Faces"] = 105};
			for i: string, v: number in el_globals do
				const res: any = real_enviorment[i];
				const type_str: string = type(res);
				if (type_str == "function") then
					const debug_name_str: string = debug.info(res, "n");
					self.setstackhidden(res, true);
					roblox_enviorment[i] = self.mk_closure(function(...: any): ...any
						const args: {[any]: any} = table.pack(self.decode_arugments(...));
						const results: {[any]: any} = table.pack(res(table.unpack(args, 1, args.n)));
						const encoded: {[any]: any} = table.pack(self.encode_arugments(table.unpack(results, 1, results.n)));
						return table.unpack(encoded, 1, encoded.n);
					end, {debugname = debug_name_str});
					continue;
				elseif (type_str == "table") then
					const entry: {[any]: any} = {};
					for i: string, v: any in res do
						const type_str: string = type(v);
						if (type_str == "function") then
							self.setstackhidden(v, true);
							const debug_name_str: string = debug.info(v, "n");
							entry[i] = self.mk_closure(function(...: any)
								const args: {[any]: any} = table.pack(self.decode_arugments(...));
								const results: {[any]: any} = table.pack(v(table.unpack(args, 1, args.n)));
								const encoded: {[any]: any} = table.pack(self.encode_arugments(table.unpack(results, 1, results.n)));
								return table.unpack(encoded, 1, encoded.n);
							end, {debugname = debug_name_str});
							continue;
						end;
						entry[i] = v;
					end;
					roblox_enviorment[i] = entry;
					self.internal_set_read_only(entry, true);
					continue;
				else
					roblox_enviorment[i] = res;
				end;
			end;
			self.genv.shared = shared;
			self.genv._G = _G;
			for i: string, v: any in roblox_enviorment do
				rawset(self.renv, i, v);
			end;
			setmetatable(self.genv, {__index = self.renv; __metatable = self.metatable_locked_str});
			self.build_instances();
			return;
		end,
	};
end;