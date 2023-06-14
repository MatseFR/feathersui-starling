package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.ButtonGroup;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.Toast;
import feathers.starling.data.ArrayCollection;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class ToastScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	private var _showToastButtons:ButtonGroup;

	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Toast";
		
		this.layout = new AnchorLayout();
		
		this._showToastButtons = new ButtonGroup();
		this._showToastButtons.dataProvider = new ArrayCollection(
		[
			{ label: "Show Toast with Message", triggered: showMessageButton_triggeredHandler },
			{ label: "Show Toast with Actions", triggered: showActionsButton_triggeredHandler },
		]);
		var buttonGroupLayoutData:AnchorLayoutData = new AnchorLayoutData();
		buttonGroupLayoutData.horizontalCenter = 0;
		buttonGroupLayoutData.verticalCenter = 0;
		this._showToastButtons.layoutData = buttonGroupLayoutData;
		this.addChild(this._showToastButtons);
		
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
	
	private function showMessageButton_triggeredHandler(event:Event):Void
	{
		Toast.showMessage("Hi, there!");
	}

	private function showActionsButton_triggeredHandler(event:Event):Void
	{
		Toast.showMessageWithActions("I have an action", new ArrayCollection(
		[
			{ label: "Neat!" }
		]));
	}
	
	private function alert_closeHandler(event:Event, data:Dynamic):Void
	{
		if (data != null)
		{
			trace("alert closed with item:", data.label);
		}
		else
		{
			trace("alert closed without item");
		}
	}
	
}