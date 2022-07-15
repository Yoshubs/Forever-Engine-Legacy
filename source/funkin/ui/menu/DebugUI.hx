package funkin.ui.menu;

import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIGroup;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.interfaces.IFlxUIButton;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxStringUtil;

/**
	HEAVILY BASED ON FLIXEL UI SHIT
	check that out lol its in the same library youre using rn
**/
class UIBox extends FlxUITabMenu
{
	public static inline var STACK_FRONT:String = "front"; // button goes in front of backing
	public static inline var STACK_BACK:String = "back"; // buton goes behind backing

	public function new(?back_:FlxSprite, ?tabs_:Array<IFlxUIButton>, ?tab_names_and_labels_:Array<{name:String, label:String}>, ?tab_offset:FlxPoint,
			?stretch_tabs:Bool = false, ?tab_spacing:Null<Float> = null, ?tab_stacking:Array<String> = null)
	{
		super();

		if (back_ == null)
		{
			// default, make this:
			back_ = new FlxUI9SliceSprite(0, 0, FlxUIAssets.IMG_CHROME_FLAT, new Rectangle(0, 0, 200, 200));
		}

		_back = back_;
		add(_back);

		if (tabs_ == null)
		{
			if (tab_names_and_labels_ != null)
			{
				tabs_ = new Array<IFlxUIButton>();

				// load default graphic data if only tab_names_and_labels are provided
				for (tdata in tab_names_and_labels_)
				{
					// set label and name
					var fb:FlxUIButton = new FlxUIButton(0, 0, tdata.label);

					// default style:
					fb.up_color = 0xffffff;
					fb.down_color = 0xffffff;
					fb.over_color = 0xffffff;
					fb.up_toggle_color = 0xffffff;
					fb.down_toggle_color = 0xffffff;
					fb.over_toggle_color = 0xffffff;

					fb.label.color = 0xFFFFFF;
					fb.label.setBorderStyle(OUTLINE);

					fb.name = tdata.name;

					// load default graphics
					var graphic_names:Array<FlxGraphicAsset> = [
						FlxUIAssets.IMG_TAB_BACK,
						FlxUIAssets.IMG_TAB_BACK,
						FlxUIAssets.IMG_TAB_BACK,
						FlxUIAssets.IMG_TAB,
						FlxUIAssets.IMG_TAB,
						FlxUIAssets.IMG_TAB
					];
					var slice9tab:Array<Int> = FlxStringUtil.toIntArray(FlxUIAssets.SLICE9_TAB);
					var slice9_names:Array<Array<Int>> = [slice9tab, slice9tab, slice9tab, slice9tab, slice9tab, slice9tab];
					fb.loadGraphicSlice9(graphic_names, 0, 0, slice9_names, FlxUI9SliceSprite.TILE_NONE, -1, true);
					tabs_.push(fb);
				}
			}
		}

		_tabs = tabs_;
		_stretch_tabs = stretch_tabs;
		_tab_spacing = tab_spacing;
		_tab_stacking = tab_stacking;
		if (_tab_stacking == null)
		{
			_tab_stacking = [STACK_FRONT, STACK_BACK];
		}
		_tab_offset = tab_offset;

		var i:Int = 0;
		var tab:FlxUITypedButton<FlxSprite> = null;
		for (t in _tabs)
		{
			tab = cast t;
			add(tab);
			tab.onUp.callback = _onTabEvent.bind(tab.name);
			i++;
		}

		distributeTabs();

		_tab_groups = new Array<FlxUIGroup>();
	}
}
