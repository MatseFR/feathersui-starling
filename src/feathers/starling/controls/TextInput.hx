/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;

import feathers.starling.core.FeathersControl;
import feathers.starling.core.IAdvancedNativeFocusOwner;
import feathers.starling.core.IFeathersControl;
import feathers.starling.core.IFocusDisplayObject;
import feathers.starling.core.IMeasureDisplayObject;
import feathers.starling.core.IMultilineTextEditor;
import feathers.starling.core.INativeFocusOwner;
import feathers.starling.core.IStateContext;
import feathers.starling.core.IStateObserver;
import feathers.starling.core.ITextBaselineControl;
import feathers.starling.core.ITextEditor;
import feathers.starling.core.ITextRenderer;
import feathers.starling.core.IValidating;
import feathers.starling.core.PopUpManager;
import feathers.starling.core.PropertyProxy;
import feathers.starling.events.FeathersEventType;
import feathers.starling.layout.RelativePosition;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.controls.TextInputState;
import feathers.starling.text.FontStylesSet;
import feathers.starling.utils.skins.SkinsUtils;
import feathers.starling.utils.type.Property;
import feathers.starling.utils.type.SafeCast;
import haxe.ds.Map;
import openfl.errors.RangeError;
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
 * A text entry control that allows users to enter and edit a single line of
 * uniformly-formatted text.
 *
 * <p>The following example sets the text in a text input, selects the text,
 * and listens for when the text value changes:</p>
 *
 * <listing version="3.0">
 * var input:TextInput = new TextInput();
 * input.text = "Hello World";
 * input.selectRange( 0, input.text.length );
 * input.addEventListener( Event.CHANGE, input_changeHandler );
 * this.addChild( input );</listing>
 *
 * @see ../../../help/text-input.html How to use the Feathers TextInput component
 * @see ../../../help/text-editors.html Introduction to Feathers text editors
 * @see feathers.core.ITextEditor
 * @see feathers.controls.AutoComplete
 * @see feathers.controls.TextArea
 *
 * @productversion Feathers 1.0.0
 */
class TextInput extends FeathersControl implements ITextBaselineControl implements IAdvancedNativeFocusOwner implements IStateContext
{
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_PROMPT_FACTORY:String = "promptFactory";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_ERROR_CALLOUT_FACTORY:String = "errorCalloutFactory";

	/**
	 * The default value added to the <code>styleNameList</code> of the text
	 * editor.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_TEXT_EDITOR:String = "feathers-text-input-text-editor";

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
	public static inline var DEFAULT_CHILD_STYLE_NAME_ERROR_CALLOUT:String = "feathers-text-input-error-callout";

	/**
	 * An alternate style name to use with <code>TextInput</code> to allow a
	 * theme to give it a search input style. If a theme does not provide a
	 * style for the search text input, the theme will automatically fal
	 * back to using the default text input style.
	 *
	 * <p>An alternate style name should always be added to a component's
	 * <code>styleNameList</code> before the component is initialized. If
	 * the style name is added later, it will be ignored.</p>
	 *
	 * <p>In the following example, the search style is applied to a text
	 * input:</p>
	 *
	 * <listing version="3.0">
	 * var input:TextInput = new TextInput();
	 * input.styleNameList.add( TextInput.ALTERNATE_STYLE_NAME_SEARCH_TEXT_INPUT );
	 * this.addChild( input );</listing>
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var ALTERNATE_STYLE_NAME_SEARCH_TEXT_INPUT:String = "feathers-search-text-input";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>TextInput</code>
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
		this.addEventListener(TouchEvent.TOUCH, textInput_touchHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, textInput_removedFromStageHandler);
	}
	
	/**
	 * The text editor sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var textEditor:ITextEditor;

	/**
	 * The prompt text renderer sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var promptTextRenderer:ITextRenderer;

	/**
	 * The currently selected background, based on state.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var currentBackground:DisplayObject;

	/**
	 * The currently visible icon. The value will be <code>null</code> if
	 * there is no currently visible icon.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var currentIcon:DisplayObject;

	/**
	 * The <code>TextCallout</code> that displays the value of the
	 * <code>errorString</code> property. The value may be
	 * <code>null</code> if there is no current error string or the text
	 * input does not have focus.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var callout:TextCallout;
	
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
	 * can customize the prompt text renderer style name in their
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
		if (Std.isOfType(this.textEditor, INativeFocusOwner))
		{
			return cast(this.textEditor, INativeFocusOwner).nativeFocus;
		}
		return null;
	}
	
	/**
	 * @private
	 */
	override function get_maintainTouchFocus():Bool 
	{
		if (Std.isOfType(this.textEditor, IFocusDisplayObject))
		{
			return cast(this.textEditor, IFocusDisplayObject).maintainTouchFocus;
		}
		return super.maintainTouchFocus;
	}
	
	/**
	 * @private
	 */
	private var _ignoreTextChanges:Bool = false;

	/**
	 * @private
	 */
	private var _touchPointID:Int = -1;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return TextInput.globalStyleProvider;
	}
	
	/**
	 * When the <code>FocusManager</code> isn't enabled, <code>hasFocus</code>
	 * can be used instead of <code>FocusManager.focus == textInput</code>
	 * to determine if the text input has focus.
	 */
	public var hasFocus(get, never):Bool;
	private function get_hasFocus():Bool { return this._textEditorHasFocus; }
	
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
	 * The current state of the text input.
	 *
	 * @see feathers.controls.TextInputState
	 * @see #event:stateChange feathers.events.FeathersEventType.STATE_CHANGE
	 */
	public var currentState(get, never):String;
	private var _currentState:String = TextInputState.ENABLED;
	private function get_currentState():String { return this._currentState; }
	
	/**
	 * The text displayed by the text input. The text input dispatches
	 * <code>Event.CHANGE</code> when the value of the <code>text</code>
	 * property changes for any reason.
	 *
	 * <p>In the following example, the text input's text is updated:</p>
	 *
	 * <listing version="3.0">
	 * input.text = "Hello World";</listing>
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
	 * The baseline measurement of the text, in pixels.
	 */
	public var baseline(get, never):Float;
	private function get_baseline():Float
	{
		if (this.textEditor == null)
		{
			return 0;
		}
		return this.textEditor.y + this.textEditor.baseline;
	}
	
	/**
	 * The prompt, hint, or description text displayed by the input when the
	 * value of its text is empty.
	 *
	 * <p>In the following example, the text input's prompt is updated:</p>
	 *
	 * <listing version="3.0">
	 * input.prompt = "User Name";</listing>
	 *
	 * @default null
	 */
	public var prompt(get, set):String;
	private var _prompt:String = null;
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
	 * @private
	 */
	public var typicalText(get, set):String;
	private var _typicalText:String = null;
	private function get_typicalText():String { return this._typicalText; }
	private function set_typicalText(value:String):String
	{
		if (this.processStyleRestriction("typicalText"))
		{
			return value;
		}
		if (this._typicalText == value)
		{
			return value;
		}
		this._typicalText = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._typicalText;
	}
	
	/**
	 * The maximum number of characters that may be entered. If <code>0</code>,
	 * any number of characters may be entered.
	 *
	 * <p>In the following example, the text input's maximum characters is
	 * specified:</p>
	 *
	 * <listing version="3.0">
	 * input.maxChars = 10;</listing>
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
	 * <p>In the following example, the text input's allowed characters are
	 * restricted:</p>
	 *
	 * <listing version="3.0">
	 * input.restrict = "0-9";</listing>
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
	 * Determines if the entered text will be masked so that it cannot be
	 * seen, such as for a password input.
	 *
	 * <p>In the following example, the text input's text is displayed as
	 * a password:</p>
	 *
	 * <listing version="3.0">
	 * input.displayAsPassword = true;</listing>
	 *
	 * @default false
	 */
	public var displayAsPassword(get, set):Bool;
	private var _displayAsPassword:Bool = false;
	private function get_displayAsPassword():Bool { return this._displayAsPassword; }
	private function set_displayAsPassword(value:Bool):Bool
	{
		if (this._displayAsPassword == value)
		{
			return value;
		}
		this._displayAsPassword = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._displayAsPassword;
	}
	
	/**
	 * Determines if the text input is editable. If the text input is not
	 * editable, it will still appear enabled.
	 *
	 * <p>In the following example, the text input is not editable:</p>
	 *
	 * <listing version="3.0">
	 * input.isEditable = false;</listing>
	 *
	 * @default true
	 *
	 * @see #isSelectable
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
	 * If the <code>isEditable</code> property is set to <code>false</code>,
	 * the <code>isSelectable</code> property determines if the text is
	 * selectable. If the <code>isEditable</code> property is set to
	 * <code>true</code>, the text will always be selectable.
	 *
	 * <p>In the following example, the text input is not selectable:</p>
	 *
	 * <listing version="3.0">
	 * input.isEditable = false;
	 * input.isSelectable = false;</listing>
	 *
	 * @default true
	 *
	 * @see #isEditable
	 */
	public var isSelectable(get, set):Bool;
	private var _isSelectable:Bool = true;
	private function get_isSelectable():Bool { return this._isSelectable; }
	private function set_isSelectable(value:Bool):Bool
	{
		if (this._isSelectable == value)
		{
			return value;
		}
		this._isSelectable = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._isSelectable;
	}
	
	/**
	 * Error text to display in a <code>Callout</code> when the input has
	 * focus. When this value is not <code>null</code> the input's state is
	 * changed to <code>TextInputState.ERROR</code>.
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
	 * input.errorString = "Something is wrong";</listing>
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
	 * A function used to instantiate the text editor. If null,
	 * <code>FeathersControl.defaultTextEditorFactory</code> is used
	 * instead. The text editor must be an instance of
	 * <code>ITextEditor</code>. This factory can be used to change
	 * properties on the text editor when it is first created. For instance,
	 * if you are skinning Feathers components without a theme, you might
	 * use this factory to set styles on the text editor.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextEditor</pre>
	 *
	 * <p>In the following example, a custom text editor factory is passed
	 * to the text input:</p>
	 *
	 * <listing version="3.0">
	 * input.textEditorFactory = function():ITextEditor
	 * {
	 *     return new TextFieldTextEditor();
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.ITextEditor
	 * @see feathers.core.FeathersControl#defaultTextEditorFactory
	 */
	public var textEditorFactory(get, set):Void->ITextEditor;
	private var _textEditorFactory:Void->ITextEditor;
	private function get_textEditorFactory():Void->ITextEditor { return this._textEditorFactory; }
	private function set_textEditorFactory(value:Void->ITextEditor):Void->ITextEditor
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
		this.invalidate(INVALIDATION_FLAG_PROMPT_FACTORY);
		return this._customPromptStyleName;
	}
	
	/**
	 * An object that stores properties for the input's prompt text
	 * renderer sub-component, and the properties will be passed down to the
	 * text renderer when the input validates. The available properties
	 * depend on which <code>ITextRenderer</code> implementation is returned
	 * by <code>messageFactory</code>. Refer to
	 * <a href="../core/ITextRenderer.html"><code>feathers.core.ITextRenderer</code></a>
	 * for a list of available text renderer implementations.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>promptFactory</code> function
	 * instead of using <code>promptProperties</code> will result in
	 * better performance.</p>
	 *
	 * <p>In the following example, the text input's prompt's properties are
	 * updated (this example assumes that the prompt text renderer is a
	 * <code>TextFieldTextRenderer</code>):</p>
	 *
	 * <listing version="3.0">
	 * input.promptProperties.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 * input.promptProperties.embedFonts = true;</listing>
	 *
	 * @default null
	 *
	 * @see #prompt
	 * @see #promptFactory
	 * @see feathers.core.ITextRenderer
	 */
	public var promptProperties(get, set):PropertyProxy;
	private var _promptProperties:PropertyProxy;
	private function get_promptProperties():PropertyProxy
	{
		if (this._promptProperties == null)
		{
			this._promptProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._promptProperties;
	}
	
	private function set_promptProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._promptProperties == value)
		{
			return value;
		}
		if (this._promptProperties != null)
		{
			this._promptProperties.dispose();
		}
		this._promptProperties = value;
		if (this._promptProperties != null)
		{
			this._promptProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._promptProperties;
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
			return value;
		}
		if (this._backgroundSkin == value)
		{
			return value;
		}
		if (this._backgroundSkin != null &&
			this.currentBackground == this._backgroundSkin)
		{
			//if this skin needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentBackground(this._backgroundSkin);
			this.currentBackground = null;
		}
		this._backgroundSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SKIN);
		return this._backgroundSkin;
	}
	
	/**
	 * @private
	 */
	private var _stateToSkin:Map<String, DisplayObject> = new Map();
	
	/**
	 * @private
	 */
	public var backgroundEnabledSkin(get, set):DisplayObject;
	private function get_backgroundEnabledSkin():DisplayObject { return this.getSkinForState(TextInputState.ENABLED); }
	private function set_backgroundEnabledSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(TextInputState.ENABLED, value);
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
	public var backgroundDisabledSkin(get, set):DisplayObject;
	private function get_backgroundDisabledSkin():DisplayObject { return this.getSkinForState(TextInputState.DISABLED); }
	private function set_backgroundDisabledSkin(value:DisplayObject):DisplayObject
	{
		this.setSkinForState(TextInputState.DISABLED, value);
		return value;
	}
	
	/**
	 * @private
	 * The width of the first icon that was displayed.
	 */
	private var _originalIconWidth:Float = Math.NaN;

	/**
	 * @private
	 * The height of the first icon that was displayed.
	 */
	private var _originalIconHeight:Float = Math.NaN;
	
	/**
	 * @private
	 */
	public var defaultIcon(get, set):DisplayObject;
	private var _defaultIcon:DisplayObject;
	private function get_defaultIcon():DisplayObject { return this._defaultIcon; }
	private function set_defaultIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("defaultIcon"))
		{
			return value;
		}
		if (this._defaultIcon == value)
		{
			return value;
		}
		this._defaultIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._defaultIcon;
	}
	
	/**
	 * @private
	 */
	private var _stateToIcon:Map<String, DisplayObject> = new Map();
	
	/**
	 * @private
	 */
	public var enabledIcon(get, set):DisplayObject;
	private function get_enabledIcon():DisplayObject { return this.getIconForState(TextInputState.ENABLED); }
	private function set_enabledIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(TextInputState.ENABLED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var disabledIcon(get, set):DisplayObject;
	private function get_disabledIcon():DisplayObject { return this.getIconForState(TextInputState.DISABLED); }
	private function set_disabledIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(TextInputState.DISABLED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var focusedIcon(get, set):DisplayObject;
	private function get_focusedIcon():DisplayObject { return this.getIconForState(TextInputState.FOCUSED); }
	private function set_focusedIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(TextInputState.FOCUSED, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var errorIcon(get, set):DisplayObject;
	private function get_errorIcon():DisplayObject { return this.getIconForState(TextInputState.ERROR); }
	private function set_errorIcon(value:DisplayObject):DisplayObject
	{
		this.setIconForState(TextInputState.ERROR, value);
		return value;
	}
	
	/**
	 * @private
	 */
	public var iconPosition(get, set):String;
	private var _iconPosition:String = RelativePosition.LEFT;
	private function get_iconPosition():String { return this._iconPosition; }
	private function set_iconPosition(value:String):String
	{
		if (this.processStyleRestriction("iconPosition"))
		{
			return value;
		}
		if (this._iconPosition == value)
		{
			return value;
		}
		this._iconPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._iconPosition;
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
	 * Flag indicating that the text editor should get focus after it is
	 * created.
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
	private var _oldMouseCursor:String = null;
	
	/**
	 * An object that stores properties for the input's text editor
	 * sub-component, and the properties will be passed down to the
	 * text editor when the input validates. The available properties
	 * depend on which <code>ITextEditor</code> implementation is returned
	 * by <code>textEditorFactory</code>. Refer to
	 * <a href="../core/ITextEditor.html"><code>feathers.core.ITextEditor</code></a>
	 * for a list of available text editor implementations.
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
	 * <code>StageTextTextEditor</code>):</p>
	 *
	 * <listing version="3.0">
	 * input.textEditorProperties.fontName = "Helvetica";
	 * input.textEditorProperties.fontSize = 16;</listing>
	 *
	 * @default null
	 *
	 * @see #textEditorFactory
	 * @see feathers.core.ITextEditor
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textEditorProperties;
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
		if (this.textEditor != null)
		{
			return this.textEditor.selectionBeginIndex;
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
		if (this.textEditor != null)
		{
			return this.textEditor.selectionEndIndex;
		}
		return 0;
	}
	
	override function set_visible(value:Bool):Bool 
	{
		if (!value)
		{
			this._isWaitingToSetFocus = false;
		}
		super.visible = value;
		//call clearFocus() after setting super.visible because the text
		//editor may check the visible property
		if (!value && this._textEditorHasFocus)
		{
			this.textEditor.clearFocus();
		}
		return value;
	}
	
	/**
	 * @private
	 */
	override public function hitTest(localPoint:Point):DisplayObject
	{
		if (!this.visible || !this.touchable)
		{
			return null;
		}
		if (this.mask != null && !this.hitTestMask(localPoint))
		{
			return null;
		}
		return this._hitArea.containsPoint(localPoint) ? cast this.textEditor : null;
	}
	
	/**
	 * Focuses the text input control so that it may be edited, and selects
	 * all of its text. Call <code>selectRange()</code> after
	 * <code>setFocus()</code> to select a different range.
	 *
	 * @see #selectRange()
	 */
	public function setFocus():Void
	{
		//if the text editor has focus, no need to set focus
		//if this is invisible, it wouldn't make sense to set focus
		//if there's a touch point ID, we'll be setting focus on our own
		if (this._textEditorHasFocus || !this.visible || this._touchPointID >= 0)
		{
			return;
		}
		if (this._isEditable || this._isSelectable)
		{
			this.selectRange(0, this._text.length);
		}
		if (this.textEditor != null)
		{
			this._isWaitingToSetFocus = false;
			this.textEditor.setFocus();
		}
		else
		{
			this._isWaitingToSetFocus = true;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		}
	}
	
	/**
	 * Manually removes focus from the text input control.
	 */
	public function clearFocus():Void
	{
		this._isWaitingToSetFocus = false;
		if (this.textEditor == null || !this._textEditorHasFocus)
		{
			return;
		}
		this.textEditor.clearFocus();
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
			throw new RangeError("Expected begin index >= 0. Received " + beginIndex + ".");
		}
		if (endIndex > this._text.length)
		{
			throw new RangeError("Expected end index <= " + this._text.length + ". Received " + endIndex + ".");
		}
		
		//if it's invalid, we need to wait until validation before changing
		//the selection
		if (this.textEditor != null && (this._isValidating || !this.isInvalid()))
		{
			this._pendingSelectionBeginIndex = -1;
			this._pendingSelectionEndIndex = -1;
			this.textEditor.selectRange(beginIndex, endIndex);
		}
		else
		{
			this._pendingSelectionBeginIndex = beginIndex;
			this._pendingSelectionEndIndex = endIndex;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SELECTED);
		}
	}
	
	/**
	 * Gets the font styles to be used to display the input's text when the
	 * input's <code>currentState</code> property matches the specified
	 * state value.
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
	 * Sets the font styles to be used to display the input's text when the
	 * input's <code>currentState</code> property matches the specified
	 * state value.
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
	 * Gets the font styles to be used to display the input's prompt when
	 * the input's <code>currentState</code> property matches the specified
	 * state value.
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
	 * Sets the font styles to be used to display the input's prompt when
	 * the input's <code>currentState</code> property matches the specified
	 * state value.
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
	 * Gets the skin to be used by the text input when the input's
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
	 * Sets the skin to be used by the text input when the input's
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
		var oldSkin:DisplayObject = this._stateToSkin[state];
		if (oldSkin != null &&
			this.currentBackground == oldSkin)
		{
			//if this skin needs to be reused somewhere else, we need to
			//properly clean it up
			this.removeCurrentBackground(oldSkin);
			this.currentBackground = null;
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
	 * Gets the icon to be used by the text input when the input's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a icon is not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see #setIconForState()
	 */
	public function getIconForState(state:String):DisplayObject
	{
		return this._stateToIcon[state];
	}
	
	/**
	 * Sets the icon to be used by the text input when the input's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If an icon is not defined for a specific state, the value of the
	 * <code>defaultIcon</code> property will be used instead.</p>
	 *
	 * @see #defaultIcon
	 * @see #getIconForState()
	 */
	public function setIconForState(state:String, icon:DisplayObject):Void
	{
		var key:String = "setIconForState--" + state;
		if (this.processStyleRestriction(key))
		{
			if (icon != null)
			{
				icon.dispose();
			}
			return;
		}
		if (icon != null)
		{
			this._stateToIcon[state] = icon;
		}
		else
		{
			this._stateToIcon.remove(state);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//we don't dispose it if the text input is the parent because it'll
		//already get disposed in super.dispose()
		if (this._backgroundSkin != null && this._backgroundSkin.parent != this)
		{
			this._backgroundSkin.dispose();
		}
		for (skin in this._stateToSkin)
		{
			if (skin != null && skin.parent != this)
			{
				skin.dispose();
			}
		}
		_stateToIcon.clear();
		if (this._defaultIcon != null && this._defaultIcon.parent != this)
		{
			this._defaultIcon.dispose();
		}
		for (icon in this._stateToIcon)
		{
			if (icon != null && icon.parent != this)
			{
				icon.dispose();
			}
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
		if (this._promptProperties != null)
		{
			this._promptProperties.dispose();
			this._promptProperties = null;
		}
		if (this._textEditorProperties != null)
		{
			this._textEditorProperties.dispose();
			this._textEditorProperties = null;
		}
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var skinInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SKIN);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var textEditorInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_TEXT_EDITOR);
		var promptFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_PROMPT_FACTORY);
		var focusInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_FOCUS);
		
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
		
		if (promptFactoryInvalid || stylesInvalid)
		{
			this.refreshPromptProperties();
		}
		
		if (textEditorInvalid || dataInvalid)
		{
			var oldIgnoreTextChanges:Bool = this._ignoreTextChanges;
			this._ignoreTextChanges = true;
			this.textEditor.text = this._text;
			this._ignoreTextChanges = oldIgnoreTextChanges;
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
			this.textEditor.isEnabled = this._isEnabled;
			if (!this._isEnabled && Mouse.supportsNativeCursor && this._oldMouseCursor != null)
			{
				Mouse.cursor = this._oldMouseCursor;
				this._oldMouseCursor = null;
			}
		}
		
		if (stateInvalid || skinInvalid)
		{
			this.refreshBackgroundSkin();
		}
		if (stateInvalid || stylesInvalid)
		{
			this.refreshIcon();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layoutChildren();
		
		//the state might not change if the text input has focus when
		//the error string changes, so check for styles too!
		if (stateInvalid || stylesInvalid)
		{
			this.refreshErrorCallout();
		}
		
		if (sizeInvalid || focusInvalid)
		{
			this.refreshFocusIndicator();
		}
		
		this.doPendingActions();
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
		
		var measureBackground:IMeasureDisplayObject = SafeCast.safe_cast(this.currentBackground, IMeasureDisplayObject);
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentBackground,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		if (Std.isOfType(this.currentBackground, IValidating))
		{
			cast(this.currentBackground, IValidating).validate();
		}
		if (Std.isOfType(this.currentIcon, IValidating))
		{
			cast(this.currentIcon, IValidating).validate();
		}
		
		var measuredContentWidth:Float = 0;
		var measuredContentHeight:Float = 0;
		
		//if the typicalText is specified, the dimensions of the text editor
		//can affect the final dimensions. otherwise, the background skin or
		//prompt should be used for measurement.
		var point:Point;
		var oldTextEditorWidth:Float = 0;
		var oldTextEditorHeight:Float = 0;
		if (this._typicalText != null)
		{
			point = Pool.getPoint();
			oldTextEditorWidth = this.textEditor.width;
			oldTextEditorHeight = this.textEditor.height;
			var oldIgnoreTextChanges:Bool = this._ignoreTextChanges;
			this._ignoreTextChanges = true;
			this.textEditor.setSize(Math.NaN, Math.NaN);
			this.textEditor.text = this._typicalText;
			this.textEditor.measureText(point);
			this.textEditor.text = this._text;
			this._ignoreTextChanges = oldIgnoreTextChanges;
			measuredContentWidth = point.x;
			measuredContentHeight = point.y;
			Pool.putPoint(point);
		}
		if (this._prompt != null)
		{
			point = Pool.getPoint();
			this.promptTextRenderer.setSize(Math.NaN, Math.NaN);
			this.promptTextRenderer.measureText(point);
			if (point.x > measuredContentWidth)
			{
				measuredContentWidth = point.x;
			}
			if (point.y > measuredContentHeight)
			{
				measuredContentHeight = point.y;
			}
			Pool.putPoint(point);
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			newWidth = measuredContentWidth;
			if (this._originalIconWidth == this._originalIconWidth) //!isNaN
			{
				newWidth += this._originalIconWidth + this._gap;
			}
			newWidth += this._paddingLeft + this._paddingRight;
			if (this.currentBackground != null &&
				this.currentBackground.width > newWidth)
			{
				newWidth = this.currentBackground.width;
			}
		}
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			newHeight = measuredContentHeight;
			if (this._originalIconHeight == this._originalIconHeight && //!isNaN
				this._originalIconHeight > newHeight)
			{
				newHeight = this._originalIconHeight;
			}
			newHeight += this._paddingTop + this._paddingBottom;
			if (this.currentBackground != null &&
				this.currentBackground.height > newHeight)
			{
				newHeight = this.currentBackground.height;
			}
		}
		
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			newMinWidth = measuredContentWidth;
			if (Std.isOfType(this.currentIcon, IFeathersControl))
			{
				newMinWidth += cast(this.currentIcon, IFeathersControl).minWidth + this._gap;
			}
			else if (this._originalIconWidth == this._originalIconWidth)
			{
				newMinWidth += this._originalIconWidth + this._gap;
			}
			newMinWidth += this._paddingLeft + this._paddingRight;
			var backgroundMinWidth:Float = 0;
			if (measureBackground != null)
			{
				backgroundMinWidth = measureBackground.minWidth;
			}
			else if (this.currentBackground != null)
			{
				backgroundMinWidth = this._explicitBackgroundMinWidth;
			}
			if (backgroundMinWidth > newMinWidth)
			{
				newMinWidth = backgroundMinWidth;
			}
		}
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			newMinHeight = measuredContentHeight;
			if (Std.isOfType(this.currentIcon, IFeathersControl))
			{
				var iconMinHeight:Float = cast(this.currentIcon, IFeathersControl).minHeight;
				if (iconMinHeight > newMinHeight)
				{
					newMinHeight = iconMinHeight;
				}
			}
			else if (this._originalIconHeight == this._originalIconHeight && //!isNaN
				this._originalIconHeight > newMinHeight)
			{
				newMinHeight = this._originalIconHeight;
			}
			newMinHeight += this._paddingTop + this._paddingBottom;
			var backgroundMinHeight:Float = 0;
			if (measureBackground != null)
			{
				backgroundMinHeight = measureBackground.minHeight;
			}
			else if (this.currentBackground != null)
			{
				backgroundMinHeight = this._explicitBackgroundMinHeight;
			}
			if (backgroundMinHeight > newMinHeight)
			{
				newMinHeight = backgroundMinHeight;
			}
		}
		
		var isMultiline:Bool = Std.isOfType(this.textEditor, IMultilineTextEditor) && cast(this.textEditor, IMultilineTextEditor).multiline;
		if (this._typicalText != null && (this._verticalAlign == VerticalAlign.JUSTIFY || isMultiline))
		{
			this.textEditor.width = oldTextEditorWidth;
			this.textEditor.height = oldTextEditorHeight;
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * Creates and adds the <code>textEditor</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #textEditor
	 * @see #textEditorFactory
	 */
	private function createTextEditor():Void
	{
		if (this.textEditor != null)
		{
			this.removeChild(cast this.textEditor, true);
			this.textEditor.removeEventListener(Event.CHANGE, textEditor_changeHandler);
			this.textEditor.removeEventListener(FeathersEventType.ENTER, textEditor_enterHandler);
			this.textEditor.removeEventListener(FeathersEventType.FOCUS_IN, textEditor_focusInHandler);
			this.textEditor.removeEventListener(FeathersEventType.FOCUS_OUT, textEditor_focusOutHandler);
			this.textEditor = null;
		}
		
		var factory:Void->ITextEditor = this._textEditorFactory != null ? this._textEditorFactory : FeathersControl.defaultTextEditorFactory;
		this.textEditor = factory();
		var textEditorStyleName:String = this._customTextEditorStyleName != null ? this._customTextEditorStyleName : this.textEditorStyleName;
		this.textEditor.styleNameList.add(textEditorStyleName);
		if (Std.isOfType(this.textEditor, IStateObserver))
		{
			cast(this.textEditor, IStateObserver).stateContext = this;
		}
		this.textEditor.addEventListener(Event.CHANGE, textEditor_changeHandler);
		this.textEditor.addEventListener(FeathersEventType.ENTER, textEditor_enterHandler);
		this.textEditor.addEventListener(FeathersEventType.FOCUS_IN, textEditor_focusInHandler);
		this.textEditor.addEventListener(FeathersEventType.FOCUS_OUT, textEditor_focusOutHandler);
		this.addChild(cast this.textEditor);
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
		this.callout = new TextCallout();
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
		if (this._isWaitingToSetFocus)
		{
			this._isWaitingToSetFocus = false;
			if (!this._textEditorHasFocus)
			{
				if ((this._isEditable || this._isSelectable) &&
					this._pendingSelectionBeginIndex < 0)
				{
					this._pendingSelectionBeginIndex = 0;
					this._pendingSelectionEndIndex = this._text.length;
				}
				this.textEditor.setFocus();
			}
		}
		if (this._pendingSelectionBeginIndex >= 0)
		{
			var startIndex:Int = this._pendingSelectionBeginIndex;
			var endIndex:Int = this._pendingSelectionEndIndex;
			this._pendingSelectionBeginIndex = -1;
			this._pendingSelectionEndIndex = -1;
			if (endIndex >= 0)
			{
				var textLength:Int = this._text.length;
				if (endIndex > textLength)
				{
					endIndex = textLength;
				}
			}
			this.selectRange(startIndex, endIndex);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshTextEditorProperties():Void
	{
		this.textEditor.displayAsPassword = this._displayAsPassword;
		this.textEditor.maxChars = this._maxChars;
		this.textEditor.restrict = this._restrict;
		this.textEditor.isEditable = this._isEditable;
		this.textEditor.isSelectable = this._isSelectable;
		this.textEditor.fontStyles = this._fontStylesSet;
		
		if (this._textEditorProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._textEditorProperties)
			{
				propertyValue = this._textEditorProperties[propertyName];
				Property.write(this.textEditor, propertyName, propertyValue);
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
		
		if (this._promptProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._promptProperties)
			{
				propertyValue = this._promptProperties[propertyName];
				Property.write(this.promptTextRenderer, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * Sets the <code>currentBackground</code> property.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function refreshBackgroundSkin():Void
	{
		var oldSkin:DisplayObject = this.currentBackground;
		this.currentBackground = this.getCurrentSkin();
		if (this.currentBackground != oldSkin)
		{
			this.removeCurrentBackground(oldSkin);
			if (this.currentBackground != null)
			{
				if (Std.isOfType(this.currentBackground, IStateObserver))
				{
					cast(this.currentBackground, IStateObserver).stateContext = this;
				}
				if (Std.isOfType(this.currentBackground, IFeathersControl))
				{
					cast(this.currentBackground, IFeathersControl).initializeNow();
				}
				if (Std.isOfType(this.currentBackground, IMeasureDisplayObject))
				{
					var measureSkin:IMeasureDisplayObject = cast this.currentBackground;
					this._explicitBackgroundWidth = measureSkin.explicitWidth;
					this._explicitBackgroundHeight = measureSkin.explicitHeight;
					this._explicitBackgroundMinWidth = measureSkin.explicitMinWidth;
					this._explicitBackgroundMinHeight = measureSkin.explicitMinHeight;
					this._explicitBackgroundMaxWidth = measureSkin.explicitMaxWidth;
					this._explicitBackgroundMaxHeight = measureSkin.explicitMaxHeight;
				}
				else
				{
					this._explicitBackgroundWidth = this.currentBackground.width;
					this._explicitBackgroundHeight = this.currentBackground.height;
					this._explicitBackgroundMinWidth = this._explicitBackgroundWidth;
					this._explicitBackgroundMinHeight = this._explicitBackgroundHeight;
					this._explicitBackgroundMaxWidth = this._explicitBackgroundWidth;
					this._explicitBackgroundMaxHeight = this._explicitBackgroundHeight;
				}
				this.addChildAt(this.currentBackground, 0);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function removeCurrentBackground(skin:DisplayObject):Void
	{
		if (skin == null)
		{
			return;
		}
		if (Std.isOfType(skin, IStateObserver))
		{
			cast(skin, IStateObserver).stateContext = null;
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
	 * Sets the <code>currentIcon</code> property.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function refreshIcon():Void
	{
		var oldIcon:DisplayObject = this.currentIcon;
		this.currentIcon = this.getCurrentIcon();
		if (Std.isOfType(this.currentIcon, IFeathersControl))
		{
			cast(this.currentIcon, IFeathersControl).isEnabled = this._isEnabled;
		}
		if (this.currentIcon != oldIcon)
		{
			if (oldIcon != null)
			{
				if (Std.isOfType(oldIcon, IStateObserver))
				{
					cast(oldIcon, IStateObserver).stateContext = null;
				}
				this.removeChild(oldIcon, false);
			}
			if (this.currentIcon != null)
			{
				if (Std.isOfType(this.currentIcon, IStateObserver))
				{
					cast(this.currentIcon, IStateObserver).stateContext = this;
				}
				//we want the icon to appear below the text editor
				var index:Int = this.getChildIndex(cast this.textEditor);
				this.addChildAt(this.currentIcon, index);
			}
		}
		if (this.currentIcon != null &&
			(this._originalIconWidth != this._originalIconWidth || //isNaN
			this._originalIconHeight != this._originalIconHeight)) //isNaN
		{
			if (Std.isOfType(this.currentIcon, IValidating))
			{
				cast(this.currentIcon, IValidating).validate();
			}
			this._originalIconWidth = this.currentIcon.width;
			this._originalIconHeight = this.currentIcon.height;
		}
	}
	
	/**
	 * @private
	 */
	private function getCurrentSkin():DisplayObject
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
	private function getCurrentIcon():DisplayObject
	{
		var result:DisplayObject = this._stateToIcon[this._currentState];
		if (result != null)
		{
			return result;
		}
		return this._defaultIcon;
	}
	
	/**
	 * Positions and sizes the text input's children.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function layoutChildren():Void
	{
		if (this.currentBackground != null)
		{
			this.currentBackground.visible = true;
			this.currentBackground.touchable = true;
			this.currentBackground.width = this.actualWidth;
			this.currentBackground.height = this.actualHeight;
		}
		
		if (Std.isOfType(this.currentIcon, IValidating))
		{
			cast(this.currentIcon, IValidating).validate();
		}
		
		if (this.currentIcon != null)
		{
			if (this._iconPosition == RelativePosition.RIGHT)
			{
				this.currentIcon.x = this.actualWidth - this.currentIcon.width - this._paddingRight;
				this.textEditor.x = this._paddingLeft;
				if (this.promptTextRenderer != null)
				{
					this.promptTextRenderer.x = this._paddingLeft;
				}
			}
			else //left
			{
				this.currentIcon.x = this._paddingLeft;
				this.textEditor.x = this.currentIcon.x + this.currentIcon.width + this._gap;
				if (this.promptTextRenderer != null)
				{
					this.promptTextRenderer.x = this.currentIcon.x + this.currentIcon.width + this._gap;
				}
			}
		}
		else
		{
			this.textEditor.x = this._paddingLeft;
			if (this.promptTextRenderer != null)
			{
				this.promptTextRenderer.x = this._paddingLeft;
			}
		}
		
		var textEditorWidth:Float = this.actualWidth - this._paddingRight - this.textEditor.x;
		if (this.currentIcon != null && this._iconPosition == RelativePosition.RIGHT)
		{
			textEditorWidth -= (this.currentIcon.width + this._gap);
		}
		this.textEditor.width = textEditorWidth;
		if (this.promptTextRenderer != null)
		{
			this.promptTextRenderer.width = textEditorWidth;
		}
		
		var isMultiline:Bool = Std.isOfType(this.textEditor, IMultilineTextEditor) && cast(this.textEditor, IMultilineTextEditor).multiline;
		if (isMultiline || this._verticalAlign == VerticalAlign.JUSTIFY)
		{
			//multiline is treated the same as justify
			this.textEditor.height = this.actualHeight - this._paddingTop - this._paddingBottom;
		}
		else
		{
			//clear the height and auto-size instead
			this.textEditor.height = Math.NaN;
		}
		this.textEditor.validate();
		if (this.promptTextRenderer != null)
		{
			this.promptTextRenderer.validate();
		}
		
		var biggerHeight:Float = this.textEditor.height;
		var biggerBaseline:Float = this.textEditor.baseline;
		var promptBaseline:Float = 0;
		if (this.promptTextRenderer != null)
		{
			promptBaseline = this.promptTextRenderer.baseline;
			var promptHeight:Float = this.promptTextRenderer.height;
			if (promptBaseline > biggerBaseline)
			{
				biggerBaseline = promptBaseline;
			}
			if (promptHeight > biggerHeight)
			{
				biggerHeight = promptHeight;
			}
		}
		
		if (isMultiline)
		{
			this.textEditor.y = this._paddingTop + biggerBaseline - this.textEditor.baseline;
			if (this.promptTextRenderer != null)
			{
				this.promptTextRenderer.y = this._paddingTop + biggerBaseline - promptBaseline;
				this.promptTextRenderer.height = this.actualHeight - this.promptTextRenderer.y - this._paddingBottom;
			}
			if (this.currentIcon != null)
			{
				this.currentIcon.y = this._paddingTop;
			}
		}
		else
		{
			switch (this._verticalAlign)
			{
				case VerticalAlign.JUSTIFY:
					this.textEditor.y = this._paddingTop + biggerBaseline - this.textEditor.baseline;
					if (this.promptTextRenderer != null)
					{
						this.promptTextRenderer.y = this._paddingTop + biggerBaseline - promptBaseline;
						this.promptTextRenderer.height = this.actualHeight - this.promptTextRenderer.y - this._paddingBottom;
					}
					if (this.currentIcon != null)
					{
						this.currentIcon.y = this._paddingTop;
					}
				
				case VerticalAlign.TOP:
					this.textEditor.y = this._paddingTop + biggerBaseline - this.textEditor.baseline;
					if (this.promptTextRenderer != null)
					{
						this.promptTextRenderer.y = this._paddingTop + biggerBaseline - promptBaseline;
					}
					if (this.currentIcon != null)
					{
						this.currentIcon.y = this._paddingTop;
					}
				
				case VerticalAlign.BOTTOM:
					this.textEditor.y = this.actualHeight - this._paddingBottom - biggerHeight + biggerBaseline - this.textEditor.baseline;
					if (this.promptTextRenderer != null)
					{
						this.promptTextRenderer.y = this.actualHeight - this._paddingBottom - biggerHeight + biggerBaseline - promptBaseline;
					}
					if (this.currentIcon != null)
					{
						this.currentIcon.y = this.actualHeight - this._paddingBottom - this.currentIcon.height;
					}
				
				default: //middle
					this.textEditor.y = biggerBaseline - this.textEditor.baseline + this._paddingTop + Math.fround((this.actualHeight - this._paddingTop - this._paddingBottom - biggerHeight) / 2);
					if (this.promptTextRenderer != null)
					{
						this.promptTextRenderer.y = biggerBaseline - promptBaseline + this._paddingTop + Math.fround((this.actualHeight - this._paddingTop - this._paddingBottom - biggerHeight) / 2);
					}
					if (this.currentIcon != null)
					{
						this.currentIcon.y = this._paddingTop + Math.fround((this.actualHeight - this._paddingTop - this._paddingBottom - this.currentIcon.height) / 2);
					}
				
			}
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
		//if the focus manager is enabled, _hasFocus will determine if we
		//pass focus to the text editor.
		//if there is no focus manager, then we check if the touch is in
		//the bounds of the text input.
		if ((this._hasFocus || isInBounds) && !this._textEditorHasFocus)
		{
			this.textEditor.globalToLocal(point, point);
			this._isWaitingToSetFocus = false;
			this.textEditor.setFocus(point);
		}
		Pool.putPoint(point);
	}
	
	/**
	 * @private
	 */
	private function refreshState():Void
	{
		if (this._isEnabled)
		{
			//this component can have focus while its text editor does not
			//have focus. StageText, in particular, can't receive focus
			//when its enabled property is false, but we still want to show
			//that the input is focused.
			if (this._textEditorHasFocus || this._hasFocus)
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
			this._errorString != null && this._errorString.length != -1)
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
	private function childProperties_onChange(proxy:PropertyProxy, name:String):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private function textInput_removedFromStageHandler(event:Event):Void
	{
		if (this._focusManager != null && this._textEditorHasFocus)
		{
			this.clearFocus();
		}
		this._textEditorHasFocus = false;
		this._isWaitingToSetFocus = false;
		this._touchPointID = -1;
		if (Mouse.supportsNativeCursor && this._oldMouseCursor != null)
		{
			Mouse.cursor = this._oldMouseCursor;
			this._oldMouseCursor = null;
		}
	}
	
	/**
	 * @private
	 */
	private function textInput_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this._touchPointID = -1;
			return;
		}
		
		var touch:Touch;
		if (this._touchPointID >= 0)
		{
			touch = event.getTouch(this, TouchPhase.ENDED, this._touchPointID);
			if (touch == null)
			{
				return;
			}
			var point:Point = Pool.getPoint();
			touch.getLocation(this.stage, point);
			var isInBounds:Bool = this.contains(this.stage.hitTest(point));
			Pool.putPoint(point);
			if (!isInBounds)
			{
				//if not in bounds on TouchPhase.ENDED, there won't be a
				//hover end event, so we need to clear the mouse cursor
				if (Mouse.supportsNativeCursor && this._oldMouseCursor != null)
				{
					Mouse.cursor = this._oldMouseCursor;
					this._oldMouseCursor = null;
				}
			}
			this._touchPointID = -1;
			if (this.textEditor.setTouchFocusOnEndedPhase)
			{
				this.setFocusOnTextEditorWithTouch(touch);
			}
		}
		else
		{
			touch = event.getTouch(this, TouchPhase.BEGAN);
			if (touch != null)
			{
				this._touchPointID = touch.id;
				if (!this.textEditor.setTouchFocusOnEndedPhase)
				{
					this.setFocusOnTextEditorWithTouch(touch);
				}
				return;
			}
			touch = event.getTouch(this, TouchPhase.HOVER);
			if (touch != null)
			{
				if ((this._isEditable || this._isSelectable) &&
					Mouse.supportsNativeCursor && this._oldMouseCursor == null)
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
	override function focusInHandler(event:Event):Void
	{
		if (this._focusManager == null)
		{
			return;
		}
		super.focusInHandler(event);
		//in some cases the text editor cannot receive focus, so it won't
		//dispatch an event. we need to detect the focused state using the
		//_hasFocus variable
		this.refreshState();
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
		//similar to above, we refresh the state based on the _hasFocus
		//because the text editor may not be able to receive focus
		this.refreshState();
		this.textEditor.clearFocus();
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
		this.text = this.textEditor.text;
	}
	
	/**
	 * @private
	 */
	private function textEditor_enterHandler(event:Event):Void
	{
		this.dispatchEventWith(FeathersEventType.ENTER);
	}
	
	/**
	 * @private
	 */
	private function textEditor_focusInHandler(event:Event):Void
	{
		if (!this.visible)
		{
			this.textEditor.clearFocus();
			return;
		}
		this._textEditorHasFocus = true;
		this.refreshState();
		this.refreshErrorCallout();
		if (this._focusManager != null && this.isFocusEnabled)
		{
			if (this._focusManager.focus != this)
			{
				//if setFocus() was called manually, we need to notify the focus
				//manager (unless isFocusEnabled is false).
				//if the focus manager already knows that we have focus, it will
				//simply return without doing anything.
				this._focusManager.focus = this;
			}
		}
		else
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
		if (this._focusManager != null && this.isFocusEnabled)
		{
			if (this._focusManager.focus == this)
			{
				//if clearFocus() was called manually, we need to notify the
				//focus manager if it still thinks we have focus.
				this._focusManager.focus = null;
			}
		}
		else
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