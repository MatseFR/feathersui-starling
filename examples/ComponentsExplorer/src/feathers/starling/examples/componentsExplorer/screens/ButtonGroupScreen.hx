package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.ButtonGroup;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.data.ArrayCollection;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class ButtonGroupScreen extends PanelScreen 
{

	public function new() 
	{
		super();
	}
	
	private var _buttonGroup:ButtonGroup;
	
	override function initialize():Void 
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Button Group";
		
		this.layout = new AnchorLayout();
		
		this._buttonGroup = new ButtonGroup();
		this._buttonGroup.dataProvider = new ArrayCollection(
		[
			{ label: "One", triggered: button_triggeredHandler },
			{ label: "Two", triggered: button_triggeredHandler },
			{ label: "Three", triggered: button_triggeredHandler },
			{ label: "Four", triggered: button_triggeredHandler },
		]);
		var buttonGroupLayoutData:AnchorLayoutData = new AnchorLayoutData();
		buttonGroupLayoutData.horizontalCenter = 0;
		buttonGroupLayoutData.verticalCenter = 0;
		this._buttonGroup.layoutData = buttonGroupLayoutData;
		this.addChild(this._buttonGroup);
		
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

	private function button_triggeredHandler(event:Event):Void
	{
		var button:Button = cast event.currentTarget;
		trace(button.label + " triggered.");
	}
	
}