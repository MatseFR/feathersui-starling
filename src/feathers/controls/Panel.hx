/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IFocusExtras;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import feathers.core.PropertyProxy;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import starling.display.DisplayObject;
import starling.events.Event;

/**
 * A container with layout, optional scrolling, a header, and an optional
 * footer.
 *
 * <p>The following example creates a panel with a horizontal layout and
 * adds two buttons to it:</p>
 *
 * <listing version="3.0">
 * var panel:Panel = new Panel();
 * panel.title = "Is it time to party?";
 * 
 * var layout:HorizontalLayout = new HorizontalLayout();
 * layout.gap = 20;
 * layout.padding = 20;
 * panel.layout = layout;
 * 
 * this.addChild( panel );
 * 
 * var yesButton:Button = new Button();
 * yesButton.label = "Yes";
 * panel.addChild( yesButton );
 * 
 * var noButton:Button = new Button();
 * noButton.label = "No";
 * panel.addChild( noButton );</listing>
 *
 * @see ../../../help/panel.html How to use the Feathers Panel component
 *
 * @productversion Feathers 1.1.0
 */
class Panel extends ScrollContainer implements IFocusExtras
{
	/**
	 * The default value added to the <code>styleNameList</code> of the header.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_HEADER:String = "feathers-panel-header";
	
	/**
	 * The default value added to the <code>styleNameList</code> of the footer.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_FOOTER:String = "feathers-panel-footer";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>Panel</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_HEADER_FACTORY:String = "headerFactory";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_FOOTER_FACTORY:String = "footerFactory";

	/**
	 * @private
	 */
	private static function defaultHeaderFactory():IFeathersControl
	{
		return new Header();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
	}
	
	/**
	 * The header sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #headerFactory
	 * @see #createHeader()
	 */
	private var header:IFeathersControl;

	/**
	 * The footer sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #footerFactory
	 * @see #createFooter()
	 */
	private var footer:IFeathersControl;

	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * header. This variable is <code>protected</code> so that sub-classes
	 * can customize the header style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_HEADER</code>.
	 *
	 * <p>To customize the header style name without subclassing, see
	 * <code>customHeaderStyleName</code>.</p>
	 *
	 * @see #style:customHeaderStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var headerStyleName:String = DEFAULT_CHILD_STYLE_NAME_HEADER;
	
	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * footer. This variable is <code>protected</code> so that sub-classes
	 * can customize the footer style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_FOOTER</code>.
	 *
	 * <p>To customize the footer style name without subclassing, see
	 * <code>customFooterStyleName</code>.</p>
	 *
	 * @see #style:customFooterStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var footerStyleName:String = DEFAULT_CHILD_STYLE_NAME_FOOTER;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return Panel.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var _explicitHeaderWidth:Float;

	/**
	 * @private
	 */
	private var _explicitHeaderHeight:Float;

	/**
	 * @private
	 */
	private var _explicitHeaderMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitHeaderMinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitFooterWidth:Float;

	/**
	 * @private
	 */
	private var _explicitFooterHeight:Float;

	/**
	 * @private
	 */
	private var _explicitFooterMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitFooterMinHeight:Float;
	
	/**
	 * The panel's title to display in the header.
	 *
	 * <p>By default, this value is passed to the <code>title</code>
	 * property of the header, if that property exists. However, if the
	 * header is not a <code>feathers.controls.Header</code> instance,
	 * changing the value of <code>titleField</code> will allow the panel to
	 * pass its title to a different property on the header instead.</p>
	 *
	 * <p>In the following example, a custom header factory is provided to
	 * the panel:</p>
	 *
	 * <listing version="3.0">
	 * panel.title = "Settings";</listing>
	 *
	 * @default null
	 *
	 * @see #headerTitleField
	 * @see #headerFactory
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._title;
	}
	
	/**
	 * A property of the header that should be used to display the panel's
	 * title.
	 *
	 * <p>By default, this value is passed to the <code>title</code>
	 * property of the header, if that property exists. However, if the
	 * header is not a <code>feathers.controls.Header</code> instance,
	 * changing the value of <code>titleField</code> will allow the panel to
	 * pass the title to a different property name instead.</p>
	 *
	 * <p>In the following example, a <code>Button</code> is used as a
	 * custom header, and the title is passed to its <code>label</code>
	 * property:</p>
	 *
	 * <listing version="3.0">
	 * panel.headerFactory = function():IFeathersControl
	 * {
	 *     return new Button();
	 * };
	 * panel.titleField = "label";</listing>
	 *
	 * @default "title"
	 *
	 * @see #title
	 * @see #headerFactory
	 */
	public var headerTitleField(get, set):String;
	private var _headerTitleField:String = "title";
	private function get_headerTitleField():String { return this._headerTitleField; }
	private function set_headerTitleField(value:String):String
	{
		if (this._headerTitleField == value)
		{
			return value;
		}
		this._headerTitleField = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerTitleField;
	}
	
	/**
	 * A function used to generate the panel's header sub-component.
	 * The header must be an instance of <code>IFeathersControl</code>, but
	 * the default is an instance of <code>Header</code>. This factory can
	 * be used to change properties on the header when it is first
	 * created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to set skins and other
	 * styles on the header.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():IFeathersControl</pre>
	 *
	 * <p>In the following example, a custom header factory is provided to
	 * the panel:</p>
	 *
	 * <listing version="3.0">
	 * panel.headerFactory = function():IFeathersControl
	 * {
	 *     var header:Header = new Header();
	 *     var closeButton:Button = new Button();
	 *     closeButton.label = "Close";
	 *     closeButton.addEventListener( Event.TRIGGERED, closeButton_triggeredHandler );
	 *     header.rightItems = new &lt;DisplayObject&gt;[ closeButton ];
	 *     return header;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Header
	 */
	public var headerFactory(get, set):Void->IFeathersControl;
	private var _headerFactory:Void->IFeathersControl;
	private function get_headerFactory():Void->IFeathersControl { return this._headerFactory; }
	private function set_headerFactory(value:Void->IFeathersControl):Void->IFeathersControl
	{
		if (this._headerFactory == value)
		{
			return value;
		}
		this._headerFactory = value;
		this.invalidate(INVALIDATION_FLAG_HEADER_FACTORY);
		//hack because the super class doesn't know anything about the
		//header factory
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._headerFactory;
	}
	
	/**
	 * @private
	 */
	public var customHeaderStyleName(get, set):String;
	private var _customHeaderStyleName:String;
	private function get_customHeaderStyleName():String { return this._customHeaderStyleName; }
	private function set_customHeaderStyleName(value:String):String
	{
		if (this.processStyleRestriction("customHeaderStyleName"))
		{
			return value;
		}
		if (this._customHeaderStyleName == value)
		{
			return value;
		}
		this._customHeaderStyleName = value;
		this.invalidate(INVALIDATION_FLAG_HEADER_FACTORY);
		//hack because the super class doesn't know anything about the
		//header factory
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._customHeaderStyleName;
	}
	
	/**
	 * An object that stores properties for the container's header
	 * sub-component, and the properties will be passed down to the header
	 * when the container validates. Any Feathers component may be used as
	 * the container's header, so the available properties depend on which
	 * type of component is returned by <code>headerFactory</code>.
	 *
	 * <p>By default, the <code>headerFactory</code> will return a
	 * <code>Header</code> instance. If you aren't using a different type of
	 * component as the container's header, you can refer to
	 * <a href="Header.html"><code>feathers.controls.Header</code></a>
	 * for a list of available properties. Otherwise, refer to the
	 * appropriate documentation for details about which properties are
	 * available on the component that you're using as the header.</p>
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>headerFactory</code> function
	 * instead of using <code>headerProperties</code> will result in better
	 * performance.</p>
	 *
	 * <p>In the following example, the header properties are customized:</p>
	 *
	 * <listing version="3.0">
	 * var closeButton:Button = new Button();
	 * closeButton.label = "Close";
	 * closeButton.addEventListener( Event.TRIGGERED, closeButton_triggeredHandler );
	 * panel.headerProperties.rightItems = new &lt;DisplayObject&gt;[ closeButton ];</listing>
	 *
	 * @default null
	 *
	 * @see #headerFactory
	 * @see feathers.controls.Header
	 */
	public var headerProperties(get, set):PropertyProxy;
	private var _headerProperties:PropertyProxy;
	private function get_headerProperties():PropertyProxy
	{
		if (this._headerProperties == null)
		{
			this._headerProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._headerProperties;
	}
	
	private function set_headerProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._headerProperties == value)
		{
			return value;
		}
		//if (value == null)
		//{
			//value = new PropertyProxy();
		//}
		//if (!Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._headerProperties != null)
		{
			//this._headerProperties.removeOnChangeCallback(childProperties_onChange);
			this._headerProperties.dispose();
		}
		this._headerProperties = value;
		if (this._headerProperties != null)
		{
			this._headerProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._headerProperties;
	}
	
	/**
	 * A function used to generate the panel's footer sub-component.
	 * The footer must be an instance of <code>IFeathersControl</code>, and
	 * by default, there is no footer. This factory can be used to change
	 * properties on the footer when it is first created. For instance, if
	 * you are skinning Feathers components without a theme, you might use
	 * this factory to set skins and other styles on the footer.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():IFeathersControl</pre>
	 *
	 * <p>In the following example, a custom footer factory is provided to
	 * the panel:</p>
	 *
	 * <listing version="3.0">
	 * panel.footerFactory = function():IFeathersControl
	 * {
	 *     return new ScrollContainer();
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.FeathersControl
	 */
	public var footerFactory(get, set):Function;
	private var _footerFactory:Function;
	private function get_footerFactory():Function { return this._footerFactory; }
	private function set_footerFactory(value:Function):Function
	{
		if (this._footerFactory == value)
		{
			return value;
		}
		this._footerFactory = value;
		this.invalidate(INVALIDATION_FLAG_FOOTER_FACTORY);
		//hack because the super class doesn't know anything about the
		//header factory
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._footerFactory;
	}
	
	/**
	 * @private
	 */
	public var customFooterStyleName(get, set):String;
	private var _customFooterStyleName:String;
	private function get_customFooterStyleName():String { return this._customFooterStyleName; }
	private function set_customFooterStyleName(value:String):String
	{
		if (this.processStyleRestriction("customFooterStyleName"))
		{
			return value;
		}
		if (this._customFooterStyleName == value)
		{
			return value;
		}
		this._customFooterStyleName = value;
		this.invalidate(INVALIDATION_FLAG_FOOTER_FACTORY);
		//hack because the super class doesn't know anything about the
		//header factory
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._customFooterStyleName;
	}
	
	/**
	 * An object that stores properties for the container's footer
	 * sub-component, and the properties will be passed down to the footer
	 * when the container validates. Any Feathers component may be used as
	 * the container's footer, so the available properties depend on which
	 * type of component is returned by <code>footerFactory</code>. Refer to
	 * the appropriate documentation for details about which properties are
	 * available on the component that you're using as the footer.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>footerFactory</code> function
	 * instead of using <code>footerProperties</code> will result in better
	 * performance.</p>
	 *
	 * <p>In the following example, the footer properties are customized:</p>
	 *
	 * <listing version="3.0">
	 * panel.footerProperties.verticalScrollPolicy = ScrollPolicy.OFF;</listing>
	 *
	 * @default null
	 *
	 * @see #footerFactory
	 */
	public var footerProperties(get, set):PropertyProxy;
	private var _footerProperties:PropertyProxy;
	private function get_footerProperties():PropertyProxy
	{
		if (this._footerProperties == null)
		{
			this._footerProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._footerProperties;
	}
	
	private function set_footerProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._footerProperties == value)
		{
			return value;
		}
		//if (value == null)
		//{
			//value = new PropertyProxy();
		//}
		//if (!Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._footerProperties != null)
		{
			//this._footerProperties.removeOnChangeCallback(childProperties_onChange);
			this._footerProperties.dispose();
		}
		this._footerProperties = value;
		if (this._footerProperties != null)
		{
			this._footerProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._footerProperties;
	}
	
	/**
	 * @inheritDoc
	 */
	public var focusExtrasBefore(get, never):Array<DisplayObject>;
	private var _focusExtrasBefore:Array<DisplayObject> = new Array<DisplayObject>();
	private function get_focusExtrasBefore():Array<DisplayObject> { return this._focusExtrasBefore; }
	
	/**
	 * @inheritDoc
	 */
	public var focusExtrasAfter(get, never):Array<DisplayObject>;
	private var _focusExtrasAfter:Array<DisplayObject> = new Array<DisplayObject>();
	private function get_focusExtrasAfter():Array<DisplayObject> { return this._focusExtrasAfter; }
	
	/**
	 * @private
	 */
	public var outerPadding(get, set):Float;
	private function get_outerPadding():Float { return this._outerPaddingTop; }
	private function set_outerPadding(value:Float):Float
	{
		this.outerPaddingTop = value;
		this.outerPaddingRight = value;
		this.outerPaddingBottom = value;
		return this.outerPaddingLeft = value;
	}
	
	/**
	 * @private
	 */
	public var outerPaddingTop(get, set):Float;
	private var _outerPaddingTop:Float = 0;
	private function get_outerPaddingTop():Float { return this._outerPaddingTop; }
	private function set_outerPaddingTop(value:Float):Float
	{
		if (this.processStyleRestriction("outerPaddingTop"))
		{
			return value;
		}
		if (this._outerPaddingTop == value)
		{
			return value;
		}
		this._outerPaddingTop = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._outerPaddingTop;
	}
	
	/**
	 * @private
	 */
	public var outerPaddingRight(get, set):Float;
	private var _outerPaddingRight:Float = 0;
	private function get_outerPaddingRight():Float { return this._outerPaddingRight; }
	private function set_outerPaddingRight(value:Float):Float
	{
		if (this.processStyleRestriction("outerPaddingRight"))
		{
			return value;
		}
		if (this._outerPaddingRight == value)
		{
			return value;
		}
		this._outerPaddingRight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._outerPaddingRight;
	}
	
	/**
	 * @private
	 */
	public var outerPaddingBottom(get, set):Float;
	private var _outerPaddingBottom:Float = 0;
	private function get_outerPaddingBottom():Float { return this._outerPaddingBottom; }
	private function set_outerPaddingBottom(value:Float):Float
	{
		if (this.processStyleRestriction("outerPaddingBottom"))
		{
			return value;
		}
		if (this._outerPaddingBottom == value)
		{
			return value;
		}
		this._outerPaddingBottom = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._outerPaddingBottom;
	}
	
	/**
	 * @private
	 */
	public var outerPaddingLeft(get, set):Float;
	private var _outerPaddingLeft:Float = 0;
	private function get_outerPaddingLeft():Float { return this._outerPaddingLeft; }
	private function set_outerPaddingLeft(value:Float):Float
	{
		if (this.processStyleRestriction("outerPaddingLeft"))
		{
			return value;
		}
		if (this._outerPaddingLeft == value)
		{
			return value;
		}
		this._outerPaddingLeft = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._outerPaddingLeft;
	}
	
	/**
	 * @private
	 */
	private var _ignoreHeaderResizing:Bool = false;
	
	/**
	 * @private
	 */
	private var _ignoreFooterResizing:Bool = false;
	
	override public function dispose():Void 
	{
		if (this._headerProperties != null)
		{
			this._headerProperties.dispose();
			this._headerProperties = null;
		}
		if (this._footerProperties != null)
		{
			this._footerProperties.dispose();
			this._footerProperties = null;
		}
		
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var headerFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_HEADER_FACTORY);
		var footerFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_FOOTER_FACTORY);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		
		if (headerFactoryInvalid)
		{
			this.createHeader();
		}
		
		if (footerFactoryInvalid)
		{
			this.createFooter();
		}
		
		if (headerFactoryInvalid || stylesInvalid)
		{
			this.refreshHeaderStyles();
		}
		
		if (footerFactoryInvalid || stylesInvalid)
		{
			this.refreshFooterStyles();
		}
		
		super.draw();
	}
	
	/**
	 * @inheritDoc
	 */
	override function autoSizeIfNeeded():Bool
	{
		if (this._autoSizeMode == AutoSizeMode.STAGE)
		{
			//the implementation in ScrollContainer can handle this
			return super.autoSizeIfNeeded();
		}
		
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
		var measureBackground:IMeasureDisplayObject = SafeCast.safe_cast(this.currentBackgroundSkin, IMeasureDisplayObject);
		if (Std.isOfType(this.currentBackgroundSkin, IValidating))
		{
			cast(this.currentBackgroundSkin, IValidating).validate();
		}
		
		//we don't measure the header and footer here because they are
		//handled in calculateViewPortOffsets(), which is automatically
		//called by Scroller before autoSizeIfNeeded().
		
		var newWidth:Float = this._explicitWidth;
		var newHeight:Float = this._explicitHeight;
		var newMinWidth:Float = this._explicitMinWidth;
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsWidth)
		{
			if (this._measureViewPort)
			{
				newWidth = this._viewPort.visibleWidth;
			}
			else
			{
				newWidth = 0;
			}
			//we don't need to account for the icon and gap because it is
			//already included in the left offset
			newWidth += this._rightViewPortOffset + this._leftViewPortOffset;
			var headerWidth:Float = this.header.width + this._outerPaddingLeft + this._outerPaddingRight;
			if (headerWidth > newWidth)
			{
				newWidth = headerWidth;
			}
			if (this.footer != null)
			{
				var footerWidth:Float = this.footer.width + this._outerPaddingLeft + this._outerPaddingRight;
				if (footerWidth > newWidth)
				{
					newWidth = footerWidth;
				}
			}
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.width > newWidth)
			{
				newWidth = this.currentBackgroundSkin.width;
			}
		}
		if (needsHeight)
		{
			if (this._measureViewPort)
			{
				newHeight = this._viewPort.visibleHeight;
			}
			else
			{
				newHeight = 0;
			}
			newHeight += this._bottomViewPortOffset + this._topViewPortOffset;
			//we don't need to account for the header and footer because
			//they're already included in the top and bottom offsets
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.height > newHeight)
			{
				newHeight = this.currentBackgroundSkin.height;
			}
		}
		if (needsMinWidth)
		{
			if (this._measureViewPort)
			{
				newMinWidth = this._viewPort.minVisibleWidth;
			}
			else
			{
				newMinWidth = 0;
			}
			//we don't need to account for the icon and gap because it is
			//already included in the left offset
			newMinWidth += this._rightViewPortOffset + this._leftViewPortOffset;
			var headerMinWidth:Float = this.header.minWidth + this._outerPaddingLeft + this._outerPaddingRight;
			if (headerMinWidth > newMinWidth)
			{
				newMinWidth = headerMinWidth;
			}
			if (this.footer != null)
			{
				var footerMinWidth:Float = this.footer.minWidth + this._outerPaddingLeft + this._outerPaddingRight;
				if (footerMinWidth > newMinWidth)
				{
					newMinWidth = footerMinWidth;
				}
			}
			if (this.currentBackgroundSkin != null)
			{
				if (measureBackground != null)
				{
					if (measureBackground.minWidth > newMinWidth)
					{
						newMinWidth = measureBackground.minWidth;
					}
				}
				else if (this._explicitBackgroundMinWidth > newMinWidth)
				{
					newMinWidth = this._explicitBackgroundMinWidth;
				}
			}
		}
		if (needsMinHeight)
		{
			if (this._measureViewPort)
			{
				newMinHeight = this._viewPort.minVisibleHeight;
			}
			else
			{
				newMinHeight = 0;
			}
			newMinHeight += this._bottomViewPortOffset + this._topViewPortOffset;
			//we don't need to account for the header and footer because
			//they're already included in the top and bottom offsets
			if (this.currentBackgroundSkin != null)
			{
				if (measureBackground != null)
				{
					if (measureBackground.minHeight > newMinHeight)
					{
						newMinHeight = measureBackground.minHeight;
					}
				}
				else if (this._explicitBackgroundMinHeight > newMinHeight)
				{
					newMinHeight = this._explicitBackgroundMinHeight;
				}
			}
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * Creates and adds the <code>header</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #header
	 * @see #headerFactory
	 * @see #style:customHeaderStyleName
	 */
	private function createHeader():Void
	{
		var displayHeader:DisplayObject;
		if (this.header != null)
		{
			this.header.removeEventListener(FeathersEventType.RESIZE, header_resizeHandler);
			displayHeader = cast this.header;
			this._focusExtrasBefore.splice(this._focusExtrasBefore.indexOf(displayHeader), 1);
			this.removeRawChild(displayHeader, true);
			this.header = null;
		}
		
		var factory:Void->IFeathersControl = this._headerFactory != null ? this._headerFactory : defaultHeaderFactory;
		var headerStyleName:String = this._customHeaderStyleName != null ? this._customHeaderStyleName : this.headerStyleName;
		this.header = factory();
		this.header.styleNameList.add(headerStyleName);
		displayHeader = cast this.header;
		this.addRawChild(displayHeader);
		this._focusExtrasBefore.push(displayHeader);
		this.header.addEventListener(FeathersEventType.RESIZE, header_resizeHandler);
		
		this.header.initializeNow();
		this._explicitHeaderWidth = this.header.explicitWidth;
		this._explicitHeaderHeight = this.header.explicitHeight;
		this._explicitHeaderMinWidth = this.header.explicitMinWidth;
		this._explicitHeaderMinHeight = this.header.explicitMinHeight;
	}
	
	/**
	 * Creates and adds the <code>footer</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #footer
	 * @see #footerFactory
	 * @see #style:customFooterStyleName
	 */
	private function createFooter():Void
	{
		var displayFooter:DisplayObject;
		if (this.footer != null)
		{
			this.footer.removeEventListener(FeathersEventType.RESIZE, footer_resizeHandler);
			displayFooter = cast this.footer;
			this._focusExtrasAfter.splice(this._focusExtrasAfter.indexOf(displayFooter), 1);
			this.removeRawChild(displayFooter, true);
			this.footer = null;
		}
		
		if (this._footerFactory == null)
		{
			return;
		}
		var footerStyleName:String = this._customFooterStyleName != null ? this._customFooterStyleName : this.footerStyleName;
		this.footer = this._footerFactory();
		this.footer.styleNameList.add(footerStyleName);
		this.footer.addEventListener(FeathersEventType.RESIZE, footer_resizeHandler);
		displayFooter = cast this.footer;
		this.addRawChild(displayFooter);
		this._focusExtrasAfter.push(displayFooter);
		
		this.footer.initializeNow();
		this._explicitFooterWidth = this.footer.explicitWidth;
		this._explicitFooterHeight = this.footer.explicitHeight;
		this._explicitFooterMinWidth = this.footer.explicitMinWidth;
		this._explicitFooterMinHeight = this.footer.explicitMinHeight;
	}
	
	/**
	 * @private
	 */
	private function refreshHeaderStyles():Void
	{
		//var fields:Array<String> = Type.getInstanceFields(Type.getClass(this.header));
		//var index:Int = fields.indexOf(this._headerTitleField);
		if (Reflect.hasField(this.header, this._headerTitleField) || Reflect.hasField(this.header, "set_" + this._headerTitleField))
		{
			Reflect.setProperty(this.header, this._headerTitleField, this._title);
		}
		if (this._headerProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._headerProperties)
			{
				propertyValue = this._headerProperties[propertyName];
				//this.header[propertyName] = propertyValue;
				Reflect.setProperty(this.header, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshFooterStyles():Void
	{
		if (this._footerProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._footerProperties)
			{
				propertyValue = this._footerProperties[propertyName];
				//this.footer[propertyName] = propertyValue;
				Reflect.setProperty(this.footer, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	override function calculateViewPortOffsets(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void
	{
		super.calculateViewPortOffsets(forceScrollBars);
		
		this._leftViewPortOffset += this._outerPaddingLeft;
		this._rightViewPortOffset += this._outerPaddingRight;
		
		var oldIgnoreHeaderResizing:Bool = this._ignoreHeaderResizing;
		this._ignoreHeaderResizing = true;
		if (useActualBounds)
		{
			this.header.width = this.actualWidth - this._outerPaddingLeft - this._outerPaddingRight;
			this.header.minWidth = this.actualMinWidth - this._outerPaddingLeft - this._outerPaddingRight;
		}
		else
		{
			this.header.width = this._explicitWidth - this._outerPaddingLeft - this._outerPaddingRight;
			this.header.minWidth = this._explicitMinWidth - this._outerPaddingLeft - this._outerPaddingRight;
		}
		this.header.maxWidth = this._explicitMaxWidth - this._outerPaddingLeft - this._outerPaddingRight;
		this.header.height = this._explicitHeaderHeight;
		this.header.minHeight = this._explicitHeaderMinHeight;
		this.header.validate();
		this._topViewPortOffset += this.header.height + this._outerPaddingTop;
		this._ignoreHeaderResizing = oldIgnoreHeaderResizing;
		
		if (this.footer != null)
		{
			var oldIgnoreFooterResizing:Bool = this._ignoreFooterResizing;
			this._ignoreFooterResizing = true;
			if (useActualBounds)
			{
				this.footer.width = this.actualWidth - this._outerPaddingLeft - this._outerPaddingRight;
				this.footer.minWidth = this.actualMinWidth - this._outerPaddingLeft - this._outerPaddingRight;
			}
			else
			{
				this.footer.width = this._explicitWidth - this._outerPaddingLeft - this._outerPaddingRight;
				this.footer.minWidth = this._explicitMinWidth - this._outerPaddingLeft - this._outerPaddingRight;
			}
			this.footer.maxWidth = this._explicitMaxWidth - this._outerPaddingLeft - this._outerPaddingRight;
			this.footer.height = this._explicitFooterHeight;
			this.footer.minHeight = this._explicitFooterMinHeight;
			this.footer.validate();
			this._bottomViewPortOffset += this.footer.height + this._outerPaddingBottom;
			this._ignoreFooterResizing = oldIgnoreFooterResizing;
		}
		else
		{
			this._bottomViewPortOffset += this._outerPaddingBottom;
		}
	}
	
	/**
	 * @private
	 */
	override function layoutChildren():Void
	{
		super.layoutChildren();
		
		var oldIgnoreHeaderResizing:Bool = this._ignoreHeaderResizing;
		this._ignoreHeaderResizing = true;
		this.header.x = this._outerPaddingLeft;
		this.header.y = this._outerPaddingTop;
		this.header.width = this.actualWidth - this._outerPaddingLeft - this._outerPaddingRight;
		this.header.height = this._explicitHeaderHeight;
		this.header.validate();
		this._ignoreHeaderResizing = oldIgnoreHeaderResizing;
		
		if (this.footer != null)
		{
			var oldIgnoreFooterResizing:Bool = this._ignoreFooterResizing;
			this._ignoreFooterResizing = true;
			this.footer.x = this._outerPaddingLeft;
			this.footer.width = this.actualWidth - this._outerPaddingLeft - this._outerPaddingRight;
			this.footer.height = this._explicitFooterHeight;
			this.footer.validate();
			this.footer.y = this.actualHeight - this.footer.height - this._outerPaddingBottom;
			this._ignoreFooterResizing = oldIgnoreFooterResizing;
		}
	}
	
	/**
	 * @private
	 */
	private function header_resizeHandler(event:Event):Void
	{
		if (this._ignoreHeaderResizing)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}

	/**
	 * @private
	 */
	private function footer_resizeHandler(event:Event):Void
	{
		if (this._ignoreFooterResizing)
		{
			return;
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
	}
	
}