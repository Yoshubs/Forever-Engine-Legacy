package states.menus;

import base.MusicBeat.MusicBeatState;
import dependency.Discord;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;

/**
	This is the main menu state! Not a lot is going to change about it so it'll remain similar to the original, but I do want to condense some code and such.
	Get as expressive as you can with this, create your own menu!
**/
class MainMenuState extends MusicBeatState
{
	var menuItems:FlxTypedGroup<FlxSprite>;
	var curSelected:Float = 0;

	var bg:FlxSprite; // the background has been separated for more control
	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	var canSnap:Array<Float> = [];

	var finishedAlphaTween:Bool = false;

	// the create 'state'
	override function create()
	{
		super.create();

		CreditsMenu.offsetNumbers = false;

		// set the transitions to the previously set ones
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		#if DISCORD_RPC
		Discord.changePresence('MENU SCREEN', 'Main Menu');
		#end

		// uh
		persistentUpdate = persistentDraw = true;

		// background
		bg = new FlxSprite(-80);
		bg.loadGraphic(Paths.image('menus/base/menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menus/base/menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);

		// add the camera
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		// add the menu items
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		// create the menu items themselves
		var tex = Paths.getSparrowAtlas('menus/base/title/FNF_main_menu_assets');

		// loop through the menu options
		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			// add the animations in a cool way (real
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			canSnap[i] = -1;
			// set the id
			menuItem.ID = i;
			menuItem.alpha = 0;

			// placements
			menuItem.screenCenter(X);
			// if the id is divisible by 2
			if (menuItem.ID % 2 == 0)
				menuItem.x += 1000;
			else
				menuItem.x -= 1000;

			// actually add the item
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItem.updateHitbox();

			FlxTween.tween(menuItem, {alpha: 1}, 0.9,
			{
				ease: FlxEase.quadIn,
				onComplete: function(tween:FlxTween)
				{
					finishedAlphaTween = true;
				}
			});


			/*
				FlxTween.tween(menuItem, {alpha: 1, x: ((FlxG.width / 2) - (menuItem.width / 2))}, 0.35, {
					ease: FlxEase.smootherStepInOut,
					onComplete: function(tween:FlxTween)
					{
						canSnap[i] = 0;
					}
			});*/
		}

		// set the camera to actually follow the camera object that was created before
		var camLerp = Main.framerateAdjust(0.10);
		FlxG.camera.follow(camFollow, null, camLerp);

		updateSelection();

		// from the base game lol

		var versionShit:FlxText = new FlxText(5, FlxG.height - 20, 0, "Forever Engine v" + Main.gameVersion + ' - Custom Build v' + Main.customBuildVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		//
	}

	// var colorTest:Float = 0;
	var selectedSomethin:Bool = false;
	var counterControl:Float = 0;

	override function update(elapsed:Float)
	{
		if (!selectedSomethin && finishedAlphaTween)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				updateSelection(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				updateSelection(1);
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
				updateSelection(-FlxG.mouse.wheel);
			}
		}

		if ((!selectedSomethin && finishedAlphaTween) && (controls.ACCEPT || FlxG.mouse.justPressed))
		{
			//
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			var flickerVal:Float = 0.06;
			
			if (Init.trueSettings.get('Disable Flashing Lights')) flickerVal = 1;
			if (!Init.trueSettings.get('Disable Flashing Lights')) FlxFlicker.flicker(magenta, 0.8, 0.1, false);

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0, x: FlxG.width * 2}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					FlxFlicker.flicker(spr, 1, flickerVal, false, false, function(flick:FlxFlicker)
					{
						var daChoice:String = optionShit[Math.floor(curSelected)];

						switch (daChoice)
						{
							case 'story mode':
								Main.switchState(this, new StoryMenuState());
							case 'freeplay':
								Main.switchState(this, new FreeplayState());
							case 'donate':
								Main.switchState(this, new CreditsMenu());
							case 'options':
								transIn = FlxTransitionableState.defaultTransIn;
								transOut = FlxTransitionableState.defaultTransOut;
								Main.switchState(this, new OptionsMenuState());
						}
					});
				}
			});
		}

		if (Math.floor(curSelected) != lastCurSelected)
			updateSelection();

		super.update(elapsed);

		menuItems.forEach(function(menuItem:FlxSprite)
		{
			menuItem.screenCenter(X);
		});
	}

	var lastCurSelected:Int = 0;

	private function updateSelection(hey:Int = 0)
	{
		curSelected += hey;

		if (curSelected < 0)
			curSelected = optionShit.length - 1;
		else if (curSelected >= optionShit.length)
			curSelected = 0;

		// reset all selections
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();
		});

		// set the sprites and all of the current selection
		camFollow.setPosition(menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().x,
			menuItems.members[Math.floor(curSelected)].getGraphicMidpoint().y);

		if (menuItems.members[Math.floor(curSelected)].animation.curAnim.name == 'idle')
			menuItems.members[Math.floor(curSelected)].animation.play('selected');

		menuItems.members[Math.floor(curSelected)].updateHitbox();

		lastCurSelected = Math.floor(curSelected);
	}
}
