package meta.data.font;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var textSpeed:Float = 0.06;
	public var randomSpeed:Bool = false; // When enabled, it'll change the speed of the text speed randomly between 80% and 180%

	public var textSize:Float;

	public var paused:Bool = false;

	// for menu shit
	public var targetY:Float = 0;
	public var disableX:Bool = false;
	public var controlGroupID:Int = 0;
	public var extensionJ:Int = 0;

	public var textInit:String;

	public var xTo = 100;

	public var isMenuItem:Bool = false;

	public var text:String = "";

	public var _finalText:String = "";
	public var _curText:String = "";

	public var widthOfWords:Float = FlxG.width;

	public var finishedLine:Bool = false;

	var yMulti:Float = 1;

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;
	var xPosResetted:Bool = false;
	var lastWasSpace:Bool = false;

	var splitWords:Array<String> = [];

	var isBold:Bool = false;

	public var soundChoices:Array<String> = ["GF_1", "GF_2", "GF_3", "GF_4",];
	public var beginPath:String = "assets/sounds/";
	public var soundChance:Int = 40;
	public var playSounds:Bool = true;
	public var lastPlayed:Int = 0;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false, typed:Bool = false, ?textSize:Float = 1)
	{
		super(x, y);

		this.text = text;
		isBold = bold;
		this.textSize = textSize;

		startText(text, typed);
	}

	public function startText(newText, typed)
	{
		yMulti = 1;
		finishedLine = false;
		xPosResetted = true;

		_finalText = newText;
		textInit = newText;
		this.text = newText;

		if (text != "")
		{
			if (typed)
			{
				startTypedText();
			}
			else
			{
				addText();
			}
		}
		else
		{
			if (swagTypingTimer != null)
			{
				destroyText();
				swagTypingTimer.cancel();
				swagTypingTimer.destroy();
			}
		}
	}

	function destroyText():Void
	{
		for (_sprite in _sprites.copy())
			_sprite.destroy();
		clear();
	}

	public var arrayLetters:Array<AlphaCharacter>;

	public function addText()
	{
		doSplitWords();

		arrayLetters = [];
		var xPos:Float = 0;
		for (character in splitWords)
		{
			if (character == " " || character == "-")
				lastWasSpace = true;

			var isNumber:Bool = AlphaCharacter.numbers.contains(character);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(character);

			if (AlphaCharacter.alphabet.indexOf(character.toLowerCase()) != -1 || AlphaCharacter.numbers.contains(character))
			{
				if (xPosResetted)
				{
					xPos = 0;
					xPosResetted = false;
				}
				else
				{
					if (lastSprite != null)
						xPos += lastSprite.width;
				}

				if (lastWasSpace)
				{
					xPos += 40;
					lastWasSpace = false;
				}

				var letter:AlphaCharacter = new AlphaCharacter(xPos, 0, textSize);

				if (isBold)
					letter.createBold(character);
				else
				{
					if (isNumber)
						letter.createNumber(character);
					else if (isSymbol)
						letter.createSymbol(character);
					else
						letter.createLetter(character);
				}

				arrayLetters.push(letter);
				add(letter);

				lastSprite = letter;
			}
		}
	}

	function doSplitWords():Void
		splitWords = _finalText.split("");

	public var personTalking:String = 'gf';

	public var swagTypingTimer:FlxTimer;

	public function startTypedText():Void
	{
		_finalText = text;
		doSplitWords();

		// Remove all the old garbage
		destroyText();

		var loopNum:Int = 0;

		var xPos:Float = 0;
		var curRow:Int = 0;

		// Forget any potential old timers
		if (swagTypingTimer != null)
			swagTypingTimer.destroy();

		// Create a new timer
		swagTypingTimer = new FlxTimer().start(textSpeed, function(tmr:FlxTimer)
		{
			if (_finalText.fastCodeAt(loopNum) == "\n".code)
			{
				yMulti += 1;
				xPosResetted = true;
				curRow += 1;
			}

			if (splitWords[loopNum] == " ")
			{
				lastWasSpace = true;
			}

			#if (haxe >= "4.0.0")
			var isNumber:Bool = AlphaCharacter.numbers.contains(splitWords[loopNum]);
			var isSymbol:Bool = AlphaCharacter.symbols.contains(splitWords[loopNum]);
			#else
			var isNumber:Bool = AlphaCharacter.numbers.indexOf(splitWords[loopNum]) != -1;
			var isSymbol:Bool = AlphaCharacter.symbols.indexOf(splitWords[loopNum]) != -1;
			#end

			if (AlphaCharacter.alphabet.indexOf(splitWords[loopNum].toLowerCase()) != -1 || isNumber || isSymbol)
			{
				if (lastSprite != null && !xPosResetted)
				{
					lastSprite.updateHitbox();
					xPos += lastSprite.width + 3;
				}
				else
				{
					xPos = 0;
					xPosResetted = false;
				}

				if (lastWasSpace)
				{
					xPos += 20;
					lastWasSpace = false;
				}
				var letter:AlphaCharacter = new AlphaCharacter(xPos, 55 * yMulti, textSize);
				letter.row = curRow;
				if (isBold)
				{
					letter.createBold(splitWords[loopNum]);
				}
				else
				{
					if (isNumber)
						letter.createNumber(splitWords[loopNum]);
					else if (isSymbol)
						letter.createSymbol(splitWords[loopNum]);
					else
						letter.createLetter(splitWords[loopNum]);

					letter.x += 90;
				}

				if (FlxG.random.bool(soundChance) || lastPlayed > 2)
				{
					if (playSounds)
					{
						lastPlayed = 0;

						var cur = FlxG.random.int(0, soundChoices.length - 1);
						var daSound:String = beginPath + soundChoices[cur] + "." + Paths.SOUND_EXT;

						FlxG.sound.play(daSound);
					}
				}
				else
					lastPlayed += 1;

				add(letter);

				lastSprite = letter;
			}

			loopNum += 1;

			if (randomSpeed)
				tmr.time = FlxG.random.float(0.8 * textSpeed, 1.8 * textSpeed);

			// I'm sorry for this implementation being a bit janky but the FlxTimer loops were not reliable for this
			// Hope you forgive me <3 <3 xoxo Sammu
			// i forgive u sammu :D
			if (loopNum >= splitWords.length)
			{
				finishedLine = true;
				tmr.destroy();
			}
		}, 0);
	}

	override function update(elapsed:Float)
	{
		if (isMenuItem)
		{
			var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), elapsed * 6);
			// lmao
			if (!disableX)
				x = FlxMath.lerp(x, (targetY * 20) + 90, elapsed * 6);
			else
				x = FlxMath.lerp(x, xTo, elapsed * 6);
		}

		if (text != textInit)
		{
			if (arrayLetters.length > 0)
				for (i in 0...arrayLetters.length)
					arrayLetters[i].destroy();
			//
			lastSprite = null;
			startText(text, false);
		}

		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	public static var numbers:String = "1234567890";

	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";

	public var row:Int = 0;

	private var textSize:Float = 1;

	public function new(x:Float, y:Float, ?textSize:Float = 1)
	{
		super(x, y);
		this.textSize = textSize;
		var tex = Paths.getSparrowAtlas('UI/default/base/alphabet');
		frames = tex;

		antialiasing = true;
	}

	public function createBold(letter:String)
	{
		if (AlphaCharacter.alphabet.indexOf(letter.toLowerCase()) != -1)
		{
			// or just load regular text
			animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
			animation.play(letter);
			scale.set(textSize, textSize);
			updateHitbox();
		}
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
		scale.set(textSize, textSize);
		updateHitbox();

		FlxG.log.add('the row' + row);

		y = (110 - height);
		y += row * 50;
	}

	public function createNumber(letter:String):Void
	{
		animation.addByPrefix(letter, letter, 24);
		animation.play(letter);

		updateHitbox();
	}

	public function createSymbol(letter:String)
	{
		switch (letter)
		{
			case '.':
				animation.addByPrefix(letter, 'period', 24);
				animation.play(letter);
				setGraphicSize(8, 8);
				y += 48;
			case "'":
				animation.addByPrefix(letter, 'apostraphie', 24);
				animation.play(letter);
				setGraphicSize(10, 10);
				y += 20;
			case "?":
				animation.addByPrefix(letter, 'question mark', 24);
				animation.play(letter);
				setGraphicSize(20, 40);
				y += 16;
			case "!":
				animation.addByPrefix(letter, 'exclamation point', 24);
				animation.play(letter);
				setGraphicSize(10, 40);
				y += 16;
			case ",":
				animation.addByPrefix(letter, 'comma', 24);
				animation.play(letter);
				setGraphicSize(10, 10);
				y += 48;
			default:
				animation.addByPrefix(letter, letter, 24);
				animation.play(letter);
		}

		updateHitbox();
	}
}
