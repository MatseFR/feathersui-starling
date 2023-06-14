package feathers.starling.examples.navigator;

import feathers.starling.controls.Drawers;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.controls.StackScreenNavigator;
import feathers.starling.controls.StackScreenNavigatorItem;
import feathers.starling.examples.navigator.screens.ScreenA;
import feathers.starling.examples.navigator.screens.ScreenB1;
import feathers.starling.examples.navigator.screens.ScreenB2;
import feathers.starling.examples.navigator.screens.ScreenC;
import feathers.starling.motion.Fade;
import feathers.starling.motion.Slide;
import feathers.starling.themes.MetalWorksDesktopTheme;
import feathers.starling.themes.MetalWorksMobileTheme;
import openfl.events.MouseEvent;
import starling.core.Starling;
import starling.events.Event;
import starling.events.ResizeEvent;

class Main extends LayoutGroup 
{
	private static inline var SCREEN_A:String = "a";
	private static inline var SCREEN_B1:String = "b1";
	private static inline var SCREEN_B2:String = "b2";
	private static inline var SCREEN_C:String = "c";
	
	public function new() 
	{
		//new MetalWorksDesktopTheme();
		new MetalWorksMobileTheme();
		super();
	}
	
	private var _navigator:StackScreenNavigator;
	
	override function initialize():Void
	{
		//super.initialize();
		
		this._navigator = new StackScreenNavigator();
		this._navigator.pushTransition = Slide.createSlideLeftTransition();
		this._navigator.popTransition = Slide.createSlideRightTransition();
		
		var itemA:StackScreenNavigatorItem = new StackScreenNavigatorItem(ScreenA);
		itemA.setScreenIDForPushEvent(Event.COMPLETE, SCREEN_B1);
		this._navigator.addScreen(SCREEN_A, itemA);
		
		var itemB1:StackScreenNavigatorItem = new StackScreenNavigatorItem(ScreenB1);
		itemB1.setScreenIDForPushEvent(Event.COMPLETE, SCREEN_C);
		itemB1.setScreenIDForReplaceEvent(Event.CHANGE, SCREEN_B2);
		itemB1.addPopEvent(Event.CANCEL);
		this._navigator.addScreen(SCREEN_B1, itemB1);
		
		var itemB2:StackScreenNavigatorItem = new StackScreenNavigatorItem(ScreenB2);
		itemB2.pushTransition = Fade.createFadeInTransition();
		itemB2.addPopEvent(Event.CANCEL);
		this._navigator.addScreen(SCREEN_B2, itemB2);
		
		var itemC:StackScreenNavigatorItem = new StackScreenNavigatorItem(ScreenC);
		itemC.addPopToRootEvent(Event.CLOSE);
		itemC.addPopEvent(Event.CANCEL);
		this._navigator.addScreen(SCREEN_C, itemC);
		
		this._navigator.rootScreenID = SCREEN_A;
		this.addChild(this._navigator);
		//this.content = this._navigator;
		
		this.stage.addEventListener(Event.RESIZE, stageResizeHandler);
	}
	
	private function stageResizeHandler(evt:ResizeEvent):Void
	{
		updateViewPort(evt.width, evt.height);
	}
	
	private function updateViewPort(width:Int, height:Int):Void
	{
		var current:Starling = Starling.current;
		var scale:Float = current.contentScaleFactor;
		
		stage.stageWidth = Std.int(width / scale);
		stage.stageHeight = Std.int(height / scale);
		
		current.viewPort.width = width;//stage.stageWidth * scale;
		current.viewPort.height = height;//stage.stageHeight * scale;
	}
}