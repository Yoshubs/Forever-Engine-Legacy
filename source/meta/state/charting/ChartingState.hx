package meta.state.charting;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.display.shapes.FlxShapeBox;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import gameObjects.*;
import gameObjects.userInterface.*;
import gameObjects.userInterface.notes.*;
import gameObjects.userInterface.notes.Note.NoteType;
import gameObjects.userInterface.notes.Strumline.UIStaticArrow;
import haxe.Json;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import meta.MusicBeat.MusicBeatState;
import meta.data.*;
import meta.data.Section.SwagSection;
import meta.data.Song.SwagSong;
import meta.data.dependency.*;
import meta.data.dependency.BaseButton.CoolAssButton;
import meta.subState.charting.*;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.geom.ColorTransform;
import openfl.geom.Rectangle;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

#if !html5
import sys.thread.Thread;
#end

/**
	As the name implies, this is the class where all of the charting state stuff happens, so when you press 7 the game
	state switches to this one, where you get to chart songs and such. I'm planning on overhauling this entirely in the future
	and making it both more practical and more user friendly.
**/
class ChartingState extends MusicBeatState
{
	var _song:SwagSong;

	var songMusic:FlxSound;
	var vocals:FlxSound;
	var keysTotal = 8;

	var strumLine:FlxSprite;

	var camHUD:FlxCamera;
	var camGame:FlxCamera;
	var strumLineCam:FlxObject;

	var curSelectedNote:Note;

	public static var songPosition:Float = 0;
	public static var curSong:SwagSong;

	public static var gridSize:Int = 50;

	var dummyArrow:FlxSprite;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<Note>;
	var curRenderedSections:FlxTypedGroup<FlxBasic>;

	var arrowGroup:FlxTypedSpriteGroup<UIStaticArrow>;

	var buttonTextGroup:FlxTypedGroup<AbsoluteText>;
	var buttonGroup:FlxTypedGroup<CoolAssButton>;
	var gridGroup:FlxTypedGroup<FlxObject>;

	var buttonArray:Array<Array<Dynamic>> = [];

	var bfIcon:HealthIcon;
	var dadIcon:HealthIcon;

	var bpmTxt:FlxText;

	override public function create()
	{
		super.create();

		generateBackground();

		//x, y, text on button, text size, child (optional), size ("", "big", or "small"), 
		//function that will be called when pressed (optional)
		buttonArray = [
			[FlxG.width - 180, 20, "Reload Song", 20, null, "", null],
			[FlxG.width - 240, 70, "Swap Section Notes", 20, null, "", null],
			[FlxG.width - 240, 120, "Copy Section Notes", 20, null, "", null],
			[FlxG.width - 240, 170, "Paste Section Notes", 20, null, "", null]
		];

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
			_song = Song.loadFromJson('test', 'test');

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		gridGroup = new FlxTypedGroup<FlxObject>();
		add(gridGroup);

		buttonGroup = new FlxTypedGroup<CoolAssButton>();
		add(buttonGroup);

		buttonTextGroup = new FlxTypedGroup<AbsoluteText>();
		add(buttonTextGroup);

		generateButtons();
		generateGrid();

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<Note>();
		curRenderedSections = new FlxTypedGroup<FlxBasic>();

		generateNotes();

		add(curRenderedSections);
		add(curRenderedSustains);
		add(curRenderedNotes);

		// epic strum line
		strumLine = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width / 2), 2);
		add(strumLine);
		strumLine.screenCenter(X);

		// cursor
		dummyArrow = new FlxSprite().makeGraphic(gridSize, gridSize);
		add(dummyArrow);

		// and now the epic note thingies
		arrowGroup = new FlxTypedSpriteGroup<UIStaticArrow>(0, 0);
		for (i in 0...keysTotal)
		{
			var typeReal:Int = i;
			if (typeReal > 3)
				typeReal -= 4;

			var newArrow:UIStaticArrow = ForeverAssets.generateUIArrows(((FlxG.width / 2) - ((keysTotal / 2) * gridSize)) + ((i - 1) * gridSize),
				-76, typeReal, 'chart editor');

			newArrow.ID = i;
			newArrow.setGraphicSize(gridSize);
			newArrow.updateHitbox();
			newArrow.alpha = 0.9;
			newArrow.antialiasing = true;

			// lol silly idiot
			newArrow.playAnim('static');

			arrowGroup.add(newArrow);
		}
		add(arrowGroup);
		arrowGroup.x -= 1;

		bfIcon = new HealthIcon(_song.player1);
		dadIcon = new HealthIcon(_song.player2);
		bfIcon.scrollFactor.set(1, 1);
		dadIcon.scrollFactor.set(1, 1);

		bfIcon.setGraphicSize(gridSize, gridSize);
		dadIcon.setGraphicSize(gridSize, gridSize);

		bfIcon.flipX = true;

		add(bfIcon);
		add(dadIcon);

		bfIcon.screenCenter(X);
		dadIcon.screenCenter(X);

		dadIcon.setPosition(strumLine.width / 2, -500);
		bfIcon.setPosition(830, dadIcon.y);

		strumLineCam = new FlxObject(0, 0);
		strumLineCam.screenCenter(X);

		// code from the playstate so I can separate the camera and hud
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		FlxG.camera.follow(strumLineCam);

		bpmTxt = new FlxText(5, FlxG.height - 30, 0, "", 16);
		bpmTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		FlxG.mouse.useSystemCursor = true; // Use system cursor because it's prettier
		FlxG.mouse.visible = true; // Hide mouse on start
	}

	var hitSoundsPlayed:Array<Note> = [];

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			if (songMusic.playing)
			{
				songMusic.pause();
				vocals.pause();
				// playButtonAnimation('pause');
			}
			else
			{
				vocals.play();
				songMusic.play();

				// reset note tick sounds
				hitSoundsPlayed = [];

				// playButtonAnimation('play');
			}
		}

		if (FlxG.keys.justPressed.E && curSelectedNote != null)
			curSelectedNote.sustainLength += Conductor.stepCrochet;
		
		else if (FlxG.keys.justPressed.Q && curSelectedNote != null)
			curSelectedNote.sustainLength -= Conductor.stepCrochet;

		if (FlxG.keys.justPressed.ESCAPE)
			bpmTxt.visible = !bpmTxt.visible;

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(songMusic.length / 1000, 2))
			+ " - Beat: " + curBeat
			+ " - Step: " + curStep;

		var scrollSpeed:Float = 0.75;
		if (FlxG.mouse.wheel != 0)
		{
			songMusic.pause();
			vocals.pause();

			songMusic.time = Math.max(songMusic.time - (FlxG.mouse.wheel * Conductor.stepCrochet * scrollSpeed), 0);
			songMusic.time = Math.min(songMusic.time, songMusic.length);
			vocals.time = songMusic.time;
		}

		// strumline camera stuffs!
		Conductor.songPosition = songMusic.time;

		strumLine.y = getYfromStrum(Conductor.songPosition);
		strumLineCam.y = strumLine.y + (FlxG.height / 3);
		arrowGroup.y = strumLine.y;

		coolGradient.y = strumLineCam.y - (FlxG.height / 2);
		coolGrid.y = strumLineCam.y - (FlxG.height / 2);

		bfIcon.y = strumLineCam.y - (FlxG.height / 2);
		dadIcon.y = strumLineCam.y - (FlxG.height / 2);

		super.update(elapsed);

		if (FlxG.mouse.overlaps(buttonGroup))
		{
			buttonGroup.forEach(function(button:CoolAssButton)
			{
				if (FlxG.mouse.overlaps(button))
				{
					button.onClick();
				}
			});
		}

		///*
		if (FlxG.mouse.x > (fullGrid.x)
			&& FlxG.mouse.x < (fullGrid.x + fullGrid.width)
			&& FlxG.mouse.y > 0
			&& FlxG.mouse.y < (getYfromStrum(songMusic.length)))
		{
			var fakeMouseX = FlxG.mouse.x - fullGrid.x;
			dummyArrow.x = (Math.floor((fakeMouseX) / gridSize) * gridSize) + fullGrid.x;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / gridSize) * gridSize;

			// moved this in here for the sake of not dying
			if (FlxG.mouse.justPressed)
			{
				if (!FlxG.mouse.overlaps(curRenderedNotes))
				{
					// add note funny
					var noteStrum = getStrumTime(dummyArrow.y);

					var notesSection = Math.floor(noteStrum / (Conductor.stepCrochet * 16));
					var noteData = adjustSide(Math.floor((dummyArrow.x - fullGrid.x) / gridSize), _song.notes[notesSection].mustHitSection);
					var noteSus = 0; // ninja you will NOT get away with this

					//noteCleanup(notesSection, noteStrum, noteData);
					//_song.notes[notesSection].sectionNotes.push([noteStrum, noteData, noteSus]);

					generateChartNote(noteData, noteStrum, noteSus, 0, notesSection);

					//updateSelection(_song.notes[notesSection].sectionNotes[_song.notes[notesSection].sectionNotes.length - 1], notesSection, true);
					//isPlacing = true;
				}

				else
				{
					curRenderedNotes.forEachAlive(function(note:Note)
					{
						if (FlxG.mouse.overlaps(note))
						{
							if (FlxG.keys.pressed.CONTROL)
							{
								curSelectedNote = note;
							}

							else
							{
								// delete the epic note
								//var notesSection = getSectionfromY(note.y);
								// persona 3 mass destruction
								//destroySustain(note, notesSection);

								//noteCleanup(notesSection, note.strumTime, note.rawNoteData);

								note.kill();
								curRenderedNotes.remove(note);
								deleteNote(note);
								note.destroy();
								//
							}
						}
						// lol
					});
				}
			}
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			songPosition = songMusic.time;

			PlayState.SONG = _song;
			ForeverTools.killMusic([songMusic, vocals]);
			Main.switchState(this, new PlayState());
		}
	}

	function deleteNote(note:Note)
	{
		var data:Null<Int> = note.noteData;

		var noteStrum = getStrumTime(dummyArrow.y);
		var curSection = Math.floor(noteStrum / (Conductor.stepCrochet * 16));

		if (data > -1 && note.mustPress != _song.notes[curSection].mustHitSection)
			data += 4;

		if (data > -1)
		{
			for (i in _song.notes[curSection].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] == data)
				{
					FlxG.log.add('FOUND EVIL NUMBER');
					_song.notes[curSection].sectionNotes.remove(i);
					break;
				}
			}
		}
	}

	override public function stepHit() 
	{
		// call all rendered notes lol
		curRenderedNotes.forEach(function(epicNote:Note)
		{
			if ((epicNote.y > (strumLineCam.y - (FlxG.height / 2) - epicNote.height))
				|| (epicNote.y < (strumLineCam.y + (FlxG.height / 2))))
			{
				epicNote.alive = true;
				epicNote.visible = true;
				// do epic note calls for strum stuffs
				if (Math.floor(Conductor.songPosition / Conductor.stepCrochet) == Math.floor(epicNote.strumTime / Conductor.stepCrochet)
					&& (!hitSoundsPlayed.contains(epicNote)))
				{
					hitSoundsPlayed.push(epicNote);
				}
			} 
			
			else 
			{
				epicNote.alive = false;
				epicNote.visible = false;
			}
		});

		super.stepHit();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, 0, (songMusic.length / Conductor.stepCrochet) * gridSize, 0, songMusic.length);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, songMusic.length, 0, (songMusic.length / Conductor.stepCrochet) * gridSize);
	}

	var fullGrid:FlxTiledSprite;

	function generateGrid()
	{
		// create new sprite
		var base:FlxSprite = FlxGridOverlay.create(gridSize, gridSize, gridSize * 2, gridSize * 2, true, FlxColor.WHITE, FlxColor.BLACK);
		fullGrid = new FlxTiledSprite(null, gridSize * keysTotal, gridSize);
		// base graphic change data
		var newAlpha = (26 / 255);
		base.graphic.bitmap.colorTransform(base.graphic.bitmap.rect, new ColorTransform(1, 1, 1, newAlpha));
		fullGrid.loadGraphic(base.graphic);
		fullGrid.screenCenter(X);

		// fullgrid height
		fullGrid.height = (songMusic.length / Conductor.stepCrochet) * gridSize;

		add(fullGrid);
	}

	public var sectionLineGraphic:FlxGraphic;
	public var sectionCameraGraphic:FlxGraphic;
	public var sectionStepGraphic:FlxGraphic;

	function regenerateSection(section:Int, placement:Float)
	{
		// this will be used to regenerate a box that shows what section the camera is focused on

		// oh and section information lol
		var sectionLine:FlxSprite = new FlxSprite(FlxG.width / 2 - (gridSize * (keysTotal / 2)) - (extraSize / 2), placement);
		sectionLine.frames = sectionLineGraphic.imageFrame;
		sectionLine.alpha = (88 / 255);

		// section camera
		var sectionExtend:Float = 0;
		if (_song.notes[section].mustHitSection)
			sectionExtend = (gridSize * (keysTotal / 2));

		var sectionCamera:FlxSprite = new FlxSprite(FlxG.width / 2 - (gridSize * (keysTotal / 2)) + (sectionExtend), placement);
		sectionCamera.frames = sectionCameraGraphic.imageFrame;
		sectionCamera.alpha = (88 / 255);
		curRenderedSections.add(sectionCamera);

		// set up section numbers
		for (i in 0...2)
		{
			var sectionNumber:FlxText = new FlxText(0, sectionLine.y - 12, 0, Std.string(section), 20);
			// set the x of the section number
			sectionNumber.x = sectionLine.x - sectionNumber.width - 5;
			if (i == 1)
				sectionNumber.x = sectionLine.x + sectionLine.width + 5;

			sectionNumber.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE);
			sectionNumber.antialiasing = false;
			sectionNumber.alpha = sectionLine.alpha;
			curRenderedSections.add(sectionNumber);
		}

		for (i in 1...Std.int(_song.notes[section].lengthInSteps / 4))
		{
			// create a smaller section stepper
			var sectionStep:FlxSprite = new FlxSprite(FlxG.width / 2 - (gridSize * (keysTotal / 2)) - (extraSize / 2),
				placement + (i * (gridSize * 4)));
			sectionStep.frames = sectionStepGraphic.imageFrame;
			sectionStep.alpha = sectionLine.alpha;
			curRenderedSections.add(sectionStep);
		}

		curRenderedSections.add(sectionLine);
	}

	var sectionsMax = 0;

	function generateNotes()
	{
		// GENERATING THE GRID NOTES!
		curRenderedNotes.clear();
		curRenderedSustains.clear();

		//sectionsMax = 1;
		generateSection();
		for (section in 0..._song.notes.length)
		{
			sectionsMax = section;
			regenerateSection(section, 16 * gridSize * section);

			for (i in _song.notes[section].sectionNotes)
			{
				// note stuffs
				var daNoteAlt:Float = 0;
				if (i.length > 2)
					daNoteAlt = i[3];

				generateChartNote(i[1], i[0], i[2], daNoteAlt, section, false);
			}
			
		}
		// lolll
		//sectionsMax--;
	}

	var extraSize = 6;

	function generateSection() { 
		// pregenerate assets so it doesnt destroy your ram later
		sectionLineGraphic = FlxG.bitmap.create(gridSize * keysTotal + extraSize, 2, FlxColor.WHITE);
		sectionCameraGraphic = FlxG.bitmap.create(Std.int(gridSize * (keysTotal / 2)), 16 * gridSize, FlxColor.fromRGB(43, 116, 219));
		sectionStepGraphic = FlxG.bitmap.create(gridSize * keysTotal + extraSize, 1, FlxColor.WHITE);
	}

	function loadSong(daSong:String):Void
	{
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();

		songMusic = new FlxSound().loadEmbedded(Paths.inst(daSong), false, true);
		if (_song.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong), false, true);
		else
			vocals = new FlxSound();
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		songMusic.play();
		vocals.play();

		if (curSong == _song)
			songMusic.time = songPosition;
		curSong = _song;
		songPosition = 0;

		pauseMusic();

		songMusic.onComplete = function()
		{
			ForeverTools.killMusic([songMusic, vocals]);
			loadSong(daSong);
		};
		//
	}

	function generateChartNote(daNoteInfo, daStrumTime, daSus, daNoteAlt:Float, noteSection, ?shouldPush:Bool = true)
	{
		var note:Note = ForeverAssets.generateArrow(PlayState.assetModifier, daStrumTime, daNoteInfo % 4, 0, false, null);
		// I love how there's 3 different engines that use this exact same variable name lmao
		note.rawNoteData = daNoteInfo;
		note.sustainLength = daSus;
		note.setGraphicSize(gridSize, gridSize);
		note.updateHitbox();

		note.screenCenter(X);
		note.x -= ((gridSize * (keysTotal / 2)) - (gridSize / 2));
		note.x += Math.floor(adjustSide(daNoteInfo, _song.notes[noteSection].mustHitSection) * gridSize);
		note.mustPress = _song.notes[noteSection].mustHitSection;
		note.y = Math.floor(getYfromStrum(daStrumTime));

		if (shouldPush)
		{
			_song.notes[noteSection].sectionNotes.push([daStrumTime, (daNoteInfo + 4) % 8, daSus, NORMAL]);
			curSelectedNote = note;
		}

		curRenderedNotes.add(note);
		generateSustain(daStrumTime, daNoteInfo, daSus, daNoteAlt, note);
	}

	function generateSustain(daStrumTime:Float = 0, daNoteInfo:Int = 0, daSus:Float = 0, daNoteAlt:Float = 0, note:Note)
	{
		/*
			if (daSus > 0)
			{
				//prevNote = note;
				var constSize = Std.int(gridSize / 3);

				var sustainVis:Note = new Note(daStrumTime + (Conductor.stepCrochet * daSus) + Conductor.stepCrochet, daNoteInfo % 4, daNoteAlt, prevNote, true);
				sustainVis.setGraphicSize(constSize,
					Math.floor(FlxMath.remapToRange((daSus / 2) - constSize, 0, Conductor.stepCrochet * verticalSize, 0, gridSize * verticalSize)));
				sustainVis.updateHitbox();
				sustainVis.x = note.x + constSize;
				sustainVis.y = note.y + (gridSize / 2);

				var sustainEnd:Note = new Note(daStrumTime + (Conductor.stepCrochet * daSus) + Conductor.stepCrochet, daNoteInfo % 4, daNoteAlt, sustainVis, true);
				sustainEnd.setGraphicSize(constSize, constSize);
				sustainEnd.updateHitbox();
				sustainEnd.x = sustainVis.x;
				sustainEnd.y = note.y + (sustainVis.height) + (gridSize / 2);

				// loll for later
				sustainVis.rawNoteData = daNoteInfo;
				sustainEnd.rawNoteData = daNoteInfo;

				curRenderedSustains.add(sustainVis);
				curRenderedSustains.add(sustainEnd);
				//

				// set the note at the current note map
				curNoteMap.set(note, [sustainVis, sustainEnd]);
			}
		 */
	}

	///*
	var coolGrid:FlxBackdrop;
	var coolGradient:FlxSprite;

	function generateBackground()
	{
		coolGrid = new FlxBackdrop(null, 1, 1, true, true, 1, 1);
		coolGrid.loadGraphic(Paths.image('UI/forever/base/chart editor/grid'));
		coolGrid.alpha = (32 / 255);
		add(coolGrid);

		// gradient
		coolGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(188, 158, 255, 200), FlxColor.fromRGB(80, 12, 108, 255), 16));
		coolGradient.alpha = (32 / 255);
		add(coolGradient);
	}

	function generateButtons():Void
	{
		buttonGroup.clear();
		buttonTextGroup.clear();

		var void:Void -> Void = null;

		for (i in buttonArray)
		{
			if (i != null)
			{
				switch (i[2].toLowerCase())
				{
					case 'load song':
						void = function()
						{
							loadSong(_song.song);
							FlxG.resetState();
						};

					default:
						void = i[6];
				}

				var button:CoolAssButton = new CoolAssButton(i[0], i[1], i[5], void);
				button.child = i[4];
				buttonGroup.add(button);

				var text:AbsoluteText = new AbsoluteText(i[2], i[3], button);
				text.scrollFactor.set();
				buttonTextGroup.add(text);
			}
		}
	}


	function adjustSide(noteData:Int, sectionTemp:Bool)
	{
		return (sectionTemp ? ((noteData + 4) % 8) : noteData);
	}

	function pauseMusic()
	{
		songMusic.time = Math.max(songMusic.time, 0);
		songMusic.time = Math.min(songMusic.time, songMusic.length);

		resyncVocals();
		songMusic.pause();
		vocals.pause();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		songMusic.play();
		Conductor.songPosition = songMusic.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}
}
