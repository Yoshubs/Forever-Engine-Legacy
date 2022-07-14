package gameObjects;

/**
	The character class initialises any and all characters that exist within gameplay. For now, the character class will
	stay the same as it was in the original source of the game. I'll most likely make some changes afterwards though!
**/
import flixel.FlxG;
import flixel.util.FlxSort;
import flixel.addons.util.FlxSimplex;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import gameObjects.userInterface.HealthIcon;
import meta.*;
import meta.data.*;
import meta.data.Section.SwagSection;
import meta.data.dependency.FNFSprite;
import gameObjects.background.TankmenBG;
import openfl.utils.Assets as OpenFlAssets;
import states.PlayState;
import states.subStates.GameOverSubState;

using StringTools;

typedef CharacterData =
{
	var offsetX:Float;
	var offsetY:Float;
	var camOffsetX:Float;
	var camOffsetY:Float;
	var scaleX:Float;
	var scaleY:Float;
	var quickDancer:Bool;
}

class Character extends FNFSprite
{
	public var debugMode:Bool = false;
	public var skipDance:Bool = false;

	public var character:String;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	
	public var holdTimer:Float = 0;

	public var icon:String;

	public var characterData:CharacterData;
	public var adjustPos:Bool = true;

	public var animationNotes:Array<Dynamic> = [];
	public var positionArray:Array<Float> = [0, 0];
	public var barColor:Array<Float> = [];

	public function new(?x:Float = 0, ?y:Float = 0, ?isPlayer:Bool = false, ?character:String = 'bf')
	{
		super(x, y);
		this.isPlayer = isPlayer;
		this.character = character;
		curCharacter = character;

		characterData = {
			offsetY: 0,
			offsetX: 0,
			camOffsetY: 0,
			camOffsetX: 0,
			scaleX: 0,
			scaleY: 0,
			quickDancer: false
		};

		switch(curCharacter)
		{
			case 'pico-speaker':
				skipDance = true;
				loadMappedAnims();
				playAnim("shoot1");
		}

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;
		}

		antialiasing = true;

		var charScript:HaxeScript = new HaxeScript(Paths.getPreloadPath('characters/${character.toLowerCase()}/${curCharacter.toLowerCase()}.hxs'));

		//trace(charScript.interp, charScript.script);
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
			if (name == 'idle') positionArray = [x, y];
		});

		charScript.set('set', function(name:String, value:Dynamic)
		{
			Reflect.setProperty(this, name, value);
		});

		charScript.set('setOffsets', function(?x:Float = 0, ?y:Float = 0)
		{
			characterData.offsetX = x;
			characterData.offsetY = y;
		});

		charScript.set('setCamOffsets', function(?x:Float = 0, ?y:Float = 0)
		{
			characterData.camOffsetX = x;
			characterData.camOffsetY = y;
		});

		charScript.set('setScale', function(?x:Float = 1, ?y:Float = 1)
		{
			characterData.scaleX = x;
			characterData.scaleY = y;
			scale.set(characterData.scaleX, characterData.scaleY);
		});

		charScript.set('setIcon', function(swag:String = 'face') icon = swag);

		charScript.set('quickDancer', function(quick:Bool = false)
		{
			characterData.quickDancer = quick;
		});

		charScript.set('setBarColor', function(rgb:Array<Float>)
		{
			if (barColor != null)
				barColor = rgb;
			else
				barColor = [161,161,161];
			return true;
		});

		charScript.set('setDeathChar', function(char:String = 'bf-dead', lossSfx:String = 'fnf_loss_sfx',
			song:String = 'gameOver', confirmSound:String = 'gameOverEnd')
		{
			GameOverSubState.character = char;
			GameOverSubState.deathSound = lossSfx;
			GameOverSubState.deathMusic = song;
			GameOverSubState.deathConfirm = confirmSound;
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

		charScript.set('isPlayer', isPlayer);
		charScript.set('curStage', PlayState.curStage);

		charScript.execute();

		if (isPlayer) // fuck you ninjamuffin lmao
		{
			flipX = !flipX;
		}

		if (icon == null) icon = curCharacter;

		if (adjustPos)
		{
			x += characterData.offsetX;
			#if debug trace('character ${curCharacter} scale ${scale.y}'); #end
			y += (characterData.offsetY - (frameHeight * scale.y));
		}

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

		switch(curCharacter)
		{
			case 'pico-speaker':
				if(animationNotes.length > 0 && Conductor.songPosition > animationNotes[0][0])
				{
					var noteData:Int = 1;
					if(animationNotes[0][1] > 2) noteData = 3;

					noteData += FlxG.random.int(0, 1);
					playAnim('shoot' + noteData, true);
					animationNotes.shift();
				}
				if(animation.curAnim.finished) playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
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
		if (!debugMode && !skipDance && animation.curAnim != null)
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
					if (animation.getByName('danceLeft') != null && animation.getByName('danceRight') != null)
					{
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

	public function simplifyCharacter():String
	{
		var base = curCharacter;

		if (base.contains('-'))
			base = base.substring(0, base.indexOf('-'));

		return base;
	}

	function loadMappedAnims()
	{
		var sections:Array<SwagSection> = Song.loadFromJson('picospeaker', PlayState.SONG.song.toLowerCase()).notes;
		for (section in sections)
		{
			for (note in section.sectionNotes)
			{
				animationNotes.push(note);
			}
		}
		TankmenBG.animationNotes = animationNotes;
		//trace(animationNotes);
		animationNotes.sort(sortAnims);
	}

	function sortAnims(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}
}
