package dragonBones.objects  {


    import dragonBones.objects.ArmatureData;

    import loom2d.math.Point;




    public class SkeletonData {


        public var name:String;

        private var _subTexturePivots:Dictionary.<String, Point>;

        private var _armatureDataList:Vector.<ArmatureData>;




        public function SkeletonData() {

            _armatureDataList = new Vector.<ArmatureData>();
            _subTexturePivots = new Dictionary.<String, Point>();
        }


        public function get armatureNames():Vector.<String>
        {
            var nameList:Vector.<String> = new Vector.<String>;
            for each(var armatureData:ArmatureData in _armatureDataList)
            {
                nameList.push(armatureData.name);
            }
            return nameList;
        }


        public function get armatureDataList():Vector.<ArmatureData>
        {
            return _armatureDataList;
        }


        public function dispose():void
        {
            for each(var armatureData:ArmatureData in _armatureDataList)
            {
                armatureData.dispose();
            }

            _armatureDataList.clear();
            _subTexturePivots.clear();
            _armatureDataList = null;
            _subTexturePivots = null;
        }

        public function getArmatureData(armatureName:String):ArmatureData {

            for(var i:int=0; i<_armatureDataList.length; i++){

                if(_armatureDataList[i].name == armatureName)
                    return _armatureDataList[i];
            }

            return null;
        }

        public function addArmatureData(armatureData:ArmatureData):void {

            if(!armatureData) {
                //throw new ArgumentError();
            }

            if(_armatureDataList.indexOf(armatureData) < 0) {
                _armatureDataList.push(armatureData);
                //_armatureDataList.setFixed();

            } else {

                //throw new ArgumentError();
            }
        }

        public function removeArmatureData(armatureData:ArmatureData):void
        {
            var index:int = int(_armatureDataList.indexOf(armatureData));
            if(index >= 0)
            {
                _armatureDataList.splice(index, 1);
                //_armatureDataList.setFixed();
            }
        }

        public function removeArmatureDataByName(armatureName:String):void
        {
            var i:int = int(_armatureDataList.length);
            while(i --)
            {
                if(_armatureDataList[i].name == armatureName)
                {
                    _armatureDataList.splice(i, 1);
                    //_armatureDataList.setFixed();
                }
            }
        }

        public function getSubTexturePivot(subTextureName:String):Point
        {
            var p:Point = _subTexturePivots[subTextureName] as Point;
            return p;
        }

        public function addSubTexturePivot(x:Number, y:Number, subTextureName:String):Point
        {
            //var point:Point = _subTexturePivots[subTextureName] as Point;
            var point:Point = new Point();
            if(_subTexturePivots[subTextureName]) {
                point.x = x;
                point.y = y;

            } else {

                _subTexturePivots[subTextureName] = point = new Point(x, y);
            }

            return point;
        }

        public function removeSubTexturePivot(subTextureName:String):void
        {
            if(subTextureName)
            {
                _subTexturePivots.deleteKey(subTextureName);
                //delete _subTexturePivots[subTextureName];
            }
            else
            {
                for(subTextureName in _subTexturePivots)
                {
                    _subTexturePivots.deleteKey(subTextureName);
                    //delete _subTexturePivots[subTextureName];
                }
            }
        }
    }
}
