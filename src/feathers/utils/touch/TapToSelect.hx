/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.utils.touch;
import feathers.core.IToggle;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Stage;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Changes the <code>isSelected</code> property of the target when the
 * target is tapped (which will dispatch <code>Event.CHANGE</code>).
 * Conveniently handles all <code>TouchEvent</code> listeners automatically.
 * Useful for custom item renderers that should be selected when tapped.
 *
 * <p>In the following example, a custom item renderer will be selected when
 * tapped:</p>
 *
 * <listing version="3.0">
 * public class CustomItemRenderer extends LayoutGroupListItemRenderer
 * {
 *     public function CustomItemRenderer()
 *     {
 *         super();
 *         this._tapToSelect = new TapToSelect(this);
 *     }
 * 
 *     private var _tapToSelect:TapToSelect;
 * }</listing>
 *
 * <p>Note: When combined with a <code>TapToTrigger</code> instance, the
 * <code>TapToSelect</code> instance should be created second because
 * <code>Event.TRIGGERED</code> should be dispatched before
 * <code>Event.CHANGE</code>.</p>
 *
 * @see feathers.utils.touch.TapToTrigger
 * @see feathers.utils.touch.LongPress
 *
 * @productversion Feathers 2.3.0
 */
class TapToSelect 
{
	/**
	 * Constructor.
	 */
	public function new(target:IToggle = null) 
	{
		this.target = target;
	}
	
	/**
	 * The target component that should be selected when tapped.
	 */
	public var target(get, set):IToggle;
	private var _target:IToggle;
	private function get_target():IToggle { return this._target; }
	private function set_target(value:IToggle):IToggle
	{
		if (this._target == value)
		{
			return value;
		}
		if (this._target != null)
		{
			this._target.removeEventListener(TouchEvent.TOUCH, target_touchHandler);
		}
		this._target = value;
		if (this._target != null)
		{
			//if we're changing targets, and a touch is active, we want to
			//clear it.
			this._touchPointID = -1;
			this._target.addEventListener(TouchEvent.TOUCH, target_touchHandler);
		}
		return this._target;
	}
	
	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;
	
	/**
	 * May be set to <code>false</code> to disable selection temporarily
	 * until set back to <code>true</code>.
	 */
	public var isEnabled(get, set):Bool;
	private var _isEnabled:Bool = true;
	private function get_isEnabled():Bool { return this._isEnabled; }
	private function set_isEnabled(value:Bool):Bool
	{
		if (this._isEnabled == value)
		{
			return value;
		}
		if (!value)
		{
			this._touchPointID = -1;
		}
		return this._isEnabled = value;
	}
	
	/**
	 * May be set to <code>true</code> to allow the target to be deselected
	 * when tapped.
	 */
	public var tapToDeselect(get, set):Bool;
	private var _tapToDeselect:Bool;
	private function get_tapToDeselect():Bool { return this._tapToDeselect; }
	private function set_tapToDeselect(value:Bool):Bool
	{
		return this._tapToDeselect = value;
	}
	
	/**
	 * In addition to a normal call to <code>hitTest()</code>, a custom
	 * function may impose additional rules that determine if the target
	 * should be selected. Called on <code>TouchPhase.BEGAN</code>.
	 *
	 * <p>The function must have the following signature:</p>
	 *
	 * <pre>function(localPosition:Point):Boolean;</pre>
	 *
	 * <p>The function should return <code>true</code> if the target should
	 * be selected, and <code>false</code> if it should not be selected.</p>
	 */
	public var customHitTest(get, set):Point->Bool;
	private var _customHitTest:Point->Bool;
	private function get_customHitTest():Point->Bool { return this._customHitTest; }
	private function set_customHitTest(value:Point->Bool):Point->Bool
	{
		return this._customHitTest = value;
	}
	
	/**
	 * @private
	 */
	private function target_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._touchPointID = -1;
			return;
		}
		
		var touch:Touch;
		var point:Point;
		var isInBounds:Bool;
		if (this._touchPointID >= 0)
		{
			//a touch has begun, so we'll ignore all other touches.
			touch = event.getTouch(cast this._target, null, this._touchPointID);
			if (touch == null)
			{
				//this should not happen.
				return;
			}
			
			if (touch.phase == TouchPhase.ENDED)
			{
				var stage:Stage = this._target.stage;
				if (stage != null)
				{
					point = Pool.getPoint();
					touch.getLocation(stage, point);
					if (Std.is(this._target, DisplayObjectContainer))
					{
						isInBounds = cast(this._target, DisplayObjectContainer).contains(stage.hitTest(point));
					}
					else
					{
						isInBounds = cast(this._target, DisplayObject) == stage.hitTest(point);
					}
					Pool.putPoint(point);
					if(isInBounds)
					{
						if(this._tapToDeselect)
						{
							this._target.isSelected = !this._target.isSelected;
						}
						else
						{
							this._target.isSelected = true;
						}
					}
				}
				
				//the touch has ended, so now we can start watching for a
				//new one.
				this._touchPointID = -1;
			}
			return;
		}
		else
		{
			//we aren't tracking another touch, so let's look for a new one.
			touch = event.getTouch(cast this._target, TouchPhase.BEGAN);
			if (touch == null)
			{
				//we only care about the began phase. ignore all other
				//phases when we don't have a saved touch ID.
				return;
			}
			if (this._customHitTest != null)
			{
				point = Pool.getPoint();
				touch.getLocation(cast this._target, point);
				isInBounds = this._customHitTest(point);
				Pool.putPoint(point);
				if (!isInBounds)
				{
					return;
				}
			}
			
			//save the touch ID so that we can track this touch's phases.
			this._touchPointID = touch.id;
		}
	}
	
}