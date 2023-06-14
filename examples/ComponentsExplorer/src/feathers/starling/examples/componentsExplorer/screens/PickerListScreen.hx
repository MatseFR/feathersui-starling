package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.List;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.PickerList;
import feathers.starling.controls.SpinnerList;
import feathers.starling.controls.renderers.DefaultListItemRenderer;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.data.ArrayCollection;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class PickerListScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	private var _list:PickerList;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Picker List";
		
		this.layout = new AnchorLayout();
		
		var items:Array<Dynamic> = [];
		var item:Dynamic;
		for (i in 0...150)
		{
			item = {text: "Item " + (i + 1)};
			items[i] = item;
		}
		
		this._list = new PickerList();
		this._list.prompt = "Select an Item";
		this._list.dataProvider = new ArrayCollection(items);
		//normally, the first item is selected, but let's show the prompt
		this._list.selectedIndex = -1;
		var listLayoutData:AnchorLayoutData = new AnchorLayoutData();
		listLayoutData.horizontalCenter = 0;
		listLayoutData.verticalCenter = 0;
		this._list.layoutData = listLayoutData;
		this._list.addEventListener(Event.CHANGE, pickerList_changeHandler);
		this.addChildAt(this._list, 0);
		
		//the typical item helps us set an ideal width for the button
		//if we don't use a typical item, the button will resize to fit
		//the currently selected item.
		this._list.typicalItem = { text: "Select an Item" };
		this._list.labelField = "text";
		
		this._list.listFactory = function():List
		{
			var list:List;
			if (DeviceCapabilities.isPhone(Starling.current.nativeStage))
			{
				list = new SpinnerList();
			}
			else
			{
				list = new List();
			}
			//notice that we're setting typicalItem on the list separately. we
			//may want to have the list measure at a different width, so it
			//might need a different typical item than the picker list's button.
			list.typicalItem = { text: "Item 1000" };
			list.itemRendererFactory = function():IListItemRenderer
			{
				var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
				//notice that we're setting labelField on the item renderers
				//separately. the default item renderer has a labelField property,
				//but a custom item renderer may not even have a label, so
				//PickerList cannot simply pass its labelField down to item
				//renderers automatically
				renderer.labelField = "text";
				return renderer;
			};
			return list;
		};
		
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
	
	private function pickerList_changeHandler(event:Event):Void
	{
		trace("PickerList change:", this._list.selectedIndex);
	}
	
}