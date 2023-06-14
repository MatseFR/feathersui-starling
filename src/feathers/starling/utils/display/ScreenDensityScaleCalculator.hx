/*
Feathers
Copyright 2012-2021 Bowler Hat LLC. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.starling.utils.display;
import openfl.errors.ArgumentError;
import openfl.errors.IllegalOperationError;

/**
 * Selects a value for <code>contentScaleFactor</code> based on the screen
 * density (sometimes called DPI or PPI).
 *
 * @productversion Feathers 3.1.0
 */
class ScreenDensityScaleCalculator 
{
	/**
	 * Constructor.
	 */
	public function new() 
	{
		
	}
	
	/**
	 * @private
	 */
	private var _buckets:Array<ScreenDensityBucket> = new Array<ScreenDensityBucket>();
	
	/**
	 * Adds a new scale for the specified density.
	 *
	 * <listing version="3.0">
	 * selector.addScaleForDensity( 160, 1 );
	 * selector.addScaleForDensity( 240, 1.5 );
	 * selector.addScaleForDensity( 320, 2 );
	 * selector.addScaleForDensity( 480, 3 );</listing>
	 */
	public function addScaleForDensity(density:Int, scale:Float):Void
	{
		var bucketCount:Int = this._buckets.length;
		var index:Int = -1;
		var bucket:ScreenDensityBucket;
		for (i in 0...bucketCount)
		{
			bucket = this._buckets[i];
			if (bucket.density > density)
			{
				index = i;
				break;
			}
			if (bucket.density == density)
			{
				throw new ArgumentError("Screen density cannot be added more than once: " + density);
			}
		}
		this._buckets.insert(index, new ScreenDensityBucket(density, scale));
	}
	
	/**
	 * Removes a scale that was added with
	 * <code>addScaleForDensity()</code>.
	 *
	 * <listing version="3.0">
	 * selector.addScaleForDensity( 320, 2 );
	 * selector.removeScaleForDensity( 320 );</listing>
	 */
	public function removeScaleForDensity(density:Int):Void
	{
		var bucketCount:Int = this._buckets.length;
		var bucket:ScreenDensityBucket;
		for (i in 0...bucketCount)
		{
			bucket = this._buckets[i];
			if (bucket.density == density)
			{
				this._buckets.splice(i, 1);
				return;
			}
		}
	}
	
	/**
	 * Returns the ideal <code>contentScaleFactor</code> value for the
	 * specified density.
	 */
	public function getScale(density:Int):Float
	{
		if (this._buckets.length == 0)
		{
			throw new IllegalOperationError("Cannot choose scale because none have been added");
		}
		var bucket:ScreenDensityBucket = this._buckets[0];
		if (density <= bucket.density)
		{
			return bucket.scale;
		}
		var previousBucket:ScreenDensityBucket = bucket;
		var bucketCount:Int = this._buckets.length;
		var midDPI:Float;
		for (i in 1...bucketCount)
		{
			bucket = this._buckets[i];
			if (density > bucket.density)
			{
				previousBucket = bucket;
				continue;
			}
			midDPI = (bucket.density + previousBucket.density) / 2;
			if (density < midDPI)
			{
				return previousBucket.scale;
			}
			return bucket.scale;
		}
		return bucket.scale;
	}
	
}


class ScreenDensityBucket
{
	public function new(dpi:Float, scale:Float) 
	{
		this.density = dpi;
		this.scale = scale;
	}
	
	public var density:Float;
	public var scale:Float;
}