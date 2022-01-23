package meta;

import openfl.Lib;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

/**
	This is the infoHud class that is derrived from the default FPS class from haxeflixel.
	It displays debug information, like frames per second, and active states.
	Hopefully I can also add memory usage in here (reminder to remove later if I don't know how to)
**/
class InfoHud extends TextField
{
	// set up variables
	public static var currentFPS:Int = 0;
	public static var memoryUsage:Float = 0;

	// display info
	public static var displayFps = true;
	public static var displayMemory = true;
	public static var displayExtra = true;

	// I also like to set them up so that you can call on them later since they're static
	// anyways heres some other stuff I didn't write most of this so its just standard fps stuff
	private var display:Bool = false;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000, hudDisplay:Bool = false)
	{
		super();

		display = hudDisplay;

		this.x = x;
		this.y = y;

		selectable = false;
		mouseEnabled = false;
		// might as well have made it comic sans
		defaultTextFormat = new TextFormat(Paths.font("pixel.otf"), 10, color);
		// set text area for the time being
		width = Main.gameWidth;
		height = Main.gameHeight;
	}

	// Event Handlers
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		// u h
		text = "";
		currentFPS = Std.int(Lib.current.stage.frameRate);
		if (displayFps)
			text += "FPS: " + currentFPS + "\n";

		if (displayExtra)
			text += "State: " + Main.mainClassState + "\n";

		memoryUsage = Math.round(System.totalMemory / (1e+6)); // division to convert the memory usage in megabytes
		if (displayMemory)
			text += "Memory: " + memoryUsage + " mb";
		// mb stands for my bad
	}

	public static function updateDisplayInfo(shouldDisplayFps:Bool, shouldDisplayExtra:Bool, shouldDisplayMemory:Bool)
	{
		displayFps = shouldDisplayFps;
		displayExtra = shouldDisplayExtra;
		displayMemory = shouldDisplayMemory;
	}
}
