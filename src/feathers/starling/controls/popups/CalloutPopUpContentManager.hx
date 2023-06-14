/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.popups;
import feathers.starling.core.PopUpManager;
import feathers.starling.controls.Callout;
import feathers.starling.utils.geom.GeomUtils;
import haxe.Constraints.Function;
import openfl.errors.IllegalOperationError;
import openfl.geom.Matrix;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.utils.Pool;

/**
 * Displays pop-up content (such as the List in a PickerList) in a Callout.
 *
 * @see feathers.controls.PickerList
 * @see feathers.controls.Callout
 *
 * @productversion Feathers 1.0.0
 */
class CalloutPopUpContentManager extends EventDispatcher implements IPopUpContentManager
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * The factory used to create the <code>Callout</code> instance. If
	 * <code>null</code>, <code>Callout.calloutFactory()</code> will be used.
	 *
	 * <p>Note: If you change this value while a callout is open, the new
	 * value will not go into effect until the callout is closed and a new
	 * callout is opened.</p>
	 *
	 * @see feathers.controls.Callout#calloutFactory
	 *
	 * @default null
	 */
	public var calloutFactory:Void->Callout;
	
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
	 * <p>Note: If you change this value while a callout is open, the new
	 * value will not go into effect until the callout is closed and a new
	 * callout is opened.</p>
	 *
	 * <p>In the following example, the callout's supported positions are
	 * restricted to the top and bottom of the origin:</p>
	 *
	 * <listing version="3.0">
	 * manager.supportedPositions = new &lt;String&gt;[RelativePosition.TOP, RelativePosition.BOTTOM];</listing>
	 *
	 * <p>In the following example, the callout's position is restricted to
	 * the right of the origin:</p>
	 *
	 * <listing version="3.0">
	 * manager.supportedPositions = new &lt;String&gt;[RelativePosition.RIGHT];</listing>
	 *
	 * @default null
	 *
	 * @see feathers.layout.RelativePosition#TOP
	 * @see feathers.layout.RelativePosition#RIGHT
	 * @see feathers.layout.RelativePosition#BOTTOM
	 * @see feathers.layout.RelativePosition#LEFT
	 */
	public var supportedPositions:Array<String> = Callout.DEFAULT_POSITIONS;
	
	/**
	 * Determines if the callout will be modal or not.
	 *
	 * <p>Note: If you change this value while a callout is open, the new
	 * value will not go into effect until the callout is closed and a new
	 * callout is opened.</p>
	 *
	 * <p>In the following example, the callout is not modal:</p>
	 *
	 * <listing version="3.0">
	 * manager.isModal = false;</listing>
	 *
	 * @default true
	 */
	public var isModal:Bool = true;
	
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
	 * @private
	 */
	private var content:DisplayObject;

	/**
	 * @private
	 */
	private var callout:Callout;
	
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
		
		var scaledCalloutFactory:Void->Callout = this.calloutFactory;
		//make sure the content is scaled the same as the source
		var matrix:Matrix = Pool.getMatrix();
		source.getTransformationMatrix(PopUpManager.root, matrix);
		var contentScaleX:Float = GeomUtils.matrixToScaleX(matrix);
		var contentScaleY:Float = GeomUtils.matrixToScaleY(matrix);
		Pool.putMatrix(matrix);
		if (contentScaleX != 1 || contentScaleY != 1)
		{
			var originalCalloutFactory:Void->Callout = this.calloutFactory;
			if (originalCalloutFactory == null)
			{
				originalCalloutFactory = Callout.calloutFactory;
			}
			scaledCalloutFactory = function():Callout
			{
				var callout:Callout = originalCalloutFactory();
				callout.scaleX = contentScaleX;
				callout.scaleY = contentScaleY;
				return callout;
			};
			
		}
		
		this.content = content;
		this.callout = Callout.show(content, source, this.supportedPositions, this.isModal, scaledCalloutFactory, this._overlayFactory);
		this.callout.addEventListener(Event.REMOVED_FROM_STAGE, callout_removedFromStageHandler);
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
		this.callout.close();
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
	private function cleanup():Void
	{
		this.content = null;
		this.callout.content = null;
		this.callout.removeEventListener(Event.REMOVED_FROM_STAGE, callout_removedFromStageHandler);
		this.callout = null;
	}

	/**
	 * @private
	 */
	private function callout_removedFromStageHandler(event:Event):Void
	{
		this.cleanup();
		this.dispatchEventWith(Event.CLOSE);
	}
	
}