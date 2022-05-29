package meta.state.charting;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxStrip;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUITabMenu;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import gameObjects.userInterface.menu.DebugUI.UIBox;
import gameObjects.userInterface.menu.DebugUI;
import gameObjects.userInterface.notes.Note;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import lime.media.vorbis.VorbisFile;
import meta.MusicBeat.MusicBeatState;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.media.Sound;
#if desktop
import sys.thread.Thread;
#end

/**
	This is just code I stole from gedehari, he's a really cool guy. Here's a link to the source.
	https://github.com/gedehari/HaxeFlixel-Waveform-Rendering
	This is only used to test waveforms, I'm going to write my own code based on this later
**/
class TestState extends MusicBeatState
{
	var UI_box:FlxUITabMenu;

	override public function create()
	{
		super.create();
		FlxG.mouse.useSystemCursor = false;
		FlxG.mouse.visible = true;

		generateBackground();


		/*
		var groupOfItems:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>();
		add(groupOfItems);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'}
		];

		var baseBox = new FlxUI9SliceSprite(0, 0, Paths.image('UI/forever/base/chart editor/box_ui'), new Rectangle(0, 0, 200, 200), [10, 10, 90, 90]);
		UI_box = new FlxUITabMenu(baseBox, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = 916;
		UI_box.y = 160;
		add(UI_box);
		*/

		// var tab_group_section = new UIBox(null, UI_box);
		// tab_group_section.name = 'Section';
	}

	private function generateBackground()
	{
		var coolGrid = new FlxBackdrop(null, 1, 1, true, true, 1, 1);
		coolGrid.loadGraphic(Paths.image('UI/forever/base/chart editor/grid'));
		coolGrid.alpha = (32 / 255);
		add(coolGrid);

		// gradient
		var coolGradient = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height,
			FlxColor.gradient(FlxColor.fromRGB(188, 158, 255, 200), FlxColor.fromRGB(80, 12, 108, 255), 16));
		coolGradient.alpha = (32 / 255);
		add(coolGradient);
	}
}
