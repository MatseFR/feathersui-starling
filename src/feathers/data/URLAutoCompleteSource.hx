/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.data;

import feathers.utils.type.ArgumentsCount;
import feathers.utils.type.SafeCast;
import haxe.Constraints.Function;
import openfl.events.ErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.SecurityErrorEvent;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import starling.events.EventDispatcher;

/**
 * Creates a list of suggestions for an <code>AutoComplete</code> component
 * by loading data from a URL.
 *
 * <p>Data may be filtered on the server or on the client. The
 * <code>urlRequestFunction</code> may be used to include the text from the
 * <code>AutoComplete</code> in the request sent to the server.
 * Alternatively, the <code>parseResultFunction</code> may filter the
 * result on the client.</p>
 *
 * <p>By default, the <code>URLAutoCompleteSource</code> will parse a JSON
 * string. However, a custom <code>parseResultFunction</code> may be
 * provided to parse other formats.</p>
 *
 * @see feathers.controls.AutoComplete
 *
 * @productversion Feathers 2.1.0
 */
class URLAutoCompleteSource extends EventDispatcher 
{
	/**
	 * @private
	 */
	private static function defaultParseResultFunction(result:String):Dynamic
	{
		return JSON.parse(result);
	}
	
	/**
	 * Constructor.
	 */
	public function new(urlRequestFunction:Function, parseResultFunction:Function = null) 
	{
		super();
		this.urlRequestFunction = urlRequestFunction;
		this.parseResultFunction = parseResultFunction;
	}
	
	/**
	 * @private
	 */
	private var _cachedResult:String;
	
	/**
	 * A function called by the auto-complete source that builds the
	 * <code>flash.net.URLRequest</code> that is to be loaded.
	 *
	 * <p>The function is expected to have one of the following signatures:</p>
	 * <pre>function( textToMatch:String ):URLRequest</pre>
	 * <pre>function():URLRequest</pre>
	 *
	 * <p>The function may optionally accept one argument, the text
	 * entered into the <code>AutoComplete</code> component. If available,
	 * this argument should be included in the <code>URLRequest</code>, and
	 * the server-side script should use it to return a pre-filtered result.
	 * Alternatively, if the function accepts zero arguments, a static URL
	 * will be called, and the <code>parseResultFunction</code> may be used
	 * to filter the result on the client side instead.</p>
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/URLRequest.html Full description of flash.net.URLRequest in Adobe's Flash Platform API Reference
	 * @see #parseResultFunction
	 */
	public var urlRequestFunction(get, set):Function;
	private var _urlRequestFunction:Function;
	private function get_urlRequestFunction():Function { return this._urlRequestFunction; }
	private function set_urlRequestFunction(value:Function):Function
	{
		if (this._urlRequestFunction == value)
		{
			return value;
		}
		this._urlRequestFunction = value;
		this._cachedResult = null;
		return this._urlRequestFunction;
	}
	
	/**
	 * A function that parses the result loaded from the URL. Any plain-text
	 * data format may be accepted by providing a custom parse function. The
	 * default function parses the result as JSON.
	 *
	 * <p>The function is expected to have one of the following signatures:</p>
	 * <pre>function( loadedText:String ):Object</pre>
	 * <pre>function( loadedText:String, textToMatch:String ):Object</pre>
	 *
	 * <p>The function may accept one or two arguments. The first argument
	 * is always the plain-text result returned from the URL. Optionally,
	 * the second argument is the text entered into the
	 * <code>AutoComplete</code> component. It may be used to filter the
	 * result on the client side. It is meant to be used when the
	 * <code>urlRequestFunction</code> accepts zero arguments and does not
	 * pass the text entered into the <code>AutoComplete</code> component
	 * to the server.</p>
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/JSON.html#parse() Full description of JSON.parse() in Adobe's Flash Platform API Reference
	 * @see #urlRequestFunction
	 */
	public var parseResultFunction(get, set):Function;
	private var _parseResultFunction:Function = defaultParseResultFunction;
	private function get_parseResultFunction():Function { return this._parseResultFunction; }
	private function set_parseResultFunction(value:Function):Function
	{
		if (value == null)
		{
			value = defaultParseResultFunction;
		}
		if (this._parseResultFunction == value)
		{
			return value;
		}
		this._cachedResult = null;
		return this._parseResultFunction = value;
	}
	
	/**
	 * @private
	 */
	private var _intermediateCollection:ListCollection = new ListCollection();

	/**
	 * @private
	 */
	private var _savedSuggestionsCollection:IListCollection;

	/**
	 * @private
	 */
	private var _savedTextToMatch:String;

	/**
	 * @private
	 */
	private var _urlLoader:URLLoader;
	
	/**
	 * @copy feathers.data.IAutoCompleteSource#load()
	 */
	public function load(textToMatch:String, suggestionsResult:IListCollection = null):Void
	{
		if (!suggestionsResult)
		{
			suggestionsResult = new ArrayCollection();
		}
		var urlRequestFunction:Function = this._urlRequestFunction;
		var request:URLRequest;
		if (ArgumentsCount.count_args(urlRequestFunction) == 1)
		{
			request = cast urlRequestFunction(textToMatch);
		}
		else
		{
			if (this._cachedResult != null)
			{
				this.parseData(this._cachedResult, textToMatch, suggestionsResult);
				return;
			}
			request = cast urlRequestFunction();
		}
		this._savedSuggestionsCollection = suggestionsResult;
		this._savedTextToMatch = textToMatch;
		if (this._urlLoader != null)
		{
			this._urlLoader.close();
		}
		else
		{
			this._urlLoader = new URLLoader();
			this._urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			this._urlLoader.addEventListener(openfl.events.Event.COMPLETE, urlLoader_completeHandler);
			this._urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoader_errorHandler);
			this._urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoader_errorHandler);
		}
		this._urlLoader.load(request);
	}
	
	/**
	 * @private
	 */
	private function parseData(resultText:String, textToMatch:String, suggestions:IListCollection):Void
	{
		var parseResultFunction:Function = this._parseResultFunction;
		if (ArgumentsCount.count_args(parseResultFunction) == 2)
		{
			//this is kind of hacky, and maybe it would be better to modify
			//parseResultFunction to return an IListCollection
			this._intermediateCollection.data = parseResultFunction(resultText, textToMatch);
		}
		else
		{
			this._intermediateCollection.data = parseResultFunction(resultText);
		}
		suggestions.reset(this._intermediateCollection);
		this.dispatchEventWith(starling.events.Event.COMPLETE, false, suggestions);
	}
	
	/**
	 * @private
	 */
	private function urlLoader_completeHandler(event:openfl.events.Event):Void
	{
		var suggestions:IListCollection = this._savedSuggestionsCollection;
		this._savedSuggestionsCollection = null;
		var textToMatch:String = this._savedTextToMatch;
		this._savedTextToMatch = null;
		
		var loadedData:String = SafeCast.safe_cast(this._urlLoader.data, String);
		if (ArgumentsCount.count_args(this._urlRequestFunction) == 0)
		{
			this._cachedResult = loadedData;
		}
		if (loadedData != null)
		{
			this.parseData(loadedData, textToMatch, suggestions);
		}
		else
		{
			suggestions.removeAll();
			this.dispatchEventWith(starling.events.Event.COMPLETE, false, suggestions);
		}
	}
	
	/**
	 * @private
	 */
	private function urlLoader_errorHandler(event:ErrorEvent):Void
	{
		var result:IListCollection = this._savedSuggestionsCollection;
		result.removeAll();
		this._savedSuggestionsCollection = null;
		this.dispatchEventWith(starling.events.Event.COMPLETE, false, result);
	}
	
}