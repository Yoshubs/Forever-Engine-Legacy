package meta.data.dependency;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;

class FNFUIState extends FlxUIState
{
	override function create()
	{
		// state stuffs
		// just noticed i had to add 0.4s for make it act like trans in
		if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new FNFTransition(1.1, true));

		super.create();
	}
}
