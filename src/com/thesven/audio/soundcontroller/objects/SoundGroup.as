package com.thesven.audio.soundcontroller.objects {
	import com.thesven.audio.soundcontroller.utils.SoundControllerUtils;
	

	/**
	 * @author michaelsvendsen
	 */
	public class SoundGroup extends Object {
		
		protected var   _name:String;
		protected var   _items:Vector.<SoundObject>;
		
		public function SoundGroup(groupItems:Vector.<SoundObject>) {
		
			if(groupItems != null) {
				_items = groupItems;			
			} else {
				_items = new Vector.<SoundObject>();
			}
		}
		
		public function addSoundObjectToGroup(snd:SoundObject):Boolean{
			if(!checkForExistingName(snd.name)){
				
				_items.push(snd);
				
			} else {
				SoundControllerUtils.throwError('SoundGroup', 'addSoundObjectToGroup', 'there is already a sound in the group with that name ::' + snd.name);	
			}
			return true;
		}
		
		public function removeSoundObjectFromGroup(sndName:String):void{
			
			if(checkForExistingName(sndName)){
				
				for(var i:int = 0; i < _items.length; i++){
					if(_items[i].name == sndName) {
						_items.splice(i, 1);
					}
				}
				
			} else {
				SoundControllerUtils.throwError('SoundGroup', 'removeSoundObjectFromGroup', 'there is no sound in the group with the name ::' + sndName);	
			}
			
		}

		public function playGroup():void{
			
			if(_items.length > 0) {
				for each(var s:SoundObject in _items) {
					s.play();
				}
			} else {
				SoundControllerUtils.throwError('SoundGroup', 'playGroup', 'there are no sounds in the group ::' + _name);	
			}
			
		}
		
		public function pauseGroup():void{
			
			if(_items.length > 0) {
				for each(var s:SoundObject in _items) {
					s.pause();
				}
			} else {
				SoundControllerUtils.throwError('SoundGroup', 'pauseGroup', 'there are no sounds in the group ::' + _name);	
			}
		}
		
		public function stopGroup():void{
			
			if(_items.length > 0) {
				for each(var s:SoundObject in _items) {
					s.stop();
				}
			} else {
				SoundControllerUtils.throwError('SoundGroup', 'stopGroup', 'there are no sounds in the group ::' + _name);	
			}
		}
		
		public function fadeGroupToTargetVolume(targetFadeVol:Number, fadeTimeInSeconds:Number):void{
			if(_items.length > 0) {
				for each(var s:SoundObject in _items) {
					s.fadeToTargetVolume(targetFadeVol, fadeTimeInSeconds);
				}
			} else {
				SoundControllerUtils.throwError('SoundGroup', 'fadeGroupToTargetVolume', 'there are no sounds in the group ::' + _name);	
			}	
		}

		public function destroy():void {
			_items = null;
		}

		private function checkForExistingName(nameToCheck:String):Boolean{
			
			for each(var s:SoundObject in _items) {
				if(s.name == nameToCheck) {
					return true;
				}
			}
			return false;
		}
		
		public function set name(theName:String):void{
			_name = theName;
		}

		public function get name():String{
			return _name;
		}
		
	}
}
