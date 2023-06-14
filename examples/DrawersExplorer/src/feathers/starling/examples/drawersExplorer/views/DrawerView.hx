package feathers.starling.examples.drawersExplorer.views;

import feathers.starling.controls.Check;
import feathers.starling.controls.Label;
import feathers.starling.controls.ScrollContainer;
import feathers.starling.skins.IStyleProvider;
import starling.events.Event;

class DrawerView extends ScrollContainer 
{
	public static var globalStyleProvider:IStyleProvider;
	
	public static inline var CHANGE_DOCK_MODE_TO_NONE:String = "changeDockModeToNone";
	public static inline var CHANGE_DOCK_MODE_TO_BOTH:String = "changeDockModeToBoth";
	
	public function new(title:String) 
	{
		super();
		this._title = title;
	}
	
	private var _title:String;
	private var _titleLabel:Label;
	private var _dockCheck:Check;

	override function get_defaultStyleProvider():IStyleProvider
	{
		return DrawerView.globalStyleProvider;
	}

	override function initialize():Void
	{
		//never forget to call super.initialize()
		super.initialize();
		
		this._titleLabel = new Label();
		this._titleLabel.styleNameList.add(Label.ALTERNATE_STYLE_NAME_HEADING);
		this._titleLabel.text = this._title;
		this.addChild(this._titleLabel);
		
		this._dockCheck = new Check();
		this._dockCheck.isSelected = false;
		this._dockCheck.label = "Dock";
		this._dockCheck.addEventListener(Event.CHANGE, dockCheck_changeHandler);
		this.addChild(this._dockCheck);
	}

	private function dockCheck_changeHandler(event:Event):Void
	{
		if (this._dockCheck.isSelected)
		{
			this.dispatchEventWith(CHANGE_DOCK_MODE_TO_BOTH);
		}
		else
		{
			this.dispatchEventWith(CHANGE_DOCK_MODE_TO_NONE);
		}
	}
	
}