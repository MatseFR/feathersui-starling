package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.List;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.renderers.DefaultListItemRenderer;
import feathers.starling.controls.renderers.IListItemRenderer;
import feathers.starling.data.ArrayCollection;
import feathers.starling.events.FeathersEventType;
import feathers.starling.examples.componentsExplorer.data.ListSettings;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class ListScreen extends PanelScreen 
{
	public static inline var SHOW_SETTINGS:String = "showSettings";
	
	public function new() 
	{
		super();
	}
	
	public var settings:ListSettings;

	private var _list:List;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "List";
		
		this.layout = new AnchorLayout();
		
		var items:Array<Dynamic> = [];
		var item:Dynamic;
		for (i in 0...150)
		{
			item = {text: "Item " + (i + 1)};
			items[i] = item;
		}
		
		this._list = new List();
		this._list.dataProvider = new ArrayCollection(items);
		this._list.typicalItem = {text: "Item 1000"};
		this._list.isSelectable = this.settings.isSelectable;
		this._list.allowMultipleSelection = this.settings.allowMultipleSelection;
		this._list.hasElasticEdges = this.settings.hasElasticEdges;
		//optimization: since this list fills the entire screen, there's no
		//need for clipping. clipping should not be disabled if there's a
		//chance that item renderers could be visible if they appear outside
		//the list's bounds
		this._list.clipContent = false;
		//optimization: when the background is covered by all item
		//renderers, don't render it
		this._list.autoHideBackground = true;
		this._list.itemRendererFactory = function():IListItemRenderer
		{
			var renderer:DefaultListItemRenderer = new DefaultListItemRenderer();
			
			//enable the quick hit area to optimize hit tests when an item
			//is only selectable and doesn't have interactive children.
			renderer.isQuickHitAreaEnabled = true;
			
			renderer.labelField = "text";
			return renderer;
		};
		this._list.addEventListener(Event.CHANGE, list_changeHandler);
		this._list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this.addChild(this._list);
		
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
		this._list.revealScrollBars();
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
		var selectedIndices:Array<Int> = this._list.selectedIndices;
		trace("List change:", selectedIndices.length > 0 ? selectedIndices : this._list.selectedIndex);
	}
	
}