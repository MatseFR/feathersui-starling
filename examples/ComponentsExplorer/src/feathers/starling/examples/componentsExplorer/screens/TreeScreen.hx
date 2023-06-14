package feathers.starling.examples.componentsExplorer.screens;

import feathers.starling.controls.Button;
import feathers.starling.controls.Header;
import feathers.starling.controls.PanelScreen;
import feathers.starling.controls.Tree;
import feathers.starling.controls.renderers.DefaultTreeItemRenderer;
import feathers.starling.controls.renderers.ITreeItemRenderer;
import feathers.starling.data.ArrayHierarchicalCollection;
import feathers.starling.events.FeathersEventType;
import feathers.starling.layout.AnchorLayout;
import feathers.starling.layout.AnchorLayoutData;
import feathers.starling.system.DeviceCapabilities;
import starling.core.Starling;
import starling.events.Event;

class TreeScreen extends PanelScreen 
{
	public function new() 
	{
		super();
	}
	
	private var _tree:Tree;
	
	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this.title = "Tree";
		
		this.layout = new AnchorLayout();
		
		var data:Array<Dynamic> =
		[
			{
				text: "Node 1",
				children:
				[
					{
						text: "Node 1A",
						children:
						[
							{ text: "Node 1A-I" },
							{ text: "Node 1A-II" },
							{ text: "Node 1A-III" },
							{ text: "Node 1A-IV" },
						]
					},
					{ text: "Node 1B" },
					{ text: "Node 1C" },
				]
			},
			{
				text: "Node 2",
				children:
				[
					{ text: "Node 2A" },
					{ text: "Node 2B" },
					{ text: "Node 2C" },
				]
			},
			{
				text: "Node 3"
			},
			{
				text: "Node 4",
				children:
				[
					{ text: "Node 4A" },
					{ text: "Node 4B" },
					{ text: "Node 4C" },
					{ text: "Node 4D" },
					{ text: "Node 4E" },
				]
			}
		];
		
		this._tree = new Tree();
		this._tree.dataProvider = new ArrayHierarchicalCollection(data);
		this._tree.typicalItem = { text: "Item 1000" };
		//optimization: since this tree fills the entire screen, there's no
		//need for clipping. clipping should not be disabled if there's a
		//chance that item renderers could be visible if they appear outside
		//the tree's bounds
		this._tree.clipContent = false;
		//optimization: when the background is covered by all item
		//renderers, don't render it
		this._tree.autoHideBackground = true;
		this._tree.itemRendererFactory = function():ITreeItemRenderer
		{
			var renderer:DefaultTreeItemRenderer = new DefaultTreeItemRenderer();
			renderer.labelField = "text";
			return renderer;
		};
		this._tree.addEventListener(Event.CHANGE, tree_changeHandler);
		this._tree.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this.addChildAt(this._tree, 0);
		
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
		return header;
	}
	
	private function onBackButton():Void
	{
		this.dispatchEventWith(Event.COMPLETE);
	}

	private function transitionInCompleteHandler(event:Event):Void
	{
		this._tree.revealScrollBars();
	}
	
	private function backButton_triggeredHandler(event:Event):Void
	{
		this.onBackButton();
	}

	private function tree_changeHandler(event:Event):Void
	{
		trace("Tree change:", this._tree.dataProvider.getItemLocation(this._tree.selectedItem));
	}
	
}