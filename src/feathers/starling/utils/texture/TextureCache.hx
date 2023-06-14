/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.utils.texture;
import feathers.starling.utils.math.MathUtils;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;
import starling.textures.Texture;

/**
 * Caches textures in memory. Each texture may be saved with its own key,
 * such as the URL where the original image file is located.
 *
 * <p><strong>Note:</strong> Most developers will only need to create a
 * <code>TextureCache</code>, pass it to multiple <code>ImageLoader</code>
 * components, and dispose the cache when finished. APIs to retain and
 * release textures are meant to be used by <code>ImageLoader</code>.</p>
 *
 * <p>A single <code>TextureCache</code> may be passed to multiple
 * <code>ImageLoader</code> components using the <code>textureCache</code>
 * property:</p>
 *
 * <listing version="3.0">
 * var cache:TextureCache = new TextureCache();
 * loader1.textureCache = cache;
 * loader2.textureCache = cache;</listing>
 *
 * <p>Don't forget to dispose the <code>TextureCache</code> when it is no
 * longer needed -- to avoid memory leaks:</p>
 *
 * <listing version="3.0">
 * cache.dispose();</listing>
 *
 * <p>To use a TextureCache in a <code>List</code> or
 * <code>GroupedList</code> with the default item renderer, pass the cache
 * to the <code>ImageLoader</code> components using the
 * <code>iconLoaderFactory</code> or
 * <code>accessoryLoaderFactory</code>:</p>
 *
 * <listing version="3.0">
 * var cache:TextureCache = new TextureCache();
 * list.itemRendererFactory = function():IListItemRenderer
 * {
 *     var itemRenderer:DefaultListItemRenderer = new DefaultListItemRenderer();
 *     itemRenderer.iconLoaderFactory = function():ImageLoader
 *     {
 *         var loader:ImageLoader = new ImageLoader();
 *         loader.textureCache = cache;
 *         return loader;
 *     };
 *     return itemRenderer;
 * };</listing>
 *
 * @see feathers.controls.ImageLoader#textureCache
 *
 * @productversion Feathers 2.3.0
 */
class TextureCache 
{
	/**
	 * Constructor.
	 */
	public function new(maxUnretainedTextures:Int = MathUtils.INT_MAX) 
	{
		this._maxUnretainedTextures = maxUnretainedTextures;
	}
	
	/**
	 * @private
	 */
	private var _unretainedKeys:Array<String> = new Array<String>();
	
	/**
	 * @private
	 */
	private var _unretainedTextures:Map<String, Texture> = new Map<String, Texture>();

	/**
	 * @private
	 */
	private var _retainedTextures:Map<String, Texture> = new Map<String, Texture>();

	/**
	 * @private
	 */
	private var _retainCounts:Map<String, Int> = new Map<String, Int>();
	
	/**
	 * Limits the number of unretained textures that may be stored in
	 * memory. The textures retained least recently will be disposed if
	 * there are too many.
	 */
	public var maxUnretainedTextures(get, set):Int;
	private var _maxUnretainedTextures:Int;
	private function get_maxUnretainedTextures():Int { return this._maxUnretainedTextures; }
	private function set_maxUnretainedTextures(value:Int):Int
	{
		if (this._maxUnretainedTextures == value)
		{
			return value;
		}
		this._maxUnretainedTextures = value;
		if (this._unretainedKeys.length > value)
		{
			this.trimCache();
		}
		return this._maxUnretainedTextures;
	}
	
	/**
	 * Disposes the texture cache, including all textures (even if they are
	 * retained).
	 */
	public function dispose():Void
	{
		for (texture in this._unretainedTextures)
		{
			texture.dispose();
		}
		for (texture in this._retainedTextures)
		{
			texture.dispose();
		}
		this._retainedTextures.clear();
		this._retainedTextures = null;
		this._unretainedTextures.clear();
		this._unretainedTextures = null;
		this._retainCounts.clear();
		this._retainCounts = null;
	}
	
	/**
	 * Saves a texture, and associates it with a specific key.
	 *
	 * @see #removeTexture()
	 * @see #hasTexture()
	 */
	public function addTexture(key:String, texture:Texture, retainTexture:Bool = true):Void
	{
		if (this._retainedTextures == null)
		{
			throw new IllegalOperationError("Cannot add a texture after the cache has been disposed.");
		}
		if (this._unretainedTextures.exists(key) || this._retainedTextures.exists(key))
		{
			throw new ArgumentError("Key \"" + key + "\" already exists in the cache.");
		}
		if (retainTexture)
		{
			this._retainedTextures[key] = texture;
			this._retainCounts[key] = 1;
			return;
		}
		this._unretainedTextures[key] = texture;
		this._unretainedKeys[this._unretainedKeys.length] = key;
		if (this._unretainedKeys.length > this._maxUnretainedTextures)
		{
			this.trimCache();
		}
	}
	
	/**
	 * Removes a specific key from the cache, and optionally disposes the
	 * texture associated with the key.
	 *
	 * @see #addTexture()
	 */
	public function removeTexture(key:String, dispose:Bool = false):Void
	{
		if (this._unretainedTextures == null)
		{
			return;
		}
		var texture:Texture = this._unretainedTextures[key];
		if (texture != null)
		{
			this.removeUnretainedKey(key);
		}
		else
		{
			texture = this._retainedTextures[key];
			this._retainedTextures.remove(key);
			this._retainCounts.remove(key);
		}
		if (dispose && texture != null)
		{
			texture.dispose();
		}
	}
	
	/**
	 * Indicates if a texture is associated with the specified key.
	 */
	public function hasTexture(key:String):Bool
	{
		if (this._retainedTextures == null)
		{
			return false;
		}
		return this._retainedTextures.exists(key) || this._unretainedTextures.exists(key);
	}
	
	/**
	 * Returns how many times the texture associated with the specified key
	 * has currently been retained.
	 */
	public function getRetainCount(key:String):Int
	{
		if (this._retainCounts != null && this._retainCounts.exists(key))
		{
			return this._retainCounts[key];
		}
		return 0;
	}
	
	/**
	 * Gets the texture associated with the specified key, and increments
	 * the retain count for the texture. Always remember to call
	 * <code>releaseTexture()</code> when finished with a retained texture.
	 *
	 * @see #releaseTexture()
	 */
	public function retainTexture(key:String):Texture
	{
		if (this._retainedTextures == null)
		{
			throw new IllegalOperationError("Cannot retain a texture after the cache has been disposed.");
		}
		if (this._retainedTextures.exists(key))
		{
			var count:Int = this._retainCounts[key];
			count++;
			this._retainCounts[key] = count;
			return this._retainedTextures[key];
		}
		
		if (!this._unretainedTextures.exists(key))
		{
			throw new ArgumentError("Texture with key \"" + key + "\" cannot be retained because it has not been added to the cache.");
		}
		var texture:Texture = this._unretainedTextures[key];
		this.removeUnretainedKey(key);
		this._retainedTextures[key] = texture;
		this._retainCounts[key] = 1;
		return texture;
	}
	
	/**
	 * Releases a retained texture.
	 *
	 * @see #retainTexture()
	 */
	public function releaseTexture(key:String):Void
	{
		if (this._retainedTextures == null || !this._retainedTextures.exists(key))
		{
			return;
		}
		var count:Int = this._retainCounts[key];
		count--;
		if (count == 0)
		{
			//get the existing texture
			var texture:Texture = this._retainedTextures[key];
			
			//remove from retained
			this._retainCounts.remove(key);
			this._retainedTextures.remove(key);
			
			this._unretainedTextures[key] = texture;
			this._unretainedKeys[this._unretainedKeys.length] = key;
			if (this._unretainedKeys.length > this._maxUnretainedTextures)
			{
				this.trimCache();
			}
		}
		else
		{
			this._retainCounts[key] = count;
		}
	}
	
	/**
	 * @private
	 */
	private function removeUnretainedKey(key:String):Void
	{
		var index:Int = this._unretainedKeys.indexOf(key);
		if (index < 0)
		{
			return;
		}
		this._unretainedKeys.splice(index, 1);
		this._unretainedTextures.remove(key);
	}
	
	/**
	 * @private
	 */
	private function trimCache():Void
	{
		var currentCount:Int = this._unretainedKeys.length;
		var maxCount:Int = this._maxUnretainedTextures;
		while (currentCount > maxCount)
		{
			var key:String = this._unretainedKeys.shift();
			var texture:Texture = this._unretainedTextures[key];
			texture.dispose();
			this._unretainedTextures.remove(key);
			currentCount--;
		}
	}
	
}