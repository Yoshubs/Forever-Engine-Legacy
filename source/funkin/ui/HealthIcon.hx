package funkin.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;

using StringTools;

class HealthIcon extends FlxSprite
{
	// rewrite using da new icon system as ninjamuffin would say it
	public var sprTracker:FlxSprite;
	public var initialWidth:Float = 0;
	public var initialHeight:Float = 0;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		updateIcon(char, isPlayer);
	}

	public function updateIcon(char:String = 'bf', isPlayer:Bool = false)
	{
		var trimmedCharacter:String = char;
		if (trimmedCharacter.contains('-'))
			trimmedCharacter = trimmedCharacter.substring(0, trimmedCharacter.indexOf('-'));

		var iconPath = char;
		if (!FileSystem.exists(Paths.getPath('images/icons/icon-' + iconPath + '.png', IMAGE)))
		{
			if (iconPath != trimmedCharacter)
				iconPath = trimmedCharacter;
			else
				iconPath = 'face';
			trace('$char icon trying $iconPath instead you fuck');
		}

		antialiasing = true;
		var iconGraphic:FlxGraphic = Paths.image('icons/icon-' + iconPath);

		if (iconGraphic.width >= 450) // 3 frames
		{
			loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 3), iconGraphic.height);
			animation.add('icon', [0, 1, 2], 0, false, isPlayer);
		}
		else if (iconGraphic.width >= 300) // 2 frames
		{
			loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 2), iconGraphic.height);
			animation.add('icon', [0, 1], 0, false, isPlayer);
		}
		else if (iconGraphic.width >= 150) // 1 frame
		{
			loadGraphic(iconGraphic, true, Std.int(iconGraphic.width / 1), iconGraphic.height);
			animation.add('icon', [0], 0, false, isPlayer);
		}
		initialWidth = width;
		initialHeight = height;

		animation.play('icon');
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
