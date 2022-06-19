package states.menus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.menu.Checkmark;
import gameObjects.userInterface.menu.Selector;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;
import states.subStates.OptionsSubState;
import states.subStates.PauseSubState;

/**
	Options menu rewrite because I'm unhappy with how it was done previously
**/
class OptionsMenuState extends MusicBeatState
{
	private var categoryMap:Map<String, Dynamic>;
	private var activeSubgroup:FlxTypedGroup<Alphabet>;
	private var attachments:FlxTypedGroup<FlxBasic>;

	var curSelection = 0;
	var curSelectedScript:Void->Void;
	var curCategory:String;

	var lockedMovement:Bool = false;

	override public function create():Void
	{
		super.create();

		// define the categories
		/* 
			To explain how these will work, each main category is just any group of options, the options in the category are defined
			by the first array. The second array value defines what that option does.
			These arrays are within other arrays for information storing purposes, don't worry about that too much.
			If you plug in a value, the script will run when the option is hovered over.
		 */

		// NOTE : Make sure to check Init.hx if you are trying to add options.

		#if !html5
		Discord.changePresence('OPTIONS MENU', 'Main Menu');
		#end

		categoryMap = [
			'main' => [
				[
					['preferences', callNewGroup],
					['appearance', callNewGroup],
					['controls', openControlmenu],
					['exit', exitMenu]
				]
			],
			'preferences' => [
				[
					['Game Settings', null],
					['', null],
					['Auto Pause', getFromOption],
					['Downscroll', getFromOption],
					['Centered Notefield', getFromOption],
					['Ghost Tapping', getFromOption],
					['Display Accuracy', getFromOption],
					['Sound Type', getFromOption],
					['Hitsound Volume', getFromOption],
					['Skip Text', getFromOption],
					['', null],
					/*['Player Judgements'],
					['', null],
					['Sick! Hit Window', getFromOption],
					['Good Hit Window', getFromOption],
					['Bad Hit Window', getFromOption],
					['Shit Hit Window', getFromOption],
					['', null],*/
					['Meta Settings', null],
					['', null],
					["Framerate Cap", getFromOption],
					['FPS Counter', getFromOption],
					['Memory Counter', getFromOption],
					['Debug Info', getFromOption],
				]
			],
			'appearance' => [
				[
					['Judgements', null],
					['', null],
					["UI Skin", getFromOption],
					['Fixed Judgements', getFromOption], 
					['Simply Judgements', getFromOption],
					['Counter', getFromOption],
					['', null],
					['Notes', null],
					['', null],
					["Note Skin", getFromOption],
					["Clip Style", getFromOption],
					['No Camera Note Movement', getFromOption],
					['Disable Note Splashes', getFromOption],
					['Opaque Arrows', getFromOption],
					['Opaque Holds', getFromOption],
					['', null],
					['Accessibility Settings', null],
					['', null],
					['Filter', getFromOption],
					['Disable Antialiasing', getFromOption],
					["Stage Opacity", getFromOption],
					["Opacity Type", getFromOption],
					['Reduced Movements', getFromOption],
				]
			]
		];

		for (category in categoryMap.keys())
		{
			categoryMap.get(category)[1] = returnSubgroup(category);
			categoryMap.get(category)[2] = returnExtrasMap(categoryMap.get(category)[1]);
		}

		// make sure the music is playing
		ForeverTools.resetMenuMusic();

		// call the options menu
		var bg = new FlxSprite(-85);
		bg.loadGraphic(Paths.image('menus/base/menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xCE64DF;
		bg.antialiasing = true;
		add(bg);

		infoText = new FlxText(5, FlxG.height - 24, 0, "", 32);
		infoText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		infoText.textField.background = true;
		infoText.textField.backgroundColor = FlxColor.BLACK;
		add(infoText);

		loadSubgroup('main');
	}

	private var currentAttachmentMap:Map<Alphabet, Dynamic>;

	function loadSubgroup(subgroupName:String)
	{
		// unlock the movement
		lockedMovement = false;

		// lol we wanna kill infotext so it goes over checkmarks later
		if (infoText != null)
			remove(infoText);

		// kill previous subgroup attachments
		if (attachments != null)
			remove(attachments);

		// kill previous subgroup if it exists
		if (activeSubgroup != null)
			remove(activeSubgroup);

		// load subgroup lmfao
		activeSubgroup = categoryMap.get(subgroupName)[1];
		add(activeSubgroup);

		// set the category
		curCategory = subgroupName;

		// add all group attachments afterwards
		currentAttachmentMap = categoryMap.get(subgroupName)[2];
		attachments = new FlxTypedGroup<FlxBasic>();
		for (setting in activeSubgroup)
			if (currentAttachmentMap.get(setting) != null)
				attachments.add(currentAttachmentMap.get(setting));
		add(attachments);

		// re-add
		add(infoText);
		regenInfoText();

		// reset the selection
		curSelection = 0;
		selectOption(curSelection);
	}

	function selectOption(newSelection:Int, playSound:Bool = true)
	{
		if ((newSelection != curSelection) && (playSound))
			FlxG.sound.play(Paths.sound('scrollMenu'));

		// direction increment finder
		var directionIncrement = ((newSelection < curSelection) ? -1 : 1);

		// updates to that new selection
		curSelection = newSelection;

		// wrap the current selection
		if (curSelection < 0)
			curSelection = activeSubgroup.length - 1;
		else if (curSelection >= activeSubgroup.length)
			curSelection = 0;

		// set the correct group stuffs lol
		for (i in 0...activeSubgroup.length)
		{
			activeSubgroup.members[i].alpha = 0.6;
			if (currentAttachmentMap != null)
				setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[i]), 0.6);
			activeSubgroup.members[i].targetY = (i - curSelection) / 2;
			activeSubgroup.members[i].xTo = 200 + ((i - curSelection) * 25);

			// check for null members and hardcode the dividers
			if (categoryMap.get(curCategory)[0][i][1] == null) {
				activeSubgroup.members[i].alpha = 1;
				activeSubgroup.members[i].xTo += Std.int((FlxG.width / 2) - ((activeSubgroup.members[i].text.length / 2) * 40)) - 200;
			}
		}

		activeSubgroup.members[curSelection].alpha = 1;
		if (currentAttachmentMap != null)
			setAttachmentAlpha(currentAttachmentMap.get(activeSubgroup.members[curSelection]), 1);

		// what's the script of the current selection?
		for (i in 0...categoryMap.get(curCategory)[0].length)
			if (categoryMap.get(curCategory)[0][i][0] == activeSubgroup.members[curSelection].text)
				curSelectedScript = categoryMap.get(curCategory)[0][i][1];
		// wow thats a dumb check lmao

		// skip line if the selected script is null (indicates line break)
		if (curSelectedScript == null)
			selectOption(curSelection + directionIncrement, false);
	}

	function setAttachmentAlpha(attachment:FlxSprite, newAlpha:Float)
	{
		// oddly enough, you can't set alphas of objects that arent directly and inherently defined as a value.
		// ya flixel is weird lmao
		if (attachment != null)
			attachment.alpha = newAlpha;
		// therefore, I made a script to circumvent this by defining the attachment with the `attachment` variable!
		// pretty neat, huh?
	}

	var infoText:FlxText;
	var finalText:String;
	var textValue:String = '';
	var infoTimer:FlxTimer;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// just uses my outdated code for the main menu state where I wanted to implement
		// hold scrolling but I couldnt because I'm dumb and lazy
		if (!lockedMovement)
		{
			// check for the current selection
			if (curSelectedScript != null)
				curSelectedScript();

			updateSelections();
		}

		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			// lol had to set this or else itd tell me expected }
			var currentSetting = Init.gameSettings.get(activeSubgroup.members[curSelection].text);
			var textValue = currentSetting[2];
			if (textValue == null)
				textValue = "";

			if (finalText != textValue)
			{
				// trace('call??');
				// trace(textValue);
				regenInfoText();

				var textSplit = [];
				finalText = textValue;
				textSplit = finalText.split("");

				var loopTimes = 0;
				infoTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
				{
					//
					infoText.text += textSplit[loopTimes];
					infoText.screenCenter(X);

					loopTimes++;
				}, textSplit.length);
			}
		}

		// move the attachments if there are any
		for (setting in currentAttachmentMap.keys())
		{
			if ((setting != null) && (currentAttachmentMap.get(setting) != null))
			{
				var thisAttachment = currentAttachmentMap.get(setting);
				thisAttachment.x = setting.x - 100;
				thisAttachment.y = setting.y - 50;
			}
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));

			if (curCategory != 'main') {
				loadSubgroup('main');
			} else if (PauseSubState.toOptions) {
					PlayState.resetMusic();
					Main.switchState(this, new PlayState());
				} else {
					Main.switchState(this, new MainMenuState());
				}
		}
	}

	private function regenInfoText()
	{
		if (infoTimer != null)
			infoTimer.cancel();
		if (infoText != null)
			infoText.text = "";
	}

	function updateSelections()
	{
		var up = controls.UI_UP;
		var down = controls.UI_DOWN;
		var up_p = controls.UI_UP_P;
		var down_p = controls.UI_DOWN_P;
		var controlArray:Array<Bool> = [up, down, up_p, down_p];

		if (controlArray.contains(true))
		{
			for (i in 0...controlArray.length)
			{
				// here we check which keys are pressed
				if (controlArray[i] == true)
				{
					// if single press
					if (i > 1)
					{
						// up is 2 and down is 3
						// paaaaaiiiiiiinnnnn
						if (i == 2)
							selectOption(curSelection - 1);
						else if (i == 3)
							selectOption(curSelection + 1);
					}
				}
				//
			}
		}
	}

	private function returnSubgroup(groupName:String):FlxTypedGroup<Alphabet>
	{
		//
		var newGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();

		for (i in 0...categoryMap.get(groupName)[0].length)
		{
			if (Init.gameSettings.get(categoryMap.get(groupName)[0][i][0]) == null
				|| Init.gameSettings.get(categoryMap.get(groupName)[0][i][0])[3] != Init.FORCED)
			{
				var thisOption:Alphabet = new Alphabet(0, 0, categoryMap.get(groupName)[0][i][0], true, false);
				thisOption.screenCenter();
				thisOption.y += (90 * (i - Math.floor(categoryMap.get(groupName)[0].length / 2)));
				thisOption.targetY = i;
				thisOption.disableX = true;
				// hardcoded main so it doesnt have scroll
				if (groupName != 'main')
					thisOption.isMenuItem = true;
				thisOption.alpha = 0.6;
				newGroup.add(thisOption);
			}
		}

		return newGroup;
	}

	private function returnExtrasMap(alphabetGroup:FlxTypedGroup<Alphabet>):Map<Alphabet, Dynamic>
	{
		var extrasMap:Map<Alphabet, Dynamic> = new Map<Alphabet, Dynamic>();
		for (letter in alphabetGroup)
		{
			if (Init.gameSettings.get(letter.text) != null)
			{
				switch (Init.gameSettings.get(letter.text)[1])
				{
					case Init.SettingTypes.Checkmark:
						// checkmark
						var checkmark = ForeverAssets.generateCheckmark(10, letter.y, 'checkboxThingie', 'base', 'default', 'UI');
						checkmark.playAnim(Std.string(Init.trueSettings.get(letter.text)) + ' finished');

						extrasMap.set(letter, checkmark);
					case Init.SettingTypes.Selector:
						// selector
						var selector:Selector = new Selector(10, letter.y, letter.text, Init.gameSettings.get(letter.text)[4],
							(letter.text == 'Framerate Cap') ? true : false,
							(letter.text == 'Stage Opacity') ? true : false,
							(letter.text == 'Sick! Hit Window') ? true : false,
							(letter.text == 'Good Hit Window') ? true : false,
							(letter.text == 'Bad Hit Window') ? true : false,
							(letter.text == 'Shit Hit Window') ? true : false,
							(letter.text == 'Hitsound Volume') ? true : false);

						extrasMap.set(letter, selector);
					default:
						// dont do ANYTHING
				}
				//
			}
		}

		return extrasMap;
	}

	/*
		This is the base option return
	 */
	public function getFromOption()
	{
		if (Init.gameSettings.get(activeSubgroup.members[curSelection].text) != null)
		{
			switch (Init.gameSettings.get(activeSubgroup.members[curSelection].text)[1])
			{
				case Init.SettingTypes.Checkmark:
					// checkmark basics lol
					if (controls.ACCEPT)
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));
						lockedMovement = true;
						FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
						{
							// LMAO THIS IS HUGE
							Init.trueSettings.set(activeSubgroup.members[curSelection].text,
								!Init.trueSettings.get(activeSubgroup.members[curSelection].text));
							updateCheckmark(currentAttachmentMap.get(activeSubgroup.members[curSelection]),
								Init.trueSettings.get(activeSubgroup.members[curSelection].text));

							// save the setting
							Init.saveSettings();
							lockedMovement = false;
						});
					}
				case Init.SettingTypes.Selector:
					#if !html5
					var selector:Selector = currentAttachmentMap.get(activeSubgroup.members[curSelection]);

					if (!controls.UI_LEFT)
						selector.selectorPlay('left');
					if (!controls.UI_RIGHT)
						selector.selectorPlay('right');

					if (controls.UI_RIGHT_P)
						updateSelector(selector, 1);
					else if (controls.UI_LEFT_P)
						updateSelector(selector, -1);
					#end
				default:
					// none
			}
		}
	}

	function updateCheckmark(checkmark:FNFSprite, animation:Bool) {
		if (checkmark != null)
			checkmark.playAnim(Std.string(animation));
	}

	function updateSelector(selector:Selector, updateBy:Int)
	{
		var fps = selector.fpsCap;
		var bgdark = selector.darkBG;
		var sickhw = selector.sickHW;
		var goodhw = selector.goodHW;
		var badhw = selector.badHW;
		var shithw = selector.shitHW;
		var hitVol = selector.hitVol;

		if (fps)
		{
			// bro I dont even know if the engine works in html5 why am I even doing this
			// lazily hardcoded fps cap
			var originalFPS = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 15 * updateBy;
			if (originalFPS + increase < 30)
				increase = 0;
			// high fps cap
			if (originalFPS + increase > 360)
				increase = 0;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			originalFPS += increase;
			selector.chosenOptionString = Std.string(originalFPS);
			selector.optionChosen.text = Std.string(originalFPS);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, originalFPS);
			Init.saveSettings();
		}
		else if (bgdark)
		{
			// lazily hardcoded darkness cap
			var originaldark = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 5 * updateBy;
			if (originaldark + increase < 0)
				increase = 0;
			// high darkness cap
			if (originaldark + increase > 100)
				increase = 0;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			originaldark += increase;
			selector.chosenOptionString = Std.string(originaldark);
			selector.optionChosen.text = Std.string(originaldark);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, originaldark);
			Init.saveSettings();
		}
		else if (sickhw)
		{
			// lazily hardcoded sick hit window cap
			var ogMil = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 1 * updateBy;
			if (ogMil + increase < 5)
				increase = 5;
			// high hit window cap
			if (ogMil + increase > 55)
				increase = 5;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			ogMil += increase;
			selector.chosenOptionString = Std.string(ogMil);
			selector.optionChosen.text = Std.string(ogMil);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, ogMil);
			Init.saveSettings();
		}
		else if (goodhw)
		{
			// lazily hardcoded good hit window cap
			var ogMil = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 1 * updateBy;
			if (ogMil + increase < 5)
				increase = 5;
			// high hit window cap
			if (ogMil + increase > 80)
				increase = 5;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			ogMil += increase;
			selector.chosenOptionString = Std.string(ogMil);
			selector.optionChosen.text = Std.string(ogMil);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, ogMil);
			Init.saveSettings();
		}
		else if (badhw)
		{
			// lazily hardcoded bad hit window cap
			var ogMil = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 1 * updateBy;
			if (ogMil + increase < 5)
				increase = 5;
			// high hit window cap
			if (ogMil + increase > 135)
				increase = 5;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			ogMil += increase;
			selector.chosenOptionString = Std.string(ogMil);
			selector.optionChosen.text = Std.string(ogMil);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, ogMil);
			Init.saveSettings();
		}
		else if (shithw)
		{
			// lazily hardcoded shit hit window cap
			var ogMil = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 1 * updateBy;
			if (ogMil + increase < 5)
				increase = 5;
			// high hit window cap
			if (ogMil + increase > 160)
				increase = 5;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			ogMil += increase;
			selector.chosenOptionString = Std.string(ogMil);
			selector.optionChosen.text = Std.string(ogMil);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, ogMil);
			Init.saveSettings();
		}
		else if (hitVol)
		{
			// lazily hardcoded hitsound volume
			var originalSV = Init.trueSettings.get(activeSubgroup.members[curSelection].text);
			var increase = 5 * updateBy;
			if (originalSV + increase < 0)
				increase = 0;
			// high hitsound volume cap
			if (originalSV + increase > 100)
				increase = 0;

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			originalSV += increase;
			selector.chosenOptionString = Std.string(originalSV);
			selector.optionChosen.text = Std.string(originalSV);
			Init.trueSettings.set(activeSubgroup.members[curSelection].text, originalSV);
			Init.saveSettings();
		}
		else if (!fps && !bgdark && !sickhw && !goodhw && !badhw && !shithw && !hitVol)
		{ 
			// get the current option as a number
			var storedNumber:Int = 0;
			var newSelection:Int = storedNumber;
			if (selector.options != null) {
				for (curOption in 0...selector.options.length)
				{
					if (selector.options[curOption] == selector.optionChosen.text)
						storedNumber = curOption;
				}
				
				newSelection = storedNumber + updateBy;
				if (newSelection < 0)
					newSelection = selector.options.length - 1;
				else if (newSelection >= selector.options.length)
					newSelection = 0;
			}

			if (updateBy == -1)
				selector.selectorPlay('left', 'press');
			else
				selector.selectorPlay('right', 'press');

			FlxG.sound.play(Paths.sound('scrollMenu'));

			selector.chosenOptionString = selector.options[newSelection];
			selector.optionChosen.text = selector.chosenOptionString;

			Init.trueSettings.set(activeSubgroup.members[curSelection].text, selector.chosenOptionString);
			Init.saveSettings();
		}
	}

	public function callNewGroup()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				loadSubgroup(activeSubgroup.members[curSelection].text);
			});
		}
	}

	public function openControlmenu()
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				openSubState(new OptionsSubState());
				lockedMovement = false;
			});
		}
	}

	public function exitMenu()
	{
		//
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			lockedMovement = true;
			FlxFlicker.flicker(activeSubgroup.members[curSelection], 0.5, 0.06 * 2, true, false, function(flick:FlxFlicker)
			{
				if (PauseSubState.toOptions) {
					PlayState.resetMusic();
					Main.switchState(this, new PlayState());
				} else {
					Main.switchState(this, new MainMenuState());
				}
				lockedMovement = false;
			});
		}
		//
	}
}
