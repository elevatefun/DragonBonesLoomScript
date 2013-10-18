package dragonBones.objects {


    import dragonBones.objects.DisplayData;


    final public class SlotData {


        public var name:String;
        public var parent:String;
        public var zOrder:Number;
        public var blendMode:String;

        private var _displayDataList:Vector.<DisplayData>;


        public function get displayDataList():Vector.<DisplayData>
        {
            return _displayDataList;
        }

        public function SlotData()
        {
            _displayDataList = new Vector.<DisplayData>();
            zOrder = 0;
            blendMode = 'normal';
        }

        public function dispose():void
        {
            var i:int = int(_displayDataList.length);
            while(i --)
            {
                _displayDataList[i].dispose();
            }
            _displayDataList.clear();
            _displayDataList = null;
        }

        public function addDisplayData(displayData:DisplayData):void
        {
            if(!displayData)
            {
                //throw new ArgumentError();
            }
            if (_displayDataList.indexOf(displayData) < 0)
            {
                _displayDataList.push(displayData);
            }
            else
            {
                //throw new ArgumentError();
            }
        }

        public function getDisplayData(displayName:String):DisplayData
        {
            var i:int = int(_displayDataList.length);
            while(i --)
            {
                if(_displayDataList[i].name == displayName)
                {
                    return _displayDataList[i];
                }
            }

            return null;
        }
    }
}
