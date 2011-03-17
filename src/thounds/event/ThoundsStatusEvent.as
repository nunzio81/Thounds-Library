package thounds.event
{
	import flash.events.Event;
	
	public class ThoundsStatusEvent extends Event
	{
		public static const SONG_RECEIVED:String= "ThoundsStatusEvent.SONG_RECEIVED";
		public static const ERROR:String="ThoundsStatusEvent.ERROR";
		public static const HTTP_STATUS_COMPLETE:String="ThoundsStatusEvent.HTTP_STATUS_COMPLETE";
		
		public var status:int;
		
		public function ThoundsStatusEvent( type : String, states:int=null, bubbles : Boolean = true, cancelable : Boolean = false ) {
					super( type, bubbles, cancelable );
					status=states;
		}
	}
}