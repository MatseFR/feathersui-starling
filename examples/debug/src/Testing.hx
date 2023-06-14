package;

import feathers.starling.controls.AutoSizeMode;
import feathers.starling.controls.Button;
import feathers.starling.controls.ButtonGroup;
import feathers.starling.controls.Check;
import feathers.starling.controls.ImageLoader;
import feathers.starling.controls.Label;
import feathers.starling.controls.LayoutGroup;
import feathers.starling.controls.ProgressBar;
import feathers.starling.controls.Radio;
import feathers.starling.controls.ScreenNavigator;
import feathers.starling.controls.ScrollContainer;
import feathers.starling.controls.Slider;
import feathers.starling.controls.StackScreenNavigator;
import feathers.starling.controls.TextInput;
import feathers.starling.controls.ToggleButton;
import feathers.starling.core.PropertyProxy;
import feathers.starling.core.PropertyProxyReal;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.HorizontalLayout;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.themes.MetalWorksDesktopTheme;
import feathers.starling.utils.math.MathUtils;
import feathers.starling.utils.type.ArgumentsCount;
import openfl.utils.Assets;
import starling.assets.AssetManager;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.Event;

/**
 * ...
 * @author Matse
 */
class Testing extends Sprite 
{

	public function new() 
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		//trace(ArgumentsCount.count_args(addedToStageHandler));
	}
	
	/**
	 * 
	 * @param	evt
	 */
	private function addedToStageHandler(evt:Event):Void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		feathersTest();
		//loadTest();
	}
	
	/**
	 * 
	 */
	private function feathersTest():Void
	{
		var theme:MetalWorksDesktopTheme = new MetalWorksDesktopTheme();
		
		//var navigator:ScreenNavigator = new ScreenNavigator();
		//var stackNavigator:StackScreenNavigator = new StackScreenNavigator();
		//var grp:ButtonGroup = new ButtonGroup();
		//var imgLoader:ImageLoader;
		//
		//var group:LayoutGroup = new LayoutGroup();
		//group.autoSizeMode = AutoSizeMode.STAGE;
		//addChild(group);
		//group.validate();
		//
		////var hLayout:HorizontalLayout = new HorizontalLayout();
		////hLayout.horizontalAlign = HorizontalAlign.CENTER;
		////hLayout.verticalAlign = VerticalAlign.MIDDLE;
		////group.layout = hLayout;
		//
		//var vLayout:VerticalLayout = new VerticalLayout();
		//vLayout.horizontalAlign = HorizontalAlign.CENTER;
		//vLayout.verticalAlign = VerticalAlign.MIDDLE;
		//vLayout.gap = 8;
		//group.layout = vLayout;
		//
		//var container:ScrollContainer = new ScrollContainer();
		//vLayout = new VerticalLayout();
		//vLayout.horizontalAlign = HorizontalAlign.CENTER;
		//vLayout.verticalAlign = VerticalAlign.MIDDLE;
		//vLayout.paddingLeft = vLayout.paddingRight = 8;
		//vLayout.gap = 24;
		//container.layout = vLayout;
		////var hLayout:HorizontalLayout = new HorizontalLayout();
		////hLayout.horizontalAlign = HorizontalAlign.CENTER;
		////hLayout.verticalAlign = VerticalAlign.MIDDLE;
		////hLayout.gap = 8;
		////container.layout = hLayout;
		//container.height = 100;
		//container.width = 180;
		//group.addChild(container);
		//
		//var label:Label = new Label();
		//label.text = "Hello World !";
		////label.height = 20;
		////label.width = 100;
		////label.x = 200;
		////label.y = 200;
		////addChild(label);
		////label.validate();
		//container.addChild(label);
		//
		//var quad:Quad = new Quad(50, 50);
		//container.addChild(quad);
		//
		//var btn:Button = new Button();
		//var test = btn.defaultLabelProperties;
		//trace(test);
		//btn.label = "yep";
		//container.addChild(btn);
		//
		//var toggle:ToggleButton = new ToggleButton();
		//toggle.label = "toggle";
		//container.addChild(toggle);
		//
		//var check:Check = new Check();
		//check.label = "check";
		//container.addChild(check);
		//
		//var radio:Radio = new Radio();
		//radio.label = "cool!";
		//container.addChild(radio);
		//
		//radio = new Radio();
		//radio.label = "nice!";
		//container.addChild(radio);
		//
		//var slider:Slider = new Slider();
		//slider.minimum = 0;
		//slider.maximum = 10;
		////slider.step = 1;
		//container.addChild(slider);
		//
		//var progress:ProgressBar = new ProgressBar();
		//progress.value = 0.5;
		//container.addChild(progress);
		//
		//var input:TextInput = new TextInput();
		//container.addChild(input);
	}
	
	private var assetManager:AssetManager;
	/**
	 * 
	 */
	private function loadTest():Void
	{
		assetManager = new AssetManager();
		//_assetMediator = new AssetMediator(assetManager);
		assetManager.enqueue([
			Assets.getPath("assets/img/metalworks_desktop.png"),
			Assets.getPath("assets/img/metalworks_desktop.xml")
		]);
		//assetManager.loadQueue(function(ratio:Float):Void {
			//if (ratio == 1) {
				//trace("Assets Loaded");
				//_sprite = new Sprite();
				//_sprite.addChild(new Image(assetManager.getTexture("header_text")));
				//addChild(_sprite);
				////onResize(null);
			//}
		//});
		assetManager.loadQueue(onComplete, onError, onProgress);
	}

	private function onComplete():Void
	{
		trace("complete");
		addChild(new Image(assetManager.getTexture("back-button-disabled-skin0000")));
	}

	private function onError(msg:String):Void
	{
		trace(msg);
	}

	private function onProgress(ratio:Float):Void
	{
		trace(ratio);
	}
	
}