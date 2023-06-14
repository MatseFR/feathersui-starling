/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;
import feathers.starling.controls.text.ITextEditorViewPort;
import feathers.starling.controls.text.TextFieldTextEditorViewPort;
import feathers.starling.core.FeathersControl;
import feathers.starling.core.IAdvancedNativeFocusOwner;
import feathers.starling.core.IFeathersControl;
import feathers.starling.core.IMeasureDisplayObject;
import feathers.starling.core.INativeFocusOwner;
import feathers.starling.core.IStateContext;
import feathers.starling.core.IStateObserver;
import feathers.starling.core.ITextRenderer;
import feathers.starling.core.PopUpManager;
import feathers.starling.core.PropertyProxy;
import feathers.starling.events.FeathersEventType;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.controls.TextCallout;
import feathers.starling.controls.TextInputState;
import feathers.starling.text.FontStylesSet;
import feathers.starling.utils.type.Property;
import feathers.starling.utils.type.SafeCast;
import openfl.errors.RangeError;
import openfl.events.KeyboardEvent;
import openfl.geom.Point;
import openfl.ui.Mouse;
import openfl.ui.MouseCursor;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.text.TextFormat;
import starling.utils.Pool;

/**
 * A text entry control that allows users to enter and edit multiple lines
 * of uniformly-formatted text with the ability to scroll.
 *
 * <p>The following example sets the text in a text area, selects the text,
 * and listens for when the text value changes:</p>
 *
 * <listing version="3.0">
 * var textArea:TextArea = new TextArea();
 * textArea.text = "Hello\nWorld"; //it's multiline!
 * textArea.selectRange( 0, textArea.text.length );
 * textArea.addEventListener( Event.CHANGE, textArea_changeHandler );
 * this.addChild( textArea );</listing>
 *
 * @see ../../../help/text-area.html How to use the Feathers TextArea component
 * @see feathers.controls.TextInput
 *
 * @productversion Feathers 1.1.0
 */
class TextArea extends Scroller implements IAdvancedNativeFocusOwner implements IStateContext
{
	/**
	 * The default value added to the <code>styleNameList</code> of the text
	 * editor.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR:String = "feathers-text-area-text-editor";

	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * prompt text renderer.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_PROMPT:String = "feathers-text-input-prompt";

	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * error callout.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT:String = "feathers-text-area-error-callout";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY:String = "errorCalloutFactory";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_PROMPT_FACTORY:String = "promptFactory";

	/**
	 * The default <code>IStyleProvider</code> for all <code>TextArea</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	private static function defaultTextCalloutFactory():TextCallout
	{
		return new TextCallout();
	}
	
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
		if (this._promptFontStylesSet == null)
		{
			this._promptFontStylesSet = new FontStylesSet();
			this._promptFontStylesSet.addEventListener(Event.CHANGE, fontStyles_changeHandler);
		}
		this._measureViewPort = false;
		this.addEventListener(TouchEvent.TOUCH, textArea_touchHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, textArea_removedFromStageHandler);
	}
	
	/**
	 * @private
	 */
	private var textEditorViewPort:ITextEditorViewPort;

	/**
	 * The <code>TextCallout</code> that displays the value of the
	 * <code>errorString</code> property. The value may be <code>null</code>
	 * if there is no current error string or if the text area doesn't have
	 * focus.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var callout:TextCallout;

	/**
	 * The prompt text renderer sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var promptTextRenderer:ITextRenderer;

	/**
	 * The value added to the <code>styleNameList</code> of the text editor.
	 * This variable is <code>protected</code> so that sub-classes can
	 * customize the text editor style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR</code>.
	 *
	 * <p>To customize the text editor style name without subclassing, see
	 * <code>customTextEditorStyleName</code>.</p>
	 *
	 * @see #style:customTextEditorStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var textEditorStyleName:String = DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR;

	/**
	 * The value added to the <code>styleNameList</code> of the prompt text
	 * renderer. This variable is <code>protected</code> so that sub-classes
	 * can customize the prompt text renderer style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_PROMPT</code>.
	 *
	 * <p>To customize the prompt text renderer style name without
	 * subclassing, see <code>customPromptStyleName</code>.</p>
	 *
	 * @see #style:customPromptStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var promptStyleName:String = DEFAULT_CHILD_STYLE_NAME_PROMPT;
	
	/**
	 * The value added to the <code>styleNameList</code> of the error
	 * callout. This variable is <code>protected</code> so that sub-classes
	 * can customize the error callout text renderer style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT</code>.
	 *
	 * <p>To customize the error callout style name without subclassing, see
	 * <code>customErrorCalloutStyleName</code>.</p>
	 *
	 * @see #style:customErrorCalloutStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var errorCalloutStyleName:String = DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT;

	/**
	 * @private
	 */
	private var _textEditorHasFocus:Bool = false;
	
	/**
	 * A text editor may be an <code>INativeFocusOwner</code>, so we need to
	 * return the value of its <code>nativeFocus</code> property. If not,
	 * then we return <code>null</code>.
	 *
	 * @see feathers.core.INativeFocusOwner
	 */
	public var nativeFocus(get, never):Dynamic;
	private function get_nativeFocus():Dynamic
	{
		if (Std.isOfType(this.textEditorViewPort, INativeFocusOwner))
		{
			return cast(this.textEditorViewPort, INativeFocusOwner).nativeFocus;
		}
		return null;
	}
	
	/**
	 * @private
	 */
	private var _isWaitingToSetFocus:Bool = false;

	/**
	 * @private
	 */
	private var _pendingSelectionBeginIndex:Int = -1;

	/**
	 * @private
	 */
	private var _pendingSelectionEndIndex:Int = -1;

	/**
	 * @private
	 */
	private var _textAreaTouchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _oldMouseCursor:String = null;

	/**
	 * @private
	 */
	private var _ignoreTextChanges:Bool = false;

	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return TextArea.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	override function get_isFocusEnabled():Bool 
	{
		if (this._isEditable)
		{
			//the behavior is different when editable.
			return this._isEnabled && this._isFocusEnabled;
		}
		return super.get_isFocusEnabled();
	}
	
	/**
	 * When the <code>FocusManager</code> isn't enabled, <code>hasFocus</code>
	 * can be used instead of <code>FocusManager.focus == textArea</code>
	 * to determine if the text area has focus.
	 */
	public var hasFocus(get, never):Bool;
	private function get_hasFocus():Bool
	{
		if (this._focusManager == null)
		{
			return this._textEditorHasFocus;
		}
		return this._hasFocus;
	}
	
	/**
	 * @private
	 */
	override function set_isEnabled(value:Bool):Bool 
	{
		super.set_isEnabled(value);
		this.refreshState();
		return value;
	}
	
	/**
	 * The current state of the text area.
	 *
	 * @see feathers.controls.TextInputState
	 * @see #event:stateChange feathers.events.FeathersEventType.STATE_CHANGE
	 */
	public var currentState(get, never):String;
	private var _currentState:String = TextInputState.ENABLED;
	private function get_currentState():String { return this._currentState; }
	
	/**
	 * The text displayed by the text area. The text area dispatches
	 * <code>Event.CHANGE</code> when the value of the <code>text</code>
	 * property changes for any reason.
	 *
	 * <p>In the following example, the text area's text is updated:</p>
	 *
	 * <listing version="3.0">
	 * textArea.text = "Hello World";</listing>
	 *
	 * @see #event:change
	 *
	 * @default ""
	 */
	public var text(get, set):String;
	private var _text:String = "";
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		if (value == null)
		{
			//don't allow null or undefined
			value = "";
		}
		if (this._text == value)
		{
			return value;
		}
		this._text = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.dispatchEventWith(Event.CHANGE);
		return this._text;
	}
	
	/**
	 * The prompt, hint, or description text displayed by the text area when
	 * the value of its text is empty.
	 *
	 * <p>In the following example, the text area's prompt is updated:</p>
	 *
	 * <listing version="3.0">
	 * textArea.prompt = "User Name";</listing>
	 *
	 * @default null
	 */
	public var prompt(get, set):String;
	private var _prompt:String;
	private function get_prompt():String { return this._prompt; }
	private function set_prompt(value:String):String
	{
		if (this._prompt == value)
		{
			return value;
		}
		this._prompt = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._prompt;
	}
	
	/**
	 * The maximum number of characters that may be entered.
	 *
	 * <p>In the following example, the text area's maximum characters is
	 * specified:</p>
	 *
	 * <listing version="3.0">
	 * textArea.maxChars = 10;</listing>
	 *
	 * @default 0
	 */
	public var maxChars(get, set):Int;
	private var _maxChars:Int = 0;
	private function get_maxChars():Int { return this._maxChars; }
	private function set_maxChars(value:Int):Int
	{
		if (this._maxChars == value)
		{
			return value;
		}
		this._maxChars = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._maxChars;
	}
	
	/**
	 * Limits the set of characters that may be entered.
	 *
	 * <p>In the following example, the text area's allowed characters are
	 * restricted:</p>
	 *
	 * <listing version="3.0">
	 * textArea.restrict = "0-9;</listing>
	 *
	 * @default null
	 */
	public var restrict(get, set):String;
	@:native("_restrict1")
	private var _restrict:String;
	private function get_restrict():String { return this._restrict; }
	private function set_restrict(value:String):String
	{
		if (this._restrict == value)
		{
			return value;
		}
		this._restrict = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._restrict;
	}
	
	/**
	 * Determines if the text area is editable. If the text area is not
	 * editable, it will still appear enabled.
	 *
	 * <p>In the following example, the text area is not editable:</p>
	 *
	 * <listing version="3.0">
	 * textArea.isEditable = false;</listing>
	 *
	 * @default true
	 */
	public var isEditable(get, set):Bool;
	private var _isEditable:Bool = true;
	private function get_isEditable():Bool { return this._isEditable; }
	private function set_isEditable(value:Bool):Bool
	{
		if (this._isEditable == value)
		{
			return value;
		}
		this._isEditable = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._isEditable;
	}
	
	/**
	 * Error text to display in a <code>Callout</code> when the text area
	 * has focus. When this value is not <code>null</code> the text area's
	 * state is changed to <code>TextInputState.ERROR</code>.
	 *
	 * An empty string will change the background, but no
	 * <code>Callout</code> will appear on focus.
	 *
	 * To clear an error, the <code>errorString</code> property must be set
	 * to <code>null</code>
	 *
	 * <p>The following example displays an error string:</p>
	 *
	 * <listing version="3.0">
	 * textArea.errorString = "Something is wrong";</listing>
	 *
	 * @default null
	 *
	 * @see #currentState
	 */
	public var errorString(get, set):String;
	private var _errorString:String = null;
	private function get_errorString():String { return this._errorString; }
	private function set_errorString(value:String):String
	{
		if (this._errorString == value)
		{
			return value;
		}
		this._errorString = value;
		this.refreshState();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._errorString;
	}
	
	/**
	 * @private
	 */
	private var _stateToSkin:Map<String, DisplayObject> = new Map<String, DisplayObject>();
	
	/**
	 * @private
	 */
	override function get_backgroundDisabledSkin():DisplayObject
	{
		return this.getSkinForState(TextInputState.DISABLED);
	}

	/**
	 * @private
	 */
	override function set_backgroundDisabledSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(TextInputState.DISABLED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var backgroundFocusedSkin(get, set):DisplayObject;
	private function get_backgroundFocusedSkin():DisplayObject { return this.getSkinForState(TextInputState.FOCUSED); }
	private function set_backgroundFocusedSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(TextInputState.FOCUSED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var backgroundErrorSkin(get, set):DisplayObject;
	private function get_backgroundErrorSkin():DisplayObject { return this.getSkinForState(TextInputState.ERROR); }
	private function set_backgroundErrorSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(TextInputState.ERROR, value);
		return value;
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
	 * A function used to instantiate the text editor view port. If
	 * <code>null</code>, a <code>TextFieldTextEditorViewPort</code> will
	 * be instantiated. The text editor must be an instance of
	 * <code>ITextEditorViewPort</code>. This factory can be used to change
	 * properties on the text editor view port when it is first created. For
	 * instance, if you are skinning Feathers components without a theme,
	 * you might use this factory to set styles on the text editor view
	 * port.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextEditorViewPort</pre>
	 *
	 * <p>In the following example, a custom text editor factory is passed
	 * to the text area:</p>
	 *
	 * <listing version="3.0">
	 * textArea.textEditorFactory = function():ITextEditorViewPort
	 * {
	 *     return new TextFieldTextEditorViewPort();
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.text.ITextEditorViewPort
	 */
	public var textEditorFactory(get, set):Void->ITextEditorViewPort;
	private var _textEditorFactory:Void->ITextEditorViewPort;
	private function get_textEditorFactory():Void->ITextEditorViewPort { return this._textEditorFactory; }
	private function set_textEditorFactory(value:Void->ITextEditorViewPort):Void->ITextEditorViewPort
	{
		if (this._textEditorFactory == value)
		{
			return value;
		}
		this._textEditorFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_EDITOR);
		return this._textEditorFactory;
	}
	
	/**
	 * @private
	 */
	public var customTextEditorStyleName(get, set):String;
	private var _customTextEditorStyleName:String;
	private function get_customTextEditorStyleName():String { return this._customTextEditorStyleName; }
	private function set_customTextEditorStyleName(value:String):String
	{
		if (this.processStyleRestriction("customTextEditorStyleName"))
		{
			return value;
		}
		if (this._customTextEditorStyleName == value)
		{
			return value;
		}
		this._customTextEditorStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customTextEditorStyleName;
	}
	
	/**
	 * An object that stores properties for the text area's text editor
	 * sub-component, and the properties will be passed down to the
	 * text editor when the text area validates. The available properties
	 * depend on which <code>ITextEditorViewPort</code> implementation is
	 * returned by <code>textEditorFactory</code>. Refer to
	 * <a href="text/ITextEditorViewPort.html"><code>feathers.controls.text.ITextEditorViewPort</code></a>
	 * for a list of available text editor implementations for text area.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>textEditorFactory</code> function
	 * instead of using <code>textEditorProperties</code> will result in
	 * better performance.</p>
	 *
	 * <p>In the following example, the text input's text editor properties
	 * are specified (this example assumes that the text editor is a
	 * <code>TextFieldTextEditorViewPort</code>):</p>
	 *
	 * <listing version="3.0">
	 * textArea.textEditorProperties.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333);
	 * textArea.textEditorProperties.embedFonts = true;</listing>
	 *
	 * @default null
	 *
	 * @see #textEditorFactory
	 * @see feathers.controls.text.ITextEditorViewPort
	 */
	public var textEditorProperties(get, set):PropertyProxy;
	private var _textEditorProperties:PropertyProxy;
	private function get_textEditorProperties():PropertyProxy 
	{
		if (this._textEditorProperties == null)
		{
			this._textEditorProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._textEditorProperties;
	}
	
	private function set_textEditorProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._textEditorProperties == value)
		{
			return value;
		}
		if (this._textEditorProperties != null)
		{
			this._textEditorProperties.dispose();
		}
		this._textEditorProperties = value;
		if (this._textEditorProperties != null)
		{
			this._textEditorProperties.addOnChangeCallback(childProperties_onChange);
		}
		return this._textEditorProperties;
	}
	
	/**
	 * @private
	 */
	private var _promptFontStylesSet:FontStylesSet;
	
	/**
	 * @private
	 */
	public var promptFontStyles(get, set):TextFormat;
	private function get_promptFontStyles():TextFormat { return this._promptFontStylesSet.format; }
	private function set_promptFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("promptFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("promptFontStyles");
		}
		
		var oldValue:TextFormat = this._promptFontStylesSet.format;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._promptFontStylesSet.format = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * @private
	 */
	public var promptDisabledFontStyles(get, set):TextFormat;
	private function get_promptDisabledFontStyles():TextFormat { return this._promptFontStylesSet.disabledFormat; }
	private function set_promptDisabledFontStyles(value:TextFormat):TextFormat
	{
		if (this.processStyleRestriction("promptDisabledFontStyles"))
		{
			return value;
		}
		
		function changeHandler(event:Event):Void
		{
			processStyleRestriction("promptDisabledFontStyles");
		}
		
		var oldValue:TextFormat = this._promptFontStylesSet.disabledFormat;
		if (oldValue != null)
		{
			oldValue.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._promptFontStylesSet.disabledFormat = value;
		if (value != null)
		{
			value.addEventListener(Event.CHANGE, changeHandler);
		}
		return value;
	}
	
	/**
	 * A function used to instantiate the prompt text renderer. If null,
	 * <code>FeathersControl.defaultTextRendererFactory</code> is used
	 * instead. The prompt text renderer must be an instance of
	 * <code>ITextRenderer</code>. This factory can be used to change
	 * properties on the prompt when it is first created. For instance, if
	 * you are skinning Feathers components without a theme, you might use
	 * this factory to set styles on the prompt.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>If the <code>prompt</code> property is <code>null</code>, the
	 * prompt text renderer will not be created.</p>
	 *
	 * <p>In the following example, a custom prompt factory is passed to the
	 * text input:</p>
	 *
	 * <listing version="3.0">
	 * input.promptFactory = function():ITextRenderer
	 * {
	 *     return new TextFieldTextRenderer();
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #prompt
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var promptFactory(get, set):Void->ITextRenderer;
	private var _promptFactory:Void->ITextRenderer;
	private function get_promptFactory():Void->ITextRenderer { return this._promptFactory; }
	private function set_promptFactory(value:Void->ITextRenderer):Void->ITextRenderer
	{
		if (this._promptFactory == value)
		{
			return value;
		}
		this._promptFactory = value;
		this.invalidate(INVALIDATION_FLAG_PROMPT_FACTORY);
		return this._promptFactory;
	}
	
	/**
	 * @private
	 */
	public var customPromptStyleName(get, set):String;
	private var _customPromptStyleName:String;
	private function get_customPromptStyleName():String { return this._customPromptStyleName; }
	private function set_customPromptStyleName(value:String):String
	{
		if (this.processStyleRestriction("customPromptStyleName"))
		{
			return value;
		}
		if (this._customPromptStyleName == value)
		{
			return value;
		}
		this._customPromptStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customPromptStyleName;
	}
	
	/**
	 * A function used to instantiate the error text callout. If null,
	 * <code>new TextCallout()</code> is used instead.
	 * The error text callout must be an instance of
	 * <code>TextCallout</code>. This factory can be used to change
	 * properties on the callout when it is first created. For instance, if
	 * you are skinning Feathers components without a theme, you might use
	 * this factory to set styles on the callout.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():TextCallout</pre>
	 *
	 * <p>In the following example, a custom error callout factory is passed to the
	 * text input:</p>
	 *
	 * <listing version="3.0">
	 * input.errorCalloutFactory = function():TextCallout
	 * {
	 *     return new TextCallout();
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #errorString
	 * @see feathers.controls.TextCallout
	 */
	public var errorCalloutFactory(get, set):Void->TextCallout;
	private var _errorCalloutFactory:Void->TextCallout;
	private function get_errorCalloutFactory():Void->TextCallout { return this._errorCalloutFactory; }
	private function set_errorCalloutFactory(value:Void->TextCallout):Void->TextCallout
	{
		if (this._errorCalloutFactory == value)
		{
			return value;
		}
		this._errorCalloutFactory = value;
		this.invalidate(INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY);
		return this._errorCalloutFactory;
	}
	
	/**
	 * @private
	 */
	public var customErrorCalloutStyleName(get, set):String;
	private var _customErrorCalloutStyleName:String;
	private function get_customErrorCalloutStyleName():String { return this._customErrorCalloutStyleName; }
	private function set_customErrorCalloutStyleName(value:String):String
	{
		if (this.processStyleRestriction("customErrorCalloutStyleName"))
		{
			return value;
		}
		if (this._customErrorCalloutStyleName == value)
		{
			return value;
		}
		this._customErrorCalloutStyleName = value;
		this.invalidate(INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY);
		return this._customErrorCalloutStyleName;
	}
	
	/**
	 * @private
	 */
	public var innerPadding(get, set):Float;
	private function get_innerPadding():Float { return this._innerPaddingTop; }
	private function set_innerPadding(value:Float):Float
	{
		this.innerPaddingTop = value;
		this.innerPaddingRight = value;
		this.innerPaddingBottom = value;
		return this.innerPaddingLeft = value;
	}
	
	/**
	 * @private
	 */
	public var innerPaddingTop(get, set):Float;
	private var _innerPaddingTop:Float = 0;
	private function get_innerPaddingTop():Float { return this._innerPaddingTop; }
	private function set_innerPaddingTop(value:Float):Float
	{
		if (this.processStyleRestriction("innerPaddingTop"))
		{
			return value;
		}
		if (this._innerPaddingTop == value)
		{
			return value;
		}
		this._innerPaddingTop = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._innerPaddingTop;
	}
	
	/**
	 * @private
	 */
	public var innerPaddingRight(get, set):Float;
	private var _innerPaddingRight:Float = 0;
	private function get_innerPaddingRight():Float { return this._innerPaddingRight; }
	private function set_innerPaddingRight(value:Float):Float
	{
		if (this.processStyleRestriction("innerPaddingRight"))
		{
			return value;
		}
		if (this._innerPaddingRight == value)
		{
			return value;
		}
		this._innerPaddingRight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._innerPaddingRight;
	}
	
	/**
	 * @private
	 */
	public var innerPaddingBottom(get, set):Float;
	private var _innerPaddingBottom:Float = 0;
	private function get_innerPaddingBottom():Float { return this._innerPaddingBottom; }
	private function set_innerPaddingBottom(value:Float):Float
	{
		if (this.processStyleRestriction("innerPaddingBottom"))
		{
			return value;
		}
		if (this._innerPaddingBottom == value)
		{
			return value;
		}
		this._innerPaddingBottom = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._innerPaddingBottom;
	}
	
	/**
	 * @private
	 */
	public var innerPaddingLeft(get, set):Float;
	private var _innerPaddingLeft:Float = 0;
	private function get_innerPaddingLeft():Float { return this._innerPaddingLeft; }
	private function set_innerPaddingLeft(value:Float):Float
	{
		if (this.processStyleRestriction("innerPaddingLeft"))
		{
			return value;
		}
		if (this._innerPaddingLeft == value)
		{
			return value;
		}
		this._innerPaddingLeft = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._innerPaddingLeft;
	}
	
	/**
	 * @copy feathers.core.ITextEditor#selectionBeginIndex
	 */
	public var selectionBeginIndex(get, never):Int;
	private function get_selectionBeginIndex():Int
	{
		if (this._pendingSelectionBeginIndex >= 0)
		{
			return this._pendingSelectionBeginIndex;
		}
		if (this.textEditorViewPort != null)
		{
			return this.textEditorViewPort.selectionBeginIndex;
		}
		return 0;
	}
	
	/**
	 * @copy feathers.core.ITextEditor#selectionEndIndex
	 */
	public var selectionEndIndex(get, never):Int;
	private function get_selectionEndIndex():Int
	{
		if (this._pendingSelectionEndIndex >= 0)
		{
			return this._pendingSelectionEndIndex;
		}
		if (this.textEditorViewPort != null)
		{
			return this.textEditorViewPort.selectionEndIndex;
		}
		return 0;
	}
	
	/**
	 * Focuses the text area control so that it may be edited.
	 */
	public function setFocus():Void
	{
		if (this._textEditorHasFocus)
		{
			return;
		}
		if (this.textEditorViewPort != null)
		{
			this._isWaitingToSetFocus = false;
			this.textEditorViewPort.setFocus();
		}
		else
		{
			this._isWaitingToSetFocus = true;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		}
	}
	
	/**
	 * Manually removes focus from the text area control.
	 */
	public function clearFocus():Void
	{
		this._isWaitingToSetFocus = false;
		if (this.textEditorViewPort == null || !this._textEditorHasFocus)
		{
			return;
		}
		this.textEditorViewPort.clearFocus();
	}
	
	/**
	 * Sets the range of selected characters. If both values are the same,
	 * or the end index is <code>-1</code>, the text insertion position is
	 * changed and nothing is selected.
	 */
	public function selectRange(beginIndex:Int, endIndex:Int = -1):Void
	{
		if (endIndex < 0)
		{
			endIndex = beginIndex;
		}
		if (beginIndex < 0)
		{
			throw new RangeError("Expected begin index greater than or equal to 0. Received " + beginIndex + ".");
		}
		if (endIndex > this._text.length)
		{
			throw new RangeError("Expected begin index less than " + this._text.length + ". Received " + endIndex + ".");
		}
		
		//if it's invalid, we need to wait until validation before changing
		//the selection
		if (this.textEditorViewPort != null && (this._isValidating || !this.isInvalid()))
		{
			this._pendingSelectionBeginIndex = -1;
			this._pendingSelectionEndIndex = -1;
			this.textEditorViewPort.selectRange(beginIndex, endIndex);
		}
		else
		{
			this._pendingSelectionBeginIndex = beginIndex;
			this._pendingSelectionEndIndex = endIndex;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		}
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//we don't dispose it if the text area is the parent because it'll
		//already get disposed in super.dispose()
		if (this._stateToSkin != null)
		{
			for (skin in this._stateToSkin)
			{
				if (skin != null && skin.parent != this)
				{
					skin.dispose();
				}
			}
			this._stateToSkin.clear();
			this._stateToSkin = null;
		}
		if (this._fontStylesSet != null)
		{
			this._fontStylesSet.dispose();
			this._fontStylesSet = null;
		}
		if (this._promptFontStylesSet != null)
		{
			this._promptFontStylesSet.dispose();
			this._promptFontStylesSet = null;
		}
		if (this._textEditorProperties != null)
		{
			this._textEditorProperties.dispose();
			this._textEditorProperties = null;
		}
		
		super.dispose();
	}
	
	/**
	 * Gets the font styles to be used to display the text area's text when
	 * the text area's <code>currentState</code> property matches the
	 * specified state value.
	 *
	 * <p>If font styles are not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #setFontStylesForState()
	 * @see #style:fontStyles
	 */
	public function getFontStylesForState(state:String):TextFormat
	{
		if (this._fontStylesSet == null)
		{
			return null;
		}
		return this._fontStylesSet.getFormatForState(state);
	}
	
	/**
	 * Sets the font styles to be used to display the text area's text when
	 * the text area's <code>currentState</code> property matches the
	 * specified state value.
	 *
	 * <p>If font styles are not defined for a specific state, the value of
	 * the <code>fontStyles</code> property will be used instead.</p>
	 *
	 * <p>Note: if the text editor has been customized with advanced font
	 * formatting, it may override the values specified with
	 * <code>setFontStylesForState()</code> and properties like
	 * <code>fontStyles</code> and <code>disabledFontStyles</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #style:fontStyles
	 */
	public function setFontStylesForState(state:String, format:TextFormat):Void
	{
		var key:String = "setFontStylesForState--" + state;
		if (this.processStyleRestriction(key))
		{
			return;
		}
		function changeHandler(event:Event):Void
		{
			processStyleRestriction(key);
		}
		var oldFormat:TextFormat = this._fontStylesSet.getFormatForState(state);
		if (oldFormat != null)
		{
			oldFormat.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._fontStylesSet.setFormatForState(state, format);
		if (format != null)
		{
			format.addEventListener(Event.CHANGE, changeHandler);
		}
	}
	
	/**
	 * Gets the font styles to be used to display the text area's prompt
	 * when the text area's <code>currentState</code> property matches the
	 * specified state value.
	 *
	 * <p>If prompt font styles are not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #setPromptFontStylesForState()
	 * @see #promptFontStyles
	 */
	public function getPromptFontStylesForState(state:String):TextFormat
	{
		if (this._promptFontStylesSet == null)
		{
			return null;
		}
		return this._promptFontStylesSet.getFormatForState(state);
	}
	
	/**
	 * Sets the font styles to be used to display the text area's prompt
	 * when the text area's <code>currentState</code> property matches the
	 * specified state value.
	 *
	 * <p>If prompt font styles are not defined for a specific state, the
	 * value of the <code>promptFontStyles</code> property will be used instead.</p>
	 *
	 * <p>Note: if the text renderer has been customized with advanced font
	 * formatting, it may override the values specified with
	 * <code>setPromptFontStylesForState()</code> and properties like
	 * <code>promptFontStyles</code> and <code>promptDisabledFontStyles</code>.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 * @see #promptFontStyles
	 */
	public function setPromptFontStylesForState(state:String, format:TextFormat):Void
	{
		var key:String = "setPromptFontStylesForState--" + state;
		if (this.processStyleRestriction(key))
		{
			return;
		}
		function changeHandler(event:Event):Void
		{
			processStyleRestriction(key);
		}
		var oldFormat:TextFormat = this._promptFontStylesSet.getFormatForState(state);
		if (oldFormat != null)
		{
			oldFormat.removeEventListener(Event.CHANGE, changeHandler);
		}
		this._promptFontStylesSet.setFormatForState(state, format);
		if (format != null)
		{
			format.addEventListener(Event.CHANGE, changeHandler);
		}
	}
	
	/**
	 * Gets the skin to be used by the text area when its
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a skin is not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see #setSkinForState()
	 * @see feathers.controls.TextInputState
	 */
	public function getSkinForState(state:String):DisplayObject
	{
		return this._stateToSkin[state];
	}

	/**
	 * Sets the skin to be used by the text area when its
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a skin is not defined for a specific state, the value of the
	 * <code>backgroundSkin</code> property will be used instead.</p>
	 *
	 * @see #backgroundSkin
	 * @see #getSkinForState()
	 * @see feathers.controls.TextInputState
	 */
	public function setSkinForState(state:String, skin:DisplayObject):Void
	{
		var key:String = "setSkinForState--" + state;
		if (this.processStyleRestriction(key))
		{
			if (skin != null)
			{
				skin.dispose();
			}
			return;
		}
		if (skin != null)
		{
			this._stateToSkin[state] = skin;
		}
		else
		{
			this._stateToSkin.remove(state);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var textEditorInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_TEXT_EDITOR);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var promptFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_PROMPT_FACTORY);
		
		if (textEditorInvalid)
		{
			this.createTextEditor();
		}
		
		if (promptFactoryInvalid || (this._prompt != null && this.promptTextRenderer == null))
		{
			this.createPrompt();
		}
		
		if (textEditorInvalid || stylesInvalid)
		{
			this.refreshTextEditorProperties();
		}
		
		if (textEditorInvalid || dataInvalid)
		{
			var oldIgnoreTextChanges:Bool = this._ignoreTextChanges;
			this._ignoreTextChanges = true;
			this.textEditorViewPort.text = this._text;
			this._ignoreTextChanges = oldIgnoreTextChanges;
		}
		
		if (promptFactoryInvalid || stylesInvalid)
		{
			this.refreshPromptProperties();
		}
		
		if (this.promptTextRenderer != null)
		{
			if (promptFactoryInvalid || dataInvalid || stylesInvalid)
			{
				this.promptTextRenderer.visible = this._prompt != null && this._text.length == 0;
			}
			
			if (promptFactoryInvalid || stateInvalid)
			{
				this.promptTextRenderer.isEnabled = this._isEnabled;
			}
		}
		
		if (textEditorInvalid || stateInvalid)
		{
			this.textEditorViewPort.isEnabled = this._isEnabled;
			if (!this._isEnabled && Mouse.supportsNativeCursor && this._oldMouseCursor != null)
			{
				Mouse.cursor = this._oldMouseCursor;
				this._oldMouseCursor = null;
			}
		}
		
		super.draw();
		
		//the state might not change if the text input has focus when
		//the error string changes, so check for styles too!
		if (stateInvalid || stylesInvalid)
		{
			this.refreshErrorCallout();
		}
		
		this.doPendingActions();
	}
	
	/**
	 * Creates and adds the <code>textEditorViewPort</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #textEditorViewPort
	 * @see #textEditorFactory
	 */
	private function createTextEditor():Void
	{
		if (this.textEditorViewPort != null)
		{
			this.textEditorViewPort.removeEventListener(Event.CHANGE, textEditor_changeHandler);
			this.textEditorViewPort.removeEventListener(FeathersEventType.FOCUS_IN, textEditor_focusInHandler);
			this.textEditorViewPort.removeEventListener(FeathersEventType.FOCUS_OUT, textEditor_focusOutHandler);
			this.textEditorViewPort = null;
		}
		
		if (this._textEditorFactory != null)
		{
			this.textEditorViewPort = this._textEditorFactory();
		}
		else
		{
			this.textEditorViewPort = new TextFieldTextEditorViewPort();
		}
		var textEditorStyleName:String = this._customTextEditorStyleName != null ? this._customTextEditorStyleName : this.textEditorStyleName;
		this.textEditorViewPort.styleNameList.add(textEditorStyleName);
		if (Std.isOfType(this.textEditorViewPort, IStateObserver))
		{
			cast(this.textEditorViewPort, IStateObserver).stateContext = this;
		}
		this.textEditorViewPort.addEventListener(Event.CHANGE, textEditor_changeHandler);
		this.textEditorViewPort.addEventListener(FeathersEventType.FOCUS_IN, textEditor_focusInHandler);
		this.textEditorViewPort.addEventListener(FeathersEventType.FOCUS_OUT, textEditor_focusOutHandler);
		
		var oldViewPort:ITextEditorViewPort = SafeCast.safe_cast(this._viewPort, ITextEditorViewPort);
		this.viewPort = this.textEditorViewPort;
		if (oldViewPort != null)
		{
			//the view port setter won't do this
			oldViewPort.dispose();
		}
	}
	
	/**
	 * @private
	 */
	private function createPrompt():Void
	{
		if (this.promptTextRenderer != null)
		{
			this.removeChild(cast this.promptTextRenderer, true);
			this.promptTextRenderer = null;
		}
		
		if (this._prompt == null)
		{
			return;
		}
		
		var factory:Void->ITextRenderer = this._promptFactory != null ? this._promptFactory : FeathersControl.defaultTextRendererFactory;
		this.promptTextRenderer = factory();
		var promptStyleName:String = this._customPromptStyleName != null ? this._customPromptStyleName : this.promptStyleName;
		this.promptTextRenderer.styleNameList.add(promptStyleName);
		this.addChild(cast this.promptTextRenderer);
	}
	
	/**
	 * @private
	 */
	private function createErrorCallout():Void
	{
		if (this.callout != null)
		{
			this.callout.removeFromParent(true);
			this.callout = null;
		}
		
		if (this._errorString == null)
		{
			return;
		}
		var factory:Void->TextCallout = this._errorCalloutFactory != null ? this._errorCalloutFactory : defaultTextCalloutFactory;
		this.callout = factory();
		var errorCalloutStyleName:String = this._customErrorCalloutStyleName != null ? this._customErrorCalloutStyleName : this.errorCalloutStyleName;
		this.callout.styleNameList.add(errorCalloutStyleName);
		this.callout.closeOnKeys = null;
		this.callout.closeOnTouchBeganOutside = false;
		this.callout.closeOnTouchEndedOutside = false;
		this.callout.touchable = false;
		this.callout.origin = this;
		PopUpManager.addPopUp(this.callout, false, false);
	}
	
	/**
	 * @private
	 */
	private function changeState(state:String):Void
	{
		if (this._currentState == state)
		{
			return;
		}
		this._currentState = state;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
		this.dispatchEventWith(FeathersEventType.STATE_CHANGE);
	}
	
	/**
	 * @private
	 */
	private function doPendingActions():Void
	{
		if (this._isWaitingToSetFocus || (this._focusManager != null && this._focusManager.focus == this))
		{
			this._isWaitingToSetFocus = false;
			if (!this._textEditorHasFocus)
			{
				this.textEditorViewPort.setFocus();
			}
		}
		if (this._pendingSelectionBeginIndex >= 0)
		{
			var beginIndex:Int = this._pendingSelectionBeginIndex;
			var endIndex:Int = this._pendingSelectionEndIndex;
			this._pendingSelectionBeginIndex = -1;
			this._pendingSelectionEndIndex = -1;
			this.selectRange(beginIndex, endIndex);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshTextEditorProperties():Void
	{
		this.textEditorViewPort.fontStyles = this._fontStylesSet;
		this.textEditorViewPort.maxChars = this._maxChars;
		this.textEditorViewPort.restrict = this._restrict;
		this.textEditorViewPort.isEditable = this._isEditable;
		this.textEditorViewPort.paddingTop = this._innerPaddingTop;
		this.textEditorViewPort.paddingRight = this._innerPaddingRight;
		this.textEditorViewPort.paddingBottom = this._innerPaddingBottom;
		this.textEditorViewPort.paddingLeft = this._innerPaddingLeft;
		
		if (this._textEditorProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._textEditorProperties)
			{
				propertyValue = this._textEditorProperties[propertyName];
				Property.write(this.textEditorViewPort, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshPromptProperties():Void
	{
		if (this.promptTextRenderer == null)
		{
			return;
		}
		this.promptTextRenderer.text = this._prompt;
		this.promptTextRenderer.fontStyles = this._promptFontStylesSet;
	}
	
	/**
	 * @private
	 */
	override function refreshBackgroundSkin():Void
	{
		var oldSkin:DisplayObject = this.currentBackgroundSkin;
		this.currentBackgroundSkin = this.getCurrentBackgroundSkin();
		if (oldSkin != this.currentBackgroundSkin)
		{
			if (oldSkin != null)
			{
				if (Std.isOfType(oldSkin, IStateObserver))
				{
					cast(oldSkin, IStateObserver).stateContext = null;
				}
				this.removeChild(oldSkin, false);
			}
			if (this.currentBackgroundSkin != null)
			{
				if (Std.isOfType(this.currentBackgroundSkin, IStateObserver))
				{
					cast(this.currentBackgroundSkin, IStateObserver).stateContext = this;
				}
				this.addChildAt(this.currentBackgroundSkin, 0);
				if  (Std.isOfType(this.currentBackgroundSkin, IFeathersControl))
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
				}
				else
				{
					this._explicitBackgroundWidth = this.currentBackgroundSkin.width;
					this._explicitBackgroundHeight = this.currentBackgroundSkin.height;
					this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
					this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	override function getCurrentBackgroundSkin():DisplayObject
	{
		var result:DisplayObject = this._stateToSkin[this._currentState];
		if (result != null)
		{
			return result;
		}
		return this._backgroundSkin;
	}
	
	/**
	 * @private
	 */
	private function refreshState():Void
	{
		if (this._isEnabled)
		{
			if (this._textEditorHasFocus)
			{
				this.changeState(TextInputState.FOCUSED);
			}
			else if (this._errorString != null)
			{
				this.changeState(TextInputState.ERROR);
			}
			else
			{
				this.changeState(TextInputState.ENABLED);
			}
		}
		else
		{
			this.changeState(TextInputState.DISABLED);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshErrorCallout():Void
	{
		if (this._textEditorHasFocus && this.callout == null &&
			this._errorString != null && this._errorString.length != 0)
		{
			this.createErrorCallout();
		}
		else if (this.callout != null &&
			(!this._textEditorHasFocus || this._errorString == null || this._errorString.length == 0))
		{
			this.callout.removeFromParent(true);
			this.callout = null;
		}
		if (this.callout != null)
		{
			this.callout.text = this._errorString;
		}
	}
	
	/**
	 * @private
	 */
	override function layoutChildren():Void
	{
		super.layoutChildren();
		
		if (this.promptTextRenderer != null)
		{
			this.promptTextRenderer.x = this._leftViewPortOffset + this._innerPaddingLeft;
			this.promptTextRenderer.y = this._topViewPortOffset + this._innerPaddingTop;
			this.promptTextRenderer.width = this.actualWidth - this._leftViewPortOffset - this._rightViewPortOffset - this._innerPaddingLeft - this._innerPaddingRight;
			this.promptTextRenderer.height = this.actualHeight - this._topViewPortOffset - this._bottomViewPortOffset - this._innerPaddingTop - this._innerPaddingBottom;
		}
	}
	
	/**
	 * @private
	 */
	private function setFocusOnTextEditorWithTouch(touch:Touch):Void
	{
		if (!this.isFocusEnabled)
		{
			return;
		}
		var point:Point = Pool.getPoint();
		touch.getLocation(this.stage, point);
		var isInBounds:Bool = this.contains(this.stage.hitTest(point));
		if (!this._textEditorHasFocus && isInBounds)
		{
			this.globalToLocal(point, point);
			point.x -= this._paddingLeft;
			point.y -= this._paddingTop;
			//we account for the scroll position in the text editor view
			//port, so don't do it here!
			this._isWaitingToSetFocus = false;
			this.textEditorViewPort.setFocus(point);
		}
		Pool.putPoint(point);
	}
	
	/**
	 * @private
	 */
	private function textArea_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._textAreaTouchPointID = -1;
			return;
		}
		
		var horizontalScrollBar:DisplayObject = cast this.horizontalScrollBar;
		var verticalScrollBar:DisplayObject = cast this.verticalScrollBar;
		var touch:Touch;
		if (this._textAreaTouchPointID >= 0)
		{
			touch = event.getTouch(this, TouchPhase.ENDED, this._textAreaTouchPointID);
			if (touch == null || touch.isTouching(verticalScrollBar) || touch.isTouching(horizontalScrollBar))
			{
				return;
			}
			this.removeEventListener(Event.SCROLL, textArea_scrollHandler);
			this._textAreaTouchPointID = -1;
			if (this.textEditorViewPort.setTouchFocusOnEndedPhase)
			{
				this.setFocusOnTextEditorWithTouch(touch);
			}
		}
		else
		{
			touch = event.getTouch(this, TouchPhase.BEGAN);
			if (touch != null)
			{
				if (touch.isTouching(verticalScrollBar) || touch.isTouching(horizontalScrollBar))
				{
					return;
				}
				this._textAreaTouchPointID = touch.id;
				if (!this.textEditorViewPort.setTouchFocusOnEndedPhase)
				{
					this.setFocusOnTextEditorWithTouch(touch);
				}
				this.addEventListener(Event.SCROLL, textArea_scrollHandler);
				return;
			}
			touch = event.getTouch(this, TouchPhase.HOVER);
			if (touch != null)
			{
				if (touch.isTouching(verticalScrollBar) || touch.isTouching(horizontalScrollBar))
				{
					return;
				}
				if (Mouse.supportsNativeCursor && this._oldMouseCursor == null)
				{
					this._oldMouseCursor = Mouse.cursor;
					Mouse.cursor = MouseCursor.IBEAM;
				}
				return;
			}
			//end hover
			if (Mouse.supportsNativeCursor && this._oldMouseCursor != null)
			{
				Mouse.cursor = this._oldMouseCursor;
				this._oldMouseCursor = null;
			}
		}
	}
	
	/**
	 * @private
	 */
	private function textArea_scrollHandler(event:Event):Void
	{
		this.removeEventListener(Event.SCROLL, textArea_scrollHandler);
		this._textAreaTouchPointID = -1;
	}

	/**
	 * @private
	 */
	private function textArea_removedFromStageHandler(event:Event):Void
	{
		if (this._focusManager == null && this._textEditorHasFocus)
		{
			this.clearFocus();
		}
		this._isWaitingToSetFocus = false;
		this._textEditorHasFocus = false;
		this._textAreaTouchPointID = -1;
		this.removeEventListener(Event.SCROLL, textArea_scrollHandler);
		if (Mouse.supportsNativeCursor && this._oldMouseCursor != null)
		{
			Mouse.cursor = this._oldMouseCursor;
			this._oldMouseCursor = null;
		}
	}
	
	/**
	 * @private
	 */
	override function focusInHandler(event:Event):Void
	{
		if (this._focusManager == null)
		{
			return;
		}
		super.focusInHandler(event);
		this.setFocus();
	}

	/**
	 * @private
	 */
	override function focusOutHandler(event:Event):Void
	{
		if (this._focusManager == null)
		{
			return;
		}
		super.focusOutHandler(event);
		this.textEditorViewPort.clearFocus();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
	}
	
	/**
	 * @private
	 */
	override function nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (this._isEditable)
		{
			return;
		}
		super.nativeStage_keyDownHandler(event);
	}

	/**
	 * @private
	 */
	private function textEditor_changeHandler(event:Event):Void
	{
		if (this._ignoreTextChanges)
		{
			return;
		}
		this.text = this.textEditorViewPort.text;
	}
	
	/**
	 * @private
	 */
	private function textEditor_focusInHandler(event:Event):Void
	{
		this._textEditorHasFocus = true;
		this.refreshState();
		this.refreshErrorCallout();
		this._touchPointID = -1;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
		if (this._focusManager != null && this.isFocusEnabled && this._focusManager.focus != this)
		{
			//if setFocus() was called manually, we need to notify the focus
			//manager (unless isFocusEnabled is false).
			//if the focus manager already knows that we have focus, it will
			//simply return without doing anything.
			this._focusManager.focus = this;
		}
		else if (this._focusManager == null)
		{
			this.dispatchEventWith(FeathersEventType.FOCUS_IN);
		}
	}

	/**
	 * @private
	 */
	private function textEditor_focusOutHandler(event:Event):Void
	{
		this._textEditorHasFocus = false;
		this.refreshState();
		this.refreshErrorCallout();
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STATE);
		if (this._focusManager != null && this._focusManager.focus == this)
		{
			//if clearFocus() was called manually, we need to notify the
			//focus manager if it still thinks we have focus.
			this._focusManager.focus = null;
		}
		else if (this._focusManager == null)
		{
			this.dispatchEventWith(FeathersEventType.FOCUS_OUT);
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