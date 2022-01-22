package meta.data;

import haxe.Json;
import sys.io.File;

using StringTools;

typedef SwagWeek =
{
	var name:String;
	var directory:String;

	var songs:Array<String>;
	var characters:Array<String>;
	var color:Array<Int>;
	var unlocked:Bool;
	var hideWeek:Bool;
	var hideOnFreeplay:Array<String>;
};

// enjoyable weeks unharcode
class Week
{
	public var name:String = 'Test Week';
	public var directory:String = '';

	public var songs:Array<String> = ['Test'];
	public var characters:Array<String> = ['bf'];
	public var color:Array<Int> = [255, 255, 255];
	public var unlocked:Bool = true;
	public var hideWeek:Bool = false;
	public var hideOnFreeplay:Array<String> = [];

	// faster way to init shit????
	public function new(weekFile:SwagWeek)
	{
		this.name = weekFile.name;
		this.directory = weekFile.directory;
		this.songs = weekFile.songs;
		this.characters = weekFile.characters;
		this.color = weekFile.color;
		this.unlocked = weekFile.unlocked;
		this.hideWeek = weekFile.hideWeek;
		this.hideOnFreeplay = weekFile.hideOnFreeplay;
	}

	public static function loadFromJson(path:String):SwagWeek
	{
		var rawJson:String = CoolUtil.formatJson(File.getContent(path).trim());
		return cast Json.parse(rawJson);
	}
}
