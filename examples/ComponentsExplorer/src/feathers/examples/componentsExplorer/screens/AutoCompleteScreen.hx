package feathers.examples.componentsExplorer.screens;

import feathers.controls.AutoComplete;
import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.PanelScreen;
import feathers.controls.ScrollPolicy;
import feathers.data.ArrayCollection;
import feathers.data.LocalAutoCompleteSource;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class AutoCompleteScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	private var _input:AutoComplete;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Auto-complete";
		
		var verticalLayout:VerticalLayout = new VerticalLayout();
		verticalLayout.horizontalAlign = HorizontalAlign.CENTER;
		verticalLayout.verticalAlign = VerticalAlign.TOP;
		verticalLayout.padding = 12;
		verticalLayout.gap = 8;
		this.layout = verticalLayout;
		
		this.verticalScrollPolicy = ScrollPolicy.ON;
		
		this._input = new AutoComplete();
		this._input.prompt = "Fruits. Type 'ap' to see suggestions";
		this._input.source = new LocalAutoCompleteSource(new ArrayCollection(
		[
			"Apple",
			"Apricot",
			"Banana",
			"Cantaloupe",
			"Cherry",
			"Grape",
			"Lemon",
			"Lime",
			"Mango",
			"Orange",
			"Peach",
			"Pineapple",
			"Plum",
			"Pomegranate",
			"Raspberry",
			"Strawberry",
			"Watermelon"
		]));
		this.addChild(this._input);
		
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
		return header;
	}

	private function onBackButton():Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}

	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
}