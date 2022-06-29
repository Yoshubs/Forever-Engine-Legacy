package gameObjects;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.OverlayShader;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import gameObjects.background.*;
import meta.CoolUtil;
import meta.data.ChartParser;
import meta.data.Conductor;
import meta.data.dependency.FNFSprite;
import openfl.display.BlendMode;
import openfl.display.BlendModeEffect;
import openfl.display.GraphicsShader;
import openfl.filters.ShaderFilter;
import states.PlayState;

using StringTools;

/**
	This is the stage class. It sets up everything you need for stages in a more organised and clean manner than the
	base game. It's not too bad, just very crowded. I'll be adding stages as a separate
	thing to the weeks, making them not hardcoded to the songs.
**/
class Stage extends FlxTypedGroup<FlxBasic>
{
	// week 2
	var halloweenBG:FNFSprite;

	// week 3
	var phillyCityLights:FlxTypedGroup<FNFSprite>;
	var phillyTrain:FNFSprite;
	var trainSound:FlxSound;

	// week 4
	public var limo:FNFSprite;
	public var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FNFSprite;

	// week 5
	var upperBoppers:FNFSprite;
	var bottomBoppers:FNFSprite;
	var santa:FNFSprite;

	// week 6
	var bgGirls:BackgroundGirls;

	// week 7
	var tankWatchtower:FNFSprite;
	var tankGround:FNFSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	//

	public var gfVersion:String = 'gf';

	public var curStage:String;

	var daPixelZoom = PlayState.daPixelZoom;

	public var foreground:FlxTypedGroup<FlxBasic>;

	public function new(curStage)
	{
		super();
		this.curStage = curStage;

		switch (ChartParser.songType)
		{
			case FNF:
				// placeholder
			case FNF_LEGACY:
				/// get hardcoded stage type if chart is fnf style
				// this is because I want to avoid editing the fnf chart type
				// custom stage stuffs will come with forever charts
				switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
				{
					case 'spookeez' | 'south' | 'monster':
						curStage = 'spooky';
					case 'pico' | 'blammed' | 'philly-nice':
						curStage = 'philly';
					case 'milf' | 'satin-panties' | 'high':
						curStage = 'highway';
					case 'cocoa' | 'eggnog':
						curStage = 'mall';
					case 'winter-horrorland':
						curStage = 'mallEvil';
					case 'senpai' | 'roses':
						curStage = 'school';
					case 'thorns':
						curStage = 'schoolEvil';
					case 'ugh' | 'guns' | 'stress':
						curStage = 'military';
					default:
						curStage = 'stage';
				}

				PlayState.curStage = curStage;

			case UNDERSCORE | PSYCH | FOREVER:
				if(curStage == null || curStage.length < 1)
				{
					// get hardcoded values *if* the chart json has no data on it for them
					switch (CoolUtil.spaceToDash(PlayState.SONG.song.toLowerCase()))
					{
						case 'spookeez' | 'south' | 'monster':
							curStage = 'spooky';
						case 'pico' | 'blammed' | 'philly-nice':
							curStage = 'philly';
						case 'milf' | 'satin-panties' | 'high':
							curStage = 'highway';
						case 'cocoa' | 'eggnog':
							curStage = 'mall';
						case 'winter-horrorland':
							curStage = 'mallEvil';
						case 'senpai' | 'roses':
							curStage = 'school';
						case 'thorns':
							curStage = 'schoolEvil';
						case 'ugh' | 'guns' | 'stress':
							curStage = 'military';
						default:
							curStage = 'stage';
					}
				}
				PlayState.curStage = PlayState.SONG.stage;
		}

		// to apply to foreground use foreground.add(); instead of add();
		foreground = new FlxTypedGroup<FlxBasic>();

		//
		switch (curStage)
		{
			case 'philly':
				curStage = 'philly';

				var bg:FNFSprite = new FNFSprite(-100).loadGraphic(Paths.image('backgrounds/' + curStage + '/sky'));
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				var city:FNFSprite = new FNFSprite(-10).loadGraphic(Paths.image('backgrounds/' + curStage + '/city'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<FNFSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FNFSprite = new FNFSprite(city.x).loadGraphic(Paths.image('backgrounds/' + curStage + '/win' + i));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				var streetBehind:FNFSprite = new FNFSprite(-40, 50).loadGraphic(Paths.image('backgrounds/' + curStage + '/behindTrain'));
				add(streetBehind);

				phillyTrain = new FNFSprite(2000, 360).loadGraphic(Paths.image('backgrounds/' + curStage + '/train'));
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				// var cityLights:FNFSprite = new FNFSprite().loadGraphic(AssetPaths.win0.png);

				var street:FNFSprite = new FNFSprite(-40, streetBehind.y).loadGraphic(Paths.image('backgrounds/' + curStage + '/street'));
				add(street);
			case 'highway':
				curStage = 'highway';
				PlayState.defaultCamZoom = 0.90;

				var skyBG:FNFSprite = new FNFSprite(-120, -50).loadGraphic(Paths.image('backgrounds/' + curStage + '/limoSunset'));
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);

				var bgLimo:FNFSprite = new FNFSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/bgLimo');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...5)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
				}

				var overlayShit:FNFSprite = new FNFSprite(-500, -600).loadGraphic(Paths.image('backgrounds/' + curStage + '/limoOverlay'));
				overlayShit.alpha = 0.5;
				// add(overlayShit);

				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

				// overlayShit.shader = shaderBullshit;

				var limoTex = Paths.getSparrowAtlas('backgrounds/' + curStage + '/limoDrive');

				limo = new FNFSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FNFSprite(-300, 160).loadGraphic(Paths.image('backgrounds/' + curStage + '/fastCarLol'));
			// loadArray.add(limo);
			case 'mall':
				curStage = 'mall';
				PlayState.defaultCamZoom = 0.80;

				var bg:FNFSprite = new FNFSprite(-1000, -500).loadGraphic(Paths.image('backgrounds/' + curStage + '/bgWalls'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				upperBoppers = new FNFSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/upperBop');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);

				var bgEscalator:FNFSprite = new FNFSprite(-1100, -600).loadGraphic(Paths.image('backgrounds/' + curStage + '/bgEscalator'));
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);

				var tree:FNFSprite = new FNFSprite(370, -250).loadGraphic(Paths.image('backgrounds/' + curStage + '/christmasTree'));
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				bottomBoppers = new FNFSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/bottomBop');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:FNFSprite = new FNFSprite(-600, 700).loadGraphic(Paths.image('backgrounds/' + curStage + '/fgSnow'));
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				add(fgSnow);

				santa = new FNFSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/santa');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				add(santa);
			case 'mallEvil':
				curStage = 'mallEvil';
				var bg:FNFSprite = new FNFSprite(-400, -500).loadGraphic(Paths.image('backgrounds/mall/evilBG'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FNFSprite = new FNFSprite(300, -300).loadGraphic(Paths.image('backgrounds/mall/evilTree'));
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FNFSprite = new FNFSprite(-200, 700).loadGraphic(Paths.image("backgrounds/mall/evilSnow"));
				evilSnow.antialiasing = true;
				add(evilSnow);
			case 'school':
				curStage = 'school';

				// defaultCamZoom = 0.9;

				var bgSky = new FNFSprite().loadGraphic(Paths.image('backgrounds/' + curStage + '/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FNFSprite = new FNFSprite(repositionShit, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FNFSprite = new FNFSprite(repositionShit).loadGraphic(Paths.image('backgrounds/' + curStage + '/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var fgTrees:FNFSprite = new FNFSprite(repositionShit + 170, 130).loadGraphic(Paths.image('backgrounds/' + curStage + '/weebTreesBack'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var bgTrees:FNFSprite = new FNFSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('backgrounds/' + curStage + '/weebTrees');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FNFSprite = new FNFSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/petals');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (PlayState.SONG.song.toLowerCase() == 'roses')
					bgGirls.getScared();

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			case 'schoolEvil':
				var posX = 400;
				var posY = 200;
				var bg:FNFSprite = new FNFSprite(posX, posY);
				bg.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/animatedEvilSchool');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);
			case 'military':
				curStage = 'military';
				PlayState.defaultCamZoom = 0.9;
				
				var sky:FNFSprite = new FNFSprite(-400, -400).loadGraphic(Paths.image('backgrounds/' + curStage + '/tankSky'));
				sky.scrollFactor.set(0, 0);
				add(sky);

				var tankCloudX:Int;
				var tankCloudY:Int;

				tankCloudX = FlxG.random.int(-700, -100);
				tankCloudY = FlxG.random.int(-20, 20);

				var clouds:FNFSprite = new FNFSprite(tankCloudX, tankCloudY).loadGraphic(Paths.image('backgrounds/' + curStage + '/tankClouds'));
				clouds.scrollFactor.set(0.1, 0.1);
				clouds.active = true;
				clouds.velocity.x = FlxG.random.float(5, 15);
				add(clouds);
						
				var mountains:FNFSprite = new FNFSprite(300, -20).loadGraphic(Paths.image('backgrounds/' + curStage + '/tankMountains'));
				mountains.scrollFactor.set(0.2, 0.2);
				mountains.setGraphicSize(Std.int(mountains.width * 1.2));
				mountains.updateHitbox();
				add(mountains);
						
				var buildings:FNFSprite = new FNFSprite(-200, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/tankBuildings'));
				buildings.scrollFactor.set(0.3, 0.3);
				buildings.setGraphicSize(Std.int(buildings.width * 1.1));
				buildings.updateHitbox();
				add(buildings);
						
				var ruins:FNFSprite = new FNFSprite(-200, 0).loadGraphic(Paths.image('backgrounds/' + curStage + '/tankRuins'));
				ruins.scrollFactor.set(0.35, 0.35);
				ruins.setGraphicSize(Std.int(ruins.width * 1.1));
				ruins.updateHitbox();
				add(ruins);

				var smokeL:FNFSprite = new FNFSprite(-200, -100);
				smokeL.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/smokeLeft');
				smokeL.animation.addByPrefix('smokeLeft', 'SmokeBlurLeft');
				smokeL.antialiasing = true;
				smokeL.scrollFactor.set(0.4, 0.4);
				add(smokeL);

				var smokeR:FNFSprite = new FNFSprite(1100, -100);
				smokeR.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/smokeRight');
				smokeR.animation.addByPrefix('smokeRight', 'SmokeRight');
				smokeR.antialiasing = true;
				smokeR.scrollFactor.set(0.4, 0.4);
				add(smokeR);

				tankWatchtower = new FNFSprite(100, 50);
				tankWatchtower.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/tankWatchtower');
				tankWatchtower.animation.addByPrefix('watchtower', 'watchtower gradient color');
				tankWatchtower.antialiasing = true;
				tankWatchtower.scrollFactor.set(0.5, 0.5);
				add(tankWatchtower);

				tankGround = new FNFSprite(300, 300);
				tankGround.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/tankRolling');
				tankGround.animation.addByPrefix('bgTank', 'BG tank w lighting');
				tankGround.antialiasing = true;
				tankGround.scrollFactor.set(0.5, 0.5);
				add(tankGround);
						
				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);
						
				var ground:FNFSprite = new FNFSprite(-420, -150).loadGraphic(Paths.image('backgrounds/' + curStage + '/tankGround'));
				ground.setGraphicSize(Std.int(ground.width * 1.15));
				ground.updateHitbox();
				add(ground);
				moveTank();

				var tankdude0:FNFSprite = new FNFSprite(-500, 650);
				tankdude0.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/tank0');
				tankdude0.animation.addByPrefix('fg', 'fg');
				tankdude0.antialiasing = true;
				tankdude0.scrollFactor.set(1.7, 1.5);
				foreground.add(tankdude0);

				var tankdude1:FNFSprite = new FNFSprite(-300, 750);
				tankdude1.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/tank1');
				tankdude1.animation.addByPrefix('fg', 'fg');
				tankdude1.antialiasing = true;
				tankdude1.scrollFactor.set(2, 0.2);
				foreground.add(tankdude1);	

				var tankdude2:FNFSprite = new FNFSprite(450, 940);
				tankdude2.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/tank2');
				tankdude2.animation.addByPrefix('fg', 'foreground');
				tankdude2.antialiasing = true;
				tankdude2.scrollFactor.set(1.5, 1.5);
				foreground.add(tankdude2);

				var tankdude4:FNFSprite = new FNFSprite(1300, 900);
				tankdude4.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/tank4');
				tankdude4.animation.addByPrefix('fg', 'fg');
				tankdude4.antialiasing = true;
				tankdude4.scrollFactor.set(1.5, 1.5);
				foreground.add(tankdude4);

				var tankdude5:FNFSprite = new FNFSprite(1620, 700);
				tankdude5.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/tank5');
				tankdude5.animation.addByPrefix('fg', 'fg');
				tankdude5.antialiasing = true;
				tankdude5.scrollFactor.set(1.5, 1.5);
				foreground.add(tankdude5);

				var tankdude3:FNFSprite = new FNFSprite(1300, 1200);
				tankdude3.frames = Paths.getSparrowAtlas('backgrounds/' + curStage + '/tank3');
				tankdude3.animation.addByPrefix('fg', 'fg');
				tankdude3.antialiasing = true;
				tankdude3.scrollFactor.set(3.5, 2.5);
				foreground.add(tankdude3);
		}

		var stageScript:SScript = new SScript(Paths.getPreloadPath('stages/$curStage.hxs'));
		stageScript.set('createGraphic', function(id:String, x:Float, y:Float, 
			size:Float = 1, scrollX:Float, scrollY:Float, image:String, foreground:Bool = false)
		{
			var madeGraphic:FNFSprite = new FNFSprite(x, y).loadGraphic(Paths.image(image));
			madeGraphic.setGraphicSize(Std.int(madeGraphic.width * size));
			madeGraphic.scrollFactor.set(scrollX, scrollY);
			madeGraphic.updateHitbox();
			madeGraphic.antialiasing = true;
			PlayState.GraphicMap.set(id, madeGraphic);

			if (foreground)
				foreground.add(madeGraphic);
			else
				add(madeGraphic);
		});
	
		stageScript.set('createAnimatedGraphic', function(id:String, x:Float, y:Float, 
			size:Float, scrollX:Float, scrollY:Float, image:String,
			anims:Array<Array<Dynamic>>, defaultAnim:String, foreground:Bool = false)
		{
			var madeGraphic:FNFSprite = new FNFSprite(x, y);
			madeGraphic.frames = Paths.getSparrowAtlas(image);

			for (anim in anims)
			{
				madeGraphic.animation.addByPrefix(anim[0], anim[1], anim[3], anim[4]);
			}

			madeGraphic.setGraphicSize(Std.int(madeGraphic.width * size));
			madeGraphic.scrollFactor.set(scrollOne, scrollTwo);
			madeGraphic.updateHitbox();
			madeGraphic.scrollFactor.set(scrollX, scrollY);
			madeGraphic.animation.play(defaultAnim);
			madeGraphic.antialiasing = true;
			PlayState.GraphicMap.set(id, madeGraphic);
			if (foreground)
				foreground.add(madeGraphic);
			else
				add(madeGraphic);
		});

		stageScript.set('addOffsetByID', function(id:String, anim:String, x:Float, y:Float)
		{
			var getSprite:FNFSprite = PlayState.GraphicMap.get(id);
			getSprite.addOffset(anim, x, y);
		});

		stageScript.set('configStage', function(daStage:String = 'stage', desiredZoom:Float = 1.05)
		{
			curStage = daStage;
			PlayState.defaultCamZoom = desiredZoom;
		});

		stageScript.set('curStage', curStage);

		stageScript.execute();
	}

	// return the girlfriend's type
	public function returnGFtype(curStage)
	{
		switch (curStage)
		{
			case 'highway':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'ugh' | 'guns':
				gfVersion = 'gf-tankmen';
			case 'stress':
				gfVersion = 'pico-speaker';
		}
		
		return gfVersion;
	}

	// get the dad's position
	public function dadPosition(curStage, boyfriend:Character, dad:Character, gf:Character, camPos:FlxPoint):Void
	{
		var characterArray:Array<Character> = [dad, boyfriend];
		for (char in characterArray) {
			switch (char.curCharacter)
			{
				case 'gf':
					char.setPosition(gf.x, gf.y);
					gf.visible = false;
				/*
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
				}*/
				/*
				case 'spirit':
					var evilTrail = new FlxTrail(char, null, 4, 24, 0.3, 0.069);
					evilTrail.changeValuesEnabled(false, false, false, false);
					add(evilTrail);
					*/
			}
		}
	}

	public function repositionPlayers(curStage, boyfriend:Character, dad:Character, gf:Character):Void
	{
		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'highway':
				boyfriend.y -= 220;
				boyfriend.x += 260;

			case 'mall':
				boyfriend.x += 200;
				dad.x -= 400;
				dad.y += 20;

			case 'mallEvil':
				boyfriend.x += 320;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				dad.x += 200;
				dad.y += 580;
				gf.x += 200;
				gf.y += 320;
			case 'schoolEvil':
				dad.x -= 150;
				dad.y += 50;
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;

			case "military":
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;
				if (gfVersion != 'pico-speaker')
				{
					gf.x -= 170;
					gf.y -= 75;
				}
		}
	}

	var curLight:Int = 0;
	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var startedMoving:Bool = false;

	public function stageUpdate(curBeat:Int, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		// trace('update backgrounds');
		switch (PlayState.curStage)
		{
			case 'highway':
				// trace('highway update');
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});
			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'school':
				bgGirls.dance();

			case 'philly':
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					var lastLight:FlxSprite = phillyCityLights.members[0];

					phillyCityLights.forEach(function(light:FNFSprite)
					{
						// Take note of the previous light
						if (light.visible == true)
							lastLight = light;

						light.visible = false;
					});

					// To prevent duplicate lights, iterate until you get a matching light
					while (lastLight == phillyCityLights.members[curLight])
					{
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
					}

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;

					FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.stepCrochet * .016);
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'stress':
				gf.x -= 50;
				gf.y -= 200;
				var tankmen:TankmenBG = new TankmenBG(20, 500, true);
				tankmen.strumTime = 10;
				tankmen.resetShit(20, 600, true);
				tankmanRun.add(tankmen);
				for (i in 0...TankmenBG.animationNotes.length)
				{
					if (FlxG.random.bool(16))
					{
						var man:TankmenBG = tankmanRun.recycle(TankmenBG);
						man.strumTime = TankmenBG.animationNotes[i][0];
						man.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
						tankmanRun.add(man);
					}
				}
		}
	}

	public function stageUpdateConstant(elapsed:Float, boyfriend:Boyfriend, gf:Character, dadOpponent:Character)
	{
		switch (PlayState.curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos(gf);
						trainFrameTiming = 0;
					}
				}
			case 'military':
				moveTank();
		}
	}

	// PHILLY STUFFS!
	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	function updateTrainPos(gf:Character):Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset(gf);
		}
	}

	function trainReset(gf:Character):Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	function moveTank():Void
	{
		tankAngle += tankSpeed * FlxG.elapsed;
		tankGround.angle = (tankAngle - 90 + 15);
		tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
		tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
	}

	override function add(Object:FlxBasic):FlxBasic
	{
		if (Init.trueSettings.get('Disable Antialiasing') && Std.isOfType(Object, FlxSprite))
			cast(Object, FlxSprite).antialiasing = false;
		return super.add(Object);
	}
}
