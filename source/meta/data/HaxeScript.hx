package meta.data;

import hscript.*;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

/**
 * Main class for haxe scripts.
 * Create a `new` script then set the variables.
 * Executing without setting variables will not do anything.
 */
class HaxeScript
{
    var interp:Interp;
    var script:String = "";

    /**
     * Creates a haxe script. Not ready to be executed yet.
     * @param scriptPath The script path, it will automatically get the path's contents.
     */
    public inline function new(scriptPath:String = "")
    {
        if (scriptPath == "" || !#if sys FileSystem.exists(scriptPath) #else Assets.exists(scriptPath, TEXT) #end)
            return;

        interp = new Interp();

        script = #if sys File.getContent(scriptPath) #else Assets.getText(scriptPath) #end;
    }

    /**
	 * Executes `this` script.
	 * If `this` script does not have any variables set, executing won't do anything.
     */
    public function execute()
    {
		interp.execute(new Parser().parseString(script));
    }
    
    /**
	 * Sets a variable to anything. If `key` already exists it will be replaced.
     * @param key Variable name.
     * @param obj The dynamic to set.  
     * @return Returns always true.
     */
    public function set(key:String, obj:Dynamic):Bool
    {
        interp.variables.set(key, obj);
        return true;
    }

    /**
	 * Gets a variable by name. If a variable named as `key` does not exists return is null.
     * @param key Variable name.
     * @return The variable got by name.
     */
    public function get(key:String):Dynamic
        return interp.variables.get(key);
}