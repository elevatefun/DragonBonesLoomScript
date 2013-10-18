package dragonBones.objects {


    import dragonBones.objects.SlotData;




    final public class SkinData {

        public var name:String;

        private var _slotDataList:Vector.<SlotData>;


        public function SkinData()
        {
            _slotDataList = new Vector.<SlotData>();
        }


        public function get slotDataList():Vector.<SlotData>
        {
            return _slotDataList;
        }


        public function dispose():void
        {
            var i:int = int(_slotDataList.length);
            while(i --)
            {
                _slotDataList[i].dispose();
            }
            _slotDataList.clear();
            _slotDataList = null;
        }

        public function getSlotData(slotName:String):SlotData
        {
            var i:int = int(_slotDataList.length);
            while(i --)
            {
                if(_slotDataList[i].name == slotName)
                {
                    return _slotDataList[i];
                }
            }
            return null;
        }

        public function addSlotData(slotData:SlotData):void
        {
            if(!slotData)
            {
                //throw new ArgumentError();
            }

            if (_slotDataList.indexOf(slotData) < 0)
            {
                _slotDataList.push(slotData);
            }
            else
            {
                //throw new ArgumentError();
            }
        }
    }
}
