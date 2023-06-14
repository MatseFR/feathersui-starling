/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.controls.popups;

import feathers.starling.core.PopUpManager;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.Panel;
import feathers.starling.utils.display.DisplayUtils;
import feathers.starling.utils.geom.GeomUtils;
import openfl.errors.IllegalOperationError;
import openfl.events.KeyboardEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Stage;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.events.ResizeEvent;
import starling.events.Touch;
import starling.events.TouchEvent;
import starling.events.TouchPhase;
import starling.utils.Pool;

/**
 * Displays pop-up content as a mobile-style drawer that opens from the
 * bottom of the stage.
 *
 * @productversion Feathers 2.3.0
 */
class BottomDrawerPopUpContentManager extends EventDispatcher implements IPersistentPopUpContentManager implements IPopUpContentManagerWithPrompt
{
	/**
	 * @private
	 */
	private static function defaultPanelFactory():Panel
	{
		return new Panel();
	}

	/**
	 * @private
	 */
	private static function defaultCloseButtonFactory():Button
	{
		return new Button();
	}
	
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
	private var panel:Panel;
	
	/**
	 * @private
	 */
	private var content:DisplayObject;
	
	/**
	 * @private
	 */
	private var isClosing:Bool = false;
	
	/**
	 * @inheritDoc
	 */
	public var isOpen(get, never):Bool;
	private function get_isOpen():Bool { return this.content != null; }
	
	/**
	 * Creates the <code>Panel</code> that wraps the content.
	 *
	 * <p>In the following example, a custom panel factory is provided:</p>
	 *
	 * <listing version="3.0">
	 * manager.panelFactory = function():Panel
	 * {
	 *     var panel:Panel = new Panel();
	 *     panel.backgroundSkin = new Image( texture );
	 *     return panel;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Panel
	 */
	public var panelFactory:Void->Panel = null;
	
	/**
	 * Adds a style name to the <code>Panel</code> that wraps the content.
	 *
	 * <p>In the following example, a custom style name is provided:</p>
	 *
	 * <listing version="3.0">
	 * manager.customPanelStyleName = "my-custom-pop-up-panel";</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Panel
	 */
	public var customPanelStyleName:String = null;
	
	/**
	 * Creates the <code>Button</code> that closes the pop-up.
	 *
	 * <p>In the following example, a custom close button factory is provided:</p>
	 *
	 * <listing version="3.0">
	 * manager.closeButtonFactory = function():Button
	 * {
	 *     var closeButton:Button = new Button();
	 *     closeButton.defaultSkin = new Image( texture );
	 *     return closeButton;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
	 */
	public var closeButtonFactory:Void->Button = null;

	/**
	 * Adds a style name to the close button.
	 *
	 * <p>In the following example, a custom style name is provided:</p>
	 *
	 * <listing version="3.0">
	 * manager.customCloseButtonStyleName = "my-custom-close-button";</listing>
	 *
	 * @default null
	 *
	 * @see feathers.controls.Button
	 */
	public var customCloseButtonStyleName:String = null;
	
	/**
	 * A prompt to display in the panel's title.
	 *
	 * <p>Note: If using this manager with a component that has its own
	 * prompt (like <code>PickerList</code>), this value may be overridden
	 * by the component.</p>
	 *
	 * <p>In the following example, a custom title is provided:</p>
	 *
	 * <listing version="3.0">
	 * manager.prompt = "Pick a value";</listing>
	 *
	 * @default null
	 */
	public var prompt(get, set):String;
	private var _prompt:String;
	private function get_prompt():String { return this._prompt; }
	private function set_prompt(value:String):String
	{
		return this._prompt = value;
	}
	
	/**
	 * The text to display in the label of the close button.
	 *
	 * <p>In the following example, a custom close button label is provided:</p>
	 *
	 * <listing version="3.0">
	 * manager.closeButtonLabel = "Save";</listing>
	 *
	 * @default "Done"
	 */
	public var closeButtonLabel(get, set):String;
	private var _closeButtonLabel:String = "Done";
	private function get_closeButtonLabel():String { return this._closeButtonLabel; }
	private function set_closeButtonLabel(value:String):String
	{
		return this._closeButtonLabel = value;
	}
	
	/**
	 * The duration, in seconds, of the animation to open or close the
	 * pop-up.
	 *
	 * <p>In the following example, the duration is changed to 2 seconds:</p>
	 *
	 * <listing version="3.0">
	 * manager.openOrCloseDuration = 2.0;</listing>
	 *
	 * @default 0.5
	 */
	public var openOrCloseDuration(get, set):Float;
	private var _openOrCloseDuration:Float = 0.5;
	private function get_openOrCloseDuration():Float { return this._openOrCloseDuration; }
	private function set_openOrCloseDuration(value:Float):Float
	{
		return this._openOrCloseDuration = value;
	}
	
	/**
	 * The easing function used for opening or closing the pop-up.
	 *
	 * <p>In the following example, the animation ease is changed:</p>
	 *
	 * <listing version="3.0">
	 * manager.openOrCloseEase = Transitions.EASE_IN_OUT;</listing>
	 *
	 * @default starling.animation.Transitions.EASE_OUT
	 *
	 * @see http://doc.starling-framework.org/core/starling/animation/Transitions.html starling.animation.Transitions
	 * @see #openOrCloseDuration
	 */
	public var openOrCloseEase(get, set):Dynamic;
	private var _openOrCloseEase:Dynamic = Transitions.EASE_OUT;
	private function get_openOrCloseEase():Dynamic { return this._openOrCloseEase; }
	private function set_openOrCloseEase(value:Dynamic):Dynamic
	{
		return this._openOrCloseEase = value;
	}
	
	/**
	 * This function may be used to customize the modal overlay displayed by
	 * the pop-up manager. If the value of <code>overlayFactory</code> is
	 * <code>null</code>, the pop-up manager's default overlay factory will
	 * be used instead.
	 *
	 * <p>This function is expected to have the following signature:</p>
	 * <pre>function():DisplayObject</pre>
	 *
	 * <p>In the following example, the overlay is customized:</p>
	 *
	 * <listing version="3.0">
	 * manager.overlayFactory = function():DisplayObject
	 * {
	 *     var quad:Quad = new Quad(1, 1, 0xff00ff);
	 *     quad.alpha = 0;
	 *     return quad;
	 * };</listing>
	 *
	 * @default null
	 *
	 * @see feathers.core.PopUpManager#overlayFactory
	 */
	public var overlayFactory(get, set):Void->DisplayObject;
	private var _overlayFactory:Void->DisplayObject;
	private function get_overlayFactory():Void->DisplayObject { return this._overlayFactory; }
	private function set_overlayFactory(value:Void->DisplayObject):Void->DisplayObject
	{
		return this._overlayFactory = value;
	}
	
	/**
	 * @private
	 */
	private var touchPointID:Int = -1;

	/**
	 * @private
	 */
	private var openTween:Tween;

	/**
	 * @private
	 */
	private var closeTween:Tween;
	
	/**
	 * @inheritDoc
	 */
	public function open(content:DisplayObject, source:DisplayObject):Void
	{
		if (this.isOpen)
		{
			throw new IllegalOperationError("Pop-up content is already open. Close the previous content before opening new content.");
		}
		
		this.content = content;
		
		var layout:VerticalLayout = new VerticalLayout();
		layout.horizontalAlign = HorizontalAlign.JUSTIFY;
		
		var panelFactory:Void->Panel = this.panelFactory != null ? this.panelFactory : defaultPanelFactory;
		this.panel = panelFactory();
		if (this.customPanelStyleName != null)
		{
			this.panel.styleNameList.add(this.customPanelStyleName);
		}
		this.panel.title = this._prompt;
		this.panel.layout = layout;
		this.panel.headerFactory = headerFactory;
		this.panel.touchable = false;
		this.panel.addChild(content);
		
		//make sure the content is scaled the same as the source
		var matrix:Matrix = Pool.getMatrix();
		source.getTransformationMatrix(PopUpManager.root, matrix);
		panel.scaleX = GeomUtils.matrixToScaleX(matrix);
		panel.scaleY = GeomUtils.matrixToScaleY(matrix);
		Pool.putMatrix(matrix);
		
		PopUpManager.addPopUp(this.panel, true, false, this._overlayFactory);
		this.layout();
		
		this.panel.addEventListener(Event.REMOVED_FROM_STAGE, panel_removedFromStageHandler);
		
		var stage:Stage = Starling.current.stage;
		stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		stage.addEventListener(ResizeEvent.RESIZE, stage_resizeHandler);
		
		//using priority here is a hack so that objects higher up in the
		//display list have a chance to cancel the event first.
		var priority:Int = -DisplayUtils.getDisplayObjectDepthFromStage(this.panel);
		Starling.current.nativeStage.addEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler, false, priority, true);
		
		this.panel.y = this.panel.stage.stageHeight;
		this.openTween = new Tween(this.panel, this.openOrCloseDuration, this.openOrCloseEase);
		this.openTween.moveTo(0, this.panel.stage.stageHeight - this.panel.height);
		this.openTween.onComplete = openTween_onComplete;
		Starling.currentJuggler.add(this.openTween);
	}
	
	/**
	 * @inheritDoc
	 */
	public function close():Void
	{
		if (!this.isOpen || this.isClosing)
		{
			return;
		}
		
		if (this.openTween != null)
		{
			Starling.currentJuggler.remove(this.openTween);
			this.openTween = null;
		}
		if (this.content.stage != null)
		{
			this.isClosing = true;
			this.panel.touchable = false;
			this.closeTween = new Tween(this.panel, this.openOrCloseDuration, this.openOrCloseEase);
			this.closeTween.moveTo(0, this.panel.stage.stageHeight);
			this.closeTween.onComplete = closeTween_onComplete;
			Starling.currentJuggler.add(this.closeTween);
		}
		else
		{
			this.cleanup();
			this.dispatchEventWith(Event.CLOSE);
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function dispose():Void
	{
		this.close();
	}
	
	/**
	 * @private
	 */
	private function headerFactory():Header
	{
		var header:Header = new Header();
		var closeButtonFactory:Void->Button = this.closeButtonFactory != null ? this.closeButtonFactory : defaultCloseButtonFactory;
		var closeButton:Button = closeButtonFactory();
		if (this.customCloseButtonStyleName != null)
		{
			closeButton.styleNameList.add(this.customCloseButtonStyleName);
		}
		closeButton.label = this.closeButtonLabel;
		closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
		header.rightItems = [closeButton];
		return header;
	}
	
	/**
	 * @private
	 */
	private function layout():Void
	{
		this.panel.width = this.panel.stage.stageWidth;
		this.panel.x = 0;
		this.panel.maxHeight = this.panel.stage.stageHeight;
		this.panel.validate();
		this.panel.y = this.panel.stage.stageHeight - this.panel.height;
	}
	
	/**
	 * @private
	 */
	private function cleanup():Void
	{
		var stage:Stage = Starling.current.stage;
		stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
		stage.removeEventListener(ResizeEvent.RESIZE, stage_resizeHandler);
		Starling.current.nativeStage.removeEventListener(KeyboardEvent.KEY_DOWN, nativeStage_keyDownHandler);
		
		if (this.panel != null)
		{
			this.panel.removeEventListener(Event.REMOVED_FROM_STAGE, panel_removedFromStageHandler);
			if (this.panel.contains(this.content))
			{
				this.panel.removeChild(this.content, false);
			}
			this.panel.removeFromParent(true);
			this.panel = null;
		}
		this.content = null;
	}
	
	/**
	 * @private
	 */
	private function openTween_onComplete():Void
	{
		this.openTween = null;
		this.panel.touchable = true;
		this.dispatchEventWith(Event.OPEN);
	}

	/**
	 * @private
	 */
	private function closeTween_onComplete():Void
	{
		this.isClosing = false;
		this.closeTween = null;
		this.cleanup();
		this.dispatchEventWith(Event.CLOSE);
	}
	
	/**
	 * @private
	 */
	private function closeButton_triggeredHandler(event:Event):Void
	{
		this.close();
	}

	/**
	 * @private
	 */
	private function panel_removedFromStageHandler(event:Event):Void
	{
		this.close();
	}
	
	/**
	 * @private
	 */
	private function nativeStage_keyDownHandler(event:KeyboardEvent):Void
	{
		if (event.isDefaultPrevented())
		{
			//someone else already handled this one
			return;
		}
		// TODO : Keyboard.BACK only exists on flash target
		if (#if flash event.keyCode != Keyboard.BACK && #end event.keyCode != Keyboard.ESCAPE)
		{
			return;
		}
		//don't let the OS handle the event
		event.preventDefault();
		
		this.close();
	}
	
	/**
	 * @private
	 */
	private function stage_resizeHandler(event:ResizeEvent):Void
	{
		if (this.closeTween != null)
		{
			this.closeTween.advanceTime(this.closeTween.totalTime);
			//the onComplete callback will remove the panel, so no layout is
			//required.
			return;
		}
		
		if (this.openTween != null)
		{
			//just stop the animation and go to the final layout
			Starling.currentJuggler.remove(this.openTween);
			this.openTween = null;
		}
		this.layout();
	}
	
	/**
	 * @private
	 */
	private function stage_touchHandler(event:TouchEvent):Void
	{
		if (!PopUpManager.isTopLevelPopUp(this.panel))
		{
			return;
		}
		var stage:Stage = Starling.current.stage;
		var touch:Touch;
		var point:Point;
		var hitTestResult:DisplayObject;
		if (this.touchPointID >= 0)
		{
			touch = event.getTouch(stage, TouchPhase.ENDED, this.touchPointID);
			if (touch == null)
			{
				return;
			}
			point = Pool.getPoint();
			touch.getLocation(stage, point);
			hitTestResult = stage.hitTest(point);
			Pool.putPoint(point);
			if (!this.panel.contains(hitTestResult))
			{
				this.touchPointID = -1;
				this.close();
			}
		}
		else
		{
			touch = event.getTouch(stage, TouchPhase.BEGAN);
			if (touch == null)
			{
				return;
			}
			point = Pool.getPoint();
			touch.getLocation(stage, point);
			hitTestResult = stage.hitTest(point);
			Pool.putPoint(point);
			if (this.panel.contains(hitTestResult))
			{
				return;
			}
			this.touchPointID = touch.id;
		}
	}
	
}