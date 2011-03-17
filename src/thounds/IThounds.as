package thounds
{
	import flash.events.IEventDispatcher;
	
	import org.iotashan.oauth.OAuthToken;
	public interface IThounds extends IEventDispatcher
	{

		function set consumerKey( key : String ) : void;
		
		function set consumerSecret( secret : String ) : void;
		
		function authenticate() : void;
		
		function obtainAccessToken( pin : String ) : void;
		
		function verifyAccessToken( token : OAuthToken ) : void;
		
		function makeRequest (token:OAuthToken, url:String, method:String, param:URLVariables=null):void;
		
		function getSong(token:OAuthToken,url:String):void;
		
	}
}