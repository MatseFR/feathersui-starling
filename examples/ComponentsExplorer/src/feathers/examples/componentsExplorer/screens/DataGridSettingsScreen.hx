package feathers.examples.componentsExplorer.screens;

import feathers.controls.Button;
import feathers.controls.Header;
import feathers.controls.List;
import feathers.controls.PanelScreen;
import feathers.controls.ToggleSwitch;
import feathers.data.ArrayCollection;
import feathers.examples.componentsExplorer.data.DataGridSettings;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.DisplayObject;
import starling.events.Event;

class DataGridSettingsScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	public var settings:DataGridSettings;
	
	private var _list:List;
	private var _sortableColumnsToggle:ToggleSwitch;
	private var _resizableColumnsToggle:ToggleSwitch;
	private var _reorderColumnsToggle:ToggleSwitch;
	
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
		
		this.title = "Data Grid Settings";
		
		this.layout = new AnchorLayout();
		
		this._sortableColumnsToggle = new ToggleSwitch();
		this._sortableColumnsToggle.isSelected = this.settings.sortableColumns;
		this._sortableColumnsToggle.addEventListener(Event.CHANGE, sortableColumnsToggle_changeHandler);
		
		this._resizableColumnsToggle = new ToggleSwitch();
		this._resizableColumnsToggle.isSelected = this.settings.resizableColumns;
		this._resizableColumnsToggle.addEventListener(Event.CHANGE, resizableColumnsToggle_changeHandler);
		
		this._reorderColumnsToggle = new ToggleSwitch();
		this._reorderColumnsToggle.isSelected = this.settings.reorderColumns;
		this._reorderColumnsToggle.addEventListener(Event.CHANGE, reorderColumnsToggle_changeHandler);
		
		this._list = new List();
		this._list.isSelectable = false;
		this._list.dataProvider = new ArrayCollection(
		[
			{ label: "Sortable Columns", accessory: this._sortableColumnsToggle },
			{ label: "Resizable Columns", accessory: this._resizableColumnsToggle },
			{ label: "Reorder Columns", accessory: this._reorderColumnsToggle },
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
	
	private function reorderColumnsToggle_changeHandler(event:Event):Void
	{
		this.settings.reorderColumns = this._reorderColumnsToggle.isSelected;
	}
	
	private function resizableColumnsToggle_changeHandler(event:Event):Void
	{
		this.settings.resizableColumns = this._resizableColumnsToggle.isSelected;
	}
	
	private function sortableColumnsToggle_changeHandler(event:Event):Void
	{
		this.settings.sortableColumns = this._sortableColumnsToggle.isSelected;
	}
	
	private function doneButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
}