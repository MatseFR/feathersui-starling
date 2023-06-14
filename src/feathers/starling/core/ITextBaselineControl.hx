package feathers.starling.core;
import feathers.starling.core.IFeathersControl;

/**
 * @author Matse
 */
interface ITextBaselineControl extends IFeathersControl
{
	/**
	 * Returns the text baseline measurement, in pixels.
	 */
	public var baseline(get, never):Float;
}