/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.skins;
import haxe.ds.Map;
import openfl.errors.ArgumentError;

/**
 * Used by themes to create and manage style providers for component classes.
 *
 * @productversion Feathers 2.0.0
 */
class StyleProviderRegistry 
{
	/**
	 * @private
	 */
	private static inline var GLOBAL_STYLE_PROVIDER_PROPERTY_NAME:String = "globalStyleProvider";

	/**
	 * @private
	 */
	private static function defaultStyleProviderFactory():IStyleProvider
	{
		return new StyleNameFunctionStyleProvider();
	}
	
	/**
	 * Constructor.
	 *
	 * <p>If style providers are to be registered globally, they will be
	 * passed to the static <code>globalStyleProvider</code> property of the
	 * specified class. If the class does not define a
	 * <code>globalStyleProvider</code> property, an error will be thrown.</p>
	 *
	 * <p>The style provider factory function is expected to have the following
	 * signature:</p>
	 * <pre>function():IStyleProvider</pre>
	 *
	 * @param registerGlobally			Determines if the registry sets the static <code>globalStyleProvider</code> property.
	 * @param styleProviderFactory		An optional function that creates a new style provider. If <code>null</code>, a <code>StyleNameFunctionStyleProvider</code> will be created.
	 */
	public function new(registerGlobally:Bool = true, styleProviderFactory:Void->IStyleProvider = null) 
	{
		this._registerGlobally = registerGlobally;
		if(styleProviderFactory == null)
		{
			this._styleProviderFactory = defaultStyleProviderFactory;
		}
		else
		{
			this._styleProviderFactory = styleProviderFactory;
		}
	}
	
	/**
	 * @private
	 */
	private var _registerGlobally:Bool;

	/**
	 * @private
	 */
	private var _styleProviderFactory:Void->IStyleProvider;
	
	/**
	 * @private
	 */
	private var _classToStyleProvider:Map<String, IStyleProvider> = new Map<String, IStyleProvider>();
	
	private var _classList:Array<Class<Dynamic>> = new Array<Class<Dynamic>>();
	
	/**
	 * Disposes the theme.
	 */
	public function dispose():Void
	{
		//clear the global style providers, but only if they still match the
		//ones that the theme created. a developer could replace the global
		//style providers with different ones.
		//for (type in this._classToStyleProvider.keys())
		//{
			//this.clearStyleProvider(type);
		//}
		for (type in this._classList)
		{
			this.clearStyleProvider(type);
		}
		this._classToStyleProvider.clear();
		this._classToStyleProvider = null;
	}
	
	/**
	 * Determines if an <code>IStyleProvider</code> for the specified
	 * component class has been created.
	 *
	 * @param forClass	The class that may have a style provider.
	 */
	public function hasStyleProvider(forClass:Class<Dynamic>):Bool
	{
		if (this._classToStyleProvider == null)
		{
			return false;
		}
		return this._classToStyleProvider.exists(Type.getClassName(forClass));
	}
	
	/**
	 * Returns all classes that have been registered with a style provider.
	 */
	public function getRegisteredClasses(result:Array<Class<Dynamic>> = null):Array<Class<Dynamic>>
	{
		if (result != null)
		{
			result.resize(0);
		}
		else
		{
			//result = new Array<Class<Dynamic>>();
			return this._classList.copy();
		}
		
		var count:Int = this._classList.length;
		for (i in 0...count)
		{
			result[i] = this._classList[i];
		}
		//for (forClass in this._classToStyleProvider.keys())
		//{
			//result[index] = forClass;
			//index++;
		//}
		return result;
	}
	
	/**
	 * Creates an <code>IStyleProvider</code> for the specified component
	 * class, or if it was already created, returns the existing registered
	 * style provider. If the registry is global, a newly created style
	 * provider will be passed to the static <code>globalStyleProvider</code>
	 * property of the specified class.
	 *
	 * @param forClass					The style provider is registered for this class.
	 * @param styleProviderFactory		A factory used to create the style provider.
	 */
	public function getStyleProvider(forClass:Class<Dynamic>):IStyleProvider
	{
		var className:String = Type.getClassName(forClass);
		this.validateComponentClass(forClass);
		var styleProvider:IStyleProvider = this._classToStyleProvider[className];
		if (styleProvider == null)
		{
			styleProvider = this._styleProviderFactory();
			this._classToStyleProvider[className] = styleProvider;
			_classList.push(forClass);
			if (this._registerGlobally)
			{
				//forClass[GLOBAL_STYLE_PROVIDER_PROPERTY_NAME] = styleProvider;
				Reflect.setProperty(forClass, GLOBAL_STYLE_PROVIDER_PROPERTY_NAME, styleProvider);
			}
		}
		return styleProvider;
	}
	
	/**
	 * Removes the style provider for the specified component class. If the
	 * registry is global, and the static <code>globalStyleProvider</code>
	 * property contains the same value, it will be set to <code>null</code>.
	 * If it contains a different value, then it will be left unchanged to
	 * avoid conflicts with other registries or code.
	 *
	 * @param forClass		The style provider is registered for this class.
	 */
	public function clearStyleProvider(forClass:Class<Dynamic>):IStyleProvider
	{
		var className:String = Type.getClassName(forClass);
		this.validateComponentClass(forClass);
		if (this._classToStyleProvider.exists(className))
		{
			var styleProvider:IStyleProvider = this._classToStyleProvider[className];
			this._classToStyleProvider.remove(className);
			this._classList.remove(forClass);
			if (this._registerGlobally &&
				Reflect.field(forClass, GLOBAL_STYLE_PROVIDER_PROPERTY_NAME) == styleProvider)
				//forClass[GLOBAL_STYLE_PROVIDER_PROPERTY_NAME] == styleProvider)
			{
				//something else may have changed the global style provider
				//after this registry set it, so we check if it's equal
				//before setting to null.
				//forClass[GLOBAL_STYLE_PROVIDER_PROPERTY_NAME] = null;
				Reflect.setField(forClass, GLOBAL_STYLE_PROVIDER_PROPERTY_NAME, null);
			}
			return styleProvider;
		}
		return null;
	}
	
	/**
	 * @private
	 */
	private function validateComponentClass(type:Class<Dynamic>):Void
	{
		//if (!this._registerGlobally || Object(type).hasOwnProperty(GLOBAL_STYLE_PROVIDER_PROPERTY_NAME))
		//if (!this._registerGlobally || Reflect.hasField(type, GLOBAL_STYLE_PROVIDER_PROPERTY_NAME))
		//trace(Reflect.getProperty(type, "no_property"));
		#if html5
		// TODO : find a better way of checking that a property exists in JS
		//if (!this._registerGlobally || Type.getClassFields(type).contains(GLOBAL_STYLE_PROVIDER_PROPERTY_NAME))
		//if (untyped '"globalStyleProvider" in type')
		if (!this._registerGlobally || untyped 'GLOBAL_STYLE_PROVIDER_PROPERTY_NAME in type')
		#else
		if (!this._registerGlobally || Reflect.hasField(type, GLOBAL_STYLE_PROVIDER_PROPERTY_NAME))
		#end
		{
			return;
		}
		throw new ArgumentError("Class " + Type.getClassName(type) + " must have a " + GLOBAL_STYLE_PROVIDER_PROPERTY_NAME + " static property to support themes.");
	}
	
}