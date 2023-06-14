package feathers.starling.examples.gallery.controls;

import feathers.starling.controls.ImageLoader;
import feathers.starling.controls.List;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.core.FeathersControl;
import feathers.starling.events.FeathersEventType;
import feathers.starling.examples.gallery.data.GalleryItem;
import feathers.starling.utils.math.MathUtils;
import feathers.starling.utils.texture.TextureCache;
import feathers.starling.utils.touch.TapToSelect;
import openfl.geom.Point;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.events.Event;

/**
 * Renders a simple thumbnail image with animation to fade in when it
 * completes loading.
 */
class ThumbItemRenderer extends FeathersControl implements IListItemRenderer
{
	/**
	 * @private
	 * This will only work in a single list. If this item renderer needs to
	 * be used by multiple lists, this data should be stored differently.
	 */
	private static var CACHED_BOUNDS:Map<Int, Point> = new Map<Int, Point>();
	
	public function new() 
	{
		super();
		//optimization: this item renderer doesn't have interactive children
		this.isQuickHitAreaEnabled = true;
	}
	
	/**
	 * @private
	 */
	private var image:ImageLoader;

	/**
	 * @private
	 */
	private var fadeTween:Tween;
	
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
			this._owner.removeEventListener(FeathersEventType.SCROLL_START, owner_scrollStartHandler);
			this._owner.removeEventListener(FeathersEventType.SCROLL_COMPLETE, owner_scrollCompleteHandler);
		}
		this._owner = value;
		if (this._owner != null)
		{
			if (this.image != null)
			{
				this.image.delayTextureCreation = this._owner.isScrolling;
			}
			this._owner.addEventListener(FeathersEventType.SCROLL_START, owner_scrollStartHandler);
			this._owner.addEventListener(FeathersEventType.SCROLL_COMPLETE, owner_scrollCompleteHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._owner;
	}
	
	/**
	 * @private
	 */
	private var _tapToSelect:TapToSelect;
	
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
	 * @inheritDoc
	 */
	public var textureCache(get, set):TextureCache;
	private var _textureCache:TextureCache;
	private function get_textureCache():TextureCache { return this._textureCache; }
	private function set_textureCache(value:TextureCache):TextureCache
	{
		if (this._textureCache == value)
		{
			return value;
		}
		this._textureCache = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textureCache;
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		super.initialize();
		
		this.image = new ImageLoader();
		this.image.textureQueueDuration = 0.25;
		this.image.addEventListener(Event.COMPLETE, image_completeHandler);
		this.image.addEventListener(FeathersEventType.ERROR, image_errorHandler);
		this.addChild(this.image);
		
		this._tapToSelect = new TapToSelect(this);
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		
		this.image.textureCache = this._textureCache;
		
		if (dataInvalid)
		{
			if (this.fadeTween != null)
			{
				this.fadeTween.advanceTime(MathUtils.FLOAT_MAX);
			}
			if (this._data != null)
			{
				this.image.visible = false;
				this.image.source = this._data.thumbURL;
			}
			else
			{
				this.image.source = null;
			}
		}
		
		this.autoSizeIfNeeded();
		this.layoutChildren();
	}
	
	/**
	 * @private
	 */
	private function autoSizeIfNeeded():Bool
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth;//isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight;//isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth;//isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight;//isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		
		//pass all of these values down to the ImageLoader
		//because they can affect its measured dimensions
		this.image.width = this._explicitWidth;
		this.image.height = this._explicitHeight;
		this.image.minWidth = this._explicitMinWidth;
		this.image.minHeight = this._explicitMinHeight;
		this.image.maxWidth = this._explicitMaxWidth;
		this.image.maxHeight = this._explicitMaxHeight;
		this.image.validate();
		var newWidth:Float = this._explicitWidth;
		var boundsFromCache:Point;
		if (needsWidth)
		{
			if (this.image.isLoaded)
			{
				if (!CACHED_BOUNDS.exists(this._index))
				{
					CACHED_BOUNDS[this._index] = new Point();
				}
				boundsFromCache = CACHED_BOUNDS[this._index];
				//also save it to a cache so that we can reuse the width and
				//height values later if the same image needs to be loaded
				//again.
				newWidth = boundsFromCache.x = this.image.width;
			}
			else
			{
				if (CACHED_BOUNDS.exists(this._index))
				{
					//if the image isn't loaded yet, but we've loaded it at
					//least once before, we can use a cached value to avoid
					//jittering when the image resizes
					boundsFromCache = CACHED_BOUNDS[this._index];
					newWidth = boundsFromCache.x;
				}
				else
				{
					//default to 100 if we've never displayed an image for
					//this index yet.
					newWidth = 100;
				}
				
			}
		}
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (this.image.isLoaded)
			{
				if (!CACHED_BOUNDS.exists(this._index))
				{
					CACHED_BOUNDS[this._index] = new Point();
				}
				boundsFromCache = CACHED_BOUNDS[this._index];
				newHeight = boundsFromCache.y = this.image.height;
			}
			else
			{
				if (CACHED_BOUNDS.exists(this._index))
				{
					boundsFromCache = CACHED_BOUNDS[this._index];
					newHeight = boundsFromCache.y;
				}
				else
				{
					newHeight = 100;
				}
			}
		}
		return this.saveMeasurements(newWidth, newHeight, newWidth, newHeight);
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
		this.image.width = this.actualWidth;
		this.image.height = this.actualHeight;
		this.image.validate();
	}
	
	/**
	 * @private
	 */
	private function fadeTween_onComplete():Void
	{
		this.fadeTween = null;
	}
	
	/**
	 * @private
	 */
	private function owner_scrollStartHandler(event:Event):Void
	{
		this.image.delayTextureCreation = true;
	}

	/**
	 * @private
	 */
	private function owner_scrollCompleteHandler(event:Event):Void
	{
		this.image.delayTextureCreation = false;
	}

	/**
	 * @private
	 */
	private function image_completeHandler(event:Event):Void
	{
		this.image.alpha = 0;
		this.image.visible = true;
		this.fadeTween = new Tween(this.image, 1, Transitions.EASE_OUT);
		this.fadeTween.fadeTo(1);
		this.fadeTween.onComplete = fadeTween_onComplete;
		Starling.juggler.add(this.fadeTween);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	private function image_errorHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
}