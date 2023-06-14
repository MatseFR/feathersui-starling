/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls;

import feathers.starling.core.FeathersControl;
import feathers.starling.core.IFeathersControl;
import feathers.starling.core.IMeasureDisplayObject;
import feathers.starling.core.IValidating;
import feathers.starling.layout.Direction;
import feathers.starling.skins.IStyleProvider;
import feathers.starling.utils.math.MathUtils;
import feathers.starling.utils.skins.SkinsUtils;
import feathers.starling.utils.type.SafeCast;
import starling.display.DisplayObject;

/**
 * Displays the progress of a task over time. Non-interactive.
 *
 * <p>The following example creates a progress bar:</p>
 *
 * <listing version="3.0">
 * var progress:ProgressBar = new ProgressBar();
 * progress.minimum = 0;
 * progress.maximum = 100;
 * progress.value = 20;
 * this.addChild( progress );</listing>
 *
 * @see ../../../help/progress-bar.html How to use the Feathers ProgressBar component
 *
 * @productversion Feathers 1.0.0
 */
class ProgressBar extends FeathersControl 
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>ProgressBar</code>
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
		
	}
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return ProgressBar.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	public var direction(get, set):String;
	private var _direction:String = Direction.HORIZONTAL;
	private function get_direction():String { return this._direction; }
	private function set_direction(value:String):String
	{
		if (this.processStyleRestriction("direction"))
		{
			return value;
		}
		if (this._direction == value)
		{
			return value;
		}
		this._direction = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._direction;
	}
	
	/**
	 * The value of the progress bar, between the minimum and maximum.
	 *
	 * <p>In the following example, the value is set to 12:</p>
	 *
	 * <listing version="3.0">
	 * progress.minimum = 0;
	 * progress.maximum = 100;
	 * progress.value = 12;</listing>
	 *
	 * @default 0
	 *
	 * @see #minimum
	 * @see #maximum
	 */
	public var value(get, set):Float;
	private var _value:Float = 0;
	private function get_value():Float { return this._value; }
	private function set_value(newValue:Float):Float
	{
		newValue = MathUtils.clamp(newValue, this._minimum, this._maximum);
		if (this._value == newValue)
		{
			return value;
		}
		this._value = newValue;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._value;
	}
	
	/**
	 * The progress bar's value will not go lower than the minimum.
	 *
	 * <p>In the following example, the minimum is set to 0:</p>
	 *
	 * <listing version="3.0">
	 * progress.minimum = 0;
	 * progress.maximum = 100;
	 * progress.value = 12;</listing>
	 *
	 * @default 0
	 *
	 * @see #value
	 * @see #maximum
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
	 * The progress bar's value will not go higher than the maximum.
	 *
	 * <p>In the following example, the maximum is set to 100:</p>
	 *
	 * <listing version="3.0">
	 * progress.minimum = 0;
	 * progress.maximum = 100;
	 * progress.value = 12;</listing>
	 *
	 * @default 1
	 *
	 * @see #value
	 * @see #minimum
	 */
	public var maximum(get, set):Float;
	private var _maximum:Float = 1;
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
	private var currentBackground:DisplayObject;
	
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
			this.currentBackground == this._backgroundSkin)
		{
			this.removeCurrentBackground(this._backgroundSkin);
			this.currentBackground = null;
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
			this.currentBackground == this._backgroundDisabledSkin)
		{
			this.removeCurrentBackground(this._backgroundDisabledSkin);
			this.currentBackground = null;
		}
		this._backgroundDisabledSkin = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._backgroundDisabledSkin;
	}
	
	/**
	 * @private
	 * The width of the first fill skin that was displayed.
	 */
	private var _originalFillWidth:Float = Math.NaN;

	/**
	 * @private
	 * The width of the first fill skin that was displayed.
	 */
	private var _originalFillHeight:Float = Math.NaN;

	/**
	 * @private
	 */
	private var currentFill:DisplayObject;
	
	/**
	 * @private
	 */
	public var fillSkin(get, set):DisplayObject;
	private var _fillSkin:DisplayObject;
	private function get_fillSkin():DisplayObject { return this._fillSkin; }
	private function set_fillSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("fillSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._fillSkin == value)
		{
			return value;
		}
		if (this._fillSkin != null && this._fillSkin != this._fillDisabledSkin)
		{
			this.removeChild(this._fillSkin);
		}
		this._fillSkin = value;
		if (this._fillSkin != null && this._fillSkin.parent != this)
		{
			this._fillSkin.visible = false;
			this.addChild(this._fillSkin);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._fillSkin;
	}
	
	/**
	 * @private
	 */
	public var fillDisabledSkin(get, set):DisplayObject;
	private var _fillDisabledSkin:DisplayObject;
	private function get_fillDisabledSkin():DisplayObject { return this._fillDisabledSkin; }
	private function set_fillDisabledSkin(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("fillDisabledSkin"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._fillDisabledSkin == value)
		{
			return value;
		}
		if (this._fillDisabledSkin != null && this._fillDisabledSkin != this._fillSkin)
		{
			this.removeChild(this._fillDisabledSkin);
		}
		this._fillDisabledSkin = value;
		if (this._fillDisabledSkin != null && this._fillDisabledSkin.parent != this)
		{
			this._fillDisabledSkin.visible = false;
			this.addChild(this._fillDisabledSkin);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._fillDisabledSkin;
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
	override public function dispose():Void
	{
		//we don't dispose it if the label is the parent because it'll
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
		super.dispose();
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		
		if (stylesInvalid || stateInvalid)
		{
			this.refreshBackground();
			this.refreshFill();
		}
		
		this.autoSizeIfNeeded();
		
		this.layoutChildren();
		
		if (Std.isOfType(this.currentBackground, IValidating))
		{
			cast(this.currentBackground, IValidating).validate();
		}
		if (Std.isOfType(this.currentFill, IValidating))
		{
			cast(this.currentFill, IValidating).validate();
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
		if (Std.isOfType(this.currentFill, IValidating))
		{
			cast(this.currentFill, IValidating).validate();
		}
		
		//minimum dimensions
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			if (measureBackground != null)
			{
				newMinWidth = measureBackground.minWidth;
			}
			else if (this.currentBackground != null)
			{
				newMinWidth = this._explicitBackgroundMinWidth;
			}
			else
			{
				newMinWidth = 0;
			}
			var fillMinWidth:Float = this._originalFillWidth;
			if (Std.isOfType(this.currentFill, IFeathersControl))
			{
				fillMinWidth = cast(this.currentFill, IFeathersControl).minWidth;
			}
			fillMinWidth += this._paddingLeft + this._paddingRight;
			if (fillMinWidth > newMinWidth)
			{
				newMinWidth = fillMinWidth;
			}
		}
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (measureBackground != null)
			{
				newMinHeight = measureBackground.minHeight;
			}
			else if (this.currentBackground != null)
			{
				newMinHeight = this._explicitBackgroundMinHeight;
			}
			else
			{
				newMinHeight = 0;
			}
			var fillMinHeight:Float = this._originalFillHeight;
			if (Std.isOfType(this.currentFill, IFeathersControl))
			{
				fillMinHeight = cast(this.currentFill, IFeathersControl).minHeight;
			}
			fillMinHeight += this._paddingTop + this._paddingBottom;
			if (fillMinHeight > newMinHeight)
			{
				newMinHeight = fillMinHeight;
			}
		}
		
		//current dimensions
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (this.currentBackground != null)
			{
				newWidth = this.currentBackground.width;
			}
			else
			{
				newWidth = 0;
			}
			var fillWidth:Float = this._originalFillWidth + this._paddingLeft + this._paddingRight;
			if (fillWidth > newWidth)
			{
				newWidth = fillWidth;
			}
		}
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (this.currentBackground != null)
			{
				newHeight = this.currentBackground.height;
			}
			else
			{
				newHeight = 0;
			}
			var fillHeight:Float = this._originalFillHeight + this._paddingTop + this._paddingBottom;
			if (fillHeight > newHeight)
			{
				newHeight = fillHeight;
			}
		}
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	private function refreshBackground():Void
	{
		var oldBackground:DisplayObject = this.currentBackground;
		this.currentBackground = this._backgroundSkin;
		if (!this._isEnabled && this._backgroundDisabledSkin != null)
		{
			this.currentBackground = this._backgroundDisabledSkin;
		}
		if (oldBackground != this.currentBackground)
		{
			this.removeCurrentBackground(oldBackground);
			if (this.currentBackground != null)
			{
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
	private function refreshFill():Void
	{
		this.currentFill = this._fillSkin;
		if (this._fillDisabledSkin != null)
		{
			if (this._isEnabled)
			{
				this._fillDisabledSkin.visible = false;
			}
			else
			{
				this.currentFill = this._fillDisabledSkin;
				if (this._backgroundSkin != null)
				{
					this._fillSkin.visible = false;
				}
			}
		}
		if (this.currentFill != null)
		{
			if (Std.isOfType(this.currentFill, IValidating))
			{
				cast(this.currentFill, IValidating).validate();
			}
			if (this._originalFillWidth != this._originalFillWidth) //isNaN
			{
				this._originalFillWidth = this.currentFill.width;
			}
			if (this._originalFillHeight != this._originalFillHeight) //isNaN
			{
				this._originalFillHeight = this.currentFill.height;
			}
			this.currentFill.visible = true;
		}
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
		if (this.currentBackground != null)
		{
			this.currentBackground.width = this.actualWidth;
			this.currentBackground.height = this.actualHeight;
		}
		
		var percentage:Float;
		if (this._minimum == this._maximum)
		{
			percentage = 1;
		}
		else
		{
			percentage = (this._value - this._minimum) / (this._maximum - this._minimum);
			if (percentage < 0)
			{
				percentage = 0;
			}
			else if (percentage > 1)
			{
				percentage = 1;
			}
		}
		var calculatedHeight:Float;
		if (this._direction == Direction.VERTICAL)
		{
			calculatedHeight = Math.fround(percentage * (this.actualHeight - this._paddingTop - this._paddingBottom));
			if (calculatedHeight < this._originalFillHeight)
			{
				calculatedHeight = this._originalFillHeight;
				//if the size is too small, and the value is equal to the
				//minimum, people don't expect to see the fill
				this.currentFill.visible = this._value > this._minimum;
			}
			else
			{
				//if it was hidden before, we want to show it again
				this.currentFill.visible = true;
			}
			this.currentFill.width = this.actualWidth - this._paddingLeft - this._paddingRight;
			this.currentFill.height = calculatedHeight;
			this.currentFill.x = this._paddingLeft;
			this.currentFill.y = this.actualHeight - this._paddingBottom - this.currentFill.height;
		}
		else //horizontal
		{
			var calculatedWidth:Float = Math.fround(percentage * (this.actualWidth - this._paddingLeft - this._paddingRight));
			if (calculatedWidth < this._originalFillWidth)
			{
				calculatedWidth = this._originalFillWidth;
				//if the size is too small, and the value is equal to the
				//minimum, people don't expect to see the fill
				this.currentFill.visible = this._value > this._minimum;
			}
			else
			{
				//if it was hidden before, we want to show it again
				this.currentFill.visible = true;
			}
			this.currentFill.width = calculatedWidth;
			this.currentFill.height = this.actualHeight - this._paddingTop - this._paddingBottom;
			this.currentFill.x = this._paddingLeft;
			this.currentFill.y = this._paddingTop;
		}
	}
	
}