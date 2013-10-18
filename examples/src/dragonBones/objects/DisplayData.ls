package dragonBones.objects {

    import loom2d.math.Point;
    import dragonBones.objects.DBTransform;


    final public class DisplayData {


        public static const ARMATURE:String = "armature";
        public static const IMAGE:String = "image";

        public var name:String;
        public var type:String;
        public var transform:DBTransform;
        public var pivot:Point;


        public function DisplayData() {

            transform = new DBTransform();
        }

        public function dispose():void {

            transform = null;
        }
    }
}
