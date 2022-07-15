package funkin;

import dependency.FNFSprite;

/**
	Create the note splashes in week 7 whenever you get a sick!
**/
class NoteSplash extends FNFSprite
{
	public function new(noteData:Int)
	{
		super(x, y);
		visible = false;
		alpha = 0.6;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// kill the note splash if it's done
		if (animation.finished)
		{
			// set the splash to invisible
			if (visible)
				visible = false;
		}
		//
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0)
	{
		// make sure the animation is visible
		if (!Init.trueSettings.get('Disable Note Splashes'))
			visible = true;

		super.playAnim(AnimName, Force, Reversed, Frame);
	}
}
