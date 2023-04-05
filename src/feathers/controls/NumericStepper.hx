/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IAdvancedNativeFocusOwner;
import feathers.core.ITextBaselineControl;
import feathers.core.PropertyProxy;
import feathers.events.ExclusiveTouch;
import feathers.events.FeathersEventType;
import feathers.skins.IStyleProvider;
import feathers.utils.math.MathUtils;
import feathers.utils.type.Property;
import haxe.Constraints.Function;
import openfl.events.TimerEvent;
import openfl.ui.Keyboard;
import openfl.utils.Timer;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.KeyboardEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;

/**
 * Select a value between a minimum and a maximum by using increment and
 * decrement buttons or typing in a value in a text input.
 *
 * <p>The following example sets the stepper's range and listens for when
 * the value changes:</p>
 *
 * <listing version="3.0">
 * var stepper:NumericStepper = new NumericStepper();
 * stepper.minimum = 0;
 * stepper.maximum = 100;
 * stepper.step = 1;
 * stepper.value = 12;
 * stepper.addEventListener( Event.CHANGE, stepper_changeHandler );
 * this.addChild( stepper );</listing>
 *
 * @see ../../../help/numeric-stepper.html How to use the Feathers NumericStepper component
 *
 * @productversion Feathers 1.1.0
 */
class NumericStepper extends FeathersControl implements IRange implements IAdvancedNativeFocusOwner implements ITextBaselineControl
{
	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY:String = "decrementButtonFactory";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY:String = "incrementButtonFactory";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_TEXT_INPUT_FACTORY:String = "textInputFactory";

	/**
	 * The default value added to the <code>styleNameList</code> of the decrement
	 * button.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON:String = "feathers-numeric-stepper-decrement-button";

	/**
	 * The default value added to the <code>styleNameList</code> of the increment
	 * button.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON:String = "feathers-numeric-stepper-increment-button";

	/**
	 * The default value added to the <code>styleNameList</code> of the text
	 * input.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_TEXT_INPUT:String = "feathers-numeric-stepper-text-input";
	
	/**
	 * The default <code>IStyleProvider</code> for all <code>NumericStepper</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

	/**
	 * @private
	 */
	private static function defaultDecrementButtonFactory():Button
	{
		return new Button();
	}

	/**
	 * @private
	 */
	private static function defaultIncrementButtonFactory():Button
	{
		return new Button();
	}

	/**
	 * @private
	 */
	private static function defaultTextInputFactory():TextInput
	{
		return new TextInput();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		this.addEventListener(Event.REMOVED_FROM_STAGE, numericStepper_removedFromStageHandler);
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the decrement
	 * button. This variable is <code>protected</code> so that sub-classes
	 * can customize the decrement button style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON</code>.
	 *
	 * <p>To customize the decrement button name without subclassing, see
	 * <code>customDecrementButtonStyleName</code>.</p>
	 *
	 * @see #style:customDecrementButtonStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var decrementButtonStyleName:String = DEFAULT_CHILD_STYLE_NAME_DECREMENT_BUTTON;

	/**
	 * The value added to the <code>styleNameList</code> of the increment
	 * button. This variable is <code>protected</code> so that sub-classes
	 * can customize the increment button style name in their constructors
	 * instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON</code>.
	 *
	 * <p>To customize the increment button name without subclassing, see
	 * <code>customIncrementButtonStyleName</code>.</p>
	 *
	 * @see #style:customIncrementButtonStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var incrementButtonStyleName:String = DEFAULT_CHILD_STYLE_NAME_INCREMENT_BUTTON;

	/**
	 * The value added to the <code>styleNameList</code> of the text input.
	 * This variable is <code>protected</code> so that sub-classes can
	 * customize the text input style name in their constructors instead of
	 * using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_TEXT_INPUT</code>.
	 *
	 * <p>To customize the text input name without subclassing, see
	 * <code>customTextInputStyleName</code>.</p>
	 *
	 * @see #style:customTextInputStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var textInputStyleName:String = DEFAULT_CHILD_STYLE_NAME_TEXT_INPUT;
	
	/**
	 * The decrement button sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #createDecrementButton()
	 */
	private var decrementButton:Button;

	/**
	 * The increment button sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #createIncrementButton()
	 */
	private var incrementButton:Button;

	/**
	 * The text input sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 *
	 * @see #createTextInput()
	 */
	private var textInput:TextInput;

	/**
	 * @private
	 */
	private var textInputExplicitWidth:Float;

	/**
	 * @private
	 */
	private var textInputExplicitHeight:Float;

	/**
	 * @private
	 */
	private var textInputExplicitMinWidth:Float;

	/**
	 * @private
	 */
	private var textInputExplicitMinHeight:Float;

	/**
	 * @private
	 */
	private var touchPointID:Int = -1;

	/**
	 * @private
	 */
	private var _textInputHasFocus:Bool = false;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return NumericStepper.globalStyleProvider;
	}
	
	/**
	 * A text input's text editor may be an <code>INativeFocusOwner</code>,
	 * so we need to return the value of its <code>nativeFocus</code>
	 * property.
	 *
	 * @see feathers.core.INativeFocusOwner
	 */
	public var nativeFocus(get, never):Dynamic;
	private function get_nativeFocus():Dynamic
	{
		if (this.textInput != null)
		{
			return this.textInput.nativeFocus;
		}
		return null;
	}
	
	/**
	 * The value of the numeric stepper, between the minimum and maximum.
	 *
	 * <p>In the following example, the value is changed to 12:</p>
	 *
	 * <listing version="3.0">
	 * stepper.minimum = 0;
	 * stepper.maximum = 100;
	 * stepper.step = 1;
	 * stepper.value = 12;</listing>
	 *
	 * @default 0
	 *
	 * @see #minimum
	 * @see #maximum
	 * @see #step
	 * @see #event:change
	 */
	public var value(get, set):Float;
	private var _value:Float = 0;
	private function get_value():Float { return this._value; }
	private function set_value(newValue:Float):Float
	{
		if (this._step != 0 && newValue != this._maximum && newValue != this._minimum)
		{
			//roundToPrecision helps us to avoid numbers like 1.00000000000000001
			//caused by the inaccuracies of floating point math.
			newValue = MathUtils.roundToPrecision(MathUtils.roundToNearest(newValue - this._minimum, this._step) + this._minimum, 10);
		}
		newValue = MathUtils.clamp(newValue, this._minimum, this._maximum);
		if (this._value == newValue)
		{
			return value;
		}
		this._value = newValue;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.dispatchEventWith(Event.CHANGE);
		return this._value;
	}
	
	/**
	 * The numeric stepper's value will not go lower than the minimum.
	 *
	 * <p>In the following example, the minimum is changed to 0:</p>
	 *
	 * <listing version="3.0">
	 * stepper.minimum = 0;
	 * stepper.maximum = 100;
	 * stepper.step = 1;
	 * stepper.value = 12;</listing>
	 *
	 * @default 0
	 *
	 * @see #value
	 * @see #maximum
	 * @see #step
	 */
	public var minimum(get, set):Float;
	private var _minimum:Float = 0;
	private function get_minimum():Float { return this._minimum; }
	private function set_minimum(value:Float):Float
	{
		if (this._minimum == value)
		{
			return value;
		}
		this._minimum = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._minimum;
	}
	
	/**
	 * The numeric stepper's value will not go higher than the maximum.
	 *
	 * <p>In the following example, the maximum is changed to 100:</p>
	 *
	 * <listing version="3.0">
	 * stepper.minimum = 0;
	 * stepper.maximum = 100;
	 * stepper.step = 1;
	 * stepper.value = 12;</listing>
	 *
	 * @default 0
	 *
	 * @see #value
	 * @see #minimum
	 * @see #step
	 */
	public var maximum(get, set):Float;
	private var _maximum:Float = 0;
	private function get_maximum():Float { return this._maximum; }
	private function set_maximum(value:Float):Float
	{
		if (this._maximum == value)
		{
			return value;
		}
		this._maximum = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._maximum;
	}
	
	/**
	 * As the numeric stepper's buttons are pressed, the value is snapped to
	 * a multiple of the step.
	 *
	 * <p>In the following example, the step is changed to 1:</p>
	 *
	 * <listing version="3.0">
	 * stepper.minimum = 0;
	 * stepper.maximum = 100;
	 * stepper.step = 1;
	 * stepper.value = 12;</listing>
	 *
	 * @default 0
	 *
	 * @see #value
	 * @see #minimum
	 * @see #maximum
	 */
	public var step(get, set):Float;
	private var _step:Float = 0;
	private function get_step():Float { return this._step; }
	private function set_step(value:Float):Float
	{
		if (this._step == value)
		{
			return value;
		}
		return this._step = value;
	}
	
	/**
	 * Indicates if the <code>Keyboard.LEFT</code> and
	 * <code>Keyboard.RIGHT</code> keys should be used to change the value
	 * of the stepper, instead of the default <code>Keyboard.DOWN</code> and
	 * <code>Keyboard.UP</code> keys.
	 *
	 * <p>In the following example, the left and right keys are preferred:</p>
	 *
	 * <listing version="3.0">
	 * stepper.useLeftAndRightKeys = true;</listing>
	 *
	 * @default false
	 */
	public var useLeftAndRightKeys(get, set):Bool;
	private var _useLeftAndRightKeys:Bool = false;
	private function get_useLeftAndRightKeys():Bool { return this._useLeftAndRightKeys; }
	private function set_useLeftAndRightKeys(value:Bool):Bool
	{
		return this._useLeftAndRightKeys = value;
	}
	
	/**
	 * A callback that formats the numeric stepper's value as a string to
	 * display to the user.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function(value:Number):String</pre>
	 *
	 * <p>In the following example, the stepper's value format function is
	 * customized:</p>
	 *
	 * <listing version="3.0">
	 * stepper.valueFormatFunction = function(value:Number):String
	 * {
	 *     return currencyFormatter.format(value, true);
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #valueParseFunction
	 */
	public var valueFormatFunction(get, set):Float->String;
	private var _valueFormatFunction:Float->String;
	private function get_valueFormatFunction():Float->String { return this._valueFormatFunction; }
	private function set_valueFormatFunction(value:Float->String):Float->String
	{
		if (this._valueFormatFunction == value)
		{
			return value;
		}
		this._valueFormatFunction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._valueFormatFunction;
	}
	
	/**
	 * A callback that accepts the displayed text of the numeric stepper and
	 * converts it to a simple numeric value.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function(displayedText:String):Number</pre>
	 *
	 * <p>In the following example, the stepper's value parse function is
	 * customized:</p>
	 *
	 * <listing version="3.0">
	 * stepper.valueParseFunction = function(displayedText:String):Number
	 * {
	 *     return currencyFormatter.parse(displayedText).value;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #valueFormatFunction
	 */
	public var valueParseFunction(get, set):String->Float;
	private var _valueParseFunction:String->Float;
	private function get_valueParseFunction():String->Float { return this._valueParseFunction; }
	private function set_valueParseFunction(value:String->Float):String->Float
	{
		return this._valueParseFunction = value;
	}
	
	/**
	 * @private
	 */
	private var currentRepeatAction:Function;

	/**
	 * @private
	 */
	private var _repeatTimer:Timer;
	
	/**
	 * The time, in seconds, before actions are repeated. The first repeat
	 * happens after a delay that is five times longer than the following
	 * repeats.
	 *
	 * <p>In the following example, the stepper's repeat delay is set to
	 * 500 milliseconds:</p>
	 *
	 * <listing version="3.0">
	 * stepper.repeatDelay = 0.5;</listing>
	 *
	 * @default 0.05
	 */
	public var repeatDelay(get, set):Float;
	private var _repeatDelay:Float = 0.05;
	private function get_repeatDelay():Float { return this._repeatDelay; }
	private function set_repeatDelay(value:Float):Float
	{
		if (this._repeatDelay == value)
		{
			return value;
		}
		this._repeatDelay = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._repeatDelay;
	}
	
	/**
	 * @private
	 */
	public var buttonLayoutMode(get, set):String;
	private var _buttonLayoutMode:String = StepperButtonLayoutMode.SPLIT_HORIZONTAL;
	private function get_buttonLayoutMode():String { return this._buttonLayoutMode; }
	private function set_buttonLayoutMode(value:String):String
	{
		if (this.processStyleRestriction("buttonLayoutMode"))
		{
			return value;
		}
		if (this._buttonLayoutMode == value)
		{
			return value;
		}
		this._buttonLayoutMode = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._buttonLayoutMode;
	}
	
	/**
	 * @private
	 */
	public var buttonGap(get, set):Float;
	private var _buttonGap:Float = 0;
	private function get_buttonGap():Float { return this._buttonGap; }
	private function set_buttonGap(value:Float):Float
	{
		if (this.processStyleRestriction("buttonGap"))
		{
			return value;
		}
		if (this._buttonGap == value)
		{
			return value;
		}
		this._buttonGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._buttonGap;
	}
	
	/**
	 * @private
	 */
	public var textInputGap(get, set):Float;
	private var _textInputGap:Float = 0;
	private function get_textInputGap():Float { return this._textInputGap; }
	private function set_textInputGap(value:Float):Float
	{
		if (this.processStyleRestriction("textInputGap"))
		{
			return value;
		}
		if (this._textInputGap == value)
		{
			return value;
		}
		this._textInputGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textInputGap;
	}
	
	/**
	 * A function used to generate the numeric stepper's decrement button
	 * sub-component. The decrement button must be an instance of
	 * <code>Button</code>. This factory can be used to change properties on
	 * the decrement button when it is first created. For instance, if you
	 * are skinning Feathers components without a theme, you might use this
	 * factory to set skins and other styles on the decrement button.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():Button</pre>
	 *
	 * <p>In the following example, a custom decrement button factory is passed
	 * to the stepper:</p>
	 *
	 * <listing version="3.0">
	 * stepper.decrementButtonFactory = function():Button
	 * {
	 *     var button:Button = new Button();
	 *     button.defaultSkin = new Image( upTexture );
	 *     button.downSkin = new Image( downTexture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
	 */
	public var decrementButtonFactory(get, set):Function;
	private var _decrementButtonFactory:Function;
	private function get_decrementButtonFactory():Function { return this._decrementButtonFactory; }
	private function set_decrementButtonFactory(value:Function):Function
	{
		if (this._decrementButtonFactory == value)
		{
			return value;
		}
		this._decrementButtonFactory = value;
		this.invalidate(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		return this._decrementButtonFactory;
	}
	
	/**
	 * @private
	 */
	public var customDecrementButtonStyleName(get, set):String;
	private var _customDecrementButtonStyleName:String;
	private function get_customDecrementButtonStyleName():String { return this._customDecrementButtonStyleName; }
	private function set_customDecrementButtonStyleName(value:String):String
	{
		if (this.processStyleRestriction("customDecrementButtonStyleName"))
		{
			return value;
		}
		if (this._customDecrementButtonStyleName == value)
		{
			return value;
		}
		this._customDecrementButtonStyleName = value;
		this.invalidate(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		return this._customDecrementButtonStyleName;
	}
	
	/**
	 * An object that stores properties for the numeric stepper's decrement
	 * button sub-component, and the properties will be passed down to the
	 * decrement button when the numeric stepper validates. For a list of
	 * available properties, refer to <a href="Button.html"><code>feathers.controls.Button</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>decrementButtonFactory</code>
	 * function instead of using <code>decrementButtonProperties</code> will
	 * result in better performance.</p>
	 *
	 * <p>In the following example, the stepper's decrement button properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * stepper.decrementButtonProperties.defaultSkin = new Image( upTexture );
	 * stepper.decrementButtonProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #decrementButtonFactory
	 * @see feathers.controls.Button
	 */
	public var decrementButtonProperties(get, set):PropertyProxy;
	private var _decrementButtonProperties:PropertyProxy;
	private function get_decrementButtonProperties():PropertyProxy
	{
		if (this._decrementButtonProperties == null)
		{
			this._decrementButtonProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._decrementButtonProperties;
	}
	
	private function set_decrementButtonProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._decrementButtonProperties == value)
		{
			return value;
		}
		if (this._decrementButtonProperties != null)
		{
			this._decrementButtonProperties.dispose();
		}
		this._decrementButtonProperties = value;
		if (this._decrementButtonProperties != null)
		{
			this._decrementButtonProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._decrementButtonProperties;
	}
	
	/**
	 * @private
	 */
	public var decrementButtonLabel(get, set):String;
	private var _decrementButtonLabel:String;
	private function get_decrementButtonLabel():String { return this._decrementButtonLabel; }
	private function set_decrementButtonLabel(value:String):String
	{
		if (this.processStyleRestriction("decrementButtonLabel"))
		{
			return value;
		}
		if (this._decrementButtonLabel == value)
		{
			return value;
		}
		this._decrementButtonLabel = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._decrementButtonLabel;
	}
	
	/**
	 * A function used to generate the numeric stepper's increment button
	 * sub-component. The increment button must be an instance of
	 * <code>Button</code>. This factory can be used to change properties on
	 * the increment button when it is first created. For instance, if you
	 * are skinning Feathers components without a theme, you might use this
	 * factory to set skins and other styles on the increment button.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():Button</pre>
	 *
	 * <p>In the following example, a custom increment button factory is passed
	 * to the stepper:</p>
	 *
	 * <listing version="3.0">
	 * stepper.incrementButtonFactory = function():Button
	 * {
	 *     var button:Button = new Button();
	 *     button.defaultSkin = new Image( upTexture );
	 *     button.downSkin = new Image( downTexture );
	 *     return button;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
	 */
	public var incrementButtonFactory(get, set):Function;
	private var _incrementButtonFactory:Function;
	private function get_incrementButtonFactory():Function { return this._incrementButtonFactory; }
	private function set_incrementButtonFactory(value:Function):Function
	{
		if (this._incrementButtonFactory == value)
		{
			return value;
		}
		this._incrementButtonFactory = value;
		this.invalidate(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		return this._incrementButtonFactory;
	}
	
	/**
	 * @private
	 */
	public var customIncrementButtonStyleName(get, set):String;
	private var _customIncrementButtonStyleName:String;
	private function get_customIncrementButtonStyleName():String { return this._customIncrementButtonStyleName; }
	private function set_customIncrementButtonStyleName(value:String):String
	{
		if (this.processStyleRestriction("customIncrementButtonStyleName"))
		{
			return value;
		}
		if (this._customIncrementButtonStyleName == value)
		{
			return value;
		}
		this._customIncrementButtonStyleName = value;
		this.invalidate(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		return this._customIncrementButtonStyleName;
	}
	
	/**
	 * An object that stores properties for the numeric stepper's increment
	 * button sub-component, and the properties will be passed down to the
	 * increment button when the numeric stepper validates. For a list of
	 * available properties, refer to <a href="Button.html"><code>feathers.controls.Button</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>incrementButtonFactory</code>
	 * function instead of using <code>incrementButtonProperties</code> will
	 * result in better performance.</p>
	 *
	 * <p>In the following example, the stepper's increment button properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * stepper.incrementButtonProperties.defaultSkin = new Image( upTexture );
	 * stepper.incrementButtonProperties.downSkin = new Image( downTexture );</listing>
	 *
	 * @default null
	 *
	 * @see #incrementButtonFactory
	 * @see feathers.controls.Button
	 */
	public var incrementButtonProperties(get, set):PropertyProxy;
	private var _incrementButtonProperties:PropertyProxy;
	private function get_incrementButtonProperties():PropertyProxy
	{
		if (this._incrementButtonProperties == null)
		{
			this._incrementButtonProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._incrementButtonProperties;
	}
	
	private function set_incrementButtonProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._incrementButtonProperties == value)
		{
			return value;
		}
		if (this._incrementButtonProperties != null)
		{
			this._incrementButtonProperties.dispose();
		}
		this._incrementButtonProperties = value;
		if (this._incrementButtonProperties != null)
		{
			this._incrementButtonProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._incrementButtonProperties;
	}
	
	/**
	 * @private
	 */
	public var incrementButtonLabel(get, set):String;
	private var _incrementButtonLabel:String;
	private function get_incrementButtonLabel():String { return this._incrementButtonLabel; }
	private function set_incrementButtonLabel(value:String):String
	{
		if (this.processStyleRestriction("incrementButtonLabel"))
		{
			return value;
		}
		if (this._incrementButtonLabel == value)
		{
			return value;
		}
		this._incrementButtonLabel = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._incrementButtonLabel;
	}
	
	/**
	 * A function used to generate the numeric stepper's text input
	 * sub-component. The text input must be an instance of <code>TextInput</code>.
	 * This factory can be used to change properties on the text input when
	 * it is first created. For instance, if you are skinning Feathers
	 * components without a theme, you might use this factory to set skins
	 * and other styles on the text input.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():TextInput</pre>
	 *
	 * <p>In the following example, a custom text input factory is passed
	 * to the stepper:</p>
	 *
	 * <listing version="3.0">
	 * stepper.textInputFactory = function():TextInput
	 * {
	 *     var textInput:TextInput = new TextInput();
	 *     textInput.backgroundSkin = new Image( texture );
	 *     return textInput;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.TextInput
	 */
	public var textInputFactory(get, set):Function;
	private var _textInputFactory:Function;
	private function get_textInputFactory():Function { return this._textInputFactory; }
	private function set_textInputFactory(value:Function):Function
	{
		if (this._textInputFactory == value)
		{
			return value;
		}
		this._textInputFactory = value;
		this.invalidate(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);
		return this._textInputFactory;
	}
	
	/**
	 * @private
	 */
	public var customTextInputStyleName(get, set):String;
	private var _customTextInputStyleName:String;
	private function get_customTextInputStyleName():String { return this._customTextInputStyleName; }
	private function set_customTextInputStyleName(value:String):String
	{
		if (this.processStyleRestriction("customTextInputStyleName"))
		{
			return value;
		}
		if (this._customTextInputStyleName == value)
		{
			return value;
		}
		this._customTextInputStyleName = value;
		this.invalidate(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);
		return this._customTextInputStyleName;
	}
	
	/**
	 * An object that stores properties for the numeric stepper's text
	 * input sub-component, and the properties will be passed down to the
	 * text input when the numeric stepper validates. For a list of
	 * available properties, refer to <a href="TextInput.html"><code>feathers.controls.TextInput</code></a>.
	 *
	 * <p>If the subcomponent has its own subcomponents, their properties
	 * can be set too, using attribute <code>&#64;</code> notation. For example,
	 * to set the skin on the thumb which is in a <code>SimpleScrollBar</code>,
	 * which is in a <code>List</code>, you can use the following syntax:</p>
	 * <pre>list.verticalScrollBarProperties.&#64;thumbProperties.defaultSkin = new Image(texture);</pre>
	 *
	 * <p>Setting properties in a <code>textInputFactory</code> function
	 * instead of using <code>textInputProperties</code> will result in
	 * better performance.</p>
	 *
	 * <p>In the following example, the stepper's text input properties
	 * are updated:</p>
	 *
	 * <listing version="3.0">
	 * stepper.textInputProperties.backgroundSkin = new Image( texture );</listing>
	 *
	 * @default null
	 *
	 * @see #textInputFactory
	 * @see feathers.controls.TextInput
	 */
	public var textInputProperties(get, set):PropertyProxy;
	private var _textInputProperties:PropertyProxy;
	private function get_textInputProperties():PropertyProxy
	{
		if (this._textInputProperties == null)
		{
			this._textInputProperties = new PropertyProxy(childProperties_onChange);
		}
		return this._textInputProperties;
	}
	
	private function set_textInputProperties(value:PropertyProxy):PropertyProxy
	{
		if (this._textInputProperties == value)
		{
			return value;
		}
		//if (value != null && !Std.isOfType(value, PropertyProxyReal))
		//{
			//value = PropertyProxy.fromObject(value);
		//}
		if (this._textInputProperties != null)
		{
			this._textInputProperties.dispose();
		}
		this._textInputProperties = value;
		if (this._textInputProperties != null)
		{
			this._textInputProperties.addOnChangeCallback(childProperties_onChange);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._textInputProperties;
	}
	
	/**
	 * @inheritDoc
	 */
	public var baseline(get, never):Float;
	private function get_baseline():Float
	{
		if (this.textInput == null)
		{
			return this.scaledActualHeight;
		}
		return this.scaleY * (this.textInput.y + this.textInput.baseline);
	}
	
	/**
	 * @private
	 */
	public var hasFocus(get, never):Bool;
	private function get_hasFocus():Bool { return this._hasFocus; }
	
	/**
	 * @private
	 */
	public function setFocus():Void
	{
		if (this.textInput == null)
		{
			return;
		}
		this.textInput.setFocus();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var decrementButtonFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_DECREMENT_BUTTON_FACTORY);
		var incrementButtonFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_INCREMENT_BUTTON_FACTORY);
		var textInputFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_TEXT_INPUT_FACTORY);
		var focusInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_FOCUS);
		
		if (decrementButtonFactoryInvalid)
		{
			this.createDecrementButton();
		}
		
		if (incrementButtonFactoryInvalid)
		{
			this.createIncrementButton();
		}
		
		if (textInputFactoryInvalid)
		{
			this.createTextInput();
		}
		
		if (decrementButtonFactoryInvalid || stylesInvalid)
		{
			this.refreshDecrementButtonStyles();
		}
		
		if (incrementButtonFactoryInvalid || stylesInvalid)
		{
			this.refreshIncrementButtonStyles();
		}
		
		if (textInputFactoryInvalid || stylesInvalid)
		{
			this.refreshTextInputStyles();
		}
		
		if (textInputFactoryInvalid || dataInvalid)
		{
			this.refreshTypicalText();
			this.refreshDisplayedText();
		}
		
		if (decrementButtonFactoryInvalid || stateInvalid)
		{
			this.decrementButton.isEnabled = this._isEnabled;
		}
		
		if (incrementButtonFactoryInvalid || stateInvalid)
		{
			this.incrementButton.isEnabled = this._isEnabled;
		}
		
		if (textInputFactoryInvalid || stateInvalid)
		{
			this.textInput.isEnabled = this._isEnabled;
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		
		this.layoutChildren();
		
		if (sizeInvalid || focusInvalid)
		{
			this.refreshFocusIndicator();
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
		
		var newWidth:Float = this._explicitWidth;
		var newHeight:Float = this._explicitHeight;
		var newMinWidth:Float = this._explicitMinWidth;
		var newMinHeight:Float = this._explicitMinHeight;
		
		this.decrementButton.validate();
		this.incrementButton.validate();
		var decrementButtonWidth:Float = this.decrementButton.width;
		var decrementButtonHeight:Float = this.decrementButton.height;
		var decrementButtonMinWidth:Float = this.decrementButton.minWidth;
		var decrementButtonMinHeight:Float = this.decrementButton.minHeight;
		var incrementButtonWidth:Float = this.incrementButton.width;
		var incrementButtonHeight:Float = this.incrementButton.height;
		var incrementButtonMinWidth:Float = this.incrementButton.minWidth;
		var incrementButtonMinHeight:Float = this.incrementButton.minHeight;
		
		//we'll default to the values set in the textInputFactory
		var textInputWidth:Float = this.textInputExplicitWidth;
		var textInputHeight:Float = this.textInputExplicitHeight;
		var textInputMinWidth:Float = this.textInputExplicitMinWidth;
		var textInputMinHeight:Float = this.textInputExplicitMinHeight;
		var textInputMaxWidth:Float = Math.POSITIVE_INFINITY;
		var textInputMaxHeight:Float = Math.POSITIVE_INFINITY;
		
		var maxButtonWidth:Float = 0;
		var maxButtonMinWidth:Float = 0;
		if (this._buttonLayoutMode == StepperButtonLayoutMode.RIGHT_SIDE_VERTICAL)
		{
			maxButtonWidth = decrementButtonWidth;
			if (incrementButtonWidth > maxButtonWidth)
			{
				maxButtonWidth = incrementButtonWidth;
			}
			maxButtonMinWidth = decrementButtonMinWidth;
			if (incrementButtonMinWidth > maxButtonMinWidth)
			{
				maxButtonMinWidth = incrementButtonMinWidth;
			}
			
			if (!needsWidth)
			{
				textInputWidth = this._explicitWidth - maxButtonWidth - this._textInputGap;
			}
			if (!needsHeight)
			{
				textInputHeight = this._explicitHeight;
			}
			if (!needsMinWidth)
			{
				textInputMinWidth = this._explicitMinWidth - maxButtonMinWidth - this._textInputGap;
				if (this.textInputExplicitMinWidth > textInputMinWidth)
				{
					textInputMinWidth = this.textInputExplicitMinWidth;
				}
			}
			if (!needsMinHeight)
			{
				textInputMinHeight = this._explicitMinHeight;
				if (this.textInputExplicitMinHeight > textInputMinHeight)
				{
					textInputMinHeight = this.textInputExplicitMinHeight;
				}
			}
			textInputMaxWidth = this._explicitMaxWidth - maxButtonWidth - this._textInputGap;
		}
		else if (this._buttonLayoutMode == StepperButtonLayoutMode.SPLIT_VERTICAL)
		{
			if (!needsWidth)
			{
				textInputWidth = this._explicitWidth;
			}
			if (!needsHeight)
			{
				textInputHeight = this._explicitHeight - decrementButtonHeight - incrementButtonHeight;
			}
			if (!needsMinWidth)
			{
				textInputMinWidth = this._explicitMinWidth;
				if (this.textInputExplicitMinWidth > textInputMinWidth)
				{
					textInputMinWidth = this.textInputExplicitMinWidth;
				}
			}
			if (!needsMinHeight)
			{
				textInputMinHeight = this._explicitMinHeight - decrementButtonMinHeight - incrementButtonMinHeight;
				if (this.textInputExplicitMinHeight > textInputMinHeight)
				{
					textInputMinHeight = this.textInputExplicitMinHeight;
				}
			}
			textInputMaxHeight = this._explicitMaxHeight - decrementButtonHeight - incrementButtonHeight;
		}
		else //split horizontal
		{
			if (!needsWidth)
			{
				textInputWidth = this._explicitWidth - decrementButtonWidth - incrementButtonWidth;
			}
			if (!needsHeight)
			{
				textInputHeight = this._explicitHeight;
			}
			if (!needsMinWidth)
			{
				textInputMinWidth = this._explicitMinWidth - decrementButtonMinWidth - incrementButtonMinWidth;
				if (textInputMinWidth < this.textInputExplicitMinWidth)
				{
					textInputMinWidth = this.textInputExplicitMinWidth;
				}
			}
			if (!needsMinHeight)
			{
				textInputMinHeight = this._explicitMinHeight;
				if (this.textInputExplicitMinHeight > textInputMinHeight)
				{
					textInputMinHeight = this.textInputExplicitMinHeight;
				}
			}
			textInputMaxWidth = this._explicitMaxWidth - decrementButtonWidth - incrementButtonWidth;
		}
		
		if (textInputWidth < 0)
		{
			textInputWidth = 0;
		}
		if (textInputHeight < 0)
		{
			textInputHeight = 0;
		}
		if (textInputMinWidth < 0)
		{
			textInputMinWidth = 0;
		}
		if (textInputMinHeight < 0)
		{
			textInputMinHeight = 0;
		}
		this.textInput.width = textInputWidth;
		this.textInput.height = textInputHeight;
		this.textInput.minWidth = textInputMinWidth;
		this.textInput.minHeight = textInputMinHeight;
		this.textInput.maxWidth = textInputMaxWidth;
		this.textInput.maxHeight = textInputMaxHeight;
		this.textInput.validate();
		
		if (this._buttonLayoutMode == StepperButtonLayoutMode.RIGHT_SIDE_VERTICAL)
		{
			if (needsWidth)
			{
				newWidth = this.textInput.width + maxButtonWidth + this._textInputGap;
			}
			if (needsHeight)
			{
				newHeight = decrementButtonHeight + this._buttonGap + incrementButtonHeight;
				if (this.textInput.height > newHeight)
				{
					newHeight = this.textInput.height;
				}
			}
			if (needsMinWidth)
			{
				newMinWidth = this.textInput.minWidth + maxButtonMinWidth + this._textInputGap;
			}
			if (needsMinHeight)
			{
				newMinHeight = decrementButtonMinHeight + this._buttonGap + incrementButtonMinHeight;
				if (this.textInput.minHeight > newMinHeight)
				{
					newMinHeight = this.textInput.minHeight;
				}
			}
		}
		else if (this._buttonLayoutMode == StepperButtonLayoutMode.SPLIT_VERTICAL)
		{
			if (needsWidth)
			{
				newWidth = this.textInput.width;
				if (decrementButtonWidth > newWidth)
				{
					newWidth = decrementButtonWidth;
				}
				if (incrementButtonWidth > newWidth)
				{
					newWidth = incrementButtonWidth;
				}
			}
			if (needsHeight)
			{
				newHeight = decrementButtonHeight + this.textInput.height + incrementButtonHeight + 2 * this._textInputGap;
			}
			if (needsMinWidth)
			{
				newMinWidth = this.textInput.minWidth;
				if (decrementButtonMinWidth > newMinWidth)
				{
					newMinWidth = decrementButtonMinWidth;
				}
				if (incrementButtonMinWidth > newMinWidth)
				{
					newMinWidth = incrementButtonMinWidth;
				}
			}
			if (needsMinHeight)
			{
				newMinHeight = decrementButtonMinHeight + this.textInput.minHeight + incrementButtonMinHeight + 2 * this._textInputGap;
			}
		}
		else //split horizontal
		{
			if (needsWidth)
			{
				newWidth = decrementButtonWidth + this.textInput.width + incrementButtonWidth + 2 * this._textInputGap;
			}
			if (needsHeight)
			{
				newHeight = this.textInput.height;
				if (decrementButtonHeight > newHeight)
				{
					newHeight = decrementButtonHeight;
				}
				if (incrementButtonHeight > newHeight)
				{
					newHeight = incrementButtonHeight;
				}
			}
			if (needsMinWidth)
			{
				newMinWidth = decrementButtonMinWidth + this.textInput.minWidth + incrementButtonMinWidth + 2 * this._textInputGap;
			}
			if (needsMinHeight)
			{
				newMinHeight = this.textInput.minHeight;
				if (decrementButtonMinHeight > newMinHeight)
				{
					newMinHeight = decrementButtonMinHeight;
				}
				if (incrementButtonMinHeight > newMinHeight)
				{
					newMinHeight = incrementButtonMinHeight;
				}
			}
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	private function decrement():Void
	{
		this.value = this._value - this._step;
		this.validate();
		this.textInput.selectRange(0, this.textInput.text.length);
	}

	/**
	 * @private
	 */
	private function increment():Void
	{
		this.value = this._value + this._step;
		this.validate();
		this.textInput.selectRange(0, this.textInput.text.length);
	}
	
	/**
	 * @private
	 */
	private function toMinimum():Void
	{
		this.value = this._minimum;
		this.validate();
		this.textInput.selectRange(0, this.textInput.text.length);
	}

	/**
	 * @private
	 */
	private function toMaximum():Void
	{
		this.value = this._maximum;
		this.validate();
		this.textInput.selectRange(0, this.textInput.text.length);
	}
	
	/**
	 * Creates and adds the <code>decrementButton</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #decrementButton
	 * @see #decrementButtonFactory
	 * @see #style:customDecrementButtonStyleName
	 */
	private function createDecrementButton():Void
	{
		if (this.decrementButton != null)
		{
			this.decrementButton.removeFromParent(true);
			this.decrementButton = null;
		}
		
		var factory:Function = this._decrementButtonFactory != null ? this._decrementButtonFactory : defaultDecrementButtonFactory;
		var decrementButtonStyleName:String = this._customDecrementButtonStyleName != null ? this._customDecrementButtonStyleName : this.decrementButtonStyleName;
		this.decrementButton = cast factory();
		this.decrementButton.styleNameList.add(decrementButtonStyleName);
		this.decrementButton.addEventListener(TouchEvent.TOUCH, decrementButton_touchHandler);
		this.addChild(this.decrementButton);
	}
	
	/**
	 * Creates and adds the <code>incrementButton</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #incrementButton
	 * @see #incrementButtonFactory
	 * @see #style:customIncrementButtonStyleName
	 */
	private function createIncrementButton():Void
	{
		if (this.incrementButton != null)
		{
			this.incrementButton.removeFromParent(true);
			this.incrementButton = null;
		}
		
		var factory:Function = this._incrementButtonFactory != null ? this._incrementButtonFactory : defaultIncrementButtonFactory;
		var incrementButtonStyleName:String = this._customIncrementButtonStyleName != null ? this._customIncrementButtonStyleName : this.incrementButtonStyleName;
		this.incrementButton = cast factory();
		this.incrementButton.styleNameList.add(incrementButtonStyleName);
		this.incrementButton.addEventListener(TouchEvent.TOUCH, incrementButton_touchHandler);
		this.addChild(this.incrementButton);
	}
	
	/**
	 * Creates and adds the <code>textInput</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #textInput
	 * @see #textInputFactory
	 * @see #style:customTextInputStyleName
	 */
	private function createTextInput():Void
	{
		if (this.textInput != null)
		{
			this.textInput.removeFromParent(true);
			this.textInput = null;
		}
		
		var factory:Function = this._textInputFactory != null ? this._textInputFactory : defaultTextInputFactory;
		var textInputStyleName:String = this._customTextInputStyleName != null ? this._customTextInputStyleName : this.textInputStyleName;
		this.textInput = cast factory();
		this.textInput.styleNameList.add(textInputStyleName);
		this.textInput.addEventListener(FeathersEventType.ENTER, textInput_enterHandler);
		this.textInput.addEventListener(FeathersEventType.FOCUS_IN, textInput_focusInHandler);
		this.textInput.addEventListener(FeathersEventType.FOCUS_OUT, textInput_focusOutHandler);
		//while we're setting isFocusEnabled to false on the text input when
		//we have a focus manager, we'll still be able to call setFocus() on
		//the text input manually.
		this.textInput.isFocusEnabled = this._focusManager == null;
		this.addChild(this.textInput);
		
		//we will use these values for measurement, if possible
		this.textInput.initializeNow();
		this.textInputExplicitWidth = this.textInput.explicitWidth;
		this.textInputExplicitHeight = this.textInput.explicitHeight;
		this.textInputExplicitMinWidth = this.textInput.explicitMinWidth;
		this.textInputExplicitMinHeight = this.textInput.explicitMinHeight;
	}
	
	/**
	 * @private
	 */
	private function refreshDecrementButtonStyles():Void
	{
		if (this._decrementButtonProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._decrementButtonProperties)
			{
				propertyValue = this._decrementButtonProperties[propertyName];
				Property.write(this.decrementButton, propertyName, propertyValue);
			}
		}
		this.decrementButton.label = this._decrementButtonLabel;
	}

	/**
	 * @private
	 */
	private function refreshIncrementButtonStyles():Void
	{
		if (this._decrementButtonProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._incrementButtonProperties)
			{
				propertyValue = this._incrementButtonProperties[propertyName];
				Property.write(this.incrementButton, propertyName, propertyValue);
			}
		}
		this.incrementButton.label = this._incrementButtonLabel;
	}

	/**
	 * @private
	 */
	private function refreshTextInputStyles():Void
	{
		if (this._textInputProperties != null)
		{
			var propertyValue:Dynamic;
			for (propertyName in this._textInputProperties)
			{
				propertyValue = this._textInputProperties[propertyName];
				Property.write(this.textInput, propertyName, propertyValue);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshDisplayedText():Void
	{
		if (this._valueFormatFunction != null)
		{
			this.textInput.text = this._valueFormatFunction(this._value);
		}
		else
		{
			this.textInput.text = Std.string(this._value);
		}
	}
	
	/**
	 * @private
	 */
	private function refreshTypicalText():Void
	{
		var typicalText:String = "";
		var maxCharactersBeforeDecimal:Float = Math.max(Std.string(Std.int((this._minimum))).length, Std.string(Std.int((this._maximum))).length);
		maxCharactersBeforeDecimal = Math.max(maxCharactersBeforeDecimal, Std.string(Std.int((this._step))).length);
		//roundToPrecision() helps us to avoid numbers like 1.00000000000000001
		//caused by the inaccuracies of floating point math.
		var maxCharactersAfterDecimal:Float = Math.max(Std.string(MathUtils.roundToPrecision(this._minimum - Std.int(this._minimum), 10)).length,
			Std.string(MathUtils.roundToPrecision(this._maximum - Std.int(this._maximum), 10)).length);
		maxCharactersAfterDecimal = Math.max(maxCharactersAfterDecimal, Std.string(MathUtils.roundToPrecision(this._step - Std.int(this._step), 10)).length) - 2;
		if (maxCharactersAfterDecimal < 0)
		{
			maxCharactersAfterDecimal = 0;
		}
		var characterCount:Int = Std.int(maxCharactersBeforeDecimal + maxCharactersAfterDecimal);
		for (i in 0...characterCount)
		{
			typicalText += "0";
		}
		if (maxCharactersAfterDecimal != 0)
		{
			typicalText += ".";
		}
		this.textInput.typicalText = typicalText;
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
		if (this._buttonLayoutMode == StepperButtonLayoutMode.RIGHT_SIDE_VERTICAL)
		{
			var buttonHeight:Float = (this.actualHeight - this._buttonGap) / 2;
			this.incrementButton.y = 0;
			this.incrementButton.height = buttonHeight;
			this.incrementButton.validate();
			
			this.decrementButton.y = buttonHeight + this._buttonGap;
			this.decrementButton.height = buttonHeight;
			this.decrementButton.validate();
			
			var buttonWidth:Float = Math.max(this.decrementButton.width, this.incrementButton.width);
			var buttonX:Float = this.actualWidth - buttonWidth;
			this.decrementButton.x = buttonX;
			this.incrementButton.x = buttonX;
			
			this.textInput.x = 0;
			this.textInput.y = 0;
			this.textInput.width = buttonX - this._textInputGap;
			this.textInput.height = this.actualHeight;
		}
		else if (this._buttonLayoutMode == StepperButtonLayoutMode.SPLIT_VERTICAL)
		{
			this.incrementButton.x = 0;
			this.incrementButton.y = 0;
			this.incrementButton.width = this.actualWidth;
			this.incrementButton.validate();
			
			this.decrementButton.x = 0;
			this.decrementButton.width = this.actualWidth;
			this.decrementButton.validate();
			this.decrementButton.y = this.actualHeight - this.decrementButton.height;
			
			this.textInput.x = 0;
			this.textInput.y = this.incrementButton.height + this._textInputGap;
			this.textInput.width = this.actualWidth;
			this.textInput.height = Math.max(0, this.actualHeight - this.decrementButton.height - this.incrementButton.height - 2 * this._textInputGap);
		}
		else //split horizontal
		{
			this.decrementButton.x = 0;
			this.decrementButton.y = 0;
			this.decrementButton.height = this.actualHeight;
			this.decrementButton.validate();
			
			this.incrementButton.y = 0;
			this.incrementButton.height = this.actualHeight;
			this.incrementButton.validate();
			this.incrementButton.x = this.actualWidth - this.incrementButton.width;
			
			this.textInput.x = this.decrementButton.width + this._textInputGap;
			this.textInput.width = this.actualWidth - this.decrementButton.width - this.incrementButton.width - 2 * this._textInputGap;
			this.textInput.height = this.actualHeight;
		}
		
		//final validation to avoid juggler next frame issues
		this.textInput.validate();
	}
	
	/**
	 * @private
	 */
	private function startRepeatTimer(action:Function):Void
	{
		if (this.touchPointID != -1)
		{
			var exclusiveTouch:ExclusiveTouch = ExclusiveTouch.forStage(this.stage);
			var claim:DisplayObject = exclusiveTouch.getClaim(this.touchPointID);
			if (claim != this)
			{
				if (claim != null)
				{
					//already claimed by another display object
					return;
				}
				else
				{
					exclusiveTouch.claimTouch(this.touchPointID, this);
				}
			}
		}
		this.currentRepeatAction = action;
		if (this._repeatDelay > 0)
		{
			if (this._repeatTimer == null)
			{
				this._repeatTimer = new Timer(this._repeatDelay * 1000);
				this._repeatTimer.addEventListener(TimerEvent.TIMER, repeatTimer_timerHandler);
			}
			else
			{
				this._repeatTimer.reset();
				this._repeatTimer.delay = this._repeatDelay * 1000;
			}
			this._repeatTimer.start();
		}
	}
	
	/**
	 * @private
	 */
	private function parseTextInputValue():Void
	{
		var newValue:Float;
		if (this._valueParseFunction != null)
		{
			newValue = this._valueParseFunction(this.textInput.text);
		}
		else
		{
			newValue = Std.parseFloat(this.textInput.text);
		}
		if (newValue == newValue) //!isNaN
		{
			this.value = newValue;
		}
		//we need to force invalidation just to be sure that the text input
		//is displaying the correct value.
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
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
	private function numericStepper_removedFromStageHandler(event:Event):Void
	{
		this.touchPointID = -1;
	}
	
	/**
	 * @private
	 */
	override function focusInHandler(event:Event):Void
	{
		super.focusInHandler(event);
		this.textInput.setFocus();
		this.textInput.selectRange(0, this.textInput.text.length);
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
	}
	
	/**
	 * @private
	 */
	override function focusOutHandler(event:Event):Void
	{
		super.focusOutHandler(event);
		this.textInput.clearFocus();
		this.stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
	}
	
	/**
	 * @private
	 */
	private function textInput_enterHandler(event:Event):Void
	{
		this.parseTextInputValue();
	}

	/**
	 * @private
	 */
	private function textInput_focusInHandler(event:Event):Void
	{
		this._textInputHasFocus = true;
	}

	/**
	 * @private
	 */
	private function textInput_focusOutHandler(event:Event):Void
	{
		this._textInputHasFocus = false;
		this.parseTextInputValue();
	}
	
	/**
	 * @private
	 */
	private function decrementButton_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this.touchPointID = -1;
			return;
		}
		
		var touch:Touch;
		if (this.touchPointID != -1)
		{
			touch = event.getTouch(this.decrementButton, TouchPhase.ENDED, this.touchPointID);
			if (touch == null)
			{
				return;
			}
			this.touchPointID = -1;
			this._repeatTimer.stop();
			this.dispatchEventWith(FeathersEventType.END_INTERACTION);
		}
		else //if we get here, we don't have a saved touch ID yet
		{
			touch = event.getTouch(this.decrementButton, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			if (this._textInputHasFocus)
			{
				this.parseTextInputValue();
			}
			this.touchPointID = touch.id;
			this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
			this.decrement();
			this.startRepeatTimer(this.decrement);
		}
	}
	
	/**
	 * @private
	 */
	private function incrementButton_touchHandler(event:TouchEvent):Void
	{
		if (!this._isEnabled)
		{
			this.touchPointID = -1;
			return;
		}
		
		var touch:Touch;
		if (this.touchPointID != -1)
		{
			touch = event.getTouch(this.incrementButton, TouchPhase.ENDED, this.touchPointID);
			if (touch == null)
			{
				return;
			}
			this.touchPointID = -1;
			this._repeatTimer.stop();
			this.dispatchEventWith(FeathersEventType.END_INTERACTION);
		}
		else //if we get here, we don't have a saved touch ID yet
		{
			touch = event.getTouch(this.incrementButton, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			if (this._textInputHasFocus)
			{
				this.parseTextInputValue();
			}
			this.touchPointID = touch.id;
			this.dispatchEventWith(FeathersEventType.BEGIN_INTERACTION);
			this.increment();
			this.startRepeatTimer(this.increment);
		}
	}
	
	/**
	 * @private
	 */
	private function stage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.keyCode == Keyboard.HOME)
		{
			//prevent default so that text input selection doesn't change
			event.preventDefault();
			this.toMinimum();
		}
		else if (event.keyCode == Keyboard.END)
		{
			//prevent default so that text input selection doesn't change
			event.preventDefault();
			this.toMaximum();
		}
		else if (this._useLeftAndRightKeys)
		{
			if (event.keyCode == Keyboard.RIGHT)
			{
				//prevent default so that text input selection doesn't change
				event.preventDefault();
				this.increment();
			}
			else if (event.keyCode == Keyboard.LEFT)
			{
				//prevent default so that text input selection doesn't change
				event.preventDefault();
				this.decrement();
			}
		}
		else if (event.keyCode == Keyboard.UP)
		{
			//prevent default so that text input selection doesn't change
			event.preventDefault();
			this.increment();
		}
		else if (event.keyCode == Keyboard.DOWN)
		{
			//prevent default so that text input selection doesn't change
			event.preventDefault();
			this.decrement();
		}
	}
	
	/**
	 * @private
	 */
	private function repeatTimer_timerHandler(event:TimerEvent):Void
	{
		if (this._repeatTimer.currentCount < 5)
		{
			return;
		}
		this.currentRepeatAction();
	}
	
}