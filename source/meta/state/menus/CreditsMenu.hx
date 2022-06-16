package meta.state.menus;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.AbsoluteSprite;
import meta.data.dependency.Discord;
import meta.data.font.Alphabet;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

typedef CreditsData =
{
    data:Array<Dynamic>,
    name:String,
    icon:String,
    desc:String,
    quote:String,
    url:String, // this should be an array so we can add multiple socials later
    color:Array<FlxColor>,
    offsetX:Int,
    offsetY:Int,
    size:Float,
    menuBG:String,
}

class CreditsMenu extends MusicBeatState
{
    var alfabe:FlxTypedGroup<Alphabet>;
    var menuBG:FlxSprite = new FlxSprite();
    var menuBGTween:FlxTween;
    var desc:FlxText;

    var curSelected:Int;
    
    var creditStuff:Array<Dynamic> = [];
    var icons:Array<AbsoluteSprite> = [];
    var creditsData:CreditsData;
    
    override function create()
    {
        super.create();

        // make sure the music is playing
        ForeverTools.resetMenuMusic();

        creditsData = Json.parse(Paths.getTextFromFile('credits.json'));

        //if (fileExists)
            creditStuff = creditsData.data;
        //else
        //    creditStuff = [["ERROR", 'error', "AN ERROR HAS OCURRED", " - PLEASE CHECK YOUR CREDITS JSON FILE!.", "", [255, 255, 255], -180, 0]];
        
        #if !html5
        Discord.changePresence('MENU SCREEN', 'Credits Menu');
        #end

        if (creditsData.menuBG != null && creditsData.menuBG.length > 0)
			menuBG.loadGraphic(Paths.image(creditsData.menuBG));
		else
			menuBG.loadGraphic(Paths.image('menus/base/menuDesat'));

        menuBG.antialiasing = true;
        menuBG.screenCenter();
        menuBG.color = FlxColor.WHITE;
        add(menuBG);
        
        alfabe = new FlxTypedGroup<Alphabet>();
        add(alfabe);

        for (i in 0...creditStuff.length)
        {
            var alphabet:Alphabet = new Alphabet(0, 70 * i, creditStuff[i][0], !isSelectable(i));
            alphabet.isMenuItem = true;
            alphabet.itemType = "Centered";
            alphabet.screenCenter(X);
            alphabet.targetY = i;
            alfabe.add(alphabet);
            
            var curIcon = 'credits/${creditStuff[i][1]}';
            if (creditStuff[i][1] == '' || creditStuff[i][1] == null) curIcon = 'credits/error';
            
            var icon:AbsoluteSprite = new AbsoluteSprite(curIcon, alphabet, creditStuff[i][6], creditStuff[i][7]);
            if (creditStuff[i][8] != null) icon.setGraphicSize(Std.int(icon.width * creditStuff[i][8]));
            icons.push(icon);
            //icon.updateHitbox();
            add(icon);
        }
        
        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
        textBG.alpha = 0.6;
        add(textBG);
        
        desc = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "", 18);
        desc.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER);
        desc.scrollFactor.set();
        add(desc);
        
        changeSelection();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (controls.UI_UP_P) 
            changeSelection(-1);

        if (controls.UI_DOWN_P) 
            changeSelection(1);

        if (controls.BACK) 
            Main.switchState(this, new MainMenuState());

        if (controls.ACCEPT && isSelectable(curSelected) && creditStuff[curSelected][4] != null
            && creditStuff[curSelected][4] != '') 
            CoolUtil.browserLoad(creditStuff[curSelected][4]);
    }
    
    public function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        
        curSelected += change;
        
        if (curSelected < 0)
            curSelected = creditStuff.length - 1;
        
        if (curSelected >= creditStuff.length)
            curSelected = 0;
        
        var bullShit:Int = 0;
        var color:FlxColor = FlxColor.fromRGB(creditStuff[curSelected][5][0],
            creditStuff[curSelected][5][1], creditStuff[curSelected][5][2]);
            
        if (menuBGTween != null)
            menuBGTween.cancel();
        
        if (color != menuBG.color)
        {
            menuBGTween = FlxTween.color(menuBG, 0.35, menuBG.color, color,
            {
                onComplete: function(tween:FlxTween)
                    menuBGTween = null
            });
        }
        
        desc.text = creditStuff[curSelected][2];
        if (creditStuff[curSelected][3] != null && creditStuff[curSelected][3].length >= 0) desc.text += ' - "' + creditStuff[curSelected][3] + '"';
        
        for (item in alfabe.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;
            
            item.alpha = 0.6;
            
            if (!isSelectable(bullShit - 1))
                item.alpha = 1;
            
            if (item.targetY == 0)
            {
                item.alpha = 1;
            }
        }
    }
    
    public function isSelectable(id:Int):Bool
        return creditStuff[id].length > 1;
}