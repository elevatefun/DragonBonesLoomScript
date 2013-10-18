package dragonBones.objects
{
    final public class AnimationData extends Timeline
    {
        public var frameRate:uint;
        public var name:String;
        public var loop:int;
        public var tweenEasing:Number;

        public var timelines:Dictionary.<String, TransformTimeline>;
        //public function get timelines():Dictionary.<String, TransformTimeline>;
        //{
        //  return timelines;
        //}

        public var _fadeTime:Number;
        public function get fadeInTime():Number
        {
            return _fadeTime;
        }
        public function set fadeInTime(value:Number):void
        {
            if(isNaN(value))
            {
                value = 0;
            }
            _fadeTime = value;
        }

        public function AnimationData()
        {
            super();
            loop = 0;
            tweenEasing = NaN;

            timelines = new Dictionary.<String, TransformTimeline>();

            _fadeTime = 0;
        }

        override public function dispose():void
        {
            super.dispose();

            for(var timelineName:String in timelines)
            {
                (timelines[timelineName] as TransformTimeline).dispose();
            }
            timelines.clear();
            timelines = null;
        }

        public function getTimeline(timelineName:String):TransformTimeline
        {
            return timelines[timelineName] as TransformTimeline;
        }

        public function addTimeline(timeline:TransformTimeline, timelineName:String):void
        {
            if(!timeline)
            {
                return;
                //throw new ArgumentError();
            }

            timelines[timelineName] = timeline;
        }
    }
}
