package dragonBones.objects
{


	import dragonBones.objects.BoneData;
	import dragonBones.objects.SkinData;
	import dragonBones.objects.AnimationData;



	//  Helper class for ArmatureData class
	public class HelpBoneData {

		public var boneData:BoneData;
		public var level:int;

		public function HelpBoneData(lvl:int, data:BoneData){
			level = lvl;
			boneData = data;
		}
	}



	final public class ArmatureData {


		public var name:String;
		
		private var _boneDataList:Vector.<BoneData>;
		
		private var _skinDataList:Vector.<SkinData>;
		
		private var _animationDataList:Vector.<AnimationData>;
		

		
		public function ArmatureData() {

			_boneDataList = new Vector.<BoneData>();
			_skinDataList = new Vector.<SkinData>();
			_animationDataList = new Vector.<AnimationData>();
		}
		


		public function dispose():void {

			var i:int = int(_boneDataList.length);
			while(i --)
			{
				_boneDataList[i].dispose();
			}
			i = _skinDataList.length;
			while(i --)
			{
				_skinDataList[i].dispose();
			}
			i = _animationDataList.length;
			while(i --)
			{
				_animationDataList[i].dispose();
			}

			_boneDataList.clear();
			_skinDataList.clear();
			_animationDataList.clear();
			_boneDataList = null;
			_skinDataList = null;
			_animationDataList = null;
		}
		

		public function getBoneData(boneName:String):BoneData {

			var i:int = int(_boneDataList.length);
			while(i --)
			{
				if(_boneDataList[i].name == boneName) {
					var bData:BoneData = _boneDataList[i];
					return bData;
				}
			}
			return null;
		}
		

		public function getSkinData(skinName:String):SkinData {
			if(!skinName)
			{
				return _skinDataList[0];
			}
			var i:int = int(_skinDataList.length);
			while(i --)
			{
				if(_skinDataList[i].name == skinName)
				{
					return _skinDataList[i];
				}
			}
			
			return null;
		}
		


		public function getAnimationData(animationName:String):AnimationData {
			var i:int = int(_animationDataList.length);
			while(i --)
			{
				if(_animationDataList[i].name == animationName)
				{
					return _animationDataList[i];
				}
			}
			return null;
		}
		



		public function addBoneData(boneData:BoneData):void {
			if(!boneData){
				return;				
			}
				//throw new ArgumentError();
			
			if (_boneDataList.indexOf(boneData) < 0)
			{
				_boneDataList.push(boneData);
				//_boneDataList.setFixed();
			}
			else
			{
				//throw new ArgumentError();
			}
		}
		

		public function addSkinData(skinData:SkinData):void {
			if(!skinData)
			{
				//throw new ArgumentError();
			}
			
			if(_skinDataList.indexOf(skinData) < 0)
			{
				_skinDataList.push(skinData);
				//_skinDataList.setFixed();
			}
			else
			{
				//throw new ArgumentError();
			}
		}
		
		public function addAnimationData(animationData:AnimationData):void {
			
			if(!animationData)
			{
				//throw new ArgumentError();
			}
			
			if(_animationDataList.indexOf(animationData) < 0) {
				_animationDataList.push(animationData);
				//_animationDataList.setFixed();
			}
		}



		//  Numeric vector sort
		public function vecSorter(o1:HelpBoneData, o2:HelpBoneData):Number {

			var a:int = int(o1.level);
			var b:int = int(o2.level);
			if (a < b){
				return -1;
			}else if (a > b){
				return 1;
			} else {
				return 0;					
			}
		}


		
		
		public function sortBoneDataList():void {

			var bones:int = int(_boneDataList.length);
			if(bones == 0) {
				return;
			}
			
			var helpArray:Vector.<HelpBoneData> = new Vector.<HelpBoneData>();
			var i:int;
			for(i=0; i<bones; i++){

				var boneData:BoneData = _boneDataList[i];
				var level:int = 0;
				var parentData:BoneData = boneData;
				while(parentData && parentData.parent)
				{
					level ++;
					parentData = getBoneData(parentData.parent);
				}
				helpArray.push(new HelpBoneData(level, boneData));
			}
			
			helpArray.sort(vecSorter);
			//helpArray.sortOn("level", Vector.NUMERIC);
			
			i = helpArray.length;
			while(i --)
			{
				_boneDataList[i] = helpArray[i].boneData;
			}
		}



		/*
		*   Getter Setters
		*/

		public function get boneDataList():Vector.<BoneData> {
			return _boneDataList;
		}


		public function get skinDataList():Vector.<SkinData> {
			return _skinDataList;
		}


		public function get animationDataList():Vector.<AnimationData> {
			return _animationDataList;
		}
	}
}
