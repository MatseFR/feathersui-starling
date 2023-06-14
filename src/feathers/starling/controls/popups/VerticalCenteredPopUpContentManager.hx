/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.popups;
import feathers.starling.core.IFeathersControl;
import feathers.starling.core.IValidating;
import feathers.starling.core.PopUpManager;
import feathers.starling.events.FeathersEventType;
import feathers.starling.controls.popups.IPopUpContentManager;
import feathers.starling.utils.display.DisplayUtils;
import feathers.starling.utils.geom.GeomUtils;
import openfl.errors.IllegalOperationError;
import openfl.events.KeyboardEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Stage;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.ResizeEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Displays a pop-up at the center of the stage, filling the vertical space.
 * The content will be sized horizontally so that it is no larger than the
 * the width or height of the stage (whichever is smaller).
 *
 * @productversion Feathers 1.0.0
 */
class VerticalCenteredPopUpContentManager extends EventDispatcher implements IPopUpContentManager
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * Quickly sets all margin properties to the same value. The
	 * <code>margin</code> getter always returns the value of
	 * <code>marginTop</code>, but the other padding values may be
	 * different.
	 *
	 * <p>The following example gives the pop-up a minimum of 20 pixels of
	 * margin on all sides:</p>
	 *
	 * <listing version="3.0">
	 * manager.margin = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #marginTop
	 * @see #marginRight
	 * @see #marginBottom
	 * @see #marginLeft
	 */
	public var margin(get, set):Float;
	private function get_margin():Float { return this.marginTop; }
	private function set_margin(value:Float):Float
	{
		this.marginTop = value;
		this.marginRight = value;
		this.marginBottom = value;
		return this.marginLeft = value;
	}
	
	/**
	 * The minimum space, in pixels, between the top edge of the content and
	 * the top edge of the stage.
	 *
	 * <p>The following example gives the pop-up a minimum of 20 pixels of
	 * margin on the top:</p>
	 *
	 * <listing version="3.0">
	 * manager.marginTop = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #margin
	 */
	public var marginTop:Float = 0;

	/**
	 * The minimum space, in pixels, between the right edge of the content
	 * and the right edge of the stage.
	 *
	 * <p>The following example gives the pop-up a minimum of 20 pixels of
	 * margin on the right:</p>
	 *
	 * <listing version="3.0">
	 * manager.marginRight = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #margin
	 */
	public var marginRight:Float = 0;

	/**
	 * The minimum space, in pixels, between the bottom edge of the content
	 * and the bottom edge of the stage.
	 *
	 * <p>The following example gives the pop-up a minimum of 20 pixels of
	 * margin on the bottom:</p>
	 *
	 * <listing version="3.0">
	 * manager.marginBottom = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #margin
	 */
	public var marginBottom:Float = 0;

	/**
	 * The minimum space, in pixels, between the left edge of the content
	 * and the left edge of the stage.
	 *
	 * <p>The following example gives the pop-up a minimum of 20 pixels of
	 * margin on the left:</p>
	 *
	 * <listing version="3.0">
	 * manager.marginLeft = 20;</listing>
	 *
	 * @default 0
	 *
	 * @see #margin
	 */
	public var marginLeft:Float = 0;
	
	/**
	 * This function may be used to customize the modal overlay displayed by
	 * the pop-up manager. If the value of <code>overlayFactory</code> is
	 * <code>null</code>, the pop-up manager's default overlay factory will
	 * be used instead.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function():DisplayObject</pre>
	 *
	 * <p>In the following example, the overlay is customized:</p>
	 *
	 * <listing version="3.0">
	 * manager.overlayFactory = function():DisplayObject
	 * {
	 *     var quad:Quad = new Quad(1, 1, 0xff00ff);
	 *     quad.alpha = 0;
	 *     return quad;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.PopUpManager#overlayFactory
	 */
	public var overlayFactory(get, set):Void->DisplayObject;
	private var _overlayFactory:Void->DisplayObject;
	private function get_overlayFactory():Void->DisplayObject { return this._overlayFactory; }
	private function set_overlayFactory(value:Void->DisplayObject):Void->DisplayObject
	{
		return this._overlayFactory = value;
	}
	
	/**
	 * @private
	 */
	private var content:DisplayObject;

	/**
	 * @private
	 */
	private var touchPointID:Int = -1;
	
	/**
	 * @inheritDoc
	 */
	public var isOpen(get, never):Bool;
	private function get_isOpen():Bool { return this.content != null; }
	
	/**
	 * @inheritDoc
	 */
	public function open(content:DisplayObject, source:DisplayObject):Void
	{
		if (this.isOpen)
		{
			throw new IllegalOperationError("Pop-up content is already open. Close the previous content before opening new content.");
		}
		
		//make sure the content is scaled the same as the source
		var matrix:Matrix = Pool.getMatrix();
		source.getTransformationMatrix(PopUpManager.root, matrix);
		content.scaleX = GeomUtils.matrixToScaleX(matrix);
		content.scaleY = GeomUtils.matrixToScaleY(matrix);
		Pool.putMatrix(matrix);
		
		this.content = content;
		PopUpManager.addPopUp(this.content, true, false, this._overlayFactory);
		if (Std.isOfType(this.content, IFeathersControl))
		{
			this.content.addEventListener(FeathersEventType.RESIZE, content_resizeHandler);
		}
		this.content.addEventListener(Event.REMOVED_FROM_STAGE, content_removedFromStageHandler);
		this.layout();
		var stage:Stage = Starling.current.stage;
		stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		stage.addEventListener(ResizeEvent.RESIZE, stage_resizeHandler);
		
		//using priority here is a hack so that objects higher up in the
		//display list have a chance to cancel the event first.
		var priority:Int = -DisplayUtils.getDisplayObjectDepthFromStage(this.content);
		Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler, false, priority, true);
		this.dispatchEventWith(Event.OPEN);
	}
	
	/**
	 * @inheritDoc
	 */
	public function close():Void
	{
		if (!this.isOpen)
		{
			return;
		}
		var content:DisplayObject = this.content;
		this.content = null;
		var stage:Stage = Starling.current.stage;
		stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
		stage.removeEventListener(ResizeEvent.RESIZE, stage_resizeHandler);
		Starling.current.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler);
		if (Std.isOfType(content, IFeathersControl))
		{
			content.removeEventListener(FeathersEventType.RESIZE, content_resizeHandler);
		}
		content.removeEventListener(Event.REMOVED_FROM_STAGE, content_removedFromStageHandler);
		if (content.parent != null)
		{
			content.removeFromParent(false);
		}
		this.dispatchEventWith(Event.CLOSE);
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispose():Void
	{
		this.close();
	}

	/**
	 * @private
	 */
	private function layout():Void
	{
		var stage:Stage = Starling.current.stage;
		var point:Point = Pool.getPoint(stage.stageWidth, stage.stageHeight);
		PopUpManager.root.globalToLocal(point, point);
		var parentWidth:Float = point.x;
		var parentHeight:Float = point.y;
		Pool.putPoint(point);
		var maxWidth:Float = parentWidth;
		if (maxWidth > parentHeight)
		{
			maxWidth = parentHeight;
		}
		maxWidth -= (this.marginLeft + this.marginRight);
		var maxHeight:Float = parentHeight - this.marginTop - this.marginBottom;
		var hasSetBounds:Bool = false;
		if (Std.isOfType(this.content, IFeathersControl))
		{
			//if it's a ui control that is able to auto-size, this section
			//will ensure that the control stays within the required bounds.
			var uiContent:IFeathersControl = cast this.content;
			uiContent.minWidth = maxWidth;
			uiContent.maxWidth = maxWidth;
			uiContent.maxHeight = maxHeight;
			hasSetBounds = true;
		}
		if (Std.isOfType(this.content, IValidating))
		{
			cast(this.content, IValidating).validate();
		}
		if (!hasSetBounds)
		{
			//if it's not a ui control, and the control's explicit width and
			//height values are greater than our maximum bounds, then we
			//will enforce the maximum bounds the hard way.
			if (this.content.width > maxWidth)
			{
				this.content.width = maxWidth;
			}
			if (this.content.height > maxHeight)
			{
				this.content.height = maxHeight;
			}
		}
		//round to the nearest pixel to avoid unnecessary smoothing
		this.content.x = Math.fround((parentWidth - this.content.width) / 2);
		this.content.y = Math.fround((parentHeight - this.content.height) / 2);
	}
	
	/**
	 * @private
	 */
	private function content_resizeHandler(event:Event):Void
	{
		this.layout();
	}

	/**
	 * @private
	 */
	private function content_removedFromStageHandler(event:Event):Void
	{
		this.close();
	}
	
	/**
	 * @private
	 */
	private function nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			//someone else already handled this one
			return;
		}
		// TODO : Keyboard.BACK only exists on flash target
		if (#if flash event.keyCode != Keyboard.BACK && #end event.keyCode != Keyboard.ESCAPE)
		{
			return;
		}
		//don't let the OS handle the event
		event.preventDefault();
		
		this.close();
	}
	
	/**
	 * @private
	 */
	private function stage_resizeHandler(event:ResizeEvent):Void
	{
		this.layout();
	}
	
	/**
	 * @private
	 */
	private function stage_touchHandler(event:TouchEvent):Void
	{
		if (!PopUpManager.isTopLevelPopUp(this.content))
		{
			return;
		}
		var stage:Stage = Starling.current.stage;
		var touch:Touch;
		var point:Point;
		var hitTestResult:DisplayObject;
		var isInBounds:Bool;
		if (this.touchPointID >= 0)
		{
			touch = event.getTouch(stage, TouchPhase.ENDED, this.touchPointID);
			if (touch == null)
			{
				return;
			}
			point = Pool.getPoint();
			touch.getLocation(stage, point);
			hitTestResult = stage.hitTest(point);
			Pool.putPoint(point);
			isInBounds = false;
			if (Std.isOfType(this.content, DisplayObjectContainer))
			{
				isInBounds = cast(this.content, DisplayObjectContainer).contains(hitTestResult);
			}
			else
			{
				isInBounds = this.content == hitTestResult;
			}
			if (!isInBounds)
			{
				this.touchPointID = -1;
				this.close();
			}
		}
		else
		{
			touch = event.getTouch(stage, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			point = Pool.getPoint();
			touch.getLocation(stage, point);
			hitTestResult = stage.hitTest(point);
			Pool.putPoint(point);
			isInBounds = false;
			if (Std.isOfType(this.content, DisplayObjectContainer))
			{
				isInBounds = cast(this.content, DisplayObjectContainer).contains(hitTestResult);
			}
			else
			{
				isInBounds = this.content == hitTestResult;
			}
			if (isInBounds)
			{
				return;
			}
			this.touchPointID = touch.id;
		}
	}
	
}