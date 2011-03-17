package thounds.event
{
	import flash.events.Event;
	
	public class ThoundsUserEvent extends Event
	{
				
		public static const USER_INFO:String = "ThoundsUserEvent.USER_INFO";
		public static const USER_ERROR:String = "ThoundsUserEvent.USER_ERROR";
				
		
				
		public function ThoundsUserEvent( type : String,  bubbles : Boolean = false, cancelable : Boolean = false ) {
			super( type, bubbles, cancelable );
			
		}
	}
}