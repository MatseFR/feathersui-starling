package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Check;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.ScrollPolicy;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.layout.VerticalLayout;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class CheckScreen extends PanelScreen 
{

	public function new() 
	{
		super();
	}
	
	private var _check:Check;
	private var _checked:Check;
	private var _disabled:Check;
	private var _selectedDisabled:Check;
	
	override function initialize():Void 
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Check";
		
		var verticalLayout:VerticalLayout = new VerticalLayout();
		verticalLayout.horizontalAlign = HorizontalAlign.LEFT;
		verticalLayout.verticalAlign = VerticalAlign.TOP;
		verticalLayout.padding = 12;
		verticalLayout.gap = 8;
		this.layout = verticalLayout;
		
		this.verticalScrollPolicy = ScrollPolicy.ON;
		
		this._check = new Check();
		this._check.label = "Default";
		this._check.addEventListener(Event.CHANGE, check_changeHandler);
		this.addChild(this._check);
		
		this._checked = new Check();
		this._checked.label = "Selected";
		this._checked.isSelected = true;
		this.addChild(this._checked);
		
		this._disabled = new Check();
		this._disabled.label = "Disabled";
		this._disabled.isEnabled = false;
		this.addChild(this._disabled);
		
		this._selectedDisabled = new Check();
		this._selectedDisabled.label = "Selected and Disabled";
		this._selectedDisabled.isSelected = true;
		this._selectedDisabled.isEnabled = false;
		this.addChild(this._selectedDisabled);
		
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

	private function check_changeHandler(event:Event):Void
	{
		trace("check changed:", this._check.isSelected);
	}

	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
}