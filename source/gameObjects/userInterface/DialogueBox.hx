package gameObjects.userInterface;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import meta.CoolUtil;
import meta.MusicBeat.MusicBeatState;
import meta.data.font.Alphabet;
import states.PlayState;
import openfl.media.Sound;

using StringTools;

typedef Dialogue =
{
	skin:String,
	lines:Array<Array<Dynamic>>
}

typedef DialogueCharacter =
{
	animations:Array<Array<Dynamic>>,
	onLeft:Bool,
	isPixel:Bool
}

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curSkin:String = '';
	var curCharacter:String = '';

	var dialogue:Dialogue;

	var characters:Map<String, DialogueCharacter>;
	var skins:Array<String> = [];

	var swagText:FlxTypeText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var bgFade:FlxSprite;

	var skipText:FlxText;

	var curLine:Int = 0;

	var isPixelSkin:Bool = false;

	var skinBase:String = 'dialogue/boxes/';
	var portraitBase:String = 'dialogue/portraits/';

	public function new(dialogue:Dialogue, ?music:Sound)
	{
		super();

		this.dialogue = dialogue;

		characters = new Map<String, DialogueCharacter>();

		// create the characters and the skins lists
		for (line in dialogue.lines)
		{
			var char:String = line[0][0];
			if (!characters.exists(char))
				characters.set(char, loadCharacterFromJson(Paths.json('images/' + portraitBase + char)));

			var skin:String = line[0][2];
			if (skin != null && !skins.contains(skin))
				skins.push(skin);
		}

		// cache characters and skins to reduce lag
		for (char in characters.keys())
			Paths.returnGraphic(portraitBase + char);
		for (skin in skins)
			Paths.returnGraphic(skinBase + skin);

		if (dialogue.skin == null && dialogue.skin == '')
			dialogue.skin = 'normal';
		if (music != null)
		{
			FlxG.sound.playMusic(music, 0);
			FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			if (!isEnding)
			{
				bgFade.alpha += (1 / 5) * 0.7;
				if (bgFade.alpha > 0.7)
					bgFade.alpha = 0.7;
			}
		}, 5);

		box = new FlxSprite(0, 45);
		loadSkin(dialogue.skin.toLowerCase());
		box.screenCenter(X);
		if (!isPixelSkin)
			box.flipX = getCharacter().onLeft;
		box.animation.play('normalOpen');
		add(box);

		portraitLeft = new FlxSprite(-20, 40);
		portraitLeft.flipX = true;
		portraitLeft.scrollFactor.set();
		portraitLeft.visible = false;
		add(portraitLeft);

		portraitRight = new FlxSprite(0, 40);
		portraitRight.scrollFactor.set();
		portraitRight.visible = false;
		add(portraitRight);

		loadPortraits();

		portraitLeft.screenCenter(X);

		var textX:Float = 240;
		var textY:Float = 500;
		if (!isPixelSkin)
		{
			textX -= 75;
			textY -= 35;
		}

		swagText = new FlxTypeText(textX, textY, Std.int(FlxG.width * 0.6), "", 32);
		swagText.font = 'Pixel Arial 11 Bold';
		swagText.color = 0xFF3F2021;
		swagText.borderStyle = SHADOW;
		swagText.borderColor = 0xFFD89494;
		swagText.borderSize = 2;
		swagText.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagText);

		skipText = new FlxText(0, FlxG.height - 25, FlxG.width, 'PRESS SHIFT TO SKIP', 20);
		skipText.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skipText.borderSize = 1.5;
		skipText.visible = false;
		add(skipText);

		if (dialogue.skin == 'evil-pixel')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagText.color = FlxColor.WHITE;
			swagText.borderColor = FlxColor.BLACK;
		}
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
			skipText.visible = true;
		}

		var shift = FlxG.keys.justPressed.SHIFT;

		if ((shift || CoolUtil.getControls().ACCEPT) && dialogueStarted == true)
		{
			if (!isEnding)
				FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (shift || curLine == dialogue.lines.length - 1)
			{
				if (!isEnding)
				{
					isEnding = true;

					remove(skipText);

					if (FlxG.sound.music != null)
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagText.alpha -= 1 / 5;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				curLine++;
				var skin:String = dialogue.lines[curLine][0][2];
				if (skin != null && skin.toLowerCase() != curSkin.toLowerCase())
					loadSkin(skin);
				loadPortraits();
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue()
	{
		if (!isEnding && dialogue.lines[curLine] != null)
		{
			swagText.resetText(dialogue.lines[curLine][1]);
			swagText.start(0.04, true);

			// check if the character is on the right or the left
			if (getCharacter().onLeft)
			{
				portraitRight.visible = false;
				if (!portraitLeft.visible)
					portraitLeft.visible = true;
				if (!isPixelSkin)
					box.flipX = true;
			}
			else
			{
				portraitLeft.visible = false;
				if (!portraitRight.visible)
					portraitRight.visible = true;
				if (!isPixelSkin)
					box.flipX = false;
			}
		}
	}

	function loadSkin(name:String = 'normal')
	{
		switch (name)
		{
			case 'evil-pixel':
				curSkin = 'evil-pixel';
				isPixelSkin = true;
				box.frames = Paths.getSparrowAtlas(skinBase + 'dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
			case 'pixel':
				curSkin = 'pixel';
				isPixelSkin = true;
				box.frames = Paths.getSparrowAtlas(skinBase + 'dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			default:
				curSkin = 'normal';
				isPixelSkin = false;
				box.frames = Paths.getSparrowAtlas(skinBase + 'speech_bubble_talking');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
				box.y = FlxG.height - box.height / 1.1;
		}

		if (!isPixelSkin)
			box.x += 32;
		if (isPixelSkin)
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
	}

	function loadPortraits()
	{
		var lineShit:Array<String> = dialogue.lines[curLine][0];
		var character:DialogueCharacter = getCharacter();

		if (character.onLeft)
		{
			portraitLeft.frames = Paths.getSparrowAtlas(portraitBase + lineShit[0]);
			setCharacterAnims(portraitLeft, character);
			if (character.isPixel)
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
			portraitLeft.updateHitbox();
			if (lineShit[1] != null)
				portraitLeft.animation.play(lineShit[1]);
			else
				portraitLeft.animation.play('normal');
		}
		else
		{
			portraitRight.frames = Paths.getSparrowAtlas(portraitBase + lineShit[0]);
			setCharacterAnims(portraitRight, character);
			if (character.isPixel)
				portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
			portraitRight.updateHitbox();
			if (lineShit[1] != null)
				portraitRight.animation.play(lineShit[1]);
			else
				portraitRight.animation.play('normal');
		}
	}

	function setCharacterAnims(sprite:FlxSprite, character:DialogueCharacter)
	{
		for (anim in character.animations)
			sprite.animation.addByPrefix(anim[0], anim[1], 24, anim[2]);
	}

	function getCharacter()
	{
		return characters.get(dialogue.lines[curLine][0][0]);
	}

	public static function loadFromJson(path:String):Dialogue
	{
		return cast CoolUtil.readJson(path);
	}

	public static function loadCharacterFromJson(path:String):DialogueCharacter
	{
		return cast CoolUtil.readJson(path);
	}
}
