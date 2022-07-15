package base;

import base.hscript.*;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

/**
 * A simple class for haxe scripts.
 * Includes simple tasks such as setting getting variables.
 * Needs set values before executing.
 */
class HaxeScript
{
    /**
     * The variable map and executer. 
     * If you destroy `this` script interp will be null and you won't be able to mess with this ever again.
     */
    public var interp(default, set):Interp;

    /**
     * The script to execute. Gets set automatically if you create a `new` HaxeScript.
     * Similar to `interp` if you destroy `this` script you won't be able to mess with this ever again.
     */
    public var script(default, set):String;

    /**
     * This variable tells if `this` script is active or not.
     * Set this to false if you do not want your script to be able to get executed!
     */
    public var isActive(default, set):Bool = true;
    
    /**
     * This variable tells if `this` script is destroyed or not.
     * Will be false if you `destroy()` this script.
     * Also this is a variable you would not wanna mess with, since it can break the script.
     */
    public var isDestroyable(default, set):Bool = true;

    /**
     * Creates a haxe script. Not ready to be executed yet.
     * @param scriptPath The script path, it will automatically get the path's contents.
     */
    public inline function new(?scriptPath:String = "")
    {
        #if !sys
        return;
        #else
        if (scriptPath == "")
            return;
        #end

        interp = new Interp();

        script = File.getContent(scriptPath);
    }

    /**
	 * Executes `this` script once.
	 * If `this` script does not have any variables set, executing won't do anything.
     */
    public inline function execute():Void
    {
        #if !sys
        return;
        #else
        if (interp == null || !isActive)
            return;
        #end

		interp.execute(new Parser().parseString(script));
    }
    
    /**
	 * Sets a variable to `this` script. If `key` already exists it will be replaced.
     * If you want to set a variable to multiple scripts check the `setOnScripts` function.
     * @param key Variable name.
     * @param obj The object to set.  
     * @return If `this` script is destroyed or not active return is an error string otherwise return is true.
     */
    public inline function set(key:String, obj:Dynamic, ?onComplete:Void -> Void):Void
    {
        #if !sys
        return;
        #else
        if (interp == null || !isActive)
        {
            #if debug
            if (interp == null) 
                trace("This script is destroyed and unusable!");
            else 
                trace("This script is not active!");
            #end

            return;
        }
        #end

        interp.variables.set(key, obj);

        if (onComplete != null)
            onComplete();
    }

    /**
     * Unsets a variable from `this` script. If a variable named `key` doesn't exist, unsetting won't do anything.
     * @param key Variable name to unset.
     */
    public inline function unset(key:String):Void
    {
        #if !sys
        return;
        #else
        if (interp == null || !isActive || key == null || !interp.variables.exists(key))
            return;
        #end

        interp.variables.remove(key);
    }

    /**
	 * Gets a variable by name. If a variable named as `key` does not exists return is null.
     * @param key Variable name.
     * @return The variable got by name. If `this` script is destroyed or inactive return is an error string.
     */
    public inline function get(key:String):Dynamic
    {
        #if !sys
        return null;
        #else
        if (interp == null || !isActive)
        {
            if (interp == null) 
                trace("This script is destroyed and unusable!");
            else 
                trace("This script is not active!");

            return null;
        }
        #end

        return interp.variables.get(key);
    }

    /**
     * `WARNING:` This is a dangerous function since it makes `this` script completely unusable.
     * If you wanna get rid of `this` script COMPLETELY, call this function.
     * Else if you want to disable `this` script temporarily just set `isActive` to false!
     */
    public inline function destroy():Void
    {
        #if !sys
        return;
        #end

        DestroyScript.destroy(this);
    }

    /**
     * Clears all of the keys assigned to `this` script.
     */
    public inline function clear():Void
    {
        #if !sys
        return;
        #end

        for (i in interp.variables.keys())
        {
            interp.variables.remove(i);
        }
    }

    /**
     * Merges all the variables from `scriptToMerge` to `this` script.
     * @param scriptToMerge The script to merge. 
     * @return HaxeScript merged together.
     */
    public inline function merge(scriptToMerge:HaxeScript):HaxeScript
    {
        var interpToMerge:Interp = scriptToMerge.interp;

        for (i in interpToMerge.variables.keys())
        {
            set(i, interpToMerge.variables.get(i));
        }

        return this;
    }

    /**
     * Sets a variable in multiple scripts.
     * @param scriptArray The scripts you want to set the variable to.
     * @param key Variable name.
     * @param obj The object to set to `key`.
     */
    public static inline function setOnScripts(scriptArray:Array<HaxeScript>, key:String, obj:Dynamic):Void
    {
        #if !sys
        return;
        #end

        for (script in scriptArray)
            script.set(key, obj);
    }

    inline function set_isActive(active:Bool):Null<Bool>
    {
        isActive = active;
        return isActive;
    }

    inline function set_isDestroyable(destroyable:Bool):Null<Bool>
    {
        isDestroyable = destroyable;
        
        if (!isDestroyable)
            isActive = false;
        
        return isDestroyable;
    }

    inline function set_interp(value:Interp):Interp
    {
        if (interp == null && value != null && !isDestroyable)
            return null;

        interp = value;
        return interp;
    }

    inline function set_script(value:String):String
    {
        if (script == "" && value != "" && !isDestroyable)
            return "";

        script = value;
        return script;
    }
}

class DestroyScript
{
    public static function destroy(hscript:HaxeScript)
    {
        hscript.isDestroyable = false;
        hscript.interp = null;
        hscript.script = "";
    }

    /**
     * Destroys multiple scripts from an array. Remember that you won't be able to use these scripts again!
     * @param scriptArray Scripts you want to destroy as an array.
     */
    public static function destroyMultiple(scriptArray:Array<HaxeScript>)
    {
        for (i in scriptArray)
            i.destroy();
    }
}