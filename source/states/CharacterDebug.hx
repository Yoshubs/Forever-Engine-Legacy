package states;

import base.MusicBeat.MusicBeatState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import funkin.Boyfriend;
import funkin.Character;
import funkin.Stage;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

using StringTools;

/**
	character offset editor
	this is just code from the base game
	with some tweaking here and there to make it work on forever engine
	and some other additional features
 */
 
class CharacterDebug extends MusicBeatState
{
	var _file:FileReference;

	// characters
	var bf:Boyfriend;
	var dadOpponent:Character;
	var char:Character;

	var isDad:Bool = true;
	var curCharacter:String = 'dad';

	var curAnim:Int = 0;

	var textAnim:FlxText;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [''];

	var camFollow:FlxObject;

	var ghost:Character;

	private var stageBuild:Stage;
	var curStage:String = 'stage';

	private var camGame:FlxCamera;
	private var camHUD:FlxCamera;

	var UI_box:FlxUITabMenu;

	var canOffset:Bool = false;

	var fileExt:String = 'hxs';

	public function new(curCharacter:String = 'dad', curStage:String = 'stage')
	{
		super();
		this.curCharacter = curCharacter;
		this.curStage = curStage;
	}

	override public function create()
	{
		super.create();

		FlxG.sound.music.stop();

		FlxG.mouse.visible = true;

		//camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		//FlxG.cameras.reset(camGame);
		//FlxG.cameras.add(camHUD);

		stageBuild = new Stage(curStage);
		add(stageBuild);

		if (curCharacter.startsWith('bf'))
			isDad = false;

		ghost = new Character(0, 0, curCharacter);
		ghost.debugMode = true;
		ghost.visible = false;
		add(ghost);

		if (isDad)
		{
			dadOpponent = new Character(0, 0, curCharacter);
			dadOpponent.screenCenter();
			dadOpponent.debugMode = true;
			add(dadOpponent);

			char = dadOpponent;
			dadOpponent.flipX = false;
		}
		else
		{
			bf = new Boyfriend(0, 0);
			bf.screenCenter();
			bf.debugMode = true;
			add(bf);

			char = bf;
			bf.flipX = false;
		}

		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		textAnim = new FlxText(300, 16);
		textAnim.size = 26;
		textAnim.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		textAnim.scrollFactor.set();
		add(textAnim);

		genCharOffsets();

		var tipTextArray:Array<String> =
		"==================================
		\nE/Q - Camera Zoom In/Out
		\nR - Reset Camera Zoom
		\nJKLI - Move Camera
		\nHold Shift to Move 10x faster
		\n==================================
		\nW/S - Previous/Next Animation
		\nSpace - Play Animation
		\nF - Flip Character horizontally
		\nArrow Keys - Move Character Offset
		\n==================================\n".split('\n');

		for (i in 0...tipTextArray.length - 1)
		{
			var tipText:FlxText = new FlxText(FlxG.width - 320, FlxG.height - 15 - 16 * (tipTextArray.length - i), 300, tipTextArray[i], 12);
			//tipText.cameras = [camHUD];
			tipText.setFormat(null, 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
			tipText.scrollFactor.set();
			tipText.borderSize = 1.5;
			add(tipText);
		}

		var tabs = [
			{name: 'Preferences', label: 'Preferences'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);
		//UI_box.cameras = [camHUD];
		UI_box.resize(250, 120);
		UI_box.x = FlxG.width - 275;
		UI_box.y = 25;
		UI_box.scrollFactor.set();
		add(UI_box);

		addPreferencesUI();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow);
	}

	var ghostAnimDropDown:FlxUIDropDownMenu;
	function addPreferencesUI()
	{
		var tab_group = new FlxUI(null, UI_box);
		tab_group.name = "Preferences";

		var check_offset = new FlxUICheckBox(10, 60, null, null, "Offset Mode", 100);
		check_offset.callback = function()
		{
			canOffset = !canOffset;
		};
		check_offset.checked = true;

		ghostAnimDropDown = new FlxUIDropDownMenu(10, 30, FlxUIDropDownMenu.makeStrIdLabelArray(animList, true), function(animation:String)
		{
			if (animList[0] != '' || animList[0] != null)
			{
				ghost.visible = true;
				ghost.alpha = 0.85;
				ghost.playAnim(animList[0], true);
			}
			else
			{
				ghost.visible = false;
			}
		});

		tab_group.add(new FlxText(ghostAnimDropDown.x, ghostAnimDropDown.y - 18, 0, 'Ghost Animation:'));
		tab_group.add(check_offset);
		tab_group.add(ghostAnimDropDown);
		UI_box.addGroup(tab_group);
	}

	function genCharOffsets(pushList:Bool = true):Void
	{
		var daLoop:Int = 0;

		for (anim => offsets in char.animOffsets)
		{
			var text:FlxText = new FlxText(10, 20 + (18 * daLoop), 0, anim + ": " + offsets, 15);
			text.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
			text.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
			text.scrollFactor.set();
			dumbTexts.add(text);

			if (pushList)
				animList.push(anim);

			daLoop++;

			char.setPosition(offsets[0], offsets[1]);
		}
	}

	function saveCharOffsets():Void
	{
		var result = "";

		for (anim => offsets in char.animOffsets)
		{
			var text = 'addOffset("' + anim + '", ' + offsets.join(", ") + ');';
			result += text + "\n";
		}

		if ((result != null) && (result.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(result.trim(), curCharacter + "Offsets." + fileExt);
		}
	}

	/**
	 * Called when the save file dialog is completed.
	 */
	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved OFFSET DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the offset data.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Offset data");
	}

	function updateTexts():Void
	{
		dumbTexts.forEach(function(text:FlxText)
		{
			text.kill();
			dumbTexts.remove(text, true);
		});
	}

	override function update(elapsed:Float)
	{
		textAnim.text = char.animation.curAnim.name;
		ghost.flipX = char.flipX;

		if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.ESCAPE) {
			FlxG.mouse.visible = false;
			Main.switchState(this, new PlayState());
		}

		if (FlxG.keys.justPressed.R)
		{
			FlxG.camera.zoom = 1;
		}

		if (FlxG.keys.pressed.E && FlxG.camera.zoom < 3)
		{
			FlxG.camera.zoom += elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom > 3)
				FlxG.camera.zoom = 3;
		}
		if (FlxG.keys.pressed.Q && FlxG.camera.zoom > 0.1)
		{
			FlxG.camera.zoom -= elapsed * FlxG.camera.zoom;
			if (FlxG.camera.zoom < 0.1)
				FlxG.camera.zoom = 0.1;
		}

		if (FlxG.keys.justPressed.F) {
			char.flipX = !char.flipX;
		}

		if (FlxG.keys.pressed.I || FlxG.keys.pressed.J || FlxG.keys.pressed.K || FlxG.keys.pressed.L)
		{
			var addToCam:Float = 500 * elapsed;
			if (FlxG.keys.pressed.SHIFT)
				addToCam *= 4;

			if (FlxG.keys.pressed.I)
				camFollow.y -= addToCam;
			else if (FlxG.keys.pressed.K)
				camFollow.y += addToCam;

			if (FlxG.keys.pressed.J)
				camFollow.x -= addToCam;
			else if (FlxG.keys.pressed.L)
				camFollow.x += addToCam;
		}

		if (canOffset)
		{
			if (FlxG.keys.justPressed.W)
				updateAnimation(-1);
			else if (FlxG.keys.justPressed.S)
				updateAnimation(1);

			if (FlxG.keys.justPressed.S || FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE)
			{
				char.playAnim(animList[curAnim]);
				ghost.playAnim(animList[curAnim]);

				updateTexts();
				genCharOffsets(false);
			}
		}

		var upP = FlxG.keys.anyJustPressed([UP]);
		var rightP = FlxG.keys.anyJustPressed([RIGHT]);
		var downP = FlxG.keys.anyJustPressed([DOWN]);
		var leftP = FlxG.keys.anyJustPressed([LEFT]);

		var holdShift = FlxG.keys.pressed.SHIFT;
		var multiplier = 1;
		if (holdShift)
			multiplier = 10;

		if (upP || rightP || downP || leftP)
		{
			updateTexts();
			if (upP) {
				char.animOffsets.get(animList[curAnim])[1] += 1 * multiplier;
			}
			if (downP) {
				char.animOffsets.get(animList[curAnim])[1] -= 1 * multiplier;
			}
			if (leftP) {
				char.animOffsets.get(animList[curAnim])[0] += 1 * multiplier;
			}
			if (rightP) {
				char.animOffsets.get(animList[curAnim])[0] -= 1 * multiplier;
			}

			updateTexts();
			genCharOffsets(false);

			ghost.setPosition(char.x, char.y);
			char.playAnim(animList[curAnim]);
			ghost.playAnim(animList[curAnim]);
		}

		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.S)
			saveCharOffsets();

		super.update(elapsed);
	}

	function updateAnimation(hey:Int)
	{
		curAnim += hey;

		if (curAnim < 0)
			curAnim = animList.length;
		if (curAnim >= animList.length)
			curAnim = 0;
	}
}