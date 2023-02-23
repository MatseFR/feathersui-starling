package feathers.motion.effectClasses;

import feathers.core.IFeathersControl;
import haxe.Constraints.Function;
import starling.animation.Transitions;
import starling.animation.Tween;
import starling.display.DisplayObject;
import starling.utils.Execute;

/**
 * ...
 * @author Matse
 */
class TweenEffectContext extends BaseEffectContext 
{
	/**
	 * Constructor.
	 */
	public function new(target:DisplayObject, tween:Tween, interruptBehavior:String = EffectInterruptBehavior.END) 
	{
		this._tween = tween;
		this._interruptBehavior = interruptBehavior;
		var linearTransitionFunc:Float->Float = Transitions.getTransition(Transitions.LINEAR);
		var transitionFunc:Float->Float = this._tween.transitionFunc;
		//we want setting the position property to be linear, but when
		//play() or playReverse() is called, we'll use the saved transition
		this._tween.transitionFunc = linearTransitionFunc;
		
		//we'll take over for onStart and onComplete because we don't them
		//being called by the Tween, since we're taking over control
		this._onStart = this._tween.onStart;
		this._onComplete = this._tween.onComplete;
		this._tween.onStart = null;
		this._tween.onComplete = null;
		
		if (target == null)
		{
			target = cast tween.target;
		}
		
		//the delay does not affect the totalTime, so we need to add them
		//to calculate the full duration of the effect
		super(target, this._tween.totalTime + this._tween.delay, transitionFunc);
	}
	
	/**
	 * The tween that is controlled by the effect.
	 */
	public var tween(get, never):Tween;
	private var _tween:Tween;
	private function get_tween():Tween { return this._tween; }
	
	/**
	 * Indicates how the effect behaves when it is interrupted. Interrupted
	 * effects can either advance directly to the end or stop at the current
	 * position.
	 *
	 * @default feathers.motion.EffectInterruptBehavior.END
	 *
	 * @see feathers.motion.EffectInterruptBehavior#END
	 * @see feathers.motion.EffectInterruptBehavior#STOP
	 * @see #interrupt()
	 */
	public var interruptBehavior(get, set):String;
	private var _interruptBehavior:String;
	private function get_interruptBehavior():String { return this._interruptBehavior; }
	private function set_interruptBehavior(value:String):String
	{
		return this._interruptBehavior = value;
	}
	
	/**
	 * @private
	 */
	private var _onStart:Function = null;

	/**
	 * @private
	 */
	private var _onComplete:Function = null;
	
	/**
	 * @private
	 *
	 * @see #interruptBehavior
	 */
	override public function interrupt():Void
	{
		if (this._interruptBehavior == EffectInterruptBehavior.STOP)
		{
			this.stop();
			return;
		}
		this.toEnd();
	}
	
	/**
	 * @private
	 */
	override function prepareEffect():Void
	{
		if (this._onStart != null)
		{
			//this._onStart.apply(null, this._tween.onStartArgs);
			Execute.execute(this._onStart, this._tween.onStartArgs);
		}
	}
	
	/**
	 * @private
	 */
	override function updateEffect():Void
	{
		if (Std.isOfType(this._target, IFeathersControl))
		{
			cast(this._target, IFeathersControl).suspendEffects();
		}
		var duration:Float = this._tween.totalTime + this._tween.delay;
		var newCurrentTime:Float = (this._position * duration) - this._tween.delay;
		this._tween.advanceTime(newCurrentTime - this._tween.currentTime);
		if (Std.isOfType(this._target, IFeathersControl))
		{
			cast(this._target, IFeathersControl).resumeEffects();
		}
	}
	
	/**
	 * @private
	 */
	override function cleanupEffect():Void
	{
		if (this._onComplete != null)
		{
			//this._onComplete.apply(null, this._tween.onCompleteArgs);
			Execute.execute(this._onComplete, this._tween.onCompleteArgs);
		}
	}
	
}