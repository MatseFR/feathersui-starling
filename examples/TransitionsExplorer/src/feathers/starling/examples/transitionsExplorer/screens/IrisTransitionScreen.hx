package feathers.starling.examples.transitionsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.List;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.renderers.DefaultListItemRenderer;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.data.ArrayCollection;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.motion.Iris;
import haxe.Constraints.Function;
import starling.display.DisplayObject;
import starling.events.Event;

class IrisTransitionScreen extends PanelScreen 
{
	private static function irisCloseAtRandomPosition(oldScreen:DisplayObject, newScreen:DisplayObject, completeCallback:Function):Void
	{
		var randomX:Float = Math.random() * (oldScreen != null ? oldScreen.width : newScreen.width);
		var randomY:Float = Math.random() * (oldScreen != null ? oldScreen.height : newScreen.height);
		#if neko
		var func:Function = Iris.createIrisCloseTransitionAt(randomX, randomY);
		Reflect.callMethod(func, func, [oldScreen, newScreen, completeCallback]);
		#else
		Iris.createIrisCloseTransitionAt(randomX, randomY)(oldScreen, newScreen, completeCallback);
		#end
	}
	
	private static function irisOpenAtRandomPosition(oldScreen:DisplayObject, newScreen:DisplayObject, completeCallback:Function):Void
	{
		var randomX:Float = Math.random() * (oldScreen != null ? oldScreen.width : newScreen.width);
		var randomY:Float = Math.random() * (oldScreen != null ? oldScreen.height : newScreen.height);
		#if neko
		var func:Function = Iris.createIrisOpenTransitionAt(randomX, randomY);
		Reflect.callMethod(func, func, [oldScreen, newScreen, completeCallback]);
		#else
		Iris.createIrisOpenTransitionAt(randomX, randomY)(oldScreen, newScreen, completeCallback);
		#end
	}
	
	public static inline var TRANSITION:String = "transition";
	
	public function new() 
	{
		super();
	}
	
	private var _list:List;
	private var _backButton:Button;

	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Iris";
		
		this.layout = new AnchorLayout();
		
		this._list = new List();
		this._list.dataProvider = new ArrayCollection(
		[
			{ label: "Iris Open", transition: Iris.createIrisOpenTransition() },
			{ label: "Iris Close", transition: Iris.createIrisCloseTransition() },
			{ label: "Iris Open At", transition: irisOpenAtRandomPosition },
			{ label: "Iris Close At", transition: irisCloseAtRandomPosition },
		]);
		this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._list.clipContent = false;
		this._list.autoHideBackground = true;
		
		this._list.itemRendererFactory = function():IListItemRenderer
		{
			var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
			
			//enable the quick hit area to optimize hit tests when an item
			//is only selectable and doesn't have interactive children.
			renderer.isQuickHitAreaEnabled = true;
			
			renderer.labelField = "label";
			
			renderer.accessoryLabelField = "accessory";
			return renderer;
		};
		
		this._list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
		this._list.revealScrollBars();
		this.addChild(this._list);
		
		this.headerFactory = this.customHeaderFactory;
	}
	
	private function customHeaderFactory():Header
	{
		var header:Header = new Header();
		
		this._backButton = new Button();
		this._backButton.styleNameList.add(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON);
		this._backButton.label = "Transitions";
		this._backButton.addEventListener(Event.TRIGGERED, backButton_triggeredHandler);
		header.leftItems = [this._backButton];
		
		return header;
	}

	private function list_triggeredHandler(event:Event, item:Dynamic):Void
	{
		var transition:Function = item.transition;
		this.dispatchEventWith(TRANSITION, false, transition);
	}

	private function backButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}
}