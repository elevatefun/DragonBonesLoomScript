package dragonBones.objects {


    import dragonBones.objects.AnimationData;
    import dragonBones.objects.ArmatureData;
    import dragonBones.objects.BoneData;
    import dragonBones.objects.DBTransform;
    import dragonBones.objects.DisplayData;
    import dragonBones.objects.Frame;
    import dragonBones.objects.SkeletonData;
    import dragonBones.objects.SkinData;
    import dragonBones.objects.SlotData;
    import dragonBones.objects.Timeline;
    import dragonBones.objects.TransformFrame;
    import dragonBones.objects.TransformTimeline;
    import dragonBones.utils.ConstValues;
    import dragonBones.utils.DBDataUtil;

    import loom2d.math.Color;
    import loom2d.math.Point;
    import loom2d.math.Rectangle;
    import loom.LoomTextAsset;


    public class JSONDataParser {


        private var _skeletonData:SkeletonData;


        public function parseSkeletonData(filePath:String):SkeletonData {

            _skeletonData = null;
            var jsonAsset = LoomTextAsset.create(filePath);
            jsonAsset.updateDelegate += onJSONLoad;
            jsonAsset.load();

            while(!_skeletonData){

            }

            return _skeletonData;
        }

        private function onJSONLoad(path:String, contents:String) {

            var json = new JSON();
            json.loadString(contents);

            var frameRate:int = int(json.getInteger(ConstValues.A_FRAME_RATE));

            var data:SkeletonData = new SkeletonData();
            data.name = json.getString(ConstValues.A_NAME);

            var armatures:JSON = json.getArray(ConstValues.ARMATURE);
            for(var i:int=0; i<armatures.getArrayCount(); i++){

                data.addArmatureData(parseArmatureData(armatures.getArrayObject(i), data, frameRate));
            }

            _skeletonData = data;
        }

        private function parseArmatureData(json:JSON, data:SkeletonData, frameRate:int):ArmatureData {

            var armatureData:ArmatureData = new ArmatureData();
            armatureData.name = json.getString(ConstValues.A_NAME);

            var boneObject:JSON = json.getArray(ConstValues.BONE);
            var len:Number = boneObject.getArrayCount();
            var i:int;
            for(i=0; i<len; i++){

                armatureData.addBoneData(parseBoneData(boneObject.getArrayObject(i)));
            }

            var skinObject:JSON = json.getArray(ConstValues.SKIN);
            len = skinObject.getArrayCount();
            for(i=0; i<len; i++){

                armatureData.addSkinData(parseSkinData(skinObject.getArrayObject(i), data));
            }

            DBDataUtil.transformArmatureData(armatureData);
            armatureData.sortBoneDataList();

            var animationObject:JSON = json.getArray(ConstValues.ANIMATION);
            len = animationObject.getArrayCount();
            for(i=0; i<len; i++){
                armatureData.addAnimationData(parseAnimationData(animationObject.getArrayObject(i), armatureData, frameRate));
            }

            return armatureData;
        }


        private function parseBoneData(json:JSON):BoneData {

            var boneData:BoneData = new BoneData();
            boneData.name = json.getString(ConstValues.A_NAME);
            boneData.parent = json.getString(ConstValues.A_PARENT);
            boneData.length = getNumber(json, ConstValues.A_LENGTH);

            var transformObject:JSON = json.getObject(ConstValues.TRANSFORM);
            parseTransform(transformObject, boneData.global);
            boneData.transform.copy(boneData.global);

            return boneData;
        }



        private function parseSkinData(json:JSON, data:SkeletonData):SkinData {

            var skinData:SkinData = new SkinData();
            skinData.name = json.getString(ConstValues.A_NAME);

            var slotArray:JSON = json.getArray(ConstValues.SLOT);
            for(var i:int=0; i<slotArray.getArrayCount(); i++){

                var slotData:SlotData = parseSlotData(slotArray.getArrayObject(i), data);
                skinData.addSlotData(slotData);
            }

            return skinData;
        }



        private function parseSlotData(json:JSON, data:SkeletonData):SlotData {

            var slotData:SlotData = new SlotData();
            slotData.name = json.getString(ConstValues.A_NAME);
            slotData.parent = json.getString(ConstValues.A_PARENT);
            slotData.zOrder = json.getInteger(ConstValues.A_Z_ORDER);

            var displayArray:JSON = json.getArray(ConstValues.DISPLAY);
            for(var i:int=0; i<displayArray.getArrayCount(); i++){

                slotData.addDisplayData(parseDisplayData(displayArray.getArrayObject(i), data));
            }

            return slotData;
        }


        private function parseDisplayData(json:JSON, data:SkeletonData):DisplayData {

            var displayData:DisplayData = new DisplayData();
            displayData.name = json.getString(ConstValues.A_NAME);
            displayData.type = json.getString(ConstValues.A_TYPE);

            displayData.pivot = data.addSubTexturePivot(0, 0, displayData.name);

            var transformObject:JSON = json.getObject(ConstValues.TRANSFORM);
            parseTransform(transformObject, displayData.transform, displayData.pivot);

            return displayData;
        }


        protected function parseAnimationData(json:JSON, armatureData:ArmatureData, frameRate:uint):AnimationData {

            var animationData:AnimationData = new AnimationData();
            animationData.name = json.getString(ConstValues.A_NAME);
            animationData.frameRate = frameRate;
            animationData.loop = getNumber(json, ConstValues.A_LOOP);
            animationData.fadeInTime = getNumber(json, ConstValues.A_FADE_IN_TIME);
            animationData.duration = getNumber(json, ConstValues.A_DURATION) / frameRate;
            animationData.scale = getNumber(json, ConstValues.A_SCALE);
            animationData.tweenEasing = getNumber(json, ConstValues.A_TWEEN_EASING);

            parseTimeline(json, animationData, parseMainFrame, frameRate);

            var timeline:TransformTimeline;
            var timelineName:String;
            var timelineArray:JSON = json.getArray(ConstValues.TIMELINE);
            for(var i:int=0; i<timelineArray.getArrayCount(); i++){

                var timelineObject:JSON = timelineArray.getArrayObject(i);
                timeline = parseTransformTimeline(timelineObject, animationData.duration, frameRate);
                timelineName = timelineObject.getString(ConstValues.A_NAME);
                animationData.addTimeline(timeline, timelineName);
            }

            DBDataUtil.addHideTimeline(animationData, armatureData);
            DBDataUtil.transformAnimationData(animationData, armatureData);

            return animationData;
        }


        private function parseTimeline(json:JSON, timeline:Timeline, frameParser:Function, frameRate:uint):void {

            var position:Number = 0;
            var frame:Frame;

            var frameArray:JSON = json.getArray(ConstValues.FRAME);
            if(frameArray){
                for(var i:int=0; i<frameArray.getArrayCount(); i++){

                    frame = Frame(frameParser(frameArray.getArrayObject(i), frameRate));
                    frame.position = position;
                    timeline.addFrame(frame);
                    position += frame.duration;
                }
            }

            if(frame) {
                frame.duration = timeline.duration - frame.position;
            }
        }


        private function parseTransformTimeline(json:JSON, duration:Number, frameRate:uint):TransformTimeline {

            var timeline:TransformTimeline = new TransformTimeline();
            timeline.duration = duration;

            parseTimeline(json, timeline, parseTransformFrame, frameRate);

            timeline.scale = getNumber(json, ConstValues.A_SCALE);
            timeline.offset = getNumber(json, ConstValues.A_OFFSET);

            return timeline;
        }


        private function parseFrame(json:JSON, frame:Frame, frameRate:uint):void {

            frame.duration = getNumber(json, ConstValues.A_DURATION) / frameRate;
            frame.action = json.getString(ConstValues.A_ACTION);
            frame.event = json.getString(ConstValues.A_EVENT);
            frame.sound = json.getString(ConstValues.A_SOUND);
        }



        private function parseMainFrame(json:JSON, frameRate:uint):Frame {

            var frame:Frame = new Frame();
            parseFrame(json, frame, frameRate);
            return frame;
        }


        private function parseTransformFrame(json:JSON, frameRate:uint):TransformFrame {

            var frame:TransformFrame = new TransformFrame();
            parseFrame(json, frame, frameRate);

            frame.visible = getNumber(json, ConstValues.A_HIDE) != 1;
            frame.tweenEasing = getNumber(json, ConstValues.A_TWEEN_EASING);
            frame.tweenRotate = getNumber(json, ConstValues.A_TWEEN_ROTATE);
            frame.displayIndex = getNumber(json, ConstValues.A_DISPLAY_INDEX);

            frame.zOrder = Number(json.getInteger(ConstValues.A_Z_ORDER));

            parseTransform(json.getObject(ConstValues.TRANSFORM), frame.global, frame.pivot);
            frame.transform.copy(frame.global);

            //var colorTransformObject:JSON = json.getObject(ConstValues.COLOR_TRANSFORM);
            //if(colorTransformObject)
            //{
            //    frame.color = new ColorTransform();
            //    frame.color.alphaOffset = Number(colorTransformObject.getInteger(ConstValues.A_ALPHA_OFFSET));
            //    frame.color.redOffset = Number(colorTransformObject.getInteger(ConstValues.A_RED_OFFSET));
            //    frame.color.greenOffset = Number(colorTransformObject.getInteger(ConstValues.A_GREEN_OFFSET));
            //    frame.color.blueOffset = Number(colorTransformObject.getInteger(ConstValues.A_BLUE_OFFSET));

            //    frame.color.alphaMultiplier = Number(colorTransformObject.getInteger(ConstValues.A_ALPHA_MULTIPLIER)) * 0.01;
            //    frame.color.redMultiplier = Number(colorTransformObject.getInteger(ConstValues.A_RED_MULTIPLIER)) * 0.01;
            //    frame.color.greenMultiplier = Number(colorTransformObject.getInteger(ConstValues.A_GREEN_MULTIPLIER)) * 0.01;
            //    frame.color.blueMultiplier = Number(colorTransformObject.getInteger(ConstValues.A_BLUE_MULTIPLIER)) * 0.01;
            //}

            return frame;
        }




        private function parseTransform(json:JSON, transform:DBTransform, pivot:Point = new Point()):void {

            if(json) {

                if(transform) {

                    transform.x = getNumber(json, ConstValues.A_X);
                    transform.y = getNumber(json, ConstValues.A_Y);
                    transform.skewX = getNumber(json, ConstValues.A_SKEW_X) * ConstValues.ANGLE_TO_RADIAN;
                    transform.skewY = getNumber(json, ConstValues.A_SKEW_Y) * ConstValues.ANGLE_TO_RADIAN;
                    transform.scaleX = getNumber(json, ConstValues.A_SCALE_X);
                    transform.scaleY = getNumber(json, ConstValues.A_SCALE_Y);
                }
                if(pivot) {
                    pivot.x = getNumber(json, ConstValues.A_PIVOT_X);
                    pivot.y = getNumber(json, ConstValues.A_PIVOT_Y);
                }
            }
        }



        /*
        *   Hopefully this is a temporary work around for what seems to be bug with properties returning 0
        */
        private function getNumber(json:JSON, property:String):Number {

            var num:Number = json.getInteger(property);
            if(num == 0){
                num = json.getFloat(property);
            }

            return num;
        }

    }

}
