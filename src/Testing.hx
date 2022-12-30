package;

import feathers.controls.AutoSizeMode;
import feathers.controls.LayoutGroup;
import feathers.themes.MetalWorksDesktopTheme;
import starling.display.Sprite;
import starling.events.Event;

/**
 * ...
 * @author Matse
 */
class Testing extends Sprite 
{

	public function new() 
	{
		super();
		this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	
	/**
	 * 
	 * @param	evt
	 */
	private function addedToStageHandler(evt:Event):Void
	{
		this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		
		var theme:MetalWorksDesktopTheme = new MetalWorksDesktopTheme();
		
		var group:LayoutGroup = new LayoutGroup();
		group.autoSizeMode = AutoSizeMode.STAGE;
		addChild(group);
	}
	
}