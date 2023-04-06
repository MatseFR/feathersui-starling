/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.controls.renderers.DefaultListItemRenderer;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IMeasureDisplayObject;
import feathers.core.IValidating;
import feathers.data.ArrayCollection;
import feathers.data.IListCollection;
import feathers.events.CollectionEventType;
import feathers.events.FeathersEventType;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.skins.IStyleProvider;
import feathers.utils.math.MathUtils;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.type.SafeCast;
import openfl.Vector;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
//#if flash
//import flash.globalization.DateTimeFormatter;
//#else
import openfl.globalization.DateTimeFormatter;
//#end
import openfl.globalization.DateTimeNameStyle;
import openfl.globalization.DateTimeStyle;
import openfl.globalization.LocaleID;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.events.EventDispatcher;

/**
 * A set of <code>SpinnerList</code> components that allow you to select the
 * date, the time, or the date and time.
 *
 * <p>The following example sets the date spinner's range and listens for
 * when the value changes:</p>
 *
 * <listing version="3.0">
 * var spinner:DateTimeSpinner = new DateTimeSpinner();
 * spinner.editingMode = DateTimeMode.DATE;
 * spinner.minimum = new Date(1970, 0, 1);
 * spinner.maximum = new Date(2050, 11, 31);
 * spinner.value = new Date();
 * spinner.addEventListener( Event.CHANGE, spinner_changeHandler );
 * this.addChild( spinner );</listing>
 *
 * @see ../../../help/date-time-spinner.html How to use the Feathers DateTimeSpinner component
 *
 * @productversion Feathers 2.3.0
 */
class DateTimeSpinner extends FeathersControl 
{
	/**
	 * The default name to use with lists.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_LIST:String = "feathers-date-time-spinner-list";

	/**
	 * @private
	 */
	private static inline var MS_PER_DAY:Int = 86400000;

	/**
	 * @private
	 */
	private static inline var MIN_MONTH_VALUE:Int = 0;

	/**
	 * @private
	 */
	private static inline var MAX_MONTH_VALUE:Int = 11;

	/**
	 * @private
	 */
	private static inline var MIN_DATE_VALUE:Int = 1;

	/**
	 * @private
	 */
	private static inline var MAX_DATE_VALUE:Int = 31;

	/**
	 * @private
	 */
	private static inline var MIN_HOURS_VALUE:Int = 0;

	/**
	 * @private
	 */
	private static inline var MAX_HOURS_VALUE_12HOURS:Int = 11;

	/**
	 * @private
	 */
	private static inline var MAX_HOURS_VALUE_24HOURS:Int = 23;

	/**
	 * @private
	 */
	private static inline var MIN_MINUTES_VALUE:Int = 0;

	/**
	 * @private
	 */
	private static inline var MAX_MINUTES_VALUE:Int = 59;
	
	/**
	 * @private
	 */
	private static var HELPER_DATE:Date;// = new Date(0, 1, 0, 0, 0, 0);

	/**
	 * @private
	 */
	private static var DAYS_IN_MONTH:Array<Int> = new Array<Int>();

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_LOCALE:String = "locale";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_EDITING_MODE:String = "editingMode";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_PENDING_SCROLL:String = "pendingScroll";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_SPINNER_LIST_FACTORY:String = "spinnerListFactory";

	/**
	 * The default <code>IStyleProvider</code> for all <code>DateTimeSpinner</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

	/**
	 * @private
	 */
	private static function defaultListFactory():SpinnerList
	{
		return new SpinnerList();
	}
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		if (DAYS_IN_MONTH.length == 0)
		{
			//HELPER_DATE.setFullYear(2015); //this is pretty arbitrary
			for (i in MIN_MONTH_VALUE...MAX_MONTH_VALUE + 1)
			{
				//subtract one date from the 1st of next month to figure out
				//the last date of the current month
				//HELPER_DATE.setMonth(i + 1, -1);
				//DAYS_IN_MONTH[i] = HELPER_DATE.date + 1;
				HELPER_DATE = new Date(2023, i, 1, 0, 0, 0);
				DAYS_IN_MONTH[i] = DateTools.getMonthDays(HELPER_DATE);
			}
			//DAYS_IN_MONTH.fixed = true;
		}
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the lists. This
	 * variable is <code>protected</code> so that sub-classes can customize
	 * the list style name in their constructors instead of using the
	 * default style name defined by <code>DEFAULT_CHILD_STYLE_NAME_LIST</code>.
	 *
	 * <p>To customize the list style name without subclassing, see
	 * <code>customListStyleName</code>.</p>
	 *
	 * @see #style:customListStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var listStyleName:String = DEFAULT_CHILD_STYLE_NAME_LIST;

	/**
	 * @private
	 */
	private var monthsList:SpinnerList;

	/**
	 * @private
	 */
	private var datesList:SpinnerList;

	/**
	 * @private
	 */
	private var yearsList:SpinnerList;

	/**
	 * @private
	 */
	private var dateAndTimeDatesList:SpinnerList;

	/**
	 * @private
	 */
	private var hoursList:SpinnerList;

	/**
	 * @private
	 */
	private var minutesList:SpinnerList;

	/**
	 * @private
	 */
	private var meridiemList:SpinnerList;

	/**
	 * @private
	 */
	private var listGroup:LayoutGroup;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return DateTimeSpinner.globalStyleProvider;
	}
	
	/**
	 * The locale used to display the date. Supports values defined by
	 * Unicode Technical Standard #35, such as <code>"en_US"</code>,
	 * <code>"fr_FR"</code> or <code>"ru_RU"</code>.
	 *
	 * @default flash.globalization.LocaleID.DEFAULT
	 *
	 * @see http://unicode.org/reports/tr35/ Unicode Technical Standard #35
	 */
	public var locale(get, set):String;
	private var _locale:String = LocaleID.DEFAULT;
	private function get_locale():String { return this._locale; }
	private function set_locale(value:String):String
	{
		if (this._locale == value)
		{
			return value;
		}
		this._locale = value;
		this._formatter = null;
		this.invalidate(INVALIDATION_FLAG_LOCALE);
		return this._locale;
	}
	
	/**
	 * The value of the date time spinner, between the minimum and maximum.
	 *
	 * <p>In the following example, the value is changed to a date:</p>
	 *
	 * <listing version="3.0">
	 * stepper.minimum = new Date(1970, 0, 1);
	 * stepper.maximum = new Date(2050, 11, 31);
	 * stepper.value = new Date(1995, 2, 7);</listing>
	 *
	 * @default 0
	 *
	 * @see #minimum
	 * @see #maximum
	 * @see #event:change
	 */
	public var value(get, set):Date;
	private var _value:Date;
	private function get_value():Date { return this._value; }
	private function set_value(newValue:Date):Date
	{
		var time:Float = newValue.getTime();
		if (this._minimum != null && this._minimum.getTime() > time)
		{
			time = this._minimum.getTime();
		}
		if (this._maximum != null && this._maximum.getTime() < time)
		{
			time = this._maximum.getTime();
		}
		if (this._value != null && this._value.getTime() == time)
		{
			return value;
		}
		this._value = Date.fromTime(time);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._value;
	}
	
	/**
	 * The date time spinner's value will not go lower than the minimum.
	 *
	 * <p>In the following example, the minimum is changed:</p>
	 *
	 * <listing version="3.0">
	 * spinner.minimum = new Date(1970, 0, 1);</listing>
	 *
	 * @see #value
	 * @see #maximum
	 */
	public var minimum(get, set):Date;
	private var _minimum:Date;
	private function get_minimum():Date { return this._minimum; }
	private function set_minimum(value:Date):Date
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
	 * The date time spinner's value will not go higher than the maximum.
	 *
	 * <p>In the following example, the maximum is changed:</p>
	 *
	 * <listing version="3.0">
	 * spinner.maximum = new Date(2050, 11, 31);</listing>
	 *
	 * @see #value
	 * @see #minimum
	 */
	public var maximum(get, set):Date;
	private var _maximum:Date;
	private function get_maximum():Date { return this._maximum; }
	private function set_maximum(value:Date):Date
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
	 * In the list that allows selection of minutes, customizes the number
	 * of minutes between each item. For instance, one might choose 15 or
	 * 30 minute increments.
	 *
	 * <p>In the following example, the spinner uses 15 minute increments:</p>
	 *
	 * <listing version="3.0">
	 * spinner.minuteStep = 15;</listing>
	 *
	 * @default 1
	 */
	public var minuteStep(get, set):Int;
	private var _minuteStep:Int = 1;
	private function get_minuteStep():Int { return this._minuteStep; }
	private function set_minuteStep(value:Int):Int
	{
		if (60 % value != 0)
		{
			throw new ArgumentError("minuteStep must evenly divide into 60.");
		}
		if (this._minuteStep == value)
		{
			return value;
		}
		this._minuteStep = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._minuteStep;
	}
	
	/**
	 * Determines which parts of the <code>Date</code> value may be edited.
	 *
	 * @default feathers.controls.DateTimeMode.DATE_AND_TIME
	 *
	 * @see feathers.controls.DateTimeMode#DATE_AND_TIME
	 * @see feathers.controls.DateTimeMode#DATE
	 * @see feathers.controls.DateTimeMode#TIME
	 */
	public var editingMode(get, set):String;
	private var _editingMode:String = DateTimeMode.DATE_AND_TIME;
	private function get_editingMode():String { return this._editingMode; }
	private function set_editingMode(value:String):String
	{
		if (this._editingMode == value)
		{
			return value;
		}
		this._editingMode = value;
		this.invalidate(INVALIDATION_FLAG_EDITING_MODE);
		return this._editingMode;
	}
	
	/**
	 * @private
	 */
	private var _formatter:DateTimeFormatter;

	/**
	 * @private
	 */
	private var _longestMonthNameIndex:Int;

	/**
	 * @private
	 */
	private var _localeMonthNames:Array<String>;

	/**
	 * @private
	 */
	private var _localeWeekdayNames:Array<String>;

	/**
	 * @private
	 */
	private var _ignoreListChanges:Bool = false;

	/**
	 * @private
	 */
	private var _monthFirst:Bool = true;

	/**
	 * @private
	 */
	private var _showMeridiem:Bool = true;

	/**
	 * @private
	 */
	private var _lastMeridiemValue:Int = 0;

	/**
	 * @private
	 */
	private var _listMinYear:Int;

	/**
	 * @private
	 */
	private var _listMaxYear:Int;

	/**
	 * @private
	 */
	private var _minYear:Int;

	/**
	 * @private
	 */
	private var _maxYear:Int;

	/**
	 * @private
	 */
	private var _minMonth:Int;

	/**
	 * @private
	 */
	private var _maxMonth:Int;

	/**
	 * @private
	 */
	private var _minDate:Int;

	/**
	 * @private
	 */
	private var _maxDate:Int;

	/**
	 * @private
	 */
	private var _minHours:Int;

	/**
	 * @private
	 */
	private var _maxHours:Int;

	/**
	 * @private
	 */
	private var _minMinute:Int;

	/**
	 * @private
	 */
	private var _maxMinute:Int;
	
	/**
	 * @private
	 */
	public var scrollDuration(get, set):Float;
	private var _scrollDuration:Float = 0.5;
	private function get_scrollDuration():Float { return this._scrollDuration; }
	private function set_scrollDuration(value:Float):Float
	{
		if (this.processStyleRestriction("scrollDuration"))
		{
			return value;
		}
		if (this._scrollDuration == value)
		{
			return value;
		}
		return this._scrollDuration = value;
	}
	
	/**
	 * A function used to instantiate the date time spinner's item renderer
	 * sub-components. A single factory will be shared by all
	 * <code>SpinnerList</code> sub-components displayed by the
	 * <code>DateTimeSpinner</code>. The item renderers must be instances of
	 * <code>DefaultListItemRenderer</code>. This factory can be used to
	 * change properties of the item renderer sub-components when they are
	 * first created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to style the item
	 * renderer sub-components.
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():DefaultListItemRenderer</pre>
	 *
	 * <p>In the following example, the date time spinner uses a custom item
	 * renderer factory:</p>
	 *
	 * <listing version="3.0">
	 * spinner.itemRendererFactory = function():DefaultListItemRenderer
	 * {
	 *     var itemRenderer:DefaultListItemRenderer = new DefaultListItemRenderer();
	 *     // set properties
	 *     return itemRenderer;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.renderers.DefaultListItemRenderer
	 * @see #itemRendererFactory
	 */
	public var itemRendererFactory(get, set):Void->DefaultListItemRenderer;
	private var _itemRendererFactory:Void->DefaultListItemRenderer;
	private function get_itemRendererFactory():Void->DefaultListItemRenderer { return this._itemRendererFactory; }
	private function set_itemRendererFactory(value:Void->DefaultListItemRenderer):Void->DefaultListItemRenderer
	{
		if (this._itemRendererFactory == value)
		{
			return value;
		}
		this._itemRendererFactory = value;
		this.invalidate(INVALIDATION_FLAG_SPINNER_LIST_FACTORY);
		return this._itemRendererFactory;
	}
	
	/**
	 * A function used to instantiate the date time spinner's list
	 * sub-components. The lists must be instances of
	 * <code>SpinnerList</code>. This factory can be used to change
	 * properties of the list sub-components when they are first created.
	 * For instance, if you are skinning Feathers components without a
	 * theme, you might use this factory to style the list sub-components.
	 *
	 * <p><strong>Warning:</strong> The <code>itemRendererFactory</code>
	 * and <code>customItemRendererStyleName</code> properties of the
	 * <code>SpinnerList</code> should not be set in the
	 * <code>listFactory</code>. Instead, set the
	 * <code>itemRendererFactory</code> and
	 * <code>customItemRendererStyleName</code> properties of the
	 * <code>DateTimeSpinner</code>.</p>
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():SpinnerList</pre>
	 *
	 * <p>In the following example, the date time spinner uses a custom list
	 * factory:</p>
	 *
	 * <listing version="3.0">
	 * spinner.listFactory = function():SpinnerList
	 * {
	 *     var list:SpinnerList = new SpinnerList();
	 *     // set properties
	 *     return list;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.SpinnerList
	 * @see #itemRendererFactory
	 */
	public var listFactory(get, set):Void->SpinnerList;
	private var _listFactory:Void->SpinnerList;
	private function get_listFactory():Void->SpinnerList { return this._listFactory; }
	private function set_listFactory(value:Void->SpinnerList):Void->SpinnerList
	{
		if (this._listFactory == value)
		{
			return value;
		}
		this._listFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._listFactory;
	}
	
	/**
	 * @private
	 */
	public var customListStyleName(get, set):String;
	private var _customListStyleName:String;
	private function get_customListStyleName():String { return this._customListStyleName; }
	private function set_customListStyleName(value:String):String
	{
		if (this.processStyleRestriction("customListStyleName"))
		{
			return value;
		}
		if (this._customListStyleName == value)
		{
			return value;
		}
		this._customListStyleName = value;
		this.invalidate(INVALIDATION_FLAG_SPINNER_LIST_FACTORY);
		return this._customListStyleName;
	}
	
	/**
	 * @private
	 */
	public var customItemRendererStyleName(get, set):String;
	private var _customItemRendererStyleName:String;
	private function get_customItemRendererStyleName():String { return this._customItemRendererStyleName; }
	private function set_customItemRendererStyleName(value:String):String
	{
		if (this.processStyleRestriction("customItemRendererStyleName"))
		{
			return value;
		}
		if (this._customItemRendererStyleName == value)
		{
			return value;
		}
		this._customItemRendererStyleName = value;
		this.invalidate(INVALIDATION_FLAG_SPINNER_LIST_FACTORY);
		return this._customItemRendererStyleName;
	}
	
	/**
	 * @private
	 */
	private var _lastValidate:Date;
	
	/**
	 * If not <code>null</code>, and the <code>editingMode</code> property
	 * is set to <code>DateTimeMode.DATE_AND_TIME</code> the date matching
	 * today's current date will display this label instead of the date.
	 *
	 * <p>In the following example, the label for today is set:</p>
	 *
	 * <listing version="3.0">
	 * spinner.todayLabel = "Today";</listing>
	 *
	 * @default null
	 */
	public var todayLabel(get, set):String;
	private var _todayLabel:String;
	private function get_todayLabel():String { return this._todayLabel; }
	private function set_todayLabel(value:String):String
	{
		if (this._todayLabel == value)
		{
			return value;
		}
		this._todayLabel = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._todayLabel;
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
	private var currentBackgroundSkin:DisplayObject;
	
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SKIN);
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
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SKIN);
		return this._backgroundDisabledSkin;
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
	private var _amString:String;

	/**
	 * @private
	 */
	private var _pmString:String;

	/**
	 * @private
	 */
	private var pendingScrollToDate:Date;

	/**
	 * @private
	 */
	private var pendingScrollDuration:Float;
	
	/**
	 * After the next validation, animates the scroll positions of the lists
	 * to a specific date. If the <code>animationDuration</code> argument is
	 * <code>NaN</code> (the default value), the value of the
	 * <code>scrollDuration</code> property is used instead. The duration is
	 * measured in seconds.
	 *
	 * <p>Note: The <code>value</code> property will not be updated
	 * immediately when calling <code>scrollToDate()</code>. Similar to how
	 * the animation won't start until the next validation, the
	 * <code>value</code> property will be updated at the same time.</p>
	 *
	 * <p>In the following example, we scroll to a specific date with
	 * animation of 1.5 seconds:</p>
	 *
	 * <listing version="3.0">
	 * spinner.scrollToDate( new Date(2016, 0, 1), 1.5 );</listing>
	 *
	 * @see #style:scrollDuration
	 */
	public function scrollToDate(date:Date, ?animationDuration:Float):Void
	{
		if (animationDuration == null) animationDuration = Math.NaN;
		
		if (this.pendingScrollToDate != null && this.pendingScrollToDate.getTime() == date.getTime() &&
			this.pendingScrollDuration == animationDuration)
		{
			return;
		}
		this.pendingScrollToDate = date;
		this.pendingScrollDuration = animationDuration;
		this.invalidate(INVALIDATION_FLAG_PENDING_SCROLL);
	}
	
	/**
	 * @private
	 */
	override public function dispose():Void
	{
		//we don't dispose it if the group is the parent because it'll
		//already get disposed in super.dispose()
		if (this._backgroundSkin != null && this._backgroundSkin.parent != this)
		{
			this._backgroundSkin.dispose();
		}
		if (this._backgroundDisabledSkin != null && this._backgroundDisabledSkin.parent != this)
		{
			this._backgroundDisabledSkin.dispose();
		}
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function initialize():Void
	{
		if (this.listGroup == null)
		{
			var groupLayout:HorizontalLayout = new HorizontalLayout();
			groupLayout.horizontalAlign = HorizontalAlign.CENTER;
			groupLayout.verticalAlign = VerticalAlign.JUSTIFY;
			this.listGroup = new LayoutGroup();
			this.listGroup.layout = groupLayout;
			this.addChild(this.listGroup);
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var skinInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SKIN);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var editingModeInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_EDITING_MODE);
		var localeInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_LOCALE);
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var pendingScrollInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_PENDING_SCROLL);
		var spinnerListFactoryInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_SPINNER_LIST_FACTORY);
		
		if (this._todayLabel != null)
		{
			this._lastValidate = new Date(1970, 0, 1, 0, 0, 0);
		}
		
		if (skinInvalid || stateInvalid)
		{
			this.refreshBackgroundSkin();
		}
		
		if (localeInvalid || editingModeInvalid)
		{
			this.refreshLocale();
		}
		
		if (localeInvalid || editingModeInvalid || spinnerListFactoryInvalid)
		{
			this.refreshLists(editingModeInvalid || spinnerListFactoryInvalid, localeInvalid);
		}
		
		if (localeInvalid || editingModeInvalid || dataInvalid || spinnerListFactoryInvalid)
		{
			this.useDefaultsIfNeeded();
			this.refreshValidRanges();
			this.refreshSelection();
		}
		
		if (localeInvalid || editingModeInvalid || stateInvalid || spinnerListFactoryInvalid)
		{
			this.refreshEnabled();
		}
		
		this.autoSizeIfNeeded();
		
		this.layoutChildren();
		
		if (pendingScrollInvalid)
		{
			this.handlePendingScroll();
		}
	}
	
	/**
	 * @private
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
		
		var measureBackground:IMeasureDisplayObject = SafeCast.safe_cast(this.currentBackgroundSkin, IMeasureDisplayObject);
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		if (Std.isOfType(this.currentBackgroundSkin, IValidating))
		{
			cast(this.currentBackgroundSkin, IValidating).validate();
		}
		
		this.listGroup.width = this._explicitWidth;
		this.listGroup.height = this._explicitHeight;
		this.listGroup.minWidth = this._explicitMinWidth;
		this.listGroup.minHeight = this._explicitMinHeight;
		this.listGroup.validate(); //minimum dimensions
		
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			if (measureBackground != null)
			{
				newMinWidth = measureBackground.minWidth;
			}
			else if (this.currentBackgroundSkin != null)
			{
				newMinWidth = this._explicitBackgroundMinWidth;
			}
			else
			{
				newMinWidth = 0;
			}
			var listsMinWidth:Float = this.listGroup.minWidth;
			listsMinWidth += this._paddingLeft + this._paddingRight;
			if (listsMinWidth > newMinWidth)
			{
				newMinWidth = listsMinWidth;
			}
		}
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (measureBackground != null)
			{
				newMinHeight = measureBackground.minHeight;
			}
			else if (this.currentBackgroundSkin != null)
			{
				newMinHeight = this._explicitBackgroundMinHeight;
			}
			else
			{
				newMinHeight = 0;
			}
			var listsMinHeight:Float = this.listGroup.minHeight;
			listsMinHeight += this._paddingTop + this._paddingBottom;
			if (listsMinHeight > newMinHeight)
			{
				newMinHeight = listsMinHeight;
			}
		}
		
		//current dimensions
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (this.currentBackgroundSkin != null)
			{
				newWidth = this.currentBackgroundSkin.width;
			}
			else
			{
				newWidth = 0;
			}
			var listsWidth:Float = this.listGroup.width + this._paddingLeft + this._paddingRight;
			if (listsWidth > newWidth)
			{
				newWidth = listsWidth;
			}
		}
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (this.currentBackgroundSkin != null)
			{
				newHeight = this.currentBackgroundSkin.height;
			}
			else
			{
				newHeight = 0;
			}
			var listsHeight:Float = this.listGroup.height + this._paddingTop + this._paddingBottom;
			if (listsHeight > newHeight)
			{
				newHeight = listsHeight;
			}
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * Choose the appropriate background skin based on the control's current
	 * state.
	 */
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
			this.setRequiresRedraw();
			skin.removeFromParent(false);
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
	private function refreshLists(createNewLists:Bool, localeChanged:Bool):Void
	{
		if (createNewLists)
		{
			this.createYearList();
			this.createMonthList();
			this.createDateList();
			
			this.createHourList();
			this.createMinuteList();
			this.createMeridiemList();
			
			this.createDateAndTimeDateList();
		}
		else if ((this._showMeridiem && this.meridiemList == null) ||
			(!this._showMeridiem && this.meridiemList != null))
		{
			//if the locale changes, we may need to create or destroy this
			//list, but the other lists can stay
			this.createMeridiemList();
		}
		
		if (this._editingMode == DateTimeMode.DATE)
		{
			//does this locale show the month or the date first?
			if (this._monthFirst)
			{
				this.listGroup.setChildIndex(this.monthsList, 0);
			}
			else
			{
				this.listGroup.setChildIndex(this.datesList, 0);
			}
		}
		
		if (localeChanged)
		{
			if (this.monthsList != null)
			{
				var monthsCollection:IListCollection = this.monthsList.dataProvider;
				if (monthsCollection != null)
				{
					monthsCollection.updateAll();
				}
			}
			if (this.dateAndTimeDatesList != null)
			{
				var dateAndTimeDatesCollection:IListCollection = this.dateAndTimeDatesList.dataProvider;
				if (dateAndTimeDatesCollection != null)
				{
					dateAndTimeDatesCollection.updateAll();
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function createYearList():Void
	{
		if (this.yearsList != null)
		{
			this.listGroup.removeChild(this.yearsList, true);
			this.yearsList = null;
		}
		
		if (this._editingMode != DateTimeMode.DATE)
		{
			return;
		}
		
		var listFactory:Void->SpinnerList = (this._listFactory != null) ? this._listFactory : defaultListFactory;
		this.yearsList = listFactory();
		var listStyleName:String = (this._customListStyleName != null) ? this._customListStyleName : this.listStyleName;
		this.yearsList.styleNameList.add(listStyleName);
		//we'll set the data provider later, when we know what range
		//of years we need
		
		//for backwards compatibility, allow the listFactory to take
		//precedence if it also sets itemRendererFactory or
		//customItemRendererStyleName
		if (this._itemRendererFactory != null)
		{
			this.yearsList.itemRendererFactory = this._itemRendererFactory;
		}
		if (this._customItemRendererStyleName != null)
		{
			this.yearsList.customItemRendererStyleName = this._customItemRendererStyleName;
		}
		this.yearsList.addEventListener(FeathersEventType.RENDERER_ADD, yearsList_rendererAddHandler);
		this.yearsList.addEventListener(Event.CHANGE, yearsList_changeHandler);
		this.listGroup.addChild(this.yearsList);
	}
	
	/**
	 * @private
	 */
	private function createMonthList():Void
	{
		if (this.monthsList != null)
		{
			this.listGroup.removeChild(this.monthsList, true);
			this.monthsList = null;
		}
		
		if (this._editingMode != DateTimeMode.DATE)
		{
			return;
		}
		
		var listFactory:Void->SpinnerList = (this._listFactory != null) ? this._listFactory : defaultListFactory;
		this.monthsList = listFactory();
		var listStyleName:String = (this._customListStyleName != null) ? this._customListStyleName : this.listStyleName;
		this.monthsList.styleNameList.add(listStyleName);
		this.monthsList.dataProvider = new IntegerRangeCollection(MIN_MONTH_VALUE, MAX_MONTH_VALUE, 1);
		this.monthsList.typicalItem = this._longestMonthNameIndex;
		//for backwards compatibility, allow the listFactory to take
		//precedence if it also sets itemRendererFactory or
		//customItemRendererStyleName
		if (this._itemRendererFactory != null)
		{
			this.monthsList.itemRendererFactory = this._itemRendererFactory;
		}
		if (this._customItemRendererStyleName != null)
		{
			this.monthsList.customItemRendererStyleName = this._customItemRendererStyleName;
		}
		this.monthsList.addEventListener(FeathersEventType.RENDERER_ADD, monthsList_rendererAddHandler);
		this.monthsList.addEventListener(Event.CHANGE, monthsList_changeHandler);
		this.listGroup.addChildAt(this.monthsList, 0);
	}
	
	/**
	 * @private
	 */
	private function createDateList():Void
	{
		if (this.datesList != null)
		{
			this.listGroup.removeChild(this.datesList, true);
			this.datesList = null;
		}
		
		if (this._editingMode != DateTimeMode.DATE)
		{
			return;
		}
		
		var listFactory:Void->SpinnerList = (this._listFactory != null) ? this._listFactory : defaultListFactory;
		this.datesList = listFactory();
		var listStyleName:String = (this._customListStyleName != null) ? this._customListStyleName : this.listStyleName;
		this.datesList.styleNameList.add(listStyleName);
		this.datesList.dataProvider = new IntegerRangeCollection(MIN_DATE_VALUE, MAX_DATE_VALUE, 1);
		//for backwards compatibility, allow the listFactory to take
		//precedence if it also sets itemRendererFactory or
		//customItemRendererStyleName
		if (this._itemRendererFactory != null)
		{
			this.datesList.itemRendererFactory = this._itemRendererFactory;
		}
		if (this._customItemRendererStyleName != null)
		{
			this.datesList.customItemRendererStyleName = this._customItemRendererStyleName;
		}
		this.datesList.addEventListener(FeathersEventType.RENDERER_ADD, datesList_rendererAddHandler);
		this.datesList.addEventListener(Event.CHANGE, datesList_changeHandler);
		this.listGroup.addChildAt(this.datesList, 0);
	}
	
	/**
	 * @private
	 */
	private function createHourList():Void
	{
		if (this.hoursList != null)
		{
			this.listGroup.removeChild(this.hoursList, true);
			this.hoursList = null;
		}
		
		if (this._editingMode == DateTimeMode.DATE)
		{
			return;
		}
		
		var listFactory:Void->SpinnerList = (this._listFactory != null) ? this._listFactory : defaultListFactory;
		this.hoursList = listFactory();
		var listStyleName:String = (this._customListStyleName != null) ? this._customListStyleName : this.listStyleName;
		this.hoursList.styleNameList.add(listStyleName);
		//for backwards compatibility, allow the listFactory to take
		//precedence if it also sets itemRendererFactory or
		//customItemRendererStyleName
		if (this._itemRendererFactory != null)
		{
			this.hoursList.itemRendererFactory = this._itemRendererFactory;
		}
		if (this._customItemRendererStyleName != null)
		{
			this.hoursList.customItemRendererStyleName = this._customItemRendererStyleName;
		}
		this.hoursList.addEventListener(FeathersEventType.RENDERER_ADD, hoursList_rendererAddHandler);
		this.hoursList.addEventListener(Event.CHANGE, hoursList_changeHandler);
		this.listGroup.addChild(this.hoursList);
	}
	
	/**
	 * @private
	 */
	private function createMinuteList():Void
	{
		if (this.minutesList != null)
		{
			this.listGroup.removeChild(this.minutesList, true);
			this.minutesList = null;
		}
		
		if (this._editingMode == DateTimeMode.DATE)
		{
			return;
		}
		
		var listFactory:Void->SpinnerList = (this._listFactory != null) ? this._listFactory : defaultListFactory;
		this.minutesList = listFactory();
		var listStyleName:String = (this._customListStyleName != null) ? this._customListStyleName : this.listStyleName;
		this.minutesList.styleNameList.add(listStyleName);
		this.minutesList.dataProvider = new IntegerRangeCollection(MIN_MINUTES_VALUE, MAX_MINUTES_VALUE, this._minuteStep);
		//for backwards compatibility, allow the listFactory to take
		//precedence if it also sets itemRendererFactory or
		//customItemRendererStyleName
		if (this._itemRendererFactory != null)
		{
			this.minutesList.itemRendererFactory = this._itemRendererFactory;
		}
		if (this._customItemRendererStyleName != null)
		{
			this.minutesList.customItemRendererStyleName = this._customItemRendererStyleName;
		}
		this.minutesList.addEventListener(FeathersEventType.RENDERER_ADD, minutesList_rendererAddHandler);
		this.minutesList.addEventListener(Event.CHANGE, minutesList_changeHandler);
		this.listGroup.addChild(this.minutesList);
	}
	
	/**
	 * @private
	 */
	private function createMeridiemList():Void
	{
		if (this.meridiemList != null)
		{
			this.listGroup.removeChild(this.meridiemList, true);
			this.meridiemList = null;
		}
		
		if (!this._showMeridiem)
		{
			return;
		}
		
		var listFactory:Void->SpinnerList = (this._listFactory != null) ? this._listFactory : defaultListFactory;
		this.meridiemList = listFactory();
		var listStyleName:String = (this._customListStyleName != null) ? this._customListStyleName : this.listStyleName;
		this.meridiemList.styleNameList.add(listStyleName);
		//for backwards compatibility, allow the listFactory to take
		//precedence if it also sets itemRendererFactory or
		//customItemRendererStyleName
		if (this._itemRendererFactory != null)
		{
			this.meridiemList.itemRendererFactory = this._itemRendererFactory;
		}
		if (this._customItemRendererStyleName != null)
		{
			this.meridiemList.customItemRendererStyleName = this._customItemRendererStyleName;
		}
		this.meridiemList.addEventListener(Event.CHANGE, meridiemList_changeHandler);
		this.listGroup.addChild(this.meridiemList);
	}
	
	/**
	 * @private
	 */
	private function createDateAndTimeDateList():Void
	{
		if (this.dateAndTimeDatesList != null)
		{
			this.listGroup.removeChild(this.dateAndTimeDatesList, true);
			this.dateAndTimeDatesList = null;
		}
		
		if (this._editingMode != DateTimeMode.DATE_AND_TIME)
		{
			return;
		}
		
		var listFactory:Void->SpinnerList = (this._listFactory != null) ? this._listFactory : defaultListFactory;
		this.dateAndTimeDatesList = listFactory();
		var listStyleName:String = (this._customListStyleName != null) ? this._customListStyleName : this.listStyleName;
		this.dateAndTimeDatesList.styleNameList.add(listStyleName);
		//for backwards compatibility, allow the listFactory to take
		//precedence if it also sets itemRendererFactory or
		//customItemRendererStyleName
		if (this._itemRendererFactory != null)
		{
			this.dateAndTimeDatesList.itemRendererFactory = this._itemRendererFactory;
		}
		if (this._customItemRendererStyleName != null)
		{
			this.dateAndTimeDatesList.customItemRendererStyleName = this._customItemRendererStyleName;
		}
		this.dateAndTimeDatesList.addEventListener(FeathersEventType.RENDERER_ADD, dateAndTimeDatesList_rendererAddHandler);
		this.dateAndTimeDatesList.addEventListener(Event.CHANGE, dateAndTimeDatesList_changeHandler);
		this.dateAndTimeDatesList.typicalItem = {};
		this.listGroup.addChildAt(this.dateAndTimeDatesList, 0);
	}
	
	/**
	 * @private
	 */
	private function refreshLocale():Void
	{
		if (this._formatter == null || this._formatter.requestedLocaleIDName != this._locale)
		{
			this._formatter = new DateTimeFormatter(this._locale, DateTimeStyle.SHORT, DateTimeStyle.SHORT);
			var dateTimePattern:String = this._formatter.getDateTimePattern();
			//figure out if month or date should be displayed first
			var monthIndex:Int = dateTimePattern.indexOf("M");
			var dateIndex:Int = dateTimePattern.indexOf("d");
			this._monthFirst = monthIndex < dateIndex;
			//figure out if this locale uses am/pm or 24-hour format
			this._showMeridiem = this._editingMode != DateTimeMode.DATE && dateTimePattern.indexOf("a") != -1;
			if (this._showMeridiem)
			{
				this._formatter.setDateTimePattern("a");
				//HELPER_DATE.setHours(1);
				// we can't modify Date in Haxe so create a new one
				HELPER_DATE = new Date(2023, 0, 1, 1, 0, 0);
				//different locales have different names for am and pm
				//as an example, see zh_CN
				this._amString = this._formatter.format(HELPER_DATE);
				//HELPER_DATE.setHours(13);
				// we can't modify Date in Haxe so create a new one
				HELPER_DATE = new Date(2023, 0, 1, 13, 0, 0);
				this._pmString = this._formatter.format(HELPER_DATE);
				this._formatter.setDateTimePattern(dateTimePattern);
			}
		}
		var vector:Vector<String>;
		if (this._editingMode == DateTimeMode.DATE)
		{
			//this._localeMonthNames = this._formatter.getMonthNames(DateTimeNameStyle.FULL);
			vector = this._formatter.getMonthNames(DateTimeNameStyle.FULL);
			if (this._localeMonthNames == null)
			{
				this._localeMonthNames = new Array<String>();
			}
			else
			{
				this._localeMonthNames.resize(0);
			}
			for (monthName in vector)
			{
				this._localeMonthNames.push(monthName);
			}
			this._localeWeekdayNames = null;
		}
		else if (this._editingMode == DateTimeMode.DATE_AND_TIME)
		{
			//this._localeMonthNames = this._formatter.getMonthNames(DateTimeNameStyle.SHORT_ABBREVIATION);
			//this._localeWeekdayNames = this._formatter.getWeekdayNames(DateTimeNameStyle.LONG_ABBREVIATION);
			vector = this._formatter.getMonthNames(DateTimeNameStyle.SHORT_ABBREVIATION);
			if (this._localeMonthNames == null)
			{
				this._localeMonthNames = new Array<String>();
			}
			else
			{
				this._localeMonthNames.resize(0);
			}
			for (monthName in vector)
			{
				this._localeMonthNames.push(monthName);
			}
			vector = this._formatter.getWeekdayNames(DateTimeNameStyle.LONG_ABBREVIATION);
			if (this._localeWeekdayNames == null)
			{
				this._localeWeekdayNames = new Array<String>();
			}
			else
			{
				this._localeWeekdayNames.resize(0);
			}
			for (dayName in vector)
			{
				this._localeWeekdayNames.push(dayName);
			}
		}
		else //time only
		{
			this._localeMonthNames = null;
			this._localeWeekdayNames = null;
		}
		if (this._localeMonthNames != null)
		{
			this._longestMonthNameIndex = 0;
			var longestMonth:String = this._localeMonthNames[0];
			var monthCount:Int = this._localeMonthNames.length;
			for (i in 1...monthCount)
			{
				var otherMonthName:String = this._localeMonthNames[i];
				if (otherMonthName.length > longestMonth.length)
				{
					longestMonth = otherMonthName;
					this._longestMonthNameIndex = i;
				}
			}
		}
	}
	
	/**
	 * @private
	 */
	private function refreshSelection():Void
	{
		var oldIgnoreListChanges:Bool = this._ignoreListChanges;
		this._ignoreListChanges = true;
		
		if (this._editingMode == DateTimeMode.DATE)
		{
			var yearsCollection:IntegerRangeCollection = cast this.yearsList.dataProvider;
			if (yearsCollection != null)
			{
				yearsCollection.minimum = this._listMinYear;
				yearsCollection.maximum = this._listMaxYear;
			}
			else
			{
				this.yearsList.dataProvider = new IntegerRangeCollection(this._listMinYear, this._listMaxYear, 1);
			}
		}
		else //time only or both date and time
		{
			var totalMS:Float = this._maximum.getTime() - this._minimum.getTime();
			var totalDays:Int = Std.int(totalMS / MS_PER_DAY);
			
			if (this._editingMode == DateTimeMode.DATE_AND_TIME)
			{
				var dateAndTimeDatesCollection:IntegerRangeCollection = cast this.dateAndTimeDatesList.dataProvider;
				if (dateAndTimeDatesCollection != null)
				{
					dateAndTimeDatesCollection.maximum = totalDays;
				}
				else
				{
					this.dateAndTimeDatesList.dataProvider = new IntegerRangeCollection(0, totalDays, 1);
				}
			}
			
			var hoursMinimum:Int = MIN_HOURS_VALUE;
			var hoursMaximum:Int = this._showMeridiem ? MAX_HOURS_VALUE_12HOURS : MAX_HOURS_VALUE_24HOURS;
			var hoursCollection:IntegerRangeCollection = SafeCast.safe_cast(this.hoursList.dataProvider, IntegerRangeCollection);
			if (hoursCollection != null)
			{
				hoursCollection.minimum = hoursMinimum;
				hoursCollection.maximum = hoursMaximum;
			}
			else
			{
				this.hoursList.dataProvider = new IntegerRangeCollection(hoursMinimum, hoursMaximum, 1);
			}
			
			if (this._showMeridiem && this.meridiemList.dataProvider == null)
			{
				//this.meridiemList.dataProvider = new VectorCollection(new <String>[this._amString, this._pmString]);
				this.meridiemList.dataProvider = new ArrayCollection([this._amString, this._pmString]);
			}
		}
		
		if (this.monthsList != null && !this.monthsList.isScrolling)
		{
			this.monthsList.selectedItem = this._value.getMonth();
		}
		if (this.datesList != null && !this.datesList.isScrolling)
		{
			this.datesList.selectedItem = this._value.getDate();
		}
		if (this.yearsList != null && !this.yearsList.isScrolling)
		{
			this.yearsList.selectedItem = this._value.getFullYear();
		}
		
		if (this.dateAndTimeDatesList != null)
		{
			this.dateAndTimeDatesList.selectedIndex = Std.int((this._value.getTime() - this._minimum.getTime()) / MS_PER_DAY);
		}
		if (this.hoursList != null)
		{
			if (this._showMeridiem)
			{
				this.hoursList.selectedIndex = this._value.getHours() % 12;
			}
			else
			{
				this.hoursList.selectedIndex = this._value.getHours();
			}
		}
		if (this.minutesList != null)
		{
			this.minutesList.selectedItem = this._value.getMinutes();
		}
		if (this.meridiemList != null)
		{
			this.meridiemList.selectedIndex = (this._value.getHours() <= MAX_HOURS_VALUE_12HOURS) ? 0 : 1;
		}
		this._ignoreListChanges = oldIgnoreListChanges;
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		var listCount:Int = this.listGroup.numChildren;
		var list:SpinnerList;
		for (i in 0...listCount)
		{
			list = cast this.listGroup.getChildAt(i);
			list.isEnabled = this._isEnabled;
		}
	}
	
	/**
	 * @private
	 */
	private function getMinMonth(year:Int):Int
	{
		if (year == this._minYear)
		{
			return this._minimum.getMonth();
		}
		return MIN_MONTH_VALUE;
	}
	
	/**
	 * @private
	 */
	private function getMaxMonth(year:Int):Int
	{
		if (year == this._maxYear)
		{
			return this._maximum.getMonth();
		}
		return MAX_MONTH_VALUE;
	}
	
	/**
	 * @private
	 */
	private function getMinDate(year:Int, month:Int):Int
	{
		if (year == this._minYear && month == this._minimum.getMonth())
		{
			return this._minimum.getDate();
		}
		return MIN_DATE_VALUE;
	}
	
	/**
	 * @private
	 */
	private function getMaxDate(year:Int, month:Int):Int
	{
		if (year == this._maxYear && month == this._maximum.getMonth())
		{
			return this._maximum.getDate();
		}
		if (month == 1) //february has a variable number of days
		{
			//subtract one date from march 1st to figure out the last
			//date of february for the specified year
			//HELPER_DATE.setFullYear(year, month + 1, -1);
			//return HELPER_DATE.date + 1;
			HELPER_DATE = new Date(year, month, 1, 0, 0, 0);
			return DateTools.getMonthDays(HELPER_DATE);
		}
		//all other months have been pre-calculated
		return DAYS_IN_MONTH[month];
	}
	
	/**
	 * @private
	 */
	private function getMinHours(year:Int, month:Int, date:Int):Int
	{
		if (this._editingMode == DateTimeMode.DATE_AND_TIME)
		{
			if (year == this._minYear && month == this._minimum.getMonth() &&
				date == this._minimum.getDate())
			{
				return this._minimum.getHours();
			}
			return MIN_HOURS_VALUE;
		}
		return this._minimum.getHours();
	}
	
	/**
	 * @private
	 */
	private function getMaxHours(year:Int, month:Int, date:Int):Int
	{
		if (this._editingMode == DateTimeMode.DATE_AND_TIME)
		{
			if (year == this._maxYear && month == this._maximum.getMonth() &&
				date == this._maximum.getDate())
			{
				return this._maximum.getHours();
			}
			return MAX_HOURS_VALUE_24HOURS;
		}
		return this._maximum.getHours();
	}
	
	/**
	 * @private
	 */
	private function getMinMinutes(year:Int, month:Int, date:Int, hours:Int):Int
	{
		if (this._editingMode == DateTimeMode.DATE_AND_TIME)
		{
			if (year == this._minYear && month == this._minimum.getMonth() &&
				date == this._minimum.getDate() && hours == this._minimum.getHours())
			{
				return this._minimum.getMinutes();
			}
			return MIN_MINUTES_VALUE;
		}
		if (hours == this._minHours)
		{
			return this._minimum.getMinutes();
		}
		return MIN_MINUTES_VALUE;
	}
	
	/**
	 * @private
	 */
	private function getMaxMinutes(year:Int, month:Int, date:Int, hours:Int):Int
	{
		if (this._editingMode == DateTimeMode.DATE_AND_TIME)
		{
			if (year == this._maxYear && month == this._maximum.getMonth() &&
				date == this._maximum.getDate() && hours == this._maximum.getHours())
			{
				return this._maximum.getMinutes();
			}
			return MAX_MINUTES_VALUE;
		}
		if (hours == this._maxHours)
		{
			return this._maximum.getMinutes();
		}
		return MAX_MINUTES_VALUE;
	}
	
	/**
	 * @private
	 */
	private function getValidDateForYearAndMonth(year:Int, month:Int):Int
	{
		var date:Int = this._value.getDate();
		var minDate:Int = this.getMinDate(year, month);
		var maxDate:Int = this.getMaxDate(year, month);
		if (date < minDate)
		{
			date = minDate;
		}
		else if (date > maxDate)
		{
			date = maxDate;
		}
		return date;
	}
	
	/**
	 * @private
	 */
	private function refreshValidRanges():Void
	{
		var oldMinYear:Int = this._minYear;
		var oldMaxYear:Int = this._maxYear;
		var oldMinMonth:Int = this._minMonth;
		var oldMaxMonth:Int = this._maxMonth;
		var oldMinDate:Int = this._minDate;
		var oldMaxDate:Int = this._maxDate;
		var oldMinHours:Int = this._minHours;
		var oldMaxHours:Int = this._maxHours;
		var oldMinMinutes:Int = this._minMinute;
		var oldMaxMinutes:Int = this._maxMinute;
		var currentYear:Int = this._value.getFullYear();
		var currentMonth:Int = this._value.getMonth();
		var currentDate:Int = this._value.getDate();
		var currentHours:Int = this._value.getHours();
		
		this._minYear = this._minimum.getFullYear();
		this._maxYear = this._maximum.getFullYear();
		this._minMonth = this.getMinMonth(currentYear);
		this._maxMonth = this.getMaxMonth(currentYear);
		this._minDate = this.getMinDate(currentYear, currentMonth);
		this._maxDate = this.getMaxDate(currentYear, currentMonth);
		this._minHours = this.getMinHours(currentYear, currentMonth, currentDate);
		this._maxHours = this.getMaxHours(currentYear, currentMonth, currentDate);
		this._minMinute = this.getMinMinutes(currentYear, currentMonth, currentDate, currentHours);
		this._maxMinute = this.getMaxMinutes(currentYear, currentMonth, currentDate, currentHours);
		
		//the item renderers in the lists may need to be enabled or disabled
		//after the ranges change, so we need to call updateAll() on the
		//collections
		
		var yearsCollection:IListCollection = this.yearsList != null ? this.yearsList.dataProvider : null;
		if (yearsCollection != null && (oldMinYear != this._minYear || oldMaxYear != this._maxYear))
		{
			//we need to ensure that the item renderers are enabled
			yearsCollection.updateAll();
		}
		var monthsCollection:IListCollection = this.monthsList != null ? this.monthsList.dataProvider : null;
		if (monthsCollection != null && (oldMinMonth != this._minMonth || oldMaxMonth != this._maxMonth))
		{
			monthsCollection.updateAll();
		}
		var datesCollection:IListCollection = this.datesList != null ? this.datesList.dataProvider : null;
		if (datesCollection != null && (oldMinDate != this._minDate || oldMaxDate != this._maxDate))
		{
			datesCollection.updateAll();
		}
		var dateAndTimeDatesCollection:IListCollection = this.dateAndTimeDatesList != null ? this.dateAndTimeDatesList.dataProvider : null;
		if (dateAndTimeDatesCollection != null &&
			(oldMinYear != this._minYear || oldMaxYear != this._maxYear ||
			oldMinMonth != this._minMonth || oldMaxMonth != this._maxMonth ||
			oldMinDate != this._minDate || oldMaxDate != this._maxDate))
		{
			dateAndTimeDatesCollection.updateAll();
		}
		var hoursCollection:IListCollection = this.hoursList != null ? this.hoursList.dataProvider : null;
		if (hoursCollection != null && (oldMinHours != this._minHours || oldMaxHours != this._maxHours ||
			(this._showMeridiem && this._lastMeridiemValue != this.meridiemList.selectedIndex)))
		{
			hoursCollection.updateAll();
		}
		var minutesCollection:IListCollection = this.minutesList != null ? this.minutesList.dataProvider : null;
		if (minutesCollection != null && (oldMinMinutes != this._minMinute || oldMaxMinutes != this._maxMinute))
		{
			minutesCollection.updateAll();
		}
		if (this._showMeridiem)
		{
			this._lastMeridiemValue = (this._value.getHours() <= MAX_HOURS_VALUE_12HOURS) ? 0 : 1;
		}
	}
	
	/**
	 * @private
	 */
	private function useDefaultsIfNeeded():Void
	{
		if (this._value == null)
		{
			//if we don't have a value, try to use today's date
			this._value = Date.now();
			//but if there's an existing range, keep the value in there
			if (this._minimum != null && this._value.getTime() < this._minimum.getTime())
			{
				//this._value.time = this._minimum.time;
				this._value = Date.fromTime(this._minimum.getTime());
			}
			else if (this._maximum != null && this._value.getTime() > this._maximum.getTime())
			{
				//this._value.time = this._maximum.time;
				this._value = Date.fromTime(this._maximum.getTime());
			}
		}
		if (this._minimum != null)
		{
			//we want to be able to see years outside the range between
			//minimum and maximum, even if we cannot select them. otherwise,
			//it'll look weird to loop back to the beginning or end.
			if (this._editingMode == DateTimeMode.DATE_AND_TIME)
			{
				//in this editing mode, the date is only controlled by one
				//spinner list, that increments by day. we shouldn't need to
				//go back more than a year.
				this._listMinYear = this._minimum.getFullYear() - 1;
			}
			else
			{
				//in this editing mode, the year, month, and date are
				//selected separately, so we should have a bigger range
				this._listMinYear = this._minimum.getFullYear() - 10;
			}
		}
		//if there's no minimum, we need to generate something that is
		//arbitrary, but acceptable for most needs
		else if (this._editingMode == DateTimeMode.DATE_AND_TIME)
		{
			//in this editing mode, the date is only controlled by one
			//spinner list, that increments by day. we shouldn't need to
			//go back more than a year.
			//HELPER_DATE.time = this._value.time;
			//this._listMinYear = HELPER_DATE.fullYear - 1;
			this._listMinYear = this._value.getFullYear() - 1;
			this._minimum = new Date(this._listMinYear, MIN_MONTH_VALUE, MIN_DATE_VALUE,
				MIN_HOURS_VALUE, MIN_MINUTES_VALUE, 0);
		}
		else
		{
			//in this editing mode, the year, month, and date are
			//selected separately, so we should have a bigger range
			//HELPER_DATE.time = this._value.time;
			//goes back 100 years, rounded down to the nearest half century
			//for 2015, this would give us 1900
			//for 2065, this would give us 1950
			//this._listMinYear = roundDownToNearest(HELPER_DATE.fullYear - 100, 50);
			#if neko
			this._listMinYear = 1971;
			#elseif cpp
			this._listMinYear = 1970;
			#else
			this._listMinYear = Std.int(MathUtils.roundDownToNearest(this._value.getFullYear() - 100, 50));
			#end
			this._minimum = new Date(this._listMinYear, MIN_MONTH_VALUE, MIN_DATE_VALUE,
				MIN_HOURS_VALUE, MIN_MINUTES_VALUE, 0);
		}
		if (this._maximum != null)
		{
			if (this._editingMode == DateTimeMode.DATE_AND_TIME)
			{
				this._listMaxYear = this._maximum.getFullYear() + 1;
			}
			else
			{
				this._listMaxYear = this._maximum.getFullYear() + 10;
			}
		}
		else if (this._editingMode == DateTimeMode.DATE_AND_TIME)
		{
			//in this editing mode, the date is only controlled by one
			//spinner list, that increments by day. we shouldn't need to
			//go forward more than a year.
			//HELPER_DATE.time = this._value.time;
			//this._listMaxYear = HELPER_DATE.fullYear + 1;
			this._listMaxYear = this._value.getFullYear() + 1;
			this._maximum = new Date(this._listMaxYear, MAX_MONTH_VALUE,
				DAYS_IN_MONTH[MAX_MONTH_VALUE], MAX_HOURS_VALUE_24HOURS,
				MAX_MINUTES_VALUE, 0);
		}
		else //date
		{
			//for 2015, this would give us 2150
			//for 2065, this would give us 2200
			//HELPER_DATE.time = this._value.time;
			//this._listMaxYear = roundUpToNearest(HELPER_DATE.fullYear + 100, 50);
			#if neko
			this._listMaxYear = 2037;
			#else
			this._listMaxYear = Std.int(MathUtils.roundUpToNearest(this._value.getFullYear() + 100, 50));
			#end
			this._maximum = new Date(this._listMaxYear, MAX_MONTH_VALUE,
				DAYS_IN_MONTH[MAX_MONTH_VALUE], MAX_HOURS_VALUE_24HOURS,
				MAX_MINUTES_VALUE, 0);
		}
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
		if (this.currentBackgroundSkin != null &&
			(this.currentBackgroundSkin.width != this.actualWidth ||
			this.currentBackgroundSkin.height != this.actualHeight))
		{
			this.currentBackgroundSkin.width = this.actualWidth;
			this.currentBackgroundSkin.height = this.actualHeight;
		}
		this.listGroup.x = this._paddingLeft;
		this.listGroup.y = this._paddingTop;
		this.listGroup.width = this.actualWidth - this._paddingLeft - this._paddingRight;
		this.listGroup.height = this.actualHeight - this._paddingTop - this._paddingBottom;
		this.listGroup.validate();
	}
	
	/**
	 * @private
	 */
	private function handlePendingScroll():Void
	{
		if (this.pendingScrollToDate == null)
		{
			return;
		}
		var pendingDate:Date = this.pendingScrollToDate;
		this.pendingScrollToDate = null;
		var duration:Float = this.pendingScrollDuration;
		if (duration != duration) //isNaN
		{
			duration = this._scrollDuration;
		}
		if (this.yearsList != null)
		{
			var year:Int = pendingDate.getFullYear();
			if (this.yearsList.selectedItem != year)
			{
				var yearRange:IntegerRangeCollection = cast this.yearsList.dataProvider;
				this.yearsList.scrollToDisplayIndex(year - yearRange.minimum, duration);
			}
		}
		if (this.monthsList != null)
		{
			var month:Int = pendingDate.getMonth();
			if (this.monthsList.selectedItem != month)
			{
				this.monthsList.scrollToDisplayIndex(month, duration);
			}
		}
		if (this.datesList != null)
		{
			var date:Int = pendingDate.getDate();
			if (this.datesList.selectedItem != date)
			{
				this.datesList.scrollToDisplayIndex(date - 1, duration);
			}
		}
		if (this.dateAndTimeDatesList != null)
		{
			var dateIndex:Int = Std.int((pendingDate.getTime() - this._minimum.getTime()) / MS_PER_DAY);
			if (this.dateAndTimeDatesList.selectedIndex != dateIndex)
			{
				this.dateAndTimeDatesList.scrollToDisplayIndex(dateIndex, duration);
			}
		}
		if (this.hoursList != null)
		{
			var hours:Int = pendingDate.getHours();
			if (this._showMeridiem)
			{
				hours %= 12;
			}
			if (this.hoursList.selectedItem != hours)
			{
				this.hoursList.scrollToDisplayIndex(hours, duration);
			}
		}
		if (this.minutesList != null)
		{
			var minutes:Int = pendingDate.getMinutes();
			if (this.minutesList.selectedItem != minutes)
			{
				this.minutesList.scrollToDisplayIndex(minutes, duration);
			}
		}
		if (this.meridiemList != null)
		{
			var index:Int = (pendingDate.getHours() < MAX_HOURS_VALUE_12HOURS) ? 0 : 1;
			if (this.meridiemList.selectedIndex != index)
			{
				this.meridiemList.scrollToDisplayIndex(index, duration);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function isMonthEnabled(month:Int):Bool
	{
		return month >= this._minMonth && month <= this._maxMonth;
	}

	/**
	 * @private
	 */
	private function isYearEnabled(year:Int):Bool
	{
		return year >= this._minYear && year <= this._maxYear;
	}

	/**
	 * @private
	 */
	private function isDateEnabled(date:Int):Bool
	{
		return date >= this._minDate && date <= this._maxDate;
	}
	
	/**
	 * @private
	 */
	private function isHourEnabled(hour:Int):Bool
	{
		if (this._showMeridiem && this.meridiemList.selectedIndex != 0)
		{
			hour += 12;
		}
		return hour >= this._minHours && hour <= this._maxHours;
	}
	
	/**
	 * @private
	 */
	private function isMinuteEnabled(minute:Int):Bool
	{
		return minute >= this._minMinute && minute <= this._maxMinute;
	}
	
	/**
	 * @private
	 */
	private function formatHours(item:Int):String
	{
		if (this._showMeridiem)
		{
			if (item == 0)
			{
				item = 12;
			}
			return Std.string(item);
		}
		var hours:String = Std.string(item);
		if (hours.length < 2)
		{
			hours = "0" + hours;
		}
		return hours;
	}
	
	/**
	 * @private
	 */
	private function formatMinutes(item:Int):String
	{
		var minutes:String = Std.string(item);
		if (minutes.length < 2)
		{
			minutes = "0" + minutes;
		}
		return minutes;
	}
	
	/**
	 * @private
	 */
	private function formatDateAndTimeWeekday(item:Dynamic):String
	{
		if (Std.isOfType(item, Int))
		{
			//HELPER_DATE.setTime(this._minimum.time);
			//HELPER_DATE.setDate(HELPER_DATE.date + item);
			HELPER_DATE = new Date(this._minimum.getFullYear(), this._minimum.getMonth(),
				this._minimum.getDate() + item, this._minimum.getHours(), this._minimum.getMinutes(),
				this._minimum.getSeconds());
			if (this._todayLabel != null)
			{
				//_lastValidate will be updated once per validation when
				//scrolling, which is better than creating many duplicate Date
				//objects in this function
				if (HELPER_DATE.getFullYear() == this._lastValidate.getFullYear() &&
					HELPER_DATE.getMonth() == this._lastValidate.getMonth() &&
					HELPER_DATE.getDate() == this._lastValidate.getDate())
				{
					return "";
				}
			}
			return this._localeWeekdayNames[HELPER_DATE.getDay()];
		}
		//this value is used for measurement to try to avoid truncated text.
		//it will not be displayed!
		return "Wom";
	}
	
	/**
	 * @private
	 */
	private function formatDateAndTimeDate(item:Dynamic):String
	{
		if (Std.isOfType(item, Int))
		{
			//HELPER_DATE.setTime(this._minimum.time);
			//HELPER_DATE.setDate(HELPER_DATE.date + item);
			HELPER_DATE = new Date(this._minimum.getFullYear(), this._minimum.getMonth(),
				this._minimum.getDate() + item, this._minimum.getHours(), this._minimum.getMinutes(),
				this._minimum.getSeconds());
			if (this._todayLabel != null)
			{
				//_lastValidate will be updated once per validation when
				//scrolling, which is better than creating many duplicate Date
				//objects in this function
				if (HELPER_DATE.getFullYear() == this._lastValidate.getFullYear() &&
					HELPER_DATE.getMonth() == this._lastValidate.getMonth() &&
					HELPER_DATE.getDate() == this._lastValidate.getDate())
				{
					return this._todayLabel;
				}
			}
			var monthName:String = this._localeMonthNames[HELPER_DATE.getMonth()];
			if (this._monthFirst)
			{
				return monthName + " " + HELPER_DATE.getDate();
			}
			return HELPER_DATE.getDate() + " " + monthName;
		}
		//this value is used for measurement to try to avoid truncated text.
		//it will not be displayed!
		return "Wom 30";
	}
	
	/**
	 * @private
	 */
	private function formatMonthName(item:Int):String
	{
		return this._localeMonthNames[item];
	}
	
	/**
	 * @private
	 */
	private function validateNewValue():Void
	{
		var currentTime:Float = this._value.getTime();
		var minimumTime:Float = this._minimum.getTime();
		var maximumTime:Float = this._maximum.getTime();
		var needsToScroll:Bool = false;
		if (currentTime < minimumTime)
		{
			needsToScroll = true;
			//this._value.setTime(minimumTime);
			this._value = Date.fromTime(minimumTime);
		}
		else if (currentTime > maximumTime)
		{
			needsToScroll = true;
			//this._value.setTime(maximumTime);
			this._value = Date.fromTime(maximumTime);
		}
		if (needsToScroll)
		{
			this.scrollToDate(this._value);
		}
	}
	
	/**
	 * @private
	 */
	private function updateHoursFromLists():Bool
	{
		var hours:Int = this.hoursList.selectedItem;
		if (this.meridiemList != null && this.meridiemList.selectedIndex == 1)
		{
			hours += 12;
		}
		if (this._value.getHours() == hours)
		{
			return false;
		}
		//this._value.setHours(hours);
		this._value = new Date(this._value.getFullYear(), this._value.getMonth(), this._value.getDate(),
			hours, this._value.getMinutes(), this._value.getSeconds());
		return true;
	}
	
	/**
	 * @private
	 */
	private function minutesList_rendererAddHandler(event:Event, itemRenderer:DefaultListItemRenderer):Void
	{
		itemRenderer.labelFunction = formatMinutes;
		itemRenderer.enabledFunction = isMinuteEnabled;
		itemRenderer.itemHasEnabled = true;
	}

	/**
	 * @private
	 */
	private function hoursList_rendererAddHandler(event:Event, itemRenderer:DefaultListItemRenderer):Void
	{
		itemRenderer.labelFunction = formatHours;
		itemRenderer.enabledFunction = isHourEnabled;
		itemRenderer.itemHasEnabled = true;
	}
	
	/**
	 * @private
	 */
	private function dateAndTimeDatesList_rendererAddHandler(event:Event, itemRenderer:DefaultListItemRenderer):Void
	{
		itemRenderer.labelFunction = formatDateAndTimeDate;
		itemRenderer.accessoryLabelFunction = formatDateAndTimeWeekday;
	}
	
	/**
	 * @private
	 */
	private function monthsList_rendererAddHandler(event:Event, itemRenderer:DefaultListItemRenderer):Void
	{
		itemRenderer.labelFunction = formatMonthName;
		itemRenderer.enabledFunction = isMonthEnabled;
		itemRenderer.itemHasEnabled = true;
	}
	
	/**
	 * @private
	 */
	private function datesList_rendererAddHandler(event:Event, itemRenderer:DefaultListItemRenderer):Void
	{
		itemRenderer.enabledFunction = isDateEnabled;
		itemRenderer.itemHasEnabled = true;
	}

	/**
	 * @private
	 */
	private function yearsList_rendererAddHandler(event:Event, itemRenderer:DefaultListItemRenderer):Void
	{
		itemRenderer.enabledFunction = isYearEnabled;
		itemRenderer.itemHasEnabled = true;
	}
	
	/**
	 * @private
	 */
	private function monthsList_changeHandler(event:Event):Void
	{
		if (this._ignoreListChanges)
		{
			return;
		}
		var month:Int = this.monthsList.selectedItem;
		var date:Int = this.getValidDateForYearAndMonth(this._value.getFullYear(), month);
		var needsToScroll:Bool = this._value.getDate() != date;
		if (!needsToScroll && this._value.getMonth() == month)
		{
			return;
		}
		//this._value.setMonth(month, date);
		this._value = new Date(this._value.getFullYear(), month, date, this._value.getHours(),
			this._value.getMinutes(), this._value.getSeconds());
		this.validateNewValue();
		this.refreshValidRanges();
		this.dispatchEventWith(Event.CHANGE);
		if (needsToScroll)
		{
			this.scrollToDate(this._value);
		}
	}
	
	/**
	 * @private
	 */
	private function datesList_changeHandler(event:Event):Void
	{
		if (this._ignoreListChanges)
		{
			return;
		}
		var date:Int = this.datesList.selectedItem;
		if (this._value.getDate() == date)
		{
			return;
		}
		//this._value.setDate(date);
		this._value = new Date(this._value.getFullYear(), this._value.getMonth(), date,
			this._value.getHours(), this._value.getMinutes(), this._value.getSeconds());
		this.validateNewValue();
		this.refreshValidRanges();
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @private
	 */
	private function yearsList_changeHandler(event:Event):Void
	{
		if (this._ignoreListChanges)
		{
			return;
		}
		var year:Int = this.yearsList.selectedItem;
		if (this._value.getFullYear() == year)
		{
			return;
		}
		//this._value.setFullYear(year);
		this._value = new Date(year, this._value.getMonth(), this._value.getDate(),
			this._value.getHours(), this._value.getMinutes(), this._value.getSeconds());
		this.validateNewValue();
		this.refreshValidRanges();
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @private
	 */
	private function dateAndTimeDatesList_changeHandler(event:Event):Void
	{
		if (this._ignoreListChanges)
		{
			return;
		}
		//this._value.setFullYear(this._minimum.fullYear, this._minimum.month, this._minimum.date + this.dateAndTimeDatesList.selectedIndex);
		this._value = new Date(this._minimum.getFullYear(), this._minimum.getMonth(), this._minimum.getDate() + this.dateAndTimeDatesList.selectedIndex,
			this._value.getHours(), this._value.getMinutes(), this._value.getSeconds());
		this.validateNewValue();
		this.refreshValidRanges();
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @private
	 */
	private function hoursList_changeHandler(event:Event):Void
	{
		if (this._ignoreListChanges)
		{
			return;
		}
		if (!this.updateHoursFromLists())
		{
			return;
		}
		this.validateNewValue();
		this.refreshValidRanges();
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @private
	 */
	private function minutesList_changeHandler(event:Event):Void
	{
		if (this._ignoreListChanges)
		{
			return;
		}
		var minutes:Int = this.minutesList.selectedItem;
		if (this._value.getMinutes() == minutes)
		{
			return;
		}
		//this._value.setMinutes(minutes);
		this._value = new Date(this._value.getFullYear(), this._value.getMonth(), this._value.getDate(),
			this._value.getHours(), minutes, this._value.getSeconds());
		this.validateNewValue();
		this.refreshValidRanges();
		this.dispatchEventWith(Event.CHANGE);
	}
	
	/**
	 * @private
	 */
	private function meridiemList_changeHandler(event:Event):Void
	{
		if (this._ignoreListChanges)
		{
			return;
		}
		if (!this.updateHoursFromLists())
		{
			return;
		}
		this.validateNewValue();
		this.refreshValidRanges();
		this.dispatchEventWith(Event.CHANGE);
	}
	
}

class IntegerRangeCollection extends EventDispatcher implements IListCollection
{
	public function new(minimum:Int = 0, maximum:Int = 1, step:Int = 1)
	{
		super();
		this._minimum = minimum;
		this._maximum = maximum;
		this._step = step;
	}
	
	public var minimum(get, set):Int;
	private var _minimum:Int;
	private function get_minimum():Int { return this._minimum; }
	private function set_minimum(value:Int):Int
	{
		if (this._minimum == value)
		{
			return value;
		}
		this._minimum = value;
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
		return this._minimum;
	}
	
	public var maximum(get, set):Int;
	private var _maximum:Int;
	private function get_maximum():Int { return this._maximum; }
	private function set_maximum(value:Int):Int
	{
		if (this._maximum == value)
		{
			return value;
		}
		this._maximum = value;
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
		return this._maximum;
	}
	
	public var step(get, set):Int;
	private var _step:Int;
	private function get_step():Int { return this._step; }
	private function set_step(value:Int):Int
	{
		if (this._step == value)
		{
			return value;
		}
		this._step = value;
		this.dispatchEventWith(CollectionEventType.RESET);
		this.dispatchEventWith(Event.CHANGE);
		return this._step;
	}
	
	public var filterFunction(get, set):Dynamic->Bool;
	private function get_filterFunction():Dynamic->Bool { return null; }
	private function set_filterFunction(value:Dynamic->Bool):Dynamic->Bool
	{
		throw new Error("Not implemented");
	}
	
	public var sortCompareFunction(get, set):Dynamic->Dynamic->Int;
	private function get_sortCompareFunction():Dynamic->Dynamic->Int { return null; }
	private function set_sortCompareFunction(value:Dynamic->Dynamic->Int):Dynamic->Dynamic->Int
	{
		throw new Error("Not implemented");
	}
	
	public var data(get, set):Dynamic;
	private function get_data():Dynamic { return null; }
	private function set_data(value:Dynamic):Dynamic
	{
		throw new Error("Not implemented");
	}
	
	public var length(get, never):Int;
	private function get_length():Int
	{
		return 1 + Std.int((this._maximum - this._minimum) / this._step);
	}
	
	public function getItemAt(index:Int):Dynamic
	{
		var maximum:Int = this._maximum;
		var result:Int = this._minimum + index * this._step;
		if (result > maximum)
		{
			result = maximum;
		}
		return result;
	}
	
	public function contains(item:Dynamic):Bool
	{
		if (!Std.isOfType(item, Int))
		{
			return false;
		}
		var value:Int = item;
		return Math.ceil((value - this._minimum) / this._step) != -1;
	}
	
	public function getItemIndex(item:Dynamic):Int
	{
		if (!Std.isOfType(item, Int))
		{
			return -1;
		}
		var value:Int = item;
		return Math.ceil((value - this._minimum) / this._step);
	}
	
	public function refreshFilter():Void
	{
		throw new Error("Not implemented");
	}
	
	public function refresh():Void
	{
		throw new Error("Not implemented");
	}
	
	public function setItemAt(item:Dynamic, index:Int):Void
	{
		throw new Error("Not implemented");
	}
	
	public function addItem(item:Dynamic):Void
	{
		throw new Error("Not implemented");
	}
	
	public function addItemAt(item:Dynamic, index:Int):Void
	{
		throw new Error("Not implemented");
	}

	public function push(item:Dynamic):Void
	{
		throw new Error("Not implemented");
	}

	public function shift():Dynamic
	{
		throw new Error("Not implemented");
	}

	public function removeItem(item:Dynamic):Void
	{
		throw new Error("Not implemented");
	}

	public function removeItemAt(index:Int):Dynamic
	{
		throw new Error("Not implemented");
	}

	public function unshift(item:Dynamic):Void
	{
		throw new Error("Not implemented");
	}

	public function removeAll():Void
	{
		throw new Error("Not implemented");
	}

	public function pop():Dynamic
	{
		throw new Error("Not implemented");
	}

	public function addAll(collection:IListCollection):Void
	{
		throw new Error("Not implemented");
	}

	public function addAllAt(collection:IListCollection, index:Int):Void
	{
		throw new Error("Not implemented");
	}

	public function reset(collection:IListCollection):Void
	{
		throw new Error("Not implemented");
	}

	public function updateItemAt(index:Int):Void
	{
		this.dispatchEventWith(CollectionEventType.UPDATE_ITEM, false, index);
	}

	public function updateAll():Void
	{
		this.dispatchEventWith(CollectionEventType.UPDATE_ALL);
	}

	public function dispose(callback:Dynamic->Void):Void
	{
		throw new Error("Not implemented");
	}
}