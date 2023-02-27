package feathers.examples.componentsExplorer.data;
import feathers.controls.ItemRendererLayoutOrder;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.layout.VerticalAlign;

/**
 * ...
 * @author Matse
 */
class ItemRendererSettings 
{
	public static inline var ICON_ACCESSORY_TYPE_DISPLAY_OBJECT:String = "Display Object";
	public static inline var ICON_ACCESSORY_TYPE_TEXTURE:String = "Texture";
	public static inline var ICON_ACCESSORY_TYPE_LABEL:String = "Label";

	public function new() 
	{
		
	}
	
	public var hasIcon:Bool = true;
	public var hasAccessory:Bool = true;
	public var layoutOrder:String = ItemRendererLayoutOrder.LABEL_ICON_ACCESSORY;
	public var iconType:String = ICON_ACCESSORY_TYPE_TEXTURE;
	public var iconPosition:String = RelativePosition.LEFT;
	public var useInfiniteGap:Bool = false;
	public var accessoryPosition:String = RelativePosition.RIGHT;
	public var accessoryType:String = ICON_ACCESSORY_TYPE_DISPLAY_OBJECT;
	public var useInfiniteAccessoryGap:Bool = true;
	public var horizontalAlign:String = HorizontalAlign.LEFT;
	public var verticalAlign:String = VerticalAlign.MIDDLE;
	
}