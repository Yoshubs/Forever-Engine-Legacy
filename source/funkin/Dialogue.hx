package funkin;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import funkin.Alphabet.AlphaCharacter;

using StringTools;

class Dialogue extends FlxSpriteGroup
{
	public var textSpeed:Float = 0.05;
	public var textSize:Float = 1;
	public var textPosition:Int = 0;

	private var _buildText:String;
	private var _finalText:String;

	private var splitWords:Array<String> = [];

	private var dialogueMaxSize:FlxPoint;

	public function new(x:Float, y:Float, text:String = "", width:Int, height:Int)
	{
		super(x, y);
		_finalText = text;
		dialogueMaxSize = new FlxPoint(width, height);
	}

	public function buildText():Void
	{
		// Reset values on the hypothetical that the text was started over
		textPosition = 0;

		var curRow = 0;
		var loopNum = 0;
		var lastWasSpace = false;

		// Clear out all the old sprites if there are any
		if (_sprites.length > 0)
		{
			for (_sprite in _sprites)
			{
				_sprite.destroy();
			}
			clear();
		}

		// Split all of the text into an array
		splitWords = _finalText.split("");

		new FlxTimer().start(textSpeed, function(timer:FlxTimer)
		{
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				curRow++;
			}

			if (splitWords[curRow] == " ")
			{
				lastWasSpace = true;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[curRow]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[curRow]);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[curRow]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[curRow]) != -1;
			#end
		});
	}
}
