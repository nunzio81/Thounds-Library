package thounds.event
{
	import flash.events.Event;
	
	public class ThoundsEvent extends Event
	{
		public static const REQUEST_COMPLETE:String = "requestComplete";
		
		
		/**
		 * Contains the parsed response of an API call if it returns
		 * XML or JSON format.
		 */
		public var data:Object;
		
		
		public function ThoundsEvent(type:String, data:Object, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.data = data;
			
		}
		
		override public function clone():Event
		{
			return new ThoundsEvent(type, data, rawData, bubbles, cancelable);
		}
	}
}