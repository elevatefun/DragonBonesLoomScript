package dragonBones.factories {

    import dragonBones.Armature;
    import dragonBones.Bone;
    import dragonBones.Slot;
    import dragonBones.objects.AnimationData;
    import dragonBones.objects.ArmatureData;
    import dragonBones.objects.BoneData;
    import dragonBones.objects.DataParser;
    //import dragonBones.objects.DecompressedData;
    import dragonBones.objects.JSONDataParser;
    import dragonBones.objects.XMLDataParser;
    import dragonBones.objects.DisplayData;
    import dragonBones.objects.SkeletonData;
    import dragonBones.objects.SkinData;
    import dragonBones.objects.SlotData;
    import dragonBones.display.LoomDisplayBridge;
    //import dragonBones.display.StarlingDisplayBridge;
    //import dragonBones.textures.ITextureAtlas;
    //import dragonBones.utils.BytesType;

    import loom2d.textures.Texture;
    import loom2d.textures.TextureAtlas;
    import loom2d.ui.TextureAtlasManager;
    import loom2d.ui.TextureAtlasSprite;
    import loom2d.display.Sprite;
    //import loom2d.events.Event;
    //import loom2d.events.EventDispatcher;
    import loom2d.math.Matrix;
    import loom2d.math.Point;

    //import system.ByteArray;


    delegate LoomFactoryDelegate();




    public class LoomFactory {


        //  Dictionary of SkeletonData
        protected var _dataDic:Dictionary.<String, SkeletonData>;

        //  Dictionary that keeps track of textureAtlas names based on data names
        protected var _textureAtlasDic:Dictionary.<String, String>;

        protected var _currentDataName:String;

        protected var _currentTextureAtlasName:String;


        //  Callback when json file is parsed and ready to use
        public var onParseComplete:LoomFactoryDelegate = null;


        public function LoomFactory() {

            super();
            _dataDic = new Dictionary.<String, SkeletonData>();
            _textureAtlasDic = new Dictionary.<String, String>();

        }



        public function parseData(atlasXMLPath:String, skeletonPath:String, dataName:String = null):SkeletonData {

            var data:SkeletonData = DataParser.parseSkeletonData(skeletonPath);
            var skeleton:SkeletonData;

            while(!skeleton){

                skeleton = data;
            }

            var entryName = (dataName) ? dataName : skeleton.name;

            TextureAtlasManager.register(entryName, atlasXMLPath);

            _dataDic[entryName] = skeleton;
            _textureAtlasDic[entryName] = entryName;

            onParseComplete();
            return skeleton;
        }


        /*
         * Build and returns a new Armature instance.
         * @example
         * <listing>
         * var armature:Armature = factory.buildArmature('dragon');
         * </listing>
         * @param   armatureName The name of this Armature instance.
         * @param   The name of this animation.
         * @param   The name of this SkeletonData.
         * @param   The name of this textureAtlas.
         * @param   The name of this skin.
         * @return A Armature instance.
         */
        public function buildArmature(armatureName:String, animationName:String = null, skeletonName:String = null, textureAtlasName:String = null, skinName:String = null):Armature {

            var armatureData:ArmatureData;

            var entryName:String = (skeletonName) ? skeletonName : armatureName;

            _currentDataName = _dataDic[entryName].name;
            _currentTextureAtlasName = _textureAtlasDic[entryName];

            if(skeletonName) {
                var data:SkeletonData = _dataDic[skeletonName];
                if(data) {
                    armatureData = data.getArmatureData(armatureName);
                }

            } else {

                for each (var skelData:SkeletonData in _dataDic) {
                    armatureData = skelData.getArmatureData(armatureName);
                    if(armatureData) {
                        break;
                    }
                }
            }

            if(!armatureData) {
                return null;
            }

            var armature:Armature = new Armature(new Sprite());
            armature.name = armatureName;
            var bone:Bone;
            for each(var boneData:BoneData in armatureData.boneDataList)
            {

                bone = new Bone();
                bone.name = boneData.name;
                bone.origin.copy(boneData.transform);
                if(armatureData.getBoneData(boneData.parent))
                {
                    armature.addBone(bone, boneData.parent);
                }
                else
                {
                    armature.addBone(bone);
                }
            }

            if(animationName && animationName != armatureName)
            {
                var animationArmatureData:ArmatureData = data.getArmatureData(animationName);
                if(!animationArmatureData)
                {
                    for each (var skelName:SkeletonData in _dataDic)
                    {
                        animationArmatureData = skelName.getArmatureData(animationName);
                        if(animationArmatureData)
                        {
                            break;
                        }
                    }
                }
            }

            if(animationArmatureData)
            {
                armature.animation.animationDataList = animationArmatureData.animationDataList;
            }
            else
            {
                armature.animation.animationDataList = armatureData.animationDataList;
            }

            var skinData:SkinData = armatureData.getSkinData(skinName);
            if(!skinData)
            {
                //throw new ArgumentError();
            }

            var slot:Slot;
            var displayData:DisplayData;
            var childArmature:Armature;
            var i:int;
            var helpArray:Vector.<Object> = new Vector.<Object>();
            for each(var slotData:SlotData in skinData.slotDataList)
            {

                bone = armature.getBone(slotData.parent);
                if(!bone) {
                    continue;
                }
                slot = new Slot(new LoomDisplayBridge());
                slot.name = slotData.name;
                slot._originZOrder = slotData.zOrder;
                slot._dislayDataList = slotData.displayDataList;

                helpArray.clear();
                i = slotData.displayDataList.length;
                while(i --)
                {
                    displayData = slotData.displayDataList[i];
                    switch(displayData.type)
                    {
                        case DisplayData.ARMATURE:
                            childArmature = buildArmature(displayData.name, null, _currentDataName, _currentTextureAtlasName);
                            if(childArmature)
                            {
                                helpArray.push(childArmature);
                            }
                            break;
                        case DisplayData.IMAGE:
                        default:
                            helpArray.push(generateDisplay(_currentTextureAtlasName, displayData.name, displayData.pivot.x, displayData.pivot.y));
                            break;

                    }
                }
                slot.displayList = helpArray;
                slot.changeDisplay(0);
                bone.addChild(slot);
            }
            armature._slotsZOrderChanged = true;
            armature.advanceTime(0);
            return armature;
        }



        /*
         * Return the TextureDisplay.
         * @example
         * <listing>
         * var texturedisplay:Object = factory.getTextureDisplay('dragon');
         * </listing>
         * @param   The name of this Texture.
         * @param   The name of the TextureAtlas.
         * @param   The registration pivotX position.
         * @param   The registration pivotY position.
         * @return An Object.
         */
        //public function getTextureDisplay(textureName:String, textureAtlasName:String = null, pivotX:Number = NaN, pivotY:Number = NaN):Object
        //{

        //    var textureAtlas:Texture;
        //    if(textureAtlasName)
        //    {
        //        //textureAtas = _textureAtlasDic[textureAtlasName];
        //    }
        //    if(!textureAtlas && !textureAtlasName)
        //    {
        //        for (textureAtlasName in _textureAtlasDic)
        //        {
        //            textureAtlas = _textureAtlasDic[textureAtlasName];
        //            if(textureAtlas.getRegion(textureName))
        //            {
        //                break;
        //            }
        //            textureAtlas = null;
        //        }
        //    }
        //    if(textureAtlas)
        //    {
        //        if(isNaN(pivotX) || isNaN(pivotY))
        //        {
        //            var data:SkeletonData = _dataDic[textureAtlasName];
        //            if(data)
        //            {
        //                var pivot:Point = data.getSubTexturePivot(textureName);
        //                if(pivot)
        //                {
        //                    pivotX = pivot.x;
        //                    pivotY = pivot.y;
        //                }
        //            }
        //        }

        //        return generateDisplay(textureAtlas, textureName, pivotX, pivotY);
        //    }
        //    return null;
        //}


        /** @private */
        //protected function generateTextureAtlas(content:Object, textureAtlasRawData:Object):ITextureAtlas
        //{
        //    return null;
        //}



        /*
         * Generates a DisplayObject
         * @param   textureAtlasName The TextureAtlas Name.
         * @param   fullName A qualified name.
         * @param   pivotX A pivot x based value.
         * @param   pivotY A pivot y based value.
         * @return
         */
        protected function generateDisplay(textureAtlasName:String, fullName:String, pivotX:Number, pivotY:Number):TextureAtlasSprite {

            var sprite:TextureAtlasSprite = new TextureAtlasSprite();
            sprite.atlasName = textureAtlasName;
            sprite.textureName = fullName;
            sprite.pivotX = pivotX;
            sprite.pivotY = pivotY;
            return sprite;
        }




        public function dispose(disposeData:Boolean = true):void {

            if(disposeData) {

                for each(var data:SkeletonData in _dataDic) {
                    data.dispose();
                }

                //for each(var textureAtlas:TextureAtlas in _textureAtlasDic) {
                //    textureAtlas.dispose();
                //}
            }

            _dataDic.clear();
            _dataDic = null;
            _textureAtlasDic.clear();
            _textureAtlasDic = null;
            _currentDataName = null;
            _currentTextureAtlasName = null;
        }



        public function getSkeletonData(name:String):SkeletonData {

            return _dataDic[name];
        }



        /*
        *   Add a SkeletonData instance
        * @example
        * <listing>
        * factory.addSkeletonData(data, 'dragon');
        * </listing>
        * @param   A SkeletonData instance.
        * @param   (optional) A name for this SkeletonData instance.
        */
        public function addSkeletonData(data:SkeletonData, skelName:String = null):void {

            if(!data){
                return;
            }

            var skeletonName = (skelName) ? skelName : data.name;

            if(skeletonName){
                _dataDic[skeletonName] = data;
            }
        }


        /*
         * Remove a SkeletonData instance from this BaseFactory instance.
         * @example
         * <listing>
         * factory.removeSkeletonData('dragon');
         * </listing>
         * @param   The name for the SkeletonData instance to remove.
         */
        public function removeSkeletonData(name:String):void {
            _dataDic.deleteKey(name);
        }



        //public function getTextureAtlas(name:String):TextureAtlas {

        //    return _textureAtlasDic[name];
        //}



        //public function addTextureAtlas(atlasName:String, atlasXmlPath:String):void {

        //    TextureAtlasManager.register(atlasName, atlasXMLPath);
        //}



        public function removeTextureAtlas(name:String):void {

            //var entry:TextureAtlas = _textureAtlasDic[name];
            //if(entry){
            //    entry.dispose();
            //    _textureAtlasDic.deleteKey(name);
            //}
        }


    }

}
