# DragonBones for LoomScript

DragonBones Library, LoomScript Version

Version 1.0
Port Author: Elevate Entertainment

---

### Example


    package
    {
        import loom.Application;
        import loom2d.display.StageScaleMode;
        import loom2d.display.Image;
        import loom2d.display.Sprite;
        import loom2d.textures.Texture;
        import loom.gameframework.IAnimated;

        import dragonBones.factories.LoomFactory;
        import dragonBones.Armature;
        import dragonBones.animation.WorldClock;

        public class KnightRunning extends Application implements IAnimated
        {

            public var factory:LoomFactory;
            public var armature:Armature;

            override public function run():void
            {

                // Comment out this line to turn off automatic scaling.
                stage.scaleMode = StageScaleMode.LETTERBOX;

                var bg = new Image(Texture.fromAsset("assets/bg.png"));
                bg.width = stage.stageWidth;
                bg.height = stage.stageHeight;
                stage.addChild(bg);

                // Register the WorldClock to advance through all the Armatures
                group.registerManager(WorldClock.clock, WorldClock, 'WorldClock');

                factory = new LoomFactory();

                // We use a delegate here instead of the AS3 addEventListener
                factory.onParseComplete += setupKnight;

                // The Flash version supports bytecode embedded in the image sheets
                // and JSON texture data. Loom TextureAtlases only support XML.
                // The skeleton data, however, does support JSON.
                factory.parseData('texture', 'assets/Knight/texture.xml', 'assets/Knight/skeleton.xml');

            }

            // Once parsed, we use the data to build the Armature
            public function setupKnight():void {

                armature = factory.buildArmature('Knight');
                var armatureClip:Sprite = armature.display as Sprite;
                armatureClip.pivotX = armatureClip.width * 0.5;
                armatureClip.pivotY = armatureClip.height;
                armatureClip.x = 330;
                armatureClip.y = 300;
                stage.addChild(armatureClip);
                armature.animation.gotoAndPlay('run');

                WorldClock.clock.add(armature);

            }

            // onFrame is called because this class implements IAnimated
            public function onFrame():void {

                // Passing in -1 allows the WorldClock to use TimeManager.platformTime
                WorldClock.clock.advanceTime(-1);

            }

        }
    }

### Known "anomalies"
For some reason, assumed to be a bug in Loom or LoomScript, the project refuses
to run without a trace statement.

### Incompleted features

* Blend modes
* Color transforms
* Zipped assets
