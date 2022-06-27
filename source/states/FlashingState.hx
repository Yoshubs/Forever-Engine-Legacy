package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import meta.MusicBeat.MusicBeatState;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
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
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var accept:Bool = controls.ACCEPT;
			var back:Bool = controls.BACK;

			if (accept || back)
			{
				leftState = true;
				if(!back) {
					Init.trueSettings.set('Disable Flashing Lights', true);
					Init.saveSettings();
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
		}
		super.update(elapsed);
	}
}
