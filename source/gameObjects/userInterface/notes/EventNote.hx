package gameObjects.userInterface.notes;

import flixel.FlxSprite;
import meta.data.*;

class EventNote extends FlxSprite
{
    public var strumTime:Float;
    public var val1:String;
    public var val2:String;
    public var id:String;

    public var shouldExecute:Bool;
    //should always return true else it'll break
    public var onHit:Void -> Bool;

    public function new(strumTime:Float, val1:String, val2:String, id:String)
    {
        super();

        this.strumTime = strumTime;
        this.val1 = val1;
        this.val2 = val2;
        this.id = id;

        loadGraphic(Paths.image('UI/default/base/charter/eventNote'));
    }

    override function update(e:Float)
    {
        super.update(e);

        if (strumTime < 0 || onHit == null)
            return;

        if (strumTime <= Conductor.songPosition)
            shouldExecute = true;
    }

    public function set(void:Void -> Bool)
    {
		if (void == null)
            return;

        onHit = void;
        shouldExecute = false;
    }
}