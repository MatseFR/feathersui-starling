/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls.text;
import feathers.core.FeathersControl;
import feathers.skins.IStyleProvider;
import feathers.utils.math.MathUtils;
import openfl.errors.ArgumentError;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import starling.core.Starling;
import starling.utils.MatrixUtil;
import starling.utils.Pool;

/**
 * A text editor view port for the <code>TextArea</code> component that uses
 * <code>flash.text.TextField</code>.
 *
 * @see feathers.controls.TextArea
 *
 * @productversion Feathers 1.1.0
 */
class TextFieldTextEditorViewPort extends TextFieldTextEditor implements
{
	/**
	 * The default <code>IStyleProvider</code> for all <code>TextFieldTextEditorViewPort</code>
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
		this.multiline = true;
		this.wordWrap = true;
		this.resetScrollOnFocusOut = false;
	}
	
	override function get_defaultStyleProvider():IStyleProvider 
	{
		return globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var _ignoreScrolling:Bool = false;
	
	private var _actualMinVisibleWidth:Float = 0;
	
	private var _explicitMinVisibleWidth:Float;
	
	public var minVisibleWidth(get, set):Float;
	private function get_minVisibleWidth():Float
	{
		if (this._explicitMinVisibleWidth != this._explicitMinVisibleWidth) //isNaN
		{
			return this._actualMinVisibleWidth;
		}
		return this._explicitMinVisibleWidth;
	}
	
	private function set_minVisibleWidth(value:Float):Float
	{
		if (this._explicitMinVisibleWidth == value)
		{
			return value;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if(valueIsNaN &&
			this._explicitMinVisibleWidth != this._explicitMinVisibleWidth) //isNaN
		{
			return;
		}
		var oldValue:Float = this._explicitMinVisibleWidth;
		this._explicitMinVisibleWidth = value;
		if(valueIsNaN)
		{
			this._actualMinVisibleWidth = 0;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
		else
		{
			this._actualMinVisibleWidth = value;
			if(this._explicitVisibleWidth != this._explicitVisibleWidth && //isNaN
				(this._actualVisibleWidth < value || this._actualVisibleWidth == oldValue))
			{
				//only invalidate if this change might affect the visibleWidth
				this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
			}
		}
	}
	
	public var maxVisibleWidth(get, set):Float;
	private var _maxVisibleWidth:Float = Math.POSITIVE_INFINITY;
	private function get_maxVisibleWidth():Float { return this._maxVisibleWidth; }
	private function set_maxVisibleWidth(value:Float):Float
	{
		if(this._maxVisibleWidth == value)
		{
			return;
		}
		if(value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleWidth cannot be NaN");
		}
		var oldValue:Float = this._maxVisibleWidth;
		this._maxVisibleWidth = value;
		if(this._explicitVisibleWidth != this._explicitVisibleWidth && //isNaN
			(this._actualVisibleWidth > value || this._actualVisibleWidth == oldValue))
		{
			//only invalidate if this change might affect the visibleWidth
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
	}
	
	private var _actualVisibleWidth:Float = 0;
	
	private var _explicitVisibleWidth:Float;
	
	public var visibleWidth(get, set):Float;
	private function get_visibleWidth():Float
	{
		if(this._explicitVisibleWidth != this._explicitVisibleWidth) //isNaN
		{
			return this._actualVisibleWidth;
		}
		return this._explicitVisibleWidth;
	}
	
	private function set_visibleWidth(value:Float):Float
	{
		if(this._explicitVisibleWidth == value ||
			(value != value && this._explicitVisibleWidth != this._explicitVisibleWidth)) //isNaN
		{
			return;
		}
		this._explicitVisibleWidth = value;
		if(this._actualVisibleWidth != value)
		{
			this._actualVisibleWidth = value;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
	}
	
	private var _actualMinVisibleHeight:Float = 0;
	
	private var _explicitMinVisibleHeight:Float;
	
	public var minVisibleHeight(get, set):Float;
	private function get_minVisibleWidth():Float
	{
		if(this._explicitMinVisibleHeight != this._explicitMinVisibleHeight) //isNaN
		{
			return this._actualMinVisibleHeight;
		}
		return this._explicitMinVisibleHeight;
	}
	
	private function set_minVisibleHeight(value:Float):Float
	{
		if (this._explicitMinVisibleHeight == value)
		{
			return;
		}
		var valueIsNaN:Bool = value != value; //isNaN
		if(valueIsNaN &&
			this._explicitMinVisibleHeight != this._explicitMinVisibleHeight) //isNaN
		{
			return;
		}
		var oldValue:Float = this._explicitMinVisibleHeight;
		this._explicitMinVisibleHeight = value;
		if(valueIsNaN)
		{
			this._actualMinVisibleHeight = 0;
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		else
		{
			this._actualMinVisibleHeight = value;
			if(this._explicitVisibleHeight !== this._explicitVisibleHeight && //isNaN
				(this._actualVisibleHeight < value || this._actualVisibleHeight == oldValue))
			{
				//only invalidate if this change might affect the visibleHeight
				this.invalidate(INVALIDATION_FLAG_SIZE);
			}
		}
	}
	
	public var maxVisibleHeight(get, set):Float;
	private var _maxVisibleHeight:Float = Math.POSITIVE_INFINITY;
	private function get_maxVisibleHeight():Float { return this._maxVisibleHeight; } 
	private function set_maxVisibleHeight(value:Float):Float
	{
		if(this._maxVisibleHeight == value)
		{
			return;
		}
		if(value != value) //isNaN
		{
			throw new ArgumentError("maxVisibleHeight cannot be NaN");
		}
		var oldValue:Float = this._maxVisibleHeight;
		this._maxVisibleHeight = value;
		if(this._explicitVisibleHeight != this._explicitVisibleHeight && //isNaN
			(this._actualVisibleHeight > value || this._actualVisibleHeight == oldValue))
		{
			//only invalidate if this change might affect the visibleHeight
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
	}
	
	private var _actualVisibleHeight:Float = 0;
	
	private var _explicitVisibleHeight:Float;
	
	public var visibleHeight(get, set):Float;
	private function get_visibleHeight():Float
	{
		if(this._explicitVisibleHeight != this._explicitVisibleHeight) //isNaN
		{
			return this._actualVisibleHeight;
		}
		return this._explicitVisibleHeight;
	}
	
	private function set_visibleHeight(value:Float):Float
	{
		if(this._explicitVisibleHeight == value ||
			(value != value && this._explicitVisibleHeight != this._explicitVisibleHeight)) //isNaN
		{
			return;
		}
		this._explicitVisibleHeight = value;
		if(this._actualVisibleHeight != value)
		{
			this._actualVisibleHeight = value;
			this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		}
	}
	
	public var contentX(get, never):Float;
	private function get_contentX():Float { return 0; }
	
	public var contentY(get, never):Float;
	private function get_contentY():Float { return 0; }
	
	/**
	 * @private
	 */
	private var _scrollStep:Int = 0;
	
	public var horizontalScrollStep(get, never):Float;
	private function get_horizontalScrollStep():Float { return this._scrollStep; }
	
	public var verticalScrollStep(get, never):Float;
	private function get_verticalScrollStep():Float { return this._scrollStep; }
	
	public var verticalScrollPosition(get, set):Float;
	private var _verticalScrollPosition:Float = 0;
	private function get_verticalScrollPosition():Float { return this._verticalScrollPosition; }
	private function set_verticalScrollPosition(value:Float):Float
	{
		if(this._verticalScrollPosition == value)
		{
			return;
		}
		this._verticalScrollPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SCROLL);
		//hack because the superclass doesn't know about the scroll flag
		this.invalidate(FeathersControl.INVALIDATION_FLAG_SIZE);
		return this._verticalScrollPosition;
	}
	
	public var requiresMeasurementOnScroll(get, never):Bool;
	private function get_requiresMeasurementOnScroll():Bool { return false; }
	
	override function get_baseline():Float
	{
		return super.baseline + this._paddingTop + this._verticalScrollPosition;
	}
	
	/**
	 * Quickly sets all padding properties to the same value. The
	 * <code>padding</code> getter always returns the value of
	 * <code>paddingTop</code>, but the other padding values may be
	 * different.
	 *
	 * @default 0
	 *
	 * @see #paddingTop
	 * @see #paddingRight
	 * @see #paddingBottom
	 * @see #paddingLeft
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
	 * The minimum space, in pixels, between the view port's top edge and
	 * the view port's content.
	 *
	 * @default 0
	 */
	public var paddingTop(get, set):Float;
	private var _paddingTop:Float = 0;
	private function get_paddingTop():Float { return this._paddingTop; }
	private function set_paddingTop(value:Float):Float
	{
		if(this._paddingTop == value)
		{
			return;
		}
		this._paddingTop = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingTop;
	}
	
	/**
	 * The minimum space, in pixels, between the view port's right edge and
	 * the view port's content.
	 *
	 * @default 0
	 */
	public var paddingRight(get, set):Float;
	private var _paddingRight:Float = 0;
	private function get_paddingRight():Float { return this._paddingRight; }
	private function set_paddingRight(value:Float):Float
	{
		if(this._paddingRight == value)
		{
			return;
		}
		this._paddingRight = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingRight;
	}
	
	/**
	 * The minimum space, in pixels, between the view port's bottom edge and
	 * the view port's content.
	 *
	 * @default 0
	 */
	public var paddingBottom(get, set):Float;
	private var _paddingBottom:Float = 0;
	private function get_paddingBottom():Float { return this._paddingBottom; }
	private function set_paddingBottom(value:Float):Float
	{
		if(this._paddingBottom == value)
		{
			return;
		}
		this._paddingBottom = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._paddingBottom;
	}
	
	/**
	 * The minimum space, in pixels, between the view port's left edge and
	 * the view port's content.
	 *
	 * @default 0
	 */
	public var paddingLeft(get, set):Float;
	private var _paddingLeft:Float = 0;
	private function get_paddingLeft():Float { return this._paddingLeft; }
	private function set_paddingLeft(value:Float):Float
	{
		if(this._paddingLeft == value)
		{
			return;
		}
		this._paddingLeft = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	override public function setFocus(position:Point = null):Void 
	{
		if (position != null)
		{
			position.x -= this._paddingLeft;
			position.y -= this._paddingTop;
		}
		super.setFocus(position);
	}
	
	/**
	 * @private
	 */
	override function autoSizeIfNeeded():Bool 
	{
		var result:Bool = super.autoSizeIfNeeded();
		var needsWidth:Bool = this._explicitVisibleWidth != this._explicitVisibleWidth; //isNaN
		var needsHeight:Bool = this._explicitVisibleHeight != this._explicitVisibleHeight; //isNaN
		var needsMinWidth:Bool = this._explicitMinVisibleWidth != this._explicitMinVisibleWidth; //isNaN
		var needsMinHeight:Bool = this._explicitMinVisibleHeight != this._explicitMinVisibleHeight; //isNaN
		if(!needsWidth && !needsHeight && !needsMinWidth && !needsMinHeight)
		{
			return result;
		}
		if(needsWidth)
		{
			this._actualVisibleWidth = this.actualWidth;
		}
		if(needsHeight)
		{
			this._actualVisibleHeight = this.actualHeight;
		}
		if(needsMinWidth)
		{
			this._actualMinVisibleWidth = this.actualMinWidth;
		}
		if(needsMinHeight)
		{
			this._actualMinVisibleHeight = this.actualMinHeight;
		}
		return result;
	}
	
	/**
	 * @private
	 */
	override function measure(result:Point = null):Point 
	{
		if (result == null)
		{
			result = new Point();
		}
		
		var needsWidth:Bool = this._explicitVisibleWidth != this._explicitVisibleWidth; //isNaN
		
		this.commitStylesAndData(this.measureTextField);
		
		var gutterDimensionsOffset:Float = 4;
		if (this._useGutter)
		{
			gutterDimensionsOffset = 0;
		}
		
		var newWidth:Float = this._explicitVisibleWidth;
		this.measureTextField.width = newWidth - this._paddingLeft - this._paddingRight + gutterDimensionsOffset;
		if (needsWidth)
		{
			//this.measureTextField.wordWrap = false;
			newWidth = this.measureTextField.width + this._paddingLeft + this._paddingRight - gutterDimensionsOffset;
			if(this._explicitMinVisibleWidth == this._explicitMinVisibleWidth && //!isNaN
				newWidth < this._explicitMinVisibleWidth)
			{
				newWidth = this._explicitMinVisibleWidth;
			}
			else if(newWidth > this._maxVisibleWidth)
			{
				newWidth = this._maxVisibleWidth;
			}
		}
		//this.measureTextField.width = newWidth - this._paddingLeft - this._paddingRight + gutterDimensionsOffset;
		//this.measureTextField.wordWrap = true;
		var newHeight:Float = this.measureTextField.height + this._paddingTop + this._paddingBottom - gutterDimensionsOffset;
		if(this._useGutter)
		{
			newHeight += 4;
		}
		if(this._explicitVisibleHeight == this._explicitVisibleHeight) //!isNaN
		{
			if(newHeight < this._explicitVisibleHeight)
			{
				newHeight = this._explicitVisibleHeight;
			}
		}
		else if(this._explicitMinVisibleHeight == this._explicitMinVisibleHeight) //!isNaN
		{
			if(newHeight < this._explicitMinVisibleHeight)
			{
				newHeight = this._explicitMinVisibleHeight;
			}
		}
		
		result.x = newWidth;
		result.y = newHeight;
		
		return result;
	}
	
	/**
	 * @private
	 */
	override function refreshSnapshotParameters():Void 
	{
		var textFieldWidth:Float = this._actualVisibleWidth - this._paddingLeft - this._paddingRight;
		if (textFieldWidth != textFieldWidth) //isNaN
		{
			if(this._maxVisibleWidth < Math.POSITIVE_INFINITY)
			{
				textFieldWidth = this._maxVisibleWidth - this._paddingLeft - this._paddingRight;
			}
			else
			{
				textFieldWidth = this._actualMinVisibleWidth - this._paddingLeft - this._paddingRight;
			}
		}
		var textFieldHeight:Float = this._actualVisibleHeight - this._paddingTop - this._paddingBottom;
		if (textFieldHeight != textFieldHeight) //isNaN
		{
			if(this._maxVisibleHeight < Math.POSITIVE_INFINITY)
			{
				textFieldHeight = this._maxVisibleHeight - this._paddingTop - this._paddingBottom;
			}
			else
			{
				textFieldHeight = this._actualMinVisibleHeight - this._paddingTop - this._paddingBottom;
			}
		}
		
		this._textFieldOffsetX = 0;
		this._textFieldOffsetY = 0;
		this._textFieldSnapshotClipRect.x = 0;
		this._textFieldSnapshotClipRect.y = 0;
		
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var scaleFactor:Float = starling.contentScaleFactor;
		var clipWidth:Float = textFieldWidth * scaleFactor;
		if (this._updateSnapshotOnScaleChange)
		{
			var matrix:Matrix = Pool.getMatrix();
			this.getTransformationMatrix(this.stage, matrix);
			clipWidth *= matrixToScaleX(matrix);
		}
		if (clipWidth < 0)
		{
			clipWidth = 0;
		}
		var clipHeight:Float = textFieldHeight * scaleFactor;
		if (this._updateSnapshotOnScaleChange)
		{
			clipHeight *= matrixToScaleY(matrix);
			Pool.putMatrix(matrix);
		}
		if (clipHeight < 0)
		{
			clipHeight = 0;
		}
		this._textFieldSnapshotClipRect.width = clipWidth;
		this._textFieldSnapshotClipRect.height = clipHeight;
	}
	
	/**
	 * @private
	 */
	override function refreshTextFieldSize():Void 
	{
		var oldIgnoreScrolling:Bool = this._ignoreScrolling;
		var gutterDimensionsOffset:Float = 4;
		if (this._useGutter)
		{
			gutterDimensionsOffset = 0;
		}
		this._ignoreScrolling = true;
		this.textField.width = this._actualVisibleWidth - this._paddingLeft - this._paddingRight + gutterDimensionsOffset;
		var textFieldHeight:Float = this._actualVisibleHeight - this._paddingTop - this._paddingBottom + gutterDimensionsOffset;
		if (this.textField.height != textFieldHeight)
		{
			this.textField.height = textFieldHeight;
		}
		var scroller:Scroller = cast this.parent;
		this.textField.scrollV = Math.round(1 + ((this.textField.maxScrollV - 1) * (this._verticalScrollPosition / scroller.maxVerticalScrollPosition)));
		this._ignoreScrolling = oldIgnoreScrolling;
	}
	
	/**
	 * @private
	 */
	override function commitStylesAndData(textField:TextField):Void
	{
		super.commitStylesAndData(textField);
		if (textField == this.textField)
		{
			this._scrollStep = textField.getLineMetrics(0).height;
		}
	}
	
	/**
	 * @private
	 */
	override function transformTextField():Void
	{
		var starling:Starling = this.stage != null ? this.stage.starling : Starling.current;
		var nativeScaleFactor:Float = 1;
		if (starling.supportHighResolutions)
		{
			nativeScaleFactor = starling.nativeStage.contentsScaleFactor;
		}
		var scaleFactor:Float = starling.contentScaleFactor / nativeScaleFactor;
		var matrix:Matrix = Pool.getMatrix();
		var point:Point = Pool.getPoint();
		this.getTransformationMatrix(this.stage, matrix);
		MatrixUtil.transformCoords(matrix, 0, 0, point);
		var scaleX:Float = matrixToScaleX(matrix) * scaleFactor;
		var scaleY:Float = matrixToScaleY(matrix) * scaleFactor;
		var offsetX:Float = Math.round(this._paddingLeft * scaleX);
		var offsetY:Float = Math.round((this._paddingTop + this._verticalScrollPosition) * scaleY);
		var starlingViewPort:Rectangle = starling.viewPort;
		var gutterPositionOffset:Float = 2;
		if (this._useGutter)
		{
			gutterPositionOffset = 0;
		}
		this.textField.x = offsetX + Math.round(starlingViewPort.x + (point.x * scaleFactor) - gutterPositionOffset * scaleX);
		this.textField.y = offsetY + Math.round(starlingViewPort.y + (point.y * scaleFactor) - gutterPositionOffset * scaleY);
		this.textField.rotation = matrixToRotation(matrix) * 180 / Math.PI;
		this.textField.scaleX = scaleX;
		this.textField.scaleY = scaleY;
		Pool.putPoint(point);
		Pool.putMatrix(matrix);
	}
	
	/**
	 * @private
	 */
	override function positionSnapshot():Void
	{
		if (!this.textSnapshot)
		{
			return;
		}
		var matrix:Matrix = Pool.getMatrix();
		this.getTransformationMatrix(this.stage, matrix);
		this.textSnapshot.x = this._paddingLeft + Math.round(matrix.tx) - matrix.tx;
		this.textSnapshot.y = this._paddingTop + this._verticalScrollPosition + Math.round(matrix.ty) - matrix.ty;
		Pool.putMatrix(matrix);
	}
	
	/**
	 * @private
	 */
	override function checkIfNewSnapshotIsNeeded():Void
	{
		super.checkIfNewSnapshotIsNeeded();
		this._needsNewTexture = this._needsNewTexture || this.isInvalid(INVALIDATION_FLAG_SCROLL);
	}
	
	/**
	 * @private
	 */
	override function textField_focusInHandler(event:FocusEvent):Void
	{
		this.textField.addEventListener(Event.SCROLL, textField_scrollHandler);
		super.textField_focusInHandler(event);
		this.invalidate(INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	override function textField_focusOutHandler(event:FocusEvent):Void
	{
		this.textField.removeEventListener(Event.SCROLL, textField_scrollHandler);
		super.textField_focusOutHandler(event);
		this.invalidate(INVALIDATION_FLAG_SIZE);
	}
	
	/**
	 * @private
	 */
	private function textField_scrollHandler(event:Event):Void
	{
		//for some reason, the text field's scroll positions don't work
		//properly unless we access the values here. weird.
		var scrollH:Float = this.textField.scrollH;
		var scrollV:Float = this.textField.scrollV;
		if (this._ignoreScrolling)
		{
			return;
		}
		var scroller:Scroller = Scroller(this.parent);
		if (scroller.maxVerticalScrollPosition > 0 && this.textField.maxScrollV > 1)
		{
			var calculatedVerticalScrollPosition:Float = scroller.maxVerticalScrollPosition * (scrollV - 1) / (this.textField.maxScrollV - 1);
			scroller.verticalScrollPosition = MathUtils.roundToNearest(calculatedVerticalScrollPosition, this._scrollStep);
		}
	}
	
}