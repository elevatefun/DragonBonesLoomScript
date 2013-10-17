package dragonBones.display {

    import dragonBones.objects.DBTransform;

    //import flash.geom.ColorTransform;
    import loom2d.math.Color;
    import loom2d.math.Matrix;

    import loom2d.display.DisplayObject;
    import loom2d.display.DisplayObjectContainer;

    //import loom2d.display.Image;
    import loom2d.display.Quad;
    import loom2d.textures.Texture;
    import loom2d.ui.TextureAtlasSprite;



    /*
    *   The LoomDisplayBridge class is an implementation of the IDisplayBridge
    */

    public class LoomDisplayBridge implements IDisplayBridge {

        private var _imageBackup:TextureAtlasSprite;
        private var _textureBackup:Texture;
        private var _pivotXBackup:Number;
        private var _pivotYBackup:Number;

        private var _display:TextureAtlasSprite;



        public function get display():DisplayObject {

            return _display;
        }


        public function set display(value:TextureAtlasSprite):void {

            if (_display is TextureAtlasSprite && value is TextureAtlasSprite) {

                var from:TextureAtlasSprite = _display;
                var to:TextureAtlasSprite = value;

                if (from.texture == to.texture) {

                    if(from == _imageBackup) {
                        from.texture = _textureBackup;
                        from.pivotX = _pivotXBackup;
                        from.pivotY = _pivotYBackup;
                        from.readjustSize();
                    }
                    return;
                }

                from.texture = to.texture;
                //update pivot
                from.pivotX = to.pivotX;
                from.pivotY = to.pivotY;
                from.readjustSize();
                return;
            }

            if (_display == value) {
                return;
            }

            if (_display) {

                var parent:DisplayObjectContainer = DisplayObject(_display).parent as DisplayObjectContainer;
                if (parent) {
                    var index:int = int(_display.parent.getChildIndex(_display));
                }
                removeDisplay();

            } else if(value is TextureAtlasSprite && !_imageBackup) {
                _imageBackup = value;
                _textureBackup = _imageBackup.texture;
                _pivotXBackup = _imageBackup.pivotX;
                _pivotYBackup = _imageBackup.pivotY;
            }

            _display = value;
            addDisplay(parent, index);
        }

        public function get visible():Boolean {

            return _display ? _display.visible : false;
        }

        public function set visible(value:Boolean):void {

            if(_display) {
                _display.visible = value;
            }
        }


        public function dispose():void {
            _display = null;
            _imageBackup = null;
            _textureBackup = null;
        }



        public function updateTransform(matrix:Matrix, transform:DBTransform):void {
            var pivotX:Number = _display.pivotX;
            var pivotY:Number = _display.pivotY;
            /* matrix.tx -= matrix.a * pivotX + matrix.c * pivotY; */
            /* matrix.ty -= matrix.b * pivotX + matrix.d * pivotY; */
            matrix.tx -= matrix.a + matrix.c;
            matrix.ty -= matrix.b + matrix.d;

            var mtx:Matrix = new Matrix();
            mtx.copyFrom(matrix);
            _display.transformationMatrix = mtx;
            _display.pivotX = pivotX;
            _display.pivotY = pivotY;
        }



        public function updateBlendMode(blendMode:String):void {

            //if (_display is DisplayObject)
            //{
            //    _display.blendMode = blendMode;
            //}
        };


        public function updateColor(
            aOffset:Number,
            rOffset:Number,
            gOffset:Number,
            bOffset:Number,
            aMultiplier:Number,
            rMultiplier:Number,
            gMultiplier:Number,
            bMultiplier:Number
        ):void
        {
            if (_display is Quad)
            {
                (_display as Quad).alpha = aMultiplier;
                (_display as Quad).color = (uint(rMultiplier * 0xff) << 16) + (uint(gMultiplier * 0xff) << 8) + uint(bMultiplier * 0xff);
            }
        }


        public function addDisplay(container:DisplayObjectContainer, index:int = -1):void {

            if (container && _display) {
                if (index < 0) {
                    container.addChild(_display);
                } else {
                    container.addChildAt(_display, Math.min(index, container.numChildren));
                }
            }
        }


        public function removeDisplay():void {

            if (_display && _display.parent) {

                _display.parent.removeChild(_display);
            }
        }
    }
}
