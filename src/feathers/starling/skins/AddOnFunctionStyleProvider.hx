/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.skins;
import feathers.starling.skins.IStyleProvider;
import haxe.Constraints.Function;
import feathers.starling.core.IFeathersControl;

/**
 * Wraps an existing style provider to call an additional function before or
 * after the existing style provider applies its styles.
 *
 * <p>Starting with Feathers 3.1, "style" properties that are set outside a
 * style provider won't be replaced by the style provider, so
 * <code>AddOnFunctionStyleProvider</code> may only be useful in rare
 * cases.</p>
 *
 * <p>Expected usage is to replace a component's existing style provider:</p>
 * <listing version="3.0">
 * var button:Button = new Button();
 * button.label = "Click Me";
 * function setExtraStyles( target:Button ):void
 * {
 *     target.defaultIcon = new Image( texture );
 *     // set other styles, if desired...
 * }
 * button.styleProvider = new AddOnFunctionStyleProvider( button.styleProvider, setExtraStyles );
 * this.addChild( button );</listing>
 *
 * @productversion Feathers 2.0.0
 */
class AddOnFunctionStyleProvider implements IStyleProvider
{
	/**
	 * Constructor.
	 */
	public function new(originalStyleProvider:IStyleProvider = null, addOnFunction:Function = null) 
	{
		this._originalStyleProvider = originalStyleProvider;
		this._addOnFunction = addOnFunction;
	}
	
	/**
	 * The <code>addOnFunction</code> will be called after the original
	 * style provider applies its styles.
	 */
	public var originalStyleProvider(get, set):IStyleProvider;
	private var _originalStyleProvider:IStyleProvider;
	private function get_originalStyleProvider():IStyleProvider { return this._originalStyleProvider; }
	private function set_originalStyleProvider(value:IStyleProvider):IStyleProvider
	{
		return this._originalStyleProvider = value;
	}
	
	/**
	 * A function to call after applying the original style provider's
	 * styles.
	 *
	 * <p>The function is expected to have the following signature:</p>
	 * <pre>function( item:IFeathersControl ):void</pre>
	 */
	public var addOnFunction(get, set):Function;
	private var _addOnFunction:Function;
	private function get_addOnFunction():Function { return this._addOnFunction; }
	private function set_addOnFunction(value:Function):Function
	{
		return this._addOnFunction = value;
	}
	
	/**
	 * Determines if the add on function should be called before the
	 * original style provider is applied, or after.
	 *
	 * @default false
	 */
	public var callBeforeOriginalStyleProvider(get, set):Bool;
	private var _callBeforeOriginalStyleProvider:Bool = false;
	private function get_callBeforeOriginalStyleProvider():Bool { return this._callBeforeOriginalStyleProvider; }
	private function set_callBeforeOriginalStyleProvider(value:Bool):Bool
	{
		return this._callBeforeOriginalStyleProvider;
	}
	
	/**
	 * @inheritDoc
	 */
	public function applyStyles(target:IFeathersControl):Void
	{
		if (this._callBeforeOriginalStyleProvider && this._addOnFunction != null)
		{
			this._addOnFunction(target);
		}
		if (this._originalStyleProvider != null)
		{
			this._originalStyleProvider.applyStyles(target);
		}
		if (!this._callBeforeOriginalStyleProvider && this._addOnFunction != null)
		{
			this._addOnFunction(target);
		}
	}
	
}