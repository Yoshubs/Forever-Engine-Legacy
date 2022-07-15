package funkin.ui.menu;

import dependency.FNFSprite;

using StringTools;

class Checkmark extends FNFSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);
		animOffsets = new Map<String, Array<Float>>();
	}

	override public function update(elapsed:Float)
	{
		if (animation != null)
		{
			if ((animation.finished) && (animation.curAnim.name == 'true'))
				playAnim('true finished');
			if ((animation.finished) && (animation.curAnim.name == 'false'))
				playAnim('false finished');
		}

		super.update(elapsed);
	}
}
