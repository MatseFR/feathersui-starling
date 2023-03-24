/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.themes;

import feathers.skins.ConditionalStyleProvider;
import feathers.skins.IStyleProvider;
import feathers.skins.StyleNameFunctionStyleProvider;
import feathers.skins.StyleProviderRegistry;
import feathers.core.IFeathersControl;
import starling.core.Starling;
import starling.events.EventDispatcher;

/**
 * Base class for themes that pass a <code>StyleNameFunctionStyleProvider</code>
 * to each component class.
 *
 * @see feathers.skins.StyleNameFunctionStyleProvider
 * @see ../../../help/skinning.html Skinning Feathers components
 * @see ../../../help/custom-themes.html Creating custom Feathers themes
 *
 * @productversion Feathers 2.0.0
 */
class StyleNameFunctionTheme extends EventDispatcher 
{
	/**
	 * @private
	 */
	private static inline var GLOBAL_STYLE_PROVIDER_PROPERTY_NAME:String = "globalStyleProvider";
	
	/**
	 * Constructor.
	 */
	public function new() 
	{
		super();
		if (this.starling == null)
		{
			this.starling = Starling.current;
		}
		this.createRegistry();
		this._conditionalRegistry = new StyleProviderRegistry(true, createConditionalStyleProvider);
	}
	
	/**
	 * The Starling instance associated with this theme.
	 */
	private var starling:Starling;

	/**
	 * @private
	 */
	private var _registry:StyleProviderRegistry;

	/**
	 * @private
	 */
	private var _conditionalRegistry:StyleProviderRegistry;
	
	/**
	 * Disposes the theme.
	 */
	public function dispose():Void
	{
		if (this._registry != null)
		{
			this._registry.dispose();
			this._registry = null;
		}
		if (this._conditionalRegistry != null)
		{
			this.disposeConditionalRegistry();
		}
	}
	
	/**
	 * Returns a <code>StyleNameFunctionStyleProvider</code> to be passed to
	 * the specified class.
	 */
	public function getStyleProviderForClass(type:Class<Dynamic>):StyleNameFunctionStyleProvider
	{
		var existingGlobalStyleProvider:IStyleProvider = Reflect.field(type, GLOBAL_STYLE_PROVIDER_PROPERTY_NAME);
		var conditional:ConditionalStyleProvider = cast this._conditionalRegistry.getStyleProvider(type);
		if (conditional.trueStyleProvider == null)
		{
			var styleProvider:StyleNameFunctionStyleProvider = cast this._registry.getStyleProvider(type);
			conditional.trueStyleProvider = styleProvider;
			conditional.falseStyleProvider = existingGlobalStyleProvider;
		}
		return cast conditional.trueStyleProvider;
	}
	
	/**
	 * @private
	 */
	private function createRegistry():Void
	{
		this._registry = new StyleProviderRegistry(false);
	}
	
	/**
	 * @private
	 */
	private function starlingConditional(target:IFeathersControl):Bool
	{
		var starling:Starling = target.stage != null ? target.stage.starling : Starling.current;
		return starling == this.starling;
	}
	
	/**
	 * @private
	 */
	private function createConditionalStyleProvider():ConditionalStyleProvider
	{
		return new ConditionalStyleProvider(starlingConditional);
	}
	
	/**
	 * @private
	 */
	private function disposeConditionalRegistry():Void
	{
		var classes:Array<Class<Dynamic>> = this._conditionalRegistry.getRegisteredClasses();
		var classCount:Int = classes.length;
		var forClass:Class<Dynamic>;
		var globalStyleProvider:IStyleProvider;
		var styleProviderInRegistry:ConditionalStyleProvider;
		var currentStyleProvider:ConditionalStyleProvider;
		var previousStyleProvider:ConditionalStyleProvider;
		var nextStyleProvider:IStyleProvider;
		for (i in 0...classCount)
		{
			forClass = classes[i];
			globalStyleProvider = Reflect.field(forClass, GLOBAL_STYLE_PROVIDER_PROPERTY_NAME);
			styleProviderInRegistry = cast this._conditionalRegistry.clearStyleProvider(forClass);
			
			currentStyleProvider = cast globalStyleProvider;
			previousStyleProvider = null;
			do
			{
				if (currentStyleProvider == null)
				{
					//worse case scenario is that we don't know how to
					//remove this style provider from the chain, so we leave
					//it in but always pass to the falseStyleProvider.
					styleProviderInRegistry.conditionalFunction = null;
					styleProviderInRegistry.trueStyleProvider = null;
					break;
				}
				nextStyleProvider = currentStyleProvider.falseStyleProvider;
				if (currentStyleProvider == styleProviderInRegistry)
				{
					if (previousStyleProvider != null)
					{
						previousStyleProvider.falseStyleProvider = nextStyleProvider;
					}
					else //currentStyleProvider == globalStyleProvider
					{
						Reflect.setField(forClass, GLOBAL_STYLE_PROVIDER_PROPERTY_NAME, nextStyleProvider);
					}
					break;
				}
				previousStyleProvider = currentStyleProvider;
				currentStyleProvider = cast nextStyleProvider;
			}
			while (true);
		}
		this._conditionalRegistry = null;
	}
	
}