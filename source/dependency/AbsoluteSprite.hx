package dependency;

import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * A simple absolute sprite that will only follow it's parent's positions.
 * Cannot be used for animated sprites, only for non-animated graphics only.
 */
class AbsoluteSprite extends FlxSprite
{
    public var parent:FlxObject;
    public var offsetX:Null<Float> = null;
    public var offsetY:Null<Float> = null;

    public function new(image:String, ?parent:FlxObject, ?offsetX:Float, ?offsetY:Float)
    {
        super();

        this.parent = parent;
        this.offsetX = offsetX;
        this.offsetY = offsetY;

        loadGraphic(Paths.image(image), false);

        antialiasing = true;
        scrollFactor.set();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (parent != null)
        {
            setPosition(parent.x + offsetX, parent.y + offsetY);
        }
    }
}