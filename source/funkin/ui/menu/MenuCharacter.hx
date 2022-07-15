package funkin.ui.menu;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String = '';

	var curCharacterMap:Map<String, Array<Dynamic>> = [
		// the format is currently
		// name of character => id in atlas, fps, loop, scale, offsetx, offsety
		'bf' => ["BF idle dance white", 24, true, 0.9, 100, 100],
		'bfConfirm' => ['BF HEY!!', 24, false, 0.9, 100, 100],
		'gf' => ["GF Dancing Beat WHITE", 24, true, 1, 100, 100],
		'dad' => ["Dad idle dance BLACK LINE", 24, true, 1 * 0.5, 0, 0],
		'spooky' => ["spooky dance idle BLACK LINES", 24, true, 1 * 0.5, 0, 90],
		'pico' => ["Pico Idle Dance", 24, true, 1 * 0.5, 0, 100],
		'mom' => ["Mom Idle BLACK LINES", 24, true, 1 * 0.5, 0, -30],
		'parents-christmas' => ["Parent Christmas Idle", 24, true, 0.8, -100, 50],
		'senpai' => ["SENPAI idle Black Lines", 24, true, 1.4 * 0.5, -50, 100],
		'tankman' => ["Tankman Menu BLACK", 24, true, 1 * 0.5, 0, 80],
	];

	var baseX:Float = 0;
	var baseY:Float = 0;

	public function new(x:Float, newCharacter:String = 'bf')
	{
		super(x);
		y += 70;

		baseX = x;
		baseY = y;

		createCharacter(newCharacter);
		updateHitbox();
	}

	public function createCharacter(newCharacter:String, canChange:Bool = false)
	{
		var tex = Paths.getSparrowAtlas('menus/base/storymenu/campaign_menu_UI_characters');
		frames = tex;
		var assortedValues = curCharacterMap.get(newCharacter);
		if (assortedValues != null)
		{
			if (!visible)
				visible = true;

			// animation
			animation.addByPrefix(newCharacter, assortedValues[0], assortedValues[1], assortedValues[2]);
			// if (character != newCharacter)
			animation.play(newCharacter);

			if (canChange)
			{
				// offset
				setGraphicSize(Std.int(width * assortedValues[3]));
				updateHitbox();
				setPosition(baseX + assortedValues[4], baseY + assortedValues[5]);

				if (newCharacter == 'pico')
					flipX = true;
				else
					flipX = false;
			}
		}
		else
			visible = false;

		character = newCharacter;
	}
}
