package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;

typedef PortraitDataDef =
{
	var name:String;
	var expressions:Array<String>;
	var position:Null<Dynamic>;
	var offset:Null<Array<Int>>;
	var scale:Null<Int>;
	var antialiasing:Null<Bool>;
	var flipX:Null<Bool>;
	var loop:Null<Bool>;

	var sounds:Null<Array<String>>;
	var soundChance:Null<Int>;
	var soundPath:Null<String>;
}

typedef DialogueDataDef =
{
	var events:Array<Array<Dynamic>>;
	var portrait:String;
	var expression:String;
	var text:Null<String>;
	var boxState:Null<String>;

	var speed:Null<Int>;
	var scale:Null<Int>;
}

typedef BoxDataDef =
{
	var position:Null<Array<Int>>;
	var textPos:Null<Array<Int>>;
	var scale:Null<Float>;
	var antialiasing:Null<Bool>;
	var singleFrame:Null<Bool>;
	var doFlip:Null<Bool>;
	var bgColor:Null<Array<Int>>;

	var states:Null<Dynamic>;
}

typedef DialogueFileDataDef =
{
	var box:String;
	var boxState:Null<String>;
	var dialogue:Array<DialogueDataDef>;
}

class DialogueBox extends FlxSpriteGroup
{
	///
	/*
		Epic Dialogue Documentation!

		nothing yet :P
	 */
	public var box:FNFSprite;
	public var bgFade:FlxSprite;
	public var portrait:FNFSprite;
	public var text:FlxText;
	public var alphabetText:Alphabet;

	public var dialogueData:DialogueFileDataDef;
	public var portraitData:PortraitDataDef;
	public var boxData:BoxDataDef;

	public var curPage:Int = 0;
	public var curCharacter:String;
	public var curExpression:String;
	public var curBoxState:String;

	public var eventImage:Null<FlxSprite>;

	public var whenDaFinish:Void->Void;

	public var textStarted:Bool = false;

	public static function createDialogue(thisDialogue:String):DialogueBox
	{
		//
		var newDialogue = new DialogueBox(false, thisDialogue);
		return newDialogue;
	}

	public function dialoguePath(file:String):String
	{
		var dialoguePath = Paths.file('assets/images/dialogue/portraits/$curCharacter/$file');
		var truePath = Paths.file(file);

		// load the json file
		if (sys.FileSystem.exists(dialoguePath))
			return dialoguePath;
		else
			return truePath;
	}

	public function new(?talkingRight:Bool = false, ?daDialogue:String)
	{
		super();

		trace("start");

		// get dialog data from dialogue.json
		dialogueData = haxe.Json.parse(daDialogue);

		dialogDataCheck();

		// background fade
		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), FlxColor.BLACK);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		// add the dialog box
		box = new FNFSprite(0, 370);

		// cur portrait
		portrait = new FNFSprite(800, 160);

		// thank u sammu for fixing alphabet.hx
		// i dont wanna touch it ever
		alphabetText = new Alphabet(100, 425, "cool", false, true, 0.7);

		// text
		text = new FlxText(100, 480, 1000, "", 35);
		text.color = FlxColor.BLACK;
		text.visible = false;

		updateDialog(true);

		// add stuff
		add(portrait);
		add(box);
		add(text);

		add(alphabetText);

		// skip text
		var skipText = new FlxText(100, 670, 1000, "PRESS SHIFT TO SKIP", 20);
		skipText.alignment = FlxTextAlign.CENTER;

		skipText.borderStyle = FlxTextBorderStyle.OUTLINE;
		skipText.borderColor = FlxColor.BLACK;
		skipText.borderSize = 3;

		skipText.screenCenter(X);
		add(skipText);
	}

	public function updateDialog(force:Bool = false)
	{
		// set current portrait
		updateTextBox(force);
		updatePortrait(force);
		updateEvents(force);

		var pageData = dialogueData.dialogue[curPage];

		var startText:Void->Void = function()
		{
			// Text update
			var textToDisplay = "lol u need text for dialog";

			if (pageData.text != null)
				textToDisplay = pageData.text;

			alphabetText.startText(textToDisplay, true);
		}

		// change speed
		if (pageData.speed != null)
			alphabetText.textSpeed = 0.06 / pageData.speed;
		else
			alphabetText.textSpeed = 0.06;

		// change size
		if (pageData.scale != null)
			alphabetText.textSize = 0.7 * pageData.scale;
		else
			alphabetText.textSize = 0.7;

		// If no text has shown up yet, we need to wait a moment
		if (textStarted == false)
		{
			// Set the text to nothing for now
			alphabetText.startText('', true);
			// To prevent awkward text not against a dialogue background, a quick fix is to delay the initial text
			new FlxTimer().start(0.375, function(tmr:FlxTimer)
			{
				textStarted = true;
				startText();
			});
		}
		// If the text has started, build the text
		else
			startText();
	}

	public function updateTextBox(force:Bool = false)
	{
		var curBox = dialogueData.box;
		var newState = dialogueData.dialogue[curPage].boxState;

		if (force && newState == null)
			newState = dialogueData.boxState;

		if (newState == null)
			return;

		if (curBoxState != newState || force)
		{
			curBoxState = newState;

			// get the path to the json
			var boxJson = Paths.file('images/dialogue/boxes/$curBox/$curBox.json');

			// load the json and sprite
			boxData = haxe.Json.parse(sys.io.File.getContent(boxJson));
			box.frames = Paths.getSparrowAtlas('dialogue/boxes/$curBox/$curBox');

			// get the states sectioon
			var curStateData = Reflect.field(boxData.states, curBoxState);

			if (curStateData == null)
				return;

			// default and open animations
			var defaultAnim:Array<Dynamic> = Reflect.field(curStateData, "default");
			var openAnim:Array<Dynamic> = Reflect.field(curStateData, "open");

			// make sure theres atleast a offset if things are null
			if (defaultAnim[1] == null)
				defaultAnim[1] = [0, 0];

			if (openAnim[1] == null)
				openAnim[1] = [0, 0];

			// check if single frame
			if (boxData.singleFrame == null)
				boxData.singleFrame = false;

			// do flip
			if (boxData.doFlip == null)
				boxData.doFlip = true;

			if (boxData.bgColor != null)
			{
				var colorArray = boxData.bgColor;
				var newColor = FlxColor.fromRGB(colorArray[0], colorArray[1], colorArray[2]);

				bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), newColor);
				bgFade.scrollFactor.set();
				bgFade.alpha = 0;
				add(bgFade);
			}

			// add the animations
			box.animation.addByPrefix('normal', defaultAnim[0], 24, true);
			box.addOffset('normal', defaultAnim[1][0], defaultAnim[1][1]);

			box.animation.addByPrefix('normalOpen', openAnim[0], 24, false);
			box.addOffset('normalOpen', openAnim[1][0], openAnim[1][1]);

			// if the box doesnt have a position set it to 0 0
			if (boxData.position == null)
				boxData.position = [0, 0];

			box.x = boxData.position[0];
			box.y = boxData.position[1];

			// other stuff
			if (boxData.scale == null)
				boxData.scale = 1;

			if (boxData.antialiasing == null)
				boxData.antialiasing = true;

			box.scale = new FlxPoint(boxData.scale, boxData.scale);
			box.antialiasing = boxData.antialiasing;

			if (boxData.textPos != null)
			{
				text.x = boxData.textPos[0];
				text.y = boxData.textPos[1];
			}

			box.playAnim('normalOpen');
		}
	}

	public function updatePortrait(force:Bool = false)
	{
		var newChar = dialogueData.dialogue[curPage].portrait;

		if (curCharacter != newChar || force)
		{
			if (newChar != null)
			{
				// made the curCharacter the new character
				curCharacter = newChar;
				var portraitJson = Paths.file('images/dialogue/portraits/$curCharacter/$curCharacter.json');

				// load the json file
				if (sys.FileSystem.exists(portraitJson))
				{
					portraitData = haxe.Json.parse(sys.io.File.getContent(portraitJson));
					portrait.frames = Paths.getSparrowAtlas('dialogue/portraits/$curCharacter/$curCharacter');
				}

				// check if the animation loops for the talking anim lol
				var loop = true;
				if (portraitData.loop != null)
					loop = portraitData.loop;

				// loop through the expressions and add the to the list of expressions
				for (n in Reflect.fields(portraitData.expressions))
				{
					var curAnim = Reflect.field(portraitData.expressions, n);
					var animName = n;

					portrait.animation.addByPrefix(animName, curAnim, 24, loop);
				}

				// check for null values
				if (portraitData.scale == null)
					portraitData.scale = 1;

				if (portraitData.antialiasing == null)
					portraitData.antialiasing = true;

				// change some smaller values
				portrait.scale.set(portraitData.scale, portraitData.scale);
				portrait.antialiasing = portraitData.antialiasing;

				// position and flip stuff
				// honestly
				var newX = 850;
				var newY = 160;
				var enterX = -20;
				var newFlip = false;

				if (Std.isOfType(portraitData.position, String))
				{
					switch (portraitData.position)
					{
						case "left":
							newX = 10;
							enterX = -enterX;
							newFlip = true;
						case "middle":
							newX = 400;
					}
				}
				else if (Std.isOfType(portraitData.position, Array))
				{
					if (portraitData.flipX)
						enterX = -enterX;

					newX = portraitData.position[0];
					newY = portraitData.position[1];
				}

				if (portraitData.offset == null)
					portraitData.offset = [0, 0];

				newX -= portraitData.offset[0];
				newY -= portraitData.offset[1];

				portrait.x = newX - enterX;
				portrait.y = newY;

				// flip
				if (portraitData.flipX != null)
					newFlip = portraitData.flipX;

				portrait.flipX = newFlip;

				// update bloops
				if (portraitData.sounds != null)
				{
					if (portraitData.soundPath != null)
						alphabetText.beginPath = "assets/" + portraitData.soundPath;
					else
						alphabetText.beginPath = 'assets/images/dialogue/portraits/$curCharacter/';

					alphabetText.soundChoices = portraitData.sounds;

					if (portraitData.soundChance != null)
						alphabetText.soundChance = portraitData.soundChance;
					else
						alphabetText.soundChance = 40;
				}
				else
					alphabetText.soundChance = 0;

				// flip check
				if (boxData.doFlip == true)
					box.flipX = newFlip;

				// this causes problems, and i know exactly what the problem is... i just cant fix it
				// basically i need to get rid of the last tween before doing a new one, or else the portraits slide around all over the place
				// ngl its kinda funny
				FlxTween.tween(portrait, {x: newX + enterX}, 0.2, {ease: FlxEase.quadInOut});
			}
		}

		// change expressions
		var newExpression = dialogueData.dialogue[curPage].expression;
		if (newExpression != null)
			curExpression = newExpression;

		portrait.animation.play(curExpression);
	}

	function runEvent(eventArray:Array<Dynamic>)
	{
		var event = eventArray[0];

		switch (event)
		{
			case "image":
				var _sprite:Dynamic = eventArray[1];
				var _x = eventArray[2];
				var _y = eventArray[3];
				var _scaleX = eventArray[4];
				var _scaleY = eventArray[5];

				trace(Paths.file(_sprite));

				eventImage = new FlxSprite(_x, _y);

				if (Std.isOfType(_sprite, Array))
				{
					eventImage.frames = Paths.getSparrowAtlas(_sprite[0]);

					eventImage.animation.addByPrefix("anim", _sprite[1], 24, _sprite[2]);
					eventImage.animation.play("anim");
				}
				else
				{
					eventImage.loadGraphic(Paths.file(_sprite + ".png"));
				}

				eventImage.scale.set(_scaleX, _scaleY);
				add(eventImage);

			case "sound":
				var _sound = eventArray[1] + "." + Paths.SOUND_EXT;

				trace(Paths.file(_sound));

				FlxG.sound.play(Paths.file(_sound));
		}
	}

	function updateEvents(force:Bool = false)
	{
		var curEvents = dialogueData.dialogue[curPage].events;

		if (eventImage != null)
			eventImage.destroy();

		// do da current vent
		if (curEvents == null)
			return;

		for (event in curEvents)
		{
			trace(event);
			runEvent(event);
		}
	}

	// mario
	// WOAH THE CODIST I LOVE MARIO!!!
	public function closeDialog()
	{
		whenDaFinish();
		alphabetText.playSounds = false;
		kill();
	}

	public function dialogDataCheck()
	{
		var tisOkay = true;

		if (dialogueData.box == null)
			tisOkay = false;
		if (dialogueData.dialogue == null)
			tisOkay = false;

		if (!tisOkay)
			closeDialog();
	}

	override function update(elapsed:Float)
	{
		if (box.animation.finished)
		{
			if (boxData.singleFrame != true)
				box.playAnim('normal');

			text.visible = true;
		}

		portrait.animation.paused = alphabetText.finishedLine;
		if (portrait.animation.paused)
			portrait.animation.finish();

		bgFade.alpha += 0.02;
		if (bgFade.alpha > 0.6)
			bgFade.alpha = 0.6;

		super.update(elapsed);
	}
}
