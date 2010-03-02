package com.thesven.audio.soundcontroller.objects {
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.Timer;

	/**
	 * @author michaelsvendsen
	 */
	public class SoundObject extends Object {
		
		protected var   _name:String;
		protected var   _sound:Sound;
		protected var   _channel:SoundChannel;
		protected var   _position:Number;
		protected var   _paused:Boolean;
		protected var   _volume:Number;
		protected var   _startTime:Number;
		protected var   _loops:int;
		protected var   _muted:Boolean;
		
		//variables used for fading
		protected var   _targetFadeVal:Number;
		protected var   _targetFadeDivisor:Number;
		protected var   _tweeningVol:Number;
		protected var   _fadeDirection:String;
		
		protected static const   FADE_UP:String = 'fadeUP';
		protected static const   FADE_DOWN:String = 'fadeDOWN';
		
		public function SoundObject(sndName:String, snd:Sound, vol:Number, startingTime:Number, loopAmount:int) {
		
			_name = sndName;
			_sound = snd;
			_channel = new SoundChannel();
			_position = 0;
			_paused = true;
			_volume = vol;
			_startTime = startingTime;
			_loops = loopAmount;
			_muted = false;
			
			_channel.addEventListener(Event.SOUND_COMPLETE, _soundComplete);
		}
		
		public function destroy():void{
			
			stop();
			
			_channel.removeEventListener(Event.SOUND_COMPLETE, _soundComplete);
			_channel = null;
			_sound = null;
			
		}

		public function play():void{
			
			if(!_muted) {
				var playVolume:Number = (_muted) ? 0 : _volume;
				var newStartTime:Number = (_paused) ? _position : _startTime;
				_channel = _sound.play(newStartTime, loops, new SoundTransform(playVolume));
				_paused = false;
			}
			
		}
		
		public function pause():void{
			
			_paused = true;
			_position = _channel.position;
			_channel.stop();
			
		}

		public function stop():void{
			
			_paused = true;
			_position = _startTime;
			_channel.stop();
			
		}
		
		public function fadeToTargetVolume(targetFadeVol:Number, fadeTimeInSeconds:Number):void{
			if(!this._paused) {
				_targetFadeVal = targetFadeVol;
				
				var totalFadeTime:Number = fadeTimeInSeconds * 1000;
				var stepAmount : int = (fadeTimeInSeconds * 10) - 1;
				var stepTime:Number = Math.ceil(totalFadeTime / stepAmount);
				
				_targetFadeDivisor = (Math.max(volume, targetFadeVol) - Math.min(volume, targetFadeVol)) / stepAmount;
				_fadeDirection = (volume > targetFadeVol) ? SoundObject.FADE_DOWN : SoundObject.FADE_UP ;
				_tweeningVol = _volume;
				
				var fadeTimer:Timer = new Timer(stepTime, stepAmount);
				fadeTimer.addEventListener(TimerEvent.TIMER, _handleFadeTimerTick);
				fadeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _handleFadeTimerComplete);
				fadeTimer.start();
				
			}
		}

		public function set name(theName:String):void{
			_name = theName;
		}

		public function get name():String{
			return _name;
		}
		
		public function set volume(theVol:Number):void {
			_volume = theVol;
		}

		public function get volume():Number{
			return _volume;
		}
		
		public function set startTime(theStartTime:Number):void {
			_startTime = theStartTime;
		}

		public function get startTime():Number{
			return _startTime;
		}
		
		public function set loops(loopAmount:int):void {
			_loops = loopAmount;
		}

		public function get loops():int{
			return _loops;
		}
		
		public function set paused(isPaused:Boolean):void {
			_paused = isPaused;
		}

		public function get paused():Boolean{
			return _paused;
		}

		protected function _soundComplete(e:Event):void {
			_paused = true;
		}
		
		protected function _handleFadeTimerTick(e : TimerEvent) : void {
			
			var transform:SoundTransform = _channel.soundTransform;
			var curVolume:Number = transform.volume;
			
			if(_fadeDirection == SoundObject.FADE_DOWN) _tweeningVol = curVolume - _targetFadeDivisor;
			if(_fadeDirection == SoundObject.FADE_UP) _tweeningVol = curVolume + _targetFadeDivisor;
			if(_tweeningVol < 0) _tweeningVol = 0;
			if(_tweeningVol > 1) _tweeningVol = 1;
			
			transform.volume = _tweeningVol;
			_channel.soundTransform = transform;
		}

		protected function _handleFadeTimerComplete(e : TimerEvent) : void {
			(e.target as Timer).removeEventListener(TimerEvent.TIMER, _handleFadeTimerTick);
			(e.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE, _handleFadeTimerComplete);
		}
		
	}
}
