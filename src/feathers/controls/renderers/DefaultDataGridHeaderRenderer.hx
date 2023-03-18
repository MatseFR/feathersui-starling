/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.renderers;

import feathers.controls.DataGrid;
import feathers.controls.DataGridColumn;
import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IMeasureDisplayObject;
import feathers.core.ITextRenderer;
import feathers.core.IValidating;
import feathers.data.SortOrder;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.skins.IStyleProvider;
import feathers.text.FontStylesSet;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.touch.TapToTrigger;
import feathers.utils.type.SafeCast;
import openfl.geom.Point;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.text.TextFormat;
import starling.utils.Pool;

/**
 * The default renderer used for headers in a <code>DataGrid</code> component.
 *
 * @see feathers.controls.DataGrid
 *
 * @productversion Feathers 3.4.0
 */
class DefaultDataGridHeaderRenderer extends FeathersControl implements IDataGridHeaderRenderer
{
	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * text renderer.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER:String = "feathers-data-grid-header-renderer-text-renderer";

	/**
	 * The default <code>IStyleProvider</code> for all <code>DefaultDataGridHeaderRenderer</code>
	 * components.
	 *
	 * @default null
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;

	/**
	 * @private
	 */
	private static function defaultImageLoaderFactory():ImageLoader
	{
		return new ImageLoader();
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
	 * @private
	 */
	private var _tapToTrigger:TapToTrigger;
	
	/**
	 * The value added to the <code>styleNameList</code> of the text
	 * renderer. This variable is <code>protected</code> so that
	 * sub-classes can customize the label text renderer style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER</code>.
	 *
	 * <p>To customize the text renderer style name without
	 * subclassing, see <code>customTextRendererStyleName</code>.</p>
	 *
	 * @see #style:customTextRendererStyleName
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var textRendererStyleName:String = DEFAULT_CHILD_STYLE_NAME_TEXT_RENDERER;
	
	/**
	 * @private
	 */
	private var textRenderer:ITextRenderer;
	
	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return DefaultDataGridHeaderRenderer.globalStyleProvider;
	}
	
	/**
	 * @inheritDoc
	 */
	public var data(get, set):DataGridColumn;
	private var _data:DataGridColumn;
	private function get_data():DataGridColumn { return this._data; }
	private function set_data(value:DataGridColumn):DataGridColumn
	{
		if (this._data == value)
		{
			return value;
		}
		this._data = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._data;
	}
	
	/**
	 * @inheritDoc
	 */
	public var columnIndex(get, set):Int;
	private var _columnIndex:Int = -1;
	private function get_columnIndex():Int { return this._columnIndex; }
	private function set_columnIndex(value:Int):Int
	{
		return this._columnIndex = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public var owner(get, set):DataGrid;
	private var _owner:DataGrid;
	private function get_owner():DataGrid { return this._owner; }
	private function set_owner(value:DataGrid):DataGrid
	{
		if (this._owner == value)
		{
			return value;
		}
		this._owner = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._owner;
	}
	
	/**
	 * @inheritDoc
	 */
	public var sortOrder(get, set):String;
	private var _sortOrder:String = SortOrder.NONE;
	private function get_sortOrder():String { return this._sortOrder; }
	private function set_sortOrder(value:String):String
	{
		if (this._sortOrder == value)
		{
			return value;
		}
		this._sortOrder = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._sortOrder;
	}
	
	/**
	 * @private
	 */
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.LEFT;
	private function get_horizontalAlign():String { return this._horizontalAlign; }
	private function set_horizontalAlign(value:String):String
	{
		if (this.processStyleRestriction("horizontalAlign"))
		{
			return value;
		}
		if (this._horizontalAlign == value)
		{
			return value;
		}
		this._horizontalAlign = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._horizontalAlign;
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
		this._wordWrap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._wordWrap;
	}
	
	/**
	 * A function that generates an <code>ITextRenderer</code> that
	 * displays the header's text. The factory may be used to set custom
	 * properties on the <code>ITextRenderer</code>.
	 *
	 * <p>In the following example, a custom text renderer factory is passed
	 * to the renderer:</p>
	 *
	 * <listing version="3.0">
	 * headerRenderer.textRendererFactory = function():ITextRenderer
	 * {
	 *     var textRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
	 *     textRenderer.textFormat = new TextFormat( "Source Sans Pro", 16, 0x333333 );
	 *     textRenderer.embedFonts = true;
	 *     return textRenderer;
	 * };</listing>
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
	private var _explicitTextRendererWidth:Float;

	/**
	 * @private
	 */
	private var _explicitTextRendererHeight:Float;

	/**
	 * @private
	 */
	private var _explicitTextRendererMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitTextRendererMinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitTextRendererMaxWidth:Float;

	/**
	 * @private
	 */
	private var _explicitTextRendererMaxHeight:Float;

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
	private var currentSortIcon:DisplayObject = null;
	
	/**
	 * @private
	 */
	public var sortAscendingIcon(get, set):DisplayObject;
	private var _sortAscendingIcon:DisplayObject;
	private function get_sortAscendingIcon():DisplayObject { return this._sortAscendingIcon; }
	private function set_sortAscendingIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("sortAscendingIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._sortAscendingIcon == value)
		{
			return value;
		}
		if (this._sortAscendingIcon != null &&
			this.currentSortIcon == this._sortAscendingIcon)
		{
			this.removeCurrentSortIcon(this._sortAscendingIcon);
			this.currentSortIcon = null;
		}
		this._sortAscendingIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._sortAscendingIcon;
	}
	
	/**
	 * @private
	 */
	public var sortDescendingIcon(get, set):DisplayObject;
	private var _sortDescendingIcon:DisplayObject;
	private function get_sortDescendingIcon():DisplayObject { return this._sortDescendingIcon; }
	private function set_sortDescendingIcon(value:DisplayObject):DisplayObject
	{
		if (this.processStyleRestriction("sortDescendingIcon"))
		{
			if (value != null)
			{
				value.dispose();
			}
			return value;
		}
		if (this._sortDescendingIcon == value)
		{
			return value;
		}
		if(this._sortDescendingIcon != null &&
			this.currentSortIcon == this._sortDescendingIcon)
		{
			this.removeCurrentSortIcon(this._sortDescendingIcon);
			this.currentSortIcon = null;
		}
		this._sortDescendingIcon = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._sortDescendingIcon;
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
	 * The number of text lines displayed by the renderer. The component may
	 * contain multiple text lines if the text contains line breaks or if
	 * the <code>wordWrap</code> property is enabled.
	 *
	 * @see #wordWrap
	 */
	public var numLines(get, never):Int;
	private function get_numLines():Int
	{
		if (this.textRenderer == null)
		{
			return 0;
		}
		return this.textRenderer.numLines;
	}
	
	override public function dispose():Void 
	{
		//we don't dispose it if the renderer is the parent because it'll
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
		if (this._fontStylesSet != null)
		{
			this._fontStylesSet.dispose();
			this._fontStylesSet = null;
		}
		super.dispose();
	}
	
	/**
	 * Determines which text to display in the header.
	 */
	private function itemToText(item:DataGridColumn):String
	{
		if (item != null)
		{
			if (item.headerText != null)
			{
				return item.headerText;
			}
			else if (item.dataField != null)
			{
				return item.dataField;
			}
			return Std.string(item);
		}
		return null;
	}
	
	/**
	 * @private
	 */
	override function initialize():Void 
	{
		super.initialize();
		
		if (this._tapToTrigger == null)
		{
			this._tapToTrigger = new TapToTrigger(this);
		}
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var textRendererInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		
		if (stylesInvalid || stateInvalid)
		{
			this.refreshBackgroundSkin();
		}
		
		if (stylesInvalid || dataInvalid)
		{
			this.refreshSortIcon();
		}
		
		if (textRendererInvalid)
		{
			this.createTextRenderer();
		}
		
		if (textRendererInvalid || dataInvalid)
		{
			this.commitData();
		}
		
		if (dataInvalid || stylesInvalid)
		{
			this.refreshTextRendererStyles();
		}
		
		if (dataInvalid || stateInvalid)
		{
			this.refreshEnabled();
		}
		
		sizeInvalid = this.autoSizeIfNeeded() || sizeInvalid;
		this.layoutChildren();
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
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(cast this.textRenderer,
			this._explicitWidth - this._paddingLeft - this._paddingRight,
			this._explicitHeight - this._paddingTop - this._paddingBottom,
			this._explicitMinWidth - this._paddingLeft - this._paddingRight,
			this._explicitMinHeight - this._paddingTop - this._paddingBottom,
			this._explicitMaxWidth - this._paddingLeft - this._paddingRight,
			this._explicitMaxHeight - this._paddingTop - this._paddingBottom,
			this._explicitTextRendererWidth, this._explicitTextRendererHeight,
			this._explicitTextRendererMinWidth, this._explicitTextRendererMinHeight,
			this._explicitTextRendererMaxWidth, this._explicitTextRendererMaxHeight);
		this.textRenderer.maxWidth = this._explicitMaxWidth - this._paddingLeft - this._paddingRight;
		this.textRenderer.maxHeight = this._explicitMaxHeight - this._paddingTop - this._paddingBottom;
		var point:Point = Pool.getPoint();
		this.textRenderer.measureText(point);
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this.currentBackgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundWidth, this._explicitBackgroundHeight,
			this._explicitBackgroundMinWidth, this._explicitBackgroundMinHeight,
			this._explicitBackgroundMaxWidth, this._explicitBackgroundMaxHeight);
		var measureSkin:IMeasureDisplayObject = SafeCast.safe_cast(this.currentBackgroundSkin, IMeasureDisplayObject);
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			newWidth = point.x;
			newWidth += this._paddingLeft + this._paddingRight;
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.width > newWidth)
			{
				newWidth = this.currentBackgroundSkin.width;
			}
		}
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			newHeight = point.y;
			newHeight += this._paddingTop + this._paddingBottom;
			if (this.currentBackgroundSkin != null &&
				this.currentBackgroundSkin.height > newHeight)
			{
				newHeight = this.currentBackgroundSkin.height;
			}
		}
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			newMinWidth = point.x;
			newMinWidth += this._paddingLeft + this._paddingRight;
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
			newMinHeight = point.y;
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
		}
		Pool.putPoint(point);
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	private function refreshBackgroundSkin():Void
	{
		var oldBackgroundSkin:DisplayObject = this.currentBackgroundSkin;
		this.currentBackgroundSkin = this._backgroundSkin;
		if (!this._isEnabled && this._backgroundDisabledSkin != null)
		{
			this.currentBackgroundSkin = this._backgroundDisabledSkin;
		}
		if (oldBackgroundSkin != this.currentBackgroundSkin)
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
	private function refreshSortIcon():Void
	{
		var oldSortIcon:DisplayObject = this.currentSortIcon;
		this.currentSortIcon = null;
		if (this._sortOrder == SortOrder.ASCENDING)
		{
			this.currentSortIcon = this._sortAscendingIcon;
		}
		else if (this._sortOrder == SortOrder.DESCENDING)
		{
			this.currentSortIcon = this._sortDescendingIcon;
		}
		if (oldSortIcon != this.currentSortIcon)
		{
			this.removeCurrentSortIcon(oldSortIcon);
			if (this.currentSortIcon != null)
			{
				this.addChild(this.currentSortIcon);
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
	private function removeCurrentSortIcon(icon:DisplayObject):Void
	{
		if (icon == null)
		{
			return;
		}
		if (icon.parent == this)
		{
			icon.removeFromParent(false);
		}
	}
	
	/**
	 * @private
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
		this.addChild(cast this.textRenderer);
		
		this.textRenderer.initializeNow();
		this._explicitTextRendererWidth = this.textRenderer.explicitWidth;
		this._explicitTextRendererHeight = this.textRenderer.explicitHeight;
		this._explicitTextRendererMinWidth = this.textRenderer.explicitMinWidth;
		this._explicitTextRendererMinHeight = this.textRenderer.explicitMinHeight;
		this._explicitTextRendererMaxWidth = this.textRenderer.explicitMaxWidth;
		this._explicitTextRendererMaxHeight = this.textRenderer.explicitMaxHeight;
	}
	
	/**
	 * @private
	 */
	private function commitData():Void
	{
		if (this._owner != null)
		{
			this.textRenderer.text = this.itemToText(this._data);
		}
		else
		{
			this.textRenderer.text = null;
		}
	}
	
	/**
	 * @private
	 */
	private function refreshEnabled():Void
	{
		this.textRenderer.isEnabled = this._isEnabled;
	}
	
	/**
	 * @private
	 */
	private function refreshTextRendererStyles():Void
	{
		this.textRenderer.fontStyles = this._fontStylesSet;
		this.textRenderer.wordWrap = this._wordWrap;
	}
	
	/**
	 * @private
	 */
	private function layoutChildren():Void
	{
		if (this.currentBackgroundSkin != null)
		{
			this.currentBackgroundSkin.width = this.actualWidth;
			this.currentBackgroundSkin.height = this.actualHeight;
		}
		
		if (Std.isOfType(this.currentSortIcon, IValidating))
		{
			cast(this.currentSortIcon, IValidating).validate();
		}
		var availableTextWidth:Float = this.actualWidth - this._paddingLeft - this._paddingRight;
		if (this.currentSortIcon != null)
		{
			availableTextWidth -= this.currentSortIcon.width;
		}
		
		this.textRenderer.width = this._explicitTextRendererWidth;
		this.textRenderer.height = this._explicitTextRendererHeight;
		this.textRenderer.minWidth = this._explicitTextRendererMinWidth;
		this.textRenderer.minHeight = this._explicitTextRendererMinHeight;
		this.textRenderer.maxWidth = availableTextWidth;
		this.textRenderer.maxHeight = this._explicitTextRendererMaxHeight;
		this.textRenderer.validate();
		
		switch (this._horizontalAlign)
		{
			case HorizontalAlign.CENTER:
				this.textRenderer.x = this._paddingLeft + (availableTextWidth - this.textRenderer.width) / 2;
			
			case HorizontalAlign.RIGHT:
				this.textRenderer.x = this._paddingLeft + availableTextWidth - this.textRenderer.width;
			
			default: //left
				this.textRenderer.x = this._paddingLeft;
		}
		if (this.currentSortIcon != null)
		{
			this.currentSortIcon.x = this.actualWidth - this._paddingRight - this.currentSortIcon.width;
		}
		
		switch (this._verticalAlign)
		{
			case VerticalAlign.TOP:
				this.textRenderer.y = this._paddingTop;
				if (this.currentSortIcon != null)
				{
					this.currentSortIcon.y = this._paddingTop;
				}
			
			case VerticalAlign.BOTTOM:
				this.textRenderer.y = this.actualHeight - this._paddingBottom - this.textRenderer.height;
				if (this.currentSortIcon != null)
				{
					this.currentSortIcon.y = this.actualHeight - this._paddingBottom - this.currentSortIcon.height;
				}
			
			default: //middle
				this.textRenderer.y = this._paddingTop + (this.actualHeight - this._paddingTop - this._paddingBottom - this.textRenderer.height) / 2;
				if (this.currentSortIcon != null)
				{
					this.currentSortIcon.y = this._paddingTop + (this.actualHeight - this._paddingTop - this._paddingBottom - this.currentSortIcon.height) / 2;
				}
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