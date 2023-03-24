/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.controls;

import feathers.core.FeathersControl;
import feathers.core.IFeathersControl;
import feathers.core.IMeasureDisplayObject;
import feathers.core.ITextRenderer;
import feathers.core.IValidating;
import feathers.core.PopUpManager;
import feathers.data.IListCollection;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.motion.Fade;
import feathers.motion.effectClasses.IEffectContext;
import feathers.skins.IStyleProvider;
import feathers.system.DeviceCapabilities;
import feathers.text.FontStylesSet;
import feathers.utils.skins.SkinsUtils;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import openfl.Lib;
import openfl.errors.RangeError;
import openfl.geom.Point;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.events.Event;
import starling.text.TextFormat;
import starling.utils.Pool;

/**
 * Displays a notification-like message in a popup over the rest of your
 * app's content. May contain a message and optional actions, or completely
 * custom content.
 *
 * <p>In the following example, a toast displaying a message and actions is
 * triggered:</p>
 *
 * <listing version="3.0">
 * button.addEventListener( Event.TRIGGERED, button_triggeredHandler );
 * 
 * function button_triggeredHandler( event:Event ):void
 * {
 *     Toast.showMessageWithActions( "Item deleted", new ArrayCollection([{ label: "Undo" }]) );
 * }</listing>
 *
 * <p><a href="https://feathersui.com/help/beta-policy.html" target="_blank"><strong>Beta Component:</strong></a> This is a new component, and its APIs
 * may need some changes between now and the next version of Feathers to
 * account for overlooked requirements or other issues. Upgrading to future
 * versions of Feathers may involve manual changes to your code that uses
 * this component. The
 * <a href="https://feathersui.com/help/deprecation-policy.html" target="_blank">Feathers deprecation policy</a>
 * will not go into effect until this component's status is upgraded from
 * beta to stable.</p>
 *
 * @see ../../../help/toast.html How to use the Feathers Toast component
 * @see #showMessage()
 * @see #showMessageWithActions()
 * @see #showContent()
 *
 * @productversion Feathers 4.0.0
 */
class Toast extends FeathersControl 
{
	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * message text renderer.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 * @see ../../../help/text-renderers.html Introduction to Feathers text renderers
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_MESSAGE:String = "feathers-toast-message";

	/**
	 * The default value added to the <code>styleNameList</code> of the
	 * actions button group.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	public static inline var DEFAULT_CHILD_STYLE_NAME_ACTIONS:String = "feathers-toast-actions";

	/**
	 * @private
	 */
	private static inline var INVALIDATION_FLAG_ACTIONS_FACTORY:String = "actionsFactory";

	/**
	 * The default <code>IStyleProvider</code> for all <code>Toast</code>
	 * components.
	 *
	 * @default null
	 *
	 * @see feathers.core.FeathersControl#styleProvider
	 */
	public static var globalStyleProvider:IStyleProvider;
	
	/**
	 * The maximum number of toasts that can be displayed simultaneously.
	 * Additional toasts will be queued up to display after the current
	 * toasts are removed.
	 */
	public static var maxVisibleToasts(get, set):Int;
	private static var _maxVisibleToasts:Int = 1;
	private static function get_maxVisibleToasts():Int { return _maxVisibleToasts; }
	private static function set_maxVisibleToasts(value:Int):Int
	{
		if (_maxVisibleToasts == value)
		{
			return value;
		}
		if (value <= 0)
		{
			throw new RangeError("maxVisibleToasts must be greater than 0.");
		}
		_maxVisibleToasts = value;
		while (_activeToasts.length < _maxVisibleToasts && _queue.length != 0)
		{
			showNextInQueue();
		}
		return _maxVisibleToasts;
	}
	
	/**
	 * Determines how timeouts are treated when toasts need to be queued up
	 * because there are already <code>maxVisibleToasts</code> visible.
	 * Either waits until the timeout is complete, or immediately closes an
	 * existing toast and shows the queued toast after the closing effect is
	 * done.
	 */
	public static var queueMode(get, set):String;
	private static var _queueMode:String = ToastQueueMode.CANCEL_TIMEOUT;
	private static function get_queueMode():String { return _queueMode; }
	private static function set_queueMode(value:String):String
	{
		return _queueMode = value;
	}
	
	/**
	 * Used to create a new <code>Toast</code> instance in the
	 * <code>showMessage()</code>, <code>showMessageWithActions()</code>, or
	 * <code>showContent()</code> functions. Useful for customizing the
	 * styles of toasts without a theme.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():Toast</pre>
	 *
	 * <p>The following example shows how to create a custom toast factory:</p>
	 *
	 * <listing version="3.0">
	 * Toast.toastFactory = function():Toast
	 * {
	 *     var toast:Toast = new Toast();
	 *     toast.backgroundSkin = new Image( texture );
	 *     toast.padding = 10;
	 *     return toast;
	 * };</listing>
	 *
	 * @see #showMessage()
	 * @see #showMessageWithStyles()
	 * @see #showContent()
	 */
	public static var toastFactory(get, set):Void->Toast;
	private static var _toastFactory:Void->Toast = defaultToastFactory;
	private static function get_toastFactory():Void->Toast { return _toastFactory; }
	private static function set_toastFactory(value:Void->Toast):Void->Toast
	{
		return _toastFactory = value;
	}
	
	/**
	 * Create a container for toasts that is added to the pop-up manager.
	 * Useful for customizing the layout of toasts.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 *
	 * <pre>function():DisplayObjectContainer</pre>
	 *
	 * <p>The following example shows how to create a custom toast container:</p>
	 *
	 * <listing version="3.0">
	 * Toast.containerFactory = function():DisplayObjectContainer
	 * {
	 *     var container:LayoutGroup = new LayoutGroup();
	 *     container.layout = new VerticalLayout();
	 *     return container;
	 * };</listing>
	 *
	 * @see #showMessage()
	 * @see #showMessageWithStyles()
	 * @see #showContent()
	 */
	public static var containerFactory(get, set):Void->DisplayObjectContainer;
	private static var _containerFactory:Void->DisplayObjectContainer = defaultContainerFactory;
	private static function get_containerFactory():Void->DisplayObjectContainer { return _containerFactory; }
	private static function set_containerFactory(value:Void->DisplayObjectContainer):Void->DisplayObjectContainer
	{
		return _containerFactory = value;
	}
	
	/**
	 * @private
	 */
	private static var _activeToasts:Array<Toast> = new Array<Toast>();

	/**
	 * @private
	 */
	private static var _queue:Array<Toast> = new Array<Toast>();

	/**
	 * @private
	 */
	private static var _containers:Map<Starling, DisplayObjectContainer> = new Map<Starling, DisplayObjectContainer>();
	
	/**
	 * Shows a toast with custom content.
	 *
	 * @see #showMessage()
	 * @see #showMessageWithActions()
	 */
	public static function showContent(content:DisplayObject, timeout:Float = 4, toastFactory:Void->Toast = null):Toast
	{
		var factory:Void->Toast = toastFactory != null ? toastFactory : Toast._toastFactory;
		if (factory == null)
		{
			factory = defaultToastFactory;
		}
		var toast:Toast = factory();
		toast.content = content;
		return showToast(toast, timeout);
	}
	
	/**
	 * Shows a toast with a simple text message.
	 *
	 * @see #showMessageWithActions()
	 * @see #showContent()
	 */
	public static function showMessage(message:String, timeout:Float = 4, toastFactory:Void->Toast = null):Toast
	{
		var factory:Void->Toast = toastFactory != null ? toastFactory : Toast._toastFactory;
		if (factory == null)
		{
			factory = defaultToastFactory;
		}
		var toast:Toast = factory();
		toast.message = message;
		return showToast(toast, timeout);
	}
	
	/**
	 * Shows a toast with a text message and some action buttons.
	 *
	 * @see #showMessage()
	 * @see #showContent()
	 */
	public static function showMessageWithActions(message:String, actions:IListCollection, timeout:Float = 4, toastFactory:Void->Toast = null):Toast
	{
		var factory:Void->Toast = toastFactory != null ? toastFactory : Toast._toastFactory;
		if (factory == null)
		{
			factory = defaultToastFactory;
		}
		var toast:Toast = factory();
		toast.message = message;
		toast.actions = actions;
		return showToast(toast, timeout);
	}
	
	/**
	 * Shows a toast instance.
	 *
	 * @see #showMessage()
	 * @see #showMessageWithActions()
	 * @see #showContent()
	 */
	public static function showToast(toast:Toast, timeout:Float):Toast
	{
		toast.timeout = timeout;
		if (_activeToasts.length >= _maxVisibleToasts)
		{
			_queue[_queue.length] = toast;
			if (_queueMode == ToastQueueMode.CANCEL_TIMEOUT)
			{
				var toastCount:Int = _activeToasts.length;
				var activeToast:Toast;
				for (i in 0...toastCount)
				{
					activeToast = _activeToasts[i];
					if (activeToast.timeout < Math.POSITIVE_INFINITY &&
						!activeToast.isClosing)
					{
						activeToast.close(activeToast.disposeOnSelfClose);
						break;
					}
				}
			}
			return toast;
		}
		_activeToasts[_activeToasts.length] = toast;
		toast.addEventListener(Event.CLOSE, toast_closeHandler);
		var container:DisplayObjectContainer = getContainerForStarling(Starling.current);
		container.addChild(toast);
		if (Std.isOfType(container, IValidating))
		{
			//validate the parent container before opening the toast because
			//we want to be sure that the toast is positioned properly in
			//the layout for things that may rely on the position, like
			//openEffect
			cast(container, IValidating).validate();
		}
		toast.open();
		return toast;
	}
	
	/**
	 * @private
	 */
	private static function showNextInQueue():Void
	{
		if (_queue.length == 0)
		{
			return;
		}
		var toast:Toast;
		do
		{
			toast = _queue.shift();
		}
		//keep skipping toasts that have a timeout
		while (_queueMode == ToastQueueMode.CANCEL_TIMEOUT &&
			_queue.length != 0 &&
			toast.timeout < Math.POSITIVE_INFINITY);
		showToast(toast, toast.timeout);
	}
	
	/**
	 * @private
	 */
	private static function toast_closeHandler(event:Event):Void
	{
		var toast:Toast = cast event.currentTarget;
		toast.removeEventListener(Event.CLOSE, toast_closeHandler);
		var index:Int = _activeToasts.indexOf(toast);
		_activeToasts.splice(index, 1);
		showNextInQueue();
	}
	
	/**
	 * @private
	 */
	private static function getContainerForStarling(starling:Starling):DisplayObjectContainer
	{
		if (Toast._containers.exists(starling))
		{
			return Toast._containers[starling];
		}
		var factory:Void->DisplayObjectContainer = Toast._containerFactory != null ? Toast._containerFactory : defaultContainerFactory;
		var container:DisplayObjectContainer = factory();
		Toast._containers[starling] = container;
		container.addEventListener(Event.REMOVED_FROM_STAGE, function(event:Event):Void
		{
			Toast._containers.remove(starling);
		});
		PopUpManager.forStarling(starling).addPopUp(container, false, false);
		return container;
	}
	
	/**
	 * @private
	 */
	private static function defaultToastFactory():Toast
	{
		return new Toast();
	}
	
	/**
	 * @private
	 */
	private static function defaultContainerFactory():DisplayObjectContainer
	{
		var container:LayoutGroup = new LayoutGroup();
		container.autoSizeMode = AutoSizeMode.STAGE;
		var layout:VerticalLayout = new VerticalLayout();
		layout.verticalAlign = VerticalAlign.BOTTOM;
		if (DeviceCapabilities.isPhone())
		{
			layout.horizontalAlign = HorizontalAlign.JUSTIFY;
		}
		else
		{
			layout.horizontalAlign = HorizontalAlign.LEFT;
		}
		container.layout = layout;
		return container;
	}
	
	/**
	 * The default factory that creates the action button group. To use a
	 * different factory, you need to set <code>actionsFactory</code>
	 * to a <code>Function</code> instance.
	 */
	public static function defaultActionsFactory():ButtonGroup
	{
		return new ButtonGroup();
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
	}
	
	/**
	 * The value added to the <code>styleNameList</code> of the toast's
	 * message text renderer. This variable is <code>protected</code> so
	 * that sub-classes can customize the message style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_MESSAGE</code>.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var messageStyleName:String = DEFAULT_CHILD_STYLE_NAME_MESSAGE;

	/**
	 * The value added to the <code>styleNameList</code> of the toast's
	 * actions button group. This variable is <code>protected</code> so
	 * that sub-classes can customize the actions style name in their
	 * constructors instead of using the default style name defined by
	 * <code>DEFAULT_CHILD_STYLE_NAME_ACTIONS</code>.
	 *
	 * @see feathers.core.FeathersControl#styleNameList
	 */
	private var actionsStyleName:String = DEFAULT_CHILD_STYLE_NAME_ACTIONS;
	
	/**
	 * The message text renderer sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var messageTextRenderer:ITextRenderer = null;

	/**
	 * The actions button group sub-component.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private var actionsGroup:ButtonGroup = null;

	/**
	 * @private
	 */
	override function get_defaultStyleProvider():IStyleProvider
	{
		return Toast.globalStyleProvider;
	}
	
	/**
	 * @private
	 */
	private var _explicitMessageWidth:Float;

	/**
	 * @private
	 */
	private var _explicitMessageHeight:Float;

	/**
	 * @private
	 */
	private var _explicitMessageMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitMessageMinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitMessageMaxWidth:Float;

	/**
	 * @private
	 */
	private var _explicitMessageMaxHeight:Float;
	
	/**
	 * The toast's main text content.
	 */
	public var message(get, set):String;
	private var _message:String;
	private function get_message():String { return this._message; }
	private function set_message(value:String):String
	{
		if (this._message == value)
		{
			return value;
		}
		this._message = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._message;
	}
	
	/**
	 * The data provider of the toast's <code>ButtonGroup</code>.
	 */
	public var actions(get, set):IListCollection;
	private var _actions:IListCollection;
	private function get_actions():IListCollection { return this._actions; }
	private function set_actions(value:IListCollection):IListCollection
	{
		if (this._actions == value)
		{
			return value;
		}
		this._actions = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		return this._actions;
	}
	
	/**
	 * @private
	 */
	private var _explicitContentWidth:Float;

	/**
	 * @private
	 */
	private var _explicitContentHeight:Float;

	/**
	 * @private
	 */
	private var _explicitContentMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitContentMinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitContentMaxWidth:Float;

	/**
	 * @private
	 */
	private var _explicitContentMaxHeight:Float;
	
	/**
	 * Optional custom content to display in the toast.
	 */
	public var content(get, set):DisplayObject;
	private var _content:DisplayObject;
	private function get_content():DisplayObject { return this._content; }
	private function set_content(value:DisplayObject):DisplayObject
	{
		if (this._content == value)
		{
			return value;
		}
		if (this._content != null && this._content.parent == this)
		{
			this._content.removeFromParent(false);
		}
		this._content = value;
		if (this._content != null)
		{
			if (Std.isOfType(this._content, IFeathersControl))
			{
				cast(this._content, IFeathersControl).initializeNow();
			}
			if (Std.isOfType(this._content, IMeasureDisplayObject))
			{
				var measureContent:IMeasureDisplayObject = cast this._content;
				this._explicitContentWidth = measureContent.explicitWidth;
				this._explicitContentHeight = measureContent.explicitHeight;
				this._explicitContentMinWidth = measureContent.explicitMinWidth;
				this._explicitContentMinHeight = measureContent.explicitMinHeight;
				this._explicitContentMaxWidth = measureContent.explicitMaxWidth;
				this._explicitContentMaxHeight = measureContent.explicitMaxHeight;
			}
			else
			{
				this._explicitContentWidth = this._content.width;
				this._explicitContentHeight = this._content.height;
				this._explicitContentMinWidth = this._explicitContentWidth;
				this._explicitContentMinHeight = this._explicitContentHeight;
				this._explicitContentMaxWidth = this._explicitContentWidth;
				this._explicitContentMaxHeight = this._explicitContentHeight;
			}
			this.addChild(this._content);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_DATA);
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		this.invalidate(INVALIDATION_FLAG_ACTIONS_FACTORY);
		return this._content;
	}
	
	/**
	 * @private
	 */
	private var _startTime:Int = -1;
	
	/**
	 * The time, in seconds, when the toast will automatically close. Set
	 * to <code>Number.POSITIVE_INFINITY</code> to require the toast to be
	 * closed manually.
	 *
	 * @default Number.POSITIVE_INFINITY
	 */
	public var timeout(get, set):Float;
	private var _timeout:Float = Math.POSITIVE_INFINITY;
	private function get_timeout():Float { return this._timeout; }
	private function set_timeout(value:Float):Float
	{
		if (this._timeout == value)
		{
			return value;
		}
		this._timeout = value;
		if (this._isOpen)
		{
			this.startTimeout();
		}
		return this._timeout;
	}
	
	/**
	 * @private
	 */
	private var _openEffectContext:IEffectContext = null;
	
	/**
	 * An optional effect that is activated when the toast is opened.
	 *
	 * <p>In the following example, a open effect fades the toast's
	 * <code>alpha</code> property from <code>0</code> to <code>1</code>:</p>
	 *
	 * <listing version="3.0">
	 * toast.openEffect = Fade.createFadeBetweenEffect(0, 1);</listing>
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
	 * toast.closeEffect = function(target:DisplayObject):IEffectContext
	 * {
	 *     toast.alpha = 0;
	 *     var tween:Tween = new Tween(target, 0.5, Transitions.EASE_OUT);
	 *     tween.fadeTo(1);
	 *     return new TweenEffectContext(target, tween);
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.FeathersControl#closeEffect
	 * @see #showToast()
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public var openEffect(get, set):Function;
	private var _openEffect:Function = Fade.createFadeInEffect();
	private function get_openEffect():Function { return this._openEffect; }
	private function set_openEffect(value:Function):Function
	{
		if (this._openEffect == value)
		{
			return value;
		}
		return this._openEffect = value;
	}
	
	/**
	 * @private
	 */
	private var _closeEffectContext:IEffectContext = null;
	
	/**
	 * An optional effect that is activated when the toast is closed.
	 *
	 * <p>In the following example, a close effect fades the toast's
	 * <code>alpha</code> property from <code>1</code> to <code>0</code>:</p>
	 *
	 * <listing version="3.0">
	 * toast.closeEffect = Fade.createFadeBetweenEffect(1, 0);</listing>
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
	 * toast.closeEffect = function(target:DisplayObject):IEffectContext
	 * {
	 *     toast.alpha = 1;
	 *     var tween:Tween = new Tween(target, 0.5, Transitions.EASE_OUT);
	 *     tween.fadeTo(0);
	 *     return new TweenEffectContext(target, tween);
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.FeathersControl#openEffect
	 * @see ../../../help/effects.html Effects and animation for Feathers components
	 * @see feathers.motion.effectClasses.IEffectContext
	 * @see feathers.motion.effectClasses.TweenEffectContext
	 */
	public var closeEffect(get, set):Function;
	private var _closeEffect:Function = Fade.createFadeOutEffect();
	private function get_closeEffect():Function { return this._closeEffect; }
	private function set_closeEffect(value:Function):Function
	{
		if (this._closeEffect == value)
		{
			return value;
		}
		return this._closeEffect = value;
	}
	
	/**
	 * @private
	 */
	private var _fontStylesSet:FontStylesSet = null;
	
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
	 * A function used to instantiate the toast's message text renderer
	 * sub-component. By default, the toast will use the global text
	 * renderer factory, <code>FeathersControl.defaultTextRendererFactory()</code>,
	 * to create the message text renderer. The message text renderer must
	 * be an instance of <code>ITextRenderer</code>. This factory can be
	 * used to change properties on the message text renderer when it is
	 * first created. For instance, if you are skinning Feathers components
	 * without a theme, you might use this factory to style the message text
	 * renderer.
	 *
	 * <p>If you are not using a theme, the message factory can be used to
	 * provide skin the message text renderer with appropriate text styles.</p>
	 *
	 * <p>The factory should have the following function signature:</p>
	 * <pre>function():ITextRenderer</pre>
	 *
	 * <p>In the following example, a custom message factory is passed to
	 * the toast:</p>
	 *
	 * <listing version="3.0">
	 * toast.messageFactory = function():ITextRenderer
	 * {
	 *     var messageRenderer:TextFieldTextRenderer = new TextFieldTextRenderer();
	 *     messageRenderer.textFormat = new TextFormat( "_sans", 12, 0xff0000 );
	 *     return messageRenderer;
	 * }</listing>
	 *
	 * @default null
	 *
	 * @see #message
	 * @see feathers.core.ITextRenderer
	 * @see feathers.core.FeathersControl#defaultTextRendererFactory
	 */
	public var messageFactory(get, set):Void->ITextRenderer;
	private var _messageFactory:Void->ITextRenderer;
	private function get_messageFactory():Void->ITextRenderer { return this._messageFactory; }
	private function set_messageFactory(value:Void->ITextRenderer):Void->ITextRenderer
	{
		if (this._messageFactory == value)
		{
			return value;
		}
		this._messageFactory = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._messageFactory;
	}
	
	/**
	 * @private
	 */
	public var customMessageStyleName(get, set):String;
	private var _customMessageStyleName:String;
	private function get_customMessageStyleName():String { return this._customMessageStyleName; }
	private function set_customMessageStyleName(value:String):String
	{
		if (this.processStyleRestriction("customMessageStyleName"))
		{
			return value;
		}
		if (this._customMessageStyleName == value)
		{
			return value;
		}
		this._customMessageStyleName = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		return this._customMessageStyleName;
	}
	
	/**
	 * A function used to generate the toast's button group sub-component.
	 * The button group must be an instance of <code>ButtonGroup</code>.
	 * This factory can be used to change properties on the button group
	 * when it is first created. For instance, if you are skinning Feathers
	 * components without a theme, you might use this factory to set skins
	 * and other styles on the button group.
	 *
	 * <p>The function should have the following signature:</p>
	 * <pre>function():ButtonGroup</pre>
	 *
	 * <p>In the following example, a custom button group factory is
	 * provided to the toast:</p>
	 *
	 * <listing version="3.0">
	 * toast.actionsFactory = function():ButtonGroup
	 * {
	 *     return new ButtonGroup();
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.ButtonGroup
	 */
	public var actionsFactory(get, set):Void->ButtonGroup;
	private var _actionsFactory:Void->ButtonGroup;
	private function get_actionsFactory():Void->ButtonGroup { return this._actionsFactory; }
	private function set_actionsFactory(value:Void->ButtonGroup):Void->ButtonGroup
	{
		if (this._actionsFactory == value)
		{
			return value;
		}
		this._actionsFactory = value;
		this.invalidate(INVALIDATION_FLAG_ACTIONS_FACTORY);
		return this._actionsFactory;
	}
	
	/**
	 * @private
	 */
	public var customActionsStyleName(get, set):String;
	private var _customActionsStyleName:String;
	private function get_customActionsStyleName():String { return this._customActionsStyleName; }
	private function set_customActionsStyleName(value:String):String
	{
		if (this.processStyleRestriction("customActionsStyleName"))
		{
			return value;
		}
		if (this._customActionsStyleName == value)
		{
			return value;
		}
		this._customActionsStyleName = value;
		this.invalidate(INVALIDATION_FLAG_ACTIONS_FACTORY);
		return this._customActionsStyleName;
	}
	
	/**
	 * @private
	 */
	private var _disposeFromCloseCall:Bool = false;
	
	/**
	 * Determines if the toast will be disposed when <code>close()</code>
	 * is called internally. Close may be called internally in a variety of
	 * cases, depending on values such as <code>timeout</code> and
	 * <code>actions</code>. If set to <code>false</code>, you may reuse the
	 * toast later by passing it to <code>Toast.showToast()</code>.
	 *
	 * <p>In the following example, the toast will not be disposed when it
	 * closes itself:</p>
	 *
	 * <listing version="3.0">
	 * toast.disposeOnSelfClose = false;</listing>
	 *
	 * @default true
	 *
	 * @see #close()
	 * @see #disposeContent
	 */
	public var disposeOnSelfClose(get, set):Bool;
	private var _disposeOnSelfClose:Bool = true;
	private function get_disposeOnSelfClose():Bool { return this._disposeOnSelfClose; }
	private function set_disposeOnSelfClose(value:Bool):Bool
	{
		return this._disposeOnSelfClose = value;
	}
	
	/**
	 * Determines if the toast's content will be disposed when the toast
	 * is disposed. If set to <code>false</code>, the toast's content may
	 * be added to the display list again later.
	 *
	 * <p>In the following example, the toast's content will not be
	 * disposed when the toast is disposed:</p>
	 *
	 * <listing version="3.0">
	 * toast.disposeContent = false;</listing>
	 *
	 * @default true
	 *
	 * @see #disposeOnSelfClose
	 */
	public var disposeContent(get, set):Bool;
	private var _disposeContent:Bool = true;
	private function get_disposeContent():Bool { return this._disposeContent; }
	private function set_disposeContent(value:Bool):Bool
	{
		return this._disposeContent = value;
	}
	
	/**
	 * @private
	 */
	private var _closeData:Dynamic = null;
	
	/**
	 * Indicates if the toast is currently closing.
	 *
	 * @see #isOpening
	 * @see #isOpen
	 */
	public var isClosing(get, never):Bool;
	private var _isClosing:Bool = false;
	private function get_isClosing():Bool { return this._isClosing; }
	
	/**
	 * Indicates if the toast is currently opening.
	 *
	 * @see #isClosing
	 */
	public var isOpening(get, never):Bool;
	private var _isOpening:Bool = false;
	private function get_isOpening():Bool { return this._isOpening; }
	
	/**
	 * Indicates if the toast is currently open. Does not change from
	 * <code>false</code> to <code>true</code> until the open effect has
	 * completed. Similarly, does not change from <code>true</code> to
	 * <code>false</code> until the close effect has completed.
	 *
	 * @see #isOpening
	 * @see #isClosing
	 * @see #event:open starling.events.Event.OPEN
	 * @see #event:close starling.events.Event.CLOSE
	 */
	public var isOpen(get, never):Bool;
	private var _isOpen:Bool = false;
	private function get_isOpen():Bool { return this._isOpen; }
	
	/**
	 * @private
	 */
	private var _explicitBackgroundSkinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinMinWidth:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinMinHeight:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinMaxWidth:Float;

	/**
	 * @private
	 */
	private var _explicitBackgroundSkinMaxHeight:Float;
	
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
		var measureSkin:IMeasureDisplayObject;
		if (this._backgroundSkin != null && this._backgroundSkin.parent == this)
		{
			//we need to restore these values so that they won't be lost the
			//next time that this skin is used for measurement
			this._backgroundSkin.width = this._explicitBackgroundSkinWidth;
			this._backgroundSkin.height = this._explicitBackgroundSkinHeight;
			if (Std.isOfType(this._backgroundSkin, IMeasureDisplayObject))
			{
				measureSkin = cast this._backgroundSkin;
				measureSkin.minWidth = this._explicitBackgroundSkinMinWidth;
				measureSkin.minHeight = this._explicitBackgroundSkinMinHeight;
				measureSkin.maxWidth = this._explicitBackgroundSkinMaxWidth;
				measureSkin.maxHeight = this._explicitBackgroundSkinMaxHeight;
			}
			this._backgroundSkin.removeFromParent(false);
		}
		this._backgroundSkin = value;
		if (this._backgroundSkin != null)
		{
			if (Std.isOfType(this._backgroundSkin, IFeathersControl))
			{
				cast(this._backgroundSkin, IFeathersControl).initializeNow();
			}
			if (Std.isOfType(this._backgroundSkin, IMeasureDisplayObject))
			{
				measureSkin = cast this._backgroundSkin;
				this._explicitBackgroundSkinWidth = measureSkin.explicitWidth;
				this._explicitBackgroundSkinHeight = measureSkin.explicitHeight;
				this._explicitBackgroundSkinMinWidth = measureSkin.explicitMinWidth;
				this._explicitBackgroundSkinMinHeight = measureSkin.explicitMinHeight;
				this._explicitBackgroundSkinMaxWidth = measureSkin.explicitMaxWidth;
				this._explicitBackgroundSkinMaxHeight = measureSkin.explicitMaxHeight;
			}
			else
			{
				this._explicitBackgroundSkinWidth = this._backgroundSkin.width;
				this._explicitBackgroundSkinHeight = this._backgroundSkin.height;
				this._explicitBackgroundSkinMinWidth = this._explicitBackgroundSkinWidth;
				this._explicitBackgroundSkinMinHeight = this._explicitBackgroundSkinHeight;
				this._explicitBackgroundSkinMaxWidth = this._explicitBackgroundSkinWidth;
				this._explicitBackgroundSkinMaxHeight = this._explicitBackgroundSkinHeight;
			}
			this.addChildAt(this._backgroundSkin, 0);
		}
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._backgroundSkin;
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
	public var horizontalAlign(get, set):String;
	private var _horizontalAlign:String = HorizontalAlign.CENTER;
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
	public var gap(get, set):Float;
	private var _gap:Float = 0;
	private function get_gap():Float { return _gap; }
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
	public var minGap(get, set):Float;
	private var _minGap:Float = 0;
	private function get_minGap():Float { return _minGap; }
	private function set_minGap(value:Float):Float
	{
		if (this.processStyleRestriction("minGap"))
		{
			return value;
		}
		if (this._minGap == value)
		{
			return value;
		}
		this._minGap = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._minGap;
	}
	
	/**
	 * @private
	 */
	public var actionsPosition(get, set):String;
	private var _actionsPosition:String = RelativePosition.RIGHT;
	private function get_actionsPosition():String { return this._actionsPosition; }
	private function set_actionsPosition(value:String):String
	{
		if (this.processStyleRestriction("actionsPosition"))
		{
			return value;
		}
		if (this._actionsPosition == value)
		{
			return value;
		}
		this._actionsPosition = value;
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
		return this._actionsPosition;
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
		var savedContent:DisplayObject = this._content;
		this.content = null;
		//remove the content safely if it should not be disposed
		if (savedContent != null && this._disposeContent)
		{
			savedContent.dispose();
		}
		super.dispose();
	}
	
	/**
	 * @private
	 *
	 * @see #showToast()
	 */
	private function open():Void
	{
		if (this._isOpen || this._isOpening)
		{
			return;
		}
		if (this._suspendEffectsCount == 0 && this._closeEffectContext != null)
		{
			this._closeEffectContext.interrupt();
			this._closeEffectContext = null;
		}
		if (this._openEffect != null)
		{
			this._isOpening = true;
			this._openEffectContext = cast this._openEffect(this);
			this._openEffectContext.addEventListener(Event.COMPLETE, openEffectContext_completeHandler);
			this._openEffectContext.play();
		}
		else
		{
			this.completeOpen();
		}
	}
	
	/**
	 * Closes the toast and optionally disposes it. If a
	 * <code>closeEffect</code> has been specified, it will be played.
	 *
	 * @see #closeEffect
	 */
	public function close(dispose:Bool = true):Void
	{
		this.closeToast(null, dispose);
	}
	
	/**
	 * @private
	 */
	override function draw():Void
	{
		var dataInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_DATA);
		var sizeInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_SIZE);
		var stylesInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STYLES);
		//var stateInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_STATE);
		var textRendererInvalid:Bool = this.isInvalid(FeathersControl.INVALIDATION_FLAG_TEXT_RENDERER);
		var actionsInvalid:Bool = this.isInvalid(INVALIDATION_FLAG_ACTIONS_FACTORY);
		
		if (textRendererInvalid)
		{
			this.createMessage();
		}
		
		if (actionsInvalid)
		{
			this.createActions();
		}
		
		if (textRendererInvalid || dataInvalid)
		{
			if (this.messageTextRenderer != null)
			{
				this.messageTextRenderer.text = this._message;
			}
		}
		
		if (textRendererInvalid || stylesInvalid)
		{
			this.refreshMessageStyles();
		}
		
		if (actionsInvalid || dataInvalid)
		{
			if (this.actionsGroup != null)
			{
				this.actionsGroup.dataProvider = this._actions;
			}
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
		
		var adjustedGap:Float = this._gap;
		if (adjustedGap == Math.POSITIVE_INFINITY)
		{
			adjustedGap = this._minGap;
		}
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this._backgroundSkin,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitBackgroundSkinWidth, this._explicitBackgroundSkinHeight,
			this._explicitBackgroundSkinMinWidth, this._explicitBackgroundSkinMinHeight,
			this._explicitBackgroundSkinMaxWidth, this._explicitBackgroundSkinMaxHeight);
		var measureSkin:IMeasureDisplayObject = SafeCast.safe_cast(this._backgroundSkin, IMeasureDisplayObject);
		
		SkinsUtils.resetFluidChildDimensionsForMeasurement(this._content,
			this._explicitWidth, this._explicitHeight,
			this._explicitMinWidth, this._explicitMinHeight,
			this._explicitMaxWidth, this._explicitMaxHeight,
			this._explicitContentWidth, this._explicitContentHeight,
			this._explicitContentMinWidth, this._explicitContentMinHeight,
			this._explicitContentMaxWidth, this._explicitContentMaxHeight);
		var measureContent:IMeasureDisplayObject = SafeCast.safe_cast(this._content, IMeasureDisplayObject);
		
		if (Std.isOfType(this._content, IValidating))
		{
			cast(this._content, IValidating).validate();
		}
		var messageSize:Point = Pool.getPoint();
		if (this.messageTextRenderer != null)
		{
			this.refreshMessageTextRendererDimensions(true);
			this.messageTextRenderer.measureText(messageSize);
		}
		if (this.actionsGroup != null)
		{
			this.actionsGroup.validate();
		}
		if (Std.isOfType(this._backgroundSkin, IValidating))
		{
			cast(this._backgroundSkin, IValidating).validate();
		}
		
		var newMinWidth:Float = this._explicitMinWidth;
		if (needsMinWidth)
		{
			if (this._content != null)
			{
				if (measureContent != null)
				{
					newMinWidth = measureContent.minWidth;
				}
				else
				{
					newMinWidth = this._content.width;
				}
			}
			else if (this.messageTextRenderer != null)
			{
				newMinWidth = messageSize.x;
			}
			else
			{
				newMinWidth = 0;
			}
			if (this.actionsGroup != null)
			{
				if (this.messageTextRenderer != null) //both message and actions
				{
					if (this._actionsPosition != RelativePosition.TOP &&
						this._actionsPosition != RelativePosition.BOTTOM)
					{
						newMinWidth += adjustedGap;
						newMinWidth += this.actionsGroup.minWidth;
					}
					else //top or bottom
					{
						var iconMinWidth:Float = this.actionsGroup.minWidth;
						if (iconMinWidth > newMinWidth)
						{
							newMinWidth = iconMinWidth;
						}
					}
				}
				else //no message
				{
					newMinWidth = this.actionsGroup.minWidth;
				}
			}
			newMinWidth += this._paddingLeft + this._paddingRight;
			if (this._backgroundSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minWidth > newMinWidth)
					{
						newMinWidth = measureSkin.minWidth;
					}
				}
				else if (this._explicitBackgroundSkinMinWidth > newMinWidth)
				{
					newMinWidth = this._explicitBackgroundSkinMinWidth;
				}
			}
		}
		
		var newMinHeight:Float = this._explicitMinHeight;
		if (needsMinHeight)
		{
			if (this._content != null)
			{
				if (measureContent != null)
				{
					newMinHeight = measureContent.minHeight;
				}
				else
				{
					newMinHeight = this._content.height;
				}
			}
			else if (this.messageTextRenderer != null)
			{
				newMinHeight = messageSize.y;
			}
			else
			{
				newMinHeight = 0;
			}
			if (this.actionsGroup != null)
			{
				if (this.messageTextRenderer != null) //both message and actions
				{
					if (this._actionsPosition == RelativePosition.TOP ||
						this._actionsPosition == RelativePosition.BOTTOM)
					{
						newMinHeight += adjustedGap;
						newMinHeight += this.actionsGroup.minHeight;
					}
					else //left or right
					{
						var iconMinHeight:Float = this.actionsGroup.minHeight;
						if (iconMinHeight > newMinHeight)
						{
							newMinHeight = iconMinHeight;
						}
					}
				}
				else //no message
				{
					newMinHeight = this.actionsGroup.minHeight;
				}
			}
			newMinHeight += this._paddingTop + this._paddingBottom;
			if (this._backgroundSkin != null)
			{
				if (measureSkin != null)
				{
					if (measureSkin.minHeight > newMinHeight)
					{
						newMinHeight = measureSkin.minHeight;
					}
				}
				else if (this._explicitBackgroundSkinMinHeight > newMinHeight)
				{
					newMinHeight = this._explicitBackgroundSkinMinHeight;
				}
			}
		}
		
		var newWidth:Float = this._explicitWidth;
		if (needsWidth)
		{
			if (this._content != null)
			{
				newWidth = this._content.width;
			}
			else if (this.messageTextRenderer != null)
			{
				newWidth = messageSize.x;
			}
			else
			{
				newWidth = 0;
			}
			if (this.actionsGroup != null)
			{
				if (this.messageTextRenderer != null) //both message and actions
				{
					if (this._actionsPosition != RelativePosition.TOP &&
						this._actionsPosition != RelativePosition.BOTTOM)
					{
						newWidth += adjustedGap + this.actionsGroup.width;
					}
					else if (this.actionsGroup.width > newWidth) //top or bottom
					{
						newWidth = this.actionsGroup.width;
					}
				}
				else //no message
				{
					newWidth = this.actionsGroup.width;
				}
			}
			newWidth += this._paddingLeft + this._paddingRight;
			if (this._backgroundSkin != null &&
				this._backgroundSkin.width > newWidth)
			{
				newWidth = this._backgroundSkin.width;
			}
		}
		
		var newHeight:Float = this._explicitHeight;
		if (needsHeight)
		{
			if (this._content != null)
			{
				newHeight = this._content.height;
			}
			else if (this.messageTextRenderer != null)
			{
				newHeight = messageSize.y;
			}
			else
			{
				newHeight = 0;
			}
			if (this.actionsGroup != null)
			{
				if (this.messageTextRenderer != null) //both message and actions
				{
					if (this._actionsPosition == RelativePosition.TOP ||
						this._actionsPosition == RelativePosition.BOTTOM)
					{
						newHeight += adjustedGap + this.actionsGroup.height;
					}
					else if (this.actionsGroup.height > newHeight) //left or right
					{
						newHeight = this.actionsGroup.height;
					}
				}
				else //no message
				{
					newHeight = this.actionsGroup.height;
				}
			}
			newHeight += this._paddingTop + this._paddingBottom;
			if (this._backgroundSkin != null &&
				this._backgroundSkin.height > newHeight)
			{
				newHeight = this._backgroundSkin.height;
			}
		}
		
		Pool.putPoint(messageSize);
		
		return this.saveMeasurements(newWidth, newHeight, newMinWidth, newMinHeight);
	}
	
	/**
	 * @private
	 */
	private function refreshMessageTextRendererDimensions(forMeasurement:Bool):Void
	{
		if (this.actionsGroup != null)
		{
			this.actionsGroup.validate();
		}
		if (this.messageTextRenderer == null)
		{
			return;
		}
		var calculatedWidth:Float = this.actualWidth;
		var calculatedHeight:Float = this.actualHeight;
		if (forMeasurement)
		{
			calculatedWidth = this._explicitWidth;
			if (calculatedWidth != calculatedWidth) //isNaN
			{
				calculatedWidth = this._explicitMaxWidth;
			}
			calculatedHeight = this._explicitHeight;
			if (calculatedHeight != calculatedHeight) //isNaN
			{
				calculatedHeight = this._explicitMaxHeight;
			}
		}
		calculatedWidth -= (this._paddingLeft + this._paddingRight);
		calculatedHeight -= (this._paddingTop + this._paddingBottom);
		if (this.actionsGroup != null)
		{
			var adjustedGap:Float = this._gap;
			if (adjustedGap == Math.POSITIVE_INFINITY)
			{
				adjustedGap = this._minGap;
			}
			if (this._actionsPosition == RelativePosition.LEFT ||
				this._actionsPosition == RelativePosition.RIGHT)
			{
				calculatedWidth -= (this.actionsGroup.width + adjustedGap);
			}
			if (this._actionsPosition == RelativePosition.TOP || this._actionsPosition == RelativePosition.BOTTOM)
			{
				calculatedHeight -= (this.actionsGroup.height + adjustedGap);
			}
		}
		if (calculatedWidth < 0)
		{
			calculatedWidth = 0;
		}
		if (calculatedHeight < 0)
		{
			calculatedHeight = 0;
		}
		if (calculatedWidth > this._explicitMessageMaxWidth)
		{
			calculatedWidth = this._explicitMessageMaxWidth;
		}
		if (calculatedHeight > this._explicitMessageMaxHeight)
		{
			calculatedHeight = this._explicitMessageMaxHeight;
		}
		this.messageTextRenderer.width = this._explicitMessageWidth;
		this.messageTextRenderer.height = this._explicitMessageHeight;
		this.messageTextRenderer.minWidth = this._explicitMessageMinWidth;
		this.messageTextRenderer.minHeight = this._explicitMessageMinHeight;
		this.messageTextRenderer.maxWidth = calculatedWidth;
		this.messageTextRenderer.maxHeight = calculatedHeight;
		this.messageTextRenderer.validate();
		if (!forMeasurement)
		{
			calculatedWidth = this.messageTextRenderer.width;
			calculatedHeight = this.messageTextRenderer.height;
			//setting all of these dimensions explicitly means that the text
			//renderer won't measure itself again when it validates, which
			//helps performance. we'll reset them when the toast needs to
			//measure itself.
			this.messageTextRenderer.width = calculatedWidth;
			this.messageTextRenderer.height = calculatedHeight;
			this.messageTextRenderer.minWidth = calculatedWidth;
			this.messageTextRenderer.minHeight = calculatedHeight;
		}
	}
	
	/**
	 * Creates and adds the <code>messageTextRenderer</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #message
	 * @see #messageTextRenderer
	 * @see #messageFactory
	 */
	private function createMessage():Void
	{
		if (this.messageTextRenderer != null)
		{
			this.removeChild(cast this.messageTextRenderer, true);
			this.messageTextRenderer = null;
		}
		
		if (this._message == null)
		{
			return;
		}
		
		var factory:Void->ITextRenderer = this._messageFactory != null ? this._messageFactory : FeathersControl.defaultTextRendererFactory;
		this.messageTextRenderer = factory();
		this.messageTextRenderer.wordWrap = true;
		var messageStyleName:String = this._customMessageStyleName != null ? this._customMessageStyleName : this.messageStyleName;
		var uiTextRenderer:IFeathersControl = cast this.messageTextRenderer;
		uiTextRenderer.styleNameList.add(messageStyleName);
		uiTextRenderer.touchable = false;
		this.addChild(cast this.messageTextRenderer);
		this._explicitMessageWidth = this.messageTextRenderer.explicitWidth;
		this._explicitMessageHeight = this.messageTextRenderer.explicitHeight;
		this._explicitMessageMinWidth = this.messageTextRenderer.explicitMinWidth;
		this._explicitMessageMinHeight = this.messageTextRenderer.explicitMinHeight;
		this._explicitMessageMaxWidth = this.messageTextRenderer.explicitMaxWidth;
		this._explicitMessageMaxHeight = this.messageTextRenderer.explicitMaxHeight;
	}
	
	/**
	 * @private
	 */
	private function refreshMessageStyles():Void
	{
		if (this.messageTextRenderer == null)
		{
			return;
		}
		this.messageTextRenderer.fontStyles = this._fontStylesSet;
	}
	
	/**
	 * Creates and adds the <code>actionsGroup</code> sub-component and
	 * removes the old instance, if one exists.
	 *
	 * <p>Meant for internal use, and subclasses may override this function
	 * with a custom implementation.</p>
	 *
	 * @see #actionsGroup
	 * @see #actionsFactory
	 * @see #style:customActionsStyleName
	 */
	private function createActions():Void
	{
		if (this.actionsGroup != null)
		{
			this.actionsGroup.removeEventListener(Event.TRIGGERED, actionsGroup_triggeredHandler);
			this.removeChild(this.actionsGroup, true);
			this.actionsGroup = null;
		}
		
		if (this._actions == null)
		{
			return;
		}
		var factory:Void->ButtonGroup = this._actionsFactory != null ? this._actionsFactory : defaultActionsFactory;
		if (factory == null)
		{
			return;
		}
		var actionsStyleName:String = this._customActionsStyleName != null ? this._customActionsStyleName : this.actionsStyleName;
		this.actionsGroup = factory();
		this.actionsGroup.styleNameList.add(actionsStyleName);
		this.actionsGroup.addEventListener(Event.TRIGGERED, actionsGroup_triggeredHandler);
		this.addChild(this.actionsGroup);
	}
	
	/**
	 * Positions and sizes the toast's content.
	 *
	 * <p>For internal use in subclasses.</p>
	 */
	private function layoutChildren():Void
	{
		if (this._backgroundSkin != null)
		{
			this._backgroundSkin.width = this.actualWidth;
			this._backgroundSkin.height = this.actualHeight;
		}
		if (this._content != null)
		{
			this._content.x = this._paddingLeft;
			this._content.y = this._paddingTop;
			this._content.width = this.actualWidth - this._paddingLeft - this._paddingRight;
			this._content.height = this.actualHeight - this._paddingTop - this._paddingBottom;
		}
		
		this.refreshMessageTextRendererDimensions(false);
		if (this.actionsGroup != null)
		{
			this.positionSingleChild(cast this.messageTextRenderer);
			this.positionActionsRelativeToMessage();
		}
		else if (this.messageTextRenderer != null)
		{
			this.positionSingleChild(cast this.messageTextRenderer);
		}
	}
	
	/**
	 * @private
	 */
	private function positionSingleChild(displayObject:DisplayObject):Void
	{
		if (this._horizontalAlign == HorizontalAlign.LEFT)
		{
			displayObject.x = this._paddingLeft;
		}
		else if (this._horizontalAlign == HorizontalAlign.RIGHT)
		{
			displayObject.x = this.actualWidth - this._paddingRight - displayObject.width;
		}
		else //center
		{
			displayObject.x = this._paddingLeft + Math.fround((this.actualWidth - this._paddingLeft - this._paddingRight - displayObject.width) / 2);
		}
		if (this._verticalAlign == VerticalAlign.TOP)
		{
			displayObject.y = this._paddingTop;
		}
		else if (this._verticalAlign == VerticalAlign.BOTTOM)
		{
			displayObject.y = this.actualHeight - this._paddingBottom - displayObject.height;
		}
		else //middle
		{
			displayObject.y = this._paddingTop + Math.fround((this.actualHeight - this._paddingTop - this._paddingBottom - displayObject.height) / 2);
		}
	}
	
	/**
	 * @private
	 */
	private function positionActionsRelativeToMessage():Void
	{
		if (this._actionsPosition == RelativePosition.TOP)
		{
			if (this._gap == Math.POSITIVE_INFINITY)
			{
				this.actionsGroup.y = this._paddingTop;
				this.messageTextRenderer.y = this.actualHeight - this._paddingBottom - this.messageTextRenderer.height;
			}
			else
			{
				if (this._verticalAlign == VerticalAlign.TOP)
				{
					this.messageTextRenderer.y += this.actionsGroup.height + this._gap;
				}
				else if (this._verticalAlign == VerticalAlign.MIDDLE)
				{
					this.messageTextRenderer.y += Math.fround((this.actionsGroup.height + this._gap) / 2);
				}
				this.actionsGroup.y = this.messageTextRenderer.y - this.actionsGroup.height - this._gap;
			}
		}
		else if (this._actionsPosition == RelativePosition.RIGHT)
		{
			if (this._gap == Math.POSITIVE_INFINITY)
			{
				this.messageTextRenderer.x = this._paddingLeft;
				this.actionsGroup.x = this.actualWidth - this._paddingRight - this.actionsGroup.width;
			}
			else
			{
				if (this._horizontalAlign == HorizontalAlign.RIGHT)
				{
					this.messageTextRenderer.x -= this.actionsGroup.width + this._gap;
				}
				else if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					this.messageTextRenderer.x -= Math.fround((this.actionsGroup.width + this._gap) / 2);
				}
				this.actionsGroup.x = this.messageTextRenderer.x + this.messageTextRenderer.width + this._gap;
			}
		}
		else if (this._actionsPosition == RelativePosition.BOTTOM)
		{
			if (this._gap == Math.POSITIVE_INFINITY)
			{
				this.messageTextRenderer.y = this._paddingTop;
				this.actionsGroup.y = this.actualHeight - this._paddingBottom - this.actionsGroup.height;
			}
			else
			{
				if (this._verticalAlign == VerticalAlign.BOTTOM)
				{
					this.messageTextRenderer.y -= this.actionsGroup.height + this._gap;
				}
				else if (this._verticalAlign == VerticalAlign.MIDDLE)
				{
					this.messageTextRenderer.y -= Math.fround((this.actionsGroup.height + this._gap) / 2);
				}
				this.actionsGroup.y = this.messageTextRenderer.y + this.messageTextRenderer.height + this._gap;
			}
		}
		else if (this._actionsPosition == RelativePosition.LEFT)
		{
			if (this._gap == Math.POSITIVE_INFINITY)
			{
				this.actionsGroup.x = this._paddingLeft;
				this.messageTextRenderer.x = this.actualWidth - this._paddingRight - this.messageTextRenderer.width;
			}
			else
			{
				if (this._horizontalAlign == HorizontalAlign.LEFT)
				{
					this.messageTextRenderer.x += this._gap + this.actionsGroup.width;
				}
				else if (this._horizontalAlign == HorizontalAlign.CENTER)
				{
					this.messageTextRenderer.x += Math.fround((this._gap + this.actionsGroup.width) / 2);
				}
				this.actionsGroup.x = this.messageTextRenderer.x - this._gap - this.actionsGroup.width;
			}
		}
		
		if (this._actionsPosition == RelativePosition.LEFT || this._actionsPosition == RelativePosition.RIGHT)
		{
			if (this._verticalAlign == VerticalAlign.TOP)
			{
				this.actionsGroup.y = this._paddingTop;
			}
			else if (this._verticalAlign == VerticalAlign.BOTTOM)
			{
				this.actionsGroup.y = this.actualHeight - this._paddingBottom - this.actionsGroup.height;
			}
			else
			{
				this.actionsGroup.y = this._paddingTop + Math.fround((this.actualHeight - this._paddingTop - this._paddingBottom - this.actionsGroup.height) / 2);
			}
		}
		else //top or bottom
		{
			if (this._horizontalAlign == HorizontalAlign.LEFT)
			{
				this.actionsGroup.x = this._paddingLeft;
			}
			else if (this._horizontalAlign == HorizontalAlign.RIGHT)
			{
				this.actionsGroup.x = this.actualWidth - this._paddingRight - this.actionsGroup.width;
			}
			else
			{
				this.actionsGroup.x = this._paddingLeft + Math.fround((this.actualWidth - this._paddingLeft - this._paddingRight - this.actionsGroup.width) / 2);
			}
		}
	}
	
	/**
	 * @private
	 */
	private function startTimeout():Void
	{
		if (this._timeout == Math.POSITIVE_INFINITY)
		{
			this.removeEventListener(Event.ENTER_FRAME, this.toast_timeout_enterFrameHandler);
			return;
		}
		this._startTime = Lib.getTimer();
		this.addEventListener(Event.ENTER_FRAME, this.toast_timeout_enterFrameHandler);
	}
	
	/**
	 * @private
	 */
	private function completeClose():Void
	{
		var closeData:Dynamic = this._closeData;
		var dispose:Bool = this._disposeFromCloseCall;
		this._closeEffectContext = null;
		this._closeData = null;
		this._disposeFromCloseCall = false;
		this._isClosing = false;
		this._isOpen = false;
		//remove from parent before dispatching close so that the parent
		//layout is updated before any new toasts are added, but don't
		//dispose the toast yet!
		this.removeFromParent(false);
		this.dispatchEventWith(Event.CLOSE, false, closeData);
		if (dispose)
		{
			//dispose after the close event has been dispatched so that the
			//listeners aren't removed
			this.dispose();
		}
	}
	
	/**
	 * @private
	 */
	private function completeOpen():Void
	{
		this._openEffectContext = null;
		this._isOpening = false;
		this._isOpen = true;
		this.dispatchEventWith(Event.OPEN);
		this.startTimeout();
	}
	
	/**
	 * @private
	 */
	private function toast_timeout_enterFrameHandler(event:Event):Void
	{
		var totalTime:Float = (Lib.getTimer() - this._startTime) / 1000;
		if (totalTime > this._timeout)
		{
			this.close(this._disposeOnSelfClose);
		}
	}
	
	/**
	 * @private
	 */
	private function fontStyles_changeHandler(event:Event):Void
	{
		this.invalidate(FeathersControl.INVALIDATION_FLAG_STYLES);
	}
	
	/**
	 * @private
	 */
	private function closeToast(data:Dynamic, dispose:Bool):Void
	{
		if (this.parent == null || this._isClosing)
		{
			return;
		}
		if (this._suspendEffectsCount == 0 && this._openEffectContext != null)
		{
			this._openEffectContext.interrupt();
			this._openEffectContext = null;
		}
		this._isClosing = true;
		this._closeData = data;
		this._disposeFromCloseCall = dispose;
		this.removeEventListener(Event.ENTER_FRAME, this.toast_timeout_enterFrameHandler);
		if (this._closeEffect != null)
		{
			this._closeEffectContext = cast this._closeEffect(this);
			this._closeEffectContext.addEventListener(Event.COMPLETE, closeEffectContext_completeHandler);
			this._closeEffectContext.play();
		}
		else
		{
			this.completeClose();
		}
	}
	
	/**
	 * @private
	 */
	private function actionsGroup_triggeredHandler(event:Event, data:Dynamic):Void
	{
		this.closeToast(data, this._disposeOnSelfClose);
	}

	/**
	 * @private
	 */
	private function closeEffectContext_completeHandler(event:Event):Void
	{
		this.completeClose();
	}

	/**
	 * @private
	 */
	private function openEffectContext_completeHandler(event:Event):Void
	{
		this.completeOpen();
	}
	
}