package states.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import states.menus.*;

class TestMenu extends MusicBeatState
{
    var alphabet:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;

    var text:Array<Dynamic> = [
        ['Pong'],
        ['Snake'],
        ['Tetris']
    ];

    var menuBG:FlxSprite;

    override function create()
    {
        super.create();

		#if DISCORD_RPC
		Discord.changePresence('MENU SCREEN', 'Test Menu');
		#end

        menuBG = new FlxSprite();
        menuBG.loadGraphic(Paths.image('menus/base/menuDesat'));
        menuBG.antialiasing = true;
        menuBG.screenCenter();
        menuBG.color = FlxColor.GRAY;
        add(menuBG);

        alphabet = new FlxTypedGroup<Alphabet>();
        add(alphabet);

        for (i in 0...text.length)
        {
			var leText:Alphabet = new Alphabet(0, (70 * i) + 30, text[i][0].split('-').join(' '), true, false);
            leText.isMenuItem = true;
            leText.targetY = i;
            alphabet.add(leText);
        }

        updateSelection();
    }

    override function update(elapsed:Float)
    {
        if (controls.UI_UP_P)
            updateSelection(-1);
        if (controls.UI_DOWN_P)
            updateSelection(1);
        if (controls.BACK)
            Main.switchState(this, new MainMenuState());
    }
    
    private function updateSelection(hey:Int = 0)
    {
        curSelected += hey;

		if (curSelected < 0)
			curSelected = text.length - 1;
		if (curSelected >= text.length)
			curSelected = 0;

		var bullShit:Int = 0;
		for (item in alphabet.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
    }
}