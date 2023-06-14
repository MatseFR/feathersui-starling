package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.List;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.ToggleSwitch;
import feathers.starling.data.ArrayCollection;
import feathers.starling.examples.componentsExplorer.data.ListSettings;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import starling.display.DisplayObject;
import starling.events.Event;

class ListSettingsScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	public var settings:ListSettings;
	
	private var _list:List;
	
	private var _isSelectableToggle:ToggleSwitch;
	private var _allowMultipleSelectionToggle:ToggleSwitch;
	private var _hasElasticEdgesToggle:ToggleSwitch;
	
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
		
		this.title = "List Settings";
		
		this.layout = new AnchorLayout();
		
		this._isSelectableToggle = new ToggleSwitch();
		this._isSelectableToggle.isSelected = this.settings.isSelectable;
		this._isSelectableToggle.addEventListener(Event.CHANGE, isSelectableToggle_changeHandler);
		
		this._allowMultipleSelectionToggle = new ToggleSwitch();
		this._allowMultipleSelectionToggle.isSelected = this.settings.allowMultipleSelection;
		this._allowMultipleSelectionToggle.addEventListener(Event.CHANGE, allowMultipleSelectionToggle_changeHandler);
		
		this._hasElasticEdgesToggle = new ToggleSwitch();
		this._hasElasticEdgesToggle.isSelected = this.settings.hasElasticEdges;
		this._hasElasticEdgesToggle.addEventListener(Event.CHANGE, hasElasticEdgesToggle_changeHandler);
		
		this._list = new List();
		this._list.isSelectable = false;
		this._list.dataProvider = new ArrayCollection(
		[
			{ label: "isSelectable", accessory: this._isSelectableToggle },
			{ label: "allowMultipleSelection", accessory: this._allowMultipleSelectionToggle },
			{ label: "hasElasticEdges", accessory: this._hasElasticEdgesToggle },
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

	private function doneButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}

	private function isSelectableToggle_changeHandler(event:Event):Void
	{
		this.settings.isSelectable = this._isSelectableToggle.isSelected;
	}

	private function allowMultipleSelectionToggle_changeHandler(event:Event):Void
	{
		this.settings.allowMultipleSelection = this._allowMultipleSelectionToggle.isSelected;
	}

	private function hasElasticEdgesToggle_changeHandler(event:Event):Void
	{
		this.settings.hasElasticEdges = this._hasElasticEdgesToggle.isSelected;
	}
	
}