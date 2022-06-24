package gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import flixel.FlxG;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import gameObjects.userInterface.HealthIcon;
import meta.*;
import meta.data.*;
import meta.data.dependency.FNFSprite;
import openfl.utils.Assets as OpenFlAssets;
import states.PlayState;

using StringTools;

typedef CharacterData = {
	var offsetX:Float;
	var offsetY:Float;
	var camOffsetX:Float;
	var camOffsetY:Float;
	var quickDancer:Bool;
}

class Character extends FNFSprite
{
	public var debugMode:Bool = false;

	public var character:String;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var barColor:Int;

	public var holdTimer:Float = 0;

	public var characterData:CharacterData;
	public var adjustPos:Bool = true;

	public var animationDisabled:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, ?isPlayer:Bool = false, ?character:String = 'bf')
	{
		super(x, y);
		this.isPlayer = isPlayer;
		this.character = character;
		curCharacter = character;

		barColor = isPlayer ? 0xFF66FF33 : 0xFFFF0000;

		characterData = {
			offsetY: 0,
			offsetX: 0,
			camOffsetY: 0,
			camOffsetX: 0,
			quickDancer: false
		};

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;
		}

		antialiasing = true;

		var charScript:HaxeScript = new HaxeScript(Paths.getPreloadPath('characters/$character.hxs'));
		charScript.set('addByPrefix', function(name:String, prefix:String, ?frames:Int = 24, ?loop:Bool = false)
		{
			animation.addByPrefix(name, prefix, frames, loop);
		});
		
		charScript.set('addByIndices', function(name:String, prefix:String, indices:Array<Int>, ?frames:Int = 24, ?loop:Bool = false)
		{
			animation.addByIndices(name, prefix, indices, "", frames, loop);
		});

		charScript.set('addOffset', function(?name:String = "idle", ?x:Float = 0, ?y:Float = 0)
		{
			addOffset(name, x, y);
		});

		charScript.set('set', function(name:String, value:Dynamic)
		{
			Reflect.setProperty(this, name, value);
		});

		charScript.set('setOffsets', function(x:Float, y:Float)
		{
			characterData.offsetX = x;
			characterData.offsetY = y;
		});

		charScript.set('setCamOffsets', function(x:Float, y:Float)
		{
			characterData.camOffsetX = x;
			characterData.camOffsetY = y;
		});

		charScript.set('quickDancer', function(quick:Bool)
		{
			characterData.quickDancer = bool;
		});

		charScript.set('setBarColor', function(hex:Int)
		{
			if (Init.trueSettings.get('Icon Colored Health Bar'))
				barColor = hex;
			return true;
		});

		charScript.set('get', function(variable:String)
		{
			return Reflect.getProperty(this, variable);
		});

		charScript.set('setGraphicSize', function(width:Int = 0, height:Int = 0)
		{
			setGraphicSize(width, height);
			updateHitbox();
		});

		charScript.set('setTex', function(character:String)
		{
			frames = Paths.getSparrowAtlas(character);
		});

		charScript.set('setPacker', function(character:String)
		{
			frames = Paths.getPackerAtlas(character);
		});

		charScript.set('playAnim', function(name:String, ?force:Bool = false, ?reversed:Bool = false, ?frames:Int = 0)
		{
			playAnim(name, force, reversed, frames);
		});

		charScript.execute();

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;
		}

		x += characterData.offsetX;
		trace('character ${curCharacter} scale ${scale.y}');
		y += (characterData.offsetY - (frameHeight * scale.y));

		if(animation.getByName('danceLeft') != null)
			playAnim('danceLeft');
		else
			playAnim('idle');
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer && animation.curAnim != null)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		var curCharSimplified:String = simplifyCharacter();
		
		if (animation.curAnim != null)
			switch (curCharSimplified)
			{
				case 'gf':
					if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
						playAnim('danceRight');
					if ((animation.curAnim.name.startsWith('sad')) && (animation.curAnim.finished))
						playAnim('danceLeft');
			}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?forced:Bool = false)
	{
		if (!debugMode && animation.curAnim != null)
		{
			var curCharSimplified:String = simplifyCharacter();
			switch (curCharSimplified)
			{
				case 'gf':
					if ((!animation.curAnim.name.startsWith('hair')) && (!animation.curAnim.name.startsWith('sad')))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
				default:
					// Left/right dancing, think Skid & Pump
					if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null) {
						danced = !danced;
						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
					else
						playAnim('idle', forced);
			}
		}
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (!animationDisabled)
		{
			if (animation.getByName(AnimName) != null)
				super.playAnim(AnimName, Force, Reversed, Frame);

			if (curCharacter == 'gf')
			{
				if (AnimName == 'singLEFT')
					danced = true;
				else if (AnimName == 'singRIGHT')
					danced = false;

				if (AnimName == 'singUP' || AnimName == 'singDOWN')
					danced = !danced;
			}
		}
	}

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.contains('-'))
			base = base.substring(0, base.indexOf('-'));

		return base;
	}
}
