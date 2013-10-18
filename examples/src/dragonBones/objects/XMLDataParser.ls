package dragonBones.objects {

   /**
    * Copyright 2012-2013. DragonBones. All Rights Reserved.
    * @version 2.0
    */

    import dragonBones.core.DragonBones;
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



    /**
     * The XMLDataParser class parses xml data from dragonBones generated maps.
     */
    final public class XMLDataParser {


        //public static function parseTextureAtlasData(rawData:XML, scale:Number = 1):Object
        //{
            //var textureAtlasData:Object = {};
            //textureAtlasData.__name = rawData.@[ConstValues.A_NAME];
        //    for each (var subTextureXML:XML in rawData[ConstValues.SUB_TEXTURE])
        //    {
        //        var subTextureName:String = subTextureXML.@[ConstValues.A_NAME];
        //        var subTextureData:Rectangle = new Rectangle();
        //        subTextureData.x = int(subTextureXML.@[ConstValues.A_X]) / scale;
        //        subTextureData.y = int(subTextureXML.@[ConstValues.A_Y]) / scale;
        //        subTextureData.width = int(subTextureXML.@[ConstValues.A_WIDTH]) / scale;
        //        subTextureData.height = int(subTextureXML.@[ConstValues.A_HEIGHT]) / scale;

        //        textureAtlasData[subTextureName] = subTextureData;
        //    }

        //    return textureAtlasData;
        //}

        /*
         * Parse the SkeletonData.
         * @param   xml The SkeletonData xml to parse.
         * @return A SkeletonData instance.
         */
        public static function parseSkeletonData(filePath:String):SkeletonData
        {

            var xmlDoc:XMLDocument = new XMLDocument();
            xmlDoc.loadFile(filePath);
            var root:XMLElement = xmlDoc.rootElement();
            var frameRate:int = int(root.getNumberAttribute(ConstValues.A_FRAME_RATE));

            var data:SkeletonData = new SkeletonData();
            data.name = root.getAttribute(ConstValues.A_NAME);

            var armatureXML:XMLElement = root.firstChildElement(ConstValues.ARMATURE);
            while (armatureXML){

                data.addArmatureData(parseArmatureData(armatureXML, data, frameRate));
                armatureXML = armatureXML.nextSiblingElement();
            }

            return data;
        }



        private static function parseArmatureData(armatureXML:XMLElement, data:SkeletonData, frameRate:uint):ArmatureData {

            var armatureData:ArmatureData = new ArmatureData();
            armatureData.name = armatureXML.getAttribute(ConstValues.A_NAME);

            var boneXML:XMLElement = armatureXML.firstChildElement(ConstValues.BONE);
            while(boneXML){

                armatureData.addBoneData(parseBoneData(boneXML));
                boneXML = boneXML.nextSiblingElement(ConstValues.BONE);
            }

            var skinXML:XMLElement = armatureXML.firstChildElement(ConstValues.SKIN);
            while(skinXML){

                armatureData.addSkinData(parseSkinData(skinXML, data));
                skinXML = skinXML.nextSiblingElement(ConstValues.SKIN);
            }

            DBDataUtil.transformArmatureData(armatureData);
            armatureData.sortBoneDataList();

            var animationXML:XMLElement = armatureXML.firstChildElement(ConstValues.ANIMATION);
            while(animationXML){

                armatureData.addAnimationData(parseAnimationData(animationXML, armatureData, frameRate));
                animationXML = animationXML.nextSiblingElement(ConstValues.ANIMATION);
            }

            return armatureData;
        }



        private static function parseBoneData(boneXML:XMLElement):BoneData {

            var boneData:BoneData = new BoneData();
            boneData.name = boneXML.getAttribute(ConstValues.A_NAME);
            boneData.parent = boneXML.getAttribute(ConstValues.A_PARENT);
            boneData.length = Number(boneXML.getNumberAttribute(ConstValues.A_LENGTH));

            var inheritScale:String = boneXML.getAttribute(ConstValues.A_SCALE_MODE);
            if(inheritScale){
                boneData.scaleMode = Number(inheritScale);
            }


    /*  Need to come back to this */

            //var rotationNode:XMLElement
            //var fixedRotation:String = boneXML.firstChildElement(ConstValues.A_FIXED_ROTATION);
            //switch (fixedRotation){

            //    case "0":
            //    case "false":
            //    case "no":
            //    case "":
            //    case null:
            //        boneData.fixedRotation = false;
            //        break;
            //    default:
            //        boneData.fixedRotation = true;
            //        break;
            //}
            boneData.fixedRotation = true;

            parseTransform(boneXML.firstChildElement(ConstValues.TRANSFORM), boneData.global);
            boneData.transform.copy(boneData.global);

            return boneData;
        }



        private static function parseSkinData(skinXML:XMLElement, data:SkeletonData):SkinData {

            var skinData:SkinData = new SkinData();
            skinData.name = skinXML.getAttribute(ConstValues.A_NAME);

            var slotXML:XMLElement = skinXML.firstChildElement(ConstValues.SLOT);
            while(slotXML){

                skinData.addSlotData(parseSlotData(slotXML, data));
                slotXML = slotXML.nextSiblingElement(ConstValues.SLOT);
            }

            return skinData;
        }


        private static function parseSlotData(slotXML:XMLElement, data:SkeletonData):SlotData {

            var slotData:SlotData = new SlotData();
            slotData.name = slotXML.getAttribute(ConstValues.A_NAME);
            slotData.parent = slotXML.getAttribute(ConstValues.A_PARENT);
            slotData.zOrder = Number(slotXML.getNumberAttribute(ConstValues.A_Z_ORDER));
            slotData.blendMode = slotXML.getAttribute(ConstValues.A_BLENDMODE);
            if(!slotData.blendMode){
                slotData.blendMode = "normal";
            }

            var displayXML:XMLElement = slotXML.firstChildElement(ConstValues.DISPLAY);
            while(displayXML){

                slotData.addDisplayData(parseDisplayData(displayXML, data));
                displayXML = displayXML.nextSiblingElement(ConstValues.DISPLAY);
            }

            return slotData;
        }


        private static function parseDisplayData(displayXML:XMLElement, data:SkeletonData):DisplayData {

            var displayData:DisplayData = new DisplayData();
            displayData.name = displayXML.getAttribute(ConstValues.A_NAME);
            displayData.type = displayXML.getAttribute(ConstValues.A_TYPE);

            displayData.pivot = data.addSubTexturePivot(0, 0, displayData.name);
            parseTransform(displayXML.firstChildElement(ConstValues.TRANSFORM), displayData.transform, displayData.pivot);

            return displayData;
        }


        public static function parseAnimationData(animationXML:XMLElement, armatureData:ArmatureData, frameRate:uint):AnimationData {

            var animationData:AnimationData = new AnimationData();
            animationData.name = animationXML.getAttribute(ConstValues.A_NAME);
            animationData.frameRate = frameRate;
            animationData.loop = int(animationXML.getNumberAttribute(ConstValues.A_LOOP));
            animationData.fadeInTime = Number(animationXML.getNumberAttribute(ConstValues.A_FADE_IN_TIME));
            animationData.duration = Number(animationXML.getNumberAttribute(ConstValues.A_DURATION)) / frameRate;
            animationData.scale = Number(animationXML.getNumberAttribute(ConstValues.A_SCALE));
            animationData.tweenEasing = Number(animationXML.getNumberAttribute(ConstValues.A_TWEEN_EASING));

            parseTimeline(animationXML, animationData, parseMainFrame, frameRate);

            var timeline:TransformTimeline;
            var timelineName:String;

            var timelineXML:XMLElement = animationXML.firstChildElement(ConstValues.TIMELINE);
            while(timelineXML){

                timeline = parseTransformTimeline(timelineXML, animationData.duration, frameRate);
                timelineName = timelineXML.getAttribute(ConstValues.A_NAME);
                animationData.addTimeline(timeline, timelineName);
                timelineXML = timelineXML.nextSiblingElement(ConstValues.TIMELINE);
            }

            DBDataUtil.addHideTimeline(animationData, armatureData);
            DBDataUtil.transformAnimationData(animationData, armatureData);

            return animationData;
        }



        private static function parseTimeline(timelineXML:XMLElement, timeline:Timeline, frameParser:Function, frameRate:uint):void {

            var position:Number = 0;
            var frame:Frame;

            var frameXML:XMLElement = timelineXML.firstChildElement(ConstValues.FRAME);
            while(frameXML){

                frame = Frame(frameParser(frameXML, frameRate));
                frame.position = position;
                timeline.addFrame(frame);
                position += frame.duration;
                frameXML = frameXML.nextSiblingElement(ConstValues.FRAME);
            }

            if(frame) {

                frame.duration = timeline.duration - frame.position;
            }
        }



        private static function parseTransformTimeline(timelineXML:XMLElement, duration:Number, frameRate:uint):TransformTimeline {

            var timeline:TransformTimeline = new TransformTimeline();
            timeline.duration = duration;

            parseTimeline(timelineXML, timeline, parseTransformFrame, frameRate);

            timeline.scale = Number(timelineXML.getNumberAttribute(ConstValues.A_SCALE));
            timeline.offset = Number(timelineXML.getNumberAttribute(ConstValues.A_OFFSET));

            return timeline;
        }



        private static function parseFrame(frameXML:XMLElement, frame:Frame, frameRate:uint):void {

            frame.duration = Number(frameXML.getNumberAttribute(ConstValues.A_DURATION)) / frameRate;
            frame.action = frameXML.getAttribute(ConstValues.A_ACTION);
            frame.event = frameXML.getAttribute(ConstValues.A_EVENT);
            frame.sound = frameXML.getAttribute(ConstValues.A_SOUND);
        }


        private static function parseMainFrame(frameXML:XMLElement, frameRate:uint):Frame {

            var frame:Frame = new Frame();
            parseFrame(frameXML, frame, frameRate);
            return frame;
        }



        private static function parseTransformFrame(frameXML:XMLElement, frameRate:uint):TransformFrame {

            var frame:TransformFrame = new TransformFrame();
            parseFrame(frameXML, frame, frameRate);

            frame.visible = uint(frameXML.getNumberAttribute(ConstValues.A_HIDE)) != 1;
            frame.tweenEasing = Number(frameXML.getNumberAttribute(ConstValues.A_TWEEN_EASING));
            frame.tweenRotate = Number(frameXML.getNumberAttribute(ConstValues.A_TWEEN_ROTATE));
            frame.displayIndex = Number(frameXML.getNumberAttribute(ConstValues.A_DISPLAY_INDEX));
            //
            frame.zOrder = Number(frameXML.getNumberAttribute(ConstValues.A_Z_ORDER));

            parseTransform(frameXML.firstChildElement(ConstValues.TRANSFORM), frame.global, frame.pivot);
            frame.transform.copy(frame.global);

            //var colorTransformXML:XML = frameXML[ConstValues.COLOR_TRANSFORM)[0);
            //if(colorTransformXML)
            //{
            //    frame.color = new ColorTransform();
            //    frame.color.alphaOffset = Number(colorTransformXML.getAttribute(ConstValues.A_ALPHA_OFFSET));
            //    frame.color.redOffset = Number(colorTransformXML.getAttribute(ConstValues.A_RED_OFFSET));
            //    frame.color.greenOffset = Number(colorTransformXML.getAttribute(ConstValues.A_GREEN_OFFSET));
            //    frame.color.blueOffset = Number(colorTransformXML.getAttribute(ConstValues.A_BLUE_OFFSET));

            //    frame.color.alphaMultiplier = Number(colorTransformXML.getAttribute(ConstValues.A_ALPHA_MULTIPLIER)) * 0.01;
            //    frame.color.redMultiplier = Number(colorTransformXML.getAttribute(ConstValues.A_RED_MULTIPLIER)) * 0.01;
            //    frame.color.greenMultiplier = Number(colorTransformXML.getAttribute(ConstValues.A_GREEN_MULTIPLIER)) * 0.01;
            //    frame.color.blueMultiplier = Number(colorTransformXML.getAttribute(ConstValues.A_BLUE_MULTIPLIER)) * 0.01;
            //}

            return frame;
        }



        private static function parseTransform(transformXML:XMLElement, transform:DBTransform, pivot:Point = new Point()):void {

            if(transformXML) {
                if(transform)
                {
                    transform.x = Number(transformXML.getNumberAttribute(ConstValues.A_X));
                    transform.y = Number(transformXML.getNumberAttribute(ConstValues.A_Y));
                    transform.skewX = Number(transformXML.getNumberAttribute(ConstValues.A_SKEW_X)) * ConstValues.ANGLE_TO_RADIAN;
                    transform.skewY = Number(transformXML.getNumberAttribute(ConstValues.A_SKEW_Y)) * ConstValues.ANGLE_TO_RADIAN;
                    transform.scaleX = Number(transformXML.getNumberAttribute(ConstValues.A_SCALE_X));
                    transform.scaleY = Number(transformXML.getNumberAttribute(ConstValues.A_SCALE_Y));
                }

                //if(pivot) {

                    pivot.x = Number(transformXML.getNumberAttribute(ConstValues.A_PIVOT_X));
                    pivot.y = Number(transformXML.getNumberAttribute(ConstValues.A_PIVOT_Y));
                //}
            }
        }
    }
}
