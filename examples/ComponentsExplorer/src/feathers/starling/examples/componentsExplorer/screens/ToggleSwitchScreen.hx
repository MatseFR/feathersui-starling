package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.ToggleSwitch;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.TiledRowsLayout;
import feathers.starling.layout.VerticalAlign;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class ToggleSwitchScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	private var _toggle:ToggleSwitch;
	private var _selected:ToggleSwitch;
	private var _disabled:ToggleSwitch;
	private var _selectedDisabled:ToggleSwitch;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Toggle Switch";
		
		var layout:TiledRowsLayout = new TiledRowsLayout();
		layout.requestedColumnCount = 2;
		layout.useSquareTiles = false;
		layout.horizontalAlign = HorizontalAlign.CENTER;
		layout.verticalAlign = VerticalAlign.TOP;
		layout.tileHorizontalAlign = HorizontalAlign.CENTER;
		layout.tileVerticalAlign = VerticalAlign.TOP;
		layout.padding = 12;
		layout.horizontalGap = 12;
		layout.verticalGap = 44;
		this.layout = layout;
		
		this._toggle = new ToggleSwitch();
		this._toggle.addEventListener(Event.CHANGE, toggleSwitch_changeHandler);
		this.addChild(this._toggle);
		
		this._selected = new ToggleSwitch();
		this._selected.isSelected = true;
		this.addChild(this._selected);
		
		this._disabled = new ToggleSwitch();
		this._disabled.isEnabled = false;
		this.addChild(this._disabled);
		
		this._selectedDisabled = new ToggleSwitch();
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

	private function toggleSwitch_changeHandler(event:Event):Void
	{
		trace("toggle switch changed:", this._toggle.isSelected);
	}

	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
}