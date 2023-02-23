/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import feathers.core.PopUpManager;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.skins.IStyleProvider;
import feathers.utils.display.DisplayUtils;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.type.SafeCast;
import openfl.errors.ArgumentError;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.display.Stage;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * A pop-up container that points at (or calls out) a specific region of
 * the application (typically a specific control that triggered it).
 *
 * <p>In general, a <code>Callout</code> isn't instantiated directly.
 * Instead, you will typically call the static function
 * <code>Callout.show()</code>. This is not required, but it result in less
 * code and no need to manually manage calls to the <code>PopUpManager</code>.</p>
 *
 * <p>In the following example, a callout displaying a <code>Label</code> is
 * shown when a <code>Button</code> is triggered:</p>
 *
 * <listing version="3.0">
 * button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
 * 
 * function button_triggeredHandler( event:Event ):void
 * {
 *     var label:Label = new Label();
 *     label.text = "Hello World!";
 *     var button:Button = Button( event.currentTarget );
 *     Callout.show( label, button );
 * }</listing>
 *
 * @see ../../../help/callout.html How to use the Feathers Callout component
 *
 * @productversion Feathers 1.0.0
 */
class Callout extends FeathersControl 
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>Callout</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

	/**
	 * The default positions used by a callout.
	 */
	public static var DEFAULT_POSITIONS:Array<String> = 
	[
		RelativePosition.BOTTOM,
		RelativePosition.TOP,
		RelativePosition.RIGHT,
		RelativePosition.LEFT,
	];

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_ORIGIN:String = "origin";

	/**
	 * @private
	 */
	private static inline var FUZZY_CONTENT_DIMENSIONS_PADDING:Float = 0.000001;
	
	/**
	 * Quickly sets all stage padding properties to the same value. The
	 * <code>stagePadding</code> getter always returns the value of
	 * <code>stagePaddingTop</code>, but the other padding values may be
	 * different.
	 *
	 * <p>The following example gives the stage 20 pixels of padding on all
	 * sides:</p>
	 *
	 * <listing version="3.0">
	 * Callout.stagePadding = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #stagePaddingTop
	 * @see #stagePaddingRight
	 * @see #stagePaddingBottom
	 * @see #stagePaddingLeft
	 */
	public static var stagePadding(get, set):Float;
	private static function get_stagePadding():Float { return Callout.stagePaddingTop; }
	private static function set_stagePadding(value:Float):Float
	{
		Callout.stagePaddingTop = value;
		Callout.stagePaddingRight = value;
		Callout.stagePaddingBottom = value;
		return Callout.stagePaddingLeft = value;
	}
	
	/**
	 * The padding between a callout and the top edge of the stage when the
	 * callout is positioned automatically. May be ignored if the callout
	 * is too big for the stage.
	 *
	 * <p>In the following example, the top stage padding will be set to
	 * 20 pixels:</p>
	 *
	 * <listing version="3.0">
	 * Callout.stagePaddingTop = 20;</listing>
	 */
	public static var stagePaddingTop:Float = 0;

	/**
	 * The padding between a callout and the right edge of the stage when the
	 * callout is positioned automatically. May be ignored if the callout
	 * is too big for the stage.
	 *
	 * <p>In the following example, the right stage padding will be set to
	 * 20 pixels:</p>
	 *
	 * <listing version="3.0">
	 * Callout.stagePaddingRight = 20;</listing>
	 */
	public static var stagePaddingRight:Float = 0;

	/**
	 * The padding between a callout and the bottom edge of the stage when the
	 * callout is positioned automatically. May be ignored if the callout
	 * is too big for the stage.
	 *
	 * <p>In the following example, the bottom stage padding will be set to
	 * 20 pixels:</p>
	 *
	 * <listing version="3.0">
	 * Callout.stagePaddingBottom = 20;</listing>
	 */
	public static var stagePaddingBottom:Float = 0;

	/**
	 * The margin between a callout and the top edge of the stage when the
	 * callout is positioned automatically. May be ignored if the callout
	 * is too big for the stage.
	 *
	 * <p>In the following example, the left stage padding will be set to
	 * 20 pixels:</p>
	 *
	 * <listing version="3.0">
	 * Callout.stagePaddingLeft = 20;</listing>
	 */
	public static var stagePaddingLeft:Float = 0;
	
	/**
	 * Returns a new <code>Callout</code> instance when
	 * <code>Callout.show()</code> is called. If one wishes to skin the
	 * callout manually or change its behavior, a custom factory may be
	 * provided.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():Callout</pre>
	 *
	 * <p>The following example shows how to create a custom callout factory:</p>
	 *
	 * <listing version="3.0">
	 * Callout.calloutFactory = function():Callout
	 * {
	 *     var callout:Callout = new Callout();
	 *     //set properties here!
	 *     return callout;
	 * };</listing>
	 *
	 * <p>Note: the default callout factory sets the following properties:</p>
	 *
	 * <listing version="3.0">
	 * callout.closeOnTouchBeganOutside = true;
	 * callout.closeOnTouchEndedOutside = true;
	 * callout.closeOnKeys = new &lt;uint&gt;[Keyboard.BACK, Keyboard.ESCAPE];</listing>
	 *
	 * @see #show()
	 */
	public static var calloutFactory:Void->Callout = defaultCalloutFactory;
	
	/**
	 * Returns an overlay to display with a callout that is modal. Uses the
	 * standard <code>overlayFactory</code> of the <code>PopUpManager</code>
	 * by default, but you can use this property to provide your own custom
	 * overlay, if you prefer.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function():DisplayObject</pre>
	 *
	 * <p>The following example uses a semi-transparent <code>Quad</code> as
	 * a custom overlay:</p>
	 *
	 * <listing version="3.0">
	 * Callout.calloutOverlayFactory = function():Quad
	 * {
	 *     var quad:Quad = new Quad(10, 10, 0x000000);
	 *     quad.alpha = 0.75;
	 *     return quad;
	 * };</listing>
	 *
	 * @see feathers.core.PopUpManager#overlayFactory
	 *
	 * @see #show()
	 */
	public static var calloutOverlayFactory:Void->DisplayObject = PopUpManager.defaultOverlayFactory;
	
	/**
	 * Creates a callout, and then positions and sizes it automatically
	 * based on an origin rectangle and the specified direction relative to
	 * the original. The provided width and height values are optional, and
	 * these values may be ignored if the callout cannot be drawn at the
	 * specified dimensions.
	 *
	 * <p>The <code>supportedPositions</code> parameter should be a
	 * <code>Vector.&lt;String&gt;</code> of values from the
	 * <code>feathers.layout.RelativePosition</code> class. The positions
	 * should be ordered by preference. This parameter is typed as
	 * <code>Object</code> to allow some deprecated <code>String</code>
	 * values. In a future version of Feathers, the type will change to
	 * <code>Vector.&lt;String&gt;</code> instead.</p>
	 *
	 * <p>In the following example, a callout displaying a <code>Label</code> is
	 * shown when a <code>Button</code> is triggered:</p>
	 *
	 * <listing version="3.0">
	 * button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
	 * 
	 * function button_triggeredHandler( event:Event ):void
	 * {
	 *     var label:Label = new Label();
	 *     label.text = "Hello World!";
	 *     var button:Button = Button( event.currentTarget );
	 *     Callout.show( label, button );
	 * }</listing>
	 */
	public static function show(content:DisplayObject, origin:DisplayObject,
		supportedPositions:Array<String> = null, isModal:Bool = true, customCalloutFactory:Void->Callout = null,
		customOverlayFactory:Void->Quad = null):Callout
	{
		if (origin.stage == null)
		{
			throw new ArgumentError("Callout origin must be added to the stage.");
		}
		var factory:Void->Callout = customCalloutFactory;
		if (factory == null)
		{
			factory = calloutFactory;
			if (factory == null)
			{
				factory = defaultCalloutFactory;
			}
		}
		var callout:Callout = factory();
		callout.content = content;
		callout.supportedPositions = supportedPositions;
		callout.origin = origin;
		var overlayFactory:Void->DisplayObject = customOverlayFactory;
		if (overlayFactory == null)
		{
			overlayFactory = calloutOverlayFactory;
			if (overlayFactory == null)
			{
				overlayFactory = PopUpManager.defaultOverlayFactory;
			}
		}
		PopUpManager.addPopUp(callout, isModal, false, overlayFactory);
		return callout;
	}
	
	/**
	 * The default factory that creates callouts when <code>Callout.show()</code>
	 * is called. To use a different factory, you need to set
	 * <code>Callout.calloutFactory</code> to a <code>Function</code>
	 * instance.
	 */
	public static function defaultCalloutFactory():Callout
	{
		var callout:Callout = new Callout();
		callout.closeOnTouchBeganOutside = true;
		callout.closeOnTouchEndedOutside = true;
		#if flash
		callout.closeOnKeys = [Keyboard.BACK, Keyboard.ESCAPE];
		#else
		callout.closeOnKeys = [Keyboard.ESCAPE];
		#end
		return callout;
	}
	
	/**
	 * @private
	 */
	private static function positionBelowOrigin(callout:Callout, globalOrigin:Rectangle):Void
	{
		callout.measureWithArrowPosition(RelativePosition.TOP);
		var idealXPosition:Float = globalOrigin.x;
		if (callout._horizontalAlign == HorizontalAlign.CENTER)
		{
			idealXPosition += Math.fround((globalOrigin.width - callout.width) / 2);
		}
		else if (callout._horizontalAlign == HorizontalAlign.RIGHT)
		{
			idealXPosition += (globalOrigin.width - callout.width);
		}
		var xPosition:Float = idealXPosition;
		if (stagePaddingLeft > xPosition)
		{
			xPosition = stagePaddingLeft;
		}
		else
		{
			var stage:Stage = callout.stage != null ? callout.stage : Starling.current.stage;
			var maxXPosition:Float = stage.stageWidth - callout.width - stagePaddingRight;
			if (maxXPosition < xPosition)
			{
				xPosition = maxXPosition;
			}
		}
		var point:Point = Pool.getPoint(xPosition, globalOrigin.y + globalOrigin.height);
		//we calculate the position in global coordinates, but the callout
		//may be in a container that is offset from the global origin, so
		//adjust for that difference.
		callout.parent.globalToLocal(point, point);
		callout.x = point.x;
		callout.y = point.y + callout._originGap;
		Pool.putPoint(point);
		if (callout._isValidating)
		{
			//no need to invalidate and need to validate again next frame
			callout._arrowOffset = idealXPosition - xPosition;
			callout._arrowPosition = RelativePosition.TOP;
		}
		else
		{
			callout.arrowOffset = idealXPosition - xPosition;
			callout.arrowPosition = RelativePosition.TOP;
		}
	}
	
	/**
	 * @private
	 */
	private static function positionAboveOrigin(callout:Callout, globalOrigin:Rectangle):Void
	{
		callout.measureWithArrowPosition(RelativePosition.BOTTOM);
		var idealXPosition:Float = globalOrigin.x;
		if (callout._horizontalAlign == HorizontalAlign.CENTER)
		{
			idealXPosition += Math.fround((globalOrigin.width - callout.width) / 2);
		}
		else if (callout._horizontalAlign == HorizontalAlign.RIGHT)
		{
			idealXPosition += (globalOrigin.width - callout.width);
		}
		var xPosition:Float = idealXPosition;
		if (stagePaddingLeft > xPosition)
		{
			xPosition = stagePaddingLeft;
		}
		else
		{
			var stage:Stage = callout.stage != null ? callout.stage : Starling.current.stage;
			var maxXPosition:Float = stage.stageWidth - callout.width - stagePaddingRight;
			if (maxXPosition < xPosition)
			{
				xPosition = maxXPosition;
			}
		}
		var point:Point = Pool.getPoint(xPosition, globalOrigin.y - callout.height);
		//we calculate the position in global coordinates, but the callout
		//may be in a container that is offset from the global origin, so
		//adjust for that difference.
		callout.parent.globalToLocal(point, point);
		callout.x = point.x;
		callout.y = point.y - callout._originGap;
		Pool.putPoint(point);
		if (callout._isValidating)
		{
			//no need to invalidate and need to validate again next frame
			callout._arrowOffset = idealXPosition - xPosition;
			callout._arrowPosition = RelativePosition.BOTTOM;
		}
		else
		{
			callout.arrowOffset = idealXPosition - xPosition;
			callout.arrowPosition = RelativePosition.BOTTOM;
		}
	}
	
	/**
	 * @private
	 */
	private static function positionToRightOfOrigin(callout:Callout, globalOrigin:Rectangle):Void
	{
		callout.measureWithArrowPosition(RelativePosition.LEFT);
		var idealYPosition:Float = globalOrigin.y;
		if (callout._verticalAlign == VerticalAlign.MIDDLE)
		{
			idealYPosition += Math.fround((globalOrigin.height - callout.height) / 2);
		}
		else if (callout._verticalAlign == VerticalAlign.BOTTOM)
		{
			idealYPosition += (globalOrigin.height - callout.height);
		}
		var yPosition:Float = idealYPosition;
		if (stagePaddingTop > yPosition)
		{
			yPosition = stagePaddingTop;
		}
		else
		{
			var stage:Stage = callout.stage != null ? callout.stage : Starling.current.stage;
			var maxYPosition:Float = stage.stageHeight - callout.height - stagePaddingBottom;
			if (maxYPosition < yPosition)
			{
				yPosition = maxYPosition;
			}
		}
		var point:Point = Pool.getPoint(globalOrigin.x + globalOrigin.width, yPosition);
		//we calculate the position in global coordinates, but the callout
		//may be in a container that is offset from the global origin, so
		//adjust for that difference.
		callout.parent.globalToLocal(point, point);
		callout.x = point.x + callout._originGap;
		callout.y = point.y;
		Pool.putPoint(point);
		if (callout._isValidating)
		{
			//no need to invalidate and need to validate again next frame
			callout._arrowOffset = idealYPosition - yPosition;
			callout._arrowPosition = RelativePosition.LEFT;
		}
		else
		{
			callout.arrowOffset = idealYPosition - yPosition;
			callout.arrowPosition = RelativePosition.LEFT;
		}
	}
	
	/**
	 * @private
	 */
	private static function positionToLeftOfOrigin(callout:Callout, globalOrigin:Rectangle):Void
	{
		callout.measureWithArrowPosition(RelativePosition.RIGHT);
		var idealYPosition:Float = globalOrigin.y;
		if (callout._verticalAlign == VerticalAlign.MIDDLE)
		{
			idealYPosition += Math.round((globalOrigin.height - callout.height) / 2);
		}
		else if (callout._verticalAlign == VerticalAlign.BOTTOM)
		{
			idealYPosition += (globalOrigin.height - callout.height);
		}
		var yPosition:Float = idealYPosition;
		if (stagePaddingTop > yPosition)
		{
			yPosition = stagePaddingTop;
		}
		else
		{
			var stage:Stage = callout.stage != null ? callout.stage : Starling.current.stage;
			var maxYPosition:Float = stage.stageHeight - callout.height - stagePaddingBottom;
			if (maxYPosition < yPosition)
			{
				yPosition = maxYPosition;
			}
		}
		var point:Point = Pool.getPoint(globalOrigin.x - callout.width, yPosition);
		//we calculate the position in global coordinates, but the callout
		//may be in a container that is offset from the global origin, so
		//adjust for that difference.
		callout.parent.globalToLocal(point, point);
		callout.x = point.x - callout._originGap;
		callout.y = point.y;
		Pool.putPoint(point);
		if (callout._isValidating)
		{
			//no need to invalidate and need to validate again next frame
			callout._arrowOffset = idealYPosition - yPosition;
			callout._arrowPosition = RelativePosition.RIGHT;
		}
		else
		{
			callout.arrowOffset = idealYPosition - yPosition;
			callout.arrowPosition = RelativePosition.RIGHT;
		}
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, callout_addedToStageHandler);
	}
	
	/**
	 * Determines if the callout is automatically closed if a touch in the
	 * <code>TouchPhase.BEGAN</code> phase happens outside of the callout's
	 * or the origin's bounds.
	 *
	 * <p>In the following example, the callout will not close when a touch
	 * event with <code>TouchPhase.BEGAN</code> is detected outside the
	 * callout's (or its origin's) bounds:</p>
	 *
	 * <listing version="3.0">
	 * callout.closeOnTouchBeganOutside = false;</listing>
	 *
	 * @see #closeOnTouchEndedOutside
	 * @see #closeOnKeys
	 */
	public var closeOnTouchBeganOutside:Bool = false;

	/**
	 * Determines if the callout is automatically closed if a touch in the
	 * <code>TouchPhase.ENDED</code> phase happens outside of the callout's
	 * or the origin's bounds.
	 *
	 * <p>In the following example, the callout will not close when a touch
	 * event with <code>TouchPhase.ENDED</code> is detected outside the
	 * callout's (or its origin's) bounds:</p>
	 *
	 * <listing version="3.0">
	 * callout.closeOnTouchEndedOutside = false;</listing>
	 *
	 * @see #closeOnTouchBeganOutside
	 * @see #closeOnKeys
	 */
	public var closeOnTouchEndedOutside:Bool = false;
	
	/**
	 * The callout will be closed if any of these keys are pressed.
	 *
	 * <p>In the following example, the callout close when the Escape key
	 * is pressed:</p>
	 *
	 * <listing version="3.0">
	 * callout.closeOnKeys = new &lt;uint&gt;[Keyboard.ESCAPE];</listing>
	 *
	 * @see #closeOnTouchBeganOutside
	 * @see #closeOnTouchEndedOutside
	 */
	public var closeOnKeys:Array<Int>;
	
	/**
	 * Determines if the callout will be disposed when <code>close()</code>
	 * is called internally. Close may be called internally in a variety of
	 * cases, depending on values such as <code>closeOnTouchBeganOutside</code>,
	 * <code>closeOnTouchEndedOutside</code>, and <code>closeOnKeys</code>.
	 * If set to <code>false</code>, you may reuse the callout later by
	 * giving it a new <code>origin</code> and adding it to the
	 * <code>PopUpManager</code> again.
	 *
	 * <p>In the following example, the callout will not be disposed when it
	 * closes itself:</p>
	 *
	 * <listing version="3.0">
	 * callout.disposeOnSelfClose = false;</listing>
	 *
	 * @see #closeOnTouchBeganOutside
	 * @see #closeOnTouchEndedOutside
	 * @see #closeOnKeys
	 * @see #close()
	 */
	public var disposeOnSelfClose:Bool = true;
	
	/**
	 * Determines if the callout's content will be disposed when the callout
	 * is disposed. If set to <code>false</code>, the callout's content may
	 * be added to the display list again later.
	 *
	 * <p>In the following example, the callout's content will not be
	 * disposed when the callout is disposed:</p>
	 *
	 * <listing version="3.0">
	 * callout.disposeContent = false;</listing>
	 */
	public var disposeContent:Bool = true;
	
	/**
	 * @private
	 */
	private var _isReadyToClose:Bool = false;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return Callout.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var _explicitContentWidth:Float;

	/**
	 * @private
	 */
	private var _explicitContentHeight:Float;

	/**
	 * @private
	 */
	private var _explicitContentMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitContentMinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitContentMaxWidth:Float;

	/**
	 * @private
	 */
	private var _explicitContentMaxHeight:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinMinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinMaxWidth:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinMaxHeight:Float;
	
	/**
	 * The display object that will be presented by the callout. This object
	 * may be resized to fit the callout's bounds. If the content needs to
	 * be scrolled if placed into a smaller region than its ideal size, it
	 * must provide its own scrolling capabilities because the callout does
	 * not offer scrolling.
	 *
	 * <p>In the following example, the callout's content is an image:</p>
	 *
	 * <listing version="3.0">
	 * callout.content = new Image( texture );</listing>
	 *
	 * @default null
	 */
	public var content(get, set):DisplayObject;
	private var _content:DisplayObject;
	private function get_content():DisplayObject { return this._content; }
	private function set_content(value:DisplayObject):DisplayObject
	{
		if (this._content == value)
		{
			return value;
		}
		var measureContent:IMeasureDisplayObject;
		if (this._content != null)
		{
			if (Std.isOfType(this._content, IFeathersControl))
			{
				this._content.removeEventListener(FeathersEventType.RESIZE, content_resizeHandler);
			}
			if (this._content.parent == this)
			{
				this._content.width = this._explicitContentWidth;
				this._content.height = this._explicitContentHeight;
				if (Std.isOfType(this._content, IMeasureDisplayObject))
				{
					measureContent = cast this._content;
					measureContent.minWidth = this._explicitContentMinWidth;
					measureContent.minHeight = this._explicitContentMinHeight;
					measureContent.maxWidth = this._explicitContentMaxWidth;
					measureContent.maxHeight = this._explicitContentMaxHeight;
				}
				this._content.removeFromParent(false);
			}
		}
		this._content = value;
		if (this._content != null)
		{
			if (Std.isOfType(this._content, IFeathersControl))
			{
				this._content.addEventListener(FeathersEventType.RESIZE, content_resizeHandler);
			}
			this.addChild(this._content);
			if (Std.isOfType(this._content, IFeathersControl))
			{
				cast(this._content, IFeathersControl).initializeNow();
			}
			if (this._content is IMeasureDisplayObject)
			{
				measureContent = cast this._content;
				this._explicitContentWidth = measureContent.explicitWidth;
				this._explicitContentHeight = measureContent.explicitHeight;
				this._explicitContentMinWidth = measureContent.explicitMinWidth;
				this._explicitContentMinHeight = measureContent.explicitMinHeight;
				this._explicitContentMaxWidth = measureContent.explicitMaxWidth;
				this._explicitContentMaxHeight = measureContent.explicitMaxHeight;
			}
			else
			{
				this._explicitContentWidth = this._content.width;
				this._explicitContentHeight = this._content.height;
				this._explicitContentMinWidth = this._explicitContentWidth;
				this._explicitContentMinHeight = this._explicitContentHeight;
				this._explicitContentMaxWidth = this._explicitContentWidth;
				this._explicitContentMaxHeight = this._explicitContentHeight;
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._content;
	}
	
	/**
	 * A callout may be positioned relative to another display object, known
	 * as the callout's origin. Even if the position of the origin changes,
	 * the callout will reposition itself to always point at the origin.
	 *
	 * <p>When an origin is set, the <code>arrowPosition</code> and
	 * <code>arrowOffset</code> properties will be managed automatically by
	 * the callout. Setting either of these values manually will either have
	 * no effect or unexpected behavior, so it is recommended that you
	 * avoid modifying those properties.</p>
	 *
	 * <p>Note: The <code>origin</code> is excluded when using
	 * <code>closeOnTouchBeganOutside</code> and <code>closeOnTouchEndedOutside</code>.
	 * In other words, when the origin is touched, and either of these
	 * properties is <code>true</code>, the callout will not be closed. If
	 * the callout is not displayed modally, and touching the origin opens
	 * the callout, you should check if a callout is already visible. If a
	 * callout is visible, close it. If no callouts are visible, show one.
	 * However, if the callout is modal, the touch will be stopped by the
	 * overlay before it reaches the origin, so this behavior will not apply.</p>
	 *
	 * <p>In general, if you use <code>Callout.show()</code>, you will
	 * rarely need to manually manage the <code>origin</code> property.</p>
	 *
	 * <p>In the following example, the callout's origin is set to a button:</p>
	 *
	 * <listing version="3.0">
	 * callout.origin = button;</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Callout#show()
	 * @see #supportedPositions
	 */
	public var origin(get, set):DisplayObject;
	private var _origin:DisplayObject;
	private function get_origin():DisplayObject { return this._origin; }
	private function set_origin(value:DisplayObject):DisplayObject
	{
		if (this._origin == value)
		{
			return value;
		}
		if (value != null && value.stage == null)
		{
			throw new ArgumentError("Callout origin must have access to the stage.");
		}
		if (this._origin != null)
		{
			this.removeEventListener(EnterFrameEvent.ENTER_FRAME, callout_enterFrameHandler);
			this._origin.removeEventListener(Event.REMOVED_FROM_STAGE, origin_removedFromStageHandler);
		}
		this._origin = value;
		this._lastGlobalBoundsOfOrigin = null;
		if (this._origin != null)
		{
			this._origin.addEventListener(Event.REMOVED_FROM_STAGE, origin_removedFromStageHandler);
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, callout_enterFrameHandler);
		}
		this.invalidate(INVALIDATION_FLAG_ORIGIN);
		return this._origin;
	}
	
	/**
	 * The position of the callout, relative to its origin. Accepts a
	 * <code>Vector.&lt;String&gt;</code> containing one or more of the
	 * constants from <code>feathers.layout.RelativePosition</code> or
	 * <code>null</code>. If <code>null</code>, the callout will attempt to
	 * position itself using values in the following order:
	 *
	 * <ul>
	 *     <li><code>RelativePosition.BOTTOM</code></li>
	 *     <li><code>RelativePosition.TOP</code></li>
	 *     <li><code>RelativePosition.RIGHT</code></li>
	 *     <li><code>RelativePosition.LEFT</code></li>
	 * </ul>
	 *
	 * <p>Note: If the callout's origin is not set, the
	 * <code>supportedPositions</code> property will be ignored.</p>
	 *
	 * <p>In the following example, the callout's supported positions are
	 * restricted to the top and bottom of the origin:</p>
	 *
	 * <listing version="3.0">
	 * callout.supportedPositions = new &lt;String&gt;[RelativePosition.TOP, RelativePosition.BOTTOM];</listing>
	 *
	 * <p>In the following example, the callout's position is restricted to
	 * the right of the origin:</p>
	 *
	 * <listing version="3.0">
	 * callout.supportedPositions = new &lt;String&gt;[RelativePosition.RIGHT];</listing>
	 *
	 * <p>Note: The <code>arrowPosition</code> property is related to this
	 * one, but they have different meanings and are usually opposites. For
	 * example, a callout on the right side of its origin will generally
	 * display its left arrow.</p>
	 *
	 * @default null
	 *
	 * @see feathers.layout.RelativePosition#TOP
	 * @see feathers.layout.RelativePosition#RIGHT
	 * @see feathers.layout.RelativePosition#BOTTOM
	 * @see feathers.layout.RelativePosition#LEFT
	 */
	public var supportedPositions(get, set):Array<String>;
	private var _supportedPositions:Array<String>;
	private function get_supportedPositions():Array<String> { return this._supportedPositions; }
	private function set_supportedPositions(value:Array<String>):Array<String>
	{
		return this._supportedPositions = value;
	}
	
	/**
	 * @private
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.CENTER;
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
		this._lastGlobalBoundsOfOrigin = null;
		this.invalidate(INVALIDATION_FLAG_ORIGIN);
		return this._horizontalAlign;
	}
	
	/**
	 * @private
	 */
	public var verticalAlign(get, set):String;
	private var _verticalAlign:String = VerticalAlign.MIDDLE;
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
		this._lastGlobalBoundsOfOrigin = null;
		this.invalidate(INVALIDATION_FLAG_ORIGIN);
		return this._verticalAlign;
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
	private function get_paddingRight():Float { return this._paddingRight; }
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
	 * @private
	 */
	public var arrowPosition(get, set):String;
	private var _arrowPosition:String = RelativePosition.TOP;
	private function get_arrowPosition():String { return this._arrowPosition; }
	private function set_arrowPosition(value:String):String
	{
		if (this.processStyleRestriction("arrowPosition"))
		{
			return value;
		}
		if (this._arrowPosition == value)
		{
			return value;
		}
		this._arrowPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._arrowPosition;
	}
	
	/**
	 * @private
	 */
	public var backgroundSkin(get, set):DisplayObject;
	private var _backgroundSkin:DisplayObject;
	private function get_backgroundSkin():DisplayObject { return this._backgroundSkin; }
	private function set_backgroundSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("backgroundSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._backgroundSkin == value)
		{
			return value;
		}
		var measureSkin:IMeasureDisplayObject;
		if (this._backgroundSkin != null && this._backgroundSkin.parent == this)
		{
			//we need to restore these values so that they won't be lost the
			//next time that this skin is used for measurement
			this._backgroundSkin.width = this._explicitBackgroundSkinWidth;
			this._backgroundSkin.height = this._explicitBackgroundSkinHeight;
			if (Std.isOfType(this._backgroundSkin, IMeasureDisplayObject))
			{
				measureSkin = cast this._backgroundSkin;
				measureSkin.minWidth = this._explicitBackgroundSkinMinWidth;
				measureSkin.minHeight = this._explicitBackgroundSkinMinHeight;
				measureSkin.maxWidth = this._explicitBackgroundSkinMaxWidth;
				measureSkin.maxHeight = this._explicitBackgroundSkinMaxHeight;
			}
			this._backgroundSkin.removeFromParent(false);
		}
		this._backgroundSkin = value;
		if (this._backgroundSkin != null)
		{
			if (Std.isOfType(this._backgroundSkin, IFeathersControl))
			{
				cast(this._backgroundSkin, IFeathersControl).initializeNow();
			}
			if (Std.isOfType(this._backgroundSkin, IMeasureDisplayObject))
			{
				measureSkin = cast this._backgroundSkin;
				this._explicitBackgroundSkinWidth = measureSkin.explicitWidth;
				this._explicitBackgroundSkinHeight = measureSkin.explicitHeight;
				this._explicitBackgroundSkinMinWidth = measureSkin.explicitMinWidth;
				this._explicitBackgroundSkinMinHeight = measureSkin.explicitMinHeight;
				this._explicitBackgroundSkinMaxWidth = measureSkin.explicitMaxWidth;
				this._explicitBackgroundSkinMaxHeight = measureSkin.explicitMaxHeight;
			}
			else
			{
				this._explicitBackgroundSkinWidth = this._backgroundSkin.width;
				this._explicitBackgroundSkinHeight = this._backgroundSkin.height;
				this._explicitBackgroundSkinMinWidth = this._explicitBackgroundSkinWidth;
				this._explicitBackgroundSkinMinHeight = this._explicitBackgroundSkinHeight;
				this._explicitBackgroundSkinMaxWidth = this._explicitBackgroundSkinWidth;
				this._explicitBackgroundSkinMaxHeight = this._explicitBackgroundSkinHeight;
			}
			this.addChildAt(this._backgroundSkin, 0);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._backgroundSkin;
	}
	
	/**
	 * @private
	 */
	private var currentArrowSkin:DisplayObject;
	
	/**
	 * @private
	 */
	public var topArrowSkin(get, set):DisplayObject;
	private var _topArrowSkin:DisplayObject;
	private function get_topArrowSkin():DisplayObject { return this._topArrowSkin; }
	private function set_topArrowSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("topArrowSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._topArrowSkin == value)
		{
			return value;
		}
		if (this._topArrowSkin != null && this._topArrowSkin.parent == this)
		{
			this._topArrowSkin.removeFromParent(false);
		}
		this._topArrowSkin = value;
		if (this._topArrowSkin != null)
		{
			this._topArrowSkin.visible = false;
			var index:Int = this.getChildIndex(this._content);
			if (index == -1)
			{
				this.addChild(this._topArrowSkin);
			}
			else
			{
				this.addChildAt(this._topArrowSkin, index);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._topArrowSkin;
	}
	
	/**
	 * @private
	 */
	public var rightArrowSkin(get, set):DisplayObject;
	private var _rightArrowSkin:DisplayObject;
	private function get_rightArrowSkin():DisplayObject { return this._rightArrowSkin; }
	private function set_rightArrowSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("rightArrowSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._rightArrowSkin == value)
		{
			return value;
		}
		if (this._rightArrowSkin != null && this._rightArrowSkin.parent == this)
		{
			this._rightArrowSkin.removeFromParent(false);
		}
		this._rightArrowSkin = value;
		if (this._rightArrowSkin != null)
		{
			this._rightArrowSkin.visible = false;
			var index:Int = this.getChildIndex(this._content);
			if (index == -1)
			{
				this.addChild(this._rightArrowSkin);
			}
			else
			{
				this.addChildAt(this._rightArrowSkin, index);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._rightArrowSkin;
	}
	
	/**
	 * @private
	 */
	public var bottomArrowSkin(get, set):DisplayObject;
	private var _bottomArrowSkin:DisplayObject;
	private function get_bottomArrowSkin():DisplayObject { return this._bottomArrowSkin; }
	private function set_bottomArrowSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("bottomArrowSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._bottomArrowSkin == value)
		{
			return this._bottomArrowSkin;
		}
		if (this._bottomArrowSkin != null && this._bottomArrowSkin.parent == this)
		{
			this._bottomArrowSkin.removeFromParent(false);
		}
		this._bottomArrowSkin = value;
		if (this._bottomArrowSkin != null)
		{
			this._bottomArrowSkin.visible = false;
			var index:Int = this.getChildIndex(this._content);
			if (index == -1)
			{
				this.addChild(this._bottomArrowSkin);
			}
			else
			{
				this.addChildAt(this._bottomArrowSkin, index);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._bottomArrowSkin;
	}
	
	/**
	 * @private
	 */
	public var leftArrowSkin(get, set):DisplayObject;
	private var _leftArrowSkin:DisplayObject;
	private function get_leftArrowSkin():DisplayObject { return this._leftArrowSkin; }
	private function set_leftArrowSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("leftArrowSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._leftArrowSkin == value)
		{
			return value;
		}
		if (this._leftArrowSkin != null && this._leftArrowSkin.parent == this)
		{
			this._leftArrowSkin.removeFromParent(false);
		}
		this._leftArrowSkin = value;
		if (this._leftArrowSkin != null)
		{
			this._leftArrowSkin.visible = false;
			var index:Int = this.getChildIndex(this._content);
			if (index == -1)
			{
				this.addChild(this._leftArrowSkin);
			}
			else
			{
				this.addChildAt(this._leftArrowSkin, index);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._leftArrowSkin;
	}
	
	/**
	 * @private
	 */
	public var originGap(get, set):Float;
	private var _originGap:Float = 0;
	private function get_originGap():Float { return this._originGap; }
	private function set_originGap(value:Float):Float
	{
		if (this.processStyleRestriction("originGap"))
		{
			return value;
		}
		if (this._originGap == value)
		{
			return value;
		}
		this._originGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._originGap;
	}
	
	/**
	 * @private
	 */
	public var topArrowGap(get, set):Float;
	private var _topArrowGap:Float = 0;
	private function get_topArrowGap():Float { return this._topArrowGap; }
	private function set_topArrowGap(value:Float):Float
	{
		if (this.processStyleRestriction("topArrowGap"))
		{
			return value;
		}
		if (this._topArrowGap == value)
		{
			return value;
		}
		this._topArrowGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._topArrowGap;
	}
	
	/**
	 * @private
	 */
	public var bottomArrowGap(get, set):Float;
	private var _bottomArrowGap:Float = 0;
	private function get_bottomArrowGap():Float { return this._bottomArrowGap; }
	private function set_bottomArrowGap(value:Float):Float
	{
		if (this.processStyleRestriction("bottomArrowGap"))
		{
			return value;
		}
		if (this._bottomArrowGap == value)
		{
			return value;
		}
		this._bottomArrowGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._bottomArrowGap;
	}
	
	/**
	 * @private
	 */
	public var rightArrowGap(get, set):Float;
	private var _rightArrowGap:Float = 0;
	private function get_rightArrowGap():Float { return this._rightArrowGap; }
	private function set_rightArrowGap(value:Float):Float
	{
		if (this.processStyleRestriction("rightArrowGap"))
		{
			return value;
		}
		if (this._rightArrowGap == value)
		{
			return value;
		}
		this._rightArrowGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._rightArrowGap;
	}
	
	/**
	 * @private
	 */
	public var leftArrowGap(get, set):Float;
	private var _leftArrowGap:Float = 0;
	private function get_leftArrowGap():Float { return this._leftArrowGap; }
	private function set_leftArrowGap(value:Float):Float
	{
		if (this.processStyleRestriction("leftArrowGap"))
		{
			return value;
		}
		if (this._leftArrowGap == value)
		{
			return value;
		}
		this._leftArrowGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._leftArrowGap;
	}
	
	/**
	 * @private
	 */
	public var arrowOffset(get, set):Float;
	private var _arrowOffset:Float = 0;
	private function get_arrowOffset():Float { return this._arrowOffset; }
	private function set_arrowOffset(value:Float):Float
	{
		if (this.processStyleRestriction("arrowOffset"))
		{
			return value;
		}
		if (this._arrowOffset == value)
		{
			return value;
		}
		this._arrowOffset = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._arrowOffset;
	}
	
	/**
	 * @private
	 */
	private var _lastGlobalBoundsOfOrigin:Rectangle;

	/**
	 * @private
	 */
	private var _ignoreContentResize:Bool = false;
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		this.origin = null;
		var savedContent:DisplayObject = this._content;
		this.content = null;
		//remove the content safely if it should not be disposed
		if (savedContent != null && this.disposeContent)
		{
			savedContent.dispose();
		}
		super.dispose();
	}
	
	/**
	 * Closes the callout.
	 */
	public function close(dispose:Bool = false):Void
	{
		if (this.parent != null)
		{
			//don't dispose here because we need to keep the event listeners
			//when dispatching Event.CLOSE. we'll dispose after that.
			this.removeFromParent(false);
			this.dispatchEventWith(Event.CLOSE);
		}
		if (dispose)
		{
			this.dispose();
		}
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		this.addEventListener(Event.REMOVED_FROM_STAGE, callout_removedFromStageHandler);
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var originInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_ORIGIN);
		
		if (sizeInvalid)
		{
			this._lastGlobalBoundsOfOrigin = null;
			originInvalid = true;
		}
		
		if (originInvalid)
		{
			this.positionRelativeToOrigin();
		}
		
		if (stylesInvalid || stateInvalid)
		{
			this.refreshArrowSkin();
		}
		
		if (stateInvalid || dataInvalid)
		{
			this.refreshEnabled();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layoutChildren();
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
		return this.measureWithArrowPosition(this._arrowPosition);
	}
	
	/**
	 * @private
	 */
	private function measureWithArrowPosition(arrowPosition:String):Bool
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		
		//the dimensions of the stage (plus stage padding) affect the
		//maximum width and height
		var maxWidth:Float = this._explicitMaxWidth;
		var maxHeight:Float = this._explicitMaxHeight;
		if (this.stage != null)
		{
			var stageMaxWidth:Float = this.stage.stageWidth - stagePaddingLeft - stagePaddingRight;
			if (maxWidth > stageMaxWidth)
			{
				maxWidth = stageMaxWidth;
			}
			var stageMaxHeight:Float = this.stage.stageHeight - stagePaddingTop - stagePaddingBottom;
			if (maxHeight > stageMaxHeight)
			{
				maxHeight = stageMaxHeight;
			}
		}
		
		var oldBackgroundWidth:Float = 0;
		var oldBackgroundHeight:Float = 0;
		if (this._backgroundSkin != null)
		{
			oldBackgroundWidth = this._backgroundSkin.width;
			oldBackgroundHeight = this._backgroundSkin.height;
		}
		var measureBackground:IMeasureDisplayObject = SafeCast.safe_cast(this._backgroundSkin, IMeasureDisplayObject);
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this._backgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			maxWidth, maxHeight,
			this._explicitBackgroundSkinWidth, this._explicitBackgroundSkinHeight,
			this._explicitBackgroundSkinMinWidth, this._explicitBackgroundSkinMinHeight,
			this._explicitBackgroundSkinMaxWidth, this._explicitBackgroundSkinMaxHeight);
		if (Std.isOfType(this._backgroundSkin, IValidating))
		{
			cast(this._backgroundSkin, IValidating).validate();
		}
		
		var leftOrRightArrowWidth:Float = 0;
		var leftOrRightArrowHeight:Float = 0;
		if (arrowPosition == RelativePosition.LEFT && this._leftArrowSkin != null)
		{
			leftOrRightArrowWidth = this._leftArrowSkin.width + this._leftArrowGap + this._originGap;
			leftOrRightArrowHeight = this._leftArrowSkin.height;
		}
		else if (arrowPosition == RelativePosition.RIGHT && this._rightArrowSkin != null)
		{
			leftOrRightArrowWidth = this._rightArrowSkin.width + this._rightArrowGap + this._originGap;
			leftOrRightArrowHeight = this._rightArrowSkin.height;
		}
		var topOrBottomArrowWidth:Float = 0;
		var topOrBottomArrowHeight:Float = 0;
		if (arrowPosition == RelativePosition.TOP && this._topArrowSkin != null)
		{
			topOrBottomArrowWidth = this._topArrowSkin.width;
			topOrBottomArrowHeight = this._topArrowSkin.height + this._topArrowGap + this._originGap;
		}
		else if (arrowPosition == RelativePosition.BOTTOM && this._bottomArrowSkin != null)
		{
			topOrBottomArrowWidth = this._bottomArrowSkin.width;
			topOrBottomArrowHeight = this._bottomArrowSkin.height + this._bottomArrowGap + this._originGap;
		}
		//the content resizes when the callout resizes, so we can treat it
		//similarly to a background skin
		var oldIgnoreContentResize:Bool = this._ignoreContentResize;
		this._ignoreContentResize = true;
		var oldContentWidth:Float = 0;
		var oldContentHeight:Float = 0;
		if (this._content != null)
		{
			//we need to restore these after measurement
			oldContentWidth = this._content.width;
			oldContentHeight = this._content.height;
		}
		var measureContent:IMeasureDisplayObject = SafeCast.safe_cast(this._content, IMeasureDisplayObject);
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this._content,
			this._explicitWidth - leftOrRightArrowWidth - this._paddingLeft - this._paddingRight,
			this._explicitHeight - topOrBottomArrowHeight - this._paddingTop - this._paddingBottom,
			this._explicitMinWidth - leftOrRightArrowWidth - this._paddingLeft - this._paddingRight,
			this._explicitMinHeight - topOrBottomArrowHeight - this._paddingTop - this._paddingBottom,
			maxWidth - leftOrRightArrowHeight - this._paddingLeft - this._paddingRight,
			maxHeight - topOrBottomArrowHeight - this._paddingTop - this._paddingBottom,
			this._explicitContentWidth, this._explicitContentHeight,
			this._explicitContentMinWidth, this._explicitContentMinHeight,
			this._explicitContentMaxWidth, this._explicitContentMaxHeight);
		if (Std.isOfType(this._content, IValidating))
		{
			cast(this._content, IValidating).validate();
		}
		this._ignoreContentResize = oldIgnoreContentResize;
		
		var newWidth:Float = this._explicitWidth;
		var contentWidth:Float = 0;
		if (needsWidth)
		{
			if (this._content != null)
			{
				contentWidth = this._content.width;
			}
			if (topOrBottomArrowWidth > contentWidth)
			{
				contentWidth = topOrBottomArrowWidth;
			}
			newWidth = contentWidth + this._paddingLeft + this._paddingRight;
			var backgroundWidth:Float = 0;
			if (this._backgroundSkin != null)
			{
				backgroundWidth = this._backgroundSkin.width;
			}
			if (backgroundWidth > newWidth)
			{
				newWidth = backgroundWidth;
			}
			newWidth += leftOrRightArrowWidth;
			if (newWidth > maxWidth)
			{
				newWidth = maxWidth;
			}
		}
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			var contentHeight:Float = 0;
			if (this._content != null)
			{
				contentHeight = this._content.height;
			}
			if (leftOrRightArrowHeight > contentWidth)
			{
				contentHeight = leftOrRightArrowHeight;
			}
			newHeight = contentHeight + this._paddingTop + this._paddingBottom;
			var backgroundHeight:Float = 0;
			if (this._backgroundSkin != null)
			{
				backgroundHeight = this._backgroundSkin.height;
			}
			if (backgroundHeight > newHeight)
			{
				newHeight = backgroundHeight;
			}
			newHeight += topOrBottomArrowHeight;
			if (newHeight > maxHeight)
			{
				newHeight = maxHeight;
			}
		}
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			var contentMinWidth:Float = 0;
			if (measureContent != null)
			{
				contentMinWidth = measureContent.minWidth;
			}
			else if (this._content != null)
			{
				contentMinWidth = this._content.width;
			}
			if (topOrBottomArrowWidth > contentMinWidth)
			{
				contentMinWidth = topOrBottomArrowWidth;
			}
			newMinWidth = contentMinWidth + this._paddingLeft + this._paddingRight;
			var backgroundMinWidth:Float = 0;
			if (measureBackground != null)
			{
				backgroundMinWidth = measureBackground.minWidth;
			}
			else if (this._backgroundSkin != null)
			{
				backgroundMinWidth = this._explicitBackgroundSkinMinWidth;
			}
			if (backgroundMinWidth > newMinWidth)
			{
				newMinWidth = backgroundMinWidth;
			}
			newMinWidth += leftOrRightArrowWidth;
			if (newMinWidth > maxWidth)
			{
				newMinWidth = maxWidth;
			}
		}
		var newMinHeight:Float = this._explicitHeight;
		if (needsMinHeight)
		{
			var contentMinHeight:Float = 0;
			if (measureContent != null)
			{
				contentMinHeight = measureContent.minHeight;
			}
			else if (this._content != null)
			{
				contentMinHeight = this._content.height;
			}
			if (leftOrRightArrowHeight > contentMinHeight)
			{
				contentMinHeight = leftOrRightArrowHeight;
			}
			newMinHeight = contentMinHeight + this._paddingTop + this._paddingBottom;
			var backgroundMinHeight:Float = 0;
			if (measureBackground != null)
			{
				backgroundMinHeight = measureBackground.minHeight;
			}
			else if (this._backgroundSkin != null)
			{
				backgroundMinHeight = this._explicitBackgroundSkinMinHeight;
			}
			if (backgroundMinHeight > newMinHeight)
			{
				newMinHeight = backgroundMinHeight;
			}
			newMinHeight += topOrBottomArrowHeight;
			if (newMinHeight > maxHeight)
			{
				newMinHeight = maxHeight;
			}
		}
		if (this._backgroundSkin != null)
		{
			this._backgroundSkin.width = oldBackgroundWidth;
			this._backgroundSkin.height = oldBackgroundHeight;
		}
		if (this._content != null)
		{
			oldIgnoreContentResize = this._ignoreContentResize;
			this._ignoreContentResize = true;
			this._content.width = oldContentWidth;
			this._content.height = oldContentHeight;
			this._ignoreContentResize = oldIgnoreContentResize;
		}
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	private function refreshArrowSkin():Void
	{
		this.currentArrowSkin = null;
		if (this._arrowPosition == RelativePosition.BOTTOM)
		{
			this.currentArrowSkin = this._bottomArrowSkin;
		}
		else if (this._bottomArrowSkin != null)
		{
			this._bottomArrowSkin.visible = false;
		}
		if (this._arrowPosition == RelativePosition.TOP)
		{
			this.currentArrowSkin = this._topArrowSkin;
		}
		else if (this._topArrowSkin != null)
		{
			this._topArrowSkin.visible = false;
		}
		if (this._arrowPosition == RelativePosition.LEFT)
		{
			this.currentArrowSkin = this._leftArrowSkin;
		}
		else if (this._leftArrowSkin != null)
		{
			this._leftArrowSkin.visible = false;
		}
		if (this._arrowPosition == RelativePosition.RIGHT)
		{
			this.currentArrowSkin = this._rightArrowSkin;
		}
		else if (this._rightArrowSkin != null)
		{
			this._rightArrowSkin.visible = false;
		}
		if (this.currentArrowSkin != null)
		{
			this.currentArrowSkin.visible = true;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		if (Std.isOfType(this._content, IFeathersControl))
		{
			cast(this._content, IFeathersControl).isEnabled = this._isEnabled;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
		var xPosition:Float = 0;
		if (this._leftArrowSkin != null && this._arrowPosition == RelativePosition.LEFT)
		{
			xPosition = this._leftArrowSkin.width + this._leftArrowGap;
		}
		var yPosition:Float = 0;
		if (this._topArrowSkin != null && this._arrowPosition == RelativePosition.TOP)
		{
			yPosition = this._topArrowSkin.height + this._topArrowGap;
		}
		var widthOffset:Float = 0;
		if (this._rightArrowSkin != null && this._arrowPosition == RelativePosition.RIGHT)
		{
			widthOffset = this._rightArrowSkin.width + this._rightArrowGap;
		}
		var heightOffset:Float = 0;
		if (this._bottomArrowSkin != null && this._arrowPosition == RelativePosition.BOTTOM)
		{
			heightOffset = this._bottomArrowSkin.height + this._bottomArrowGap;
		}
		var backgroundWidth:Float = this.actualWidth - xPosition - widthOffset;
		var backgroundHeight:Float = this.actualHeight - yPosition - heightOffset;
		if (this._backgroundSkin != null)
		{
			this._backgroundSkin.x = xPosition;
			this._backgroundSkin.y = yPosition;
			this._backgroundSkin.width = backgroundWidth;
			this._backgroundSkin.height = backgroundHeight;
		}
		
		if (this.currentArrowSkin != null)
		{
			var contentWidth:Float = backgroundWidth - this._paddingLeft - this._paddingRight;
			var contentHeight:Float = backgroundHeight - this._paddingTop - this._paddingBottom;
			if (this._arrowPosition == RelativePosition.LEFT)
			{
				this._leftArrowSkin.x = xPosition - this._leftArrowSkin.width - this._leftArrowGap;
				var leftArrowSkinY:Float = this._arrowOffset + yPosition + this._paddingTop;
				if (this._verticalAlign == VerticalAlign.MIDDLE)
				{
					leftArrowSkinY += Math.fround((contentHeight - this._leftArrowSkin.height) / 2);
				}
				else if (this._verticalAlign == VerticalAlign.BOTTOM)
				{
					leftArrowSkinY += (contentHeight - this._leftArrowSkin.height);
				}
				var minLeftArrowSkinY:Float = yPosition + this._paddingTop;
				if (minLeftArrowSkinY > leftArrowSkinY)
				{
					leftArrowSkinY = minLeftArrowSkinY;
				}
				else
				{
					var maxLeftArrowSkinY:Float = yPosition + this._paddingTop + contentHeight - this._leftArrowSkin.height;
					if (maxLeftArrowSkinY < leftArrowSkinY)
					{
						leftArrowSkinY = maxLeftArrowSkinY;
					}
				}
				this._leftArrowSkin.y = leftArrowSkinY;
			}
			else if (this._arrowPosition == RelativePosition.RIGHT)
			{
				this._rightArrowSkin.x = xPosition + backgroundWidth + this._rightArrowGap;
				var rightArrowSkinY:Float = this._arrowOffset + yPosition + this._paddingTop;
				if (this._verticalAlign == VerticalAlign.MIDDLE)
				{
					rightArrowSkinY += Math.fround((contentHeight - this._rightArrowSkin.height) / 2);
				}
				else if (this._verticalAlign == VerticalAlign.BOTTOM)
				{
					rightArrowSkinY += (contentHeight - this._rightArrowSkin.height);
				}
				var minRightArrowSkinY:Float = yPosition + this._paddingTop;
				if (minRightArrowSkinY > rightArrowSkinY)
				{
					rightArrowSkinY = minRightArrowSkinY;
				}
				else
				{
					var maxRightArrowSkinY:Float = yPosition + this._paddingTop + contentHeight - this._rightArrowSkin.height;
					if (maxRightArrowSkinY < rightArrowSkinY)
					{
						rightArrowSkinY = maxRightArrowSkinY;
					}
				}
				this._rightArrowSkin.y = rightArrowSkinY;
			}
			else if (this._arrowPosition == RelativePosition.BOTTOM)
			{
				var bottomArrowSkinX:Float = this._arrowOffset + xPosition + this._paddingLeft;
				if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					bottomArrowSkinX += Math.fround((contentWidth - this._bottomArrowSkin.width) / 2);
				}
				else if (this._horizontalAlign == HorizontalAlign.RIGHT)
				{
					bottomArrowSkinX += (contentWidth - this._bottomArrowSkin.width);
				}
				var minBottomArrowSkinX:Float = xPosition + this._paddingLeft;
				if (minBottomArrowSkinX > bottomArrowSkinX)
				{
					bottomArrowSkinX = minBottomArrowSkinX;
				}
				else
				{
					var maxBottomArrowSkinX:Float = xPosition + this._paddingLeft + contentWidth - this._bottomArrowSkin.width;
					if (maxBottomArrowSkinX < bottomArrowSkinX)
					{
						bottomArrowSkinX = maxBottomArrowSkinX;
					}
				}
				this._bottomArrowSkin.x = bottomArrowSkinX;
				this._bottomArrowSkin.y = yPosition + backgroundHeight + this._bottomArrowGap;
			}
			else //top
			{
				var topArrowSkinX:Float = this._arrowOffset + xPosition + this._paddingLeft;
				if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					topArrowSkinX += Math.round((contentWidth - this._topArrowSkin.width) / 2);
				}
				else if (this._horizontalAlign == HorizontalAlign.RIGHT)
				{
					topArrowSkinX += (contentWidth - this._topArrowSkin.width);
				}
				var minTopArrowSkinX:Float = xPosition + this._paddingLeft;
				if (minTopArrowSkinX > topArrowSkinX)
				{
					topArrowSkinX = minTopArrowSkinX;
				}
				else
				{
					var maxTopArrowSkinX:Float = xPosition + this._paddingLeft + contentWidth - this._topArrowSkin.width;
					if (maxTopArrowSkinX < topArrowSkinX)
					{
						topArrowSkinX = maxTopArrowSkinX;
					}
				}
				this._topArrowSkin.x = topArrowSkinX;
				this._topArrowSkin.y = yPosition - this._topArrowSkin.height - this._topArrowGap;
			}
		}
		
		if (this._content != null)
		{
			this._content.x = xPosition + this._paddingLeft;
			this._content.y = yPosition + this._paddingTop;
			var oldIgnoreContentResize:Bool = this._ignoreContentResize;
			this._ignoreContentResize = true;
			this._content.width = backgroundWidth - this._paddingLeft - this._paddingRight;
			this._content.height = backgroundHeight - this._paddingTop - this._paddingBottom;
			if (Std.isOfType(this._content, IValidating))
			{
				cast(this._content, IValidating).validate();
			}
			this._ignoreContentResize = oldIgnoreContentResize;
		}
	}
	
	/**
	 * @private
	 */
	private function positionRelativeToOrigin():Void
	{
		if (this._origin == null)
		{
			return;
		}
		var stage:Stage = this.stage != null ? this.stage : Starling.current.stage;
		var rect:Rectangle = Pool.getRectangle();
		this._origin.getBounds(stage, rect);
		var hasGlobalBounds:Bool = this._lastGlobalBoundsOfOrigin != null;
		if (hasGlobalBounds && this._lastGlobalBoundsOfOrigin.equals(rect))
		{
			Pool.putRectangle(rect);
			return;
		}
		if (!hasGlobalBounds)
		{
			this._lastGlobalBoundsOfOrigin = new Rectangle();
		}
		this._lastGlobalBoundsOfOrigin.x = rect.x;
		this._lastGlobalBoundsOfOrigin.y = rect.y;
		this._lastGlobalBoundsOfOrigin.width = rect.width;
		this._lastGlobalBoundsOfOrigin.height = rect.height;
		Pool.putRectangle(rect);
		
		var supportedPositions:Array<String> = this._supportedPositions;
		if (supportedPositions == null)
		{
			supportedPositions = DEFAULT_POSITIONS;
		}
		var upSpace:Float = -1;
		var rightSpace:Float = -1;
		var downSpace:Float = -1;
		var leftSpace:Float = -1;
		var positionsCount:Int = supportedPositions.length;
		var position:String;
		for (i in 0...positionsCount)
		{
			position = supportedPositions[i];
			switch(position)
			{
				case RelativePosition.TOP:
					//arrow is opposite, on bottom side
					this.measureWithArrowPosition(RelativePosition.BOTTOM);
					upSpace = this._lastGlobalBoundsOfOrigin.y - this.actualHeight;
					if (upSpace >= stagePaddingTop)
					{
						positionAboveOrigin(this, this._lastGlobalBoundsOfOrigin);
						return;
					}
					if (upSpace < 0)
					{
						upSpace = 0;
					}
				
				case RelativePosition.RIGHT:
					//arrow is opposite, on left side
					this.measureWithArrowPosition(RelativePosition.LEFT);
					rightSpace = (stage.stageWidth - actualWidth) - (this._lastGlobalBoundsOfOrigin.x + this._lastGlobalBoundsOfOrigin.width);
					if (rightSpace >= stagePaddingRight)
					{
						positionToRightOfOrigin(this, this._lastGlobalBoundsOfOrigin);
						return;
					}
					if (rightSpace < 0)
					{
						rightSpace = 0;
					}
				
				case RelativePosition.LEFT:
					this.measureWithArrowPosition(RelativePosition.RIGHT);
					leftSpace = this._lastGlobalBoundsOfOrigin.x - this.actualWidth;
					if (leftSpace >= stagePaddingLeft)
					{
						positionToLeftOfOrigin(this, this._lastGlobalBoundsOfOrigin);
						return;
					}
					if (leftSpace < 0)
					{
						leftSpace = 0;
					}
				
				default: //bottom
					//arrow is opposite, on top side
					this.measureWithArrowPosition(RelativePosition.TOP);
					downSpace = (stage.stageHeight - this.actualHeight) - (this._lastGlobalBoundsOfOrigin.y + this._lastGlobalBoundsOfOrigin.height);
					if (downSpace >= stagePaddingBottom)
					{
						positionBelowOrigin(this, this._lastGlobalBoundsOfOrigin);
						return;
					}
					if (downSpace < 0)
					{
						downSpace = 0;
					}
			}
		}
		//worst case: pick the side that has the most available space
		if (downSpace != -1 && downSpace >= upSpace &&
			downSpace >= rightSpace && downSpace >= leftSpace)
		{
			positionBelowOrigin(this, this._lastGlobalBoundsOfOrigin);
		}
		else if (upSpace != -1 && upSpace >= rightSpace && upSpace >= leftSpace)
		{
			positionAboveOrigin(this, this._lastGlobalBoundsOfOrigin);
		}
		else if (rightSpace != -1 && rightSpace >= leftSpace)
		{
			positionToRightOfOrigin(this, this._lastGlobalBoundsOfOrigin);
		}
		else
		{
			positionToLeftOfOrigin(this, this._lastGlobalBoundsOfOrigin);
		}
	}
	
	/**
	 * @private
	 */
	private function callout_addedToStageHandler(event:Event):Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		//using priority here is a hack so that objects higher up in the
		//display list have a chance to cancel the event first.
		var priority:Int = -DisplayUtils.getDisplayObjectDepthFromStage(this);
		starling.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, callout_nativeStage_keyDownHandler, false, priority, true);
		
		this.stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		//to avoid touch events bubbling up to the callout and causing it to
		//close immediately, we wait one frame before allowing it to close
		//based on touches.
		this._isReadyToClose = false;
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, callout_oneEnterFrameHandler);
	}
	
	/**
	 * @private
	 */
	private function callout_removedFromStageHandler(event:Event):Void
	{
		this.stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, callout_nativeStage_keyDownHandler);
	}

	/**
	 * @private
	 */
	private function callout_oneEnterFrameHandler(event:Event):Void
	{
		this.removeEventListener(EnterFrameEvent.ENTER_FRAME, callout_oneEnterFrameHandler);
		this._isReadyToClose = true;
	}
	
	/**
	 * @private
	 */
	private function callout_enterFrameHandler(event:EnterFrameEvent):Void
	{
		this.positionRelativeToOrigin();
	}
	
	/**
	 * @private
	 */
	private function stage_touchHandler(event:TouchEvent):Void
	{
		var target:DisplayObject = cast event.target;
		if (!this._isReadyToClose ||
			(!this.closeOnTouchEndedOutside && !this.closeOnTouchBeganOutside) || this.contains(target) ||
			(PopUpManager.isPopUp(this) && !PopUpManager.isTopLevelPopUp(this)))
		{
			return;
		}
		
		if (this._origin == target || (Std.isOfType(this._origin, DisplayObjectContainer) && cast(this._origin, DisplayObjectContainer).contains(target)))
		{
			return;
		}
		
		var touch:Touch;
		if (this.closeOnTouchBeganOutside)
		{
			touch = event.getTouch(this.stage, TouchPhase.BEGAN);
			if (touch != null)
			{
				this.close(this.disposeOnSelfClose);
				return;
			}
		}
		if (this.closeOnTouchEndedOutside)
		{
			touch = event.getTouch(this.stage, TouchPhase.ENDED);
			if (touch != null)
			{
				this.close(this.disposeOnSelfClose);
				return;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function callout_nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			//someone else already handled this one
			return;
		}
		if (this.closeOnKeys == null || this.closeOnKeys.indexOf(event.keyCode) < 0)
		{
			return;
		}
		//don't let the OS handle the event
		event.preventDefault();
		this.close(this.disposeOnSelfClose);
	}
	
	/**
	 * @private
	 */
	private function origin_removedFromStageHandler(event:Event):Void
	{
		this.close(this.disposeOnSelfClose);
	}

	/**
	 * @private
	 */
	private function content_resizeHandler(event:Event):Void
	{
		if (this._ignoreContentResize)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
}