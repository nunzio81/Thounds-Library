package thounds.event
{
	import flash.events.Event;
	
	public class ThoundsNotifyEvent extends Event
	{
		
		public static const NOTIFY:String="ThoundsNotifyEvent.NOTIFY";
		public static const NEW_NOTIFY:String="ThoundsNotifyEvent.NEW_NOTIFY";
		public static const CLOSE_PANEL:String="ThoundsNotifyEvent.CLOSE_PANEL";
		
		public var notify:Object;
		
		public function ThoundsNotifyEvent(type:String, value:Object=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.notify=value;
		}
	}
}