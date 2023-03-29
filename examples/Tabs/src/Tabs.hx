package;

import feathers.examples.tabs.Main;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import openfl.display3D.Context3DRenderMode;
import openfl.system.Capabilities;
import starling.core.Starling;
import starling.events.Event;

class Tabs extends Sprite 
{
	private var _starling:Starling;
	
	public function new() 
	{
		super();
		
		if (stage != null) start();
		else addEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(event:Dynamic):Void
	{
		removeEventListener(openfl.events.Event.ADDED_TO_STAGE, onAddedToStage);
		
		start();
	}
	
	private function start():Void
	{
		//simulating iPhone Retina
		//DeviceCapabilities.dpi = 326;
		
		stage.scaleMode = StageScaleMode.NO_SCALE;
		
		_starling = new Starling(Main, stage, null, null, Context3DRenderMode.AUTO, "auto");
		_starling.enableErrorChecking = Capabilities.isDebugger;
		_starling.showStats = false;//Capabilities.isDebugger;
		_starling.skipUnchangedFrames = true;
		_starling.supportBrowserZoom = true;
		_starling.supportHighResolutions = true;
		_starling.simulateMultitouch = true;
		_starling.addEventListener(Event.ROOT_CREATED, function():Void
		{
			trace("root created");
		});
		
		//this.stage.addEventListener(Event.RESIZE, onResize, false, Max.INT_MAX_VALUE, true);
		
		_starling.start();
	}
}