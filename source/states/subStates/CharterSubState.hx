package states.subStates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.CoolUtil;
import meta.MusicBeat.MusicBeatSubState;
import meta.data.*;
import meta.data.font.Alphabet;
import states.charting.*;

class CharterSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 0;
	var pauseMusic:FlxSound;

	var pauseOG:Array<String> = ['Forever Charter', 'Original Charter'];
	var menuItems:Array<String> = [];

	public static var charter:Int = -1;

	public static var playingPause:Bool = false;

	public function new(x:Float = 0, y:Float = 0, playSong:Bool = true)
	{
		super();

		menuItems = pauseOG;

		if (!playingPause && playSong)
		{
			playingPause = true;
			pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
			pauseMusic.volume = 0;
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			pauseMusic.ID = 9000;

			FlxG.sound.list.add(pauseMusic);
		}
		else
		{
			for (i in FlxG.sound.list)
			{
				if (i.ID == 9000) // jankiest static variable
					pauseMusic = i;
			}
		}

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var select:FlxText = new FlxText(20, 15, 0, "", 32);
		select.screenCenter(X);
		select.text += 'Select a Chart Editor.';
		select.scrollFactor.set();
		select.setFormat(Paths.font('vcr.ttf'), 32);
		select.updateHitbox();
		add(select);

		select.alpha = 0;
		select.x = FlxG.width - (select.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(select, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	private function regenMenu()
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}

		for (i in 0...menuItems.length)
		{
			var menuItem:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			menuItem.isMenuItem = true;
			menuItem.itemType = "Centered";
			menuItem.screenCenter(X);
			menuItem.targetY = i;
			grpMenuShit.add(menuItem);
		}

		curSelected = 0;

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var esc = controls.BACK;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (esc)
		{
			close();
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			switch (daSelected)
			{
				case "Forever Charter":
					charter = 0;
					PlayState.chartingMode = true;
					PlayState.preventScoring = true;
					if (FlxG.sound.music != null) FlxG.sound.music.stop();
					Main.switchState(this, new ChartingState());
				case "Original Charter":
					charter = 1;
					PlayState.chartingMode = true;
					PlayState.preventScoring = true;
					if (FlxG.sound.music != null) FlxG.sound.music.stop();
					Main.switchState(this, new OriginalChartingState());
			}
		}

		if (playingPause) {
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;
		}
	}

	override function destroy()
	{
		if (playingPause) {
			pauseMusic.destroy();
			playingPause = false;
		}
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		//
	}
}