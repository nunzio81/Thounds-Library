package thounds.event
{
	import flash.events.Event;
	
	public class ThoundsFaultEvent extends Event
	{
		public static const FAULT:String = "fault";
		
		public static const REQUEST_TOKEN_FAULT:String = "requestTokenFault";
		
		public static const ACCESS_TOKEN_FAULT:String = "accessTokenFault";
		
		/**
		 * contains a text message describing the error 
		 */
		public var message:String;
		
		/**
		 * contains the HTTP code in case of an HTTP response 
		 */
		public var errorCode:int;
		
		
		public function ThoundsFaultEvent(type:String, message:String, errorCode:int=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.message = message;
			
			this.errorCode = errorCode;
		}
		
		override public function clone():Event
		{
			return new ThoundsFaultEvent(type, message, errorCode, bubbles, cancelable);
		}
	}
}