package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.DateTimeMode;
import feathers.starling.controls.Header;
import feathers.starling.controls.List;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.PickerList;
import feathers.starling.data.ArrayCollection;
import feathers.starling.examples.componentsExplorer.data.DateTimeSpinnerSettings;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import starling.display.DisplayObject;
import starling.events.Event;

class DateTimeSpinnerSettingsScreen extends PanelScreen 
{

	public function new() 
	{
		super();
	}
	
	public var settings:DateTimeSpinnerSettings;
	
	private var _list:List;
	private var _editingModePicker:PickerList;
	
	override public function dispose():Void
	{
		//icon and accessory display objects in the list's data provider
		//won't be automatically disposed because feathers cannot know if
		//they need to be used again elsewhere or not. we need to dispose
		//them manually.
		this._list.dataProvider.dispose(disposeItemAccessory);
		
		//never forget to call super.dispose() because you don't want to
		//create a memory leak!
		super.dispose();
	}
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Date Time Spinner Settings";
		
		this.layout = new AnchorLayout();
		
		this._editingModePicker = new PickerList();
		this._editingModePicker.dataProvider = new ArrayCollection(
		[
			DateTimeMode.DATE_AND_TIME,
			DateTimeMode.DATE,
			DateTimeMode.TIME,
		]);
		this._editingModePicker.selectedItem = this.settings.editingMode;
		this._editingModePicker.addEventListener(Event.CHANGE, editingModePicker_changeHandler);
		
		this._list = new List();
		this._list.isSelectable = false;
		this._list.dataProvider = new ArrayCollection(
		[
			{ label: "editingMode", accessory: this._editingModePicker },
		]);
		this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._list.clipContent = false;
		this._list.autoHideBackground = true;
		this.addChild(this._list);
		
		this.headerFactory = this.customHeaderFactory;
		
		this.backButtonHandler = this.onBackButton;
	}
	
	private function customHeaderFactory():Header
	{
		var header:Header = new Header();
		var doneButton:Button = new Button();
		doneButton.label = "Done";
		doneButton.addEventListener(Event.TRIGGERED, doneButton_triggeredHandler);
		header.rightItems = 
		[
			doneButton
		];
		return header;
	}

	private function disposeItemAccessory(item:Dynamic):Void
	{
		cast(item.accessory, DisplayObject).dispose();
	}

	private function onBackButton():Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}

	private function editingModePicker_changeHandler(event:Event):Void
	{
		this.settings.editingMode = this._editingModePicker.selectedItem;
	}

	private function doneButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
}