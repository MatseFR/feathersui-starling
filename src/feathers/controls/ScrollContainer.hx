/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.controls.supportClasses.LayoutViewPort;
import feathers.core.IFeathersControl;
import feathers.core.IFocusContainer;
import feathers.events.FeathersEventType;
import feathers.layout.ILayout;
import feathers.layout.ILayoutDisplayObject;
import feathers.layout.IVirtualLayout;
import feathers.skins.IStyleProvider;
import openfl.errors.ArgumentError;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;

/**
 * A generic container that supports layout, scrolling, and a background
 * skin. For a lighter container, see <code>LayoutGroup</code>, which
 * focuses specifically on layout without scrolling.
 *
 * <p>The following example creates a scroll container with a horizontal
 * layout and adds two buttons to it:</p>
 *
 * <listing version="3.0">
 * var container:ScrollContainer = new ScrollContainer();
 * var layout:HorizontalLayout = new HorizontalLayout();
 * layout.gap = 20;
 * layout.padding = 20;
 * container.layout = layout;
 * this.addChild( container );
 * 
 * var yesButton:Button = new Button();
 * yesButton.label = "Yes";
 * container.addChild( yesButton );
 * 
 * var noButton:Button = new Button();
 * noButton.label = "No";
 * container.addChild( noButton );</listing>
 *
 * @see ../../../help/scroll-container.html How to use the Feathers ScrollContainer component
 * @see feathers.controls.LayoutGroup
 *
 * @productversion Feathers 1.0.0
 */
class ScrollContainer extends Scroller implements IScrollContainer implements IFocusContainer
{
	/**
	 * An alternate style name to use with <code>ScrollContainer</code> to
	 * allow a theme to give it a toolbar style. If a theme does not provide
	 * a style for the toolbar container, the theme will automatically fall
	 * back to using the default scroll container skin.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the toolbar style is applied to a scroll
	 * container:</p>
	 *
	 * <listing version="3.0">
	 * var container:ScrollContainer = new ScrollContainer();
	 * container.styleNameList.add( ScrollContainer.ALTERNATE_STYLE_NAME_TOOLBAR );
	 * this.addChild( container );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_TOOLBAR:String = "feathers-toolbar-scroll-container";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>ScrollContainer</code>
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
		this.layoutViewPort = new LayoutViewPort();
		this.viewPort = this.layoutViewPort;
		this.addEventListener(Event.ADDED_TO_STAGE, scrollContainer_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, scrollContainer_removedFromStageHandler);
	}
	
	/**
	 * A flag that indicates if the display list functions like <code>addChild()</code>
	 * and <code>removeChild()</code> will be passed to the internal view
	 * port.
	 */
	private var displayListBypassEnabled:Bool = true;
	
	/**
	 * @private
	 */
	private var layoutViewPort:LayoutViewPort;
	
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return ScrollContainer.globalStyleProvider;
	}
	
	/**
	 * @copy feathers.core.IFocusContainer#isChildFocusEnabled
	 *
	 * @default true
	 *
	 * @see #isFocusEnabled
	 */
	public var isChildFocusEnabled(get, set):Bool;
	private var _isChildFocusEnabled:Bool = true;
	private function get_isChildFocusEnabled():Bool { return this._isEnabled && this._isChildFocusEnabled; }
	private function set_isChildFocusEnabled(value:Bool):Bool
	{
		return this._isChildFocusEnabled = value;
	}
	
	/**
	 * @private
	 */
	public var layout(get, set):ILayout;
	private var _layout:ILayout;
	private function get_layout():ILayout { return this._layout; }
	private function set_layout(value:ILayout):ILayout
	{
		if (this.processStyleRestriction(arguments.callee))
		{
			return value;
		}
		if (this._layout == value)
		{
			return value;
		}
		this._layout = value;
		this.invalidate(INVALIDATION_FLAG_LAYOUT);
		return this._layout;
	}
	
	/**
	 * Determines how the container will set its own size when its
	 * dimensions (width and height) aren't set explicitly.
	 *
	 * <p>In the following example, the container will be sized to
	 * match the stage:</p>
	 *
	 * <listing version="3.0">
	 * container.autoSizeMode = AutoSizeMode.STAGE;</listing>
	 *
	 * <p>Usually defaults to <code>AutoSizeMode.CONTENT</code>. However, if
	 * this component is the root of the Starling display list, defaults to
	 * <code>AutoSizeMode.STAGE</code> instead.</p>
	 *
	 * @see feathers.controls.AutoSizeMode#STAGE
	 * @see feathers.controls.AutoSizeMode#CONTENT
	 */
	public var autoSizeMode(get, set):String;
	private var _autoSizeMode:String = AutoSizeMode.CONTENT;
	private function get_autoSizeMode():String { return this._autoSizeMode; }
	private function set_autoSizeMode(value:String):String
	{
		if (this._autoSizeMode == value)
		{
			return value;
		}
		this._autoSizeMode = value;
		this._measureViewPort = this._autoSizeMode != AutoSizeMode.STAGE;
		if (this.stage != null)
		{
			if (this._autoSizeMode == AutoSizeMode.STAGE)
			{
				this.stage.addEventListener(Event.RESIZE, scrollContainer_stage_resizeHandler);
			}
			else
			{
				this.stage.removeEventListener(Event.RESIZE, scrollContainer_stage_resizeHandler);
			}
		}
		this.invalidate(INVALIDATION_FLAG_SIZE);
		return this._autoSizeMode;
	}
	
	/**
	 * @private
	 */
	private var _ignoreChildChanges:Bool = false;

	/**
	 * @private
	 * This is similar to _ignoreChildChanges, but setInvalidationFlag()
	 * may still be called.
	 */
	private var _ignoreChildChangesButSetFlags:Bool = false;
	
	/**
	 * @private
	 */
	override function get_numChildren():Int 
	{
		if (!this.displayListBypassEnabled)
		{
			return super.numChildren;
		}
		return cast(this.viewPort, DisplayObjectContainer).numChildren;
	}
	
	/**
	 * @inheritDoc
	 */
	public var numRawChildren(get, never):Int
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		var result:Int = super.numChildren;
		this.displayListBypassEnabled = oldBypass;
		return result;
	}
	
	/**
	 * @private
	 */
	override public function getChildByName(name:String):DisplayObject
	{
		if (!this.displayListBypassEnabled)
		{
			return super.getChildByName(name);
		}
		return cast(this.viewPort, DisplayObjectContainer).getChildByName(name);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getRawChildByName(name:String):DisplayObject
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		var child:DisplayObject = super.getChildByName(name);
		this.displayListBypassEnabled = oldBypass;
		return child;
	}
	
	/**
	 * @private
	 */
	override public function getChildAt(index:Int):DisplayObject
	{
		if (!this.displayListBypassEnabled)
		{
			return super.getChildAt(index);
		}
		return cast(this.viewPort, DisplayObjectContainer).getChildAt(index);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getRawChildAt(index:int):DisplayObject
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		var child:DisplayObject = super.getChildAt(index);
		this.displayListBypassEnabled = oldBypass;
		return child;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addRawChild(child:DisplayObject):DisplayObject
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		if (child.parent == this)
		{
			super.setChildIndex(child, super.numChildren);
		}
		else
		{
			child = super.addChildAt(child, super.numChildren);
		}
		this.displayListBypassEnabled = oldBypass;
		return child;
	}
	
	/**
	 * @private
	 */
	override public function addChild(child:DisplayObject):DisplayObject
	{
		return this.addChildAt(child, this.numChildren);
	}
	
	/**
	 * @private
	 */
	override public function addChildAt(child:DisplayObject, index:int):DisplayObject
	{
		if (!this.displayListBypassEnabled)
		{
			return super.addChildAt(child, index);
		}
		var result:DisplayObject = DisplayObjectContainer(this.viewPort).addChildAt(child, index);
		if (Std.isOfType(result, IFeathersControl))
		{
			result.addEventListener(Event.RESIZE, child_resizeHandler);
		}
		if (Std.isOfType(result, ILayoutDisplayObject))
		{
			result.addEventListener(FeathersEventType.LAYOUT_DATA_CHANGE, child_layoutDataChangeHandler);
		}
		this.invalidate(INVALIDATION_FLAG_SIZE);
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addRawChildAt(child:DisplayObject, index:Int):DisplayObject
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		child = super.addChildAt(child, index);
		this.displayListBypassEnabled = oldBypass;
		return child;
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeRawChild(child:DisplayObject, dispose:Bool = false):DisplayObject
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		var index:Int = super.getChildIndex(child);
		if (index >= 0)
		{
			super.removeChildAt(index, dispose);
		}
		this.displayListBypassEnabled = oldBypass;
		return child;
	}
	
	/**
	 * @private
	 */
	override public function removeChildAt(index:Int, dispose:Bool = false):DisplayObject
	{
		if (!this.displayListBypassEnabled)
		{
			return super.removeChildAt(index, dispose);
		}
		var result:DisplayObject = DisplayObjectContainer(this.viewPort).removeChildAt(index, dispose);
		if (Std.isOfType(result, IFeathersControl))
		{
			result.removeEventListener(Event.RESIZE, child_resizeHandler);
		}
		if (Std.isOfType(result, ILayoutDisplayObject))
		{
			result.removeEventListener(FeathersEventType.LAYOUT_DATA_CHANGE, child_layoutDataChangeHandler);
		}
		this.invalidate(INVALIDATION_FLAG_SIZE);
		return result;
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeRawChildAt(index:Int, dispose:Bool = false):DisplayObject
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		var child:DisplayObject = super.removeChildAt(index, dispose);
		this.displayListBypassEnabled = oldBypass;
		return child;
	}
	
	/**
	 * @private
	 */
	override public function getChildIndex(child:DisplayObject):Int
	{
		if (!this.displayListBypassEnabled)
		{
			return super.getChildIndex(child);
		}
		return cast(this.viewPort, DisplayObjectContainer).getChildIndex(child);
	}
	
	/**
	 * @inheritDoc
	 */
	public function getRawChildIndex(child:DisplayObject):Int
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		var index:Int = super.getChildIndex(child);
		this.displayListBypassEnabled = oldBypass;
		return index;
	}
	
	/**
	 * @private
	 */
	override public function setChildIndex(child:DisplayObject, index:Int):Void
	{
		if (!this.displayListBypassEnabled)
		{
			super.setChildIndex(child, index);
			return;
		}
		cast(this.viewPort, DisplayObjectContainer).setChildIndex(child, index);
	}
	
	/**
	 * @inheritDoc
	 */
	public function setRawChildIndex(child:DisplayObject, index:Int):Void
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		super.setChildIndex(child, index);
		this.displayListBypassEnabled = oldBypass;
	}
	
	/**
	 * @inheritDoc
	 */
	public function swapRawChildren(child1:DisplayObject, child2:DisplayObject):Void
	{
		var index1:Int = this.getRawChildIndex(child1);
		var index2:Int = this.getRawChildIndex(child2);
		if (index1 < 0 || index2 < 0)
		{
			throw new ArgumentError("Not a child of this container");
		}
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		this.swapRawChildrenAt(index1, index2);
		this.displayListBypassEnabled = oldBypass;
	}
	
	/**
	 * @private
	 */
	override public function swapChildrenAt(index1:Int, index2:Int):Void
	{
		if (!this.displayListBypassEnabled)
		{
			super.swapChildrenAt(index1, index2);
			return;
		}
		cast(this.viewPort, DisplayObjectContainer).swapChildrenAt(index1, index2);
	}
	
	/**
	 * @inheritDoc
	 */
	public function swapRawChildrenAt(index1:Int, index2:Int):Void
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		super.swapChildrenAt(index1, index2);
		this.displayListBypassEnabled = oldBypass;
	}
	
	/**
	 * @private
	 */
	override public function sortChildren(compareFunction:DisplayObject->DisplayObject->Int):Void
	{
		if (!this.displayListBypassEnabled)
		{
			super.sortChildren(compareFunction);
			return;
		}
		cast(this.viewPort, DisplayObjectContainer).sortChildren(compareFunction);
	}
	
	/**
	 * @inheritDoc
	 */
	public function sortRawChildren(compareFunction:DisplayObject->DisplayObject->Int):Void
	{
		var oldBypass:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		super.sortChildren(compareFunction);
		this.displayListBypassEnabled = oldBypass;
	}
	
	/**
	 * Readjusts the layout of the container according to its current
	 * content. Call this method when changes to the content cannot be
	 * automatically detected by the container. For instance, Feathers
	 * components dispatch <code>FeathersEventType.RESIZE</code> when their
	 * width and height values change, but standard Starling display objects
	 * like <code>Sprite</code> and <code>Image</code> do not.
	 */
	public function readjustLayout():Void
	{
		this.layoutViewPort.readjustLayout();
		this.invalidate(INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	override public function validate():Void
	{
		//for the start of validation, we're going to ignore when children
		//resize or dispatch changes to layout data. this allows subclasses
		//to modify children in draw() before the layout is applied.
		var oldIgnoreChildChanges:Bool = this._ignoreChildChangesButSetFlags;
		this._ignoreChildChangesButSetFlags = true;
		super.validate();
		//if super.validate() returns without calling draw(), the flag
		//won't be reset before layout is called, so we need reset manually.
		this._ignoreChildChangesButSetFlags = oldIgnoreChildChanges;
	}
	
	/**
	 * @private
	 */
	override protected function initialize():Void
	{
		if (this.stage != null)
		{
			//we use starling.root because a pop-up's root and the stage
			//root may be different.
			if (this.stage.starling.root == this)
			{
				this.autoSizeMode = AutoSizeMode.STAGE;
			}
		}
		super.initialize();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		//children are allowed to change during draw() in a subclass up
		//until it calls super.draw().
		this._ignoreChildChangesButSetFlags = false;
		
		var layoutInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_LAYOUT);
		
		if (layoutInvalid)
		{
			if (Std.isOfType(this._layout, IVirtualLayout))
			{
				cast(this._layout, IVirtualLayout).useVirtualLayout = false;
			}
			this.layoutViewPort.layout = this._layout;
		}
		
		var oldIgnoreChildChanges:Bool = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		super.draw();
		this._ignoreChildChanges = oldIgnoreChildChanges;
	}
	
	/**
	 * @private
	 */
	override protected function autoSizeIfNeeded():Boolean
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		if (this._autoSizeMode == AutoSizeMode.STAGE &&
			this.stage != null)
		{
			var newWidth:Float = this.stage.stageWidth;
			var newHeight:Float = this.stage.stageHeight;
			return this.saveMeasurements(newWidth, newHeight, newWidth, newHeight);
		}
		return super.autoSizeIfNeeded();
	}
	
	/**
	 * @private
	 */
	private function scrollContainer_addedToStageHandler(event:Event):Void
	{
		if (this._autoSizeMode == AutoSizeMode.STAGE)
		{
			//if we validated before being added to the stage, or if we've
			//been removed from stage and added again, we need to be sure
			//that the new stage dimensions are accounted for.
			this.invalidate(INVALIDATION_FLAG_SIZE);
			
			this.stage.addEventListener(Event.RESIZE, scrollContainer_stage_resizeHandler);
		}
	}
	
	/**
	 * @private
	 */
	private function scrollContainer_removedFromStageHandler(event:Event):Void
	{
		this.stage.removeEventListener(Event.RESIZE, scrollContainer_stage_resizeHandler);
	}
	
	/**
	 * @private
	 */
	private function child_resizeHandler(event:Event):Void
	{
		if (this._ignoreChildChanges)
		{
			return;
		}
		if (this._ignoreChildChangesButSetFlags)
		{
			this.setInvalidationFlag(INVALIDATION_FLAG_SIZE);
			return;
		}
		this.invalidate(INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function child_layoutDataChangeHandler(event:Event):Void
	{
		if (this._ignoreChildChanges)
		{
			return;
		}
		if (this._ignoreChildChangesButSetFlags)
		{
			this.setInvalidationFlag(INVALIDATION_FLAG_SIZE);
			return;
		}
		this.invalidate(INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function scrollContainer_stage_resizeHandler(event:Event):Void
	{
		this.invalidate(INVALIDATION_FLAG_SIZE);
	}
	
}