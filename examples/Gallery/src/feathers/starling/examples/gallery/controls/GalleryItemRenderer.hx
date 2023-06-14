package feathers.starling.examples.gallery.controls;

import feathers.starling.controls.ImageLoader;
import feathers.starling.controls.List;
import feathers.starling.controls.ScrollContainer;
import feathers.starling.core.FeathersControl;
import feathers.starling.events.FeathersEventType;
import feathers.starling.examples.gallery.data.GalleryItem;
import feathers.starling.utils.touch.TouchSheet;
import openfl.geom.Point;
import starling.animation.Tween;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
 * A list item renderer that displays an image that may be zoomed.
 */
class GalleryItemRenderer extends ScrollContainer 
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		//the default layout for a scroll container doesn't work well when
		//TouchSheet gestures move it into negative coordinates.
		this.layout = new GalleryItemRendererLayout();
		//when we reach the edge, we want to stop without elasticity
		this.hasElasticEdges = false;
	}
	
	/**
	 * @private
	 */
	private var touchSheet:TouchSheet = null;

	/**
	 * @private
	 */
	private var image:ImageLoader = null;
	
	/**
	 * @inheritDoc
	 */
	public var index(get, set):Int;
	private var _index:Int = -1;
	private function get_index():Int { return this._index; }
	private function set_index(value:Int):Int
	{
		if (this._index == value)
		{
			return value;
		}
		this._index = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._index;
	}
	
	/**
	 * @inheritDoc
	 */
	public var factoryID(get, set):String;
	private var _factoryID:String;
	private function get_factoryID():String { return this._factoryID; }
	private function set_factoryID(value:String):String
	{
		return this._factoryID = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var owner(get, set):List;
	private var _owner:List;
	private function get_owner():List { return this._owner; }
	private function set_owner(value:List):List
	{
		if (this._owner == value)
		{
			return value;
		}
		if (this._owner != null)
		{
			this._owner.removeEventListener(FeathersEventType.SCROLL_COMPLETE, owner_scrollCompleteHandler);
		}
		this._owner = value;
		if (this._owner != null)
		{
			this._owner.addEventListener(FeathersEventType.SCROLL_COMPLETE, owner_scrollCompleteHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._owner;
	}
	
	/**
	 * @inheritDoc
	 */
	public var data(get, set):Dynamic;
	private var _data:GalleryItem;
	private function get_data():Dynamic { return this._data; }
	private function set_data(value:Dynamic):Dynamic
	{
		if (this._data == value)
		{
			return value;
		}
		this._data = value != null ? cast value : null;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._data;
	}
	
	/**
	 * @inheritDoc
	 */
	public var isSelected(get, set):Bool;
	private var _isSelected:Bool;
	private function get_isSelected():Bool { return this._isSelected; }
	private function set_isSelected(value:Bool):Bool
	{
		if (this._isSelected == value)
		{
			return value;
		}
		this._isSelected = value;
		this.dispatchEventWith(Event.CHANGE);
		return this._isSelected;
	}
	
	/**
	 * @private
	 * If the scale value is less than this after a zoom gesture ends, the
	 * scale will be animated back to this value. The default scale may be
	 * updated when a new texture is loaded.
	 */
	private var _defaultScale:Float = 1;
	
	/**
	 * @private
	 */
	private var _gestureCompleteTween:Tween = null;
	
	/**
	 * @private
	 */
	override public function hitTest(localPoint:Point):DisplayObject
	{
		var target:DisplayObject = super.hitTest(localPoint);
		if (target == this)
		{
			//the TouchSheet may not fill the entire width and height of
			//the item renderer, but we want the gestures to work from
			//anywhere within the item renderer's bounds.
			return this.touchSheet;
		}
		return target;
	}

	/**
	 * @private
	 */
	override function initialize():Void
	{
		super.initialize();
		
		this.image = new ImageLoader();
		this.image.addEventListener(Event.COMPLETE, image_completeHandler);
		this.image.addEventListener(FeathersEventType.ERROR, image_errorHandler);
		
		//this is a custom version of TouchSheet designed to work better
		//with Feathers scrolling containers
		this.touchSheet = new TouchSheet(this.image);
		//you can disable certain features of this TouchSheet
		this.touchSheet.zoomEnabled = true;
		this.touchSheet.rotateEnabled = false;
		this.touchSheet.moveEnabled = false;
		//and events are dispatched when any of the gestures are performed
		this.touchSheet.addEventListener(TouchSheet.MOVE, touchSheet_gestureHandler);
		this.touchSheet.addEventListener(TouchSheet.ROTATE, touchSheet_gestureHandler);
		this.touchSheet.addEventListener(TouchSheet.ZOOM, touchSheet_gestureHandler);
		//on TouchPhase.ENDED, any gestures performed are complete
		this.touchSheet.addEventListener(TouchEvent.TOUCH, touchSheet_touchHandler);
		this.addChild(this.touchSheet);
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		if (dataInvalid)
		{
			if (this._data != null)
			{
				if (this.image.source != this._data.url)
				{
					//hide until the image finishes loading
					this.touchSheet.visible = false;
				}
				this.image.source = this._data.url;
			}
			else
			{
				this.image.source = null;
			}
			//stop any active animations because it's a new image
			if (this._gestureCompleteTween != null)
			{
				this.stage.starling.juggler.remove(this._gestureCompleteTween);
				this._gestureCompleteTween = null;
			}
			//reset all of the transformations because it's a new image
			this._defaultScale = 1;
			this.resetTransformation();
		}
		
		super.draw();
	}
	
	/**
	 * @private
	 */
	private function resetTransformation():Void
	{
		this.touchSheet.rotation = 0;
		this.touchSheet.scale = this._defaultScale;
		this.touchSheet.pivotX = 0;
		this.touchSheet.pivotY = 0;
		this.touchSheet.x = 0;
		this.touchSheet.y = 0;
	}
	
	/**
	 * @private
	 */
	private function image_completeHandler(event:Event):Void
	{
		//when an image first loads, we want it to fill the width and height
		//of the item renderer, without being larger than the item renderer
		this._defaultScale = calculateScaleRatioToFit(
			this.image.originalSourceWidth, this.image.originalSourceHeight,
			this.viewPort.visibleWidth, this.viewPort.visibleHeight);
		if (this._defaultScale > 1)
		{
			//however, we only want to make large images smaller. small
			//images should not be made larger because they'll get blurry.
			//the user can zoom in, if desired.
			this._defaultScale = 1;
		}
		this.touchSheet.scale = this._defaultScale;
		this.touchSheet.visible = true;
	}
	
	/**
	 * @private
	 */
	private function image_errorHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function touchSheet_touchHandler(event:TouchEvent):Void
	{
		//the current gesture is complete on TouchPhase.ENDED
		var touch:Touch = event.getTouch(this.touchSheet, TouchPhase.ENDED);
		if (touch == null)
		{
			return;
		}
		
		//if the scale is smaller than the default, animate it back
		var targetScale:Float = this.touchSheet.scale;
		if (targetScale < this._defaultScale)
		{
			targetScale = this._defaultScale;
		}
		if (this.touchSheet.scale != targetScale)
		{
			this._gestureCompleteTween = new Tween(this.touchSheet, 0.15, Transitions.EASE_OUT);
			this._gestureCompleteTween.scaleTo(targetScale);
			this._gestureCompleteTween.onComplete = this.gestureCompleteTween_onComplete;
			this.stage.starling.juggler.add(this._gestureCompleteTween);
		}
	}
	
	/**
	 * @private
	 */
	private function touchSheet_gestureHandler(event:Event):Void
	{
		//if the animation from the previous gesture is still active, stop
		//it immediately when a new gesture starts
		if (this._gestureCompleteTween != null)
		{
			this.stage.starling.juggler.remove(this._gestureCompleteTween);
			this._gestureCompleteTween = null;
		}
	}

	/**
	 * @private
	 */
	private function gestureCompleteTween_onComplete():Void
	{
		this._gestureCompleteTween = null;
	}

	/**
	 * @private
	 */
	private function owner_scrollCompleteHandler(event:Event):Void
	{
		if (this._owner.horizontalPageIndex == this._index)
		{
			return;
		}
		this.resetTransformation();
	}
}