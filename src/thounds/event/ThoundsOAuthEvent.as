package thounds.event
{
		import flash.events.Event;
		
		import org.iotashan.oauth.OAuthToken;
		
		public class ThoundsOAuthEvent extends Event {
			
			public static const REQUEST_TOKEN:String = "ThoundsOAuthEvent.REQUEST_TOKEN";
			public static const CONSUMER_ERROR:String = "ThoundsOAuthEvent.CONSUMER_ERROR";
			
			public static const ACCESS_TOKEN:String = "ThoundsOAuthEvent.ACCESS_TOKEN";
			public static const PIN_ERROR:String = "ThoundsOAuthEvent.PIN_ERROR";
			
			private var _token:OAuthToken;
			
			public function get token() : OAuthToken {
				return _token;
			}
			
			public function ThoundsOAuthEvent( type : String, token : OAuthToken, bubbles : Boolean = false ) {
				super( type, bubbles );
				_token = token;
			}
			
			override public function clone() : Event {
				return new ThoundsOAuthEvent( type, token, bubbles );
			}
		}
}