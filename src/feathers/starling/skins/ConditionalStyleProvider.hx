/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.skins;
import feathers.starling.core.IFeathersControl;
import feathers.starling.skins.IStyleProvider;

/**
 * A style provider that chooses between two different style providers.
 *
 * @productversion Feathers 3.0.0
 */
class ConditionalStyleProvider implements IStyleProvider
{
	/**
	 * Constructor.
	 */
	public function new(conditionalFunction:IFeathersControl->Bool,
		trueStyleProvider:IStyleProvider = null, falseStyleProvider:IStyleProvider = null) 
	{
		this._conditionalFunction = conditionalFunction;
		this._trueStyleProvider = trueStyleProvider;
		this._falseStyleProvider = falseStyleProvider;
	}
	
	/**
	 * A call to <code>applyStyles()</code> is passed to this style provider
	 * when the <code>conditionalFunction</code> returns <code>true</code>.
	 */
	public var trueStyleProvider(get, set):IStyleProvider;
	private var _trueStyleProvider:IStyleProvider;
	private function get_trueStyleProvider():IStyleProvider { return this._trueStyleProvider; }
	private function set_trueStyleProvider(value:IStyleProvider):IStyleProvider
	{
		return this._trueStyleProvider = value;
	}
	
	/**
	 * A call to <code>applyStyles()</code> is passed to this style provider
	 * when the <code>conditionalFunction</code> returns <code>false</code>.
	 */
	public var falseStyleProvider(get, set):IStyleProvider;
	private var _falseStyleProvider:IStyleProvider;
	private function get_falseStyleProvider():IStyleProvider { return this._falseStyleProvider; }
	private function set_falseStyleProvider(value:IStyleProvider):IStyleProvider
	{
		return this._falseStyleProvider = value;
	}
	
	/**
	 * When <code>applyStyles()</code> is called, the target is passed to
	 * this function to determine which style provider should be called.
	 *
	 * <pre>function(target:IFeathersControl):Boolean</pre>
	 */
	public var conditionalFunction(get, set):IFeathersControl->Bool;
	private var _conditionalFunction:IFeathersControl->Bool;
	private function get_conditionalFunction():IFeathersControl->Bool { return this._conditionalFunction; }
	private function set_conditionalFunction(value:IFeathersControl->Bool):IFeathersControl->Bool
	{
		return this._conditionalFunction = value;
	}
	
	/**
	 * @private
	 */
	public function applyStyles(target:IFeathersControl):Void
	{
		var result:Bool = false;
		if (this._conditionalFunction != null)
		{
			result = this._conditionalFunction(target);
		}
		if (result == true)
		{
			if (this._trueStyleProvider != null)
			{
				this._trueStyleProvider.applyStyles(target);
			}
		}
		else if (this._falseStyleProvider != null)
		{
			this._falseStyleProvider.applyStyles(target);
		}
	}
	
}