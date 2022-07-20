package states.subStates;

import base.Conductor.BPMChangeEvent;
import base.Conductor;
import base.MusicBeat.MusicBeatSubState;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import funkin.Boyfriend;
import states.*;
import states.menus.*;

class GameOverSubState extends MusicBeatSubState
{
	//
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var volume:Float = 1;

	public static var character:String = 'bf-dead';
	public static var deathSound:String = 'fnf_loss_sfx';
	public static var deathMusic:String = 'gameOver';
	public static var deathConfirm:String = 'gameOverEnd';

	public static function resetGameOver()
	{
		character = 'bf-dead';
		deathSound = 'fnf_loss_sfx';
		deathMusic = 'gameOver';
		deathConfirm = 'gameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float)
	{
		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, character);
		bf.x += bf.positionArray[0];
		bf.y += bf.positionArray[1];
		add(bf);

		PlayState.boyfriend.destroy();

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + 20, bf.getGraphicMidpoint().y - 40, 1, 1);
		add(camFollow);

		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
			endBullshit();

		if (controls.BACK)
		{
			//FlxG.resizeWindow(1280, 720);
			//FlxG.scaleMode = new RatioScaleMode();

			FlxG.sound.music.stop();
			PlayState.deaths = 0;

			if (PlayState.isStoryMode)
			{
				Main.switchState(this, new StoryMenuState());
			}
			else
				Main.switchState(this, new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12) {
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
			updateCamera = true;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			FlxG.sound.playMusic(Paths.music(deathMusic), volume);

		if (PlayState.storyWeek == 7)
		{
			volume = 0.2;

			if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			{
				FlxG.sound.play(Paths.sound('jeff/jeffGameover-' + FlxG.random.int(1, 25)), 1, false, null, true, function()
				{
					if (!isEnding) FlxG.sound.music.fadeIn(4, 0.2, 1);
				});
			}
		}

		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(deathConfirm));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
				{
					Main.switchState(this, new PlayState());
				});
			});
			//
		}
	}
}
