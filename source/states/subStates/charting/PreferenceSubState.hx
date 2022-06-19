package states.subStates.charting;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatSubState;

class PreferenceSubState extends MusicBeatSubState
{
	//
	private var blackTopBar:FlxSprite;
	private var blackBottomBar:FlxSprite;

	private var topText:FlxText;

	private var purpleTopBar:FlxSprite;
	private var purpleBottomBar:FlxSprite;

	private var background:FlxSprite;

	private var closing = false;

	public function new(camera:FlxCamera)
	{
		super();

		//
		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		background.alpha = 0;
		add(background);

		blackTopBar = new FlxSprite(0, -75).makeGraphic(FlxG.width, 75, FlxColor.BLACK);
		add(blackTopBar);
		topText = new FlxText(blackTopBar.x + 15, blackTopBar.y + 15, 'PREFERENCES MENU');
		topText.setFormat(Paths.font("vcr.ttf"), 24);
		add(topText);
		blackBottomBar = new FlxSprite(0, FlxG.height).makeGraphic(FlxG.width, 75, FlxColor.BLACK);
		add(blackBottomBar);

		//
		purpleTopBar = new FlxSprite(blackTopBar.x, blackTopBar.y + 60).makeGraphic(FlxG.width, 8, FlxColor.fromRGB(81, 0, 130));
		add(purpleTopBar);

		purpleBottomBar = new FlxSprite(blackBottomBar.x, blackBottomBar.y + 9).makeGraphic(FlxG.width, 8, FlxColor.fromRGB(81, 0, 130));
		add(purpleBottomBar);

		//
		blackTopBar.cameras = [camera];
		blackBottomBar.cameras = [camera];
		topText.cameras = [camera];
		background.cameras = [camera];

		purpleBottomBar.cameras = [camera];
		purpleTopBar.cameras = [camera];
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		blackTopBar.y = FlxMath.lerp(0, blackTopBar.y, 0.75);
		blackBottomBar.y = FlxMath.lerp(FlxG.height - blackBottomBar.height, blackBottomBar.y, 0.75);
		topText.y = blackTopBar.y + 15;

		purpleTopBar.y = blackTopBar.y + 60;
		purpleBottomBar.y = blackBottomBar.y + 9;

		background.alpha = FlxMath.lerp(150 / 255, background.alpha, 0.75);
	}
}
