--!nocheck
--!native
const luau_vm = require(script.Fiu);
const luau_complier = require(script.Compiler);
const vm_execute = function(source: string, env: {[string]: any}, settings: {[string]: any}): () -> ()
	const bytecode_str: string = luau_complier.luau_compile(source);
	return luau_vm.luau_load(bytecode_str, env, settings);
end;
return function(self: {[string]: any}): {[string]: any}
	luau_vm.set_self(self);
	return {
		Fiu = luau_vm;
		internal_execute = vm_execute;
	};
end;