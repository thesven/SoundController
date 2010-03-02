package com.thesven.audio.soundcontroller.utils {

	/**
	 * @author michaelsvendsen
	 */
	public class SoundControllerUtils {
	
		public static function throwError(className:String, methodName:String, message:String):void{
			throw new Error("<ERROR class='" + className + "' method='" + methodName + "'> " + message + " </ERROR>");
		}
	
	}
	
}
