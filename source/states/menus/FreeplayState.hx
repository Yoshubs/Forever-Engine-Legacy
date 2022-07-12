package states.menus;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.ColorTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.HealthIcon;
import lime.utils.Assets;
import meta.CoolUtil;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import openfl.media.Sound;
import states.subStates.CharterSubState;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	var curDifficulty:Int = 1;

	var presses:Int = 0;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var intendedRank:String = 'N/A';

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;
	var songToPlay:Sound = null;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var mainColor = FlxColor.WHITE;
	private var bg:FlxSprite;
	private var scoreBG:FlxSprite;

	private var existingSongs:Array<String> = [];
	private var existingDifficulties:Array<Array<String>> = [];

	var leText:String;
	var barTxt:FlxText;

	override function create()
	{
		super.create();

		presses = 0;

		mutex = new Mutex();

		/**
			Wanna add songs? They're in the Main state now, you can just find the week array and add a song there to a specific week.
			Alternatively, you can make a folder in the Songs folder and put your songs there, however, this gives you less
			control over what you can display about the song (color, icon, etc) since it will be pregenerated for you instead.
		**/
		// load in all songs that exist in folder
		var folderSongs:Array<String> = CoolUtil.returnLibrary('songs', 'assets');

		///*
		for (i in 0...Main.gameWeeks.length)
		{
			addWeek(Main.gameWeeks[i][0], i, Main.gameWeeks[i][1], Main.gameWeeks[i][2]);
			for (j in cast(Main.gameWeeks[i][0], Array<Dynamic>))
				existingSongs.push(j.toLowerCase());
		}

		// */

		for (i in folderSongs)
		{
			if (!existingSongs.contains(i.toLowerCase()))
			{
				var icon:String = 'gf';
				var chartExists:Bool = FileSystem.exists(Paths.songJson(i, i));
				if (chartExists)
				{
					var castSong:SwagSong = Song.loadFromJson(i, i);
					icon = (castSong != null) ? castSong.player2 : 'gf';
					addSong(CoolUtil.spaceToDash(castSong.song), 1, icon, FlxColor.WHITE);
				}
			}
		}

		// LOAD MUSIC
		// ForeverTools.resetMenuMusic();

		#if DISCORD_RPC
		Discord.changePresence('FREEPLAY MENU', 'Main Menu');
		#end

		// LOAD CHARACTERS
		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName.split('-').join(' '), true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();
		resetScore(true);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		leText = "- ALT = Open Charting Menu. - RESET = Reset Score and Ranking. -";
		var size:Int = 18;
		barTxt = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		barTxt.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		barTxt.scrollFactor.set();
		add(barTxt);

		FlxTween.tween(barTxt,{y: FlxG.height - 25}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(textBG,{y: FlxG.height - 28}, 2, {ease: FlxEase.elasticInOut});
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songColor:FlxColor)
	{
		///*
		var coolDifficultyArray = [];
		for (i in CoolUtil.difficultyArray)
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + i))
				|| (FileSystem.exists(Paths.songJson(songName, songName)) && i == "NORMAL"))
				coolDifficultyArray.push(i);

		if (coolDifficultyArray.length > 0)
		{ //*/
			songs.push(new SongMetadata(songName, weekNum, songCharacter, songColor));
			existingDifficulties.push(coolDifficultyArray);
		}
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>, ?songColor:Array<FlxColor>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];
		if (songColor == null)
			songColor = [FlxColor.WHITE];

		var num:Array<Int> = [0, 0];
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num[0]], songColor[num[1]]);

			if (songCharacters.length != 1)
				num[0]++;
			if (songColor.length != 1)
				num[1]++;
		}
	}

	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxTween.color(bg, 0.35, bg.color, mainColor);

		var lerpVal = Main.framerateAdjust(0.1);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var alt = FlxG.keys.justPressed.ALT;
		var shift = FlxG.keys.justPressed.SHIFT;
		var shiftP = FlxG.keys.pressed.SHIFT;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(shiftP) shiftMult = 3;

		if(songs.length > 1)
		{
			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 0;
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 0;
			}

			/**
			* Hold Scrolling Code
			* @author ShadowMario
			**/

			if(controls.UI_DOWN || controls.UI_UP)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					changeDiff();
				}
			}

			if(FlxG.mouse.wheel != 0)
			{
				changeSelection(-shiftMult * FlxG.mouse.wheel);
				changeDiff();
			}
		}

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		else if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK || FlxG.mouse.justPressedRight)
		{
			if (presses <= 0) {
				if (FlxG.sound.music != null) FlxG.sound.music.stop();
				threadActive = false;
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
				Main.switchState(this, new MainMenuState());
			}

			if (presses > 0) {
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
				barTxt.text = '- Data Destruction was Interrupted! -';
				endBullshit();
			}
		}

		if (accepted || FlxG.mouse.justPressed)
			loadSong(true, true);
		else if (alt) {
			loadSong(false, false);
			openSubState(new CharterSubState(0, 0, false));
		}
		else if (controls.RESET && presses < 3)
		{
			presses++;
			resetScore();
		}

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		repositionHighscore();

		mutex.acquire();
		if (songToPlay != null)
		{
			FlxG.sound.playMusic(songToPlay);

			if (FlxG.sound.music.fadeTween != null)
				FlxG.sound.music.fadeTween.cancel();

			FlxG.sound.music.volume = 0.0;
			FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);

			songToPlay = null;
		}
		mutex.release();
	}

	function loadSong(go:Bool = true, stopThread:Bool = true)
	{
		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(),
			CoolUtil.difficultyArray.indexOf(existingDifficulties[curSelected][curDifficulty]));

		PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;

		PlayState.storyWeek = songs[curSelected].week;
		#if debug trace('CUR WEEK' + PlayState.storyWeek); #end

		if (stopThread) {
			if (FlxG.sound.music != null) FlxG.sound.music.stop();
			threadActive = false;
		}
		if (go) Main.switchState(this, new PlayState());
	}

	var lastDifficulty:String;
	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		if (lastDifficulty != null && change != 0)
			while (existingDifficulties[curSelected][curDifficulty] == lastDifficulty)
				curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = existingDifficulties[curSelected].length - 1;
		if (curDifficulty > existingDifficulties[curSelected].length - 1)
			curDifficulty = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRank = Highscore.getRank(songs[curSelected].songName, curDifficulty);

		diffText.text = '< ' + existingDifficulties[curSelected][curDifficulty] + ' - ' + intendedRank + ' >';
		lastDifficulty = existingDifficulties[curSelected][curDifficulty];
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRank = Highscore.getRank(songs[curSelected].songName, curDifficulty);

		// set up color stuffs
		mainColor = songs[curSelected].songColor;

		// song switching stuffs

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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

		#if debug trace("curSelected: " + curSelected); #end

		changeDiff();

		changeSongPlaying();
	}

	function changeSongPlaying()
	{
		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
					{
						#if debug trace("Killing thread"); #end
						return;
					}

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						if (index == curSelected && index != curSongPlaying)
						{
							#if debug trace("Loading index " + index); #end

							var inst:Sound = Paths.inst(songs[curSelected].songName);

							if (index == curSelected && threadActive)
							{
								mutex.acquire();
								songToPlay = inst;
								mutex.release();

								curSongPlaying = curSelected;
							}
							#if debug
							else
								trace("Nevermind, skipping " + index);
							#end
						}
						#if debug
						else
							trace("Skipping " + index);
						#end
					}
				}
			});
		}

		songThread.sendMessage(curSelected);
	}

	var playingSongs:Array<FlxSound> = [];

	private function repositionHighscore()
	{
		// Adhere the position of all the things (I'm sorry it was just so ugly before I had to fix it Shubs)
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.width = scoreText.width + 8;
		scoreBG.x = FlxG.width - scoreBG.width;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
	}

	private function resetScore(noSound:Bool = false)
	{
		if (!noSound)
			FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);

		if (!noSound && !Init.trueSettings.get('Disable Flashing Lights')) // shut.
			FlxTween.color(bg, 0.50, FlxColor.GRAY, bg.color);

		if (presses < 0 || presses > 3)
			presses = 0;

		if (presses == 1)
			barTxt.text = '- Are you Sure? -';

		if (presses == 2)
		{
			barTxt.text = '- Really Sure? -';
			FlxG.sound.music.volume = 0.3;
		}

		if (presses == 3)
		{
			noSound = true;
			barTxt.text = '- Data Destroyed! -';
			FlxG.sound.play(Paths.sound('resetScore_sfx'), 0.4);
			iconArray[curSelected].animation.curAnim.curFrame = 1;
			Highscore.clearData(songs[curSelected].songName, curDifficulty);
			noSound = false;
			endBullshit();
		}
	}

	private function endBullshit()
	{
		new FlxTimer().start(1, function(resetText:FlxTimer)
		{
			barTxt.text = leText;
			presses = 0;
			iconArray[curSelected].animation.curAnim.curFrame = 0;
			FlxG.sound.music.fadeIn(1.0, 0.3, 1.0);
		});

		FlxTween.color(bg, 0.35, bg.color, mainColor);

		changeSelection();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songColor:FlxColor = FlxColor.WHITE;

	public function new(song:String, week:Int, songCharacter:String, songColor:FlxColor)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songColor = songColor;
	}
}
