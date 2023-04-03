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
import feathers.core.ITextRenderer;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.LayoutBoundsResult;
import feathers.layout.VerticalAlign;
import feathers.layout.ViewPortBounds;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import feathers.text.FontStylesSet;
import feathers.utils.display.ScreenDensityScaleCalculator;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.type.SafeCast;
import openfl.display.Stage;
import openfl.display.StageDisplayState;
import openfl.events.FullScreenEvent;
import openfl.geom.Point;
import openfl.system.Capabilities;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.text.TextFormat;
import starling.utils.Pool;

/**
 * A header that displays an optional title along with a horizontal regions
 * on the sides for additional UI controls. The left side is typically for
 * navigation (to display a back button, for example) and the right for
 * additional actions. The title is displayed in the center by default,
 * but it may be aligned to the left or right if there are no items on the
 * desired side.
 *
 * <p>In the following example, a header is created, given a title, and a
 * back button:</p>
 *
 * <listing version="3.0">
 * var header:Header = new Header();
 * header.title = "I'm a header";
 * 
 * var backButton:Button = new Button();
 * backButton.label = "Back";
 * backButton.styleNameList.add( Button.ALTERNATE_STYLE_NAME_BACK_BUTTON );
 * backButton.addEventListener( Event.TRIGGERED, backButton_triggeredHandler );
 * header.leftItems = new &lt;DisplayObject&gt;[ backButton ];
 * 
 * this.addChild( header );</listing>
 *
 * @see ../../../help/header.html How to use the Feathers Header component
 *
 * @productversion Feathers 1.0.0
 */
class Header extends FeathersControl 
{
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_LEFT_CONTENT:String = "leftContent";
	
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_RIGHT_CONTENT:String = "rightContent";
	
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_CENTER_CONTENT:String = "centerContent";
	
	/**
	 * @private
	 */
	private static inline var IOS_STATUS_BAR_HEIGHT:Float = 20;
	
	/**
	 * @private
	 */
	private static inline var IOS_NOTCH_STATUS_BAR_HEIGHT:Float = 44;
	
	/**
	 * @private
	 */
	private static var iOSStatusBarScaledHeight:Float;
	
	/**
	 * @private
	 */
	private static inline var IOS_NAME_PREFIX:String = "iOS ";
	
	/**
	 * @private
	 */
	private static inline var OLD_IOS_NAME_PREFIX:String = "iPhone OS ";
	
	/**
	 * @private
	 */
	private static inline var STATUS_BAR_MIN_IOS_VERSION:Int = 7;
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>Header</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * The default value added to the <code>styleNameList</code> of the header's
	 * items.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ITEM:String = "feathers-header-item";
	
	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * header's title text renderer.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_TITLE:String = "feathers-header-title";
	
	/**
	 * @private
	 */
	private static var HELPER_BOUNDS:ViewPortBounds = new ViewPortBounds();
	
	/**
	 * @private
	 */
	private static var HELPER_LAYOUT_RESULT:LayoutBoundsResult = new LayoutBoundsResult();
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		if (this._fontStylesSet == null)
		{
			this._fontStylesSet = new FontStylesSet();
			this._fontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
		this.addEventListener(Event.ADDED_TO_STAGE, header_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, header_removedFromStageHandler);
	}
	
	/**
	 * The text renderer for the header's title.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #title
	 * @see #titleFactory
	 * @see #createTitle()
	 */
	private var titleTextRenderer:ITextRenderer;
	
	/**
	 * The value added to the <code>styleNameList</code> of the header's
	 * title text renderer. This variable is <code>protected</code> so that
	 * sub-classes can customize the title text renderer style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_TITLE</code>.
	 *
	 * <p>To customize the title text renderer style name without
	 * subclassing, see <code>customTitleStyleName</code>.</p>
	 *
	 * @see #style:customTitleStyleName
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var titleStyleName:String = DEFAULT_CHILD_STYLE_NAME_TITLE;
	
	/**
	 * The value added to the <code>styleNameList</code> of each of the
	 * header's items. This variable is <code>protected</code> so that
	 * sub-classes can customize the item style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_ITEM</code>.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var itemStyleName:String = DEFAULT_CHILD_STYLE_NAME_ITEM;
	
	/**
	 * @private
	 */
	private var leftItemsWidth:Float = 0;

	/**
	 * @private
	 */
	private var rightItemsWidth:Float = 0;
	
	/**
	 * @private
	 * The layout algorithm. Shared by both sides.
	 */
	private var _layout:HorizontalLayout;
	
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return Header.globalStyleProvider;
	}
	
	/**
	 * The text displayed for the header's title.
	 *
	 * <p>In the following example, the header's title is set:</p>
	 *
	 * <listing version="3.0">
	 * header.title = "I'm a Header";</listing>
	 *
	 * @default ""
	 *
	 * @see #titleFactory
	 */
	public var title(get, set):String;
	private var _title:String = null;
	private function get_title():String { return this._title; }
	private function set_title(value:String):String
	{
		if (this._title == value)
		{
			return value;
		}
		this._title = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._title;
	}
	
	/**
	 * A function used to instantiate the header's title text renderer
	 * sub-component. By default, the header will use the global text
	 * renderer factory, <code>FeathersControl.defaultTextRendererFactory()</code>,
	 * to create the title text renderer. The title text renderer must be an
	 * instance of <code>ITextRenderer</code>. This factory can be used to
	 * change properties on the title text renderer when it is first
	 * created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to style the title text
	 * renderer.
	 *
	 * <p>If you are not using a theme, the title factory can be used to
	 * provide skin the title with appropriate text styles.</p>
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, a custom title factory is passed to the
	 * header:</p>
	 *
	 * <listing version="3.0">
	 * header.titleFactory = function():ITextRenderer
	 * {
	 *     var titleRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
	 *     titleRenderer.textFormat = new TextFormat( "_sans", 12, 0xff0000 );
	 *     return titleRenderer;
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see #title
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var titleFactory(get, set):Void->ITextRenderer;
	private var _titleFactory:Void->ITextRenderer;
	private function get_titleFactory():Void->ITextRenderer { return this._titleFactory; }
	private function set_titleFactory(value:Void->ITextRenderer):Void->ITextRenderer
	{
		if (this._titleFactory == value)
		{
			return value;
		}
		this._titleFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._titleFactory;
	}
	
	/**
	 * Determines if the <code>leftItems</code>, <code>centerItems</code>,
	 * and <code>rightItems</code> are disposed or not when the header is
	 * disposed.
	 *
	 * <p>If you change this value to <code>false</code>, you must dispose
	 * the items manually. Failing to dispose the items may result in a
	 * memory leak.</p>
	 *
	 * @default true
	 */
	public var disposeItems(get, set):Bool;
	private var _disposeItems:Bool = true;
	private function get_disposeItems():Bool { return this._disposeItems; }
	private function set_disposeItems(value:Bool):Bool
	{
		return this._disposeItems = value;
	}
	
	/**
	 * @private
	 */
	private var _ignoreItemResizing:Bool = false;
	
	/**
	 * The UI controls that appear in the left region of the header.
	 *
	 * <p>If <code>leftItems</code> is not empty, and
	 * <code>titleAlign</code> is <code>HorizontalAlign.LEFT</code>, the
	 * title text renderer will appear to the right of the left items.</p>
	 *
	 * <p>In the following example, a back button is displayed on the left
	 * side of the header:</p>
	 *
	 * <listing version="3.0">
	 * var backButton:Button = new Button();
	 * backButton.label = "Back";
	 * backButton.styleNameList.add( Button.ALTERNATE_STYLE_NAME_BACK_BUTTON );
	 * backButton.addEventListener( Event.TRIGGERED, backButton_triggeredHandler );
	 * header.leftItems = new &lt;DisplayObject&gt;[ backButton ];</listing>
	 *
	 * @default null
	 */
	public var leftItems(get, set):Array<DisplayObject>;
	private var _leftItems:Array<DisplayObject>;
	private function get_leftItems():Array<DisplayObject> { return this._leftItems; }
	private function set_leftItems(value:Array<DisplayObject>):Array<DisplayObject>
	{
		if (this._leftItems == value)
		{
			return value;
		}
		if (this._leftItems != null)
		{
			for (item in this._leftItems)
			{
				if (Std.isOfType(item, IFeathersControl))
				{
					cast(item, IFeathersControl).styleNameList.remove(this.itemStyleName);
					item.removeEventListener(FeathersEventType.RESIZE, item_resizeHandler);
				}
				item.removeFromParent();
			}
		}
		this._leftItems = value;
		if (this._leftItems != null)
		{
			for (item in this._leftItems)
			{
				if (Std.isOfType(item, IFeathersControl))
				{
					item.addEventListener(FeathersEventType.RESIZE, item_resizeHandler);
				}
			}
		}
		this.invalidate(INVALIDATION_FLAG_LEFT_CONTENT);
		return this._leftItems;
	}
	
	/**
	 * The UI controls that appear in the center region of the header. If
	 * <code>centerItems</code> is not empty, and <code>titleAlign</code>
	 * is <code>HorizontalAlign.CENTER</code>, the title text renderer will
	 * be hidden.
	 *
	 * <p>In the following example, a settings button is displayed in the
	 * center of the header:</p>
	 *
	 * <listing version="3.0">
	 * var settingsButton:Button = new Button();
	 * settingsButton.label = "Settings";
	 * settingsButton.addEventListener( Event.TRIGGERED, settingsButton_triggeredHandler );
	 * header.centerItems = new &lt;DisplayObject&gt;[ settingsButton ];</listing>
	 *
	 * @default null
	 */
	public var centerItems(get, set):Array<DisplayObject>;
	private var _centerItems:Array<DisplayObject>;
	private function get_centerItems():Array<DisplayObject> { return this._centerItems; }
	private function set_centerItems(value:Array<DisplayObject>):Array<DisplayObject>
	{
		if (this._centerItems == value)
		{
			return value;
		}
		if (this._centerItems != null)
		{
			for (item in this._centerItems)
			{
				if (Std.isOfType(item, IFeathersControl))
				{
					cast(item, IFeathersControl).styleNameList.remove(this.itemStyleName);
					item.removeEventListener(FeathersEventType.RESIZE, item_resizeHandler);
				}
				item.removeFromParent();
			}
		}
		this._centerItems = value;
		if (this._centerItems != null)
		{
			for (item in this._centerItems)
			{
				if (Std.isOfType(item, IFeathersControl))
				{
					item.addEventListener(FeathersEventType.RESIZE, item_resizeHandler);
				}
			}
		}
		this.invalidate(INVALIDATION_FLAG_CENTER_CONTENT);
		return this._centerItems;
	}
	
	/**
	 * The UI controls that appear in the right region of the header.
	 *
	 * <p>If <code>rightItems</code> is not empty, and
	 * <code>titleAlign</code> is <code>HorizontalAlign.RIGHT</code>, the
	 * title text renderer will appear to the left of the right items.</p>
	 *
	 * <p>In the following example, a settings button is displayed on the
	 * right side of the header:</p>
	 *
	 * <listing version="3.0">
	 * var settingsButton:Button = new Button();
	 * settingsButton.label = "Settings";
	 * settingsButton.addEventListener( Event.TRIGGERED, settingsButton_triggeredHandler );
	 * header.rightItems = new &lt;DisplayObject&gt;[ settingsButton ];</listing>
	 *
	 * @default null
	 */
	public var rightItems(get, set):Array<DisplayObject>;
	private var _rightItems:Array<DisplayObject>;
	private function get_rightItems():Array<DisplayObject> { return this._rightItems; }
	private function set_rightItems(value:Array<DisplayObject>):Array<DisplayObject>
	{
		if (this._rightItems == value)
		{
			return value;
		}
		if (this._rightItems != null)
		{
			for (item in this._rightItems)
			{
				if (Std.isOfType(item, IFeathersControl))
				{
					cast(item, IFeathersControl).styleNameList.remove(this.itemStyleName);
					item.removeEventListener(FeathersEventType.RESIZE, item_resizeHandler);
				}
				item.removeFromParent();
			}
		}
		this._rightItems = value;
		if (this._rightItems != null)
		{
			for (item in this._rightItems)
			{
				if (Std.isOfType(item, IFeathersControl))
				{
					item.addEventListener(FeathersEventType.RESIZE, item_resizeHandler);
				}
			}
		}
		this.invalidate(INVALIDATION_FLAG_RIGHT_CONTENT);
		return this._rightItems;
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
	public var gap(get, set):Float;
	private var _gap:Float = 0;
	private function get_gap():Float { return this._gap; }
	private function set_gap(value:Float):Float
	{
		if (this.processStyleRestriction("gap"))
		{
			return value;
		}
		if (this._gap == value)
		{
			return value;
		}
		this._gap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._gap;
	}
	
	/**
	 * @private
	 */
	public var titleGap(get, set):Float;
	private var _titleGap:Float = Math.NaN;
	private function get_titleGap():Float { return this._titleGap; }
	private function set_titleGap(value:Float):Float
	{
		if (this.processStyleRestriction("titleGap"))
		{
			return value;
		}
		if (this._titleGap == value)
		{
			return value;
		}
		this._titleGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._titleGap;
	}
	
	/**
	 * @private
	 */
	public var useExtraPaddingForOSStatusBar(get, set):Bool;
	private var _useExtraPaddingForOSStatusBar:Bool = false;
	private function get_useExtraPaddingForOSStatusBar():Bool { return this._useExtraPaddingForOSStatusBar; }
	private function set_useExtraPaddingForOSStatusBar(value:Bool):Bool
	{
		if (this.processStyleRestriction("useExtraPaddingForOSStatusBar"))
		{
			return value;
		}
		if (this._useExtraPaddingForOSStatusBar == value)
		{
			return value;
		}
		this._useExtraPaddingForOSStatusBar = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._useExtraPaddingForOSStatusBar;
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._verticalAlign;
	}
	
	/**
	 * @private
	 */
	private var currentBackgroundSkin:DisplayObject;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundHeight:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundMinWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundMinHeight:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundMaxWidth:Float;
	
	/**
	 * @private
	 */
	private var _explicitBackgroundMaxHeight:Float;
	
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
		if (this._backgroundSkin != null &&
			this.currentBackgroundSkin == this._backgroundSkin)
		{
			this.removeCurrentBackgroundSkin(this._backgroundSkin);
			this.currentBackgroundSkin = null;
		}
		this._backgroundSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._backgroundSkin;
	}
	
	/**
	 * @private
	 */
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._backgroundDisabledSkin;
	}
	
	/**
	 * @private
	 */
	private var _fontStylesSet:FontStylesSet;
	
	/**
	 * @private
	 */
	public var fontStyles(get, set):TextFormat;
	private function get_fontStyles():TextFormat { return this._fontStylesSet.format; }
	private function set_fontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("fontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("fontStyles");
		}
		
		var oldValue:TextFormat = this._fontStylesSet.format;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._fontStylesSet.format = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var disabledFontStyles(get, set):TextFormat;
	private function get_disabledFontStyles():TextFormat { return this._fontStylesSet.disabledFormat; }
	private function set_disabledFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("disabledFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("disabledFontStyles");
		}
		
		var oldValue:TextFormat = this._fontStylesSet.disabledFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._fontStylesSet.disabledFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var wordWrap(get, set):Bool;
	private var _wordWrap:Bool = false;
	private function get_wordWrap():Bool { return this._wordWrap; }
	private function set_wordWrap(value:Bool):Bool
	{
		if (this.processStyleRestriction("wordWrap"))
		{
			return value;
		}
		if (this._wordWrap == value)
		{
			return value;
		}
		this._wordWrap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return value;
	}
	
	/**
	 * @private
	 */
	public var customTitleStyleName(get, set):String;
	private var _customTitleStyleName:String;
	private function get_customTitleStyleName():String { return this._customTitleStyleName; }
	private function set_customTitleStyleName(value:String):String
	{
		if (this.processStyleRestriction("customTitleStyleName"))
		{
			return value;
		}
		if (this._customTitleStyleName == value)
		{
			return value;
		}
		this._customTitleStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customTitleStyleName;
	}
	
	/**
	 * An object that stores properties for the header's title text renderer
	 * sub-component, and the properties will be passed down to the text
	 * renderer when the header validates. The available properties
	 * depend on which <code>ITextRenderer</code> implementation is returned
	 * by <code>textRendererFactory</code>. Refer to
	 * <a href="../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.
	 *
	 * <p>In the following example, some properties are set for the header's
	 * title text renderer (this example assumes that the title text renderer
	 * is a <code>BitmapFontTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * header.titleProperties.textFormat = new BitmapFontTextFormat( bitmapFont );
	 * header.titleProperties.wordWrap = true;</listing>
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>titleFactory</code> function instead
	 * of using <code>titleProperties</code> will result in better
	 * performance.</p>
	 *
	 * @default null
	 *
	 * @see #titleFactory
	 * @see feathers.core.ITextRenderer
	 */
	public var titleProperties(get, set):PropertyProxy;
	private var _titleProperties:PropertyProxy;
	private function get_titleProperties():PropertyProxy
	{
		if (this._titleProperties == null)
		{
			this._titleProperties = new PropertyProxy(titleProperties_onChange);
		}
		return this._titleProperties;
	}
	
	private function set_titleProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._titleProperties == value)
		{
			return value;
		}
		if (this._titleProperties != null)
		{
			this._titleProperties.dispose();
		}
		this._titleProperties = value;
		if (this._titleProperties != null)
		{
			this._titleProperties.addOnChangeCallback(titleProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._titleProperties;
	}
	
	/**
	 * @private
	 */
	public var titleAlign(get, set):String;
	private var _titleAlign:String = HorizontalAlign.CENTER;
	private function get_titleAlign():String { return this._titleAlign; }
	private function set_titleAlign(value:String):String
	{
		if (value == "preferLeft")
		{
			value = HorizontalAlign.LEFT;
		}
		else if (value == "preferRight")
		{
			value = HorizontalAlign.RIGHT;
		}
		if (this.processStyleRestriction("titleAlign"))
		{
			return value;
		}
		if (this._titleAlign == value)
		{
			return value;
		}
		this._titleAlign = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._titleAlign;
	}
	
	/**
	 * The number of text lines displayed by the header. The component may
	 * contain multiple text lines if the text contains line breaks or if
	 * the <code>wordWrap</code> property is enabled.
	 *
	 * @see #wordWrap
	 */
	public var numLines(get, never):Int;
	private function get_numLines():Int
	{
		if (this.titleTextRenderer == null)
		{
			return 0;
		}
		return this.titleTextRenderer.numLines;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//we don't dispose it if the header is the parent because it'll
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
		if (this._disposeItems)
		{
			if (this._leftItems != null)
			{
				for (item in this._leftItems)
				{
					item.dispose();
				}
			}
			if (this._centerItems != null)
			{
				for (item in this._centerItems)
				{
					item.dispose();
				}
			}
			if (this._rightItems != null)
			{
				for (item in this._rightItems)
				{
					item.dispose();
				}
			}
		}
		this.leftItems = null;
		this.rightItems = null;
		this.centerItems = null;
		if (this._fontStylesSet != null)
		{
			this._fontStylesSet.dispose();
			this._fontStylesSet = null;
		}
		if (this._titleProperties != null)
		{
			this._titleProperties.dispose();
			this._titleProperties = null;
		}
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		if (this._layout == null)
		{
			var layout:HorizontalLayout = new HorizontalLayout();
			layout.useVirtualLayout = false;
			layout.verticalAlign = VerticalAlign.MIDDLE;
			this._layout = layout;
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var leftContentInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_LEFT_CONTENT);
		var rightContentInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_RIGHT_CONTENT);
		var centerContentInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_CENTER_CONTENT);
		var textRendererInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		
		if (textRendererInvalid)
		{
			this.createTitle();
		}
		
		if (textRendererInvalid || dataInvalid)
		{
			this.titleTextRenderer.text = this._title;
		}
		
		if (stateInvalid || stylesInvalid)
		{
			this.refreshBackground();
		}
		
		if (textRendererInvalid || stylesInvalid || sizeInvalid)
		{
			this.refreshLayout();
		}
		if (textRendererInvalid || stylesInvalid)
		{
			this.refreshTitleStyles();
		}
		
		var oldIgnoreItemResizing:Bool = this._ignoreItemResizing;
		this._ignoreItemResizing = true;
		if (leftContentInvalid)
		{
			if (this._leftItems != null)
			{
				for (item in this._leftItems)
				{
					if (Std.isOfType(item, IFeathersControl))
					{
						cast(item, IFeathersControl).styleNameList.add(this.itemStyleName);
					}
					this.addChild(item);
				}
			}
		}
		
		if (rightContentInvalid)
		{
			if (this._rightItems != null)
			{
				for (item in this._rightItems)
				{
					if (Std.isOfType(item, IFeathersControl))
					{
						cast(item, IFeathersControl).styleNameList.add(this.itemStyleName);
					}
					this.addChild(item);
				}
			}
		}
		
		if (centerContentInvalid)
		{
			if (this._centerItems != null)
			{
				for (item in this._centerItems)
				{
					if (Std.isOfType(item, IFeathersControl))
					{
						cast(item, IFeathersControl).styleNameList.add(this.itemStyleName);
					}
					this.addChild(item);
				}
			}
		}
		this._ignoreItemResizing = oldIgnoreItemResizing;
		
		if (stateInvalid || textRendererInvalid)
		{
			this.refreshEnabled();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layoutBackground();
		
		if (sizeInvalid || leftContentInvalid || rightContentInvalid || centerContentInvalid || stylesInvalid)
		{
			this.leftItemsWidth = 0;
			this.rightItemsWidth = 0;
			if (this._leftItems != null)
			{
				this.layoutLeftItems();
			}
			if (this._rightItems != null)
			{
				this.layoutRightItems();
			}
			if (this._centerItems != null)
			{
				this.layoutCenterItems();
			}
		}
		
		if (textRendererInvalid || sizeInvalid || stylesInvalid || dataInvalid || leftContentInvalid || rightContentInvalid || centerContentInvalid)
		{
			this.layoutTitle();
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
		if (!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return false;
		}
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		var measureSkin:IMeasureDisplayObject = SafeCast.safe_cast(this.currentBackgroundSkin, IMeasureDisplayObject);
		if (Std.isOfType(this.currentBackgroundSkin, IValidating))
		{
			cast(this.currentBackgroundSkin, IValidating).validate();
		}
		
		var extraPaddingTop:Float = this.calculateExtraOSStatusBarPadding();
		
		var totalContentWidth:Float = 0;
		var maxContentHeight:Float = 0;
		var hasLeftItems:Bool = this._leftItems != null && this._leftItems.length != 0;
		var hasRightItems:Bool = this._rightItems != null && this._rightItems.length != 0;
		var hasCenterItems:Bool = this._centerItems != null && this._centerItems.length != 0;
		var oldIgnoreItemResizing:Bool = this._ignoreItemResizing;
		var item:DisplayObject;
		var itemCount:Int;
		var itemWidth:Float;
		var itemHeight:Float;
		this._ignoreItemResizing = true;
		if (hasLeftItems)
		{
			itemCount = this._leftItems.length;
			for (i in 0...itemCount)
			{
				item = this._leftItems[i];
				if (Std.isOfType(item, IValidating))
				{
					cast(item, IValidating).validate();
				}
				itemWidth = item.width;
				if (itemWidth == itemWidth) //!isNaN
				{
					totalContentWidth += itemWidth;
					if (i != 0)
					{
						totalContentWidth += this._gap;
					}
				}
				itemHeight = item.height;
				if (itemHeight == itemHeight && //!isNaN
					itemHeight > maxContentHeight)
				{
					maxContentHeight = itemHeight;
				}
			}
		}
		if (hasCenterItems)
		{
			itemCount = this._centerItems.length;
			for (i in 0...itemCount)
			{
				item = this._centerItems[i];
				if (Std.isOfType(item, IValidating))
				{
					cast(item, IValidating).validate();
				}
				itemWidth = item.width;
				if (itemWidth == itemWidth) //!isNaN
				{
					totalContentWidth += itemWidth;
					if (i != 0)
					{
						totalContentWidth += this._gap;
					}
				}
				itemHeight = item.height;
				if (itemHeight == itemHeight && //!isNaN
					itemHeight > maxContentHeight)
				{
					maxContentHeight = itemHeight;
				}
			}
		}
		if (hasRightItems)
		{
			itemCount = this._rightItems.length;
			for (i in 0...itemCount)
			{
				item = this._rightItems[i];
				if (Std.isOfType(item, IValidating))
				{
					cast(item, IValidating).validate();
				}
				itemWidth = item.width;
				if (itemWidth == itemWidth) //!isNaN
				{
					totalContentWidth += itemWidth;
					if (i != 0)
					{
						totalContentWidth += this._gap;
					}
				}
				itemHeight = item.height;
				if (itemHeight == itemHeight && //!isNaN
					itemHeight > maxContentHeight)
				{
					maxContentHeight = itemHeight;
				}
			}
		}
		this._ignoreItemResizing = oldIgnoreItemResizing;
		
		if (this._titleAlign == HorizontalAlign.CENTER && hasCenterItems)
		{
			if (hasLeftItems)
			{
				totalContentWidth += this._gap;
			}
			if (hasRightItems)
			{
				totalContentWidth += this._gap;
			}
		}
		else if (this._title != null)
		{
			var calculatedTitleGap:Float = this._titleGap;
			if (calculatedTitleGap != calculatedTitleGap) //isNaN
			{
				calculatedTitleGap = this._gap;
			}
			var maxTitleWidth:Float = this._explicitWidth;
			if (needsWidth)
			{
				maxTitleWidth = this._explicitMaxWidth;
			}
			maxTitleWidth -= totalContentWidth;
			if (hasLeftItems)
			{
				maxTitleWidth -= calculatedTitleGap;
			}
			if (hasCenterItems)
			{
				maxTitleWidth -= calculatedTitleGap;
			}
			if (hasRightItems)
			{
				maxTitleWidth -= calculatedTitleGap;
			}
			if (maxTitleWidth < 0)
			{
				maxTitleWidth = 0;
			}
			this.titleTextRenderer.maxWidth = maxTitleWidth;
			var point:Point = Pool.getPoint();
			this.titleTextRenderer.measureText(point);
			var measuredTitleWidth:Float = point.x;
			var measuredTitleHeight:Float = point.y;
			Pool.putPoint(point);
			if (measuredTitleWidth == measuredTitleWidth) //!isNaN
			{
				if (hasLeftItems)
				{
					measuredTitleWidth += calculatedTitleGap;
				}
				if (hasRightItems)
				{
					measuredTitleWidth += calculatedTitleGap;
				}
			}
			else
			{
				measuredTitleWidth = 0;
			}
			totalContentWidth += measuredTitleWidth;
			if (measuredTitleHeight == measuredTitleHeight && //!isNaN
				measuredTitleHeight > maxContentHeight)
			{
				maxContentHeight = measuredTitleHeight;
			}
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			newWidth = totalContentWidth + this._paddingLeft + this._paddingRight;
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.width > newWidth)
			{
				newWidth = this.currentBackgroundSkin.width;
			}
		}
		
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			newHeight = maxContentHeight;
			newHeight += this._paddingTop + this._paddingBottom;
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.height > newHeight)
			{
				newHeight = this.currentBackgroundSkin.height;
			}
			//normally, padding is included before before the background
			//skin's dimensions, but this is special extra padding that
			//should simply be added on top of the normal measurement. if
			//the explicit height of the background is large enough, this
			//extra padding could be swallowed instead.
			if (extraPaddingTop > 0)
			{
				//account for the minimum height before adding the padding
				if (newHeight < this._explicitMinHeight)
				{
					newHeight = this._explicitMinHeight;
				}
				newHeight += extraPaddingTop;
			}
		}
		
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			newMinWidth = totalContentWidth + this._paddingLeft + this._paddingRight;
			if (this.currentBackgroundSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minWidth > newMinWidth)
					{
						newMinWidth = measureSkin.minWidth;
					}
				}
				else if (this._explicitBackgroundMinWidth > newMinWidth)
				{
					newMinWidth = this._explicitBackgroundMinWidth;
				}
			}
		}
		
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			newMinHeight = maxContentHeight;
			newMinHeight += this._paddingTop + this._paddingBottom;
			if (this.currentBackgroundSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minHeight > newMinHeight)
					{
						newMinHeight = measureSkin.minHeight;
					}
				}
				else if (this._explicitBackgroundMinHeight > newMinHeight)
				{
					newMinHeight = this._explicitBackgroundMinHeight;
				}
			}
			//set note above about why the extra padding is included after
			//the background skin
			if (extraPaddingTop > 0)
			{
				newMinHeight += extraPaddingTop;
			}
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * Creates and adds the <code>titleTextRenderer</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #title
	 * @see #titleTextRenderer
	 * @see #titleFactory
	 */
	private function createTitle():Void
	{
		if (this.titleTextRenderer != null)
		{
			this.removeChild(cast this.titleTextRenderer, true);
			this.titleTextRenderer = null;
		}
		
		var factory:Void->ITextRenderer = this._titleFactory != null ? this._titleFactory : FeathersControl.defaultTextRendererFactory;
		this.titleTextRenderer = factory();
		var uiTitleRenderer:IFeathersControl = cast this.titleTextRenderer;
		var titleStyleName:String = this._customTitleStyleName != null ? this._customTitleStyleName : this.titleStyleName;
		uiTitleRenderer.styleNameList.add(titleStyleName);
		this.addChild(cast uiTitleRenderer);
	}
	
	/**
	 * @private
	 */
	private function refreshBackground():Void
	{
		var oldBackgroundSkin:DisplayObject = this.currentBackgroundSkin;
		this.currentBackgroundSkin = this._backgroundSkin;
		if (!this._isEnabled && this._backgroundDisabledSkin != null)
		{
			this.currentBackgroundSkin = this._backgroundDisabledSkin;
		}
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
				this.addChildAt(this.currentBackgroundSkin, 0);
			}
		}
	}
	
	/**
	 * @private
	 */
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
			skin.removeFromParent(false);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshLayout():Void
	{
		this._layout.gap = this._gap;
		this._layout.paddingTop = this._paddingTop + this.calculateExtraOSStatusBarPadding();
		this._layout.paddingBottom = this._paddingBottom;
		this._layout.verticalAlign = this._verticalAlign;
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		this.titleTextRenderer.isEnabled = this._isEnabled;
	}
	
	/**
	 * @private
	 */
	private function refreshTitleStyles():Void
	{
		this.titleTextRenderer.fontStyles = this._fontStylesSet;
		this.titleTextRenderer.wordWrap = this._wordWrap;
		if (this._titleProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._titleProperties)
			{
				propertyValue = this._titleProperties[propertyName];
				//this.titleTextRenderer[propertyName] = propertyValue;
				Reflect.setProperty(this.titleTextRenderer, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function calculateExtraOSStatusBarPadding():Float
	{
		if (!this._useExtraPaddingForOSStatusBar)
		{
			return 0;
		}
		//first, we check if it's iOS or not. at this time, we only need to
		//use extra padding on iOS. android and others are fine.
		var os:String = Capabilities.os;
		if (os.indexOf(IOS_NAME_PREFIX) != -1)
		{
			os = os.substring(IOS_NAME_PREFIX.length, os.indexOf("."));
		}
		else if (os.indexOf(OLD_IOS_NAME_PREFIX) != -1)
		{
			os = os.substring(OLD_IOS_NAME_PREFIX.length, os.indexOf("."));
		}
		else
		{
			return 0;
		}
		//then, we check the major version of iOS. the extra padding is not
		//required before version 7.
		//the version string will always contain major and minor values, so
		//search for the first . character.
		if (Std.parseInt(os) < STATUS_BAR_MIN_IOS_VERSION)
		{
			return 0;
		}
		//next, we check if the app is full screen or not. if it is full
		//screen, then the status bar isn't visible, and we don't need the
		//extra padding.
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var nativeStage:Stage = starling.nativeStage;
		if (nativeStage.displayState != StageDisplayState.NORMAL)
		{
			return 0;
		}
		
		//this value only needs to be calculated once
		if (iOSStatusBarScaledHeight != iOSStatusBarScaledHeight) //isNaN
		{
			//uses the same mechanism as ScreenDensityScaleFactorManager,
			//but uses different density values
			var scaleSelector:ScreenDensityScaleCalculator = new ScreenDensityScaleCalculator();
			scaleSelector.addScaleForDensity(168, 1); //original
			scaleSelector.addScaleForDensity(326, 2); //retina
			scaleSelector.addScaleForDensity(401, 3); //retina HD
			if (this.hasNotch())
			{
				iOSStatusBarScaledHeight = IOS_NOTCH_STATUS_BAR_HEIGHT * scaleSelector.getScale(DeviceCapabilities.dpi);
			}
			else
			{
				iOSStatusBarScaledHeight = IOS_STATUS_BAR_HEIGHT * scaleSelector.getScale(DeviceCapabilities.dpi);
			}
		}
		
		//while it probably won't change, contentScaleFactor shouldn't be
		//considered constant, so do this calculation every time
		return iOSStatusBarScaledHeight / starling.contentScaleFactor;
	}
	
	/**
	 * @private
	 */
	private function hasNotch():Bool
	{
		//this is not an ideal way to detect the status bar height
		//because future devices will need to be added to this list
		//manually!
		var osString:String = Capabilities.os;
		var notchIDs:Array<String> = [
			"iPhone10,3", //iPhone X
			"iPhone10,6", //iPhone X
			"iPhone11,2", //iPhone XS
			"iPhone11,4", //iPhone XS Max
			"iPhone11,6", //iPhone XS Max
			"iPhone11,8", //iPhone XR
		];
		var idCount:Int = notchIDs.length;
		for (i in 0...idCount)
		{
			var id:String = notchIDs[i];
			var index:Int = osString.lastIndexOf(id);
			if (index != -1 && index == osString.length - id.length)
			{
				return true;
			}
		}
		return false;
	}
	
	/**
	 * @private
	 */
	private function layoutBackground():Void
	{
		if (this.currentBackgroundSkin == null)
		{
			return;
		}
		this.currentBackgroundSkin.width = this.actualWidth;
		this.currentBackgroundSkin.height = this.actualHeight;
	}
	
	/**
	 * @private
	 */
	private function layoutLeftItems():Void
	{
		for (item in this._leftItems)
		{
			if (Std.isOfType(item, IValidating))
			{
				cast(item, IValidating).validate();
			}
		}
		HELPER_BOUNDS.x = HELPER_BOUNDS.y = 0;
		HELPER_BOUNDS.scrollX = HELPER_BOUNDS.scrollY = 0;
		HELPER_BOUNDS.explicitWidth = this.actualWidth;
		HELPER_BOUNDS.explicitHeight = this.actualHeight;
		this._layout.horizontalAlign = HorizontalAlign.LEFT;
		this._layout.paddingRight = 0;
		this._layout.paddingLeft = this._paddingLeft;
		this._layout.layout(this._leftItems, HELPER_BOUNDS, HELPER_LAYOUT_RESULT);
		this.leftItemsWidth = HELPER_LAYOUT_RESULT.contentWidth;
		if (this.leftItemsWidth != this.leftItemsWidth) //isNaN
		{
			this.leftItemsWidth = 0;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutRightItems():Void
	{
		for (item in this._rightItems)
		{
			if (Std.isOfType(item, IValidating))
			{
				cast(item, IValidating).validate();
			}
		}
		HELPER_BOUNDS.x = HELPER_BOUNDS.y = 0;
		HELPER_BOUNDS.scrollX = HELPER_BOUNDS.scrollY = 0;
		HELPER_BOUNDS.explicitWidth = this.actualWidth;
		HELPER_BOUNDS.explicitHeight = this.actualHeight;
		this._layout.horizontalAlign = HorizontalAlign.RIGHT;
		this._layout.paddingRight = this._paddingRight;
		this._layout.paddingLeft = 0;
		this._layout.layout(this._rightItems, HELPER_BOUNDS, HELPER_LAYOUT_RESULT);
		this.rightItemsWidth = HELPER_LAYOUT_RESULT.contentWidth;
		if (this.rightItemsWidth != this.rightItemsWidth) //isNaN
		{
			this.rightItemsWidth = 0;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutCenterItems():Void
	{
		for (item in this._centerItems)
		{
			if (Std.isOfType(item, IValidating))
			{
				cast(item, IValidating).validate();
			}
		}
		HELPER_BOUNDS.x = HELPER_BOUNDS.y = 0;
		HELPER_BOUNDS.scrollX = HELPER_BOUNDS.scrollY = 0;
		HELPER_BOUNDS.explicitWidth = this.actualWidth;
		HELPER_BOUNDS.explicitHeight = this.actualHeight;
		this._layout.horizontalAlign = HorizontalAlign.CENTER;
		this._layout.paddingRight = this._paddingRight;
		this._layout.paddingLeft = this._paddingLeft;
		this._layout.layout(this._centerItems, HELPER_BOUNDS, HELPER_LAYOUT_RESULT);
	}
	
	/**
	 * @private
	 */
	private function layoutTitle():Void
	{
		var hasLeftItems:Bool = this._leftItems != null && this._leftItems.length != 0;
		var hasRightItems:Bool = this._rightItems != null && this._rightItems.length != 0;
		var hasCenterItems:Bool = this._centerItems != null && this._centerItems.length != 0;
		if (this._titleAlign == HorizontalAlign.CENTER && hasCenterItems)
		{
			this.titleTextRenderer.visible = false;
			return;
		}
		if (this._titleAlign == HorizontalAlign.LEFT && hasLeftItems && hasCenterItems)
		{
			this.titleTextRenderer.visible = false;
			return;
		}
		if (this._titleAlign == HorizontalAlign.RIGHT && hasRightItems && hasCenterItems)
		{
			this.titleTextRenderer.visible = false;
			return;
		}
		this.titleTextRenderer.visible = true;
		var calculatedTitleGap:Float = this._titleGap;
		if (calculatedTitleGap != calculatedTitleGap) //isNaN
		{
			calculatedTitleGap = this._gap;
		}
		var leftOffset:Float = this._paddingLeft;
		if (hasLeftItems)
		{
			//leftItemsWidth already includes padding
			leftOffset = this.leftItemsWidth + calculatedTitleGap;
		}
		var rightOffset:Float = this._paddingRight;
		if (hasRightItems)
		{
			//rightItemsWidth already includes padding
			rightOffset = this.rightItemsWidth + calculatedTitleGap;
		}
		var titleMaxWidth:Float;
		if (this._titleAlign == HorizontalAlign.LEFT)
		{
			titleMaxWidth = this.actualWidth - leftOffset - rightOffset;
			if (titleMaxWidth < 0)
			{
				titleMaxWidth = 0;
			}
			this.titleTextRenderer.maxWidth = titleMaxWidth;
			this.titleTextRenderer.validate();
			this.titleTextRenderer.x = leftOffset;
		}
		else if (this._titleAlign == HorizontalAlign.RIGHT)
		{
			titleMaxWidth = this.actualWidth - leftOffset - rightOffset;
			if (titleMaxWidth < 0)
			{
				titleMaxWidth = 0;
			}
			this.titleTextRenderer.maxWidth = titleMaxWidth;
			this.titleTextRenderer.validate();
			this.titleTextRenderer.x = this.actualWidth - this.titleTextRenderer.width - rightOffset;
		}
		else //center
		{
			var actualWidthMinusPadding:Float = this.actualWidth - this._paddingLeft - this._paddingRight;
			if (actualWidthMinusPadding < 0)
			{
				actualWidthMinusPadding = 0;
			}
			var actualWidthMinusOffsets:Float = this.actualWidth - leftOffset - rightOffset;
			if (actualWidthMinusOffsets < 0)
			{
				actualWidthMinusOffsets = 0;
			}
			this.titleTextRenderer.maxWidth = actualWidthMinusOffsets;
			this.titleTextRenderer.validate();
			//we try to keep the title centered between the paddings, if
			//possible. however, if the combined width of the left or right
			//items is too large to allow that, we center between the items.
			//this seems to match the behavior on iOS.
			var idealTitlePosition:Float = this._paddingLeft + Math.fround((actualWidthMinusPadding - this.titleTextRenderer.width) / 2);
			if (leftOffset > idealTitlePosition ||
				(idealTitlePosition + this.titleTextRenderer.width) > (this.actualWidth - rightOffset))
			{
				this.titleTextRenderer.x = leftOffset + Math.fround((actualWidthMinusOffsets - this.titleTextRenderer.width) / 2);
			}
			else
			{
				this.titleTextRenderer.x = idealTitlePosition;
			}
		}
		var paddingTop:Float = this._paddingTop + this.calculateExtraOSStatusBarPadding();
		switch (this._verticalAlign)
		{
			case VerticalAlign.TOP:
				this.titleTextRenderer.y = paddingTop;
			
			case VerticalAlign.BOTTOM:
				this.titleTextRenderer.y = this.actualHeight - this._paddingBottom - this.titleTextRenderer.height;
			
			default: //center
				this.titleTextRenderer.y = paddingTop + Math.fround((this.actualHeight - paddingTop - this._paddingBottom - this.titleTextRenderer.height) / 2);
		}
	}
	
	/**
	 * @private
	 */
	private function header_addedToStageHandler(event:Event):Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		starling.nativeStage.addEventListener("fullScreen", nativeStage_fullScreenHandler);
	}
	
	/**
	 * @private
	 */
	private function header_removedFromStageHandler(event:Event):Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		starling.nativeStage.removeEventListener("fullScreen", nativeStage_fullScreenHandler);
	}
	
	/**
	 * @private
	 */
	private function nativeStage_fullScreenHandler(event:FullScreenEvent):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function fontStyles_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private function titleProperties_onChange(proxy:PropertyProxy, propertyName:String):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private function item_resizeHandler(event:Event):Void
	{
		if (this._ignoreItemResizing)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
}