/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import feathers.events.FeathersEventType;
import feathers.layout.ILayout;
import feathers.layout.ILayoutDisplayObject;
import feathers.layout.IVirtualLayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.ViewPortBounds;
import feathers.skins.IStyleProvider;
import feathers.utils.skins.SkinsUtils;
import openfl.geom.Point;
import feathers.core.IFeathersControl;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.Event;
import starling.filters.FragmentFilter;
import starling.rendering.Painter;

/**
 * A generic container that supports layout. For a container that supports
 * scrolling and more robust skinning options, see <code>ScrollContainer</code>.
 *
 * <p>The following example creates a layout group with a horizontal
 * layout and adds two buttons to it:</p>
 *
 * <listing version="3.0">
 * var group:LayoutGroup = new LayoutGroup();
 * var layout:HorizontalLayout = new HorizontalLayout();
 * layout.gap = 20;
 * layout.padding = 20;
 * group.layout = layout;
 * this.addChild( group );
 * 
 * var yesButton:Button = new Button();
 * yesButton.label = "Yes";
 * group.addChild( yesButton );
 * 
 * var noButton:Button = new Button();
 * noButton.label = "No";
 * group.addChild( noButton );</listing>
 *
 * @see ../../../help/layout-group.html How to use the Feathers LayoutGroup component
 * @see feathers.controls.ScrollContainer
 *
 * @productversion Feathers 1.2.0
 */
class LayoutGroup extends FeathersControl 
{
	/**
	 * Flag to indicate that the clipping has changed.
	 */
	private static inline var INVALIDATION_FLAG_CLIPPING:String = "clipping";
	
	/**
	 * An alternate style name to use with <code>LayoutGroup</code> to
	 * allow a theme to give it a toolbar style. If a theme does not provide
	 * a style for the toolbar container, the theme will automatically fall
	 * back to using the default scroll container skin.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the toolbar style is applied to a layout
	 * group:</p>
	 *
	 * <listing version="3.0">
	 * var group:LayoutGroup = new LayoutGroup();
	 * group.styleNameList.add( LayoutGroup.ALTERNATE_STYLE_NAME_TOOLBAR );
	 * this.addChild( group );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_TOOLBAR:String = "feathers-toolbar-layout-group";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>LayoutGroup</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	   Constructor.
	**/
	public function new() 
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, layoutGroup_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, layoutGroup_removedFromStageHandler);
	}
	
	/**
	 * The items added to the group.
	 */
	private var items:Array<DisplayObject> = new Array<DisplayObject>();
	
	/**
	 * The view port bounds result object passed to the layout. Its values
	 * should be set in <code>refreshViewPortBounds()</code>.
	 */
	private var viewPortBounds:ViewPortBounds = new ViewPortBounds();
	
	/**
	   @private
	**/
	private var _layoutResult:LayoutBoundsResult = new LayoutBoundsResult();
	
	/**
	   @private
	**/
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return LayoutGroup.globalStyleProvider;
	}
	
	/**
	   @private
	**/
	public var layout(get, set):ILayout;
	private var _layout:ILayout;
	private function get_layout():ILayout { return this._layout; }
	private function set_layout(value:ILayout):ILayout
	{
		if (this.processStyleRestriction("layout"))
		{
			return value;
		}
		if (this._layout == value)
		{
			return value;
		}
		if (this._layout != null)
		{
			this._layout.removeEventListener(Event.CHANGE, layout_changeHandler);
		}
		this._layout = value;
		if (this._layout != null)
		{
			if (Std.isOfType(this._layout, IVirtualLayout))
			{
				cast(this._layout, IVirtualLayout).useVirtualLayout = false;
			}
			this._layout.addEventListener(Event.CHANGE, layout_changeHandler);
			//if we don't have a layout, nothing will need to be redrawn
			this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._layout;
	}
	
	/**
	   @private
	**/
	public var clipContent(get, set):Bool;
	private var _clipContent:Bool = false;
	private function get_clipContent():Bool { return this._clipContent; }
	private function set_clipContent(value:Bool):Bool
	{
		if (this.processStyleRestriction("clipContent"))
		{
			return value;
		}
		if (this.clipContent == value)
		{
			return value;
		}
		this._clipContent = value;
		if (!value)
		{
			this.mask = null;
		}
		this.invalidate(INVALIDATION_FLAG_CLIPPING);
		return this._clipContent;
	}
	
	/**
	   @private
	**/
	private var _explicitBackgroundWidth:Float;
	
	/**
	   @private
	**/
	private var _explicitBackgroundHeight:Float;
	
	/**
	   @private
	**/
	private var _explicitBackgroundMinWidth:Float;
	
	/**
	   @private
	**/
	private var _explicitBackgroundMinHeight:Float;
	
	/**
	   @private
	**/
	private var _explicitBackgroundMaxWidth:Float;
	
	/**
	   @private
	**/
	private var _explicitBackgroundMaxHeight:Float;
	
	/**
	   @private
	**/
	private var currentBackgroundSkin:DisplayObject;
	
	/**
	   @private
	**/
	public var backgroundSkin(get, set):DisplayObject;
	private var _backgroundSkin:DisplayObject;
	private function get_backgroundSkin():DisplayObject { return _backgroundSkin; }
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
		if (this._backgroundSkin != null &&
			this.currentBackgroundSkin == this._backgroundSkin)
		{
			this.removeCurrentBackgroundSkin(this._backgroundSkin);
			this.currentBackgroundSkin = null;
		}
		this._backgroundSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SKIN);
		return this._backgroundSkin;
	}
	
	/**
	   @private
	**/
	public var backgroundDisabledSkin(get, set):DisplayObject;
	private var _backgroundDisabledSkin:DisplayObject;
	private function get_backgroundDisabledSkin():DisplayObject { return this._backgroundDisabledSkin; }
	private function set_backgroundDisabledSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("backgroundDisabledSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._backgroundDisabledSkin == value)
		{
			return value;
		}
		if (this._backgroundDisabledSkin != null &&
			this.currentBackgroundSkin == this._backgroundDisabledSkin)
		{
			this.removeCurrentBackgroundSkin(this._backgroundDisabledSkin);
			this.currentBackgroundSkin = null;
		}
		this._backgroundDisabledSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SKIN);
		return this._backgroundDisabledSkin;
	}
	
	/**
	 * Determines how the layout group will set its own size when its
	 * dimensions (width and height) aren't set explicitly.
	 *
	 * <p>In the following example, the layout group will be sized to
	 * match the stage:</p>
	 *
	 * <listing version="3.0">
	 * group.autoSizeMode = AutoSizeMode.STAGE;</listing>
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
		if (this.stage != null)
		{
			if (this._autoSizeMode == AutoSizeMode.STAGE)
			{
				this.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			}
			else
			{
				this.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
			}
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._autoSizeMode;
	}
	
	/**
	   @private
	**/
	private var _ignoreChildChanges:Bool = false;
	
	/**
	 * @private
	 * This is similar to _ignoreChildChanges, but setInvalidationFlag()
	 * may still be called.
	 */
	private var _ignoreChildChangesButSetFlags:Bool = false;
	
	/**
	   @private
	**/
	override public function addChildAt(child:DisplayObject, index:Int):DisplayObject 
	{
		if (Std.isOfType(child , IFeathersControl))
		{
			child.addEventListener(FeathersEventType.RESIZE, child_resizeHandler);
		}
		if (Std.isOfType(child, ILayoutDisplayObject))
		{
			child.addEventListener(FeathersEventType.LAYOUT_DATA_CHANGE, child_layoutDataChangeHandler);
		}
		var oldIndex:Int = this.items.indexOf(child);
		if (oldIndex == index)
		{
			return child;
		}
		if (oldIndex != -1)
		{
			this.items.splice(oldIndex, 1);
		}
		this.items.insert(index, child);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return super.addChildAt(child, index);
	}
	
	/**
	   @private
	**/
	override public function removeChildAt(index:Int, dispose:Bool = false):DisplayObject 
	{
		if (index >= 0 && index < this.items.length)
		{
			this.items.splice(index, 1);
		}
		var child:DisplayObject = super.removeChildAt(index, dispose);
		if (Std.isOfType(child, IFeathersControl))
		{
			child.removeEventListener(FeathersEventType.RESIZE, child_resizeHandler);
		}
		if (Std.isOfType(child, ILayoutDisplayObject))
		{
			child.removeEventListener(FeathersEventType.LAYOUT_DATA_CHANGE, child_layoutDataChangeHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return child;
	}
	
	/**
	   @private
	**/
	override public function setChildIndex(child:DisplayObject, index:Int):Void 
	{
		super.setChildIndex(child, index);
		var oldIndex:Int = this.items.indexOf(child);
		if (oldIndex == index)
		{
			return;
		}
		//the super function already checks if oldIndex < 0, and throws an
		//appropriate error, so no need to do it again!
		
		this.items.splice(oldIndex, 1);
		this.items.insert(index, child);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
	/**
	   @private
	**/
	override public function swapChildrenAt(index1:Int, index2:Int):Void 
	{
		super.swapChildrenAt(index1, index2);
		var child1:DisplayObject = this.items[index1];
		var child2:DisplayObject = this.items[index2];
		this.items[index1] = child2;
		this.items[index2] = child1;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
	/**
	   @private
	**/
	override public function sortChildren(compareFunction:DisplayObject->DisplayObject->Int):Void 
	{
		super.sortChildren(compareFunction);
		this.items.sort(compareFunction);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
	/**
	   @private
	**/
	override public function hitTest(localPoint:Point):DisplayObject 
	{
		var localX:Float = localPoint.x;
		var localY:Float = localPoint.y;
		var result:DisplayObject = super.hitTest(localPoint);
		if (result != null)
		{
			if (!this._isEnabled)
			{
				return this;
			}
			return result;
		}
		if (!this.visible || !this.touchable)
		{
			return null;
		}
		if (this.currentBackgroundSkin != null && this._hitArea.contains(localX, localY))
		{
			return this;
		}
		return null;
	}
	
	/**
	   @private
	**/
	override public function render(painter:Painter):Void 
	{
		if (this.currentBackgroundSkin != null &&
			this.currentBackgroundSkin.visible &&
			this.currentBackgroundSkin.alpha > 0)
		{
			//render() won't be called unless the LayoutGroup requires a
			//redraw, so it's not a performance issue to set this flag on
			//the background skin.
			//this is needed to ensure that the background skin position and
			//things are properly updated when the LayoutGroup is
			//transformed
			this.currentBackgroundSkin.setRequiresRedraw();
			
			var mask:DisplayObject = this.currentBackgroundSkin.mask;
			var filter:FragmentFilter = this.currentBackgroundSkin.filter;
			painter.pushState();
			painter.setStateTo(this.currentBackgroundSkin.transformationMatrix, this.currentBackgroundSkin.alpha, this.currentBackgroundSkin.blendMode);
			if (mask != null)
			{
				painter.drawMask(mask);
			}
			if (filter != null)
			{
				filter.render(painter);
			}
			else
			{
				this.currentBackgroundSkin.render(painter);
			}
			if (mask != null)
			{
				painter.eraseMask(mask);
			}
			painter.popState();
		}
		super.render(painter);
	}
	
	/**
	   @private
	**/
	@:access(starling.display.DisplayObject)
	override public function dispose():Void 
	{
		if (this.currentBackgroundSkin != null)
		{
			this.currentBackgroundSkin.__setParent(null);
		}
		//we don't dispose it if the group is the parent because it'll
		//already get disposed in super.dispose()
		if (this._backgroundSkin != null &&
			this._backgroundSkin.parent != this)
		{
			this._backgroundSkin.dispose();
		}
		if (this._backgroundDisabledSkin != null &&
			this._backgroundDisabledSkin.parent != this)
		{
			this._backgroundDisabledSkin.dispose();
		}
		this.layout = null;
		super.dispose();
	}
	
	/**
	 * Readjusts the layout of the group according to its current content.
	 * Call this method when changes to the content cannot be automatically
	 * detected by the container. For instance, Feathers components dispatch
	 * <code>FeathersEventType.RESIZE</code> when their width and height
	 * values change, but standard Starling display objects like
	 * <code>Sprite</code> and <code>Image</code> do not.
	 */
	public function readjustLayout():Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
	/**
	   @private
	**/
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
	   @private
	**/
	override function initialize():Void 
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
	   @private
	**/
	override function draw():Void 
	{
		//children are allowed to change during draw() in a subclass up
		//until it calls super.draw().
		this._ignoreChildChangesButSetFlags = false;
		
		var layoutInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var clippingInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_CLIPPING);
		//we don't have scrolling, but a subclass might
		var scrollInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SCROLL);
		var skinInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SKIN);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		
		//scrolling only affects the layout is requiresLayoutOnScroll is true
		if (!layoutInvalid && scrollInvalid && this._layout != null && this._layout.requiresLayoutOnScroll)
		{
			layoutInvalid = true;
		}
		
		if (skinInvalid || stateInvalid)
		{
			this.refreshBackgroundSkin();
		}
		
		if (sizeInvalid || layoutInvalid || skinInvalid || stateInvalid)
		{
			this.refreshViewPortBounds();
			if (this._layout != null)
			{
				var oldIgnoreChildChanges:Bool = this._ignoreChildChanges;
				this._ignoreChildChanges = true;
				this._layout.layout(this.items, this.viewPortBounds, this._layoutResult);
				this._ignoreChildChanges = oldIgnoreChildChanges;
			}
			else
			{
				this.handleManualLayout();
			}
			this.handleLayoutResult();
			this.refreshBackgroundLayout();
			
			//final validation to avoid juggler next frame issues
			this.validateChildren();
		}
		
		if (sizeInvalid || clippingInvalid)
		{
			this.refreshClipRect();
		}
	}
	
	/**
	 * Choose the appropriate background skin based on the control's current
	 * state.
	 */
	@:access(starling.display.DisplayObject)
	private function refreshBackgroundSkin():Void
	{
		var oldBackgroundSkin:DisplayObject = this.currentBackgroundSkin;
		this.currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (this.currentBackgroundSkin != oldBackgroundSkin)
		{
			this.removeCurrentBackgroundSkin(oldBackgroundSkin);
			if (this.currentBackgroundSkin != null)
			{
				if (Std.isOfType(this.currentBackgroundSkin, IFeathersControl))
				{
					cast(this.currentBackgroundSkin, IFeathersControl).initializeNow();
				}
				if (Std.isOfType(this.currentBackgroundSkin, IMeasureDisplayObject))
				{
					var measureSkin:IMeasureDisplayObject = cast this.currentBackgroundSkin;
					this._explicitBackgroundWidth = measureSkin.explicitWidth;
					this._explicitBackgroundHeight = measureSkin.explicitHeight;
					this._explicitBackgroundMinWidth = measureSkin.explicitMinWidth;
					this._explicitBackgroundMinHeight = measureSkin.explicitMinHeight;
					this._explicitBackgroundMaxWidth = measureSkin.explicitMaxWidth;
					this._explicitBackgroundMaxHeight = measureSkin.explicitMaxHeight;
				}
				else
				{
					this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
					this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
					this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
					this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
					this._explicitBackgroundMaxWidth = this._explicitBackgroundWidth;
					this._explicitBackgroundMaxHeight = this._explicitBackgroundHeight;
				}
				this.currentBackgroundSkin.__setParent(this);
			}
		}
	}
	
	/**
	 * @private
	 */
	@:access(starling.display.DisplayObject)
	private function removeCurrentBackgroundSkin(skin:DisplayObject):Void
	{
		if (skin == null)
		{
			return;
		}
		if (skin.parent == this)
		{
			//we need to restore these values so that they won't be lost the
			//next time that this skin is used for measurement
			skin.width = this._explicitBackgroundWidth;
			skin.height = this._explicitBackgroundHeight;
			if (Std.isOfType(skin, IMeasureDisplayObject))
			{
				var measureSkin:IMeasureDisplayObject = cast skin;
				measureSkin.minWidth = this._explicitBackgroundMinWidth;
				measureSkin.minHeight = this._explicitBackgroundMinHeight;
				measureSkin.maxWidth = this._explicitBackgroundMaxWidth;
				measureSkin.maxHeight = this._explicitBackgroundMaxHeight;
			}
			this.setRequiresRedraw();
			skin.__setParent(null);
		}
	}
	
	/**
	 * @private
	 */
	private function getCurrentBackgroundSkin():DisplayObject
	{
		if (!this._isEnabled && this._backgroundDisabledSkin != null)
		{
			return this._backgroundDisabledSkin;
		}
		return this._backgroundSkin;
	}
	
	/**
	 * @private
	 */
	private function refreshBackgroundLayout():Void
	{
		if (this.currentBackgroundSkin == null)
		{
			return;
		}
		if (this.currentBackgroundSkin.width != this.actualWidth ||
			this.currentBackgroundSkin.height != this.actualHeight)
		{
			this.currentBackgroundSkin.width = this.actualWidth;
			this.currentBackgroundSkin.height = this.actualHeight;
		}
	}
	
	/**
	 * Refreshes the values in the <code>viewPortBounds</code> variable that
	 * is passed to the layout.
	 */
	private function refreshViewPortBounds():Void
	{
		var needsWidth:Bool = this._explicitWidth != this._explicitWidth; //isNaN
		var needsHeight:Bool = this._explicitHeight != this._explicitHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinWidth != this._explicitMinWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinHeight != this._explicitMinHeight; //isNaN
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		
		this.viewPortBounds.x = 0;
		this.viewPortBounds.y = 0;
		this.viewPortBounds.scrollX = 0;
		this.viewPortBounds.scrollY = 0;
		if (needsWidth && this._autoSizeMode == AutoSizeMode.STAGE &&
			this.stage != null)
		{
			this.viewPortBounds.explicitWidth = this.stage.stageWidth;
		}
		else
		{
			this.viewPortBounds.explicitWidth = this._explicitWidth;
		}
		if (needsHeight && this._autoSizeMode == AutoSizeMode.STAGE && 
			this.stage != null)
		{
			this.viewPortBounds.explicitHeight = this.stage.stageHeight;
		}
		else
		{
			this.viewPortBounds.explicitHeight = this._explicitHeight;
		}
		var viewPortMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			viewPortMinWidth = 0;
		}
		var viewPortMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			viewPortMinHeight = 0;
		}
		if (this.currentBackgroundSkin != null)
		{
			//because the layout might need it, we account for the
			//dimensions of the background skin when determining the minimum
			//dimensions of the view port.
			//we can't use the minimum dimensions of the background skin
			if (this.currentBackgroundSkin.width > viewPortMinWidth)
			{
				viewPortMinWidth = this.currentBackgroundSkin.width;
			}
			if (this.currentBackgroundSkin.height > viewPortMinHeight)
			{
				viewPortMinHeight = this.currentBackgroundSkin.height;
			}
		}
		this.viewPortBounds.minWidth = viewPortMinWidth;
		this.viewPortBounds.minHeight = viewPortMinHeight;
		this.viewPortBounds.maxWidth = this._explicitMaxWidth;
		this.viewPortBounds.maxHeight = this._explicitMaxHeight;
	}
	
	/**
	 * @private
	 */
	private function handleLayoutResult():Void
	{
		//the layout's dimensions are also the minimum dimensions
		//we calculate the minimum dimensions for the background skin in
		//refreshViewPortBounds() and let the layout handle it
		var viewPortWidth:Float = this._layoutResult.viewPortWidth;
		var viewPortHeight:Float = this._layoutResult.viewPortHeight;
		this.saveMeasurements(viewPortWidth, viewPortHeight,
			viewPortWidth, viewPortHeight);
	}
	
	/**
	 * @private
	 */
	private function handleManualLayout():Void
	{
		var maxX:Float = this.viewPortBounds.explicitWidth;
		if (maxX != maxX) //isNaN
		{
			maxX = 0;
		}
		var maxY:Float = this.viewPortBounds.explicitHeight;
		if (maxY != maxY) //isNaN
		{
			maxY = 0;
		}
		var oldIgnoreChildChanges:Bool = this._ignoreChildChanges;
		this._ignoreChildChanges = true;
		var itemCount:Int = this.items.length;
		for (i in 0...itemCount)
		{
			var item:DisplayObject = this.items[i];
			if (Std.isOfType(item, ILayoutDisplayObject) && cast(item, ILayoutDisplayObject).includeInLayout)
			{
				continue;
			}
			if (Std.isOfType(item, IValidating))
			{
				cast(item, IValidating).validate();
			}
			var itemMaxX:Float = item.x - item.pivotX + item.width;
			var itemMaxY:Float = item.y - item.pivotY + item.height;
			if (itemMaxX == itemMaxX && //!isNaN
				itemMaxX > maxX)
			{
				maxX = itemMaxX;
			}
			if (itemMaxY == itemMaxY && //!isNaN
				itemMaxY > maxY)
			{
				maxY = itemMaxY;
			}
		}
		this._ignoreChildChanges = oldIgnoreChildChanges;
		this._layoutResult.contentX = 0;
		this._layoutResult.contentY = 0;
		this._layoutResult.contentWidth = maxX;
		this._layoutResult.contentHeight = maxY;
		if (this.viewPortBounds.explicitWidth == this.viewPortBounds.explicitWidth) //!isNaN
		{
			this._layoutResult.viewPortWidth = this.viewPortBounds.explicitWidth;
		}
		else
		{
			var viewPortMinWidth:Float = this.viewPortBounds.minWidth;
			if (maxX < viewPortMinWidth)
			{
				maxX = viewPortMinWidth;
			}
			var viewPortMaxWidth:Float = this.viewPortBounds.maxWidth;
			if (maxX > viewPortMaxWidth)
			{
				
				maxX = viewPortMaxWidth;
			}
			this._layoutResult.viewPortWidth = maxX;
		}
		if (this.viewPortBounds.explicitHeight == this.viewPortBounds.explicitHeight)
		{
			this._layoutResult.viewPortHeight = this.viewPortBounds.explicitHeight;
		}
		else
		{
			var viewPortMinHeight:Float = this.viewPortBounds.minHeight;
			if (maxY < viewPortMinHeight)
			{
				maxY = viewPortMinHeight;
			}
			var viewPortMaxHeight:Float = this.viewPortBounds.maxHeight;
			if (maxY > viewPortMaxHeight)
			{
				maxY = viewPortMaxHeight;
			}
			this._layoutResult.viewPortHeight = maxY;
		}
	}
	
	/**
	 * @private
	 */
	private function validateChildren():Void
	{
		if (Std.isOfType(this.currentBackgroundSkin, IValidating))
		{
			
			cast(this.currentBackgroundSkin, IValidating).validate();
		}
		var itemCount:Int = this.items.length;
		for (i in 0...itemCount)
		{
			var item:DisplayObject = this.items[i];
			if (Std.isOfType(item, IValidating))
			{
				cast(item, IValidating).validate();
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshClipRect():Void
	{
		if (this.clipContent)
		{
			return;
		}
		
		var mask:Quad = cast this.mask;
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
			this.mask = mask;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutGroup_addedToStageHandler(event:Event):Void
	{
		if (this._autoSizeMode == AutoSizeMode.STAGE)
		{
			//if we validated before being added to the stage, or if we've
			//been removed from stage and added again, we need to be sure
			//that the new stage dimensions are accounted for.
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			
			this.stage.addEventListener(Event.RESIZE, stage_resizeHandler);
		}
	}
	
	/**
	 * @private
	 */
	private function layoutGroup_removedFromStageHandler(event:Event):Void
	{
		this.stage.removeEventListener(Event.RESIZE, stage_resizeHandler);
	}

	/**
	 * @private
	 */
	private function layout_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
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
			this.setInvalidationFlag(FeathersControl.INVALIDATION_FLAG_LAYOUT);
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
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
			this.setInvalidationFlag(FeathersControl.INVALIDATION_FLAG_LAYOUT);
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
	/**
	 * @private
	 */
	private function stage_resizeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
	}
	
}