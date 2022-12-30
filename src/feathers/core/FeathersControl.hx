/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.core;

import feathers.controls.text.BitmapFontTextRenderer;
import feathers.controls.text.TextFieldTextEditor;
import feathers.events.FeathersEventType;
import feathers.layout.ILayoutData;
import feathers.layout.ILayoutDisplayObject;
import feathers.motion.effectClasses.IEffectContext;
import feathers.motion.effectClasses.IMoveEffectContext;
import feathers.motion.effectClasses.IResizeEffectContext;
import feathers.skins.IStyleProvider;
import feathers.utils.display.DisplayUtils;
import feathers.utils.math.MathUtils;
import haxe.Constraints.Function;
import openfl.errors.ArgumentError;
import openfl.errors.Error;
import openfl.errors.IllegalOperationError;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import feathers.core.IFeathersControl;
import starling.display.DisplayObject;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.utils.MathUtil;
import starling.utils.MatrixUtil;
import starling.utils.Pool;

/**
 * Base class for all UI controls. Implements invalidation and sets up some
 * basic template functions like <code>initialize()</code> and
 * <code>draw()</code>.
 *
 * <p>This is a base class for Feathers components that isn't meant to be
 * instantiated directly. It should only be subclassed. For a simple
 * component that will automatically size itself based on its children,
 * and with optional support for layouts, see <code>LayoutGroup</code>.</p>
 *
 * @see feathers.controls.LayoutGroup
 *
 * @productversion Feathers 1.0.0
 */
abstract class FeathersControl extends Sprite implements IFeathersControl implements ILayoutDisplayObject
{
	private static var HELPER_POINT:Point = new Point();
	
	/**
	 * Flag to indicate that everything is invalid and should be redrawn.
	 */
	public static inline var INVALIDATION_FLAG_ALL:String = "all";
	
	/**
	 * Invalidation flag to indicate that the state has changed. Used by
	 * <code>isEnabled</code>, but may be used for other control states too.
	 *
	 * @see #isEnabled
	 */
	public static inline var INVALIDATION_FLAG_STATE:String = "state";
	
	/**
	 * Invalidation flag to indicate that the dimensions of the UI control
	 * have changed.
	 */
	public static inline var INVALIDATION_FLAG_SIZE:String = "size";
	
	/**
	 * Invalidation flag to indicate that the styles or visual appearance of
	 * the UI control has changed.
	 */
	public static inline var INVALIDATION_FLAG_STYLES:String = "styles";
	
	/**
	 * Invalidation flag to indicate that the skin of the UI control has changed.
	 */
	public static inline var INVALIDATION_FLAG_SKIN:String = "skin";
	
	/**
	 * Invalidation flag to indicate that the layout of the UI control has
	 * changed.
	 */
	public static inline var INVALIDATION_FLAG_LAYOUT:String = "layout";
	
	/**
	 * Invalidation flag to indicate that the primary data displayed by the
	 * UI control has changed.
	 */
	public static inline var INVALIDATION_FLAG_DATA:String = "data";
	
	/**
	 * Invalidation flag to indicate that the scroll position of the UI
	 * control has changed.
	 */
	public static inline var INVALIDATION_FLAG_SCROLL:String = "scroll";
	
	/**
	 * Invalidation flag to indicate that the selection of the UI control
	 * has changed.
	 */
	public static inline var INVALIDATION_FLAG_SELECTED:String = "selected";
	
	/**
	 * Invalidation flag to indicate that the focus of the UI control has
	 * changed.
	 */
	public static inline var INVALIDATION_FLAG_FOCUS:String = "focus";
	
	private static inline var INVALIDATION_FLAG_TEXT_RENDERER:String = "textRenderer";
	private static inline var INVALIDATION_FLAG_TEXT_EDITOR:String = "textEditor";
	private static inline var ILLEGAL_WIDTH_ERROR:String = "A component's width cannot be NaN.";
	private static inline var ILLEGAL_HEIGHT_ERROR:String = "A component's height cannot be NaN.";
	private static inline var ABSTRACT_CLASS_ERROR:String = "FeathersControl is an abstract class. For a lightweight Feathers wrapper, use feathers.controls.LayoutGroup.";
	
	/**
	 * A function used by all UI controls that support text renderers to
	 * create an ITextRenderer instance. You may replace the default
	 * function with your own, if you prefer not to use the
	 * BitmapFontTextRenderer.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
	 * @see feathers.core.ITextRenderer
	 */
	public static var defaultTextRendererFactory:Void->ITextRenderer = function():ITextRenderer
	{
		return new BitmapFontTextRenderer();
	};
	
	/**
	 * A function used by all UI controls that support text editor to
	 * create an <code>ITextEditor</code> instance. You may replace the
	 * default function with your own, if you prefer not to use the
	 * <code>StageTextTextEditor</code>.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function():ITextEditor</pre>
	 *
	 * @see ../../../help/text-editors.html Introduction to Feathers text editors
	 * @see feathers.core.ITextEditor
	 */
	public static var defaultTextEditorFactory:Void->ITextEditor = function():ITextEditor
	{
		return new TextFieldTextEditor();
	};
	
	/**
	   Constructor
	**/
	public function new() 
	{
		super();
		
		this.styleProvider = this.defaultStyleProvider;
		this.addEventListener(Event.ADDED_TO_STAGE, feathersControl_addedToStageHandler);
		this.addEventListener(Event.REMOVED_FROM_STAGE, feathersControl_removedFromStageHandler);
		if (Std.isOfType(this, IFocusDisplayObject))
		{
			this.addEventListener(FeathersEventType.FOCUS_IN, focusInHandler);
			this.removeEventListener(FeathersEventType.FOCUS_OUT, focusOutHandler);
		}
	}
	
	/**
	   @private
	**/
	private var _showEffectContext:IEffectContext = null;
	
	/**
	 * An optional effect that is activated when the component is shown.
	 * More specifically, this effect plays when the <code>visible</code>
	 * property is set to <code>true</code>.
	 *
	 * <p>In the following example, a show effect fades the component's
	 * <code>alpha</code> property from <code>0</code> to <code>1</code>:</p>
	 *
	 * <listing version="3.0">
	 * control.showEffect = Fade.createFadeBetweenEffect(0, 1);</listing>
	 *
	 * <p>A number of animated effects may be found in the
	 * <a href="../motion/package-detail.html">feathers.motion</a> package.
	 * However, you are not limited to only these effects. It's possible
	 * to create custom effects too.</p>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IEffectContext</pre>
	 *
	 * <p>The <code>IEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it.</p>
	 *
	 * <p>Custom animated effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenEffectContext</code>. In the following example, we
	 * recreate the <code>Fade.createFadeBetweenEffect()</code> used in the
	 * previous example.</p>
	 *
	 * <listing version="3.0">
	 * control.showEffect = function(target:DisplayObject):IEffectContext
	 * {
	 *     target.alpha = 0;
	 *     var tween:Tween = new Tween(target, 0.5, Transitions.EASE_OUT);
	 *     tween.fadeTo(1);
	 *     return new TweenEffectContext(target, tween);
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #visible
	 * @see #hideEffect
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public var showEffect(get, set):Function;
	private var _showEffect:Function = null;
	private function get_showEffect():Function { return this._showEffect; }
	private function set_showEffect(value:Function):Function
	{
		return this._showEffect = value;
	}
	
	private var _hideEffectContext:IEffectContext = null;
	
	/**
	 * An optional effect that is activated when the component is hidden.
	 * More specifically, this effect plays when the <code>visible</code>
	 * property is set to <code>false</code>.
	 *
	 * <p>In the following example, a hide effect fades the component's
	 * <code>alpha</code> property to <code>0</code>:</p>
	 *
	 * <listing version="3.0">
	 * control.hideEffect = Fade.createFadeOutEffect();</listing>
	 *
	 * <p>A number of animated effects may be found in the
	 * <a href="../motion/package-detail.html">feathers.motion</a> package.
	 * However, you are not limited to only these effects. It's possible
	 * to create custom effects too.</p>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IEffectContext</pre>
	 *
	 * <p>The <code>IEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it.</p>
	 *
	 * <p>Custom animated effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenEffectContext</code>. In the following example, we
	 * recreate the <code>Fade.createFadeOutEffect()</code> used in the
	 * previous example.</p>
	 *
	 * <listing version="3.0">
	 * control.hideEffect = function(target:DisplayObject):IEffectContext
	 * {
	 *     var tween:Tween = new Tween(target, 0.5, Transitions.EASE_OUT);
	 *     tween.fadeTo(0);
	 *     return new TweenEffectContext(target, tween);
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #visible
	 * @see #showEffect
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public var hideEffect(get, set):Function;
	private var _hideEffect:Function = null;
	private function get_hideEffect():Function { return this._hideEffect; }
	private function set_hideEffect(value:Function):Function
	{
		return this._hideEffect = value;
	}
	
	/**
	   @private
	**/
	private var _pendingVisible:Bool = true;
	
	override function set_visible(value:Bool):Bool 
	{
		if (value == this._pendingVisible)
		{
			return;
		}
		this._pendingVisible = value;
		if (this._suspendEffectsCount == 0 && this._hideEffectContext != null)
		{
			this._hideEffectContext.interrupt();
			this._hideEffectContext = null;
		}
		if (this._suspendEffectsCount == 0 && this._showEffectContext != null)
		{
			this._showEffectContext.interrupt();
			this._showEffectContext = null;
		}
		if (this._pendingVisible)
		{
			super.visible = this._pendingVisible;
			if (this.isCreated && this._suspendEffectsCount == 0 && this._showEffect != null && this.stage != null)
			{
				this._showEffectContext = cast(this._showEffect(this));
				this._showEffectContext.addEventListener(Event.COMPLETE, showEffectContext_completeHandler);
				this._showEffectContext.play();
			}
		}
		else
		{
			if (!this.dispatchEvent || this._suspendEffectsCount > 0 || this._hideEffect == null || this.stage == null)
			{
				super.visible = this._pendingVisible;
			}
			else
			{
				this._hideEffectContext = cast(this._hideEffect(this));
				this._hideEffectContext.addEventListener(Event.COMPLETE, hideEffectContext_completeHandler);
				this._hideEffectContext.play();
			}
		}
	}
	
	/**
	   @private
	**/
	private var _focusInEffectContext:IEffectContext = null;
	
	/**
	 * An optional effect that is activated when the component receives
	 * focus.
	 *
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * <p>A number of animated effects may be found in the
	 * <a href="../motion/package-detail.html">feathers.motion</a> package.
	 * However, you are not limited to only these effects. It's possible
	 * to create custom effects too.</p>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IEffectContext</pre>
	 *
	 * <p>The <code>IEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it.</p>
	 *
	 * <p>Custom animated effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenEffectContext</code>.</p>
	 *
	 * @default null
	 *
	 * @see #focusOutEffect
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public var focusInEffect(get, set):Function;
	private var _focusInEffect:Function = null;
	private function get_focusInEffect():Function { return this._focusInEffect; }
	private function set_focusInEffect(value:Function):Function
	{
		return this._focusInEffect = value;
	}
	
	/**
	   @private
	**/
	private var _focusOutEffectContext:IEffectContext = null;
	
	/**
	 * An optional effect that is activated when the component loses focus.
	 *
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * <p>A number of animated effects may be found in the
	 * <a href="../motion/package-detail.html">feathers.motion</a> package.
	 * However, you are not limited to only these effects. It's possible
	 * to create custom effects too.</p>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IEffectContext</pre>
	 *
	 * <p>The <code>IEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it.</p>
	 *
	 * <p>Custom animated effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenEffectContext</code>.</p>
	 *
	 * @default null
	 *
	 * @see #focusInEffect
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public var focusOutEffect(get, set):Function;
	private var _focusOutEffect:Function = null;
	private function get_focusOutEffect():Function { return this._focusOutEffect; }
	private function set_focusOutEffect(value:Function):Function
	{
		return this._focusOutEffect = value;
	}
	
	/**
	   @private
	**/
	private var _addedEffectContext:IEffectContext = null;
	
	/**
	 * An optional effect that is activated when the component is added to
	 * the stage. Typically used to animate the component's appearance when
	 * it is first displayed.
	 *
	 * <p>In the following example, an added effect fades the component's
	 * <code>alpha</code> property from <code>0</code> to <code>1</code>:</p>
	 *
	 * <listing version="3.0">
	 * control.addedEffect = Fade.createFadeBetweenEffect(0, 1);</listing>
	 *
	 * <p>A number of animated effects may be found in the
	 * <a href="../motion/package-detail.html">feathers.motion</a> package.
	 * However, you are not limited to only these effects. It's possible
	 * to create custom effects too.</p>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IEffectContext</pre>
	 *
	 * <p>The <code>IEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it.</p>
	 *
	 * <p>Custom animated effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenEffectContext</code>. In the following example, we
	 * recreate the <code>Fade.createFadeBetweenEffect()</code> used in the
	 * previous example.</p>
	 *
	 * <listing version="3.0">
	 * control.addedEffect = function(target:DisplayObject):IEffectContext
	 * {
	 *     target.alpha = 0;
	 *     var tween:Tween = new Tween(target, 0.5, Transitions.EASE_OUT);
	 *     tween.fadeTo(1);
	 *     return new TweenEffectContext(target, tween);
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see #removeFromParentWithEffect()
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public var addedEffect(get, set):Function;
	private var _addedEffect:Function = null;
	private function get_addedEffect():Function { return this._addedEffect; }
	private function set_addedEffect(value:Function):Function
	{
		return this._addedEffect = value;
	}
	
	/**
	   @private
	**/
	private var _removedEffectContext:IEffectContext = null;
	
	/**
	   @private
	**/
	private var _disposeAfterRemovedEffect:Bool = false;
	
	/**
	   @private
	**/
	private var _validationQueue:ValidationQueue;
	
	/**
	 * The concatenated <code>styleNameList</code>, with values separated
	 * by spaces. Style names are somewhat similar to classes in CSS
	 * selectors. In Feathers, they are a non-unique identifier that can
	 * differentiate multiple styles of the same type of UI control. A
	 * single control may have many style names, and many controls can share
	 * a single style name. A <a target="_top" href="../../../help/themes.html">theme</a>
	 * or another skinning mechanism may use style names to provide a
	 * variety of visual appearances for a single component class.
	 *
	 * <p>In general, the <code>styleName</code> property should not be set
	 * directly on a Feathers component. You should add and remove style
	 * names from the <code>styleNameList</code> property instead.</p>
	 *
	 * @default ""
	 *
	 * @see #styleNameList
	 * @see ../../../help/themes.html Introduction the Feathers themes
	 * @see ../../../help/custom-themes.html Creating custom Feathers themes
	 */
	public var styleName(get, set):String;
	private function get_styleName():String { return this._styleNameList.value; }
	private function set_styleName(value:String):String
	{
		return this._styleNameList.value = value;
	}
	
	/**
	 * Contains a list of all "styles" assigned to this control. Names are
	 * like classes in CSS selectors. They are a non-unique identifier that
	 * can differentiate multiple styles of the same type of UI control. A
	 * single control may have many names, and many controls can share a
	 * single name. A <a target="_top" href="../../../help/themes.html">theme</a>
	 * or another skinning mechanism may use style names to provide a
	 * variety of visual appearances for a single component class.
	 *
	 * <p>Names may be added, removed, or toggled on the
	 * <code>styleNameList</code>. Names cannot contain spaces.</p>
	 *
	 * <p>In the following example, a name is added to the name list:</p>
	 *
	 * <listing version="3.0">
	 * control.styleNameList.add( "custom-component-name" );</listing>
	 *
	 * @see #styleName
	 * @see ../../../help/themes.html Introduction to Feathers themes
	 * @see ../../../help/custom-themes.html Creating custom Feathers themes
	 */
	public var styleNameList(get, never):TokenList;
	private var _styleNameList:TokenList = new TokenList();
	private function get_styleNameList():TokenList { return this._styleNameList; }
	
	public var styleProvider(get, set):IStyleProvider;
	private var _styleProvider:IStyleProvider;
	private function get_styleProvider():IStyleProvider { return this._styleProvider; }
	private function set_styleProvider(value:IStyleProvider):IStyleProvider
	{
		if (this._styleProvider == value)
		{
			return value;
		}
		if (this._applyingStyles)
		{
			throw new IllegalOperationError("Cannot change styleProvider while the current style provider is applying styles.");
		}
		if (this._styleProvider != null && Std.isOfType(this._styleProvider, EventDispatcher))
		{
			cast(this._styleProvider, EventDispatcher).removeEventListener(Event.CHANGE, styleProvider_changeHandler);
		}
		this._styleProvider = value;
		if (this._styleProvider != null)
		{
			if (this.isInitialized)
			{
				this._applyingStyles = true;
				this._styleProvider.applyStyles(this);
				this._applyingStyles = false;
			}
			if (Std.isOfType(this._styleProvider, EventDispatcher))
			{
				cast(this._styleProvider, EventDispatcher).addEventListener(Event.CHANGE, styleProvider_changeHandler);
			}
		}
		return this._styleProvider;
	}
	
	/**
	 * When the <code>FeathersControl</code> constructor is called, the
	 * <code>styleProvider</code> property is set to this value. May be
	 * <code>null</code>.
	 *
	 * <p>Typically, a subclass of <code>FeathersControl</code> will
	 * override this function to return its static <code>globalStyleProvider</code>
	 * value. For instance, <code>feathers.controls.Button</code> overrides
	 * this function, and its implementation looks like this:</p>
	 *
	 * <listing version="3.0">
	 * override protected function get defaultStyleProvider():IStyleProvider
	 * {
	 *     return Button.globalStyleProvider;
	 * }</listing>
	 *
	 * @see #styleProvider
	 */
	public var defaultStyleProvider(get, never):IStyleProvider;
	private function get_defaultStyleProvider():IStyleProvider { return null; }
	
	/**
	 * Similar to <code>mouseChildren</code> on the classic display list. If
	 * <code>true</code>, children cannot dispatch touch events, but hit
	 * tests will be much faster. Easier than overriding
	 * <code>hitTest()</code>.
	 *
	 * <p>In the following example, the quick hit area is enabled:</p>
	 *
	 * <listing version="3.0">
	 * control.isQuickHitAreaEnabled = true;</listing>
	 *
	 * @default false
	 */
	public var isQuickHitAreaEnabled(get, set):Bool;
	private var _isQuickHitAreaEnabled:Bool = false;
	private function get_isQuickHitAreaEnabled():Bool { return this._isQuickHitAreaEnabled; }
	private function set_isQuickHitAreaEnabled(value:Bool):Bool
	{
		return this._isQuickHitAreaEnabled = value;
	}
	
	/**
	   @private
	**/
	private var _hitArea:Rectangle = new Rectangle();
	
	/**
	   @private
	**/
	private var _isInitializing:Bool = false;
	
	/**
	 * Determines if the component has been initialized yet. The
	 * <code>initialize()</code> function is called one time only, when the
	 * Feathers UI control is added to the display list for the first time.
	 *
	 * <p>In the following example, we check if the component is initialized
	 * or not, and we listen for an event if it isn't:</p>
	 *
	 * <listing version="3.0">
	 * if( !control.isInitialized )
	 * {
	 *     control.addEventListener( FeathersEventType.INITIALIZE, initializeHandler );
	 * }</listing>
	 *
	 * @see #event:initialize
	 * @see #isCreated
	 */
	public var isInitialized(get, never):Bool;
	private var _isInitialized:Bool = false;
	private function get_isInitialized():Bool { return this._isInitialized; }
	
	/**
	   @private
	**/
	private var _applyingStyles:Bool = false;
	
	/**
	   @private
	**/
	private var _restrictedStyles:Map<Dynamic, Bool> = new Map<Dynamic, Bool>();
	
	/**
	 * @private
	 * A flag that indicates that everything is invalid. If true, no other
	 * flags will need to be tracked.
	 */
	private var _isAllInvalid:Bool = false;
	
	/**
	   @private
	**/
	private var _invalidationFlags:Map<String, Bool> = new Map<String, Bool>();
	
	/**
	   @private
	**/
	private var _delayedInvalidationFlags:Map<String, Bool> = new Map<String, Bool>();
	
	/**
	 * Indicates whether the control is interactive or not.
	 *
	 * <p>In the following example, the control is disabled:</p>
	 *
	 * <listing version="3.0">
	 * control.isEnabled = false;</listing>
	 *
	 * @default true
	 */
	public var isEnabled(get, set):Bool;
	private var _isEnabled:Bool = true;
	private function get_isEnabled():Bool { return _isEnabled; }
	private function set_isEnabled(value:Bool):Bool
	{
		if (this._isEnabled == value)
		{
			return value;
		}
		this._isEnabled = value;
		this.invalidate(INVALIDATION_FLAG_STATE);
		return this._isEnabled;
	}
	
	/**
	 * The width value explicitly set by passing a value to the
	 * <code>width</code> setter or to the <code>setSize()</code> method.
	 */
	public var explicitWidth(get, never):Float;
	private var _explicitWidth:Float = Math.NaN;
	private function get_explicitWidth():Float { return this._explicitWidth; }
	
	/**
	   @private
	**/
	private var _resizeEffectContext:IEffectContext = null;
	
	/**
	 * An optional effect that is activated when the component is resized
	 * with new dimensions. More specifically, this effect plays when the
	 * <code>width</code> or <code>height</code> property changes.
	 *
	 * <p>In the following example, a resize effect will animate the new
	 * dimensions of the component when it resizes:</p>
	 *
	 * <listing version="3.0">
	 * control.resizeEffect = Resize.createResizeEffect();</listing>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IResizeEffectContext</pre>
	 *
	 * <p>The <code>IResizeEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it. Custom animated resize effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenResizeEffectContext</code>.</p>
	 *
	 * @see feathers.motion.Resize
	 * @see #width
	 * @see #height
	 * @see #setSize()
	 */
	public var resizeEffect(get, set):Function;
	private var _resizeEffect:Function = null;
	private function get_resizeEffect():Function { return this._resizeEffect; }
	private function set_resizeEffect(value:Function):Function
	{
		return this._resizeEffect = value;
	}
	
	/**
	   @private
	**/
	private var _moveEffectContext:IEffectContext = null;
	
	/**
	 * An optional effect that is activated when the component is moved to
	 * a new position. More specifically, this effect plays when the
	 * <code>x</code> or <code>y</code> property changes.
	 *
	 * <p>In the following example, a move effect will animate the new
	 * position of the component when it moves:</p>
	 *
	 * <listing version="3.0">
	 * control.moveEffect = Move.createMoveEffect();</listing>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IMoveEffectContext</pre>
	 *
	 * <p>The <code>IMoveEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it. Custom animated move effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenMoveEffectContext</code>.</p>
	 *
	 * @default null
	 *
	 * @see feathers.motion.Move
	 * @see #x
	 * @see #y
	 * @see #move()
	 */
	public var moveEffect(get, set):Function;
	private var _moveEffect:Function = null;
	private function get_moveEffect():Function { return this._moveEffect; }
	private function set_moveEffect(value:Function):Function
	{
		return this._moveEffect = value;
	}
	
	/**
	   @private
	**/
	override function set_x(value:Float):Float 
	{
		var newY:Float = this.y;
		if (this._suspendEffectsCount == 0 && this._moveEffectContext != null)
		{
			if (Std.isOfType(this._moveEffectContext, IMoveEffectContext))
			{
				var moveEffectContext:IMoveEffectContext = cast this._moveEffectContext;
				newY = moveEffectContext.newY;
			}
			this._moveEffectContext.interrupt();
			this._moveEffectContext = null;
		}
		if (this.isCreated && this._suspendEffectsCount == 0 && this._moveEffect != null)
		{
			this._moveEffectContext = cast this._moveEffect(this);
			this._moveEffectContext.addEventListener(Event.COMPLETE, moveEffectContext_completeHandler);
			if (Std.isOfType(this._moveEffectContext, IMoveEffectContext))
			{
				moveEffectContext = cast this._moveEffectContext;
				moveEffectContext.oldX = this.x;
				moveEffectContext.oldY = this.y;
				moveEffectContext.newX = value;
				moveEffectContext.newY = newY;
			}
			else
			{
				super.x = value;
			}
			this._moveEffectContext.play();
		}
		else
		{
			super.x = value;
		}
		return value;
	}
	
	/**
	   @private
	**/
	override function set_y(value:Float):Float
	{
		var newX:Float = this.x;
		if (this._suspendEffectsCount == 0 && this._moveEffectContext != null)
		{
			if (Std.isOfType(this._moveEffectContext, IMoveEffectContext))
			{
				var moveEffectContext:IMoveEffectContext = cast this._moveEffectContext;
				newX = moveEffectContext.newX;
			}
			this._moveEffectContext.interrupt();
			this._moveEffectContext = null;
		}
		if (this.isCreated && this._suspendEffectsCount == 0 && this._moveEffect != null)
		{
			this._moveEffectContext = cast this._moveEffect(this);
			this._moveEffectContext.addEventListener(Event.COMPLETE, moveEffectContext_completeHandler);
			if (Std.isOfType(this._moveEffectContext, IMoveEffectContext))
			{
				moveEffectContext = cast this._moveEffectContext;
				moveEffectContext.oldX = this.x;
				moveEffectContext.oldY = this.y;
				moveEffectContext.newX = newX;
				moveEffectContext.newY = value;
			}
			else
			{
				super.y = value;
			}
			this._moveEffectContext.play();
		}
		else
		{
			super.y = value;
		}
		return value;
	}
	
	/**
	 * The final width value that should be used for layout. If the width
	 * has been explicitly set, then that value is used. If not, the actual
	 * width will be calculated automatically. Each component has different
	 * automatic sizing behavior, but it's usually based on the component's
	 * skin or content, including text or subcomponents.
	 */
	private var actualWidth:Float = 0;
	
	/**
	 * @private
	 * The <code>actualWidth</code> value that accounts for
	 * <code>scaleX</code>. Not intended to be used for layout since layout
	 * uses unscaled values. This is the value exposed externally through
	 * the <code>width</code> getter.
	 */
	private var scaledActualWidth:Float = 0;
	
	/**
	 * The width of the component, in pixels. This could be a value that was
	 * set explicitly, or the component will automatically resize if no
	 * explicit width value is provided. Each component has a different
	 * automatic sizing behavior, but it's usually based on the component's
	 * skin or content, including text or subcomponents.
	 *
	 * <p><strong>Note:</strong> Values of the <code>width</code> and
	 * <code>height</code> properties may not be accurate until after
	 * validation. If you are seeing <code>width</code> or <code>height</code>
	 * values of <code>0</code>, but you can see something on the screen and
	 * know that the value should be larger, it may be because you asked for
	 * the dimensions before the component had validated. Call
	 * <code>validate()</code> to tell the component to immediately redraw
	 * and calculate an accurate values for the dimensions.</p>
	 *
	 * <p>In the following example, the width is set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * control.width = 120;</listing>
	 *
	 * <p>In the following example, the width is cleared so that the
	 * component can automatically measure its own width:</p>
	 *
	 * <listing version="3.0">
	 * control.width = NaN;</listing>
	 *
	 * @see feathers.core.FeathersControl#setSize()
	 * @see feathers.core.FeathersControl#validate()
	 */
	override function get_width():Float 
	{
		return this.scaledActualWidth;
	}
	
	/**
	   @private
	**/
	override function set_width(value:Float):Float 
	{
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitWidth != this._explicitWidth) //isNaN
		{
			return value;
		}
		if (this.scaleX != 1)
		{
			value /= this.scaleX;
		}
		if (this._explicitWidth == value)
		{
			return;
		}
		var hasSetExplicitWidth:Bool = false;
		var newHeight:Float = this.actualHeight;
		if (this._suspendEffectsCount == 0 && this._resizeEffectContext != null)
		{
			if (Std.isOfType(this._resizeEffectContext, IResizeEffectContext))
			{
				var resizeEffectContext:IResizeEffectContext = cast this._resizeEffectContext;
				newHeight = resizeEffectContext.newHeight;
			}
			this._resizeEffectContext.interrupt();
			this._resizeEffectContext = null;
		}
		if (!valueIsNaN && this.isCreated && this._suspendEffectsCount == 0 && this._resizeEffect != null)
		{
			this._resizeEffectContext = cast this._resizeEffect(this);
			this._resizeEffectContext.addEventListener(Event.COMPLETE, resizeEffectContext_completeHandler);
			if (Std.isOfType(this._resizeEffectContext, IResizeEffectContext))
			{
				resizeEffectContext = cast this._resizeEffectContext;
				resizeEffectContext.oldWidth = this.actualWidth;
				resizeEffectContext.oldHeight = this.actualHeight;
				resizeEffectContext.newWidth = value;
				resizeEffectContext.newHeight = newHeight;
			}
			else
			{
				this._explicitWidth = value;
				hasSetExplicitWidth = true;
			}
			this._resizeEffectContext.play();
		}
		else
		{
			this._explicitWidth = value;
			hasSetExplicitWidth = true;
		}
		if (hasSetExplicitWidth)
		{
			if (valueIsNaN)
			{
				this.actualWidth = this.scaledActualWidth = 0;
				this.invalidate(INVALIDATION_FLAG_SIZE);
			}
			else
			{
				var result:Bool = this.saveMeasurements(value, this.actualHeight, this.actualMinWidth, this.actualMinHeight);
				if (result)
				{
					this.invalidate(INVALIDATION_FLAG_SIZE);
				}
			}
		}
	}
	
	/**
	 * The height value explicitly set by passing a value to the
	 * <code>height</code> setter or by calling the <code>setSize()</code>
	 * function.
	 */
	public var explicitHeight(get, never):Float;
	private var _explicitHeight:Float = Math.NaN;
	private function get_explicitHeight():Float { return this._explicitHeight; }
	
	/**
	 * The final height value that should be used for layout. If the height
	 * has been explicitly set, then that value is used. If not, the actual
	 * height will be calculated automatically. Each component has different
	 * automatic sizing behavior, but it's usually based on the component's
	 * skin or content, including text or subcomponents.
	 */
	private var actualHeight:Float = 0;
	
	/**
	 * @private
	 * The <code>actualHeight</code> value that accounts for
	 * <code>scaleY</code>. Not intended to be used for layout since layout
	 * uses unscaled values. This is the value exposed externally through
	 * the <code>height</code> getter.
	 */
	private var scaledActualHeight:Float = 0;
	
	/**
	 * The height of the component, in pixels. This could be a value that
	 * was set explicitly, or the component will automatically resize if no
	 * explicit height value is provided. Each component has a different
	 * automatic sizing behavior, but it's usually based on the component's
	 * skin or content, including text or subcomponents.
	 *
	 * <p><strong>Note:</strong> Values of the <code>width</code> and
	 * <code>height</code> properties may not be accurate until after
	 * validation. If you are seeing <code>width</code> or <code>height</code>
	 * values of <code>0</code>, but you can see something on the screen and
	 * know that the value should be larger, it may be because you asked for
	 * the dimensions before the component had validated. Call
	 * <code>validate()</code> to tell the component to immediately redraw
	 * and calculate an accurate values for the dimensions.</p>
	 *
	 * <p>In the following example, the height is set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * control.height = 120;</listing>
	 *
	 * <p>In the following example, the height is cleared so that the
	 * component can automatically measure its own height:</p>
	 *
	 * <listing version="3.0">
	 * control.height = NaN;</listing>
	 *
	 * @see feathers.core.FeathersControl#setSize()
	 * @see feathers.core.FeathersControl#validate()
	 */
	override function get_height():Float 
	{
		return this.scaledActualHeight;
	}
	
	/**
	   @private
	**/
	override function set_height(value:Float):Float 
	{
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitHeight != this._explicitHeight) //isNaN
		{
			return value;
		}
		if (this.scaleY != 1)
		{
			value /= this.scaleY;
		}
		if (this._explicitHeight == value)
		{
			return;
		}
		var hasSetExplicitHeight:Bool = false;
		var newWidth:Float = this.actualWidth;
		if (this._suspendEffectsCount == 0 && this._resizeEffectContext != null)
		{
			if (Std.isOfType(this._resizeEffectContext, IResizeEffectContext))
			{
				var resizeEffectContext:IResizeEffectContext = cast this._resizeEffectContext;
				newWidth = resizeEffectContext.newWidth;
			}
			this._resizeEffectContext.interrupt();
			this._resizeEffectContext = null;
		}
		if (!valueIsNaN && this.isCreated && this._suspendEffectsCount == 0 && this._resizeEffect != null)
		{
			this._resizeEffectContext = cast this._resizeEffect(this);
			this._resizeEffectContext.addEventListener(Event.COMPLETE, resizeEffectContext_completeHandler);
			if (Std.isOfType(this._resizeEffectContext, IResizeEffectContext))
			{
				resizeEffectContext = cast this._resizeEffectContext;
				resizeEffectContext.oldWidth = this.actualWidth;
				resizeEffectContext.oldHeight = this.actualHeight;
				resizeEffectContext.newWidth = newWidth;
				resizeEffectContext.newHeight = value;
			}
			else
			{
				this._explicitHeight = value;
				hasSetExplicitHeight = true;
			}
			this._resizeEffectContext.play();
		}
		else
		{
			this._explicitHeight = value;
			hasSetExplicitHeight = true;
		}
		if (hasSetExplicitHeight)
		{
			if (valueIsNaN)
			{
				this.actualHeight = this.scaledActualHeight = 0;
				this.invalidate(INVALIDATION_FLAG_SIZE);
			}
			else
			{
				var result:Bool = this.saveMeasurements(this.actualWidth, value, this.actualMinWidth, this.actualMinHeight);
				if (result)
				{
					this.invalidate(INVALIDATION_FLAG_SIZE);
				}
			}
		}
	}
	
	/**
	 * If using <code>isQuickHitAreaEnabled</code>, and the hit area's
	 * width is smaller than this value, it will be expanded.
	 *
	 * <p>In the following example, the minimum width of the hit area is
	 * set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * control.minTouchWidth = 120;</listing>
	 *
	 * @default 0
	 */
	public var minTouchWidth(get, set):Float;
	private var _minTouchWidth:Float = 0;
	private function get_minTouchWidth():Float { return this._minTouchWidth; }
	private function set_minTouchWidth(value:Float):Float
	{
		if (this._minTouchWidth == value)
		{
			return value;
		}
		this._minTouchWidth = value;
		this.refreshHitAreaX();
		return this._minTouchWidth;
	}
	
	/**
	 * If using <code>isQuickHitAreaEnabled</code>, and the hit area's
	 * height is smaller than this value, it will be expanded.
	 *
	 * <p>In the following example, the minimum height of the hit area is
	 * set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * control.minTouchHeight = 120;</listing>
	 *
	 * @default 0
	 */
	public var minTouchHeight(get, set):Float;
	private var _minTouchHeight:Float = 0;
	private function get_minTouchHeight():Float { return this._minTouchHeight; }
	private function set_minTouchHeight(value:Float):Float
	{
		if (this._minTouchHeight == value)
		{
			return value;
		}
		this._minTouchHeight = value;
		this.refreshHitAreaY();
	}
	
	/**
	 * The minimum width value explicitly set by passing a value to the
	 * <code>minWidth</code> setter.
	 *
	 * <p>If no value has been passed to the <code>minWidth</code> setter,
	 * this property returns <code>NaN</code>.</p>
	 */
	public var explicitMinWidth(get, never):Float;
	private var _explicitMinWidth:Float = Math.NaN;
	private function get_explicitMinWidth():Float { return this._explicitMinWidth; }
	
	/**
	 * The final minimum width value that should be used for layout. If the
	 * minimum width has been explicitly set, then that value is used. If
	 * not, the actual minimum width will be calculated automatically. Each
	 * component has different automatic sizing behavior, but it's usually
	 * based on the component's skin or content, including text or
	 * subcomponents.
	 */
	private var actualMinWidth:Float = 0;
	
	/**
	 * @private
	 * The <code>actualMinWidth</code> value that accounts for
	 * <code>scaleX</code>. Not intended to be used for layout since layout
	 * uses unscaled values. This is the value exposed externally through
	 * the <code>minWidth</code> getter.
	 */
	private var scaledActualMinWidth:Float = 0;
	
	/**
	 * The minimum recommended width to be used for self-measurement and,
	 * optionally, by any code that is resizing this component. This value
	 * is not strictly enforced in all cases. An explicit width value that
	 * is smaller than <code>minWidth</code> may be set and will not be
	 * affected by the minimum.
	 *
	 * <p>In the following example, the minimum width of the control is
	 * set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * control.minWidth = 120;</listing>
	 *
	 * @default 0
	 */
	public var minWidth(get, set):Float;
	private function get_minWidth():Float { return this.scaledActualMinWidth; }
	private function set_minWidth(value:Float):Float
	{
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitMinWidth != this._explicitMinWidth) //isNaN
		{
			return value;
		}
		if (this.scaleX != 1)
		{
			value /= this.scaleX;
		}
		if (this._explicitMinWidth == value)
		{
			return value;
		}
		var oldValue:Float = this._explicitMinWidth;
		this._explicitMinWidth = value;
		if (valueIsNaN)
		{
			this.actualMinWidth = this.scaledActualMinWidth = 0;
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		else
		{
			//saveMeasurements() might change actualWidth, so keep the old
			//value for the comparisons below
			var actualWidth:Float = this.actualWidth;
			this.saveMeasurements(actualWidth, this.actualHeight, value, this.actualMinHeight);
			if (this._explicitWidth != this._explicitWidth && //isNaN
				(actualWidth < value || actualWidth == oldValue))
			{
				//only invalidate if this change might affect the width
				//because everything else was handled in saveMeasurements()
				this.invalidate(INVALIDATION_FLAG_SIZE);
			}
		}
		return value;
	}
	
	/**
	 * The minimum height value explicitly set by passing a value to the
	 * <code>minHeight</code> setter.
	 *
	 * <p>If no value has been passed to the <code>minHeight</code> setter,
	 * this property returns <code>NaN</code>.</p>
	 */
	public var explicitMinHeight(get, never):Float;
	private var _explicitMinHeight:Float = Math.NaN;
	private function get_explicitMinHeight():Float { return this._explicitMinHeight; }
	
	/**
	 * The final minimum height value that should be used for layout. If the
	 * minimum height has been explicitly set, then that value is used. If
	 * not, the actual minimum height will be calculated automatically. Each
	 * component has different automatic sizing behavior, but it's usually
	 * based on the component's skin or content, including text or
	 * subcomponents.
	 */
	private var actualMinHeight:Float = 0;
	
	/**
	 * @private
	 * The <code>actuaMinHeight</code> value that accounts for
	 * <code>scaleY</code>. Not intended to be used for layout since layout
	 * uses unscaled values. This is the value exposed externally through
	 * the <code>minHeight</code> getter.
	 */
	private var scaledActualMinHeight:Float = 0;
	
	/**
	 * The minimum recommended height to be used for self-measurement and,
	 * optionally, by any code that is resizing this component. This value
	 * is not strictly enforced in all cases. An explicit height value that
	 * is smaller than <code>minHeight</code> may be set and will not be
	 * affected by the minimum.
	 *
	 * <p>In the following example, the minimum height of the control is
	 * set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * control.minHeight = 120;</listing>
	 *
	 * @default 0
	 */
	public var minHeight(get, set):Float;
	private function get_minHeight():Float { return this.scaledActualMinHeight; }
	private function set_minHeight(value:Float):Float
	{
		var valueIsNaN:Bool = value != value; //isNaN
		if (valueIsNaN &&
			this._explicitMinHeight != this._explicitMinHeight) //isNaN
		{
			return value;
		}
		if (this.scaleY != 1)
		{
			value /= this.scaleY;
		}
		if (this._explicitMinHeight == value)
		{
			return value;
		}
		var oldValue:Float = this._explicitMinHeight;
		this._explicitMinHeight = value;
		if (valueIsNaN)
		{
			this.actualMinHeight = this.scaledActualMinHeight = 0;
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		else
		{
			//saveMeasurements() might change actualHeight, so keep the old
			//value for the comparisons below
			var actualHeight:Float = this.actualHeight;
			this.saveMeasurements(this.actualWidth, actualHeight, this.actualMinWidth, value);
			if (this._explicitHeight != this._explicitHeight && //isNaN
				(actualHeight < value || actualHeight == oldValue))
			{
				//only invalidate if this change might affect the height
				//because everything else was handled in saveMeasurements()
				this.invalidate(INVALIDATION_FLAG_SIZE);
			}
		}
	}
	
	/**
	 * The maximum width value explicitly set by passing a value to the
	 * <code>maxWidth</code> setter.
	 *
	 * <p>If no value has been passed to the <code>maxWidth</code> setter,
	 * this property returns <code>NaN</code>.</p>
	 */
	public var explicitMaxWidth(get, never):Float;
	private var _explicitMaxWidth:Float = Math.POSITIVE_INFINITY;
	private function get_explicitMaxWidth():Float { return this._explicitMaxWidth; }
	
	/**
	 * The maximum recommended width to be used for self-measurement and,
	 * optionally, by any code that is resizing this component. This value
	 * is not strictly enforced in all cases. An explicit width value that
	 * is larger than <code>maxWidth</code> may be set and will not be
	 * affected by the maximum.
	 *
	 * <p>In the following example, the maximum width of the control is
	 * set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * control.maxWidth = 120;</listing>
	 *
	 * @default Number.POSITIVE_INFINITY
	 */
	public var maxWidth(get, set):Float;
	private function get_maxWidth():Float { return this._explicitMaxWidth; }
	private function set_maxWidth(value:Float):Float
	{
		if (value < 0)
		{
			value = 0;
		}
		if (this._explicitMaxWidth == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			throw new ArgumentError("maxWidth cannot be NaN");
		}
		var oldValue:Float = this._explicitMaxWidth;
		this._explicitMaxWidth = value;
		if (this._explicitWidth != this._explicitWidth && //isNaN
			(this.actualWidth > value || this.actualWidth == oldValue))
		{
			//only invalidate if this change might affect the width
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		return this._explicitMaxWidth;
	}
	
	/**
	 * The maximum height value explicitly set by passing a value to the
	 * <code>maxHeight</code> setter.
	 *
	 * <p>If no value has been passed to the <code>maxHeight</code> setter,
	 * this property returns <code>NaN</code>.</p>
	 */
	public var explicitMaxHeight(get, never):Float;
	private var _explicitMaxHeight:Float = Math.POSITIVE_INFINITY;
	private function get_explicitMaxHeight():Float
	{
		return this._explicitMaxHeight;
	}
	
	/**
	 * The maximum recommended height to be used for self-measurement and,
	 * optionally, by any code that is resizing this component. This value
	 * is not strictly enforced in all cases. An explicit height value that
	 * is larger than <code>maxHeight</code> may be set and will not be
	 * affected by the maximum.
	 *
	 * <p>In the following example, the maximum width of the control is
	 * set to 120 pixels:</p>
	 *
	 * <listing version="3.0">
	 * control.maxWidth = 120;</listing>
	 *
	 * @default Number.POSITIVE_INFINITY
	 */
	public var maxHeight(get, set):Float;
	private function get_maxHeight():Float { return this._explicitMaxHeight; }
	private function set_maxHeight(value:Float):Float
	{
		if (value < 0)
		{
			value = 0;
		}
		if (this._explicitMaxHeight == value)
		{
			return value;
		}
		if (value != value) //isNaN
		{
			throw new ArgumentError("maxHeight cannot be NaN");
		}
		var oldValue:Float = this._explicitMaxHeight;
		this._explicitMaxHeight = value;
		if (this._explicitHeight != this._explicitHeight && //isNaN
			(this.actualHeight > value || this.actualHeight == oldValue))
		{
			//only invalidate if this change might affect the width
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		return this._explicitMaxHeight;
	}
	
	/**
	   @private
	**/
	override function set_scaleX(value:Float):Float 
	{
		super.set_scaleX(value);
		this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight);
		return value;
	}
	
	/**
	   @private
	**/
	override function set_scaleY(value:Float):Float 
	{
		super.set_scaleY(value);
		this.saveMeasurements(this.actualWidth, this.actualHeight, this.actualMinWidth, this.actualMinHeight);
		return value;
	}
	
	/**
	 * @inheritDoc
	 *
	 * @default true
	 */
	public var includeInLayout(get, set):Bool;
	private var _includeInLayout:Bool = true;
	private function get_includeInLayout():Bool { return this._includeInLayout; }
	private function set_includeInLayout(value:Bool):Bool
	{
		if (this._includeInLayout == value)
		{
			return value;
		}
		this._includeInLayout = value;
		this.dispatchEventWith(FeathersEventType.LAYOUT_DATA_CHANGE);
		return this._includeInLayout;
	}
	
	/**
	 * @inheritDoc
	 *
	 * @default null
	 */
	public var layoutData(get, set):ILayoutData;
	private var _layoutData:ILayoutData;
	private function get_layoutData():ILayoutData { return this._layoutData; }
	private function set_layoutData(value:ILayoutData):ILayoutData
	{
		if (this._layoutData == value)
		{
			return value;
		}
		if (this._layoutData != null)
		{
			this._layoutData.removeEventListener(Event.CHANGE, layoutData_changeHandler);
		}
		this._layoutData = value;
		if (this._layoutData != null)
		{
			this._layoutData.addEventListener(Event.CHANGE, layoutData_changeHandler);
		}
		this.dispatchEventWith(FeathersEventType.LAYOUT_DATA_CHANGE);
		return this._layoutData;
	}
	
	/**
	 * Text to display in a tool tip to when hovering over this component,
	 * if the <code>ToolTipManager</code> is enabled.
	 *
	 * @default null
	 *
	 * @see ../../../help/tool-tips.html Tool tips in Feathers
	 * @see feathers.core.ToolTipManager
	 */
	public var toolTip(get, set):String;
	private var _toolTip:String;
	private function get_toolTip():String { return this._toolTip; }
	private function set_toolTip(value:String):String
	{
		return this._toolTip = value;
	}
	
	/**
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#focusManager
	 *
	 * @default null
	 *
	 * @see feathers.core.IFocusDisplayObject
	 */
	public var focusManager(get, set):IFocusManager;
	private var _focusManager:IFocusManager;
	private function get_focusManager():IFocusManager { return this._focusManager; }
	private function set_focusManager(value:IFocusManager):IFocusManager
	{
		if (!Std.isOfType(this, IFocusDisplayObject))
		{
			throw new IllegalOperationError("Cannot pass a focus manager to a component that does not implement feathers.core.IFocusDisplayObject");
		}
		if (this._focusManager == value)
		{
			return value;
		}
		this._focusManager = value;
	}
	
	/**
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#focusOwner
	 *
	 * @default null
	 *
	 * @see feathers.core.IFocusDisplayObject
	 */
	public var focusOwner(get, set):IFocusDisplayObject;
	private var _focusOwner:IFocusDisplayObject;
	private function get_focusOwner():IFocusDisplayObject { return this._focusOwner; }
	private function set_focusOwner(value:IFocusDisplayObject):IFocusDisplayObject
	{
		return this._focusOwner = value;
	}
	
	/**
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#isFocusEnabled
	 *
	 * @default true
	 *
	 * @see feathers.core.IFocusDisplayObject
	 */
	public var isFocusEnabled(get, set):Bool;
	private var _isFocusEnabled:Bool = true;
	private function get_isFocusEnabled():Bool { return this._isFocusEnabled; }
	private function set_isFocusEnabled(value:Bool):Bool
	{
		if (!Std.isOfType(this, IFocusDisplayObject))
		{
			throw new IllegalOperationError("Cannot enable focus on a component that does not implement feathers.core.IFocusDisplayObject");
		}
		if (this._isFocusEnabled == value)
		{
			return value;
		}
		return this._isFocusEnabled = value;
	}
	
	/**
	 * <p>The implementation of this method is provided for convenience, but
	 * it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#isShowingFocus
	 *
	 * @see feathers.core.IFocusDisplayObject#showFocus()
	 * @see feathers.core.IFocusDisplayObject#hideFocus()
	 * @see feathers.core.IFocusDisplayObject
	 */
	public var isShowingFocus(get, never):Bool;
	private function get_isShowingFocus():Bool { return this._showFocus; }
	
	/**
	 * <p>The implementation of this method is provided for convenience, but
	 * it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#maintainTouchFocus
	 *
	 * @see feathers.core.IFocusDisplayObject
	 */
	public var maintainTouchFocus(get, never):Bool;
	private function get_maintainTouchFocus():Bool { return false; }
	
	/**
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#nextTabFocus
	 *
	 * @default null
	 *
	 * @see feathers.core.IFocusDisplayObject
	 */
	public var nextTabFocus(get, set):IFocusDisplayObject;
	private var _nextTabFocus:IFocusDisplayObject = null;
	private function get_nextTabFocus():IFocusDisplayObject { return this._nextTabFocus; }
	private function set_nextTabFocus(value:IFocusDisplayObject):IFocusDisplayObject
	{
		if (!Std.isOfType(this, IFocusDisplayObject))
		{
			throw new IllegalOperationError("Cannot set nextTabFocus on a component that does not implement feathers.core.IFocusDisplayObject");
		}
		return this._nextTabFocus = value;
	}
	
	/**
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#previousTabFocus
	 *
	 * @default null
	 *
	 * @see feathers.core.IFocusDisplayObject
	 */
	public var previousTabFocus(get, set):IFocusDisplayObject;
	private var _previousTabFocus:IFocusDisplayObject = null;
	private function get_previousTabFocus():IFocusDisplayObject { return this._previousTabFocus; }
	private function set_previousTabFocus(value:IFocusDisplayObject):IFocusDisplayObject
	{
		if (!Std.isOfType(this, IFocusDisplayObject))
		{
			throw new IllegalOperationError("Cannot set previousTabFocus on a component that does not implement feathers.core.IFocusDisplayObject");
		}
		return this._previousTabFocus = value;
	}
	
	/**
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#nextUpFocus
	 *
	 * @default null
	 *
	 * @see feathers.core.IFocusDisplayObject
	 *
	 * @productversion Feathers 3.4.0
	 */
	public var nextUpFocus(get, set):IFocusDisplayObject;
	private var _nextUpFocus:IFocusDisplayObject = null;
	private function get_nextUpFocus():IFocusDisplayObject { return this._nextUpFocus; }
	private function set_nextUpFocus(value:IFocusDisplayObject):IFocusDisplayObject
	{
		if (!Std.isOfType(this, IFocusDisplayObject))
		{
			throw new IllegalOperationError("Cannot set nextUpFocus on a component that does not implement feathers.core.IFocusDisplayObject");
		}
		return this._nextUpFocus = value;
	}
	
	/**
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#nextRightFocus
	 *
	 * @default null
	 *
	 * @see feathers.core.IFocusDisplayObject
	 *
	 * @productversion Feathers 3.4.0
	 */
	public var nextRightFocus(get, set):IFocusDisplayObject;
	private var _nextRightFocus:IFocusDisplayObject = null;
	private function get_nextRightFocus():IFocusDisplayObject { return this._nextRightFocus; }
	private function set_nextRightFocus(value:IFocusDisplayObject):IFocusDisplayObject
	{
		if (!Std.isOfType(this, IFocusDisplayObject))
		{
			throw new IllegalOperationError("Cannot set nextRightFocus on a component that does not implement feathers.core.IFocusDisplayObject");
		}
		return this._nextRightFocus = value;
	}
	
	/**
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#nextDownFocus
	 *
	 * @default null
	 *
	 * @see feathers.core.IFocusDisplayObject
	 *
	 * @productversion Feathers 3.4.0
	 */
	public var nextDownFocus(get, set):IFocusDisplayObject;
	private var _nextDownFocus:IFocusDisplayObject = null;
	private function get_nextDownFocus():IFocusDisplayObject { return this._nextDownFocus; }
	private function set_nextDownFocus(value:IFocusDisplayObject):IFocusDisplayObject
	{
		if (!Std.isOfType(this, IFocusDisplayObject))
		{
			throw new IllegalOperationError("Cannot set nextDownFocus on a component that does not implement feathers.core.IFocusDisplayObject");
		}
		return this._nextDownFocus = value;
	}
	
	/**
	 * <p>The implementation of this property is provided for convenience,
	 * but it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#nextLeftFocus
	 *
	 * @default null
	 *
	 * @see feathers.core.IFocusDisplayObject
	 *
	 * @productversion Feathers 3.4.0
	 */
	public var nextLeftFocus(get, set):IFocusDisplayObject;
	private var _nextLeftFocus:IFocusDisplayObject = null;
	private function get_nextLeftFocus():IFocusDisplayObject { return this._nextLeftFocus; }
	private function set_nextLeftFocus(value:IFocusDisplayObject):IFocusDisplayObject
	{
		if (!Std.isOfType(this, IFocusDisplayObject))
		{
			throw new IllegalOperationError("Cannot set nextLeftFocus on a component that does not implement feathers.core.IFocusDisplayObject");
		}
		return this._nextLeftFocus = value;
	}
	
	/**
	   @private
	**/
	public var focusIndicatorSkin(get, set):DisplayObject;
	private var _focusIndicatorSkin:DisplayObject;
	private function get_focusIndicatorSkin():DisplayObject { return this._focusIndicatorSkin; }
	private function set_focusIndicatorSkin(value:DisplayObject):DisplayObject
	{
		if (!Std.isOfType(this, IFocusDisplayObject))
		{
			throw new IllegalOperationError("Cannot set focus indicator skin on a component that does not implement feathers.core.IFocusDisplayObject");
		}
		// TODO: translate this code to haxe
		//if (this.processStyleRestriction(arguments.callee))
		//{
			//return value;
		//}
		if (this._focusIndicatorSkin == value)
		{
			return value;
		}
		if (this._focusIndicatorSkin != null)
		{
			if (this._focusIndicatorSkin.parent == this)
			{
				this._focusIndicatorSkin.removeFromParent(false);
			}
			if (Std.isOfType(this._focusIndicatorSkin, IStateObserver) &&
				Std.isOfType(this, IStateContext))
			{
				cast(this._focusIndicatorSkin, IStateObserver).stateContext = null;
			}
		}
		this._focusIndicatorSkin = value;
		if (this._focusIndicatorSkin != null)
		{
			this._focusIndicatorSkin.touchable = false;
		}
		if (Std.isOfType(this._focusIndicatorSkin, IStateObserver) &&
			Std.isOfType(this, IStateContext))
		{
			cast(this._focusIndicatorSkin, IStateObserver).stateContext = cast this;
		}
		if (this._focusManager != null && this._focusManager.focus == this)
		{
			this.invalidate(INVALIDATION_FLAG_STYLES);
		}
		return this._focusIndicatorSkin;
	}
	
	/**
	   @private
	**/
	public var focusPadding(get, set):Float;
	private function get_focusPadding():Float { return this._focusPaddingTop; }
	private function set_focusPadding(value:Float):Float
	{
		this.focusPaddingTop = value;
		this.focusPaddingRight = value;
		this.focusPaddingBottom = value;
		this.focusPaddingLeft = value;
	}
	
	/**
	   @private
	**/
	public var focusPaddingTop(get, set):Float;
	private var _focusPaddingTop:Float = 0;
	private function get_focusPaddingTop():Float { return this._focusPaddingTop; }
	private function set_focusPaddingTop(value:Float):Float
	{
		// TODO: translate this code to haxe
		//if (this.processStyleRestriction(arguments.callee))
		//{
			//return value;
		//}
		if (this._focusPaddingTop == value)
		{
			return value;
		}
		this._focusPaddingTop = value;
		this.invalidate(INVALIDATION_FLAG_FOCUS);
		return this._focusPaddingTop;
	}
	
	/**
	   @private
	**/
	public var focusPaddingRight(get, set):Float;
	private var _focusPaddingRight:Float = 0;
	private function get_focusPaddingRight():Float { return this._focusPaddingRight; }
	private function set_focusPaddingRight(value:Float):Float
	{
		// TODO: translate this code to haxe
		//if (this.processStyleRestriction(arguments.callee))
		//{
			//return value;
		//}
		if (this._focusPaddingRight == value)
		{
			return value;
		}
		this._focusPaddingRight = value;
		this.invalidate(INVALIDATION_FLAG_FOCUS);
		return this._focusPaddingRight;
	}
	
	/**
	   @private
	**/
	public var focusPaddingBottom(get, set):Float;
	private var _focusPaddingBottom:Float = 0;
	private function get_focusPaddingBottom():Float { return this._focusPaddingBottom; }
	private function set_focusPaddingBottom(value:Float):Float
	{
		// TODO: translate this code to haxe
		//if (this.processStyleRestriction(arguments.callee))
		//{
			//return value;
		//}
		if (this._focusPaddingBottom == value)
		{
			return value;
		}
		this._focusPaddingBottom = value;
		this.invalidate(INVALIDATION_FLAG_FOCUS);
		return this._focusPaddingBottom;
	}
	
	/**
	   @private
	**/
	public var focusPaddingLeft(get, set):Float;
	private var _focusPaddingLeft:Float = 0;
	private function get_focusPaddingLeft():Float { return this._focusPaddingLeft; }
	private function set_focusPaddingLeft(value:Float):Float
	{
		// TODO: translate this code to haxe
		//if (this.processStyleRestriction(arguments.callee))
		//{
			//return value;
		//}
		if (this._focusPaddingLeft == value)
		{
			return value;
		}
		this._focusPaddingLeft = value;
		this.invalidate(INVALIDATION_FLAG_FOCUS);
		return this._focusPaddingLeft;
	}
	
	/**
	 * Indicates if effects have been suspended.
	 *
	 * @see #suspendEffects()
	 * @see #resumeEffects()
	 */
	public var effectsSuspended(get, never):Bool;
	private function get_effectsSuspended():Bool { return this._suspendedEffectsCount > 0; }
	
	/**
	   @private
	**/
	private var _hasFocus:Bool = false;
	
	/**
	   @private
	**/
	private var _showFocus:Bool = false;
	
	/**
	 * @private
	 * Flag to indicate that the control is currently validating.
	 */
	private var _isValidating:Bool = false;
	
	/**
	 * @private
	 * Flag to indicate that the control has validated at least once.
	 */
	private var _hasValidated:Bool = false;
	
	/**
	 * Determines if the component has been initialized and validated for
	 * the first time.
	 *
	 * <p>In the following example, we check if the component is created or
	 * not, and we listen for an event if it isn't:</p>
	 *
	 * <listing version="3.0">
	 * if( !control.isCreated )
	 * {
	 *     control.addEventListener( FeathersEventType.CREATION_COMPLETE, creationCompleteHandler );
	 * }</listing>
	 *
	 * @see #event:creationComplete
	 * @see #isInitialized
	 */
	public var isCreated(get, never):Bool;
	private function get_isCreated():Bool { return this._hasValidated; }
	
	/**
	 * @copy feathers.core.IValidating#depth
	 */
	public var depth(get, never):Int;
	private var _depth:Int = -1;
	private function get_depth():Int { return this._depth; }
	
	/**
	   @private
	**/
	private var _suspendEffectsCount:Int = 0;
	
	/**
	   @private
	**/
	private var _ignoreNextStyleRestriction:Bool = false;
	
	/**
	   @private
	**/
	private var _invalidateCount:Int = 0;
	
	/**
	 * Feathers components use an optimized <code>getBounds()</code>
	 * implementation that may sometimes behave differently than regular
	 * Starling display objects. For instance, filters may need some special
	 * customization. If a component's children appear outside of its
	 * bounds (such as at negative dimensions), padding should be added to
	 * the filter to account for these regions.
	 */
	override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null):Rectangle 
	{
		if (resultRect == null)
		{
			resultRect = new Rectangle();
		}
		
		var minX:Float = MathUtils.FLOAT_MIN;
		var maxX:Float = MathUtils.FLOAT_MAX;
		var minY:Float = MathUtils.FLOAT_MIN;
		var maxY:Float = MathUtils.FLOAT_MAX;
		
		if (targetSpace == this) //optimization
		{
			minX = 0;
			minY = 0;
			maxX = this.actualWidth;
			maxY = this.actualHeight;
		}
		else
		{
			var matrix:Matrix = Pool.getMatrix();
			this.getTransformationMatrix(targetSpace, matrix);
			
			MatrixUtil.transformCoords(matrix, 0, 0, HELPER_POINT);
			minX = minX < HELPER_POINT.x ? minX : HELPER_POINT.x;
			maxX = maxX > HELPER_POINT.x ? maxX : HELPER_POINT.x;
			minY = minY < HELPER_POINT.y ? minY : HELPER_POINT.y;
			maxY = maxY > HELPER_POINT.y ? maxY : HELPER_POINT.y;
			
			MatrixUtil.transformCoords(matrix, 0, this.actualHeight, HELPER_POINT);
			minX = minX < HELPER_POINT.x ? minX : HELPER_POINT.x;
			maxX = maxX > HELPER_POINT.x ? maxX : HELPER_POINT.x;
			minY = minY < HELPER_POINT.y ? minY : HELPER_POINT.y;
			maxY = maxY > HELPER_POINT.y ? maxY : HELPER_POINT.y;
			
			MatrixUtil.transformCoords(matrix, this.actualWidth, 0, HELPER_POINT);
			minX = minX < HELPER_POINT.x ? minX : HELPER_POINT.x;
			maxX = maxX > HELPER_POINT.x ? maxX : HELPER_POINT.x;
			minY = minY < HELPER_POINT.y ? minY : HELPER_POINT.y;
			maxY = maxY > HELPER_POINT.y ? maxY : HELPER_POINT.y;
			
			MatrixUtil.transformCoords(matrix, this.actualWidth, this.actualHeight, HELPER_POINT);
			minX = minX < HELPER_POINT.x ? minX : HELPER_POINT.x;
			maxX = maxX > HELPER_POINT.x ? maxX : HELPER_POINT.x;
			minY = minY < HELPER_POINT.y ? minY : HELPER_POINT.y;
			maxY = maxY > HELPER_POINT.y ? maxY : HELPER_POINT.y;
			
			Pool.putMatrix(matrix);
		}
		
		resultRect.x = minX;
		resultRect.y = minY;
		resultRect.width = maxX - minX;
		resultRect.height = maxY - minY;
		
		return resultRect;
	}
	
	/**
	   @private
	**/
	override public function hitTest(localPoint:Point):DisplayObject 
	{
		if (this._isQuickHitAreaEnabled)
		{
			if (!this.visible || !this.touchable)
			{
				return null;
			}
			if (this.mask != null && !this.hitTestMask(localPoint))
			{
				return null;
			}
			return this._hitArea.containsPoint(localPoint) ? this : null;
		}
		return super.hitTest(localPoint);
	}
	
	/**
	   @private
	**/
	private var _isDisposed:Bool = false;
	
	/**
	   @private
	**/
	override public function dispose():Void 
	{
		//we don't dispose it if this is the parent because it'll
		//already get disposed in super.dispose()
		if (this._focusIndicatorSkin != null && this._focusIndicatorSkin.parent != this)
		{
			this._focusIndicatorSkin.dispose();
		}
		this._isDisposed = true;
		this._validationQueue = null;
		this.layoutData = null;
		this._styleNameList.removeEventListeners();
		super.dispose();
	}
	
	/**
	 * Call this function to tell the UI control that a redraw is pending.
	 * The redraw will happen immediately before Starling renders the UI
	 * control to the screen. The validation system exists to ensure that
	 * multiple properties can be set together without redrawing multiple
	 * times in between each property change.
	 *
	 * <p>If you cannot wait until later for the validation to happen, you
	 * can call <code>validate()</code> to redraw immediately. As an example,
	 * you might want to validate immediately if you need to access the
	 * correct <code>width</code> or <code>height</code> values of the UI
	 * control, since these values are calculated during validation.</p>
	 *
	 * @see feathers.core.FeathersControl#validate()
	 */
	public function invalidate(flag:String = INVALIDATION_FLAG_ALL):Void
	{
		var isAlreadyInvalid:Bool = this.isInvalid();
		var isAlreadyDelayedInvalid:Bool = false;
		if (this._isValidating)
		{
			for (otherFlag in this._delayedInvalidationFlags)
			{
				isAlreadyDelayedInvalid = true;
				break;
			}
		}
		if (flag == null || flag == INVALIDATION_FLAG_ALL)
		{
			if (this._isValidating)
			{
				this._delayedInvalidationFlags[INVALIDATION_FLAG_ALL] = true;
			}
			else
			{
				this._isAllInvalid = true;
			}
		}
		else
		{
			if (this._isValidating)
			{
				this._delayedInvalidationFlags[flag] = true;
			}
			else if (flag != INVALIDATION_FLAG_ALL && !this._invalidationFlags.exists(flag))
			{
				this._invalidationFlags[flag] = true;
			}
		}
		if (this._validationQueue == null || !this._isInitialized)
		{
			//we'll add this component to the queue later, after it has been
			//added to the stage.
			return;
		}
		if (this._isValidating)
		{
			//if we've already incremented this counter this time, we can
			//return. we're already in queue.
			if(isAlreadyDelayedInvalid)
			{
				return;
			}
			this._invalidateCount++;
			//if invalidate() is called during validation, we'll be added
			//back to the end of the queue. we'll keep trying this a certain
			//number of times, but at some point, it needs to be considered
			//an infinite loop or a serious bug because it affects
			//performance.
			if (this._invalidateCount >= 10)
			{
				throw new Error(Type.getClassName(Type.getClass(this)) + " returned to validation queue too many times during validation. This may be an infinite loop. Try to avoid doing anything that calls invalidate() during validation.");
			}
			this._validationQueue.addControl(this);
			return;
		}
		if (isAlreadyInvalid)
		{
			return;
		}
		this._invalidateCount = 0;
		this._validationQueue.addControl(this);
	}
	
	/**
	 * @copy feathers.core.IValidating#validate()
	 *
	 * @see #invalidate()
	 */
	public function validate():Void
	{
		if (this._isDisposed)
		{
			//disposed components have no reason to validate, but they may
			//have been left in the queue.
			return;
		}
		if (!this._isInitialized)
		{
			if (this._isInitializing)
			{
				throw new IllegalOperationError("A component cannot validate until after it has finished initializing.");
			}
			this.initializeNow();
		}
		//if we're not actually invalid, there's nothing to do here, so
		//simply return.
		if(!this.isInvalid())
		{
			return;
		}
		if (this._isValidating)
		{
			//we were already validating, so there's nothing to do here.
			//the existing validation will continue.
			return;
		}
		this._isValidating = true;
		this.draw();
		this._invalidationFlags.clear();
		this._isAllInvalid = false;
		for (flag in this._delayedInvalidationFlags.keys()) // TODO : don't iterate on a Map's String keys ?
		{
			if (flag == INVALIDATION_FLAG_ALL)
			{
				this._isAllInvalid = true;
			}
			else
			{
				this._invalidationFlags[flag] = true;
			}
		}
		this._delayedInvalidationFlags.clear();
		this._isValidating = false;
		if (!this._hasValidated)
		{
			this._hasValidated = true;
			this.dispatchEventWith(FeathersEventType.CREATION_COMPLETE);
			
			if (this._suspendEffectsCount == 0 && this.stage != null && this._addedEffect != null)
			{
				this._addedEffectContext = cast this._adddEffect(this);
				this._addedEffectContext.addEventListener(Event.COMPLETE, addedEffectContext_completeHandler);
				this._addedEffectContext.play();
			}
		}
	}
	
	/**
	 * Indicates whether the control is pending validation or not. By
	 * default, returns <code>true</code> if any invalidation flag has been
	 * set. If you pass in a specific flag, returns <code>true</code> only
	 * if that flag has been set (others may be set too, but it checks the
	 * specific flag only. If all flags have been marked as invalid, always
	 * returns <code>true</code>.
	 */
	public function isInvalid(flag:String = null):Bool
	{
		if (this._isAllInvalid)
		{
			return true;
		}
		if (flag == null) //return true if any flag is set
		{
			for (flag in this._invalidationFlags)
			{
				return true;
			}
			return false;
		}
		return this._invalidationFlags[flag];
	}
	
	/**
	 * Sets both the width and the height of the control in a single
	 * function call.
	 *
	 * @see #width
	 * @see #height
	 */
	public function setSize(width:Float, height:Float):Void
	{
		var hasSetExplicitSize:Bool = false;
		if (this._suspendEffectsCount == 0 && this._resizeEffectContext != null)
		{
			this._resizeEffectContext.interrupt();
			this._resizeEffectContext = null;
		}
		var widthIsNaN:Bool = width != width; //isNaN
		var heightIsNaN:Bool = height != height; //isNaN
		if ((!widthIsNaN || !heightIsNaN) && this.isCreated && this._suspendEffectsCount == 0 && this._resizeEffect != null)
		{
			this._resizeEffectContext = cast this._resizeEffect(this);
			this._resizeEffectContext.addEventListener(Event.COMPLETE, resizeEffectContext_completeHandler);
			if (Std.isOfType(this._resizeEffectContext, IResizeEffectContext))
			{
				var resizeEffectContext:IResizeEffectContext = cast this._resizeEffectContext;
				resizeEffectContext.oldWidth = this.actualWidth;
				resizeEffectContext.oldHeight = this.actualHeight;
				if (widthIsNaN)
				{
					resizeEffectContext.newWidth = this.actualWidth;
				}
				else
				{
					resizeEffectContext.newWidth = width;
				}
				if (heightIsNaN)
				{
					resizeEffectContext.newHeight = this.actualHeight;
				}
				else
				{
					resizeEffectContext.newHeight = height;
				}
			}
			else
			{
				this._explicitWidth = width;
				this._explicitHeight = height;
				hasSetExplicitSize = true;
			}
			this._resizeEffectContext.play();
		}
		else
		{
			this._explicitWidth = width;
			this._explicitHeight = height;
			hasSetExplicitSize = true;
		}
		if (hasSetExplicitSize)
		{
			if (widthIsNaN)
			{
				this.actualWidth = this.scaledActualWidth = 0;
			}
			if (heightIsNaN)
			{
				this.actualHeight = this.scaledActualHeight = 0;
			}
			
			if (widthIsNaN || heightIsNaN)
			{
				this.invalidate(INVALIDATION_FLAG_SIZE);
			}
			else
			{
				var result:Bool = this.saveMeasurements(width, height, this.actualMinWidth, this.actualMinHeight);
				if (result)
				{
					this.invalidate(INVALIDATION_FLAG_SIZE);
				}
			}
		}
	}
	
	/**
	 * Sets both the x and the y positions of the control in a single
	 * function call.
	 *
	 * @see #x
	 * @see #y
	 */
	public function move(x:Float, y:Float):Void
	{
		if (this._suspendEffectsCount == 0 && this._moveEffectContext != null)
		{
			this._moveEffectContext.interrupt();
			this._moveEffectContext = null;
		}
		if (this.isCreated && this._suspendEffectsCount == 0 && this._moveEffect != null)
		{
			this._moveEffectContext = cast this._moveEffect(this);
			this._moveEffectContext.addEventListener(Event.COMPLETE, moveEffectContext_completeHandler);
			if (Std.isOfType(this._moveEffectContext, IMoveEffectContext))
			{
				var moveEffectContext:IMoveEffectContext = cast this._moveEffectContext;
				moveEffectContext.oldX = this.x;
				moveEffectContext.oldY = this.y;
				moveEffectContext.newX = x;
				moveEffectContext.newY = y;
			}
			else
			{
				super.x = x;
				super.y = y;
			}
			this._moveEffectContext.play();
		}
		else
		{
			super.x = x;
			super.y = y;
		}
	}
	
	/**
	 * Plays an effect before removing the component from its parent.
	 *
	 * <p>In the following example, an effect fades the component's
	 * <code>alpha</code> property to <code>0</code> before removing the
	 * component from its parent:</p>
	 *
	 * <listing version="3.0">
	 * control.removeFromParentWithEffect(Fade.createFadeOutEffect(), true);</listing>
	 *
	 * <p>A number of animated effects may be found in the
	 * <a href="../motion/package-detail.html">feathers.motion</a> package.
	 * However, you are not limited to only these effects. It's possible
	 * to create custom effects too.</p>
	 *
	 * <p>A custom effect function should have the following signature:</p>
	 * <pre>function(target:DisplayObject):IEffectContext</pre>
	 *
	 * <p>The <code>IEffectContext</code> is used by the component to
	 * control the effect, performing actions like playing the effect,
	 * pausing it, or cancelling it.</p>
	 *
	 * <p>Custom animated effects that use
	 * <code>starling.display.Tween</code> typically return a
	 * <code>TweenEffectContext</code>. In the following example, we
	 * recreate the <code>Fade.createFadeOutEffect()</code> used in the
	 * previous example.</p>
	 *
	 * <listing version="3.0">
	 * function customEffect(target:DisplayObject):IEffectContext
	 * {
	 *     var tween:Tween = new Tween(target, 0.5, Transitions.EASE_OUT);
	 *     tween.fadeTo(0);
	 *     return new TweenEffectContext(target, tween);
	 * }
	 * control.removeFromParentWithEffect(customEffect, true);</listing>
	 *
	 * @see #addedEffect
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public function removeFromParentWithEffect(effect:Function, dispose:Bool = false):Void
	{
		if (this.isCreated && this._suspendEffectsCount == 0)
		{
			this._disposeAfterRemovedEffect = dispose;
			this._removedEffectContext = cast effect(this);
			this._removedEffectContext.addEventListener(Event.COMPLETE, removedEffectContext_completeHandler);
			this._removedEffectContext.play();
		}
		else
		{
			this.removeFromParent(dispose);
		}
	}
	
	/**
	 * Resets the <code>styleProvider</code> property to its default value,
	 * which is usually the global style provider for the component.
	 *
	 * @see #styleProvider
	 * @see #defaultStyleProvider
	 */
	public function resetStyleProvider():Void
	{
		this.styleProvider = this.defaultStyleProvider;
	}
	
	/**
	 * Indicates that effects should not be activated temporarily. Call
	 * <code>resumeEffects()</code> when effects should be allowed again.
	 *
	 * @see #resumeEffects()
	 */
	public function suspendEffects():Void
	{
		this._suspendEffectsCount++;
	}
	
	/**
	 * Indicates that effects should be re-activated after being suspended.
	 *
	 * @see #suspendEffects()
	 */
	public function resumeEffects():Void
	{
		this._suspendEffectsCount--;
	}
	
	/**
	 * <p>The implementation of this method is provided for convenience, but
	 * it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#showFocus()
	 *
	 * @see feathers.core.IFocusDisplayObject
	 */
	public function showFocus():Void
	{
		if (!this._hasFocus || this._focusIndicatorSkin == null)
		{
			return;
		}
		
		this._showFocus = true;
		this.invalidate(INVALIDATION_FLAG_FOCUS);
	}
	
	/**
	 * <p>The implementation of this method is provided for convenience, but
	 * it cannot be used unless a subclass implements the
	 * <code>IFocusDisplayObject</code> interface.</p>
	 *
	 * @copy feathers.core.IFocusDisplayObject#hideFocus()
	 *
	 * @see feathers.core.IFocusDisplayObject
	 */
	public function hideFocus():Void
	{
		if (!this._hasFocus || this._focusIndicatorSkin == null)
		{
			return;
		}
		
		this._showFocus = false;
		this.invalidate(INVALIDATION_FLAG_FOCUS);
	}
	
	/**
	 * If the component has not yet initialized, initializes immediately.
	 * The <code>initialize()</code> function will be called, and the
	 * <code>FeathersEventType.INITIALIZE</code> event will be dispatched.
	 * Then, if the component has a style provider, it will be applied. The
	 * component will not validate, though. To initialize and validate
	 * immediately, call <code>validate()</code> instead.
	 *
	 * @see #isInitialized
	 * @see #initialize()
	 * @see #event:initialize FeathersEventType.INITIALIZE
	 * @see #styleProvider
	 * @see #validate()
	 */
	public function initializeNow():Void
	{
		if (this._isInitialized || this._isInitializing)
		{
			return;
		}
		this._isInitializing = true;
		this.initialize();
		this.invalidate(); //invalidate everything
		this._isInitializing = false;
		this._isInitialized = true;
		this.dispatchEventWith(FeathersEventType.INITIALIZE);
		
		if (this._styleProvider != null)
		{
			this._applyingStyles = true;
			this._styleProvider.applyStyles(this);
			this._applyingStyles = false;
		}
		this._styleNameList.addEventListener(Event.CHANGE, styleNameList_changeHandler);
	}
	
	/**
	 * Sets the width and height of the control, with the option of
	 * invalidating or not. Intended to be used when the <code>width</code>
	 * and <code>height</code> values have not been set explicitly, and the
	 * UI control needs to measure itself and choose an "ideal" size.
	 */
	private function setSizeInternal(width:Float, height:Float, canInvalidate:Bool):Bool
	{
		var changed:Bool = this.saveMeasurements(width, height, this.actualMinWidth, this.actualMinHeight);
		if (canInvalidate && changed)
		{
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		return changed;
	}
	
	/**
	 * Saves the dimensions and minimum dimensions calculated for the
	 * component. Returns true if the reported values have changed and
	 * <code>Event.RESIZE</code> was dispatched.
	 */
	private function saveMeasurements(width:Float, height:Float, minWidth:Float = 0, minHeight:Float = 0):Bool
	{
		if (this._explicitMinWidth == this._explicitMinWidth) //!isNaN
		{
			//the min width has been set explicitly. it has precedence over
			//the measured min width
			minWidth = this._explicitMinWidth;
		}
		else if (minWidth > this._explicitMaxWidth)
		{
			//similarly, if the max width has been set explicitly, it can
			//affect the measured min width (but not explicit min width)
			minWidth = this._explicitMaxWidth;
		}
		if (this._explicitMinHeight == this._explicitMinHeight) //!isNaN
		{
			//the min height has been set explicitly. it has precedence over
			//the measured min height
			minHeight = this._explicitMinHeight;
		}
		else if (minHeight > this._explicitMaxHeight)
		{
			//similarly, if the max height has been set explicitly, it can
			//affect the measured min height (but not explicit min height)
			minHeight = this._explicitMaxHeight;
		}
		if (this._explicitWidth == this._explicitWidth) //!isNaN
		{
			width = this._explicitWidth;
		}
		else
		{
			if (width < minWidth)
			{
				width = minWidth;
			}
			else if (width > this._explicitMaxWidth)
			{
				width = this._explicitMaxWidth;
			}
		}
		if (this._explicitHeight == this._explicitHeight) //!isNaN
		{
			height = this._explicitHeight;
		}
		else
		{
			if (height < minHeight)
			{
				height = minHeight;
			}
			else if (height > this._explicitMaxHeight)
			{
				height = this._explicitMaxHeight;
			}
		}
		if (width != width) //isNaN
		{
			throw new ArgumentError(ILLEGAL_WIDTH_ERROR);
		}
		if (height != height) //isNaN
		{
			throw new ArgumentError(ILLEGAL_HEIGHT_ERROR);
		}
		var scaleX:Float = this.scaleX;
		if (scaleX < 0)
		{
			scaleX = -scaleX;
		}
		var scaleY:Float = this.scaleY;
		if (scaleY < 0)
		{
			scaleY = -scaleY;
		}
		var resized:Bool = false;
		if (this.actualWidth != width)
		{
			this.actualWidth = width;
			this.refreshHitAreaX();
			resized = true;
		}
		if (this.actualHeight != height)
		{
			this.actualHeight = height;
			this.refreshHitAreaY();
			resized = true;
		}
		if (this.actualMinWidth != minWidth)
		{
			this.actualMinWidth = minWidth;
			resized = true;
		}
		if (this.actualMinHeight != minHeight)
		{
			this.actualMinHeight = minHeight;
			resized = true;
		}
		width = this.scaledActualWidth;
		height = this.scaledActualHeight;
		this.scaledActualWidth = this.actualWidth * scaleX;
		this.scaledActualHeight = this.actualHeight * scaleY;
		this.scaledActualMinWidth = this.actualMinWidth * scaleX;
		this.scaledActualMinHeight = this.actualMinHeight * scaleY;
		if (width != this.scaledActualWidth || height != this.scaledActualHeight)
		{
			resized = true;
			this.dispatchEventWith(Event.RESIZE);
		}
		return resized;
	}
	
	/**
	 * Called the first time that the UI control is added to the stage, and
	 * you should override this function to customize the initialization
	 * process. Do things like create children and set up event listeners.
	 * After this function is called, <code>FeathersEventType.INITIALIZE</code>
	 * is dispatched.
	 *
	 * @see #event:initialize feathers.events.FeathersEventType.INITIALIZE
	 */
	private function initialize():Void
	{
		
	}
	
	/**
	 * Override to customize layout and to adjust properties of children.
	 * Called when the component validates, if any flags have been marked
	 * to indicate that validation is pending.
	 */
	private function draw():Void
	{
		
	}
	
	/**
	 * Sets an invalidation flag. This will not add the component to the
	 * validation queue. It only sets the flag. A subclass might use
	 * this function during <code>draw()</code> to manipulate the flags that
	 * its superclass sees.
	 */
	private function setInvalidationFlag(flag:String):Void
	{
		if (this._invalidationFlags.exists(flag))
		{
			return;
		}
		this._invalidationFlags[flag] = true;
	}
	
	/**
	 * Clears an invalidation flag. This will not remove the component from
	 * the validation queue. It only clears the flag. A subclass might use
	 * this function during <code>draw()</code> to manipulate the flags that
	 * its superclass sees.
	 */
	private function clearInvalidationFlag(flag:String):Void
	{
		this._invalidationFlags.remove(flag);
	}
	
	/**
	 * Used by setters for properties that are considered "styles" to
	 * determine if the setter has been called directly on the component or
	 * from a <em>style provider</em>. A style provider is typically
	 * associated with a theme. When a style is set directly on the
	 * component (outside of a style provider), then any attempts by the
	 * style provider to set the style later will be ignored. This allows
	 * developers to customize a component's styles directly without
	 * worrying about conflicts from the style provider or theme.
	 *
	 * <p>If a style provider is currently applying styles to the component,
	 * returns <code>true</code> if the style is restricted or false if it
	 * may be set.</p>
	 *
	 * <p>If the style setter is called outside of a style provider, marks
	 * the style as restricted and returns <code>false</code>.</p>
	 *
	 * <p>The <code>key</code> parameter should be a unique value for each
	 * separate style. In most cases, <code>processStyleRestriction()</code>
	 * will be called in the style property setter, so
	 * <code>arguments.callee</code> is recommended. Alternatively, a unique
	 * string value may be used instead.</p>
	 *
	 * <p>The following example shows how to use
	 * <code>processStyleRestriction()</code> in a style property
	 * setter:</p>
	 *
	 * <listing version="3.0">
	 * private var _customStyle:Object;
	 * 
	 * public function get customStyle():Object
	 * {
	 *     return this._customStyle;
	 * }
	 * 
	 * public function set customStyle( value:Object ):void
	 * {
	 *     if( this.processStyleRestriction( arguments.callee ) )
	 *     {
	 *         // if a style is restricted, don't set it
	 *         return;
	 *     }
	 * 
	 *     this._customStyle = value;
	 * }</listing>
	 *
	 * @see #ignoreNextStyleRestriction()
	 */
	private function processStyleRestriction(key:Dynamic):Bool
	{
		var ignore:Bool = this._ignoreNextStyleRestriction;
		this._ignoreNextStyleRestriction = false;
		//in most cases, the style is not restricted, and we can set it
		if (this._applyingStyles)
		{
			return this._restrictedStyles != null && this._restrictedStyles.exists(key);
		}
		if (ignore)
		{
			return false;
		}
		if (this._restrictedStyles == null)
		{
			//only create the object if it is needed
			this._restrictedStyles = new Map<Dynamic, Bool>();
		}
		this._restrictedStyles[key] = true;
		return false;
	}
	
	/**
	 * The next style that is set will not be restricted. This allows
	 * components to set defaults by calling the setter while still allowing
	 * the style property to be replaced by a theme in the future.
	 *
	 * @see #processStyleRestriction()
	 */
	private function ignoreNextStyleRestriction():Void
	{
		this._ignoreNextStyleRestriction = true;
	}
	
	/**
	 * Updates the focus indicator skin by showing or hiding it and
	 * adjusting its position and dimensions. This function is not called
	 * automatically. Components that support focus should call this
	 * function at an appropriate point within the <code>draw()</code>
	 * function. This function may be overridden if the default behavior is
	 * not desired.
	 */
	private function refreshFocusIndicator():Void
	{
		if (this._focusIndicatorSkin != null)
		{
			if (this._hasFocus && this._showFocus)
			{
				if (this._focusIndicatorSkin.parent != this)
				{
					this.addChild(this._focusIndicatorSkin);
				}
				else
				{
					this.setChildIndex(this._focusIndicatorSkin, this.numChildren - 1);
				}
			}
			else if (this._focusIndicatorSkin.parent != null)
			{
				this._focusIndicatorSkin.removeFromParent(false);
			}
			this._focusIndicatorSkin.x = this._focusPaddingLeft;
			this._focusIndicatorSkin.y = this._focusPaddingTop;
			this._focusIndicatorSkin.width = this.actualWidth - this._focusPaddingLeft - this._focusPaddingRight;
			this._focusIndicatorSkin.height = this.actualHeight - this._focusPaddingTop - this._focusPaddingBottom;
		}
	}
	
	/**
	   @private
	**/
	private function refreshHitAreaX():Void
	{
		if (this.actualWidth < this._minTouchWidth)
		{
			this._hitArea.width = this._minTouchWidth;
		}
		else
		{
			this._hitArea.width = this.actualWidth;
		}
		var hitAreaX:Float = (this.actualWidth - this._hitArea.width) / 2;
		if (hitAreaX != hitAreaX) //isNaN
		{
			this._hitArea.x = 0;
		}
		else
		{
			this._hitArea.x = hitAreaX;
		}
	}
	
	/**
	   @private
	**/
	private function refreshHitAreaY():Void
	{
		if (this.actualHeight < this._minTouchHeight)
		{
			this._hitArea.height = this._minTouchHeight;
		}
		else
		{
			this._hitArea.height = this.actualHeight;
		}
		var hitAreaY:Float = (this.actualHeight - this._hitArea.height) / 2;
		if (hitAreaY != hitAreaY) //isNaN
		{
			this._hitArea.y = 0;
		}
		else
		{
			this._hitArea.y = hitAreaY;
		}
	}
	
	/**
	 * Default event handler for <code>FeathersEventType.FOCUS_IN</code>
	 * that may be overridden in subclasses to perform additional actions
	 * when the component receives focus.
	 */
	private function focusInHandler(event:Event):Void
	{
		this._hasFocus = true;
		this.invalidate(INVALIDATION_FLAG_FOCUS);
		
		if (this._focusOutEffectContext != null)
		{
			this._focusOutEffectContext.interrupt();
			this._focusOutEffectContext = null;
		}
		
		if (this._suspendEffectsCount == 0 && this._focusInEffect != null)
		{
			this._focusInEffectContext = cast this._focusInEffect(this);
			this._focusInEffectContext.addEventListener(Event.COMPLETE, focusInEffectContext_completeHandler);
			this._focusInEffectContext.play();
		}
	}
	
	/**
	 * Default event handler for <code>FeathersEventType.FOCUS_OUT</code>
	 * that may be overridden in subclasses to perform additional actions
	 * when the component loses focus.
	 */
	private function focusOutHandler(event:Event):Void
	{
		this._hasFocus = false;
		this._showFocus = false;
		this.invalidate(INVALIDATION_FLAG_FOCUS);
		
		if (this._focusInEffectContext != null)
		{
			this._focusInEffectContext.interrupt();
			this._focusInEffectContext = null;
		}
		
		if (this._suspendEffectsCount == 0 && this._focusOutEffect != null)
		{
			this._focusOutEffectContext = cast this._focusOutEffect(this);
			this._focusOutEffectContext.addEventListener(Event.COMPLETE, focusOutEffectContext_completeHandler);
			this._focusOutEffectContext.play();
		}
	}
	
	/**
	 * @private
	 * Initialize the control, if it hasn't been initialized yet. Then,
	 * invalidate. If already initialized, check if invalid and put back
	 * into queue.
	 */
	private function feathersControl_addedToStageHandler(event:Event):Void
	{
		if (this.stage == null)
		{
			//this could happen if removed from parent in another
			//Event.ADDED_TO_STAGE listener
			return;
		}
		//initialize before setting the validation queue to avoid
		//getting added to the validation queue before initialization
		//completes.
		if (!this._isInitialized)
		{
			this.initializeNow();
		}
		this._depth = DisplayUtils.getDisplayObjectDepthFromStage(this);
		this._validationQueue = ValidationQueue.forStarling(this.stage.starling);
		if (this.isInvalid())
		{
			this._invalidateCount = 0;
			//add to validation queue, if required
			this._validationQueue.addControl(this);
		}
		
		//if the removed effect is still active, stop it
		if (this._removedEffectContext != null)
		{
			this._removedEffectContext.interrupt();
		}
		
		if (this.isCreated && this._suspendEffectsCount == 0 && this._addedEffect != null)
		{
			this._addedEffectContext = cast this._addedEffect(this);
			this._addedEffectContext.addEventListener(Event.COMPLETE, addedEffectContext_completeHandler);
			this._addedEffectContext.play();
		}
	}
	
	/**
	   @private
	**/
	private function feathersControl_removedFromStageHandler(event:Event):Void
	{
		if (this._addedEffectContext != null)
		{
			this._addedEffectContext.interrupt();
		}
		this._depth = -1;
		this._validationQueue = null;
	}
	
	/**
	   @private
	**/
	private function addedEffectContext_completeHandler(event:Event):Void
	{
		this._addedEffectContext = null;
	}
	
	/**
	   @private
	**/
	private function removedEffectContext_completeHandler(event:Event, stopped:Bool):Void
	{
		this._removedEffectContext = null;
		if (!stopped)
		{
			this.removeFromParent(this._disposeAfterRemovedEffect);
		}
	}
	
	/**
	   @private
	**/
	private function showEffectContext_completeHandler(event:Event):Void
	{
		this._showEffectContext.removeEventListener(Event.COMPLETE, showEffectContext_completeHandler);
		this._showEffectContext = null;
	}
	
	/**
	   @private
	**/
	private function hideEffectContext_completeHandler(event:Event, stopped:Bool):Void
	{
		this._hideEffectContext.removeEventListener(Event.COMPLETE, hideEffectContext_completeHandler);
		this._hideEffectContext = null;
		if (!stopped)
		{
			this.suspendEffects();
			super.visible = this._pendingVisible;
			this.resumeEffects();
		}
	}
	
	/**
	   @private
	**/
	private function focusInEffectContext_completeHandler(event:Event):Void
	{
		this._focusInEffectContext.removeEventListener(Event.COMPLETE, focusInEffectContext_completeHandler);
		this._focusInEffectContext = null;
	}
	
	/**
	   @private
	**/
	private function focusOutEffectContext_completeHandler(event:Event):Void
	{
		this._focusOutEffectContext.removeEventListener(Event.COMPLETE, focusOutEffectContext_completeHandler);
		this._focusOutEffectContext = null;
	}
	
	/**
	   @private
	**/
	private function moveEffectContext_completeHandler(event:Event):Void
	{
		this._moveEffectContext.removeEventListener(Event.COMPLETE, moveEffectContext_completeHandler);
		this._moveEffectContext = null;
	}
	
	/**
	   @private
	**/
	private function resizeEffectContext_completeHandler(event:Event):Void
	{
		this._resizeEffectContext.removeEventListener(Event.COMPLETE, resizeEffectContext_completeHandler);
		this._resizeEffectContext = null;
	}
	
	/**
	   @private
	**/
	private function layoutData_changeHandler(event:Event):Void
	{
		this.dispatchEventWith(FeathersEventType.LAYOUT_DATA_CHANGE);
	}
	
	/**
	   @private
	**/
	private function styleNameList_changeHandler(event:Event):Void
	{
		if (this._styleProvider == null)
		{
			return;
		}
		if (this._applyingStyles)
		{
			throw new IllegalOperationError("Cannot change styleNameList while the style provider is applying styles.");
		}
		this._applyingStyles = true;
		this._styleProvider.applyStyles(this);
		this._applyingStyles = false;
	}
	
	/**
	   @private
	**/
	private function styleProvider_changeHandler(event:Event):Void
	{
		if (!this._isInitialized)
		{
			//safe to ignore changes until initialization
			return;
		}
		if (this._applyingStyles)
		{
			throw new IllegalOperationError("Cannot change style provider while it is applying styles.");
		}
		this._applyingStyles = true;
		this._styleProvider.applyStyles(this);
		this._applyingStyles = false;
	}
	
}