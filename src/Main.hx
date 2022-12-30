package;

import openfl.display.Sprite;
import openfl.Lib;
import openfl.display.StageScaleMode;
import openfl.display3D.Context3DRenderMode;
import openfl.system.Capabilities;
import starling.core.Starling;
import starling.events.Event;

/**
 * ...
 * @author Matse
 */
class Main extends Sprite 
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
		
		stage.scaleMode = StageScaleMode.NO_BORDER;
		
		start();
	}
	
	private function start():Void
	{
		_starling = new Starling(Testing, stage, null, null, Context3DRenderMode.AUTO, "auto");
		_starling.enableErrorChecking = Capabilities.isDebugger;
		_starling.showStats = true;
		_starling.skipUnchangedFrames = true;
		_starling.supportBrowserZoom = true;
		_starling.supportHighResolutions = true;
		_starling.simulateMultitouch = true;
		_starling.addEventListener(Event.ROOT_CREATED, function():Void
		{
			//loadAssets(startGame);
			trace("root created");
		});
		
		//this.stage.addEventListener(Event.RESIZE, onResize, false, Max.INT_MAX_VALUE, true);
		
		_starling.start();
	}

}
