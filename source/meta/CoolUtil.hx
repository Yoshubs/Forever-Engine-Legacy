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
	
	public static function coolReplace(string:String, sub:String, by:String):String
	{
		/*#if (!cs && !java)*/
		return string.split(sub).join(by);
		//#end
	}


	public static function formatSong(song:String):String
   	{
		var swag:String = coolReplace(song, '-', ' ');
		var splitSong:Array<String> = swag.split(' ');

		for (i in 0...splitSong.length)
		{
		    var firstLetter = splitSong[i].substring(0, 1);
		    var coolSong:String = coolReplace(splitSong[i], firstLetter, firstLetter.toUpperCase());
				var splitCoolSong:Array<String> = coolSong.split('');

				coolSong = Std.string(splitCoolSong[0]).toUpperCase();

				for (e in 0...splitCoolSong.length)
					coolSong += Std.string(splitCoolSong[e+1]).toLowerCase();

				coolSong = coolReplace(coolSong, 'null', '');

		    for (a in 0...splitSong.length)
		    {
			var stringSong:String = Std.string(splitSong[a+1]);
			var stringFirstLetter:String = stringSong.substring(0, 1);

			var splitStringSong = stringSong.split('');
			stringSong = Std.string(splitStringSong[0]).toUpperCase();

			for (l in 0...splitStringSong.length)
				stringSong += Std.string(splitStringSong[l+1]).toLowerCase();

			stringSong = coolReplace(stringSong, 'null', '');

			coolSong += ' $stringSong';
		    }

		    return coolSong.replace(' Null', '');
       		}

        	return swag;
	}
}
