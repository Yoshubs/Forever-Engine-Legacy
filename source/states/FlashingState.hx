package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import meta.MusicBeat.MusicBeatState;

class FlashingState extends MusicBeatState
{
	var bg:FlxSprite;
	var warnText:FlxText;

	override function create()
	{
		super.create();

		// reset volume
		FlxG.sound.volume = 1;

		// bind save
		FlxG.save.bind('foreverengine-settings');

		// set up state save, this ensures that you did leave this state once BACK or ACCEPT was pressed
		if (FlxG.save.data.leftFlashing == null)
			FlxG.save.data.leftFlashing = false;

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.alpha = 0.4;
		bg.color = 0xFFFF56B3;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Hey, watch out!\n
			This Mod contains some flashing lights!\n
			Press ENTER to disable them now.\n
			You can also disable them later on the Options Menu.\n
			Press ESCAPE to ignore this message.\n
			You've been warned!",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	private function gotoTitleScreen()
	{
		// set up transitions
		FlxTransitionableState.skipNextTransIn = false;
		FlxTransitionableState.skipNextTransOut = false;

		if (Init.trueSettings.get("Custom Titlescreen"))
			Main.switchState(this, new CustomTitlescreen());
		else
			Main.switchState(this, new TitleState());

		// set it to true, since you don't wanna go back to this state
		FlxG.save.data.leftFlashing = true;
		//FlxG.save.flush();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(!FlxG.save.data.leftFlashing) {
			var accept:Bool = controls.ACCEPT;
			var back:Bool = controls.BACK;

			if (accept || back)
			{
				if(!back) {
					Init.trueSettings.set('Disable Flashing Lights', true);
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							gotoTitleScreen();
						}
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							gotoTitleScreen();
						}
					});
				}
			}
		} else {
			// anti "haha u stuck here now lmao!!!"
			gotoTitleScreen();
		}
	}
}
