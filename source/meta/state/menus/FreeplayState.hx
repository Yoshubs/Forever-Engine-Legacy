package meta.state.menus;

import openfl.system.System;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import gameObjects.userInterface.HealthIcon;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Song.SwagSong;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import sys.FileSystem;
import sys.thread.Mutex;
import sys.thread.Thread;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var curSelected:Int = 0;
	var curSongPlaying:Int = -1;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	var songThread:Thread;
	var threadActive:Bool = true;
	var mutex:Mutex;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	private var mainColor = FlxColor.WHITE;
	private var bg:FlxSprite;
	private var scoreBG:FlxSprite;

	private var existingSongs:Array<String> = [];
	private var existingDifficulties:Array<Array<String>> = [];

	// track all played songs
	private var currentTrackedSongs:Map<Int, FlxSound> = [];

	override function create()
	{
		super.create();

		mutex = new Mutex();

		/**
			Wanna add songs? They're in the Main state now, you can just find the week array and add a song there to a specific week.
			Alternatively, you can make a folder in the Songs folder and put your songs there, however, this gives you less
			control over what you can display about the song (color, icon, etc) since it will be pregenerated for you instead.
		**/
		// load in all songs that exist in folder
		var folderSongs:Array<String> = CoolUtil.returnAssetsLibrary('songs', 'assets');

		for (i in 0...Main.gameWeeks.length)
		{
			addWeek(Main.gameWeeks[i][0], i, Main.gameWeeks[i][1], Main.gameWeeks[i][2]);
			for (j in cast(Main.gameWeeks[i][0], Array<Dynamic>))
				existingSongs.push(j.toLowerCase());
		}

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
					addSong(CoolUtil.coolFormat(castSong.song), 1, icon, FlxColor.WHITE);
				}
			}
		}

		#if !html5
		Discord.changePresence('FREEPLAY MENU', 'Main Menu');
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menus/base/menuDesat'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
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

		FlxG.sound.music.destroy();

		changeSelection();
		changeDiff();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songColor:FlxColor)
	{
		var coolDifficultyArray = [];
		for (i in CoolUtil.difficultyArray)
			if (FileSystem.exists(Paths.songJson(songName, songName + '-' + i))
				|| (FileSystem.exists(Paths.songJson(songName, songName)) && i == "NORMAL"))
				coolDifficultyArray.push(i);

		if (coolDifficultyArray.length > 0)
		{
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

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		FlxTween.color(bg, 0.35, bg.color, mainColor);

		var lerpVal = Main.framerateAdjust(0.1);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, lerpVal));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		if (controls.UI_UP_P)
			changeSelection(-1);
		else if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.UI_LEFT_P)
			changeDiff(-1);
		if (controls.UI_RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			removeSongThread();
			ForeverTools.resetMenuMusic(false, true);
			Main.switchState(this, new MainMenuState());
		}

		if (controls.ACCEPT)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(),
				CoolUtil.difficultyArray.indexOf(existingDifficulties[curSelected][curDifficulty]));

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);

			removeSongThread();

			Main.switchState(this, new PlayState());
		}

		// Adhere the position of all the things (I'm sorry it was just so ugly before I had to fix it Shubs)
		scoreText.text = "PERSONAL BEST:" + lerpScore;
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.width = scoreText.width + 8;
		scoreBG.x = FlxG.width - scoreBG.width;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);

		mutex.acquire();
		mutex.release();
	}

	function removeSongThread()
	{
		// destroy all tracked songs before exit freeplay
		threadActive = false;
		for (song in currentTrackedSongs)
		{
			song.destroy();
		}
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

		diffText.text = '< ' + existingDifficulties[curSelected][curDifficulty] + ' >';
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

		changeDiff();

		// force garbage collector to run for really get some memory
		System.gc();

		if (songThread == null)
		{
			songThread = Thread.create(function()
			{
				while (true)
				{
					if (!threadActive)
					{
						trace("Killing thread");
						return;
					}

					var index:Null<Int> = Thread.readMessage(false);
					if (index != null)
					{
						// TODO: find a way to fix the memory issue with loading twice time the same song
						if (index == curSelected && index != curSongPlaying)
						{
							if (!currentTrackedSongs.exists(index))
							{
								currentTrackedSongs.set(index, new FlxSound().loadEmbedded(Paths.inst(songs[curSelected].songName), true, true).play());
								FlxG.sound.list.add(currentTrackedSongs.get(index));
							}

							if (threadActive)
							{
								mutex.acquire();
								mutex.release();

								// kill unused songs sd we will gain a little of memory
								for (i in currentTrackedSongs.keys())
								{
									var song:FlxSound = currentTrackedSongs.get(i);
									if (index == i)
									{
										song.revive();
										song.play();
									}
									else
										song.kill();
								}

								curSongPlaying = index;

								// trace("Play index " + index);
							}
							else
								trace("Thread not active, skipping " + index);
						}
						else
							trace("Skipping " + index);
					}
				}
			});
		}

		songThread.sendMessage(curSelected);
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
