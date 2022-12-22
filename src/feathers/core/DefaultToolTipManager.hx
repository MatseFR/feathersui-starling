/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;
import feathers.controls.Label;
import src.feathers.core.IFeathersControl;
import starling.animation.DelayedCall;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
 * The default <code>IToolTipManager</code> implementation.
 *
 * @see ../../../help/tool-tips.html Tool tips in Feathers
 * @see feathers.core.ToolTipManager
 *
 * @productversion Feathers 3.0.0
 */
class DefaultToolTipManager 
{
	/**
	 * The default factory that creates a tool tip. Creates a
	 * <code>Label</code> with the style name
	 * <code>Label.ALTERNATE_STYLE_NAME_TOOL_TIP</code>.
	 *
	 * @see #toolTipFactory
	 * @see feathers.controls.Label
	 * @see feathers.controls.Label#ALTERNATE_STYLE_NAME_TOOL_TIP
	 */
	public static function defaultToolTipFactory():IToolTip
	{
		var toolTip:Label = new Label();
		toolTip.styleNameList.add(Label.ALTERNATE_STYLE_NAME_TOOL_TIP);
		return toolTip;
	}
	
	/**
	 * Constructor.
	 */
	public function new(root:DisplayObjectContainer) 
	{
		this._root = root;
		this._root.addEventListener(TouchEvent.TOUCH, root_touchHandler);
	}
	
	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;
	
	/**
	 * @private
	 */
	private var _delayedCall:DelayedCall;
	
	/**
	 * @private
	 */
	private var _toolTipX:Float = 0;
	
	/**
	 * @private
	 */
	private var _toolTipY:Float = 0;
	
	/**
	 * @private
	 */
	private var _hideTime:Int = 0;
	
	/**
	 * @private
	 */
	private var _root:DisplayObjectContainer;
	
	/**
	 * @private
	 */
	private var _target:IFeathersControl;
	
	/**
	 * @private
	 */
	private var _toolTip:IToolTip;
	
	/**
	 * A function that creates a tool tip.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function():IToolTip</pre>
	 *
	 * @see feathers.core.IToolTip
	 */
	public var toolTipFactory(get, set):Void->IToolTip;
	private var _toolTipFactory:Void->IToolTip;
	private function get_toolTipFactory():Void->IToolTip { return this._toolTipFactory; }
	private function set_toolTipFactory(value:Void->IToolTip):Void->IToolTip
	{
		if (this._toolTipFactory == value)
		{
			return value;
		}
		this._toolTipFactory = value;
		if (this._toolTip != null)
		{
			this._toolTip.removeFromParent(true);
			this._toolTip = null;
		}
	}
	
	/**
	 * The delay, in seconds, before a tool tip may be displayed when the
	 * mouse is idle over a component with a tool tip.
	 *
	 * @default 0.5
	 */
	public var showDelay(get, set):Float;
	private var _showDelay:Float = 0.5;
	private function get_showDelay():Float { return this._showDelay; }
	private function set_showDelay(value:Float):Float
	{
		return this._showDelay = value;
	}
	
	/**
	 * The time, in seconds, after hiding a tool tip before the
	 * <code>showDelay</code> is required to show a new tool tip for another
	 * component. If the mouse moves over another component before this
	 * threshold, the tool tip will be shown immediately. This allows
	 * tooltips for adjacent components, such as those appearing in
	 * toolbars, to be shown quickly.
	 *
	 * <p>To disable this behavior, set the <code>resetDelay</code> to
	 * <code>0</code>.</p>
	 *
	 * @default 0.1
	 */
	public var resetDelay(get, set):Float;
	private var _resetDelay:Float = 0.1;
	private function get_resetDelay():Float { return this._resetDelay; }
	private function set_resetDelay(value:Float):Float
	{
		return this._resetDelay = value;
	}
	
	/**
	 * The offset, in pixels, of the tool tip position on the x axis.
	 *
	 * @default 0
	 */
	public var offsetX(get, set):Float;
	private var _offsetX:Float = 0;
	private function get_offsetX():Float { return this._offsetX; }
	private function set_offsetX(value:Float):Float
	{
		return this._offsetX = value;
	}
	
	/**
	 * The offset, in pixels, of the tool tip position on the y axis.
	 *
	 * @default 0
	 */
	public var offsetY(get, set):Float;
	private var _offsetY:Float = 0;
	private function get_offsetY():Float { return this._offsetY; }
	private function set_offsetY(value:Float):Float
	{
		return this._offsetY = value;
	}
	
	/**
	 * @copy feathers.core.IToolTipManager#dispose()
	 */
	public function dispose():Void
	{
		this._root.removeEventListener(TouchEvent.TOUCH, root_touchHandler);
		this._root = null;
		
		if (Starling.juggler.contains(this._delayedCall))
		{
			Starling.juggler.remove(this._delayedCall);
			this._delayedCall = null;
		}
		
		if (this._toolTip != null)
		{
			this._toolTip.removeFromParent(true);
			this._toolTip = null;
		}
	}
	
	/**
	 * @private
	 */
	private function getTarget(touch:Touch):IFeathersControl
	{
		var target:DisplayObject = touch.target;
		while (target != null)
		{
			if (Std.isOfType(target, IFeathersControl))
			{
				var toolTipSource:IFeathersControl = cast target;
				if (toolTipSource.toolTip)
				{
					return toolTipSource;
				}
			}
			target = target.parent;
		}
		return null;
	}
	
	/**
	 * @private
	 */
	private function hoverDelayCallback():Void
	{
		if (this._toolTip == null)
		{
			var factory:Void->IToolTip = this._toolTipFactory != null ? this._toolTipFactory : defaultToolTipFactory;
			var toolTip:IToolTip = factory();
			toolTip.touchable = false;
			this._toolTip = toolTip;
		}
		this._toolTip.text = this._target.toolTip;
		this._toolTip.validate();
		var toolTipX:Float = this._toolTipX + this._offsetX;
		if (toolTipX < 0)
		{
			toolTipX = 0;
		}
		else if ((toolTipX + this._toolTip.width) > this._target.stage.stageWidth)
		{
			toolTipX = this._target.stage.stageWidth - this._toolTip.width;
		}
		var toolTipY:Float = this._toolTipY - this._toolTip.height + this._offsetY;
		if (toolTipY < 0)
		{
			toolTipY = 0;
		}
		else if ((toolTipY + this._toolTip.height) > this._target.stage.stageHeight)
		{
			toolTipY = this._target.stage.stageHeight - this._toolTip.height;
		}
		this._toolTip.x = toolTipX;
		this._toolTip.y = toolTipY;
		PopUpManager.addPopUp(cast this._toolTip, false, false);
	}
	
	/**
	 * @private
	 */
	private function root_touchHandler(event:TouchEvent):Void
	{
		if (this._toolTip != null && this._toolTip.parent != null)
		{
			var touch:Touch = event.getTouch(cast this._target, null, this._touchPointID);
			if (touch == null || touch.phase != TouchPhase.HOVER)
			{
				//to avoid excessive garbage collection, we reuse the
				//tooltip object
				PopUpManager.removePopUp(DisplayObject(this._toolTip), false);
				this._touchPointID = -1;
				this._target = null;
				this._hideTime = getTimer();
			}
			return;
		}
		if (this._target != null)
		{
			touch = event.getTouch(cast this._target, null, this._touchPointID);
			if (touch == null || touch.phase != TouchPhase.HOVER)
			{
				Starling.juggler.remove(this._delayedCall);
				this._touchPointID = -1;
				this._target = null;
				return;
			}
			
			//every time TouchPhase.HOVER is dispatched, the mouse has
			//moved. we need to reset the timer and update the position
			//where the tool tip will appear when the timer completes
			this._toolTipX = touch.globalX;
			this._toolTipY = touch.globalY;
			this._delayedCall.reset(hoverDelayCallback, this._showDelay);
		}
		else
		{
			touch = event.getTouch(this._root, TouchPhase.HOVER);
			if (touch == null)
			{
				return;
			}
			this._target = this.getTarget(touch);
			if (this._target == null)
			{
				return;
			}
			this._touchPointID = touch.id;
			this._toolTipX = touch.globalX;
			this._toolTipY = touch.globalY;
			var timeSinceHide:Float = (getTimer() - this._hideTime) / 1000;
			if (timeSinceHide < this._resetDelay)
			{
				this.hoverDelayCallback();
				return;
			}
			if (this._delayedCall != null)
			{
				//to avoid excessive garbage collection, we reuse the
				//DelayedCall object.
				this._delayedCall.reset(hoverDelayCallback, this._showDelay);
			}
			else
			{
				this._delayedCall = new DelayedCall(hoverDelayCallback, this._showDelay);
			}
			Starling.juggler.add(this._delayedCall);
		}
	}
	
}