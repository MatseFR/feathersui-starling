/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.skins;
import feathers.core.TokenList;
import feathers.core.IFeathersControl;
import haxe.Constraints.Function;

/**
 * Similar to <code>FunctionStyleProvider</code>, sets styles on a Feathers
 * UI component by passing it to a function, but also provides a way to
 * define alternate functions that may be called based on the contents of
 * the component's <code>styleNameList</code>.
 *
 * <p>Alternate functions may be registered with the style provider by
 * calling <code>setFunctionForStyleName()</code> and passing in a style
 * name and a function. For each style name in the component's
 * <code>styleNameList</code>, the style provider will search its registered
 * style names to see if a function should be called. If none of a
 * component's style names have been registered with the style provider (or
 * if the component has no style names), then the default style function
 * will be called.</p>
 *
 * <p>If a component's <code>styleNameList</code> contains multiple values,
 * each of those values is eligible to trigger a call to a function
 * registered with the style provider. In other words, adding multiple
 * values to a component's <code>styleNameList</code> may be used to call
 * multiple functions.</p>
 *
 * <p>In the following example, a <code>StyleNameFunctionStyleProvider</code> is
 * created with a default style function (passed to the constructor) and
 * an alternate style function:</p>
 * <listing version="3.0">
 * var styleProvider:StyleNameFunctionStyleProvider = new StyleNameFunctionStyleProvider( function( target:Button ):void
 * {
 *     target.defaultSkin = new Image( defaultTexture );
 *     // set other styles...
 * });
 * styleProvider.setFunctionForStyleName( "alternate-button", function( target:Button ):void
 * {
 *     target.defaultSkin = new Image( alternateTexture );
 *     // set other styles...
 * });
 * 
 * var button:Button = new Button();
 * button.label = "Click Me";
 * button.styleProvider = styleProvider;
 * this.addChild(button);
 * 
 * var alternateButton:Button = new Button()
 * button.label = "No, click me!";
 * alternateButton.styleProvider = styleProvider;
 * alternateButton.styleNameList.add( "alternate-button" );
 * this.addChild( alternateButton );</listing>
 *
 * @see ../../../help/skinning.html Skinning Feathers components
 *
 * @productversion Feathers 2.0.0
 */
class StyleNameFunctionStyleProvider implements IStyleProvider
{
	/**
	 * Constructor.
	 */
	public function new(styleFunction:IFeathersControl->Void = null) 
	{
		this._defaultStyleFunction = styleFunction;
	}
	
	/**
	 * The target Feathers UI component is passed to this function when
	 * <code>applyStyles()</code> is called and the component's
	 * <code>styleNameList</code> doesn't contain any style names that are
	 * set with <code>setFunctionForStyleName()</code>.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:IFeathersControl ):void</pre>
	 *
	 * @see #setFunctionForStyleName()
	 */
	public var defaultStyleFunction(get, set):Function;
	private var _defaultStyleFunction:Function;
	private function get_defaultStyleFunction():Function { return this._defaultStyleFunction; }
	private function set_defaultStyleFunction(value:Function):Function
	{
		return this._defaultStyleFunction = value;
	}
	
	/**
	 * @private
	 */
	private var _styleNameMap:Map<String, Function>;
	
	/**
	 * The target Feathers UI component is passed to this function when
	 * <code>applyStyles()</code> is called and the component's
	 * <code>styleNameList</code> contains the specified style name.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:IFeathersControl ):void</pre>
	 *
	 * @see #defaultStyleFunction
	 */
	public function setFunctionForStyleName(styleName:String, styleFunction:Function):Void
	{
		if (this._styleNameMap == null)
		{
			this._styleNameMap = new Map<String, Function>();
		}
		this._styleNameMap[styleName] = styleFunction;
	}
	
	/**
	 * @inheritDoc
	 */
	public function applyStyles(target:IFeathersControl):Void
	{
		if (this._styleNameMap != null)
		{
			var hasNameInitializers:Bool = false;
			var styleNameList:TokenList = target.styleNameList;
			var styleNameCount:Int = styleNameList.length;
			for (i in 0...styleNameCount)
			{
				var name:String = styleNameList.item(i);
				var initializer:Function = this._styleNameMap[name];
				if (initializer != null)
				{
					hasNameInitializers = true;
					initializer(target);
				}
			}
			if (hasNameInitializers)
			{
				return;
			}
		}
		if (this._defaultStyleFunction != null)
		{
			this._defaultStyleFunction(target);
		}
	}
	
}