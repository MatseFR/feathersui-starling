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
import feathers.core.PopUpManager;
import feathers.core.PropertyProxy;
import feathers.data.IListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.IStyleProvider;
import feathers.text.FontStylesSet;
import feathers.utils.display.DisplayUtils;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.events.Event;
import starling.text.TextFormat;

/**
 * Displays a message in a modal pop-up with a title and a set of buttons.
 *
 * <p>In general, an <code>Alert</code> isn't instantiated directly.
 * Instead, you will typically call the static function
 * <code>Alert.show()</code>. This is not required, but it result in less
 * code and no need to manually manage calls to the <code>PopUpManager</code>.</p>
 *
 * <p>In the following example, an alert is shown when a <code>Button</code>
 * is triggered:</p>
 *
 * <listing version="3.0">
 * button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
 * 
 * function button_triggeredHandler( event:Event ):void
 * {
 *     var alert:Alert = Alert.show( "This is an alert!", "Hello World", new ArrayCollection(
 *     [
 *         { label: "OK" }
 *     ]));
 * }</listing>
 *
 * @see ../../../help/alert.html How to use the Feathers Alert component
 *
 * @productversion Feathers 1.2.0
 */
class Alert extends Panel 
{
	/**
	 * The default value added to the <code>styleNameList</code> of the header.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_HEADER:String = "feathers-alert-header";

	/**
	 * The default value added to the <code>styleNameList</code> of the button group.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_BUTTON_GROUP:String = "feathers-alert-button-group";

	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * message text renderer.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_MESSAGE:String = "feathers-alert-message";
	
	/**
	 * Returns a new <code>Alert</code> instance when <code>Alert.show()</code>
	 * is called. If one wishes to skin the alert manually, a custom factory
	 * may be provided.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():Alert</pre>
	 *
	 * <p>The following example shows how to create a custom alert factory:</p>
	 *
	 * <listing version="3.0">
	 * Alert.alertFactory = function():Alert
	 * {
	 *     var alert:Alert = new Alert();
	 *     //set properties here!
	 *     return alert;
	 * };</listing>
	 *
	 * @see #show()
	 */
	public static var alertFactory:Void->Alert = defaultAlertFactory;
	
	/**
	 * Creates overlays for modal alerts. When this property is
	 * <code>null</code>, uses the <code>overlayFactory</code> defined by
	 * <code>PopUpManager</code> instead.
	 *
	 * <p>Note: Specific, individual alerts may have custom overlays that
	 * are different than the default by passing a different overlay factory
	 * to <code>Alert.show()</code>.</p>
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function():DisplayObject</pre>
	 *
	 * <p>The following example uses a semi-transparent <code>Quad</code> as
	 * a custom overlay:</p>
	 *
	 * <listing version="3.0">
	 * Alert.overlayFactory = function():Quad
	 * {
	 *     var quad:Quad = new Quad(10, 10, 0x000000);
	 *     quad.alpha = 0.75;
	 *     return quad;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.PopUpManager#overlayFactory
	 * @see #show()
	 */
	public static var overlayFactory:Void->Quad;
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>Alert</code>
	 * components.
	 *
	 * @default null
	 *
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

	/**
	 * The default factory that creates alerts when <code>Alert.show()</code>
	 * is called. To use a different factory, you need to set
	 * <code>Alert.alertFactory</code> to a <code>Function</code>
	 * instance.
	 *
	 * @see #show()
	 * @see #alertFactory
	 */
	public static function defaultAlertFactory():Alert
	{
		return new Alert();
	}
	
	/**
	 * Creates an alert, sets common properties, and adds it to the
	 * <code>PopUpManager</code> with the specified modal and centering
	 * options.
	 *
	 * <p>In the following example, an alert is shown when a
	 * <code>Button</code> is triggered:</p>
	 *
	 * <listing version="3.0">
	 * button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
	 * 
	 * function button_triggeredHandler( event:Event ):void
	 * {
	 *     var alert:Alert = Alert.show( "This is an alert!", "Hello World", new ArrayCollection(
	 *     [
	 *         { label: "OK" }
	 *     ]);
	 * }</listing>
	 */
	public static function show(message:String, title:String = null, buttons:IListCollection = null,
		icon:DisplayObject = null, isModal:Bool = true, isCentered:Bool = true,
		customAlertFactory:Void->Alert = null, customOverlayFactory:Void->Quad = null):Alert
	{
		var factory:Void->Alert = customAlertFactory;
		if (factory == null)
		{
			factory = alertFactory != null ? alertFactory : defaultAlertFactory;
		}
		var alert:Alert = factory();
		alert.title = title;
		alert.message = message;
		alert.buttonsDataProvider = buttons;
		alert.icon = icon;
		var overlayFactory:Void->Quad = customOverlayFactory;
		if (overlayFactory == null)
		{
			overlayFactory = Alert.overlayFactory;
		}
		PopUpManager.addPopUp(alert, isModal, isCentered, overlayFactory);
		return alert;
	}
	
	/**
	 * @private
	 */
	private static function defaultButtonGroupFactory():ButtonGroup
	{
		return new ButtonGroup();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.headerStyleName = DEFAULT_CHILD_STYLE_NAME_HEADER;
		this.footerStyleName = DEFAULT_CHILD_STYLE_NAME_BUTTON_GROUP;
		if (this._fontStylesSet == null)
		{
			this._fontStylesSet = new FontStylesSet();
			this._fontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
		this.buttonGroupFactory = defaultButtonGroupFactory;
		this.addEventListener(Event.ADDED_TO_STAGE, alert_addedToStageHandler);
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the alert's
	 * message text renderer. This variable is <code>protected</code> so
	 * that sub-classes can customize the message style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_MESSAGE</code>.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var messageStyleName:String = DEFAULT_CHILD_STYLE_NAME_MESSAGE;

	/**
	 * The header sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var headerHeader:Header;

	/**
	 * The button group sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var buttonGroupFooter:ButtonGroup;

	/**
	 * The message text renderer sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var messageTextRenderer:ITextRenderer;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return Alert.globalStyleProvider;
	}
	
	/**
	 * The alert's main text content.
	 */
	public var message(get, set):String;
	private var _message:String;
	private function get_message():String { return this._message; }
	private function set_message(value:String):String
	{
		if (this._message == value)
		{
			return value;
		}
		this._message = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._message;
	}
	
	/**
	 * @private
	 */
	public var icon(get, set):DisplayObject;
	private var _icon:DisplayObject;
	private function get_icon():DisplayObject { return this._icon; }
	private function set_icon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("icon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._icon == value)
		{
			return value;
		}
		var oldDisplayListBypassEnabled:Bool = this.displayListBypassEnabled;
		this.displayListBypassEnabled = false;
		if (this._icon != null)
		{
			this._icon.removeEventListener(FeathersEventType.RESIZE, icon_resizeHandler);
			this.removeChild(this._icon);
		}
		this._icon = value;
		if (this._icon != null)
		{
			this._icon.addEventListener(FeathersEventType.RESIZE, icon_resizeHandler);
			this.addChild(this._icon);
		}
		this.displayListBypassEnabled = oldDisplayListBypassEnabled;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._icon;
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
		return this._gap;
	}
	
	/**
	 * The data provider of the alert's <code>ButtonGroup</code>.
	 */
	public var buttonsDataProvider(get, set):IListCollection;
	private var _buttonsDataProvider:IListCollection;
	private function get_buttonsDataProvider():IListCollection { return this._buttonsDataProvider; }
	private function set_buttonsDataProvider(value:IListCollection):IListCollection
	{
		if (this._buttonsDataProvider == value)
		{
			return value;
		}
		this._buttonsDataProvider = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._buttonsDataProvider;
	}
	
	/**
	 * The index of the button in the <code>buttonsDataProvider</code> to
	 * trigger when <code>Keyboard.ENTER</code> is pressed.
	 *
	 * <p>In the following example, the <code>acceptButtonIndex</code> is
	 * set to the first button in the data provider.</p>
	 *
	 * <listing version="3.0">
	 * var alert:Alert = Alert.show( "This is an alert!", "Hello World", new ArrayCollection(
	 * [
	 *     { label: "OK" }
	 * ]));
	 * alert.acceptButtonIndex = 0;</listing>
	 *
	 * @default -1
	 */
	public var acceptButtonIndex(get, set):Int;
	private var _acceptButtonIndex:Int;
	private function get_acceptButtonIndex():Int { return this._acceptButtonIndex; }
	private function set_acceptButtonIndex(value:Int):Int
	{
		return this._acceptButtonIndex = value;
	}
	
	/**
	 * The index of the button in the <code>buttonsDataProvider</code> to
	 * trigger when <code>Keyboard.ESCAPE</code> or
	 * <code>Keyboard.BACK</code> is pressed.
	 *
	 * <p>In the following example, the <code>cancelButtonIndex</code> is
	 * set to the second button in the data provider.</p>
	 *
	 * <listing version="3.0">
	 * var alert:Alert = Alert.show( "This is an alert!", "Hello World", new ArrayCollection(
	 * [
	 *     { label: "OK" },
	 *     { label: "Cancel" },
	 * ]));
	 * alert.cancelButtonIndex = 1;</listing>
	 *
	 * @default -1
	 */
	public var cancelButtonIndex(get, set):Int;
	private var _cancelButtonIndex:Int;
	private function get_cancelButtonIndex():Int { return this._cancelButtonIndex; }
	private function set_cancelButtonIndex(value:Int):Int
	{
		return this._cancelButtonIndex = value;
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
	 * A function used to instantiate the alert's message text renderer
	 * sub-component. By default, the alert will use the global text
	 * renderer factory, <code>FeathersControl.defaultTextRendererFactory()</code>,
	 * to create the message text renderer. The message text renderer must
	 * be an instance of <code>ITextRenderer</code>. This factory can be
	 * used to change properties on the message text renderer when it is
	 * first created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to style the message text
	 * renderer.
	 *
	 * <p>If you are not using a theme, the message factory can be used to
	 * provide skin the message text renderer with appropriate text styles.</p>
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, a custom message factory is passed to
	 * the alert:</p>
	 *
	 * <listing version="3.0">
	 * alert.messageFactory = function():ITextRenderer
	 * {
	 *     var messageRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
	 *     messageRenderer.textFormat = new TextFormat( "_sans", 12, 0xff0000 );
	 *     return messageRenderer;
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see #message
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var messageFactory(get, set):Void->ITextRenderer;
	private var _messageFactory:Void->ITextRenderer;
	private function get_messageFactory():Void->ITextRenderer { return this._messageFactory; }
	private function set_messageFactory(value:Void->ITextRenderer):Void->ITextRenderer
	{
		if (this._messageFactory == value)
		{
			return value;
		}
		this._messageFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._messageFactory;
	}
	
	/**
	 * An object that stores properties for the alert's message text
	 * renderer sub-component, and the properties will be passed down to the
	 * text renderer when the alert validates. The available properties
	 * depend on which <code>ITextRenderer</code> implementation is returned
	 * by <code>messageFactory</code>. Refer to
	 * <a href="../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.
	 *
	 * <p>In the following example, some properties are set for the alert's
	 * message text renderer (this example assumes that the message text
	 * renderer is a <code>BitmapFontTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * alert.messageProperties.textFormat = new BitmapFontTextFormat( bitmapFont );
	 * alert.messageProperties.wordWrap = true;</listing>
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>messageFactory</code> function instead
	 * of using <code>messageProperties</code> will result in better
	 * performance.</p>
	 *
	 * @default null
	 *
	 * @see #messageFactory
	 * @see feathers.core.ITextRenderer
	 */
	public var messageProperties(get, set):PropertyProxy;
	private var _messageProperties:PropertyProxy;
	private function get_messageProperties():PropertyProxy
	{
		if (this._messageProperties == null)
		{
			this._messageProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._messageProperties;
	}
	
	private function set_messageProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._messageProperties == value)
		{
			return value;
		}
		if (this._messageProperties != null)
		{
			this._messageProperties.dispose();
		}
		this._messageProperties = value;
		if (this._messageProperties != null)
		{
			this._messageProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._messageProperties;
	}
	
	/**
	 * @private
	 */
	public var customMessageStyleName(get, set):String;
	private var _customMessageStyleName:String;
	private function get_customMessageStyleName():String { return this._customMessageStyleName; }
	private function set_customMessageStyleName(value:String):String
	{
		if (this.processStyleRestriction("customMessageStyleName"))
		{
			return value;
		}
		if (this._customMessageStyleName == value)
		{
			return value;
		}
		this._customMessageStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customMessageStyleName;
	}
	
	/**
	 * A function used to generate the alerts's button group sub-component.
	 * The button group must be an instance of <code>ButtonGroup</code>.
	 * This factory can be used to change properties on the button group
	 * when it is first created. For instance, if you are skinning Feathers
	 * components without a theme, you might use this factory to set skins
	 * and other styles on the button group.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():ButtonGroup</pre>
	 *
	 * <p>In the following example, a custom button group factory is
	 * provided to the alert:</p>
	 *
	 * <listing version="3.0">
	 * alert.buttonGroupFactory = function():ButtonGroup
	 * {
	 *     return new ButtonGroup();
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.ButtonGroup
	 */
	public var buttonGroupFactory(get, set):Function;
	private function get_buttonGroupFactory():Function { return super.footerFactory; }
	private function set_buttonGroupFactory(value:Function):Function
	{
		return super.footerFactory = value;
	}
	
	/**
	 * @private
	 */
	public var customButtonGroupStyleName(get, set):String;
	private function get_customButtonGroupStyleName():String { return super.customFooterStyleName; }
	private function set_customButtonGroupStyleName(value:String):String
	{
		return super.customFooterStyleName = value;
	}
	
	/**
	 * An object that stores properties for the alert's button group
	 * sub-component, and the properties will be passed down to the button
	 * group when the alert validates. For a list of available properties,
	 * refer to <a href="ButtonGroup.html"><code>feathers.controls.ButtonGroup</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>buttonGroupFactory</code> function
	 * instead of using <code>buttonGroupProperties</code> will result in better
	 * performance.</p>
	 *
	 * <p>In the following example, the button group properties are customized:</p>
	 *
	 * <listing version="3.0">
	 * alert.buttonGroupProperties.gap = 20;</listing>
	 *
	 * @default null
	 *
	 * @see #buttonGroupFactory
	 * @see feathers.controls.ButtonGroup
	 */
	public var buttonGroupProperties(get, set):Dynamic;
	private function get_buttonGroupProperties():Dynamic { return this.footerProperties; }
	private function set_buttonGroupProperties(value:Dynamic):Dynamic
	{
		return super.footerProperties = value;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		if (this._messageProperties != null)
		{
			this._messageProperties.dispose();
			this._messageProperties = null;
		}
		if (this._fontStylesSet != null)
		{
			this._fontStylesSet.dispose();
			this._fontStylesSet = null;
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
			var layout:VerticalLayout = new VerticalLayout();
			layout.horizontalAlign = HorizontalAlign.JUSTIFY;
			this.ignoreNextStyleRestriction();
			this.layout = layout;
		}
		super.initialize();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		//var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var textRendererInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		
		if (textRendererInvalid)
		{
			this.createMessage();
		}
		
		if (textRendererInvalid || dataInvalid)
		{
			this.messageTextRenderer.text = this._message;
		}
		
		if (textRendererInvalid || stylesInvalid)
		{
			this.refreshMessageStyles();
		}
		
		super.draw();
		
		if (this._icon != null)
		{
			if (Std.isOfType(this._icon, IValidating))
			{
				cast(this._icon, IValidating).validate();
			}
			this._icon.x = this._paddingLeft;
			this._icon.y = this._topViewPortOffset + (this._viewPort.visibleHeight - this._icon.height) / 2;
		}
	}
	
	/**
	 * @private
	 */
	override function autoSizeIfNeeded():Bool
	{
		if (this._autoSizeMode == AutoSizeMode.STAGE)
		{
			//the implementation in a super class can handle this
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
		
		if (Std.isOfType(this._icon, IValidating))
		{
			cast(this._icon, IValidating).validate();
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
		var iconHeight:Float;
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
			if (this._icon != null)
			{
				iconHeight = this._icon.height;
				if (iconHeight == iconHeight && //!isNaN
					iconHeight > newHeight)
				{
					newHeight = iconHeight;
				}
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
			if (this._icon != null)
			{
				iconHeight = this._icon.height;
				if (iconHeight == iconHeight && //!isNaN
					iconHeight > newMinHeight)
				{
					newMinHeight = iconHeight;
				}
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
	override function createHeader():Void
	{
		super.createHeader();
		this.headerHeader = cast this.header;
	}
	
	/**
	 * Creates and adds the <code>buttonGroupFooter</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #buttonGroupFooter
	 * @see #buttonGroupFactory
	 * @see #style:customButtonGroupStyleName
	 */
	private function createButtonGroup():Void
	{
		if (this.buttonGroupFooter != null)
		{
			this.buttonGroupFooter.removeEventListener(Event.TRIGGERED, buttonsFooter_triggeredHandler);
		}
		super.createFooter();
		this.buttonGroupFooter = cast this.footer;
		this.buttonGroupFooter.addEventListener(Event.TRIGGERED, buttonsFooter_triggeredHandler);
	}
	
	/**
	 * @private
	 */
	override function createFooter():Void
	{
		this.createButtonGroup();
	}
	
	/**
	 * Creates and adds the <code>messageTextRenderer</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #message
	 * @see #messageTextRenderer
	 * @see #messageFactory
	 */
	private function createMessage():Void
	{
		if (this.messageTextRenderer != null)
		{
			this.removeChild(cast this.messageTextRenderer, true);
			this.messageTextRenderer = null;
		}
		
		var factory:Void->ITextRenderer = this._messageFactory != null ? this._messageFactory : FeathersControl.defaultTextRendererFactory;
		this.messageTextRenderer = factory();
		this.messageTextRenderer.wordWrap = true;
		var messageStyleName:String = this._customMessageStyleName != null ? this._customMessageStyleName : this.messageStyleName;
		var uiTextRenderer:IFeathersControl = cast this.messageTextRenderer;
		uiTextRenderer.styleNameList.add(messageStyleName);
		uiTextRenderer.touchable = false;
		this.addChild(cast this.messageTextRenderer);
	}
	
	/**
	 * @private
	 */
	override function refreshFooterStyles():Void
	{
		super.refreshFooterStyles();
		this.buttonGroupFooter.dataProvider = this._buttonsDataProvider;
	}
	
	/**
	 * @private
	 */
	private function refreshMessageStyles():Void
	{
		this.messageTextRenderer.fontStyles = this._fontStylesSet;
		if (this._messageProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._messageProperties)
			{
				propertyValue = this._messageProperties[propertyName];
				//this.messageTextRenderer[propertyName] = propertyValue;
				Reflect.setProperty(this.messageTextRenderer, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	override function calculateViewPortOffsets(forceScrollBars:Bool = false, useActualBounds:Bool = false):Void
	{
		super.calculateViewPortOffsets(forceScrollBars, useActualBounds);
		if (this._icon != null)
		{
			if (Std.isOfType(this._icon, IValidating))
			{
				cast(this._icon, IValidating).validate();
			}
			var iconWidth:Float = this._icon.width;
			if (iconWidth == iconWidth) //!isNaN
			{
				this._leftViewPortOffset += iconWidth + this._gap;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function closeAlert(item:Dynamic):Void
	{
		this.removeFromParent();
		this.dispatchEventWith(Event.CLOSE, false, item);
		this.dispose();
	}
	
	/**
	 * @private
	 */
	private function buttonsFooter_triggeredHandler(event:Event, data:Dynamic):Void
	{
		this.closeAlert(data);
	}

	/**
	 * @private
	 */
	private function icon_resizeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_LAYOUT);
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
	private function alert_addedToStageHandler(event:Event):Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		//using priority here is a hack so that objects higher up in the
		//display list have a chance to cancel the event first.
		var priority:Int = -DisplayUtils.getDisplayObjectDepthFromStage(this);
		starling.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, alert_nativeStage_keyDownHandler, false, priority, true);
		this.addEventListener(Event.REMOVED_FROM_STAGE, alert_removedFromStageHandler);
	}

	/**
	 * @private
	 */
	private function alert_removedFromStageHandler(event:Event):Void
	{
		this.removeEventListener(Event.REMOVED_FROM_STAGE, alert_removedFromStageHandler);
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		starling.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, alert_nativeStage_keyDownHandler);
	}
	
	/**
	 * @private
	 */
	private function alert_nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			//someone else already handled this one
			return;
		}
		if (this._buttonsDataProvider == null)
		{
			//no buttons to trigger
			return;
		}
		var keyCode:Int = event.keyCode;
		var item:Dynamic;
		if (this._acceptButtonIndex != -1 && keyCode == Keyboard.ENTER)
		{
			//don't let the OS handle the event
			event.preventDefault();
			item = this._buttonsDataProvider.getItemAt(this._acceptButtonIndex);
			this.closeAlert(item);
			return;
		}
		// TODO : Keyboard.BACK only available on flash target
		if (this._cancelButtonIndex != -1 &&
			(#if flash keyCode == Keyboard.BACK || #end keyCode == Keyboard.ESCAPE))
		{
			//don't let the OS handle the event
			event.preventDefault();
			item = this._buttonsDataProvider.getItemAt(this._cancelButtonIndex);
			this.closeAlert(item);
			return;
		}
	}
	
}