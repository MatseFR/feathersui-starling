/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.skins.IStyleProvider;
import feathers.utils.texture.TextureCache;
import feathers.utils.type.SafeCast;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Loader;
import openfl.display.LoaderInfo;
import openfl.display3D.Context3DTextureFormat;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.events.ErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.ProgressEvent;
import openfl.events.SecurityErrorEvent;
import openfl.geom.Rectangle;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.system.LoaderContext;
import openfl.utils.ByteArray;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Mesh;
import starling.display.Quad;
import starling.events.EnterFrameEvent;
import starling.styles.MeshStyle;
import starling.textures.ConcreteTexture;
import starling.textures.Texture;
import starling.textures.TextureSmoothing;
import starling.utils.RectangleUtil;
import starling.utils.ScaleMode;
import starling.utils.SystemUtil;

/**
 * Displays an image, either from an existing <code>Texture</code> object or
 * from an image file loaded with its URL. Supported image files include ATF
 * format and any bitmap formats that may be loaded by
 * <code>flash.display.Loader</code>, including JPG, GIF, and PNG.
 *
 * <p>The following example passes a URL to an image loader and listens for
 * its complete event:</p>
 *
 * <listing version="3.0">
 * var loader:ImageLoader = new ImageLoader();
 * loader.source = "http://example.com/example.png";
 * loader.addEventListener( Event.COMPLETE, loader_completeHandler );
 * this.addChild( loader );</listing>
 *
 * <p>The following example passes an existing texture to an image loader:</p>
 *
 * <listing version="3.0">
 * var loader:ImageLoader = new ImageLoader();
 * loader.source = Texture.fromBitmap( bitmap );
 * this.addChild( loader );</listing>
 *
 * @productversion Feathers 1.0.0
 */
class ImageLoader extends FeathersControl 
{
	/**
	 * @private
	 */
	private static var HELPER_RECTANGLE:Rectangle = new Rectangle();

	/**
	 * @private
	 */
	private static var HELPER_RECTANGLE2:Rectangle = new Rectangle();

	/**
	 * @private
	 */
	private static inline var CONTEXT_LOST_WARNING:String = "ImageLoader: Context lost while processing loaded image, retrying...";

	/**
	 * @private
	 */
	private static inline var ATF_FILE_EXTENSION:String = "atf";

	/**
	 * @private
	 */
	private static var textureQueueHead:ImageLoader;

	/**
	 * @private
	 */
	private static var textureQueueTail:ImageLoader;
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>ImageLoader</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.isQuickHitAreaEnabled = true;
	}
	
	/**
	 * The internal <code>starling.display.Image</code> child.
	 */
	private var image:Image;

	/**
	 * The internal <code>flash.display.Loader</code> used to load textures
	 * from URLs.
	 */
	private var loader:Loader;

	/**
	 * The internal <code>flash.net.URLLoader</code> used to load raw data
	 * from URLs.
	 */
	private var urlLoader:URLLoader;

	/**
	 * @private
	 */
	private var _lastURL:String;

	/**
	 * @private
	 */
	private var _originalTextureWidth:Float = Math.NaN;
	
	/**
	 * @private
	 */
	private var _originalTextureHeight:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _currentTextureWidth:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _currentTextureHeight:Float = Math.NaN;

	/**
	 * @private
	 */
	private var _currentTexture:Texture;

	/**
	 * @private
	 */
	private var _isRestoringTexture:Bool = false;

	/**
	 * @private
	 */
	private var _texture:Texture;

	/**
	 * @private
	 */
	private var _isTextureOwner:Bool = false;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return ImageLoader.globalStyleProvider;
	}
	
	/**
	 * The <code>Texture</code> to display, or a URL pointing to an image
	 * file. Supported image files include ATF format and any bitmap formats
	 * that may be loaded by <code>flash.display.Loader</code>, including
	 * JPG, GIF, and PNG.
	 *
	 * <p>In the following example, the image loader's source is set to a
	 * texture:</p>
	 *
	 * <listing version="3.0">
	 * loader.source = Texture.fromBitmap( bitmap );</listing>
	 *
	 * <p>In the following example, the image loader's source is set to the
	 * URL of a PNG image:</p>
	 *
	 * <listing version="3.0">
	 * loader.source = "http://example.com/example.png";</listing>
	 *
	 * @default null
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Loader.html
	 * @see http://wiki.starling-framework.org/manual/atf_textures
	 */
	public var source(get, set):Dynamic;
	private var _source:Dynamic;
	private function get_source():Dynamic { return this._source; }
	private function set_source(value:Dynamic):Dynamic
	{
		if (this._source == value)
		{
			return value;
		}
		this._isRestoringTexture = false;
		if(this._isInTextureQueue)
		{
			this.removeFromTextureQueue();
		}
		
		var oldTexture:Texture = null;
		//we should try to reuse the existing texture, if possible.
		if (this._isTextureOwner && value != null && !Std.isOfType(value, Texture))
		{
			oldTexture = this._texture;
			this._isTextureOwner = false;
		}
		this.cleanupTexture();
		
		//the source variable needs to be set after cleanupTexture() is
		//called because cleanupTexture() needs to know the old source if
		//a TextureCache is in use.
		this._source = value;
		
		if (oldTexture != null)
		{
			this._texture = oldTexture;
			this._isTextureOwner = true;
		}
		if (this.image != null)
		{
			this.image.visible = false;
		}
		this.cleanupLoaders(true);
		this._lastURL = null;
		if (Std.isOfType(this._source, Texture))
		{
			this._isLoaded = true;
		}
		else
		{
			
			this._isLoaded = false;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return value;
	}
	
	/**
	 * An optional cache for textures.
	 *
	 * <p>In the following example, a cache is provided for textures:</p>
	 *
	 * <listing version="3.0">
	 * var cache:TextureCache = new TextureCache(30);
	 * loader1.textureCache = cache;
	 * loader2.textureCache = cache;</listing>
	 *
	 * <p><strong>Warning:</strong> the textures in the cache will not be
	 * disposed automatically. When the cache is no longer needed (such as
	 * when the <code>ImageLoader</code> components have all been disposed),
	 * you must call the <code>dispose()</code> method on the
	 * <code>TextureCache</code>. Failing to do so will result in a serious
	 * memory leak.</p>
	 *
	 * @default null
	 */
	public var textureCache(get, set):TextureCache;
	private var _textureCache:TextureCache;
	private function get_textureCache():TextureCache { return this._textureCache; }
	private function set_textureCache(value:TextureCache):TextureCache
	{
		return this._textureCache = value;
	}
	
	/**
	 * @private
	 */
	public var loadingTexture(get, set):Texture;
	private var _loadingTexture:Texture;
	private function get_loadingTexture():Texture { return this._loadingTexture; }
	private function set_loadingTexture(value:Texture):Texture
	{
		if (this.processStyleRestriction("loadingTexture"))
		{
			return value;
		}
		if (this._loadingTexture == value)
		{
			return value;
		}
		this._loadingTexture = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._loadingTexture;
	}
	
	/**
	 * @private
	 */
	public var errorTexture(get, set):Texture;
	private var _errorTexture:Texture;
	private function get_errorTexture():Texture { return this._errorTexture; }
	private function set_errorTexture(value:Texture):Texture
	{
		if (this.processStyleRestriction("errorTexture"))
		{
			return value;
		}
		if (this._errorTexture == value)
		{
			return value;
		}
		this._errorTexture = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._errorTexture;
	}
	
	/**
	 * Indicates if the source has completed loading, if the source is a
	 * URL. Always returns <code>true</code> when the source is a texture.
	 *
	 * <p>In the following example, we check if the image loader's source
	 * has finished loading:</p>
	 *
	 * <listing version="3.0">
	 * if( loader.isLoaded )
	 * {
	 *     //do something
	 * }</listing>
	 */
	public var isLoaded(get, never):Bool;
	private var _isLoaded:Bool;
	private function get_isLoaded():Bool { return this._isLoaded; }
	
	/**
	 * Scales the texture dimensions during measurement, but does not set
	 * the texture's scale factor. Useful for UI that should scale based on
	 * screen density or resolution without accounting for
	 * <code>contentScaleFactor</code>.
	 *
	 * <p>In the following example, the image loader's texture scale is
	 * customized:</p>
	 *
	 * <listing version="3.0">
	 * loader.textureScale = 0.5;</listing>
	 *
	 * @default 1
	 */
	public var textureScale(get, set):Float;
	private var _textureScale:Float = 1;
	private function get_textureScale():Float { return this._textureScale; }
	private function set_textureScale(value:Float):Float
	{
		if (this._textureScale == value)
		{
			return this._textureScale;
		}
		this._textureScale = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._textureScale;
	}
	
	/**
	 * The scale factor value to pass to <code>Texture.fromBitmapData()</code>
	 * when creating a texture loaded from a URL.
	 *
	 * <p>In the following example, the image loader's scale factor is
	 * customized:</p>
	 *
	 * <listing version="3.0">
	 * loader.scaleFactor = 2;</listing>
	 *
	 * @default 1
	 */
	public var scaleFactor(get, set):Float;
	private var _scaleFactor:Float = 1;
	private function get_scaleFactor():Float { return this._scaleFactor; }
	private function set_scaleFactor(value:Float):Float
	{
		if (this._scaleFactor == value)
		{
			return this._scaleFactor;
		}
		this._scaleFactor = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._scaleFactor;
	}
	
	/**
	 * @private
	 */
	public var textureSmoothing(get, set):String;
	private var _textureSmoothing:String = TextureSmoothing.BILINEAR;
	private function get_textureSmoothing():String { return this._textureSmoothing; }
	private function set_textureSmoothing(value:String):String
	{
		if (this.processStyleRestriction("textureSmoothing"))
		{
			return value;
		}
		if (this._textureSmoothing == value)
		{
			return value;
		}
		this._textureSmoothing = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textureSmoothing;
	}
	
	/**
	 * @private
	 */
	private var _defaultStyle:MeshStyle = null;
	
	/**
	 * The style that is used to render the loader's image.
	 *
	 * <p>In the following example, the loader uses a custom style:</p>
	 *
	 * <listing version="3.0">
	 * loader.style = new CustomMeshStyle();</listing>
	 *
	 * @default null
	 */
	public var style(get, set):MeshStyle;
	private var _style:MeshStyle = null;
	private function get_style():MeshStyle { return this._style; }
	private function set_style(value:MeshStyle):MeshStyle
	{
		if (this._style == value)
		{
			return value;
		}
		this._style = value;
		if (this._style != null)
		{
			this._defaultStyle = null;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._style;
	}
	
	/**
	 * @private
	 */
	public var scale9Grid(get, set):Rectangle;
	private var _scale9Grid:Rectangle;
	private function get_scale9Grid():Rectangle { return this._scale9Grid; }
	private function set_scale9Grid(value:Rectangle):Rectangle
	{
		if (this._scale9Grid == value)
		{
			return value;
		}
		this._scale9Grid = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return value;
	}
	
	/**
	 * @private
	 */
	public var tileGrid(get, set):Rectangle;
	private var _tileGrid:Rectangle;
	private function get_tileGrid():Rectangle { return this._tileGrid; }
	private function set_tileGrid(value:Rectangle):Rectangle
	{
		if (this._tileGrid == value)
		{
			return value;
		}
		this._tileGrid = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._tileGrid;
	}
	
	/**
	 * @private
	 */
	public var pixelSnapping(get, set):Bool;
	private var _pixelSnapping:Bool = true;
	private function get_pixelSnapping():Bool { return this._pixelSnapping; }
	private function set_pixelSnapping(value:Bool):Bool
	{
		if (this._pixelSnapping == value)
		{
			return value;
		}
		this._pixelSnapping = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._pixelSnapping;
	}
	
	/**
	 * @private
	 */
	public var color(get, set):Int;
	private var _color:Int = 0xffffff;
	private function get_color():Int { return this._color; }
	private function set_color(value:Int):Int
	{
		if (this.processStyleRestriction("color"))
		{
			return value;
		}
		if (this._color == value)
		{
			return value;
		}
		this._color = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._color;
	}
	
	/**
	 * @private
	 */
	public var textureFormat(get, set):String;
	private var _textureFormat:String = Context3DTextureFormat.BGRA;
	private function get_textureFormat():String { return this._textureFormat; }
	private function set_textureFormat(value:String):String
	{
		if (this._textureFormat == value)
		{
			return value;
		}
		this._textureFormat = value;
		this._lastURL = null;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._textureFormat;
	}
	
	/**
	 * @private
	 */
	public var scaleContent(get, set):Bool;
	private var _scaleContent:Bool = true;
	private function get_scaleContent():Bool { return this._scaleContent; }
	private function set_scaleContent(value:Bool):Bool
	{
		if (this.processStyleRestriction("scaleContent"))
		{
			return value;
		}
		if (this._scaleContent == value)
		{
			return value;
		}
		this._scaleContent = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._scaleContent;
	}
	
	/**
	 * @private
	 */
	public var maintainAspectRatio(get, set):Bool;
	private var _maintainAspectRatio:Bool = true;
	private function get_maintainAspectRatio():Bool { return this._maintainAspectRatio; }
	private function set_maintainAspectRatio(value:Bool):Bool
	{
		if (this.processStyleRestriction("maintainAspectRatio"))
		{
			return value;
		}
		if (this._maintainAspectRatio == value)
		{
			return value;
		}
		this._maintainAspectRatio = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._maintainAspectRatio;
	}
	
	/**
	 * @private
	 */
	public var scaleMode(get, set):String;
	private var _scaleMode:String = ScaleMode.SHOW_ALL;
	private function get_scaleMode():String { return this._scaleMode; }
	private function set_scaleMode(value:String):String
	{
		if (this.processStyleRestriction("scaleMode"))
		{
			return value;
		}
		if (this._scaleMode == value)
		{
			return value;
		}
		this._scaleMode = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._scaleMode;
	}
	
	/**
	 * @private
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.LEFT;
	private function get_horizontalAlign():String { return this._horizontalAlign; }
	private function set_horizontalAlign(value:String):String
	{
		if (this.processStyleRestriction("horizontalAlign"))
		{
			return value;
		}
		if (this._horizontalAlign == value)
		{
			return value;
		}
		this._horizontalAlign = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._horizontalAlign;
	}
	
	/**
	 * @private
	 */
	public var verticalAlign(get, set):String;
	private var _verticalAlign:String = VerticalAlign.TOP;
	private function get_verticalAlign():String { return this._verticalAlign; }
	private function set_verticalAlign(value:String):String
	{
		if (this.processStyleRestriction("verticalAlign"))
		{
			return value;
		}
		if (this._verticalAlign == value)
		{
			return value;
		}
		this._verticalAlign = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._verticalAlign;
	}
	
	/**
	 * The original width of the source content, in pixels. This value will
	 * be <code>0</code> until the source content finishes loading. If the
	 * source is a texture, this value will be <code>0</code> until the
	 * <code>ImageLoader</code> validates.
	 */
	public var originalSourceWidth(get, never):Float;
	private function get_originalSourceWidth():Float
	{
		if (this._originalTextureWidth == this._originalTextureWidth) //!isNaN
		{
			return this._originalTextureWidth;
		}
		return 0;
	}
	
	/**
	 * The original height of the source content, in pixels. This value will
	 * be <code>0</code> until the source content finishes loading. If the
	 * source is a texture, this value will be <code>0</code> until the
	 * <code>ImageLoader</code> validates.
	 */
	public var originalSourceHeight(get, never):Float;
	private function get_originalSourceHeight():Float
	{
		if (this._originalTextureHeight == this._originalTextureHeight) //!isNaN
		{
			return this._originalTextureHeight;
		}
		return 0;
	}
	
	/**
	 * @private
	 */
	private var _pendingBitmapDataTexture:BitmapData;

	/**
	 * @private
	 */
	private var _pendingRawTextureData:ByteArray;
	
	/**
	 * Determines if a loaded bitmap may be converted to a texture
	 * immediately after loading. If <code>true</code>, the loaded bitmap
	 * will be saved until this property is set to <code>false</code>, and
	 * only then it will be used to create the texture.
	 *
	 * <p>This property is intended to be used while a parent container,
	 * such as a <code>List</code>, is scrolling in order to keep scrolling
	 * as smooth as possible. Creating textures is expensive and performance
	 * can be affected by it. Set this property to <code>true</code> when
	 * the <code>List</code> dispatches <code>FeathersEventType.SCROLL_START</code>
	 * and set back to false when the <code>List</code> dispatches
	 * <code>FeathersEventType.SCROLL_COMPLETE</code>. You may also need
	 * to set to false if the <code>isScrolling</code> property of the
	 * <code>List</code> is <code>true</code> before you listen to those
	 * events.</p>
	 *
	 * <p>In the following example, the image loader's texture creation is
	 * delayed:</p>
	 *
	 * <listing version="3.0">
	 * loader.delayTextureCreation = true;</listing>
	 *
	 * @default false
	 *
	 * @see #textureQueueDuration
	 * @see feathers.controls.Scroller#event:scrollStart
	 * @see feathers.controls.Scroller#event:scrollComplete
	 * @see feathers.controls.Scroller#isScrolling
	 */
	public var delayTextureCreation(get, set):Bool;
	private var _delayTextureCreation:Bool = false;
	private function get_delayTextureCreation():Bool { return this._delayTextureCreation; }
	private function set_delayTextureCreation(value:Bool):Bool
	{
		if (this._delayTextureCreation == value)
		{
			return value;
		}
		this._delayTextureCreation = value;
		if(!this._delayTextureCreation)
		{
			this.processPendingTexture();
		}
		return this._delayTextureCreation;
	}
	
	/**
	 * @private
	 */
	private var _isInTextureQueue:Bool = false;

	/**
	 * @private
	 */
	private var _textureQueuePrevious:ImageLoader;

	/**
	 * @private
	 */
	private var _textureQueueNext:ImageLoader;

	/**
	 * @private
	 */
	private var _accumulatedPrepareTextureTime:Float;
	
	/**
	 * If <code>delayTextureCreation</code> is <code>true</code> and the
	 * duration is not <code>Number.POSITIVE_INFINITY</code>, the loader
	 * will be added to a queue where the textures are uploaded to the GPU
	 * in sequence to avoid significantly affecting performance. Useful for
	 * lists where many textures may need to be uploaded during scrolling.
	 *
	 * <p>If the duration is <code>Number.POSITIVE_INFINITY</code>, the
	 * default value, the texture will not be uploaded until
	 * <code>delayTextureCreation</code> is set to <code>false</code>. In
	 * this situation, the loader will not be added to the queue, and other
	 * loaders with a duration won't be affected.</p>
	 *
	 * <p>In the following example, the image loader's texture creation is
	 * delayed by half a second:</p>
	 *
	 * <listing version="3.0">
	 * loader.delayTextureCreation = true;
	 * loader.textureQueueDuration = 0.5;</listing>
	 *
	 * @default Number.POSITIVE_INFINITY
	 *
	 * @see #delayTextureCreation
	 */
	public var textureQueueDuration(get, set):Float;
	private var _textureQueueDuration:Float = Math.POSITIVE_INFINITY;
	private function get_textureQueueDuration():Float { return this._textureQueueDuration; }
	private function set_textureQueueDuration(value:Float):Float
	{
		if (this._textureQueueDuration == value)
		{
			return value;
		}
		var oldDuration:Float = this._textureQueueDuration;
		this._textureQueueDuration = value;
		if (this._delayTextureCreation)
		{
			if ((this._pendingBitmapDataTexture != null || this._pendingRawTextureData != null) &&
				oldDuration == Math.POSITIVE_INFINITY && this._textureQueueDuration < Math.POSITIVE_INFINITY)
			{
				this.addToTextureQueue();
			}
			else if (this._isInTextureQueue && this._textureQueueDuration == Math.POSITIVE_INFINITY)
			{
				this.removeFromTextureQueue();
			}
		}
		return this._textureQueueDuration;
	}
	
	/**
	 * @private
	 */
	public var padding(get, set):Float;
	private function get_padding():Float { return this._paddingTop; }
	private function set_padding(value:Float):Float
	{
		this.paddingTop = value;
		this.paddingRight = value;
		this.paddingBottom = value;
		return this.paddingLeft = value;
	}
	
	/**
	 * @private
	 */
	public var paddingTop(get, set):Float;
	private var _paddingTop:Float = 0;
	private function get_paddingTop():Float { return this._paddingTop; }
	private function set_paddingTop(value:Float):Float
	{
		if (this.processStyleRestriction("paddingTop"))
		{
			return value;
		}
		if (this._paddingTop == value)
		{
			return value;
		}
		this._paddingTop = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingTop;
	}
	
	/**
	 * @private
	 */
	public var paddingRight(get, set):Float;
	private var _paddingRight:Float = 0;
	private function get_paddingRight():Float { return  this._paddingRight; }
	private function set_paddingRight(value:Float):Float
	{
		if (this.processStyleRestriction("paddingRight"))
		{
			return value;
		}
		if (this._paddingRight == value)
		{
			return value;
		}
		this._paddingRight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingRight;
	}
	
	/**
	 * @private
	 */
	public var paddingBottom(get, set):Float;
	private var _paddingBottom:Float = 0;
	private function get_paddingBottom():Float { return this._paddingBottom; }
	private function set_paddingBottom(value:Float):Float
	{
		if (this.processStyleRestriction("paddingBottom"))
		{
			return value;
		}
		if (this._paddingBottom == value)
		{
			return value;
		}
		this._paddingBottom = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingBottom;
	}
	
	/**
	 * @private
	 */
	public var paddingLeft(get, set):Float;
	private var _paddingLeft:Float = 0;
	private function get_paddingLeft():Float { return this._paddingLeft; }
	private function set_paddingLeft(value:Float):Float
	{
		if (this.processStyleRestriction("paddingLeft"))
		{
			return value;
		}
		if (this._paddingLeft == value)
		{
			return value;
		}
		this._paddingLeft = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingLeft;
	}
	
	/**
	 * Determines if textures loaded from URLs are uploaded asynchronously
	 * or not.
	 *
	 * <p>Note: depending on the version of AIR and the platform it is
	 * running on, textures may be uploaded synchronously, even when this
	 * property is <code>true</code>.</p>
	 *
	 * <p>In the following example, the texture will be uploaded
	 * synchronously:</p>
	 *
	 * <listing version="3.0">
	 * loader.asyncTextureUpload = false;</listing>
	 *
	 * @default true
	 */
	public var asyncTextureUpload(get, set):Bool;
	private var _asyncTextureUpload:Bool = true;
	private function get_asyncTextureUpload():Bool { return this._asyncTextureUpload; }
	private function set_asyncTextureUpload(value:Bool):Bool
	{
		return this._asyncTextureUpload = value;
	}
	
	/**
	 * @private
	 */
	private var _imageDecodingOnLoad:Bool = false;
	
	/**
	 * If the texture is loaded using <code>flash.display.Loader</code>,
	 * a custom <code>flash.system.LoaderContext</code> may optionally
	 * be provided.
	 *
	 * <p>In the following example, a custom loader context is provided:</p>
	 *
	 * <listing version="3.0">
	 * var context:LoaderContext = new LoaderContext();
	 * context.loadPolicyFile = true;
	 * loader.loaderContext = context;
	 * </listing>
	 *
	 * @see https://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/LoaderContext.html flash.system.LoaderContext
	 */
	public var loaderContext(get, set):LoaderContext;
	private var _loaderContext:LoaderContext = null;
	private function get_loaderContext():LoaderContext { return this._loaderContext; }
	private function set_loaderContext(value:LoaderContext):LoaderContext
	{
		return this._loaderContext;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		this._isRestoringTexture = false;
		this.cleanupLoaders(true);
		this.cleanupTexture();
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		
		if (dataInvalid)
		{
			this.commitData();
		}
		
		if (dataInvalid || stylesInvalid)
		{
			this.commitStyles();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		if (dataInvalid || layoutInvalid || sizeInvalid || stylesInvalid)
		{
			this.layout();
		}
	}
	
	/**
	 * If the component's dimensions have not been set explicitly, it will
	 * measure its content and determine an ideal size for itself. If the
	 * <code>explicitWidth</code> or <code>explicitHeight</code> member
	 * variables are set, those value will be used without additional
	 * measurement. If one is set, but not the other, the dimension with the
	 * explicit value will not be measured, but the other non-explicit
	 * dimension will still need measurement.
	 *
	 * <p>Calls <code>saveMeasurements()</code> to set up the
	 * <code>actualWidth</code> and <code>actualHeight</code> member
	 * variables used for layout.</p>
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 */
	private function autoSizeIfNeeded():Bool
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if(!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		
		var heightScale:Float = 1;
		var widthScale:Float = 1;
		if (this._scaleContent && this._maintainAspectRatio &&
			this._scaleMode != ScaleMode.NONE &&
			this._scale9Grid == null)
		{
			if (!needsHeight)
			{
				heightScale = this._explicitHeight / (this._currentTextureHeight * this._textureScale);
			}
			else if (this._explicitMaxHeight < this._currentTextureHeight)
			{
				heightScale = this._explicitMaxHeight / (this._currentTextureHeight * this._textureScale);
			}
			else if (this._explicitMinHeight > this._currentTextureHeight)
			{
				heightScale = this._explicitMinHeight / (this._currentTextureHeight * this._textureScale);
			}
			if (!needsWidth)
			{
				widthScale = this._explicitWidth / (this._currentTextureWidth * this._textureScale);
			}
			else if (this._explicitMaxWidth < this._currentTextureWidth)
			{
				widthScale = this._explicitMaxWidth / (this._currentTextureWidth * this._textureScale);
			}
			else if (this._explicitMinWidth > this._currentTextureWidth)
			{
				widthScale = this._explicitMinWidth / (this._currentTextureWidth * this._textureScale);
			}
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (this._currentTextureWidth == this._currentTextureWidth) //!isNaN
			{
				newWidth = this._currentTextureWidth * this._textureScale * heightScale;
			}
			else
			{
				newWidth = 0;
			}
			newWidth += this._paddingLeft + this._paddingRight;
		}
		
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (this._currentTextureHeight == this._currentTextureHeight) //!isNaN
			{
				newHeight = this._currentTextureHeight * this._textureScale * widthScale;
			}
			else
			{
				newHeight = 0;
			}
			newHeight += this._paddingTop + this._paddingBottom;
		}
		
		//this ensures that an ImageLoader can recover from width or height
		//being set to 0 by percentWidth or percentHeight
		if (needsHeight && needsMinHeight)
		{
			//if no height values are set, use the original texture width
			//for the minWidth
			heightScale = 1;
		}
		if (needsWidth && needsMinWidth)
		{
			//if no width values are set, use the original texture height
			//for the minHeight
			widthScale = 1;
		}
		
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			if (this._currentTextureWidth == this._currentTextureWidth) //!isNaN
			{
				newMinWidth = this._currentTextureWidth * this._textureScale * heightScale;
			}
			else
			{
				newMinWidth = 0;
			}
			newMinWidth += this._paddingLeft + this._paddingRight;
		}
		
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (this._currentTextureHeight == this._currentTextureHeight) //!isNaN
			{
				newMinHeight = this._currentTextureHeight * this._textureScale * widthScale;
			}
			else
			{
				newMinHeight = 0;
			}
			newMinHeight += this._paddingTop + this._paddingBottom;
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	private function commitData():Void
	{
		if (Std.isOfType(this._source, Texture))
		{
			this._lastURL = null;
			this._texture = cast this._source;
			this.refreshCurrentTexture();
		}
		else
		{
			var sourceURL:String = cast this._source;
			if (sourceURL == null)
			{
				this._lastURL = null;
			}
			else if (sourceURL != this._lastURL)
			{
				this._lastURL = sourceURL;
				
				if (this.findSourceInCache())
				{
					return;
				}
				
				if (isATFURL(sourceURL))
				{
					if (this.loader != null)
					{
						this.loader = null;
					}
					if (this.urlLoader == null)
					{
						this.urlLoader = new URLLoader();
						this.urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					}
					this.urlLoader.addEventListener(openfl.events.Event.COMPLETE, rawDataLoader_completeHandler);
					this.urlLoader.addEventListener(ProgressEvent.PROGRESS, rawDataLoader_progressHandler);
					this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, rawDataLoader_ioErrorHandler);
					this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, rawDataLoader_securityErrorHandler);
					this.urlLoader.load(new URLRequest(sourceURL));
					return;
				}
				else //not ATF
				{
					if (this.urlLoader != null)
					{
						this.urlLoader = null;
					}
					if (this.loader == null)
					{
						this.loader = new Loader();
					}
					this.loader.contentLoaderInfo.addEventListener(openfl.events.Event.COMPLETE, loader_completeHandler);
					this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loader_progressHandler);
					this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
					this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler);
					if (this._loaderContext == null)
					{
						//create a default loader context that checks
						//policy files, and also decodes images on load for
						//better performance
						this._loaderContext = new LoaderContext(true);
						#if flash
						// TODO : missing extern for ImageDecodingPolicy ?
						//this._loaderContext.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
						#end
					}
					//save this value because the _loaderContext might
					//change before we need to access it.
					//we will need it if we need to clean up the Loader.
					#if flash
					// TODO : missing extern for ImageDecodingPolicy ?
					//this._imageDecodingOnLoad = this._loaderContext.imageDecodingPolicy === ImageDecodingPolicy.ON_LOAD;
					this._imageDecodingOnLoad = true;
					#end
					this.loader.load(new URLRequest(sourceURL), this._loaderContext);
				}
			}
			this.refreshCurrentTexture();
		}
	}
	
	/**
	 * @private
	 */
	private function commitStyles():Void
	{
		if (this.image == null)
		{
			return;
		}
		this.image.textureSmoothing = this._textureSmoothing;
		this.image.color = this._color;
		this.image.scale9Grid = this._scale9Grid;
		this.image.tileGrid = this._tileGrid;
		this.image.pixelSnapping = this._pixelSnapping;
		if (this._style != null)
		{
			this.image.style = this._style;
		}
		else
		{
			if (this._defaultStyle == null)
			{
				this._defaultStyle = Mesh.createDefaultStyle(this.image);
			}
			this.image.style = this._defaultStyle;
		}
	}
	
	/**
	 * @private
	 */
	private function layout():Void
	{
		if (this.image == null || this._currentTexture == null)
		{
			return;
		}
		var imageWidth:Float = 0;
		var imageHeight:Float = 0;
		if (this._scaleContent)
		{
			if (this._maintainAspectRatio && this._scale9Grid == null)
			{
				HELPER_RECTANGLE.x = 0;
				HELPER_RECTANGLE.y = 0;
				HELPER_RECTANGLE.width = this._currentTextureWidth * this._textureScale;
				HELPER_RECTANGLE.height = this._currentTextureHeight * this._textureScale;
				HELPER_RECTANGLE2.x = 0;
				HELPER_RECTANGLE2.y = 0;
				HELPER_RECTANGLE2.width = this.actualWidth - this._paddingLeft - this._paddingRight;
				HELPER_RECTANGLE2.height = this.actualHeight - this._paddingTop - this._paddingBottom;
				RectangleUtil.fit(HELPER_RECTANGLE, HELPER_RECTANGLE2, this._scaleMode, false, HELPER_RECTANGLE);
				this.image.x = HELPER_RECTANGLE.x + this._paddingLeft;
				this.image.y = HELPER_RECTANGLE.y + this._paddingTop;
				this.image.width = HELPER_RECTANGLE.width;
				this.image.height = HELPER_RECTANGLE.height;
			}
			else
			{
				this.image.x = this._paddingLeft;
				this.image.y = this._paddingTop;
				this.image.width = this.actualWidth - this._paddingLeft - this._paddingRight;
				this.image.height = this.actualHeight - this._paddingTop - this._paddingBottom;
			}
		}
		else
		{
			imageWidth = this._currentTextureWidth * this._textureScale;
			imageHeight = this._currentTextureHeight * this._textureScale;
			if (this._horizontalAlign == HorizontalAlign.RIGHT)
			{
				this.image.x = this.actualWidth - this._paddingRight - imageWidth;
			}
			else if (this._horizontalAlign == HorizontalAlign.CENTER)
			{
				this.image.x = this._paddingLeft + ((this.actualWidth - this._paddingLeft - this._paddingRight) - imageWidth) / 2;
			}
			else //left
			{
				this.image.x = this._paddingLeft;
			}
			if (this._verticalAlign == VerticalAlign.BOTTOM)
			{
				this.image.y = this.actualHeight - this._paddingBottom - imageHeight;
			}
			else if(this._verticalAlign == VerticalAlign.MIDDLE)
			{
				this.image.y = this._paddingTop + ((this.actualHeight - this._paddingTop - this._paddingBottom) - imageHeight) / 2;
			}
			else //top
			{
				this.image.y = this._paddingTop;
			}
			this.image.width = imageWidth;
			this.image.height = imageHeight;
		}
		var mask:Quad;
		if ((!this._scaleContent || (this._maintainAspectRatio && this._scaleMode != ScaleMode.SHOW_ALL)) &&
			(this.actualWidth != imageWidth || this.actualHeight != imageHeight))
		{
			mask = SafeCast.safe_cast(this.image.mask, Quad);
			if (mask != null)
			{
				mask.x = 0;
				mask.y = 0;
				mask.width = this.actualWidth;
				mask.height = this.actualHeight;
			}
			else
			{
				mask = new Quad(1, 1, 0xff00ff);
				//the initial dimensions cannot be 0 or there's a runtime error,
				//and these values might be 0
				mask.width = this.actualWidth;
				mask.height = this.actualHeight;
				this.image.mask = mask;
				this.addChild(mask);
			}
		}
		else
		{
			mask = SafeCast.safe_cast(this.image.mask, Quad);
			if (mask != null)
			{
				mask.removeFromParent(true);
				this.image.mask = null;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function isATFURL(sourceURL:String):Bool
	{
		var index:Int = sourceURL.indexOf("?");
		if (index >= 0)
		{
			sourceURL = sourceURL.substr(0, index);
		}
		return sourceURL.toLowerCase().lastIndexOf(ATF_FILE_EXTENSION) == sourceURL.length - 3;
	}
	
	/**
	 * @private
	 */
	private function refreshCurrentTexture():Void
	{
		var newTexture:Texture = this._isLoaded ? this._texture : null;
		if (newTexture == null)
		{
			if (this.loader != null || this.urlLoader != null)
			{
				newTexture = this._loadingTexture;
			}
			else
			{
				newTexture = this._errorTexture;
			}
		}
		
		if (this._currentTexture == newTexture)
		{
			return;
		}
		this._currentTexture = newTexture;
		
		if (this._currentTexture == null)
		{
			if (this.image != null)
			{
				this.removeChild(this.image, true);
				this.image = null;
				this._defaultStyle = null;
			}
			return;
		}
		
		//save the texture's frame so that we don't need to create a new
		//rectangle every time that we want to access it.
		var frame:Rectangle = this._currentTexture.frame;
		if (frame != null)
		{
			this._currentTextureWidth = frame.width;
			this._currentTextureHeight = frame.height;
		}
		else
		{
			this._currentTextureWidth = this._currentTexture.width;
			this._currentTextureHeight = this._currentTexture.height;
			this._originalTextureWidth = this._currentTexture.nativeWidth;
			this._originalTextureHeight = this._currentTexture.nativeHeight;
		}
		if (this.image == null)
		{
			this.image = new Image(this._currentTexture);
			this.addChild(this.image);
		}
		else
		{
			this.image.texture = this._currentTexture;
			this.image.readjustSize();
		}
		this.image.visible = true;
	}
	
	/**
	 * @private
	 */
	private function cleanupTexture():Void
	{
		if (this._texture != null)
		{
			if (this._isTextureOwner)
			{
				if (!SystemUtil.isDesktop && !SystemUtil.isApplicationActive)
				{
					//avoiding stage3d calls when a mobile application isn't active
					SystemUtil.executeWhenApplicationIsActive(this._texture.dispose);
				}
				else
				{
					this._texture.dispose();
				}
			}
			else if (this._textureCache != null)
			{
				var cacheKey:String = this.sourceToTextureCacheKey(this._source);
				if (cacheKey != null)
				{
					this._textureCache.releaseTexture(cacheKey);
				}
			}
		}
		if (this._pendingBitmapDataTexture != null)
		{
			this._pendingBitmapDataTexture.dispose();
		}
		if (this._pendingRawTextureData != null)
		{
			this._pendingRawTextureData.clear();
		}
		this._currentTexture = null;
		this._currentTextureWidth = Math.NaN;
		this._currentTextureHeight = Math.NaN;
		this._originalTextureWidth = Math.NaN;
		this._originalTextureHeight = Math.NaN;
		this._pendingBitmapDataTexture = null;
		this._pendingRawTextureData = null;
		this._texture = null;
		this._isTextureOwner = false;
	}
	
	/**
	 * @private
	 */
	private function cleanupLoaders(close:Bool):Void
	{
		if (this.urlLoader != null)
		{
			this.urlLoader.removeEventListener(openfl.events.Event.COMPLETE, rawDataLoader_completeHandler);
			this.urlLoader.removeEventListener(ProgressEvent.PROGRESS, rawDataLoader_progressHandler);
			this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, rawDataLoader_ioErrorHandler);
			this.urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, rawDataLoader_securityErrorHandler);
			if (close)
			{
				try
				{
					this.urlLoader.close();
				}
				catch (error:Error)
				{
					//no need to do anything in response
				}
			}
			this.urlLoader = null;
		}
		
		if (this.loader != null)
		{
			this.loader.contentLoaderInfo.removeEventListener(openfl.events.Event.COMPLETE, loader_completeHandler);
			this.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loader_progressHandler);
			this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loader_ioErrorHandler);
			this.loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler);
			if (close)
			{
				var closed:Bool = false;
				if (!this._imageDecodingOnLoad)
				{
					//when using ImageDecodingPolicy.ON_LOAD, calling close()
					//seems to cause the image data to get stuck in memory,
					//unable to be garbage collected!
					//to clean up the memory, we need to wait for Event.COMPLETE
					//to dispose the BitmapData and call unload(). we can't do
					//either of those things here.
					try
					{
						this.loader.close();
						closed = true;
					}
					catch(error:Error)
					{
					}
				}
				if (!closed)
				{
					//if we couldn't close() the loader, for some reason,
					//our best option is to let it complete and clean
					//things up then.
					this.loader.contentLoaderInfo.addEventListener(openfl.events.Event.COMPLETE, orphanedLoader_completeHandler);
					//be sure to add listeners for these events, or errors
					//could be thrown! issue #1627
					this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, orphanedLoader_errorHandler);
					this.loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, orphanedLoader_errorHandler);
				}
			}
			this.loader = null;
		}
	}
	
	/**
	 * @private
	 */
	private function findSourceInCache():Bool
	{
		var cacheKey:String = this.sourceToTextureCacheKey(this._source);
		if (this._textureCache != null && !this._isRestoringTexture &&
			cacheKey != null && this._textureCache.hasTexture(cacheKey))
		{
			this._texture = this._textureCache.retainTexture(cacheKey);
			this._isTextureOwner = false;
			this._isRestoringTexture = false;
			this._isLoaded = true;
			this.refreshCurrentTexture();
			this.dispatchEventWith(starling.events.Event.COMPLETE);
			return true;
		}
		return false;
	}
	
	/**
	 * @private
	 * Subclasses may override this method to support sources other than
	 * URLs in the texture cache.
	 */
	private function sourceToTextureCacheKey(source:Dynamic):String
	{
		if (Std.isOfType(source, String))
		{
			return cast source;
		}
		return null;
	}
	
	/**
	 * @private
	 */
	private function verifyCurrentStarling():Void
	{
		if (this.stage == null || Starling.current.stage == this.stage)
		{
			return;
		}
		this.stage.starling.makeCurrent();
	}
	
	/**
	 * @private
	 */
	private function replaceBitmapDataTexture(bitmapData:BitmapData):Void
	{
		var starlingInstance:Starling = this.stage != null ? this.stage.starling : Starling.current;
		if (!starlingInstance.contextValid)
		{
			//this trace duplicates the behavior of AssetManager
			trace(CONTEXT_LOST_WARNING);
			Lib.setTimeout(replaceBitmapDataTexture, 1, [bitmapData]);
			return;
		}
		if (!SystemUtil.isDesktop && !SystemUtil.isApplicationActive)
		{
			//avoiding stage3d calls when a mobile application isn't active
			SystemUtil.executeWhenApplicationIsActive(replaceBitmapDataTexture, [bitmapData]);
			return;
		}
		this.verifyCurrentStarling();
		
		if (this.findSourceInCache())
		{
			//someone else added this URL to the cache while we were in the
			//middle of loading it. we can reuse the texture from the cache!
			
			//don't forget to dispose the BitmapData, though...
			bitmapData.dispose();
			
			//then invalidate so that everything is resized correctly
			this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
			return;
		}
		
		if (this._texture == null)
		{
			//skip Texture.fromBitmapData() because we don't want
			//it to create an onRestore function that will be
			//immediately discarded for garbage collection.
			try
			{
				this._texture = Texture.empty(bitmapData.width / this._scaleFactor,
					bitmapData.height / this._scaleFactor, true, false, false,
					this._scaleFactor, this._textureFormat);
			}
			catch(error:Error)
			{
				this.cleanupTexture();
				this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
				this.dispatchEventWith(starling.events.Event.IO_ERROR, false, new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, error.toString()));
				return;
			}
			this._texture.root.onRestore = this.createTextureOnRestore(this._texture,
				this._source, this._textureFormat, this._scaleFactor);
			if (this._textureCache != null)
			{
				var cacheKey:String = this.sourceToTextureCacheKey(this._source);
				if (cacheKey != null)
				{
					this._textureCache.addTexture(cacheKey, this._texture, true);
				}
			}
		}
		if (this._asyncTextureUpload)
		{
			this._texture.root.uploadBitmapData(bitmapData, function(tex:ConcreteTexture):Void
			{
				if (image != null)
				{
					//this isn't technically required because other properties of
					//the Image will be changed, but to avoid potential future
					//refactoring headaches, it won't hurt to be extra careful.
					image.setRequiresRedraw();
				}
				bitmapData.dispose();
				_isTextureOwner = _textureCache == null;
				_isRestoringTexture = false;
				_isLoaded = true;
				refreshCurrentTexture();
				invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
				dispatchEventWith(starling.events.Event.COMPLETE);
			});
		}
		else //synchronous
		{
			this._texture.root.uploadBitmapData(bitmapData);
			if (this.image != null)
			{
				//this isn't technically required because other properties of
				//the Image will be changed, but to avoid potential future
				//refactoring headaches, it won't hurt to be extra careful.
				this.image.setRequiresRedraw();
			}
			bitmapData.dispose();
			this._isTextureOwner = this._textureCache == null;
			this._isRestoringTexture = false;
			this._isLoaded = true;
			//let's refresh the texture right away so that properties like
			//originalSourceWidth and originalSourceHeight return the
			//correct values in the Event.COMPLETE listeners.
			this.refreshCurrentTexture();
			//we can still do other things later, like layout
			this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
			this.dispatchEventWith(starling.events.Event.COMPLETE);
		}
	}
	
	/**
	 * @private
	 */
	private function replaceRawTextureData(rawData:ByteArray):Void
	{
		var starlingInstance:Starling = this.stage != null ? this.stage.starling : Starling.current;
		if (!starlingInstance.contextValid)
		{
			//this trace duplicates the behavior of AssetManager
			trace(CONTEXT_LOST_WARNING);
			Lib.setTimeout(replaceRawTextureData, 1, [rawData]);
			return;
		}
		if (!SystemUtil.isDesktop && !SystemUtil.isApplicationActive)
		{
			//avoiding stage3d calls when a mobile application isn't active
			SystemUtil.executeWhenApplicationIsActive(replaceRawTextureData, [rawData]);
			return;
		}
		this.verifyCurrentStarling();
		
		if (this.findSourceInCache())
		{
			//someone else added this URL to the cache while we were in the
			//middle of loading it. we can reuse the texture from the cache!
			
			//don't forget to clear the ByteArray, though...
			rawData.clear();
			
			//then invalidate so that everything is resized correctly
			this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
			return;
		}
		
		if (this._texture != null)
		{
			this._texture.root.uploadAtfData(rawData);
		}
		else
		{
			try
			{
				this._texture = Texture.fromAtfData(rawData, this._scaleFactor);
			}
			catch(error:Error)
			{
				this.cleanupTexture();
				this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
				this.dispatchEventWith(starling.events.Event.IO_ERROR, false, new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, error.toString()));
				return;
			}
			this._texture.root.onRestore = this.createTextureOnRestore(this._texture,
				this._source, this._textureFormat, this._scaleFactor);
			if (this._textureCache != null)
			{
				var cacheKey:String = this.sourceToTextureCacheKey(this._source);
				if (cacheKey != null)
				{
					this._textureCache.addTexture(cacheKey, this._texture, true);
				}
			}
		}
		rawData.clear();
		//if we have a cache for the textures, then the cache is the owner
		//because other ImageLoaders may use the same texture.
		this._isTextureOwner = this._textureCache == null;
		this._isRestoringTexture = false;
		this._isLoaded = true;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.dispatchEventWith(starling.events.Event.COMPLETE);
	}
	
	/**
	 * @private
	 */
	private function addToTextureQueue():Void
	{
		if (!this._delayTextureCreation)
		{
			throw new IllegalOperationError("Cannot add loader to delayed texture queue if delayTextureCreation is false.");
		}
		if (this._textureQueueDuration == Math.POSITIVE_INFINITY)
		{
			throw new IllegalOperationError("Cannot add loader to delayed texture queue if textureQueueDuration is Number.POSITIVE_INFINITY.");
		}
		if (this._isInTextureQueue)
		{
			throw new IllegalOperationError("Cannot add loader to delayed texture queue more than once.");
		}
		this.addEventListener(starling.events.Event.REMOVED_FROM_STAGE, imageLoader_removedFromStageHandler);
		this._isInTextureQueue = true;
		if (textureQueueTail != null)
		{
			textureQueueTail._textureQueueNext = this;
			this._textureQueuePrevious = textureQueueTail;
			textureQueueTail = this;
		}
		else
		{
			textureQueueHead = this;
			textureQueueTail = this;
			this.preparePendingTexture();
		}
	}
	
	/**
	 * @private
	 */
	private function removeFromTextureQueue():Void
	{
		if (!this._isInTextureQueue)
		{
			return;
		}
		var previous:ImageLoader = this._textureQueuePrevious;
		var next:ImageLoader = this._textureQueueNext;
		this._textureQueuePrevious = null;
		this._textureQueueNext = null;
		this._isInTextureQueue = false;
		this.removeEventListener(starling.events.Event.REMOVED_FROM_STAGE, imageLoader_removedFromStageHandler);
		this.removeEventListener(EnterFrameEvent.ENTER_FRAME, processTextureQueue_enterFrameHandler);
		if (previous != null)
		{
			previous._textureQueueNext = next;
		}
		if (next != null)
		{
			next._textureQueuePrevious = previous;
		}
		var wasHead:Bool = textureQueueHead == this;
		var wasTail:Bool = textureQueueTail == this;
		if (wasTail)
		{
			textureQueueTail = previous;
			if (wasHead)
			{
				textureQueueHead = previous;
			}
		}
		if (wasHead)
		{
			textureQueueHead = next;
			if (wasTail)
			{
				textureQueueTail = next;
			}
		}
		if (wasHead && textureQueueHead != null)
		{
			textureQueueHead.preparePendingTexture();
		}
	}
	
	/**
	 * @private
	 */
	private function preparePendingTexture():Void
	{
		if (this._textureQueueDuration > 0)
		{
			this._accumulatedPrepareTextureTime = 0;
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, processTextureQueue_enterFrameHandler);
		}
		else
		{
			this.processPendingTexture();
		}
	}
	
	/**
	 * @private
	 */
	private function processPendingTexture():Void
	{
		if (this._pendingBitmapDataTexture != null)
		{
			var bitmapData:BitmapData = this._pendingBitmapDataTexture;
			this._pendingBitmapDataTexture = null;
			this.replaceBitmapDataTexture(bitmapData);
		}
		if (this._pendingRawTextureData != null)
		{
			var rawData:ByteArray = this._pendingRawTextureData;
			this._pendingRawTextureData = null;
			this.replaceRawTextureData(rawData);
		}
		if (this._isInTextureQueue)
		{
			this.removeFromTextureQueue();
		}
	}
	
	/**
	 * @private
	 */
	private function createTextureOnRestore(texture:Texture, source:Dynamic,
		format:String, scaleFactor:Float):ConcreteTexture->Void
	{
		return function(tex:ConcreteTexture):Void
		{
			if (_texture == texture)
			{
				texture_onRestore();
				return;
			}
			//this is a hacky way to handle restoring the texture when the
			//current ImageLoader is no longer displaying the texture being
			//restored.
			var otherLoader:ImageLoader = new ImageLoader();
			otherLoader.source = source;
			otherLoader._texture = texture;
			otherLoader._textureFormat = format;
			otherLoader._scaleFactor = scaleFactor;
			otherLoader.validate();
			otherLoader.addEventListener(starling.events.Event.COMPLETE, onRestore_onComplete);
		};
	}
	
	/**
	 * @private
	 */
	private function onRestore_onComplete(event:starling.events.Event):Void
	{
		var otherLoader:ImageLoader = cast event.currentTarget;
		otherLoader._isTextureOwner = false;
		otherLoader._texture = null;
		otherLoader.dispose();
	}
	
	/**
	 * @private
	 */
	private function texture_onRestore():Void
	{
		//reload the texture from the URL
		this._isRestoringTexture = true;
		this._lastURL = null;
		this._isLoaded = false;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
	}
	
	/**
	 * @private
	 */
	private function processTextureQueue_enterFrameHandler(event:EnterFrameEvent):Void
	{
		this._accumulatedPrepareTextureTime += event.passedTime;
		if (this._accumulatedPrepareTextureTime >= this._textureQueueDuration)
		{
			this.removeEventListener(EnterFrameEvent.ENTER_FRAME, processTextureQueue_enterFrameHandler);
			this.processPendingTexture();
		}
	}
	
	/**
	 * @private
	 */
	private function imageLoader_removedFromStageHandler(event:starling.events.Event):Void
	{
		if (this._isInTextureQueue)
		{
			this.removeFromTextureQueue();
		}
	}
	
	/**
	 * @private
	 */
	private function loader_completeHandler(event:openfl.events.Event):Void
	{
		var bitmap:Bitmap = cast this.loader.content;
		this.cleanupLoaders(false);
		
		var bitmapData:BitmapData = bitmap.bitmapData;
		
		//if the upload is synchronous, attempt to reuse the existing
		//texture so that we don't need to create a new one.
		//when AIR-4198247 is fixed in a stable build, this can be removed
		//(perhaps with some kind of AIR version detection, though)
		var canReuseTexture:Bool =
			this._texture != null &&
			(!Texture.asyncBitmapUploadEnabled || !this._asyncTextureUpload) &&
			this._texture.nativeWidth == bitmapData.width &&
			this._texture.nativeHeight == bitmapData.height &&
			this._texture.scale == this._scaleFactor &&
			this._texture.format == this._textureFormat;
		if (!canReuseTexture)
		{
			this.cleanupTexture();
			if (this._textureCache != null)
			{
				//we need to replace the current texture in the cache,
				//so we need to remove the old one so that the cache
				//doesn't throw an error because there's already a
				//texture with this key.
				var key:String = this.sourceToTextureCacheKey(this._source);
				this._textureCache.removeTexture(key);
			}
		}
		if (this._delayTextureCreation && !this._isRestoringTexture)
		{
			this._pendingBitmapDataTexture = bitmapData;
			if (this._textureQueueDuration < Math.POSITIVE_INFINITY)
			{
				this.addToTextureQueue();
			}
		}
		else
		{
			this.replaceBitmapDataTexture(bitmapData);
		}
	}
	
	/**
	 * @private
	 */
	private function loader_progressHandler(event:ProgressEvent):Void
	{
		this.dispatchEventWith(FeathersEventType.PROGRESS, false, event.bytesLoaded / event.bytesTotal);
	}
	
	/**
	 * @private
	 */
	private function loader_ioErrorHandler(event:IOErrorEvent):Void
	{
		this.cleanupLoaders(false);
		this.cleanupTexture();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.dispatchEventWith(FeathersEventType.ERROR, false, event);
		this.dispatchEventWith(starling.events.Event.IO_ERROR, false, event);
	}
	
	/**
	 * @private
	 */
	private function loader_securityErrorHandler(event:SecurityErrorEvent):Void
	{
		this.cleanupLoaders(false);
		this.cleanupTexture();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.dispatchEventWith(FeathersEventType.ERROR, false, event);
		this.dispatchEventWith(starling.events.Event.SECURITY_ERROR, false, event);
	}
	
	/**
	 * @private
	 */
	private function orphanedLoader_completeHandler(event:openfl.events.Event):Void
	{
		var loaderInfo:LoaderInfo = cast event.currentTarget;
		loaderInfo.removeEventListener(flash.events.Event.COMPLETE, orphanedLoader_completeHandler);
		loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, orphanedLoader_errorHandler);
		loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, orphanedLoader_errorHandler);
		var loader:Loader = loaderInfo.loader;
		var bitmap:Bitmap = cast loader.content;
		bitmap.bitmapData.dispose();
		//we could call unloadAndStop() and force the garbage collector to
		//run, but that could hurt performance, so let it happen naturally.
		loader.unload();
	}
	
	/**
	 * @private
	 */
	private function orphanedLoader_errorHandler(event:openfl.events.Event):Void
	{
		var loaderInfo:LoaderInfo = cast event.currentTarget;
		loaderInfo.removeEventListener(openfl.events.Event.COMPLETE, orphanedLoader_completeHandler);
		loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, orphanedLoader_errorHandler);
		loaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, orphanedLoader_errorHandler);
		//no need to do anything else. this listener only exists to avoid
		//a runtime error on an resource that is no longer required
	}
	
	/**
	 * @private
	 */
	private function rawDataLoader_completeHandler(event:openfl.events.Event):Void
	{
		var rawData:ByteArray = cast this.urlLoader.data;
		this.cleanupLoaders(false);
		
		//only clear the texture if we're not restoring
		if (!this._isRestoringTexture)
		{
			this.cleanupTexture();
		}
		if (this._delayTextureCreation && !this._isRestoringTexture)
		{
			this._pendingRawTextureData = rawData;
			if (this._textureQueueDuration < Math.POSITIVE_INFINITY)
			{
				this.addToTextureQueue();
			}
		}
		else
		{
			this.replaceRawTextureData(rawData);
		}
	}
	
	/**
	 * @private
	 */
	private function rawDataLoader_progressHandler(event:ProgressEvent):Void
	{
		this.dispatchEventWith(FeathersEventType.PROGRESS, false, event.bytesLoaded / event.bytesTotal);
	}
	
	/**
	 * @private
	 */
	private function rawDataLoader_ioErrorHandler(event:ErrorEvent):Void
	{
		this.cleanupLoaders(false);
		this.cleanupTexture();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.dispatchEventWith(FeathersEventType.ERROR, false, event);
		this.dispatchEventWith(starling.events.Event.IO_ERROR, false, event);
	}
	
	/**
	 * @private
	 */
	private function rawDataLoader_securityErrorHandler(event:ErrorEvent):Void
	{
		this.cleanupLoaders(false);
		this.cleanupTexture();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.dispatchEventWith(FeathersEventType.ERROR, false, event);
		this.dispatchEventWith(starling.events.Event.SECURITY_ERROR, false, event);
	}
	
}