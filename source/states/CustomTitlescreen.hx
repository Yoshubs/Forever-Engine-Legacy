package states;

import base.*;
import base.MusicBeat.MusicBeatState;
import dependency.Discord;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.Alphabet;
import lime.app.Application;
import openfl.Assets;
import states.menus.*;

using StringTools;

class CustomTitlescreen extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		controls.setKeyboardScheme(None, false);
		curWacky = FlxG.random.getObject(getIntroTextShit());
		super.create();

		startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	var initLogowidth:Float = 0;
	var newLogoScale:Float = 0;
	var backdrop:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			///*
			#if DISCORD_RPC
			Discord.changePresence('TITLE SCREEN', 'Main Menu');
			#end

			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.32, new FlxPoint(0, -1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.32, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			// */

			ForeverTools.resetMenuMusic(true);
		}

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		// cool bg
		backdrop = new FlxSprite().makeGraphic(100, 100, 0xFF84A682);
		backdrop.setGraphicSize(Std.int(bg.width), Std.int(bg.height));
		backdrop.screenCenter();
		add(backdrop);

		logoBl = new FlxSprite();
		logoBl.frames = Paths.getSparrowAtlas('menus/base/title/foreverlogo');
		logoBl.animation.addByPrefix('bumpin', 'forever bop', 16, false, false, false);
		logoBl.animation.play('bumpin');
		logoBl.antialiasing = true;

		logoBl.updateHitbox();

		logoBl.setGraphicSize(Std.int(logoBl.width / 2));
		logoBl.updateHitbox();

		logoBl.screenCenter();
		logoBl.y -= 100;

		initLogowidth = logoBl.width;
		newLogoScale = logoBl.scale.x;
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;
		add(logoBl);

		titleText = new FlxSprite(125, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('menus/base/title/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;
		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var swagGoodArray:Array<Array<String>> = [['no idea what psych engine is', 'vine boom sfx']];
		if (Assets.exists(Paths.txt('introText')))
		{
			var fullText:String = Assets.getText(Paths.txt('introText'));
			var firstArray:Array<String> = fullText.split('\n');

			for (i in firstArray)
				swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);
		logoBl.scale.x = FlxMath.lerp(newLogoScale, logoBl.scale.x, 0.95);
		logoBl.scale.y = FlxMath.lerp(newLogoScale, logoBl.scale.y, 0.95);

		FlxTween.color(backdrop, 1, backdrop.color, FlxColor.BLACK);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.animation.play('press');

			if (!Init.trueSettings.get('Disable Flashing Lights'))
				FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			logoBl.setGraphicSize(Std.int(initLogowidth * 1.15));

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated

				// var version:String = "v" + Application.current.meta.get('version');
				Main.switchState(this, new MainMenuState());
				// }
			});
		}

		// hi game, please stop crashing its kinda annoyin, thanks!
		if (pressedEnter && !skippedIntro && initialized)
			skipIntro();

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	var reverser = 1;

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bumpin');
		backdrop.color = 0x84A682;

		switch (curBeat)
		{
			case 16:
				skipIntro();
		}
	}

	override function stepHit()
	{
		super.stepHit();

		switch (curStep)
		{
			case 4:
				createCoolText(['Yoshubs']);
			case 6:
				addMoreText('Neolixn');
			case 8:
				addMoreText('Gedehari');
			case 10:
				addMoreText('Tsuraran');
			case 12:
				addMoreText('FlopDoodle');
			case 16:
				addMoreText('');
				addMoreText('PRESENT');

			case 24:
				deleteCoolText();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
		//
	}
}
