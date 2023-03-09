package feathers.examples.componentsExplorer.screens;

import feathers.controls.Button;
import feathers.controls.GroupedList;
import feathers.controls.Header;
import feathers.controls.ItemRendererLayoutOrder;
import feathers.controls.PanelScreen;
import feathers.controls.PickerList;
import feathers.controls.ToggleSwitch;
import feathers.data.ArrayCollection;
import feathers.data.ArrayHierarchicalCollection;
import feathers.examples.componentsExplorer.data.ItemRendererSettings;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;
import starling.display.DisplayObject;
import starling.events.Event;

class ItemRendererSettingsScreen extends PanelScreen 
{
	private static inline var GAP_LABEL_INFINITE:String = "Fill Available Space";
	private static inline var GAP_LABEL_DEFAULT:String = "No Fill";
	
	public function new() 
	{
		super();
	}
	
	public var settings:ItemRendererSettings;
	
	private var _list:GroupedList;
	private var _gapPicker:PickerList;
	private var _hasIconToggle:ToggleSwitch;
	private var _hasAccessoryToggle:ToggleSwitch;
	private var _layoutOrderPicker:PickerList;
	private var _iconPositionPicker:PickerList;
	private var _iconTypePicker:PickerList;
	private var _accessoryPositionPicker:PickerList;
	private var _accessoryTypePicker:PickerList;
	private var _accessoryGapPicker:PickerList;
	private var _horizontalAlignPicker:PickerList;
	private var _verticalAlignPicker:PickerList;
	
	override public function dispose():Void
	{
		//icon and accessory display objects in the list's data provider
		//won't be automatically disposed because feathers cannot know if
		//they need to be used again elsewhere or not. we need to dispose
		//them manually.
		this._list.dataProvider.dispose(null, disposeItemAccessory);
		
		//never forget to call super.dispose() because you don't want to
		//create a memory leak!
		super.dispose();
	}
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Item Renderer Settings";
		
		this.layout = new AnchorLayout();
		
		this._hasIconToggle = new ToggleSwitch();
		this._hasIconToggle.isSelected = this.settings.hasIcon;
		this._hasIconToggle.addEventListener(Event.CHANGE, hasIconToggle_changeHandler);
		
		this._iconTypePicker = new PickerList();
		this._iconTypePicker.typicalItem = ItemRendererSettings.ICON_ACCESSORY_TYPE_DISPLAY_OBJECT;
		this._iconTypePicker.dataProvider = new ArrayCollection(
		[
			ItemRendererSettings.ICON_ACCESSORY_TYPE_DISPLAY_OBJECT,
			ItemRendererSettings.ICON_ACCESSORY_TYPE_TEXTURE,
			ItemRendererSettings.ICON_ACCESSORY_TYPE_LABEL,
		]);
		this._iconTypePicker.listProperties.typicalItem = ItemRendererSettings.ICON_ACCESSORY_TYPE_DISPLAY_OBJECT;
		this._iconTypePicker.selectedItem = this.settings.iconType;
		this._iconTypePicker.addEventListener(Event.CHANGE, iconTypePicker_changeHandler);
		
		this._iconPositionPicker = new PickerList();
		this._iconPositionPicker.typicalItem = RelativePosition.RIGHT_BASELINE;
		this._iconPositionPicker.dataProvider = new ArrayCollection(
		[
			RelativePosition.TOP,
			RelativePosition.RIGHT,
			RelativePosition.BOTTOM,
			RelativePosition.LEFT,
			RelativePosition.LEFT_BASELINE,
			RelativePosition.RIGHT_BASELINE,
			//RelativePosition.MANUAL,
		]);
		this._iconPositionPicker.listProperties.typicalItem = RelativePosition.RIGHT_BASELINE;
		this._iconPositionPicker.selectedItem = this.settings.iconPosition;
		this._iconPositionPicker.addEventListener(Event.CHANGE, iconPositionPicker_changeHandler);
		
		this._gapPicker = new PickerList();
		this._gapPicker.dataProvider = new ArrayCollection(
		[
			{ label: GAP_LABEL_INFINITE, value: true },
			{ label: GAP_LABEL_DEFAULT, value: false },
		]);
		this._gapPicker.typicalItem = this._gapPicker.dataProvider.getItemAt(0);
		this._gapPicker.listProperties.typicalItem = this._gapPicker.dataProvider.getItemAt(0);
		this._gapPicker.selectedItem = this._gapPicker.dataProvider.getItemAt(this.settings.useInfiniteGap ? 0 : 1);
		this._gapPicker.addEventListener(Event.CHANGE, gapPicker_changeHandler);
		
		this._hasAccessoryToggle = new ToggleSwitch();
		this._hasAccessoryToggle.isSelected = this.settings.hasAccessory;
		this._hasAccessoryToggle.addEventListener(Event.CHANGE, hasAccessoryToggle_changeHandler);
		
		this._accessoryTypePicker = new PickerList();
		this._accessoryTypePicker.typicalItem = ItemRendererSettings.ICON_ACCESSORY_TYPE_DISPLAY_OBJECT;
		this._accessoryTypePicker.dataProvider = new ArrayCollection(
		[
			ItemRendererSettings.ICON_ACCESSORY_TYPE_DISPLAY_OBJECT,
			ItemRendererSettings.ICON_ACCESSORY_TYPE_TEXTURE,
			ItemRendererSettings.ICON_ACCESSORY_TYPE_LABEL,
		]);
		this._accessoryTypePicker.listProperties.typicalItem = ItemRendererSettings.ICON_ACCESSORY_TYPE_DISPLAY_OBJECT;
		this._accessoryTypePicker.selectedItem = this.settings.accessoryType;
		this._accessoryTypePicker.addEventListener(Event.CHANGE, accessoryTypePicker_changeHandler);
		
		this._accessoryPositionPicker = new PickerList();
		this._accessoryPositionPicker.typicalItem = RelativePosition.BOTTOM;
		this._accessoryPositionPicker.dataProvider = new ArrayCollection(
		[
			RelativePosition.TOP,
			RelativePosition.RIGHT,
			RelativePosition.BOTTOM,
			RelativePosition.LEFT,
			//RelativePosition.MANUAL,
		]);
		this._accessoryPositionPicker.listProperties.typicalItem = RelativePosition.BOTTOM;
		this._accessoryPositionPicker.selectedItem = this.settings.accessoryPosition;
		this._accessoryPositionPicker.addEventListener(Event.CHANGE, accessoryPositionPicker_changeHandler);
		
		this._accessoryGapPicker = new PickerList();
		this._accessoryGapPicker.dataProvider = new ArrayCollection(
		[
			{ label: GAP_LABEL_INFINITE, value: true },
			{ label: GAP_LABEL_DEFAULT, value: false },
		]);
		this._accessoryGapPicker.typicalItem = this._accessoryGapPicker.dataProvider.getItemAt(0);
		this._accessoryGapPicker.listProperties.typicalItem = this._accessoryGapPicker.dataProvider.getItemAt(0);
		this._accessoryGapPicker.selectedItem = this._accessoryGapPicker.dataProvider.getItemAt(this.settings.useInfiniteAccessoryGap ? 0 : 1);
		this._accessoryGapPicker.addEventListener(Event.CHANGE, accessoryGapPicker_changeHandler);
		
		this._layoutOrderPicker = new PickerList();
		this._layoutOrderPicker.typicalItem = ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON;
		this._layoutOrderPicker.dataProvider = new ArrayCollection(
		[
			ItemRendererLayoutOrder.LABEL_ICON_ACCESSORY,
			ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON,
		]);
		this._layoutOrderPicker.listProperties.typicalItem = ItemRendererLayoutOrder.LABEL_ACCESSORY_ICON;
		this._layoutOrderPicker.selectedItem = this.settings.layoutOrder;
		this._layoutOrderPicker.addEventListener(Event.CHANGE, layoutOrderPicker_changeHandler);
		
		this._horizontalAlignPicker = new PickerList();
		this._horizontalAlignPicker.dataProvider = new ArrayCollection(
		[
			HorizontalAlign.LEFT,
			HorizontalAlign.CENTER,
			HorizontalAlign.RIGHT,
		]);
		this._horizontalAlignPicker.typicalItem = HorizontalAlign.CENTER;
		this._horizontalAlignPicker.listProperties.typicalItem = HorizontalAlign.CENTER;
		this._horizontalAlignPicker.selectedItem = this.settings.horizontalAlign;
		this._horizontalAlignPicker.addEventListener(Event.CHANGE, horizontalAlignPicker_changeHandler);
		
		this._verticalAlignPicker = new PickerList();
		this._verticalAlignPicker.dataProvider = new ArrayCollection(
		[
			VerticalAlign.TOP,
			VerticalAlign.MIDDLE,
			VerticalAlign.BOTTOM,
		]);
		this._verticalAlignPicker.typicalItem = VerticalAlign.MIDDLE;
		this._verticalAlignPicker.listProperties.typicalItem = VerticalAlign.MIDDLE;
		this._verticalAlignPicker.selectedItem = this.settings.verticalAlign;
		this._verticalAlignPicker.addEventListener(Event.CHANGE, verticalAlignPicker_changeHandler);
		
		this._list = new GroupedList();
		this._list.styleNameList.add(GroupedList.ALTERNATE_STYLE_NAME_INSET_GROUPED_LIST);
		this._list.isSelectable = false;
		this._list.dataProvider = new ArrayHierarchicalCollection(
		[
			{
				header: "Layout",
				children:
				[
					{ label: "layoutOrder", accessory: this._layoutOrderPicker },
					{ label: "horizontalAlign", accessory: this._horizontalAlignPicker },
					{ label: "verticalAlign", accessory: this._verticalAlignPicker },
				]
			},
			{
				header: "Icon",
				children:
				[
					{ label: "Has Icon", accessory: this._hasIconToggle },
					{ label: "Icon Type", accessory: this._iconTypePicker },
					{ label: "iconPosition", accessory: this._iconPositionPicker },
					{ label: "gap", accessory: this._gapPicker },
				]
			},
			{
				header: "Accessory",
				children:
				[
					{ label: "Has Accessory", accessory: this._hasAccessoryToggle },
					{ label: "Accessory Type", accessory: this._accessoryTypePicker },
					{ label: "accessoryPosition", accessory: this._accessoryPositionPicker },
					{ label: "accessoryGap", accessory: this._accessoryGapPicker },
				]
			},
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

	private function hasIconToggle_changeHandler(event:Event):Void
	{
		this.settings.hasIcon = this._hasIconToggle.isSelected;
	}

	private function iconTypePicker_changeHandler(event:Event):Void
	{
		this.settings.iconType = this._iconTypePicker.selectedItem;
	}

	private function iconPositionPicker_changeHandler(event:Event):Void
	{
		this.settings.iconPosition = this._iconPositionPicker.selectedItem;
	}

	private function gapPicker_changeHandler(event:Event):Void
	{
		this.settings.useInfiniteGap = this._gapPicker.selectedIndex == 0;
	}

	private function hasAccessoryToggle_changeHandler(event:Event):Void
	{
		this.settings.hasAccessory = this._hasAccessoryToggle.isSelected;
	}

	private function accessoryTypePicker_changeHandler(event:Event):Void
	{
		this.settings.accessoryType = this._accessoryTypePicker.selectedItem;
	}

	private function accessoryPositionPicker_changeHandler(event:Event):Void
	{
		this.settings.accessoryPosition = this._accessoryPositionPicker.selectedItem;
	}

	private function accessoryGapPicker_changeHandler(event:Event):Void
	{
		this.settings.useInfiniteAccessoryGap = this._accessoryGapPicker.selectedIndex == 0;
	}

	private function layoutOrderPicker_changeHandler(event:Event):Void
	{
		this.settings.layoutOrder = this._layoutOrderPicker.selectedItem;
	}

	private function horizontalAlignPicker_changeHandler(event:Event):Void
	{
		this.settings.horizontalAlign = this._horizontalAlignPicker.selectedItem;
	}

	private function verticalAlignPicker_changeHandler(event:Event):Void
	{
		this.settings.verticalAlign = this._verticalAlignPicker.selectedItem;
	}

	private function doneButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
}