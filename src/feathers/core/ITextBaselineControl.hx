package feathers.core;
import src.feathers.core.IFeathersControl;

/**
 * @author Matse
 */
interface ITextBaselineControl extends IFeathersControl
{
	/**
	 * Returns the text baseline measurement, in pixels.
	 */
	public var baseLine(get, never):Float;
}