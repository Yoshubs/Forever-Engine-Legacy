package meta.data;

import hscript.*;
import openfl.Assets;
import openfl.events.DataEvent;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class HaxeScript
{
    var interp:Interp;
    var script:String = "";

    public inline function new(scriptPath:String = "")
    {
        if (scriptPath == "" || !#if sys FileSystem.exists(scriptPath) #else Assets.exists(scriptPath, TEXT) #end)
            return;

        interp = new Interp();

        script = #if sys File.getContent(scriptPath) #else Assets.getText(scriptPath) #end;
    }

    public function execute()
    {
		interp.execute(new Parser().parseString(script));
    }

    public function call(key:String, arguments:Array<Dynamic>)
    {
        if (interp.variables.exists(key))
            return;

        var func:Dynamic = interp.variables.get(key);
        Reflect.callMethod(interp, func, arguments);
    }

    public function set(key:String, obj:Dynamic):Bool
    {
        interp.variables.set(key, obj);
        return true;
    }

    public function get(key:String):Dynamic
        return interp.variables.get(key);
}