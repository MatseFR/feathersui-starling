/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.popups;
import feathers.core.IFeathersControl;
import feathers.core.IValidating;
import feathers.core.PopUpManager;
import feathers.core.ValidationQueue;
import feathers.display.RenderDelegate;
import feathers.events.FeathersEventType;
import feathers.layout.RelativePosition;
import feathers.utils.display.DisplayUtils;
import feathers.utils.geom.GeomUtils;
import feathers.utils.math.MathUtils;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import openfl.errors.IllegalOperationError;
import openfl.events.KeyboardEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.ui.Keyboard;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Quad;
import starling.display.Stage;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.ResizeEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Displays pop-up content as a desktop-style drop-down.
 *
 * @productversion Feathers 1.0.0
 */
class DropDownPopUpContentManager extends EventDispatcher implements IPopUpContentManager
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * @private
	 */
	private var content:DisplayObject;

	/**
	 * @private
	 */
	private var source:DisplayObject;

	/**
	 * @private
	 */
	private var _delegate:RenderDelegate;
	
	/**
	 * @private
	 * Stores the same value as the content property, but the content
	 * property may be set to null before the animation ends.
	 */
	private var _openCloseTweenTarget:DisplayObject;

	/**
	 * @private
	 */
	private var _openCloseTween:Tween;
	
	/**
	 * @inheritDoc
	 */
	public var isOpen(get, never):Bool;
	private function get_isOpen():Bool { return this.content != null; }
	
	/**
	 * Determines if the pop-up will be modal or not.
	 *
	 * <p>Note: If you change this value while a pop-up is displayed, the
	 * new value will not go into effect until the pop-up is removed and a
	 * new pop-up is added.</p>
	 *
	 * <p>In the following example, the pop-up is modal:</p>
	 *
	 * <listing version="3.0">
	 * manager.isModal = true;</listing>
	 *
	 * @default false
	 */
	public var isModal(get, set):Bool;
	private var _isModal:Bool = false;
	private function get_isModal():Bool { return this._isModal; }
	private function set_isModal(value:Bool):Bool
	{
		return this._isModal = value;
	}
	
	/**
	 * If <code>isModal</code> is <code>true</code>, this function may be
	 * used to customize the modal overlay displayed by the pop-up manager.
	 * If the value of <code>overlayFactory</code> is <code>null</code>, the
	 * pop-up manager's default overlay factory will be used instead.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function():DisplayObject</pre>
	 *
	 * <p>In the following example, the overlay is customized:</p>
	 *
	 * <listing version="3.0">
	 * manager.isModal = true;
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
	 * The space, in pixels, between the source and the pop-up.
	 */
	public var gap(get, set):Float;
	private var _gap:Float = 0;
	private function get_gap():Float { return this._gap; }
	private function set_gap(value:Float):Float
	{
		return this._gap = value;
	}
	
	/**
	 * The duration, in seconds, of the open and close animation.
	 */
	public var openCloseDuration(get, set):Float;
	private var _openCloseDuration:Float = 0.2;
	private function get_openCloseDuration():Float { return this._openCloseDuration; }
	private function set_openCloseDuration(value:Float):Float
	{
		return this._openCloseDuration = value;
	}
	
	/**
	 * The easing function to use for the open and close animation.
	 */
	public var openCloseEase(get, set):Dynamic;
	private var _openCloseEase:Dynamic = Transitions.EASE_OUT;
	private function get_openCloseEase():Dynamic { return this._openCloseEase; }
	private function set_openCloseEase(value:Dynamic):Dynamic
	{
		return this._openCloseEase = value;
	}
	
	/**
	 * @private
	 */
	private var _actualDirection:String;
	
	/**
	 * The preferred position of the pop-up, relative to the source. If
	 * there is not enough space to position pop-up at the preferred
	 * position, it may be positioned elsewhere.
	 *
	 * @default feathers.layout.RelativePosition.BOTTOM
	 *
	 * @see feathers.layout.RelativePosition#BOTTOM
	 * @see feathers.layout.RelativePosition#TOP
	 */
	public var primaryDirection(get, set):String;
	private var _primaryDirection = RelativePosition.BOTTOM;
	private function get_primaryDirection():String { return this._primaryDirection; }
	private function set_primaryDirection(value:String):String
	{
		if (value == "up")
		{
			value = RelativePosition.TOP;
		}
		else if (value == "down")
		{
			value = RelativePosition.BOTTOM;
		}
		return this._primaryDirection = value;
	}
	
	/**
	 * If enabled, the pop-up content's <code>minWidth</code> property will
	 * be set to the <code>width</code> property of the origin, if it is
	 * smaller.
	 *
	 * @default true
	 */
	public var fitContentMinWidthToOrigin(get, set):Bool;
	private var _fitContentMinWidthToOrigin:Bool = true;
	private function get_fitContentMinWidthToOrigin():Bool { return this._fitContentMinWidthToOrigin; }
	private function set_fitContentMinWidthToOrigin(value:Bool):Bool
	{
		return this._fitContentMinWidthToOrigin = value;
	}
	
	/**
	 * @private
	 */
	private var _lastOriginX:Float;

	/**
	 * @private
	 */
	private var _lastOriginY:Float;
	
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
		this.source = source;
		PopUpManager.addPopUp(content, this._isModal, false, this._overlayFactory);
		if (Std.isOfType(content, IFeathersControl))
		{
			content.addEventListener(FeathersEventType.RESIZE, content_resizeHandler);
		}
		content.addEventListener(Event.REMOVED_FROM_STAGE, content_removedFromStageHandler);
		this.layout();
		if (this._openCloseTween != null)
		{
			this._openCloseTween.advanceTime(this._openCloseTween.totalTime);
		}
		if (this._openCloseDuration > 0)
		{
			this._delegate = new RenderDelegate(content);
			this._delegate.scaleX = content.scaleX;
			this._delegate.scaleY = content.scaleY;
			//temporarily hide the content while the delegate is displayed
			content.visible = false;
			PopUpManager.addPopUp(this._delegate, false, false);
			this._delegate.x = content.x;
			if (this._actualDirection == RelativePosition.TOP)
			{
				this._delegate.y = content.y + content.height;
			}
			else //bottom
			{
				this._delegate.y = content.y - content.height;
			}
			var mask:Quad = new Quad(1, 1, 0xff00ff);
			mask.width = content.width / content.scaleX;
			mask.height = 0;
			this._delegate.mask = mask;
			mask.height = 0;
			this._openCloseTween = new Tween(this._delegate, this._openCloseDuration, this._openCloseEase);
			this._openCloseTweenTarget = content;
			this._openCloseTween.animate("y", content.y);
			this._openCloseTween.onUpdate = openCloseTween_onUpdate;
			this._openCloseTween.onComplete = openTween_onComplete;
			Starling.currentJuggler.add(this._openCloseTween);
		}
		var stage:Stage = this.source.stage;
		stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		stage.addEventListener(ResizeEvent.RESIZE, stage_resizeHandler);
		stage.addEventListener(Event.ENTER_FRAME, stage_enterFrameHandler);
		
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
		if (this._openCloseTween != null)
		{
			this._openCloseTween.advanceTime(this._openCloseTween.totalTime);
		}
		var content:DisplayObject = this.content;
		this.source = null;
		this.content = null;
		var stage:Stage = content.stage;
		stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
		stage.removeEventListener(ResizeEvent.RESIZE, stage_resizeHandler);
		stage.removeEventListener(Event.ENTER_FRAME, stage_enterFrameHandler);
		stage.starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler);
		if (Std.isOfType(content, IFeathersControl))
		{
			content.removeEventListener(FeathersEventType.RESIZE, content_resizeHandler);
		}
		content.removeEventListener(Event.REMOVED_FROM_STAGE, content_removedFromStageHandler);
		if (content.parent != null)
		{
			content.removeFromParent(false);
		}
		if (this._openCloseDuration > 0)
		{
			this._delegate = new RenderDelegate(content);
			this._delegate.scaleX = content.scaleX;
			this._delegate.scaleY = content.scaleY;
			PopUpManager.addPopUp(this._delegate, false, false);
			this._delegate.x = content.x;
			this._delegate.y = content.y;
			var mask:Quad = new Quad(1, 1, 0xff00ff);
			mask.width = content.width / content.scaleX;
			mask.height = content.height / content.scaleY;
			this._delegate.mask = mask;
			this._openCloseTween = new Tween(this._delegate, this._openCloseDuration, this._openCloseEase);
			this._openCloseTweenTarget = content;
			if (this._actualDirection == RelativePosition.TOP)
			{
				this._openCloseTween.animate("y", content.y + content.height);
			}
			else
			{
				this._openCloseTween.animate("y", content.y - content.height);
			}
			this._openCloseTween.onUpdate = openCloseTween_onUpdate;
			this._openCloseTween.onComplete = closeTween_onComplete;
			Starling.currentJuggler.add(this._openCloseTween);
		}
		else
		{
			this.dispatchEventWith(Event.CLOSE);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispose():Void
	{
		this.openCloseDuration = 0;
		this.close();
	}
	
	/**
	 * @private
	 */
	private function layout():Void
	{
		if (Std.isOfType(this.source, IValidating))
		{
			cast(this.source, IValidating).validate();
			if (!this.isOpen)
			{
				//it's possible that the source will close its pop-up during
				//validation, so we should check for that.
				return;
			}
		}
		
		var originBoundsInParent:Rectangle = this.source.getBounds(PopUpManager.root);
		var sourceWidth:Float = originBoundsInParent.width;
		var hasSetBounds:Bool = false;
		var uiContent:IFeathersControl = SafeCast.safe_cast(this.content, IFeathersControl);
		if (this._fitContentMinWidthToOrigin && uiContent != null && uiContent.minWidth < sourceWidth)
		{
			uiContent.minWidth = sourceWidth;
			hasSetBounds = true;
		}
		if (Std.isOfType(this.content, IValidating))
		{
			//cast(uiContent, IValidating).validate();
			uiContent.validate();
		}
		if (!hasSetBounds && this._fitContentMinWidthToOrigin && this.content.width < sourceWidth)
		{
			this.content.width = sourceWidth;
		}
		
		var stage:Stage = this.source.stage;
		
		//we need to be sure that the source is properly positioned before
		//positioning the content relative to it.
		var validationQueue:ValidationQueue = ValidationQueue.forStarling(stage.starling);
		if (validationQueue != null && !validationQueue.isValidating)
		{
			//force a COMPLETE validation of everything
			//but only if we're not already doing that...
			validationQueue.advanceTime(0);
		}
		
		originBoundsInParent = this.source.getBounds(PopUpManager.root);
		this._lastOriginX = originBoundsInParent.x;
		this._lastOriginY = originBoundsInParent.y;
		
		var stageDimensionsInParent:Point = new Point(stage.stageWidth, stage.stageHeight);
		PopUpManager.root.globalToLocal(stageDimensionsInParent, stageDimensionsInParent);
		
		var downSpace:Float = (stageDimensionsInParent.y - this.content.height) - (originBoundsInParent.y + originBoundsInParent.height + this._gap);
		//skip this if the primary direction is up
		if (this._primaryDirection == RelativePosition.BOTTOM && downSpace >= 0)
		{
			layoutBelow(originBoundsInParent, stageDimensionsInParent);
			return;
		}
		
		var upSpace:Float = originBoundsInParent.y - this._gap - this.content.height;
		if (upSpace >= 0)
		{
			layoutAbove(originBoundsInParent, stageDimensionsInParent);
			return;
		}
		
		//do what we skipped earlier if the primary direction is up
		if (this._primaryDirection == RelativePosition.TOP && downSpace >= 0)
		{
			layoutBelow(originBoundsInParent, stageDimensionsInParent);
			return;
		}
		
		//worst case: pick the side that has the most available space
		if (upSpace >= downSpace)
		{
			layoutAbove(originBoundsInParent, stageDimensionsInParent);
		}
		else
		{
			layoutBelow(originBoundsInParent, stageDimensionsInParent);
		}
		
		//the content is too big for the space, so we need to adjust it to
		//fit properly
		var newMaxHeight:Float = stageDimensionsInParent.y - (originBoundsInParent.y + originBoundsInParent.height);
		if (uiContent != null)
		{
			if (uiContent.maxHeight > newMaxHeight)
			{
				uiContent.maxHeight = newMaxHeight;
			}
		}
		else if (this.content.height > newMaxHeight)
		{
			this.content.height = newMaxHeight;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutAbove(originBoundsInParent:Rectangle, stageDimensionsInParent:Point):Void
	{
		this._actualDirection = RelativePosition.TOP;
		this.content.x = this.calculateXPosition(originBoundsInParent, stageDimensionsInParent);
		this.content.y = originBoundsInParent.y - this.content.height - this._gap;
	}

	/**
	 * @private
	 */
	private function layoutBelow(originBoundsInParent:Rectangle, stageDimensionsInParent:Point):Void
	{
		this._actualDirection = RelativePosition.BOTTOM;
		this.content.x = this.calculateXPosition(originBoundsInParent, stageDimensionsInParent);
		this.content.y = originBoundsInParent.y + originBoundsInParent.height + this._gap;
	}
	
	/**
	 * @private
	 */
	private function calculateXPosition(originBoundsInParent:Rectangle, stageDimensionsInParent:Point):Float
	{
		var idealXPosition:Float = originBoundsInParent.x;
		var fallbackXPosition:Float = idealXPosition + originBoundsInParent.width - this.content.width;
		var maxXPosition:Float = stageDimensionsInParent.x - this.content.width;
		var xPosition:Float = idealXPosition;
		if (xPosition > maxXPosition)
		{
			if (fallbackXPosition >= 0)
			{
				xPosition = fallbackXPosition;
			}
			else
			{
				xPosition = maxXPosition;
			}
		}
		if (xPosition < 0)
		{
			xPosition = 0;
		}
		return xPosition;
	}
	
	/**
	 * @private
	 */
	private function openCloseTween_onUpdate():Void
	{
		var mask:DisplayObject = this._delegate.mask;
		if (this._actualDirection == RelativePosition.TOP)
		{
			mask.height = (this._openCloseTweenTarget.height - (this._delegate.y - this._openCloseTweenTarget.y)) / this._openCloseTweenTarget.scaleY;
			mask.y = 0;
		}
		else
		{
			mask.height = (this._openCloseTweenTarget.height - (this._openCloseTweenTarget.y - this._delegate.y)) / this._openCloseTweenTarget.scaleY;
			mask.y = (this._openCloseTweenTarget.height / this._openCloseTweenTarget.scaleY) - mask.height;
		}
	}
	
	/**
	 * @private
	 */
	private function openCloseTween_onComplete():Void
	{
		this._openCloseTween = null;
		this._delegate.removeFromParent(true);
		this._delegate = null;
	}

	/**
	 * @private
	 */
	private function openTween_onComplete():Void
	{
		this.openCloseTween_onComplete();
		this.content.visible = true;
	}
	
	/**
	 * @private
	 */
	private function closeTween_onComplete():Void
	{
		this.openCloseTween_onComplete();
		this.dispatchEventWith(Event.CLOSE);
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
	private function stage_enterFrameHandler(event:Event):Void
	{
		var rect:Rectangle = Pool.getRectangle();
		this.source.getBounds(PopUpManager.root, rect);
		var rectX:Float = rect.x;
		var rectY:Float = rect.y;
		Pool.putRectangle(rect);
		if (rectY != this._lastOriginX || rectY != this._lastOriginY)
		{
			this.layout();
		}
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
		// TODO : Keyboard.BACK only available on flash target
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
		var target:DisplayObject = cast event.target;
		if (this.content == target || (Std.isOfType(this.content, DisplayObjectContainer) && cast(this.content, DisplayObjectContainer).contains(target)))
		{
			return;
		}
		if (this.source == target || (Std.isOfType(this.source, DisplayObjectContainer) && cast(this.source, DisplayObjectContainer).contains(target)))
		{
			return;
		}
		if (!PopUpManager.isTopLevelPopUp(this.content))
		{
			return;
		}
		//any began touch is okay here. we don't need to check all touches
		var stage:Stage = cast event.currentTarget;
		var touch:Touch = event.getTouch(stage, TouchPhase.BEGAN);
		if (touch == null)
		{
			return;
		}
		this.close();
	}
	
}