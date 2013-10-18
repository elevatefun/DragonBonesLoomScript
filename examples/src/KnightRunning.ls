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

            group.registerManager(WorldClock.clock, WorldClock, 'WorldClock');

            factory = new LoomFactory();
            factory.onParseComplete += setupKnight;
            factory.parseData('texture', 'assets/Knight/texture.xml', 'assets/Knight/skeleton.xml');

        }

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

        public function onFrame():void {
            WorldClock.clock.advanceTime(-1);
        }

    }
}

