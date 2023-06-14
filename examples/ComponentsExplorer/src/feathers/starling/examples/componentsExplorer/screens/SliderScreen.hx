package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.Slider;
import feathers.starling.examples.componentsExplorer.data.SliderSettings;
import feathers.starling.layout.Direction;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.HorizontalLayout;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class SliderScreen extends PanelScreen 
{
	public static inline var SHOW_SETTINGS:String = "showSettings";
	
	public function new() 
	{
		super();
	}
	
	public var settings:SliderSettings;
	
	private var _horizontalSlider:Slider;
	private var _verticalSlider:Slider;
	
	override function initialize():Void 
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Slider";
		
		var layout:HorizontalLayout = new HorizontalLayout();
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.verticalAlign = VerticalAlign.MIDDLE;
		layout.padding = 12;
		layout.gap = 12;
		this.layout = layout;
		
		this._horizontalSlider = new Slider();
		this._horizontalSlider.direction = Direction.HORIZONTAL;
		this._horizontalSlider.minimum = 0;
		this._horizontalSlider.maximum = 100;
		this._horizontalSlider.value = 50;
		this._horizontalSlider.step = this.settings.step;
		this._horizontalSlider.page = this.settings.page;
		this._horizontalSlider.liveDragging = this.settings.liveDragging;
		this._horizontalSlider.trackInteractionMode = this.settings.trackInteractionMode;
		this._horizontalSlider.addEventListener(Event.CHANGE, horizontalSlider_changeHandler);
		this.addChild(this._horizontalSlider);
		
		this._verticalSlider = new Slider();
		this._verticalSlider.direction = Direction.VERTICAL;
		this._verticalSlider.minimum = 0;
		this._verticalSlider.maximum = 100;
		this._verticalSlider.value = 50;
		this._verticalSlider.step = this.settings.step;
		this._verticalSlider.page = this.settings.page;
		this._verticalSlider.liveDragging = this.settings.liveDragging;
		this._verticalSlider.trackInteractionMode = this.settings.trackInteractionMode;
		this.addChild(this._verticalSlider);
		
		this.headerFactory = this.customHeaderFactory;
		
		//this screen doesn't use a back button on tablets because the main
		//app's uses a split layout
		if (!DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			this.backButtonHandler = this.onBackButton;
		}
	}
	
	private function customHeaderFactory():Header
	{
		var header:Header = new Header();
		//this screen doesn't use a back button on tablets because the main
		//app's uses a split layout
		if (!DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			var backButton:Button = new Button();
			backButton.styleNameList.add(Button.ALTERNATE_STYLE_NAME_BACK_BUTTON);
			backButton.label = "Back";
			backButton.addEventListener(Event.TRIGGERED, backButton_triggeredHandler);
			header.leftItems = 
			[
				backButton
			];
		}
		
		var settingsButton:Button = new Button();
		settingsButton.label = "Settings";
		settingsButton.addEventListener(Event.TRIGGERED, settingsButton_triggeredHandler);
		header.rightItems = 
		[
			settingsButton
		];
		return header;
	}
	
	private function onBackButton():Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}
	
	private function horizontalSlider_changeHandler(event:Event):Void
	{
		trace("horizontal slider change:", Std.string(this._horizontalSlider.value));
	}
	
	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
	private function settingsButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(SHOW_SETTINGS);
	}
	
}