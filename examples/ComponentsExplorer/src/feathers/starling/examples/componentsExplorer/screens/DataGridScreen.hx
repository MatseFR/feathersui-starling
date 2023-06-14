package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.DataGrid;
import feathers.starling.controls.DataGridColumn;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.data.ArrayCollection;
import feathers.starling.events.FeathersEventType;
import feathers.starling.examples.componentsExplorer.data.DataGridSettings;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class DataGridScreen extends PanelScreen 
{
	public static inline var SHOW_SETTINGS:String = "showSettings";
	
	public function new() 
	{
		super();
	}
	
	public var settings:DataGridSettings;

	private var _grid:DataGrid;

	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Data Grid";
		
		this.layout = new AnchorLayout();
		
		var items:Array<Dynamic> =
		[
			{ item: "Chicken breast", dept: "Meat", price: "5.90" },
			{ item: "Bacon", dept: "Meat", price: "4.49" },
			{ item: "2% Milk", dept: "Dairy", price: "2.49" },
			{ item: "Butter", dept: "Dairy", price: "4.69" },
			{ item: "Lettuce", dept: "Produce", price: "1.29" },
			{ item: "Broccoli", dept: "Produce", price: "2.99" },
			{ item: "Whole Wheat Bread", dept: "Bakery", price: "2.49" },
			{ item: "English Muffins", dept: "Bakery", price: "2.99" },
		];
		var columns:Array<DataGridColumn> =
		[
			new DataGridColumn("item", "Item"),
			new DataGridColumn("dept", "Department"),
			new DataGridColumn("price", "Unit Price"),
		];
		
		this._grid = new DataGrid();
		this._grid.dataProvider = new ArrayCollection(items);
		this._grid.columns = new ArrayCollection(columns);
		
		this._grid.sortableColumns = this.settings.sortableColumns;
		this._grid.resizableColumns = this.settings.resizableColumns;
		this._grid.reorderColumns = this.settings.reorderColumns;
		
		//optimization: since this grid fills the entire screen, there's no
		//need for clipping. clipping should not be disabled if there's a
		//chance that item renderers could be visible if they appear outside
		//the list's bounds
		this._grid.clipContent = false;
		//optimization: when the background is covered by all item
		//renderers, don't render it
		this._grid.autoHideBackground = true;
		this._grid.addEventListener(Event.CHANGE, list_changeHandler);
		this._grid.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this.addChild(this._grid);
		
		this.headerFactory = this.customHeaderFactory;
		
		//this screen doesn't use a back button on tablets because the main
		//app's uses a split layout
		if (!DeviceCapabilities.isTablet(Starling.current.nativeStage))
		{
			this.backButtonHandler = this.onBackButton;
		}
		
		this.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
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
		var settingsButton:Button = new Button();
		settingsButton.label = "Settings";
		settingsButton.addEventListener(Event.TRIGGERED, settingsButton_triggeredHandler);
		header.rightItems = 
		[
			settingsButton
		];
		return header;
	}
	
	private function onBackButton():Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}
	
	private function transitionInCompleteHandler(event:Event):Void
	{
		this._grid.revealScrollBars();
	}
	
	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}
	
	private function settingsButton_triggeredHandler(event:Event):Void
	{
		this.dispatchEventWith(SHOW_SETTINGS);
	}
	
	private function list_changeHandler(event:Event):Void
	{
		var selectedIndices:Array<Int> = this._grid.selectedIndices;
		trace("List change:", selectedIndices.length != 0 ? selectedIndices : this._grid.selectedIndex);
	}
	
}