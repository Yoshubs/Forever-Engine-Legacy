package base;

#if LUA_EXTENSION
import llua.*;
import llua.Lua.Lua_helper;

class LLua
{
    public var lua:State = LuaL.newstate();

    public function new(script:String)
    {
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);
		LuaL.dostring(lua, "
            os.execute, os.getenv, os.rename, os.remove, os.tmpname = nil, nil, nil, nil, nil
            io, load, loadfile, loadstring, dofile = nil, nil, nil, nil, nil
            require, module, package = nil, nil, nil
            setfenv, getfenv = nil, nil
            newproxy = nil
            gcinfo = nil
            debug = nil
            jit = nil
        ");

		var result:Null<Int> = LuaL.dofile(lua, script);
		var resultStr:String = Lua.tostring(lua, result);

		if (resultStr != null && result != 0)
			return;

        Lua_helper.add_callback(lua, 'trace', function(v:Dynamic)
            trace(v));

        call('onCreate', []);
    }

	public function call(evt:String, args:Array<Dynamic>):Null<Int>
	{
		if (isNull())
			return 0;

		Lua.getglobal(lua, evt);

		for (argument in args)
			Convert.toLua(lua, argument);

		var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);

		if (result != null && isAllowed(lua, result))
		{
			if (Lua.type(lua, -1) == Lua.LUA_TSTRING)
			{
				var error:String = Lua.tostring(lua, -1);
				Lua.pop(lua, 1);

				if (error == 'attempt to call a nil value')
					return 0;
			}

			var conv:Dynamic = Convert.fromLua(lua, result);
			Lua.pop(lua, 1);
			return conv;
		}

		return 0;
	}

	public function set(variable:String, data:Dynamic):Void
	{
		if (isNull())
			return;

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	public function isAllowed(lua:State, result:Null<Int>):Null<Bool>
	{
		switch (Lua.type(lua, result))
		{
			case Lua.LUA_TNIL | Lua.LUA_TBOOLEAN | Lua.LUA_TNUMBER | Lua.LUA_TSTRING | Lua.LUA_TTABLE:
				return true;
		}

		return false;
	}

    public function destroy():Void
    {
        if (isNull())
            return;

        Lua.close(lua);
        lua = null;
    }

    public function isNull():Bool
    {
        return lua == null;
    }
}
#end