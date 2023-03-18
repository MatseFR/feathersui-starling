/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.renderers;
import feathers.controls.Tree;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IStateObserver;
import feathers.core.IValidating;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.utils.touch.TapToTrigger;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;

/**
 * The default item renderer for Tree control. Supports up to three optional
 * sub-views, including a label to display text, an icon to display an
 * image, and an "accessory" to display a UI control or another display
 * object (with shortcuts for including a second image or a second label).
 *
 * @see feathers.controls.Tree
 *
 * @productversion Feathers 3.3.0
 */
class DefaultTreeItemRenderer extends BaseDefaultItemRenderer implements ITreeItemRenderer
{
	/**
	 * @copy feathers.controls.renderers.BaseDefaultItemRenderer#DEFAULT_CHILD_STYLE_NAME_LABEL
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_LABEL:String = "feathers-item-renderer-label";

	/**
	 * @copy feathers.controls.renderers.BaseDefaultItemRenderer#DEFAULT_CHILD_STYLE_NAME_ICON_LABEL
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ICON_LABEL:String = "feathers-item-renderer-icon-label";

	/**
	 * @copy feathers.controls.renderers.BaseDefaultItemRenderer#DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LABEL
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ACCESSORY_LABEL:String = "feathers-item-renderer-accessory-label";

	/**
	 * The default <code>IStyleProvider</code> for all <code>DefaultTreeItemRenderer</code>
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
		this.addEventListener(Event.TRIGGERED, treeItemRenderer_triggeredHandler);
	}
	
	/**
	 * @private
	 */
	private var _ignoreDisclosureIconResizes:Bool = false;

	/**
	 * @private
	 */
	private var _ignoreBranchOrLeafIconResizes:Bool = false;

	/**
	 * @private
	 */
	private var _disclosureIconTapToTrigger:TapToTrigger = null;

	/**
	 * @private
	 */
	private var _currentDisclosureIcon:DisplayObject = null;
	
	/**
	 * @private
	 */
	public var disclosureIcon(get, set):DisplayObject;
	private var _disclosureIcon:DisplayObject;
	private function get_disclosureIcon():DisplayObject { return this._disclosureIcon; }
	private function set_disclosureIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("disclosureIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._disclosureIcon == value)
		{
			return value;
		}
		if (this._disclosureIcon != null &&
			this._currentDisclosureIcon == this._disclosureIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentDisclosureIcon(this._disclosureIcon);
			this._currentDisclosureIcon = null;
		}
		this._disclosureIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._disclosureIcon;
	}
	
	/**
	 * @private
	 */
	public var disclosureOpenIcon(get, set):DisplayObject;
	private var _disclosureOpenIcon:DisplayObject;
	private function get_disclosureOpenIcon():DisplayObject { return this._disclosureOpenIcon; }
	private function set_disclosureOpenIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("disclosureOpenIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._disclosureOpenIcon == value)
		{
			return value;
		}
		if (this._disclosureOpenIcon != null &&
			this._currentDisclosureIcon == this._disclosureOpenIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentDisclosureIcon(this._disclosureOpenIcon);
			this._currentDisclosureIcon = null;
		}
		this._disclosureOpenIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._disclosureOpenIcon;
	}
	
	/**
	 * @private
	 */
	public var disclosureClosedIcon(get, set):DisplayObject;
	private var _disclosureClosedIcon:DisplayObject;
	private function get_disclosureClosedIcon():DisplayObject { return this._disclosureClosedIcon; }
	private function set_disclosureClosedIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("disclosureClosedIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._disclosureClosedIcon == value)
		{
			return value;
		}
		if (this._disclosureClosedIcon != null &&
			this._currentDisclosureIcon == this._disclosureClosedIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentDisclosureIcon(this._disclosureClosedIcon);
			this._currentDisclosureIcon = null;
		}
		this._disclosureClosedIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._disclosureClosedIcon;
	}
	
	/**
	 * @private
	 */
	private var _currentBranchOrLeafIcon:DisplayObject = null;
	
	/**
	 * @private
	 */
	public var branchIcon(get, set):DisplayObject;
	private var _branchIcon:DisplayObject;
	private function get_branchIcon():DisplayObject { return this._branchIcon; }
	private function set_branchIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("branchIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._branchIcon == value)
		{
			return value;
		}
		if (this._branchIcon != null &&
			this._currentBranchOrLeafIcon == this._branchIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentBranchOrLeafIcon(this._branchIcon);
			this._currentBranchOrLeafIcon = null;
		}
		this._branchIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._branchIcon;
	}
	
	/**
	 * @private
	 */
	public var branchOpenIcon(get, set):DisplayObject;
	private var _branchOpenIcon:DisplayObject;
	private function get_branchOpenIcon():DisplayObject { return this._branchOpenIcon; }
	private function set_branchOpenIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("branchOpenIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._branchOpenIcon == value)
		{
			return value;
		}
		if (this._branchOpenIcon != null &&
			this._currentBranchOrLeafIcon == this._branchOpenIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentBranchOrLeafIcon(this._branchOpenIcon);
			this._currentBranchOrLeafIcon = null;
		}
		this._branchOpenIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._branchOpenIcon;
	}
	
	/**
	 * @private
	 */
	public var branchClosedIcon(get, set):DisplayObject;
	private var _branchClosedIcon:DisplayObject;
	private function get_branchClosedIcon():DisplayObject { return this._branchClosedIcon; }
	private function set_branchClosedIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("branchClosedIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._branchOpenIcon == value)
		{
			return value;
		}
		if (this._branchClosedIcon != null &&
			this._currentBranchOrLeafIcon == this._branchClosedIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentBranchOrLeafIcon(this._branchClosedIcon);
			this._currentBranchOrLeafIcon = null;
		}
		this._branchClosedIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._branchClosedIcon;
	}
	
	/**
	 * @private
	 */
	public var leafIcon(get, set):DisplayObject;
	private var _leafIcon:DisplayObject;
	private function get_leafIcon():DisplayObject { return this._leafIcon; }
	private function set_leafIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("leafIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._leafIcon == value)
		{
			return value;
		}
		if (this._leafIcon != null &&
			this._currentBranchOrLeafIcon == this._leafIcon)
		{
			//if this icon needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentBranchOrLeafIcon(this._leafIcon);
			this._currentBranchOrLeafIcon = null;
		}
		this._leafIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._leafIcon;
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return DefaultTreeItemRenderer.globalStyleProvider;
	}
	
	/**
	 * @inheritDoc
	 */
	public var owner(get, set):Tree;
	private function get_owner():Tree { return cast this._owner; }
	private function set_owner(value:Tree):Tree
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
			var list:Tree = cast this._owner;
			this.isSelectableWithoutToggle = list.isSelectable;
			this._owner.addEventListener(FeathersEventType.SCROLL_START, owner_scrollStartHandler);
			this._owner.addEventListener(FeathersEventType.SCROLL_COMPLETE, owner_scrollCompleteHandler);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var location(get, set):Array<Int>;
	private var _location:Array<Int>;
	private function get_location():Array<Int> { return this._location; }
	private function set_location(value:Array<Int>):Array<Int>
	{
		if (this._location == value)
		{
			return value;
		}
		this._location = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._location;
	}
	
	/**
	 * @inheritDoc
	 */
	public var layoutIndex(get, set):Int;
	private var _layoutIndex:Int = -1;
	private function get_layoutIndex():Int { return this._layoutIndex; }
	private function set_layoutIndex(value:Int):Int
	{
		return this._layoutIndex = value;
	}
	
	/**
	 * @private
	 */
	public var indentation(get, set):Float;
	private var _indentation:Float = 10;
	private function get_indentation():Float { return this._indentation; }
	private function set_indentation(value:Float):Float
	{
		if (this.processStyleRestriction("indentation"))
		{
			return value;
		}
		if (this._indentation == value)
		{
			return value;
		}
		this._indentation = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._indentation;
	}
	
	/**
	 * @private
	 */
	public var disclosureGap(get, set):Float;
	private var _disclosureGap:Float = Math.NaN;
	private function get_disclosureGap():Float { return this._disclosureGap; }
	private function set_disclosureGap(value:Float):Float
	{
		if (this.processStyleRestriction("disclosureGap"))
		{
			return value;
		}
		if (this._disclosureGap == value)
		{
			return value;
		}
		this._disclosureGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._disclosureGap;
	}
	
	/**
	 * @private
	 */
	public var isOpen(get, set):Bool;
	private var _isOpen:Bool = false;
	private function get_isOpen():Bool { return this._isOpen; }
	private function set_isOpen(value:Bool):Bool
	{
		if (this._isOpen == value)
		{
			return value;
		}
		this._isOpen = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._isOpen;
	}
	
	/**
	 * @private
	 */
	public var isBranch(get, set):Bool;
	private var _isBranch:Bool = false;
	private function get_isBranch():Bool { return this._isBranch; }
	private function set_isBranch(value:Bool):Bool
	{
		if (this._isBranch == value)
		{
			return value;
		}
		this._isBranch = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._isBranch;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//we don't dispose it if the item renderer is the parent because
		//it'll already get disposed in super.dispose()
		if (this._disclosureIcon != null && this._disclosureIcon.parent != this)
		{
			this._disclosureIcon.dispose();
		}
		if (this._disclosureOpenIcon != null && this._disclosureOpenIcon.parent != this)
		{
			this._disclosureOpenIcon.dispose();
		}
		if (this._disclosureClosedIcon != null && this._disclosureClosedIcon.parent != this)
		{
			this._disclosureClosedIcon.dispose();
		}
		if (this._branchIcon != null && this._branchIcon.parent != this)
		{
			this._branchIcon.dispose();
		}
		if (this._branchOpenIcon != null && this._branchOpenIcon.parent != this)
		{
			this._branchOpenIcon.dispose();
		}
		if (this._branchClosedIcon != null && this._branchClosedIcon.parent != this)
		{
			this._branchClosedIcon.dispose();
		}
		if (this._leafIcon != null && this._leafIcon.parent != this)
		{
			this._leafIcon.dispose();
		}
		this.owner = null;
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		if (dataInvalid || stateInvalid || stylesInvalid)
		{
			this.refreshDisclosureIcon();
			this.refreshBranchOrLeafIcon();
		}
		super.draw();
	}
	
	/**
	 * @private
	 */
	override function refreshOffsets():Void
	{
		super.refreshOffsets();
		if (this._location != null)
		{
			//if the data provider is empty, but the tree has a typicalItem,
			//the location will be null
			this._leftOffset += this._indentation * (this._location.length - 1);
		}
		var disclosureGap:Float = this._gap;
		if (this._disclosureGap == this._disclosureGap) //!isNaN
		{
			disclosureGap = this._disclosureGap;
		}
		var oldIgnoreIconResizes:Bool;
		if (this._currentDisclosureIcon != null)
		{
			oldIgnoreIconResizes = this._ignoreDisclosureIconResizes;
			this._ignoreDisclosureIconResizes = true;
			if (Std.isOfType(this._currentDisclosureIcon, IValidating))
			{
				cast(this._currentDisclosureIcon, IValidating).validate();
			}
			this._ignoreDisclosureIconResizes = oldIgnoreIconResizes;
			this._leftOffset += this._currentDisclosureIcon.width + disclosureGap;
			if (this._isBranch)
			{
				this._currentDisclosureIcon.visible = true;
			}
			else
			{
				this._currentDisclosureIcon.visible = false;
			}
		}
		if (this._currentBranchOrLeafIcon != null)
		{
			oldIgnoreIconResizes = this._ignoreBranchOrLeafIconResizes;
			this._ignoreBranchOrLeafIconResizes = true;
			if (Std.isOfType(this._currentBranchOrLeafIcon, IValidating))
			{
				cast(this._currentBranchOrLeafIcon, IValidating).validate();
			}
			this._ignoreBranchOrLeafIconResizes = oldIgnoreIconResizes;
			this._leftOffset += this._currentBranchOrLeafIcon.width + disclosureGap;
		}
	}
	
	/**
	 * @private
	 */
	override function layoutContent():Void
	{
		super.layoutContent();
		var indent:Float = this._paddingLeft;
		if (this._location != null)
		{
			indent += this._indentation * (this._location.length - 1);
		}
		var oldIgnoreIconResizes:Bool;
		if (this._currentDisclosureIcon != null)
		{
			oldIgnoreIconResizes = this._ignoreDisclosureIconResizes;
			this._ignoreDisclosureIconResizes = true;
			if (Std.isOfType(this._currentDisclosureIcon, IValidating))
			{
				cast(this._currentDisclosureIcon, IValidating).validate();
			}
			this._ignoreDisclosureIconResizes = oldIgnoreIconResizes;
			this._currentDisclosureIcon.x = indent;
			this._currentDisclosureIcon.y = this._paddingTop + ((this.actualHeight - this._paddingTop - this._paddingBottom) - this._currentDisclosureIcon.height) / 2;
			indent += this._currentDisclosureIcon.width + this._gap;
		}
		if (this._currentBranchOrLeafIcon != null)
		{
			oldIgnoreIconResizes = this._ignoreBranchOrLeafIconResizes;
			this._ignoreBranchOrLeafIconResizes = true;
			if (Std.isOfType(this._currentBranchOrLeafIcon, IValidating))
			{
				cast(this._currentBranchOrLeafIcon, IValidating).validate();
			}
			this._ignoreBranchOrLeafIconResizes = oldIgnoreIconResizes;
			this._currentBranchOrLeafIcon.x = indent;
			this._currentBranchOrLeafIcon.y = this._paddingTop + ((this.actualHeight - this._paddingTop - this._paddingBottom) - this._currentBranchOrLeafIcon.height) / 2;
		}
	}
	
	/**
	 * @private
	 */
	override function hitTestWithAccessory(localPosition:Point):Bool
	{
		if (this._currentDisclosureIcon != null)
		{
			if (Std.isOfType(this._currentDisclosureIcon, DisplayObjectContainer))
			{
				var container:DisplayObjectContainer = cast this._currentDisclosureIcon;
				if (container.contains(this.hitTest(localPosition)))
				{
					return false;
				}
			}
			if (this.hitTest(localPosition) == this._currentDisclosureIcon)
			{
				return false;
			}
		}
		return super.hitTestWithAccessory(localPosition);
	}
	
	/**
	 * @private
	 */
	private function getCurrentDisclosureIcon():DisplayObject
	{
		var newIcon:DisplayObject = this._disclosureIcon;
		if (this._isOpen && this._disclosureOpenIcon != null)
		{
			newIcon = this._disclosureOpenIcon;
		}
		else if (!this._isOpen && this._disclosureClosedIcon != null)
		{
			newIcon = this._disclosureClosedIcon;
		}
		return newIcon;
	}
	
	/**
	 * @private
	 */
	private function getCurrentBranchOrLeafIcon():DisplayObject
	{
		var newIcon:DisplayObject = this._leafIcon;
		if (this._isBranch)
		{
			newIcon = this._branchIcon;
			if (this._isOpen && this._branchOpenIcon != null)
			{
				newIcon = this._branchOpenIcon;
			}
			else if (!this._isOpen && this._branchClosedIcon != null)
			{
				newIcon = this._branchClosedIcon;
			}
		}
		return newIcon;
	}
	
	/**
	 * @private
	 */
	private function removeCurrentDisclosureIcon(icon:DisplayObject):Void
	{
		if (icon == null)
		{
			return;
		}
		if (Std.isOfType(icon, IFeathersControl))
		{
			cast(icon, IFeathersControl).removeEventListener(FeathersEventType.RESIZE, currentDisclosureIcon_resizeHandler);
		}
		icon.removeEventListener(Event.TRIGGERED, disclosureIcon_triggeredHandler);
		if (Std.isOfType(icon, IStateObserver))
		{
			cast(icon, IStateObserver).stateContext = null;
		}
		if (icon.parent == this)
		{
			this.removeChild(icon, false);
		}
	}
	
	/**
	 * @private
	 */
	private function removeCurrentBranchOrLeafIcon(icon:DisplayObject):Void
	{
		if (icon == null)
		{
			return;
		}
		if (Std.isOfType(icon, IFeathersControl))
		{
			cast(icon, IFeathersControl).removeEventListener(FeathersEventType.RESIZE, currentBranchOrLeafIcon_resizeHandler);
		}
		if (Std.isOfType(icon, IStateObserver))
		{
			cast(icon, IStateObserver).stateContext = null;
		}
		if (icon.parent == this)
		{
			this.removeChild(icon, false);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshDisclosureIcon():Void
	{
		var oldIcon:DisplayObject = this._currentDisclosureIcon;
		this._currentDisclosureIcon = this.getCurrentDisclosureIcon();
		if (Std.isOfType(this._currentDisclosureIcon, IFeathersControl))
		{
			cast(this._currentDisclosureIcon, IFeathersControl).isEnabled = this._isEnabled;
		}
		if (this._currentDisclosureIcon != oldIcon)
		{
			if (oldIcon != null)
			{
				this.removeCurrentDisclosureIcon(oldIcon);
			}
			if (this._currentDisclosureIcon != null)
			{
				if (Std.isOfType(this._currentDisclosureIcon, IStateObserver))
				{
					cast(this._currentDisclosureIcon, IStateObserver).stateContext = this;
				}
				this.addChild(this._currentDisclosureIcon);
				if (!Std.isOfType(this._currentDisclosureIcon, BasicButton))
				{
					if (this._disclosureIconTapToTrigger != null)
					{
						this._disclosureIconTapToTrigger.target = this._currentDisclosureIcon;
					}
					else
					{
						this._disclosureIconTapToTrigger = new TapToTrigger(this._currentDisclosureIcon);
					}
				}
				this._currentDisclosureIcon.addEventListener(Event.TRIGGERED, disclosureIcon_triggeredHandler);
				if (Std.isOfType(this._currentDisclosureIcon, IFeathersControl))
				{
					cast(this._currentDisclosureIcon, IFeathersControl).addEventListener(FeathersEventType.RESIZE, currentDisclosureIcon_resizeHandler);
				}
			}
			else
			{
				this._disclosureIconTapToTrigger = null;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshBranchOrLeafIcon():Void
	{
		var oldIcon:DisplayObject = this._currentBranchOrLeafIcon;
		this._currentBranchOrLeafIcon = this.getCurrentBranchOrLeafIcon();
		if (Std.isOfType(this._currentBranchOrLeafIcon, IFeathersControl))
		{
			cast(this._currentBranchOrLeafIcon, IFeathersControl).isEnabled = this._isEnabled;
		}
		if (this._currentBranchOrLeafIcon != oldIcon)
		{
			if (oldIcon != null)
			{
				this.removeCurrentBranchOrLeafIcon(oldIcon);
			}
			if (this._currentBranchOrLeafIcon != null)
			{
				if (Std.isOfType(this._currentBranchOrLeafIcon, IStateObserver))
				{
					cast(this._currentBranchOrLeafIcon, IStateObserver).stateContext = this;
				}
				this.addChild(this._currentBranchOrLeafIcon);
				if (Std.isOfType(this._currentBranchOrLeafIcon, IFeathersControl))
				{
					cast(this._currentBranchOrLeafIcon, IFeathersControl).addEventListener(FeathersEventType.RESIZE, currentBranchOrLeafIcon_resizeHandler);
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function disclosureIcon_triggeredHandler(event:Event):Void
	{
		this.owner.toggleBranch(this._data, !this._isOpen);
	}
	
	/**
	 * @private
	 */
	private function treeItemRenderer_triggeredHandler(event:Event):Void
	{
		if ((this._currentDisclosureIcon != null && !this._isQuickHitAreaEnabled) || !this._isBranch)
		{
			return;
		}
		//if there is no disclosure icon, then the branch is toggled simply
		//by triggering it with a click/tap
		this.owner.toggleBranch(this._data, !this._isOpen);
	}
	
	/**
	 * @private
	 */
	private function currentDisclosureIcon_resizeHandler():Void
	{
		if (this._ignoreDisclosureIconResizes)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function currentBranchOrLeafIcon_resizeHandler():Void
	{
		if (this._ignoreBranchOrLeafIconResizes)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
}