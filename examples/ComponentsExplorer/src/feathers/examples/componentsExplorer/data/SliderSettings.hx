package feathers.examples.componentsExplorer.data;
import feathers.controls.TrackInteractionMode;

class SliderSettings 
{

	public function new() 
	{
		
	}
	
	public var step:Float = 1;
	public var page:Float = 10;
	public var liveDragging:Bool = true;
	public var trackInteractionMode:String = TrackInteractionMode.TO_VALUE;
	
}