package feathers.starling.examples.layoutExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.List;
import feathers.starling.controls.NumericStepper;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.PickerList;
import feathers.starling.data.ArrayCollection;
import feathers.starling.examples.layoutExplorer.data.TiledColumnsLayoutSettings;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.layout.Direction;
import feathers.starling.layout.HorizontalAlign;
import feathers.starling.layout.VerticalAlign;
import starling.display.DisplayObject;
import starling.events.Event;

class TiledColumnsLayoutSettingsScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	public var settings:TiledColumnsLayoutSettings;

	private var _list:List;
	
	private var _itemCountStepper:NumericStepper;
	private var _requestedRowCountStepper:NumericStepper;
	private var _pagingPicker:PickerList;
	private var _horizontalGapStepper:NumericStepper;
	private var _verticalGapStepper:NumericStepper;
	private var _paddingTopStepper:NumericStepper;
	private var _paddingRightStepper:NumericStepper;
	private var _paddingBottomStepper:NumericStepper;
	private var _paddingLeftStepper:NumericStepper;
	private var _horizontalAlignPicker:PickerList;
	private var _verticalAlignPicker:PickerList;
	private var _tileHorizontalAlignPicker:PickerList;
	private var _tileVerticalAlignPicker:PickerList;
	
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
		
		this.title = "Tiled Columns Layout Settings";
		
		this.layout = new AnchorLayout();
		
		this._itemCountStepper = new NumericStepper();
		this._itemCountStepper.minimum = 1;
		//the layout can certainly handle more. this value is arbitrary.
		this._itemCountStepper.maximum = 100;
		this._itemCountStepper.step = 1;
		this._itemCountStepper.value = this.settings.itemCount;
		this._itemCountStepper.addEventListener(Event.CHANGE, itemCountStepper_changeHandler);
		
		this._requestedRowCountStepper = new NumericStepper();
		this._requestedRowCountStepper.minimum = 0;
		//the layout can certainly handle more. this value is arbitrary.
		this._requestedRowCountStepper.maximum = 10;
		this._requestedRowCountStepper.step = 1;
		this._requestedRowCountStepper.value = this.settings.requestedRowCount;
		this._requestedRowCountStepper.addEventListener(Event.CHANGE, requestedRowCountStepper_changeHandler);
		
		this._pagingPicker = new PickerList();
		this._pagingPicker.typicalItem = Direction.HORIZONTAL;
		this._pagingPicker.dataProvider = new ArrayCollection(
		[
			Direction.NONE,
			Direction.HORIZONTAL,
			Direction.VERTICAL
		]);
		this._pagingPicker.selectedItem = this.settings.paging;
		this._pagingPicker.addEventListener(Event.CHANGE, pagingPicker_changeHandler);
		
		this._horizontalAlignPicker = new PickerList();
		this._horizontalAlignPicker.typicalItem = HorizontalAlign.CENTER;
		this._horizontalAlignPicker.dataProvider = new ArrayCollection(
		[
			HorizontalAlign.LEFT,
			HorizontalAlign.CENTER,
			HorizontalAlign.RIGHT
		]);
		this._horizontalAlignPicker.selectedItem = this.settings.horizontalAlign;
		this._horizontalAlignPicker.addEventListener(Event.CHANGE, horizontalAlignPicker_changeHandler);
		
		this._verticalAlignPicker = new PickerList();
		this._verticalAlignPicker.typicalItem = VerticalAlign.BOTTOM;
		this._verticalAlignPicker.dataProvider = new ArrayCollection(
		[
			VerticalAlign.TOP,
			VerticalAlign.MIDDLE,
			VerticalAlign.BOTTOM
		]);
		this._verticalAlignPicker.selectedItem = this.settings.verticalAlign;
		this._verticalAlignPicker.addEventListener(Event.CHANGE, verticalAlignPicker_changeHandler);
		
		this._tileHorizontalAlignPicker = new PickerList();
		this._tileHorizontalAlignPicker.typicalItem = HorizontalAlign.CENTER;
		this._tileHorizontalAlignPicker.dataProvider = new ArrayCollection(
		[
			HorizontalAlign.LEFT,
			HorizontalAlign.CENTER,
			HorizontalAlign.RIGHT,
			HorizontalAlign.JUSTIFY
		]);
		this._tileHorizontalAlignPicker.selectedItem = this.settings.tileHorizontalAlign;
		this._tileHorizontalAlignPicker.addEventListener(Event.CHANGE, tileHorizontalAlignPicker_changeHandler);
		
		this._tileVerticalAlignPicker = new PickerList();
		this._tileVerticalAlignPicker.typicalItem = VerticalAlign.BOTTOM;
		this._tileVerticalAlignPicker.dataProvider = new ArrayCollection(
		[
			VerticalAlign.TOP,
			VerticalAlign.MIDDLE,
			VerticalAlign.BOTTOM,
			VerticalAlign.JUSTIFY
		]);
		this._tileVerticalAlignPicker.selectedItem = this.settings.tileVerticalAlign;
		this._tileVerticalAlignPicker.addEventListener(Event.CHANGE, tileVerticalAlignPicker_changeHandler);
		
		this._horizontalGapStepper = new NumericStepper();
		this._horizontalGapStepper.minimum = 0;
		//these maximum values are completely arbitrary
		this._horizontalGapStepper.maximum = 100;
		this._horizontalGapStepper.step = 1;
		this._horizontalGapStepper.value = this.settings.horizontalGap;
		this._horizontalGapStepper.addEventListener(Event.CHANGE, horizontalGapStepper_changeHandler);
		
		this._verticalGapStepper = new NumericStepper();
		this._verticalGapStepper.minimum = 0;
		this._verticalGapStepper.maximum = 100;
		this._verticalGapStepper.step = 1;
		this._verticalGapStepper.value = this.settings.verticalGap;
		this._verticalGapStepper.addEventListener(Event.CHANGE, verticalGapStepper_changeHandler);
		
		this._paddingTopStepper = new NumericStepper();
		this._paddingTopStepper.minimum = 0;
		this._paddingTopStepper.maximum = 100;
		this._paddingTopStepper.step = 1;
		this._paddingTopStepper.value = this.settings.paddingTop;
		this._paddingTopStepper.addEventListener(Event.CHANGE, paddingTopStepper_changeHandler);
		
		this._paddingRightStepper = new NumericStepper();
		this._paddingRightStepper.minimum = 0;
		this._paddingRightStepper.maximum = 100;
		this._paddingRightStepper.step = 1;
		this._paddingRightStepper.value = this.settings.paddingRight;
		this._paddingRightStepper.addEventListener(Event.CHANGE, paddingRightStepper_changeHandler);
		
		this._paddingBottomStepper = new NumericStepper();
		this._paddingBottomStepper.minimum = 0;
		this._paddingBottomStepper.maximum = 100;
		this._paddingBottomStepper.step = 1;
		this._paddingBottomStepper.value = this.settings.paddingBottom;
		this._paddingBottomStepper.addEventListener(Event.CHANGE, paddingBottomStepper_changeHandler);
		
		this._paddingLeftStepper = new NumericStepper();
		this._paddingLeftStepper.minimum = 0;
		this._paddingLeftStepper.maximum = 100;
		this._paddingLeftStepper.step = 1;
		this._paddingLeftStepper.value = this.settings.paddingLeft;
		this._paddingLeftStepper.addEventListener(Event.CHANGE, paddingLeftStepper_changeHandler);
		
		this._list = new List();
		this._list.isSelectable = false;
		this._list.dataProvider = new ArrayCollection(
		[
			{ label: "Item Count", accessory: this._itemCountStepper },
			{ label: "Requested Row Count", accessory: this._requestedRowCountStepper },
			{ label: "Paging", accessory: this._pagingPicker },
			{ label: "horizontalAlign", accessory: this._horizontalAlignPicker },
			{ label: "verticalAlign", accessory: this._verticalAlignPicker },
			{ label: "tileHorizontalAlign", accessory: this._tileHorizontalAlignPicker },
			{ label: "tileVerticalAlign", accessory: this._tileVerticalAlignPicker },
			{ label: "horizontalGap", accessory: this._horizontalGapStepper },
			{ label: "verticalGap", accessory: this._verticalGapStepper },
			{ label: "paddingTop", accessory: this._paddingTopStepper },
			{ label: "paddingRight", accessory: this._paddingRightStepper },
			{ label: "paddingBottom", accessory: this._paddingBottomStepper },
			{ label: "paddingLeft", accessory: this._paddingLeftStepper },
		]);
		this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
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

	private function itemCountStepper_changeHandler(event:Event):Void
	{
		this.settings.itemCount = Std.int(this._itemCountStepper.value);
	}

	private function requestedRowCountStepper_changeHandler(event:Event):Void
	{
		this.settings.requestedRowCount = Std.int(this._requestedRowCountStepper.value);
	}

	private function pagingPicker_changeHandler(event:Event):Void
	{
		this.settings.paging = this._pagingPicker.selectedItem;
	}

	private function horizontalAlignPicker_changeHandler(event:Event):Void
	{
		this.settings.horizontalAlign = this._horizontalAlignPicker.selectedItem;
	}

	private function verticalAlignPicker_changeHandler(event:Event):Void
	{
		this.settings.verticalAlign = this._verticalAlignPicker.selectedItem;
	}

	private function tileHorizontalAlignPicker_changeHandler(event:Event):Void
	{
		this.settings.tileHorizontalAlign = this._tileHorizontalAlignPicker.selectedItem;
	}

	private function tileVerticalAlignPicker_changeHandler(event:Event):Void
	{
		this.settings.tileVerticalAlign = this._tileVerticalAlignPicker.selectedItem;
	}

	private function horizontalGapStepper_changeHandler(event:Event):Void
	{
		this.settings.horizontalGap = this._horizontalGapStepper.value;
	}

	private function verticalGapStepper_changeHandler(event:Event):Void
	{
		this.settings.verticalGap = this._verticalGapStepper.value;
	}

	private function paddingTopStepper_changeHandler(event:Event):Void
	{
		this.settings.paddingTop = this._paddingTopStepper.value;
	}

	private function paddingRightStepper_changeHandler(event:Event):Void
	{
		this.settings.paddingRight = this._paddingRightStepper.value;
	}

	private function paddingBottomStepper_changeHandler(event:Event):Void
	{
		this.settings.paddingBottom = this._paddingBottomStepper.value;
	}

	private function paddingLeftStepper_changeHandler(event:Event):Void
	{
		this.settings.paddingLeft = this._paddingLeftStepper.value;
	}
}