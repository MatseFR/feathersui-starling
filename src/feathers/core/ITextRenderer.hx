package feathers.core;
import feathers.text.FontStylesSet;
import openfl.geom.Point;
import src.feathers.core.IFeathersControl;

/**
 * @author Matse
 */
interface ITextRenderer extends IStateObserver extends IFeathersControl extends ITextBaselineControl
{
	/**
	 * The text to render.
	 *
	 * <p>If using the <code>Label</code> component, this property should
	 * be set on the <code>Label</code>, and it will be passed down to the
	 * text renderer.</p>
	 */
	public var text(get, set):String;
	
	/**
	 * Determines if the text wraps to the next line when it reaches the
	 * width (or max width) of the component.
	 *
	 * <p> This property is sometimes controlled by the parent component,
	 * such as on a <code>Label</code> component. If using the
	 * <code>Label</code> component, this property must be set on the
	 * <code>Label</code>, and it will be passed down to the text renderer
	 * automatically.</p>
	 */
	public var wordWrap(get, set):Bool;
	
	/**
	 * The number of text lines in the text renderer. The text renderer may
	 * contain multiple text lines if the text contains line breaks or if
	 * the <code>wordWrap</code> property is enabled.
	 */
	public var numLines(get, never):Int;
	
	/**
	 * The internal font styles used to render the text that are passed down
	 * from the parent component. Generally, most developers will set font
	 * styles on the parent component.
	 *
	 * <p>Warning: The <code>fontStyles</code> property may be ignored if
	 * more advanced styles defined by the text renderer implementation have
	 * been set.</p>
	 *
	 * @see http://doc.starling-framework.org/current/starling/text/TextFormat.html starling.text.TextFormat
	 */
	public var fontStyles(get, set):FontStylesSet;
	
	/**
	 * Measures the text's bounds (without a full validation, if
	 * possible).
	 */
	function measureText(result:Point = null):Point;
}