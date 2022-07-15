package dependency;

import flixel.FlxSprite;

class BaseButton extends FlxSprite
{
    public var clickThing:Void -> Void;
    public var size:String = "";
    public var child(default, set):String;

    public function new(x:Float, y:Float, size:String = "", ?clickThing:Void -> Void)
    {
        super(x, y);

        this.clickThing = clickThing;
        this.size = size;

        loadGraphic(Paths.image('UI/default/base/charter/charting_button${size.toUpperCase()}'));
        antialiasing = true;
        scrollFactor.set();
    }

    public function set_child(value:String):String
    {
        child = value;
        return child;
    }

    public function onClick(?value:Dynamic):Void
    {
        if (clickThing != null)
            clickThing();
    }
}

class CoolAssButton extends BaseButton
{
    public function new(x:Float, y:Float, size:String = "", ?clickThing:Void -> Void)
    {
        super(x, y, size, clickThing);
    }

    override public function onClick(?value:Dynamic)
    {
        if (value != null)
            child = value;    
        
        super.onClick();
    }
}