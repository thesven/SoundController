package com.thesven.audio.soundcontroller {
	import com.thesven.audio.soundcontroller.objects.SoundGroup;
	import com.thesven.audio.soundcontroller.objects.SoundObject;
	
	import com.thesven.audio.soundcontroller.utils.SoundControllerUtils;

	import flash.events.DataEvent;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	/**
	 * @author michaelsvendsen
	 */
	public class SoundController extends EventDispatcher {
		 
		protected static   var   _soundController:SoundController = new SoundController();
		
		protected var   _soundsDict:Dictionary = new Dictionary(true);
		protected var   _soundGroupDict:Dictionary = new Dictionary(true);
		protected var   _sounds:Vector.<SoundObject> = new Vector.<SoundObject>();
		protected var   _soundGroups:Vector.<SoundGroup> = new Vector.<SoundGroup>();
			
		//events
		public   static   const   SOUND_ADDED:String = 'aSoundHasBeenAddedToSoundController';
		public   static   const   SOUND_REMOVED:String = 'aSoundHasBeenRemovedFromSoundController';
		public   static   const   GROUP_ADDED:String = 'aSoundGroupHasBeenAddedToSoundController';
		public   static   const   GROUP_REMOVED:String = 'aSoundGroupHasBeenRemovedToSoundController';
		public   static   const   GLOBAL_VOLUME_CHANGE:String = 'theGlobalVolumeHasBeenChanged';
		
		/**
		 * <p>Main Constructor</p>
		 * <p>PLEASE DO NOT USE THIS</p>
		 * <p>SoundController is a singleton class.  You will need to use the getInstance() method</p>
		 * @see getInstance
		 */
		public function SoundController() {
			if(_soundController) {
				SoundControllerUtils.throwError('SoundController', 'SoundController [constructor]', 'The SoundController class is a singleton. Please use the getInstance() method');
			}
		}
		
		/**
		 * <p>Used to return the current instance of the class</p>
		 * <p>Please use this insted of the Main Constructor</p>
		 * @return SoundController
		 */
		public static function getInstance():SoundController{
			return _soundController;
		}
		
		/**
		 * <p>Used to add a sound that is extrnaly located</p>
		 * <p>Dispatches the SOUND_ADDED DataEvent with a value of "sndName"</p>
		 * @param sndPath:String - the direct path or url the sound you wish to use
		 * @param sndName:String - the name you wish you use for this sound
		 * @param buffer:Number - the amount of buffer to be used on the external sound
		 * @param vol:Number - the volume to be used when playing the sound
		 * @param startTime:Number - the start time to be used when playing the sound
		 * @param loops:int - the amount of loops this sound should be played
		 * @param checkPolicyFile:Boolean - is there a policy file that needs to be checked while loading the sound file
		 * @return Boolean
		 */
		public function addExternalSound(sndPath:String, sndName:String, buffer:Number = 1000, vol:Number = 1, startTime:Number = 0, loops:int = 0, checkPolicyFile:Boolean = false):Boolean{
			
			if(!checkForExistingName(sndName, "sound")){
				
				var newSnd:Sound = new Sound(new URLRequest(sndPath), new SoundLoaderContext(buffer, checkPolicyFile));
				var soundObj:SoundObject = new SoundObject(sndName, newSnd, vol, startTime, loops);
				_soundsDict[sndName] = soundObj;
				_sounds.push(soundObj);
				dispatchEvent(new DataEvent(SOUND_ADDED, true, false, sndName));
				
			} else {
				SoundControllerUtils.throwError('SoundController', 'addExternalSound', 'There is already a sound by the name ::' + sndName);
			}
			
			return true;
			
		}
		
		/**
		 * <p>Used to add a sound that has been added to your library or embeded as a class in your project</p>
		 * <p>Dispatches the SOUND_ADDED DataEvent with a value of "sndName"</p>
		 * @param sndClassName:Class - the class of the sound that you would like to use
		 * @param sndName:String - the name you wish to use for the sound
		 * @param vol:Number - the volume at which the sound should be played
		 * @param startTime:Number - the start time to be used when playing the sound
		 * @param loops:Number - the amount of loops that the should should be played
		 * @return Boolean
		 */
		public function addEmbededOrLibrarySound(sndClassName:Class, sndName:String, vol:Number = 1, startTime:Number = 0, loops:int = 0):Boolean{
			
			if(!checkForExistingName(sndName, "sound")){
				
				var newSnd:Sound = new sndClassName();
				var soundObj:SoundObject = new SoundObject(sndName, newSnd, vol, startTime, loops);
				_soundsDict[sndName] = soundObj;
				_sounds.push(soundObj);
				dispatchEvent(new DataEvent(SOUND_ADDED, true, false, sndName));
				
			} else {
				SoundControllerUtils.throwError('SoundController', 'addEmbededOrLibrarySound', 'There is already a sound by the name ::' + sndName);
			}
			
			return true;
			
		}
		
		/**
		 * <p>Used to create a new sound group</p>
		 * <p>In order to create a sound group all of the sounds must all ready be added using addEmbededOrLibrarySound or addExternalSound</p>
		 * <p>Using a sound group you can manage the state of one or more sounds by using a single call ie. play, stop, pause</p>
		 * <p>Individual sounds may be used in more than one group</p>
		 * <p>Dispatches the GROUP_ADDED DataEvent with a value of "sndGroupName"</p>
		 * @param sndGrpName:String - the name you wish to use for the sound group
		 * @param groupItems:String - a vector containing the names of the sound objects to be used in the sound group
		 * @return Boolean
		 * @see addEmbededOrLibrarySound
		 * @see addExternalSound
		 */
		public function createSoundGroup(sndGrpName:String, groupItems:Vector.<String>):Boolean{
			
			if(!checkForExistingName(sndGrpName, "group")){
				
				var objs:Vector.<SoundObject> = new Vector.<SoundObject>();
				for(var i:int = 0; i < groupItems.length; i++){
					
					if(checkForExistingName(groupItems[i], "sound")){
						objs.push(_soundsDict[groupItems[i]]);
					} else {
						SoundControllerUtils.throwError('SoundController', 'createSoundGroup', 'A sound with the name ::' + groupItems[i] + 'does not exist in the library');
					}
				}
				
				var sg:SoundGroup = new SoundGroup(objs);
				sg.name = sndGrpName;
				_soundGroups.push(sg);
				_soundGroupDict[sndGrpName] = sg;
				
				dispatchEvent(new DataEvent(GROUP_ADDED, true, false, sndGrpName));
			} else {
				SoundControllerUtils.throwError('SoundController', 'createSoundGroup', 'There is already a soundgroup with the name :: ' + sndGrpName);
			}
			
			return true;
			
		}
		
		/**
		 * <p>Used to remove a sound from the controller</p>
		 * <p>Once a sound is removed you will no longer be able to manage it through the SoundController, and all referances and listeners will be removed</p>
		 * <p>Dispatches the SOUND_REMOVED DataEvent with a value of "sndName"</p>
		 * @param sndName:String - the name of the sound you wish to remove
		 * @return Boolean
		 */
		public function removeSound(sndName:String):Boolean{
			
			if(checkForExistingName(sndName, "sound")){
				
				for(var i:int = 0; i < _sounds.length; i++){
					
					if(_sounds[i].name == sndName) {
						_sounds[i].destroy();
						_sounds[i] = null;
						_sounds.splice(i, 1);
						delete _soundsDict[sndName];
						dispatchEvent(new DataEvent(SOUND_REMOVED, true, false, sndName));
						break;
					}
					
					
				
				}
				
			} else {
				
				SoundControllerUtils.throwError('SoundController', 'removeSound', 'There is no sound by the name ::' + sndName);
			
			}
			
			return true;
			
		}
		
		/**
		 * <p>Used to remove all of the sounds from the controller</p>
		 * <p>Once a sound is removed you will no longer be able to manage it through the SoundController, and all referances and listeners will be removed</p>
		 * <p>Dispatches the SOUND_ADDED DataEvent with a value of "ALL SOUNDS"</p>
		 */
		public function removeAllSounds():void{
			
			for each(var s:SoundObject in _sounds) {
				s.destroy();
				s = null;
			}
			
			_sounds = new Vector.<SoundObject>();
			_soundsDict = new Dictionary(true);
			
			dispatchEvent(new DataEvent(SOUND_REMOVED, true, false, "ALL SOUNDS"));
		}

		/**
		 * <p>Used to remove a sound group from the controller</p>
		 * <p>Once a sound group is removed from the controller all referances and listeners will be removed.</p>
		 * <p>The sounds associated with the group will still remain the in controller</p>
		 * <p>Dispatches the GROUP_REMOVED DataEvent with a value of "sndGroupName"</p>
		 * @param sndGroupName:String - the name of the sound group you wish to remove
		 * @return Boolean
		 * @see removeSound
		 */
		public function removeSoundGroup(sndGroupName:String):Boolean{
			
			if(checkForExistingName(sndGroupName, "group")){
				
				for(var i:int = 0;i < _soundGroups.length; i++){
					
					if(_soundGroups[i].name == sndGroupName) {
						_soundGroups[i].destroy();
						_soundGroups[i] = null;
						_soundGroups.splice(i, 1);
						delete _soundGroupDict[sndGroupName];
						dispatchEvent(new DataEvent(GROUP_REMOVED, true, false, sndGroupName));
						break;
					}
					
					
				
				}
				
			} else {
				
				SoundControllerUtils.throwError('SoundController', 'removeSoundGroup', 'There is no sound group by the name ::' + sndGroupName);
			}
			
			return true;
		}
		
		/**
		 * <p>Used to play a sound that has been added to the controller</p>
		 * @param sndName:String - the name of the sound you wish to play
		 * @param useSndProps:String - would you like to use the current properties associated with the sound, or supply new ones through the method parameters
		 * @param volume:Number - if useSoundProps = true, this new volume will be used when playing the sound
		 * @param startTime:Number - if useSoundProps = true, this new startTime will be used when playing the sound
		 * @param loops:int - if useSoundProps = true, this amount will over ride the current amount of loops that the sound plays
		 * @param useDelay:Boolean - if true a delay will be used before playing the sound
		 * @param delayInSeconds:Number - if useDelay = true, the sound will be delayed "x" seconds before playing
		 */
		public function playSound(sndName:String, useSndProps:Boolean = true, volume:Number = 1, startTime:Number = 0, loops:int = 0, useDelay:Boolean = false, delayInSeconds:Number = 0):void{
			
			if(checkForExistingName(sndName, "sound")){
				
				var snd:SoundObject = _soundsDict[sndName];
				
				if(!useSndProps) {
					snd.volume = volume;
					snd.startTime = startTime;
					snd.loops = loops;
				}
				
				if(useDelay) {
					setTimeout(snd.play, delayInSeconds * 1000);
				} else {
					snd.play();	
				}
				
			} else {
				SoundControllerUtils.throwError('SoundController', 'playSound', 'There is no sound by the name ::' + sndName);
			}
			
		}
		
		/**
		 * <p>Used to play all of the sounds in the library at once</p>
		 */
		public function playAllSounds():void{
			if(_sounds.length > 1) {
			
				for each(var s:SoundObject in _sounds) {
					s.play();
				}
			
			} else {
				SoundControllerUtils.throwError('SoundController', 'playAllSounds', 'There are no sounds in the library');
			}
		}
		
		/**
		 * <p>Used to play a sound group that has been registered with the controller</p>
		 * @param groupName:String - the name of the sound group you wish to play
		 */
		public function playSoundGroup(groupName:String):void{
			
			if(checkForExistingName(groupName, "group")){
				
				var group:SoundGroup = _soundGroupDict[groupName];
				group.playGroup();
				
			} else {
				SoundControllerUtils.throwError('SoundController', 'playSoundGroup', 'There is no sound group by the name ::' + groupName);
			}
			
		}
		
		/**
		 * <p>used to pause a sound that is playing</p>
		 * @param sndName:String - the name of the sound you wish to pause
		 */
		public function pauseSound(sndName:String):void{
			if(checkForExistingName(sndName, "sound")){
				
				var snd:SoundObject = _soundsDict[sndName];
				snd.pause();
				
			} else {
				SoundControllerUtils.throwError('SoundController', 'pauseSound', 'There is no sound by the name ::' + sndName);
			}
		}
		
		/**
		 * <p>Used to pause all sounds in the controller</p>
		 */
		public function pauseAllSounds():void{
			if(_sounds.length > 1) {
			
				for each(var s:SoundObject in _sounds) {
					s.pause();
				}
			
			} else {
				SoundControllerUtils.throwError('SoundController', 'pauseAllSounds', 'There are no sounds in the library');
			}
		}
		
		/**
		 * <p>Used to pause a sound group that is currently playing</p>
		 * @param sndGroupName:String - the name of the sound group you would wish to pause
		 */
		public function pauseSoundGroup(sndGroupName:String):void{
			if(checkForExistingName(sndGroupName, "group")){
				
				var snd:SoundGroup = _soundGroupDict[sndGroupName];
				snd.pauseGroup();
				
			} else {
				SoundControllerUtils.throwError('SoundController', 'pauseSoundGroup', 'There is no sound group by the name ::' + sndGroupName);
			}
		}
		
		/**
		 * <p>Used to stop a sound</p>
		 * @param sndName:String - the name of the sound you wish to stop
		 */
		public function stopSound(sndName:String):void{
			if(checkForExistingName(sndName, "sound")){
				
				var snd:SoundObject = _soundsDict[sndName];
				snd.stop();
				
			} else {
				SoundControllerUtils.throwError('SoundController', 'stopSound', 'There is no sound by the name ::' + sndName);
			}
		}
		
		/**
		 * <p>Used to stop all sounds in the controller</p>
		 */
		public function stopAllSounds():void{
			
			if(_sounds.length > 1) {
			
				for each(var s:SoundObject in _sounds) {
					s.stop();
				}
			
			} else {
				SoundControllerUtils.throwError('SoundController', 'stopAllSounds', 'There are no sounds in the library');
			}
			
		}
		
		/**
		 * <p>Used to stop a sound group that has been registered with the controller</p>
		 * @param sndGroupName:String - the name of the sound group you wish to stop
		 */
		public function stopSoundGroup(sndGroupName:String):void{
			if(checkForExistingName(sndGroupName, "group")){
				
				var snd:SoundGroup = _soundGroupDict[sndGroupName];
				snd.stopGroup();
				
			} else {
				SoundControllerUtils.throwError('SoundController', 'stopSoundGroup', 'There is no sound group by the name ::' + sndGroupName);
			}
		}
		
		
		/**
		 * <p>This method is used to mute the global volume of a flash project using SoundMixer</p>
		 * <p>Dispatches the GLOABL_VOLUME_CHANGE DataEvent with value "GLOBAL MUTE"</p>
		 */	
		public function muteGlobalAudio():void{
			
			var st:SoundTransform = new SoundTransform();
			st.volume = 0;
			SoundMixer.soundTransform = st;
			dispatchEvent(new DataEvent(GLOBAL_VOLUME_CHANGE, true, false, "GLOBAL MUTE"));
		}
		
		/**
		 * <p>This method is used to unmute the global volume of a flash project using SoundMixer</p>
		 * <p>Dispatches the GLOABL_VOLUME_CHANGE DataEvent with value "GLOBAL UNMUTE"</p>
		 */
		public function unmuteGlobalAudio():void{
			
			var st:SoundTransform = new SoundTransform();
			st.volume = 1;
			SoundMixer.soundTransform = st;
			dispatchEvent(new DataEvent(GLOBAL_VOLUME_CHANGE, true, false, "GLOBAL UNMUTE"));
			
		}
		
		/**
		 * <p>this method is used to set the global volume of a flash project using SoundMixer</p>
		 * @param globalVol:Number - the new volume to be used
		 * <p>Dispatches the GLOABL_VOLUME_CHANGE DataEvent with value "GLOBAL VOL CHANGE :: {globalVol}"</p>
		 */
		public function setGobalVolume(globalVol:Number):void{
			
			var st:SoundTransform = new SoundTransform();
			st.volume = globalVol;
			SoundMixer.soundTransform = st;
			dispatchEvent(new DataEvent(GLOBAL_VOLUME_CHANGE, true, false, "GLOBAL VOL CHANGE :: " + globalVol));
		}
		
		/**
		 * <p>Sets the volume of a sound that has been registered with the controller</p>
		 * @param sndName:String - the sound you wish to change the volume of
		 * @param newVol:Number - the volume to use
		 */
		public function setSoundVolume(sndName:String, newVol:Number):void{
			if(checkForExistingName(sndName, "sound")) {
				(_soundsDict[sndName] as SoundObject).volume = newVol;
			} else {
				SoundControllerUtils.throwError('SoundController', 'setSoundVolume', 'there is no sound with the name :: ' + sndName);
			}
		}
		
		/**
		 * <p>Sets the start time of a sound that has been registered with the controller</p>
		 * @param sndName - the sound you wish to change the start time of
		 * @param startTime - the new start time to use
		 */
		public function setSoundStartTime(sndName:String, startTime:Number):void{
			if(checkForExistingName(sndName, "sound")) {
				(_soundsDict[sndName] as SoundObject).startTime = startTime;
			} else {
				SoundControllerUtils.throwError('SoundController', 'setSoundStartTime', 'there is no sound with the name :: ' + sndName);
			}
		}
		
		/**
		 * <p>Sets the amount of loops for a sound that has been registered with the controller</p>
		 * @param sndName:String - the sound you wish to change the loop amount of
		 * @param loopAmount:int - the new amount of loops to use when playing the song
		 */
		public function setSoundLoops(sndName:String, loopAmount:int):void{
			if(checkForExistingName(sndName, "sound")) {
				(_soundsDict[sndName] as SoundObject).loops = loopAmount;
			} else {
				SoundControllerUtils.throwError('SoundController', 'setSoundLoops', 'there is no sound with the name :: ' + sndName);
			}
		}
		
		/**
		 * <p>fades the volume of a sound to a specified volume over a length of time</p>
		 * @param sndName - the name of the sound whos volume you wish to fade
		 * @param length - the length of the fade in seconds
		 * @param targetVol - the volume you wish to fade to ... value 0-1
		 */
		public function fadeSoundVolume(sndName:String, length:Number, targetVol:Number):void{
			if(checkForExistingName(sndName, "sound")) {
				(_soundsDict[sndName] as SoundObject).fadeToTargetVolume(targetVol, length);
			} else {
				SoundControllerUtils.throwError('SoundController', 'fadeSoundVolume', 'there is no sound with the name :: ' + sndName);
			}		
		}
		
		/**
		 * <p>fades the volume of a sound group to a specified volume over a length of time</p>
		 * @param groupName - the name of the sound group whos volume you wish to fade
		 * @param length - the length of the fade in seconds
		 * @param targetVol - the volume you wish to fade to ... value 0-1
		 */
		public function fadeSoundGroupVolume(groupName:String, length:Number, targetVol:Number):void{
			if(checkForExistingName(groupName, "group")) {
				(_soundGroupDict[groupName] as SoundGroup).fadeGroupToTargetVolume(targetVol, length);
			} else {
				SoundControllerUtils.throwError('SoundController', 'fadeSoundGroupVolume', 'there is no sound group with the name :: ' + groupName);
			}		
		}
		
		private function checkForExistingName(nameToCheck:String, type:String):Boolean{
			
			switch(type){
				case "sound":
					for each(var s:SoundObject in _sounds) {
						if(s.name == nameToCheck) {
							return true;
						}
					}
					break;
				case "group":
					for each(var sg:SoundGroup in _soundGroups) {
						if(sg.name == nameToCheck) {
							return true;
						}
					}
					break;
			}
			
			return false;	
		}
		
	}
}
