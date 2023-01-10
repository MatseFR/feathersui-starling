/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;
import feathers.core.FeathersControl;
import feathers.core.ITextRenderer;
import feathers.core.PopUpManager;
import feathers.skins.IStyleProvider;
import feathers.text.FontStylesSet;
import openfl.errors.ArgumentError;
import openfl.ui.Keyboard;
import starling.display.DisplayObject;
import starling.events.EnterFrameEvent;
import starling.events.Event;
import starling.text.TextFormat;

/**
 * A special <code>Callout</code> designed to display text.
 *
 * <p>In the following example, a text callout is shown when a
 * <code>Button</code> is triggered:</p>
 *
 * <listing version="3.0">
 * button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
 * 
 * function button_triggeredHandler( event:Event ):void
 * {
 *     var button:Button = Button( event.currentTarget );
 *     Callout.show( "Hello World", button );
 * }</listing>
 *
 * @see ../../../help/text-callout.html How to use the Feathers Callout component
 *
 * @productversion Feathers 3.0.0
 */
class TextCallout extends Callout 
{
	/**
	 * The default value added to the <code>styleNameList</code> of the text
	 * renderer sub-component.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER:String = "feathers-text-callout-text-renderer";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>Label</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * Returns a new <code>TextCallout</code> instance when
	 * <code>TextCallout.show()</code> is called. If one wishes to skin the
	 * callout manually or change its behavior, a custom factory may be
	 * provided.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():TextCallout</pre>
	 *
	 * <p>The following example shows how to create a custom text callout factory:</p>
	 *
	 * <listing version="3.0">
	 * TextCallout.calloutFactory = function():TextCallout
	 * {
	 *     var callout:TextCallout = new TextCallout();
	 *     //set properties here!
	 *     return callout;
	 * };</listing>
	 *
	 * <p>Note: the default callout factory sets the following properties:</p>
	 *
	 * <listing version="3.0">
	 * callout.closeOnTouchBeganOutside = true;
	 * callout.closeOnTouchEndedOutside = true;
	 * callout.closeOnKeys = new &lt;uint&gt;[Keyboard.BACK, Keyboard.ESCAPE];</listing>
	 *
	 * @see #show()
	 */
	public static var calloutFactory:Void->TextCallout = defaultCalloutFactory;
	
	/**
	 * The default factory that creates callouts when
	 * <code>TextCallout.show()</code> is called. To use a different
	 * factory, you need to set <code>TextCallout.calloutFactory</code> to a
	 * <code>Function</code> instance.
	 */
	public static function defaultCalloutFactory():TextCallout
	{
		var callout:TextCallout = new TextCallout();
		callout.closeOnTouchBeganOutside = true;
		callout.closeOnTouchEndedOutside = true;
		#if flash
		callout.closeOnKeys = [Keyboard.BACK, Keyboard.ESCAPE];
		#else
		callout.closeOnKeys = [Keyboard.ESCAPE];
		#end
		return callout;
	}
	
	/**
	 * Creates a callout that displays some text, and then positions and
	 * sizes it automatically based on an origin rectangle and the specified
	 * positions, relative to the origin.
	 *
	 * <p>In the following example, a text callout is shown when a
	 * <code>Button</code> is triggered:</p>
	 *
	 * <listing version="3.0">
	 * button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
	 * 
	 * function button_triggeredHandler( event:Event ):void
	 * {
	 *     var button:Button = Button( event.currentTarget );
	 *     TextCallout.show( "Hello World", button );
	 * }</listing>
	 */
	public static function show(text:String, origin:DisplayObject, supportedPositions:Array<String> = null,
		isModal:Bool = true, customCalloutFactory:Void->TextCallout = null, customOverlayFactory:Void->DisplayObject = null):TextCallout
	{
		if (origin.stage == null)
		{
			throw new ArgumentError("TextCallout origin must be added to the stage.");
		}
		var factory:Void->TextCallout = customCalloutFactory;
		if (factory == null)
		{
			factory = calloutFactory;
			if (factory == null)
			{
				factory = defaultCalloutFactory;
			}
		}
		var callout:TextCallout = factory();
		callout.text = text;
		callout.supportedPositions = supportedPositions;
		callout.origin = origin;
		var overlayFactory:Void->DisplayObject = customOverlayFactory;
		if (overlayFactory == null)
		{
			overlayFactory = Callout.calloutOverlayFactory;
			if (overlayFactory == null)
			{
				overlayFactory = PopUpManager.defaultOverlayFactory;
			}
		}
		PopUpManager.addPopUp(callout, isModal, false, overlayFactory);
		callout.validate();
		return callout;
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.isQuickHitAreaEnabled = true;
		if (this._fontStylesSet == null)
		{
			this._fontStylesSet = new FontStylesSet();
			this._fontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
	}
	
	/**
	 * The text renderer.
	 *
	 * @see #createTextRenderer()
	 * @see #textRendererFactory
	 */
	private var textRenderer:ITextRenderer;

	/**
	 * The value added to the <code>styleNameList</code> of the text
	 * renderer sub-component. This variable is <code>protected</code> so
	 * that sub-classes can customize the label text renderer style name in
	 * their constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER</code>.
	 *
	 * <p>To customize the text renderer style name without subclassing, see
	 * <code>customTextRendererStyleName</code>.</p>
	 *
	 * @see #style:customTextRendererStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var textRendererStyleName:String = DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER;
	
	/**
	 * The text to display in the callout.
	 */
	public var text(get, set):String;
	private var _text:String;
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		if (this._text == value)
		{
			return value;
		}
		this._text = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._text;
	}
	
	/**
	 * @private
	 */
	public var wordWrap(get, set):Bool;
	private var _wordWrap:Bool = true;
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
		return this._wordWrap;
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
		if (value != null)
		{
			value.removeEventListener(Event.CHANGE, changeHandler);
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
		if (value != null)
		{
			value.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._fontStylesSet.disabledFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * A function used to instantiate the callout's text renderer
	 * sub-component. By default, the callout will use the global text
	 * renderer factory, <code>FeathersControl.defaultTextRendererFactory()</code>,
	 * to create the text renderer. The text renderer must be an instance of
	 * <code>ITextRenderer</code>. This factory can be used to change
	 * properties on the text renderer when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to style the text renderer.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, a custom text renderer factory is passed
	 * to the callout:</p>
	 *
	 * <listing version="3.0">
	 * callout.textRendererFactory = function():ITextRenderer
	 * {
	 *     return new TextFieldTextRenderer();
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var textRendererFactory(get, set):Void->ITextRenderer;
	private var _textRendererFactory:Void->ITextRenderer;
	private function get_textRendererFactory():Void->ITextRenderer { return this._textRendererFactory; }
	private function set_textRendererFactory(value:Void->ITextRenderer):Void->ITextRenderer
	{
		if (this._textRendererFactory == value)
		{
			return value;
		}
		this._textRendererFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._textRendererFactory;
	}
	
	/**
	 * @private
	 */
	public var customTextRendererStyleName(get, set):String;
	private var _customTextRendererStyleName:String;
	private function get_customTextRendererStyleName():String { return this._customTextRendererStyleName; }
	private function set_customTextRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customTextRendererStyleName"))
		{
			return value;
		}
		if (this._customTextRendererStyleName == value)
		{
			return value;
		}
		this._customTextRendererStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customTextRendererStyleName;
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		if (TextCallout.globalStyleProvider != null)
		{
			return TextCallout.globalStyleProvider;
		}
		return Callout.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
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
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var textRendererInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		
		if (textRendererInvalid)
		{
			this.createTextRenderer();
		}
		
		if (textRendererInvalid || dataInvalid || stateInvalid)
		{
			this.refreshTextRendererData();
		}
		
		if (textRendererInvalid || stylesInvalid)
		{
			this.refreshTextRendererStyles();
		}
		super.draw();
	}
	
	/**
	 * Creates and adds the <code>textRenderer</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #textRenderer
	 * @see #textRendererFactory
	 * @see #style:customTextRendererStyleName
	 */
	private function createTextRenderer():Void
	{
		if (this.textRenderer != null)
		{
			this.removeChild(cast this.textRenderer, true);
			this.textRenderer = null;
		}
		
		var factory:Void->ITextRenderer = this._textRendererFactory != null ? this._textRendererFactory : FeathersControl.defaultTextRendererFactory;
		this.textRenderer = factory();
		var textRendererStyleName:String = this._customTextRendererStyleName != null ? this._customTextRendererStyleName : this.textRendererStyleName;
		this.textRenderer.styleNameList.add(textRendererStyleName);
		this.content = cast this.textRenderer;
	}
	
	/**
	 * @private
	 */
	private function refreshTextRendererData():Void
	{
		this.textRenderer.text = this._text;
		this.textRenderer.visible = this._text != null && this._text.length != 0;
	}

	/**
	 * @private
	 */
	private function refreshTextRendererStyles():Void
	{
		this.textRenderer.wordWrap = this._wordWrap;
		this.textRenderer.fontStyles = this._fontStylesSet;
	}

	/**
	 * @private
	 */
	override function callout_enterFrameHandler(event:EnterFrameEvent):Void
	{
		//wait for validation
		if (this.isCreated)
		{
			this.positionRelativeToOrigin();
		}
	}

	/**
	 * @private
	 */
	private function fontStyles_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
}