package meta;

import lime.utils.Assets;
import meta.state.PlayState;

using StringTools;

#if !html5
import sys.FileSystem;
#end

class CoolUtil
{
	// tymgus45
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];
	public static var difficultyLength = difficultyArray.length;

	public static function difficultyFromNumber(number:Int):String
	{
		return difficultyArray[number];
	}

	public static function dashToSpace(string:String):String
	{
		return string.replace("-", " ");
	}

	public static function spaceToDash(string:String):String
	{
		return string.replace(" ", "-");
	}

	public static function swapSpaceDash(string:String):String
	{
		return StringTools.contains(string, '-') ? dashToSpace(string) : spaceToDash(string);
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function getOffsetsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);

		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
			swagOffsets.push(i.split(' '));

		return swagOffsets;
	}

	public static function returnAssetsLibrary(library:String, ?subDir:String = 'assets/images'):Array<String>
	{
		//
		var libraryArray:Array<String> = [];
		#if !html5
		var unfilteredLibrary = FileSystem.readDirectory('$subDir/$library');

		for (folder in unfilteredLibrary)
		{
			if (!folder.contains('.'))
				libraryArray.push(folder);
		}
		trace(libraryArray);
		#end

		return libraryArray;
	}

	public static function getAnimsFromTxt(path:String):Array<Array<String>>
	{
		var fullText:String = Assets.getText(path);

		var firstArray:Array<String> = fullText.split('\n');
		var swagOffsets:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagOffsets.push(i.split('--'));
		}

		return swagOffsets;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
	
	public static function formatSong(song:String):String
   	{
		var swag:String = song.replace('-', ' ').toLowerCase();
		var splitSong:Array<String> = swag.split(' ');

		for (i in 0...splitSong.length)
		{
		    var firstLetter = splitSong[i].substring(0, splitSong[i].length - (splitSong[i].length - 1));
		    var coolSong:String = splitSong[i].replace(firstLetter, firstLetter.toUpperCase());

		    for (a in 0...splitSong.length)
		    {
			var stringSong:String = Std.string(splitSong[a+1]);
			var stringFirstLetter:String = stringSong.substring(0, stringSong.length - (stringSong.length - 1));
			coolSong += ' ${stringSong.toLowerCase().replace(stringFirstLetter.toLowerCase(), stringFirstLetter.toUpperCase())}';
		    }

		    return coolSong.replace(' Null', '');
		}

        	return swag;
	}
}
