/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.skins;

import feathers.starling.core.IMeasureDisplayObject;
import feathers.starling.core.IStateContext;
import feathers.starling.core.IStateObserver;
import feathers.starling.core.IToggle;
import feathers.starling.events.FeathersEventType;
import feathers.starling.utils.math.MathUtils;
import openfl.errors.IllegalOperationError;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import feathers.starling.core.IFeathersControl;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;
import starling.textures.Texture;
import starling.utils.Pool;

/**
 * A skin for Feathers components that displays a texture. Has the ability
 * to change its texture based on the current state of the Feathers
 * component that is being skinned.
 *
 * <listing version="3.0">
 * var skin:ImageSkin = new ImageSkin( upTexture );
 * skin.setTextureForState( ButtonState.DOWN, downTexture );
 * skin.setTextureForState( ButtonState.HOVER, hoverTexture );
 * 
 * var button:Button = new Button();
 * button.label = "Click Me";
 * button.defaultSkin = skin;
 * this.addChild( button );</listing>
 *
 * @see starling.display.Image
 *
 * @productversion Feathers 3.0.0
 */
class ImageSkin extends Image implements IMeasureDisplayObject implements IStateObserver
{
	/**
	 * Constructor.
	 */
	public function new(defaultTexture:Texture) 
	{
		super(defaultTexture);
		//the super constructor sets the color property, so we need to wait
		//before restricting it
		this._restrictColor = true;
		this.defaultTexture = defaultTexture;
	}
	
	/**
	 * @private
	 */
	private var _restrictColor:Bool = false;
	
	/**
	 * The default texture that the skin will display. If the component
	 * being skinned supports states, the texture for a specific state may
	 * be specified using the <code>setTextureForState()</code> method. If
	 * no texture has been specified for the current state, the default
	 * texture will be used.
	 *
	 * <p>In the following example, the default texture is specified in the
	 * constructor:</p>
	 *
	 * <listing version="3.0">
	 * var skin:ImageSkin = new ImageSkin( texture );</listing>
	 *
	 * <p>In the following example, the default texture is specified by
	 * setting the property:</p>
	 *
	 * <listing version="3.0">
	 * var skin:ImageSkin = new ImageSkin();
	 * skin.defaultTexture = texture;</listing>
	 *
	 * @default null
	 *
	 * @see #disabledTexture
	 * @see #selectedTexture
	 * @see #setTextureForState()
	 * @see http://doc.starling-framework.org/current/starling/textures/Texture.html starling.textures.Texture
	 */
	public var defaultTexture(get, set):Texture;
	private var _defaultTexture:Texture;
	private function get_defaultTexture():Texture { return this._defaultTexture; }
	private function set_defaultTexture(value:Texture):Texture
	{
		if (this._defaultTexture == value)
		{
			return value;
		}
		this._defaultTexture = value;
		this.updateTextureFromContext();
		return this._defaultTexture;
	}
	
	/**
	 * The texture to display when the <code>stateContext</code> is
	 * an <code>IFeathersControl</code> and its <code>isEnabled</code>
	 * property is <code>false</code>. If a texture has been specified for
	 * the context's current state with <code>setTextureForState()</code>,
	 * it will take precedence over the <code>disabledTexture</code>.
	 *
	 * <p>In the following example, the disabled texture is changed:</p>
	 *
	 * <listing version="3.0">
	 * var skin:ImageSkin = new ImageSkin( upTexture );
	 * skin.disabledTexture = disabledTexture;
	 * 
	 * var button:Button = new Button();
	 * button.defaultSkin = skin;
	 * button.isEnabled = false;</listing>
	 *
	 * @default null
	 *
	 * @see #defaultTexture
	 * @see #selectedTexture
	 * @see #setTextureForState()
	 * @see http://doc.starling-framework.org/current/starling/textures/Texture.html starling.textures.Texture
	 */
	public var disabledTexture(get, set):Texture;
	private var _disabledTexture:Texture;
	private function get_disabledTexture():Texture { return this._disabledTexture; }
	private function set_disabledTexture(value:Texture):Texture
	{
		if (this._disabledTexture == value)
		{
			return value;
		}
		this._disabledTexture = value;
		this.updateTextureFromContext();
		return this._disabledTexture;
	}
	
	/**
	 * The texture to display when the <code>stateContext</code> is
	 * an <code>IToggle</code> instance and its <code>isSelected</code>
	 * property is <code>true</code>. If a texture has been specified for
	 * the context's current state with <code>setTextureForState()</code>,
	 * it will take precedence over the <code>selectedTexture</code>.
	 *
	 * <p>In the following example, the selected texture is changed:</p>
	 *
	 * <listing version="3.0">
	 * var skin:ImageSkin = new ImageSkin( upTexture );
	 * skin.selectedTexture = selectedTexture;
	 * 
	 * var toggleButton:ToggleButton = new ToggleButton();
	 * toggleButton.defaultSkin = skin;
	 * toggleButton.isSelected = true;</listing>
	 *
	 * @default null
	 *
	 * @see #defaultTexture
	 * @see #disabledTexture
	 * @see #setTextureForState()
	 * @see http://doc.starling-framework.org/current/starling/textures/Texture.html starling.textures.Texture
	 */
	public var selectedTexture(get, set):Texture;
	private var _selectedTexture:Texture;
	private function get_selectedTexture():Texture { return this._selectedTexture; }
	private function set_selectedTexture(value:Texture):Texture
	{
		if (this._selectedTexture == value)
		{
			return value;
		}
		this._selectedTexture = value;
		this.updateTextureFromContext();
		return this._selectedTexture;
	}
	
	/**
	 * @private
	 */
	override function set_color(value:UInt):UInt 
	{
		if (this._restrictColor)
		{
			throw new IllegalOperationError("To set the color of an ImageSkin, use defaultColor or setColorForState().");
		}
		return this.scolor = value;
	}
	
	/**
	 * @private
	 * Subclasses may use this setter to change the color.
	 */
	public var scolor(never, set):UInt;
	private function set_scolor(value:UInt):UInt
	{
		return super.color = value;
	}
	
	/**
	 * The default color to use to tint the skin. If the component
	 * being skinned supports states, the color for a specific state may
	 * be specified using the <code>setColorForState()</code> method. If
	 * no color has been specified for the current state, the default
	 * color will be used.
	 *
	 * <p>To set the color of an <code>ImageSkin</code>, the
	 * <code>defaultColor</code> property should be preferred over the
	 * <code>color</code> property defined on
	 * <code>starling.display.Mesh</code>. The <code>ImageSkin</code>
	 * will manage the <code>color</code> property internally.</p>
	 *
	 * <p>A value of <code>uint.MAX_VALUE</code> means that the
	 * <code>color</code> property will not be changed when the context's
	 * state changes.</p>
	 *
	 * <p>In the following example, the default color is specified:</p>
	 *
	 * <listing version="3.0">
	 * var skin:ImageSkin = new ImageSkin();
	 * skin.defaultColor = 0x9f0000;</listing>
	 *
	 * @default 0xffffff
	 *
	 * @see #disabledColor
	 * @see #selectedColor
	 * @see #setColorForState()
	 */
	public var defaultColor(get, set):UInt;
	private var _defaultColor:UInt = 0xffffff;
	private function get_defaultColor():UInt { return this._defaultColor; }
	private function set_defaultColor(value:UInt):UInt
	{
		if (this._defaultColor == value)
		{
			return value;
		}
		this._defaultColor = value;
		this.updateColorFromContext();
		return this._defaultColor;
	}
	
	/**
	 * The color to tint the skin when the <code>stateContext</code> is
	 * an <code>IFeathersControl</code> and its <code>isEnabled</code>
	 * property is <code>false</code>. If a color has been specified for
	 * the context's current state with <code>setColorForState()</code>,
	 * it will take precedence over the <code>disabledColor</code>.
	 *
	 * <p>A value of <code>uint.MAX_VALUE</code> means that the
	 * <code>disabledColor</code> property cannot affect the tint when the
	 * context's state changes.</p>
	 *
	 * <p>In the following example, the disabled color is changed:</p>
	 *
	 * <listing version="3.0">
	 * var skin:ImageSkin = new ImageSkin();
	 * skin.defaultColor = 0xffffff;
	 * skin.disabledColor = 0x999999;
	 * 
	 * var button:Button = new Button();
	 * button.defaultSkin = skin;
	 * button.isEnabled = false;</listing>
	 *
	 * @default uint.MAX_VALUE
	 *
	 * @see #defaultColor
	 * @see #selectedColor
	 * @see #setColorForState()
	 */
	public var disabledColor(get, set):UInt;
	private var _disabledColor:UInt = MathUtils.INT_MAX;
	private function get_disabledColor():UInt { return this._disabledColor; }
	private function set_disabledColor(value:UInt):UInt
	{
		if (this._disabledColor == value)
		{
			return value;
		}
		this._disabledColor = value;
		this.updateColorFromContext();
		return this._disabledColor;
	}
	
	/**
	 * The color to tint the skin when the <code>stateContext</code> is
	 * an <code>IToggle</code> instance and its <code>isSelected</code>
	 * property is <code>true</code>. If a color has been specified for
	 * the context's current state with <code>setColorForState()</code>,
	 * it will take precedence over the <code>selectedColor</code>.
	 *
	 * <p>In the following example, the selected color is changed:</p>
	 *
	 * <listing version="3.0">
	 * var skin:ImageSkin = new ImageSkin();
	 * skin.defaultColor = 0xffffff;
	 * skin.selectedColor = 0xffcc00;
	 * 
	 * var toggleButton:ToggleButton = new ToggleButton();
	 * toggleButton.defaultSkin = skin;
	 * toggleButton.isSelected = true;</listing>
	 *
	 * @default uint.MAX_VALUE
	 *
	 * @see #defaultColor
	 * @see #disabledColor
	 * @see #setColorForState()
	 */
	public var selectedColor(get, set):UInt;
	private var _selectedColor:UInt = MathUtils.INT_MAX;
	private function get_selectedColor():UInt { return this._selectedColor; }
	private function set_selectedColor(value:UInt):UInt
	{
		if (this._selectedColor == value)
		{
			return value;
		}
		this._selectedColor = value;
		this.updateColorFromContext();
		return this._selectedColor;
	}
	
	/**
	 * When the skin observes a state context, the skin may change its
	 * <code>Texture</code> based on the current state of that context.
	 * Typically, a relevant component will automatically assign itself as
	 * the state context of its skin, so this property is considered to be
	 * for internal use only.
	 *
	 * @default null
	 *
	 * @see #setTextureForState()
	 */
	public var stateContext(get, set):IStateContext;
	private var _stateContext:IStateContext;
	private function get_stateContext():IStateContext { return this._stateContext; }
	private function set_stateContext(value:IStateContext):IStateContext
	{
		if (this._stateContext == value)
		{
			return value;
		}
		if (this._stateContext != null)
		{
			this._stateContext.removeEventListener(FeathersEventType.STATE_CHANGE, stateContext_stageChangeHandler);
		}
		this._stateContext = value;
		if (this._stateContext != null)
		{
			this._stateContext.addEventListener(FeathersEventType.STATE_CHANGE, stateContext_stageChangeHandler);
		}
		this.updateTextureFromContext();
		this.updateColorFromContext();
		return this._stateContext;
	}
	
	/**
	 * The value passed to the <code>width</code> property setter. If the
	 * <code>width</code> property has not be set, returns <code>NaN</code>.
	 *
	 * @see #width
	 */
	public var explicitWidth(get, never):Float;
	private var _explicitWidth:Float = Math.NaN;
	private function get_explicitWidth():Float { return this._explicitWidth; }
	
	/**
	 * @private
	 */
	override function set_width(value:Float):Float 
	{
		if (this._explicitWidth == value)
		{
			return value;
		}
		if (value != value && this._explicitWidth != this._explicitWidth) //isNaN
		{
			return value;
		}
		this._explicitWidth = value;
		if (value == value) //!isNaN
		{
			super.width = value;
		}
		else if (this.texture != null)
		{
			//return to the original width of the texture
			this.scaleX = 1;
			this.readjustSize(this.texture.frameWidth);
		}
		else
		{
			this.readjustSize();
		}
		this.dispatchEventWith(Event.RESIZE);
		return this._explicitWidth;
	}
	
	/**
	 * The value passed to the <code>height</code> property setter. If the
	 * <code>height</code> property has not be set, returns
	 * <code>NaN</code>.
	 *
	 * @see #height
	 */
	public var explicitHeight(get, never):Float;
	private var _explicitHeight:Float = Math.NaN;
	private function get_explicitHeight():Float { return this._explicitHeight; }
	
	/**
	 * @private
	 */
	override function set_height(value:Float):Float 
	{
		if (this._explicitHeight == value)
		{
			return value;
		}
		if (value != value && this._explicitHeight != this._explicitHeight) //isNaN
		{
			return value;
		}
		this._explicitHeight = value;
		if (value == value) //!isNaN
		{
			super.height = value;
		}
		else if (this.texture != null)
		{
			//return to the original height of the texture
			this.scaleY = 1;
			this.readjustSize(-1, this.texture.frameHeight);
		}
		else
		{
			this.readjustSize();
		}
		this.dispatchEventWith(Event.RESIZE);
		return this._explicitHeight;
	}
	
	/**
	 * The value passed to the <code>minWidth</code> property setter. If the
	 * <code>minWidth</code> property has not be set, returns
	 * <code>NaN</code>.
	 *
	 * @see #minWidth
	 */
	public var explicitMinWidth(get, never):Float;
	private var _explicitMinWidth:Float = Math.NaN;
	private function get_explicitMinWidth():Float { return this._explicitMinWidth; }
	
	/**
	 * The minimum width of the component.
	 */
	public var minWidth(get, set):Float;
	private function get_minWidth():Float
	{
		if (this._explicitMinWidth == this._explicitMinWidth) //!isNaN
		{
			return this._explicitMinWidth;
		}
		return 0;
	}
	
	private function set_minWidth(value:Float):Float
	{
		if (this._explicitMinWidth == value)
		{
			return value;
		}
		if (value != value && this._explicitMinWidth != this._explicitMinWidth) //isNaN
		{
			return value;
		}
		this._explicitMinWidth = value;
		this.dispatchEventWith(Event.RESIZE);
		return this._explicitMinWidth;
	}
	
	/**
	 * The value passed to the <code>maxWidth</code> property setter. If the
	 * <code>maxWidth</code> property has not be set, returns
	 * <code>NaN</code>.
	 *
	 * @see #maxWidth
	 */
	public var explicitMaxWidth(get, never):Float;
	private var _explicitMaxWidth:Float = Math.POSITIVE_INFINITY;
	private function get_explicitMaxWidth():Float { return this._explicitMaxWidth; }
	
	/**
	 * The maximum width of the component.
	 */
	public var maxWidth(get, set):Float;
	private function get_maxWidth():Float { return this._explicitMaxWidth; }
	private function set_maxWidth(value:Float):Float
	{
		if (this._explicitMaxWidth == value)
		{
			return value;
		}
		if (value != value && this._explicitMaxWidth != this._explicitMaxWidth) //isNaN
		{
			return value;
		}
		this._explicitMaxWidth = value;
		this.dispatchEventWith(Event.RESIZE);
		return this._explicitMaxWidth;
	}
	
	/**
	 * The value passed to the <code>minHeight</code> property setter. If
	 * the <code>minHeight</code> property has not be set, returns
	 * <code>NaN</code>.
	 *
	 * @see #minHeight
	 */
	public var explicitMinHeight(get, never):Float;
	private var _explicitMinHeight:Float = Math.NaN;
	private function get_explicitMinHeight():Float { return this._explicitMinHeight; }
	
	/**
	 * The minimum height of the component.
	 */
	public var minHeight(get, set):Float;
	private function get_minHeight():Float
	{
		if (this._explicitMinHeight == this._explicitMinHeight) //!isNaN
		{
			return this._explicitMinHeight;
		}
		return 0;
	}
	
	private function set_minHeight(value:Float):Float
	{
		if (this._explicitMinHeight == value)
		{
			return value;
		}
		if (value != value && this._explicitMinHeight != this._explicitMinHeight) //isNaN
		{
			return value;
		}
		this._explicitMinHeight = value;
		this.dispatchEventWith(Event.RESIZE);
		return this._explicitMinHeight;
	}
	
	/**
	 * The value passed to the <code>maxHeight</code> property setter. If
	 * the <code>maxHeight</code> property has not be set, returns
	 * <code>NaN</code>.
	 *
	 * @see #maxHeight
	 */
	public var explicitMaxHeight(get, never):Float;
	private var _explicitMaxHeight:Float = Math.POSITIVE_INFINITY;
	private function get_explicitMaxHeight():Float { return this._explicitMaxHeight; }
	
	/**
	 * The maximum height of the component.
	 */
	public var maxHeight(get, set):Float;
	private function get_maxHeight():Float { return this._explicitMaxHeight; }
	private function set_maxHeight(value:Float):Float
	{
		if (this._explicitMaxHeight == value)
		{
			return value;
		}
		if (value != value && this._explicitMaxHeight != this._explicitMaxHeight) //isNaN
		{
			return value;
		}
		this._explicitMaxHeight = value;
		this.dispatchEventWith(Event.RESIZE);
		return this._explicitMaxHeight;
	}
	
	/**
	 * If the skin's width is smaller than this value, the hit area will be expanded.
	 *
	 * <p>In the following example, the minimum width of the hit area is
	 * set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * skin.minTouchWidth = 120;</listing>
	 *
	 * @default 0
	 */
	public var minTouchWidth(get, set):Float;
	private var _minTouchWidth:Float = 0;
	private function get_minTouchWidth():Float { return this._minTouchWidth; }
	private function set_minTouchWidth(value:Float):Float
	{
		return this._minTouchWidth = value;
	}
	
	/**
	 * If the skin's height is smaller than this value, the hit area will be expanded.
	 *
	 * <p>In the following example, the minimum height of the hit area is
	 * set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * skin.minTouchHeight = 120;</listing>
	 *
	 * @default 0
	 */
	public var minTouchHeight(get, set):Float;
	private var _minTouchHeight:Float = 0;
	private function get_minTouchHeight():Float { return this._minTouchHeight; }
	private function set_minTouchHeight(value:Float):Float
	{
		return this._minTouchHeight = value;
	}
	
	/**
	 * @private
	 */
	private var _stateToTexture:Map<String, Texture> = new Map<String, Texture>();
	
	/**
	 * @private
	 */
	private var _stateToColor:Map<String, UInt> = new Map<String, UInt>();
	
	/**
	 * Gets the texture to be used by the skin when the context's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a texture is not defined for a specific state, returns
	 * <code>null</code>.</p>
	 *
	 * @see #setTextureForState()
	 */
	public function getTextureForState(state:String):Texture
	{
		return this._stateToTexture[state];
	}
	
	/**
	 * Sets the texture to be used by the skin when the context's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a texture is not defined for a specific state, the value of the
	 * <code>defaultTexture</code> property will be used instead.</p>
	 *
	 * @see #defaultTexture
	 * @see #getTextureForState()
	 */
	public function setTextureForState(state:String, texture:Texture):Void
	{
		if (texture != null)
		{
			this._stateToTexture[state] = texture;
		}
		else
		{
			this._stateToTexture.remove(state);
		}
		this.updateTextureFromContext();
	}
	
	/**
	 * Gets the color to be used by the skin when the context's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a color is not defined for a specific state, returns
	 * <code>uint.MAX_VALUE</code>.</p>
	 *
	 * @see #setColorForState()
	 */
	public function getColorForState(state:String):UInt
	{
		if (this._stateToColor.exists(state))
		{
			return this._stateToColor[state];
		}
		return MathUtils.INT_MAX;
	}
	
	/**
	 * Sets the color to be used by the skin when the context's
	 * <code>currentState</code> property matches the specified state value.
	 *
	 * <p>If a color is not defined for a specific state, the value of the
	 * <code>defaultTexture</code> property will be used instead.</p>
	 *
	 * <p>To clear a state's color, pass in <code>uint.MAX_VALUE</code>.</p>
	 *
	 * @see #defaultColor
	 * @see #getColorForState()
	 */
	public function setColorForState(state:String, color:UInt):Void
	{
		if (color != MathUtils.INT_MAX)
		{
			this._stateToColor[state] = color;
		}
		else
		{
			this._stateToColor.remove(state);
		}
		this.updateColorFromContext();
	}
	
	/**
	 * @private
	 */
	override public function readjustSize(width:Float = -1, height:Float = -1):Void
	{
		super.readjustSize(width, height);
		if (this._explicitWidth == this._explicitWidth) //!isNaN
		{
			super.width = this._explicitWidth;
		}
		if (this._explicitHeight == this._explicitHeight) //!isNaN
		{
			super.height = this._explicitHeight;
		}
	}
	
	/**
	 * @private
	 */
	override public function hitTest(localPoint:Point):DisplayObject
	{
		if (this._minTouchWidth > 0 || this._minTouchHeight > 0)
		{
			if (!this.visible || !this.touchable)
			{
				return null;
			}
			if (this.mask != null && !this.hitTestMask(localPoint))
			{
				return null;
			}
			var rect:Rectangle = Pool.getRectangle();
			this.getBounds(this, rect);
			var difference:Float;
			if (rect.width < this._minTouchWidth)
			{
			difference = this._minTouchWidth - rect.width;
				rect.width += difference;
				rect.x -= difference / 2;
			}
			if (rect.height < this._minTouchHeight)
			{
				difference = this._minTouchHeight - rect.height;
				rect.height += difference;
				rect.y -= difference / 2;
			}
			var result:Bool = rect.containsPoint(localPoint);
			Pool.putRectangle(rect);
			return result ? this : null;
		}
		return super.hitTest(localPoint);
	}
	
	/**
	 * @private
	 */
	private function updateTextureFromContext():Void
	{
		var texture:Texture = null;
		if (this._stateContext == null)
		{
			texture = this._defaultTexture;
		}
		else
		{
			texture = this._stateToTexture[this._stateContext.currentState];
			if (texture == null &&
				this._disabledTexture != null &&
				Std.isOfType(this._stateContext, IFeathersControl) && !cast(this._stateContext, IFeathersControl).isEnabled)
			{
				texture = this._disabledTexture;
			}
			if (texture == null &&
				this._selectedTexture != null &&
				Std.isOfType(this._stateContext, IToggle) &&
				cast(this._stateContext, IToggle).isSelected)
			{
				texture = this._selectedTexture;
			}
			if (texture == null)
			{
				texture = this._defaultTexture;
			}
		}
		this.texture = texture;
	}
	
	/**
	 * @private
	 */
	private function updateColorFromContext():Void
	{
		if (this._stateContext == null)
		{
			if (this._defaultColor != MathUtils.INT_MAX)
			{
				this.scolor = this._defaultColor;
			}
			return;
		}
		var color:UInt = MathUtils.INT_MAX;
		var currentState:String = this._stateContext.currentState;
		if (this._stateToColor.exists(currentState))
		{
			color = this._stateToColor[currentState];
		}
		if (color == MathUtils.INT_MAX &&
			this._disabledColor != MathUtils.INT_MAX &&
			Std.isOfType(this._stateContext, IFeathersControl) && !cast(this._stateContext, IFeathersControl).isEnabled)
		{
			color = this._disabledColor;
		}
		if (color == MathUtils.INT_MAX &&
			this._selectedColor != MathUtils.INT_MAX &&
			Std.isOfType(this._stateContext, IToggle) &&
			cast(this._stateContext, IToggle).isSelected)
		{
			color = this._selectedColor;
		}
		if (color == MathUtils.INT_MAX)
		{
			color = this._defaultColor;
		}
		if (color != MathUtils.INT_MAX)
		{
			this.scolor = color;
		}
	}
	
	/**
	 * @private
	 */
	private function stateContext_stageChangeHandler(event:Event):Void
	{
		this.updateTextureFromContext();
		this.updateColorFromContext();
	}
	
}