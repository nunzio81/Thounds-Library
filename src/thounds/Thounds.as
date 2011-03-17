package thounds
{
	import thounds.event.ThoundsFaultEvent;
	import thounds.event.ThoundsNotifyEvent;
	import thounds.event.ThoundsOAuthEvent;
	import thounds.event.ThoundsStatusEvent;
	import thounds.event.ThoundsUserEvent;
	import thounds.event.ThoundsEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.html.HTMLLoader;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	//Library for OAuth Object
	import org.flaircode.oauth.OAuth;
	import org.flaircode.oauth.OAuthLoader;
	import org.iotashan.oauth.OAuthConsumer;
	import org.iotashan.oauth.OAuthRequest;
	import org.iotashan.oauth.OAuthSignatureMethod_HMAC_SHA1;
	import org.iotashan.oauth.OAuthToken;
	import org.iotashan.utils.URLEncoding;
	
	public class Thounds extends EventDispatcher implements IThounds
	{
				
		
		//URL use to logged in
		public static const VERIFY_CREDENTIALS:String = "http://thounds.com/me";
		public static const REQUEST_TOKEN:String = "http://thounds.com/oauth/request_token";
		public static const ACCESS_TOKEN:String = "http://thounds.com/oauth/access_token";
		public static const AUTHORIZE:String = "http://thounds.com/oauth/authorize";
		
		//API url with GET method
		public static const URL_NOTIFY:String="http://thounds.com/profile/notifications";
		public static const URL_HOME:String="http://thounds.com/home";
		public static const URL_USRMETADATA:String="http://thounds.com/profile";
		public static const URL_SEARCH:String="http://thounds.com/users";
		public static const URL_FRIENDLIST:String="http://thounds.com/profile/band";
		public static const URL_LIBRARY:String="http://thounds.com/profile/library";
		public static const URL_THOUND_METADATA:String="http://thounds.com/thounds/";
		
		//API url with POST method
		public static const NEW_TRACK:String="http://thounds.com/tracks";
		
		//API url with PUT method
		public static const URL_RESP_FRIENDSHIP:String="http://thounds.com/profile/friendships/";
		
		//API url with DELETE method
		public static const URL_DELETE_NOTIFY:String="http://thounds.com/track_notifications/";
		public static const URL_TRACK_DELETE:String="http://thounds.com/tracks/";
		public static const URL_THOUND_DELETE:String="http://thounds.com/thounds/";
		
		public static function getTokenFromResponse( tokenResponse : String ) : OAuthToken {
			var result:OAuthToken = new OAuthToken();
					
			var params:Array = tokenResponse.split( "&" );
			for each ( var param : String in params ) {
				var paramNameValue:Array = param.split( "=" );
				if ( paramNameValue.length == 2 ) {
					if ( paramNameValue[0] == "oauth_token" ) {
						result.key = paramNameValue[1];
					} else if ( paramNameValue[0] == "oauth_token_secret" ) {
						result.secret = paramNameValue[1];
					}
				}
			}
					
			return result;
		}
				
		protected var signature:OAuthSignatureMethod_HMAC_SHA1 = new OAuthSignatureMethod_HMAC_SHA1();
				
		protected var requestToken:OAuthToken;
		protected var accessToken:OAuthToken;
				
		private var _consumerKey:String;
		private var _consumerSecret:String;
				
		private var _consumer:OAuthConsumer;
		private var _responseFormat:String;
		
		private var songplay:Sound=new Sound();
		
		
		public function getSound():Sound{
			return songplay;
		}
				
		public function set consumerKey( key : String ) : void {
			_consumerKey = key;
		}
				
		public function set consumerSecret( secret : String ) : void {
			_consumerSecret = secret;
		}
				
		private function get consumer() : OAuthConsumer {
			if ( _consumer == null && _consumerKey != null && _consumerSecret != null ) {
				_consumer = new OAuthConsumer( _consumerKey, _consumerSecret );
			}
			return _consumer;
		}
				
		public function Thounds( consumerKey : String = null, consumerSecret : String = null ) {
			_consumerKey = consumerKey;
			_consumerSecret = consumerSecret;
		}
				
		public function setAccessToken( token : OAuthToken ) : void {
			accessToken = token;
		}
		
		//Funtion to authenticate
		public function authenticate() : void {
			trace("authenticate");
			
			var oauthRequest:OAuthRequest = new OAuthRequest( "GET", REQUEST_TOKEN, null, consumer, null );
			
			var request:URLRequest = new URLRequest( oauthRequest.buildRequest( signature ) );
			var loader:URLLoader = new URLLoader( request );
			loader.addEventListener( Event.COMPLETE, requestTokenHandler);
		}
				
		protected function requestTokenHandler( e : Event ) : void {
			requestToken = getTokenFromResponse( e.currentTarget.data as String );
			if ( dispatchEvent( new ThoundsOAuthEvent( ThoundsOAuthEvent.REQUEST_TOKEN, requestToken ) ) ) {
				var request:URLRequest = new URLRequest( AUTHORIZE + "?oauth_token=" + requestToken.key );
				navigateToURL( request, "_blank" );
			}
		}
		
		//Function to obtain access token (pin variable is the pin obtain in thounds authorize page) 
		public function obtainAccessToken( pin : String ) : void {
			trace("obtainAccessToken");
			
			var oauthRequest:OAuthRequest = new OAuthRequest( "GET", ACCESS_TOKEN, { oauth_verifier: pin }, consumer, requestToken );
			var request:URLRequest = new URLRequest( oauthRequest.buildRequest( signature, OAuthRequest.RESULT_TYPE_URL_STRING ) );
			request.method = "GET";
					
			var loader:URLLoader = new URLLoader( request );
			loader.addEventListener( Event.COMPLETE, accessTokenResultHandler );
		}
				
		protected function accessTokenResultHandler( event : Event ) : void {
			var accessToken:OAuthToken = getTokenFromResponse( event.currentTarget.data as String );
			if ( dispatchEvent( new ThoundsOAuthEvent( ThoundsOAuthEvent.ACCESS_TOKEN, accessToken ) ) ) {
				setAccessToken( accessToken );
			}
		}
		
		//Function to verify the access token (token is the token obtain after verify the pin)
		public function verifyAccessToken( token : OAuthToken ) : void {
			var oauthRequest:OAuthRequest = new OAuthRequest( "GET", VERIFY_CREDENTIALS, null, consumer, token );
			var request:URLRequest = new URLRequest( oauthRequest.buildRequest( signature, OAuthRequest.RESULT_TYPE_URL_STRING ) );
			request.method = "GET";
			var header:URLRequestHeader=new URLRequestHeader("accept","application/xml");
			request.requestHeaders.push(header);
			this.setAccessToken(token);
			var loader:URLLoader = new URLLoader( request );
			loader.addEventListener( Event.COMPLETE, completeHandler );
		}
		
		//Function to make request to API Thounds (token to access, url to make request, http method to apply, parameters to add to request)
		public function makeRequest (token:OAuthToken, url:String, method:String, param:URLVariables=null):void {
			var oauthRequest:OAuthRequest = new OAuthRequest( method, url, param, consumer, token );
			var request:URLRequest = new URLRequest( oauthRequest.buildRequest( signature, OAuthRequest.RESULT_TYPE_URL_STRING ) );
			request.method = method;
			var header:URLRequestHeader=new URLRequestHeader("accept","application/xml");
			request.requestHeaders.push(header);
			var loader:URLLoader = new URLLoader( request );
			loader.addEventListener(Event.COMPLETE, completeHandler );
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
			song.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}
		
		protected function errorHandler (event:Event):void {
			this.dispatchEvent(new ThoundsStatusEvent(ThoundsStatusEvent.ERROR));
		}
		
		protected function httpStatusHandler ( event :HTTPStatusEvent ) : void {
			var states:int=event.status;
			var e:Event=new Event(ThoundsStatusEvent.HTTP_STATUS_COMPLETE, states);
			this.dispatchEvent(e);
		}
		
		protected function completeHandler (event:Event):void {
			var decoder:XML=new XML(event.currentTarget.data);
			var value:Object = decoder.valueOf();
			var e:ThoundsEvent=new ThoundsEvent(ThoundsEvent.REQUEST_COMPLETE, value);
			this.dispatchEvent(e);
		}
		
		//Function to get Song to play
		public function getSong(token:OAuthToken,url:String):void{
			var oauthRequest:OAuthRequest = new OAuthRequest( "GET", url, null, consumer, token );
			var request:URLRequest = new URLRequest( oauthRequest.buildRequest( signature, OAuthRequest.RESULT_TYPE_URL_STRING ) );
			var song:Sound=new Sound();
			song.load(request);
			song.addEventListener(Event.COMPLETE,songHandler);
			song.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		}
		
		protected function songHandler( event : Event ) : void {
			var urlmp3:String=event.currentTarget.url.valueOf().toString();
			songplay=event.currentTarget.valueOf();
			var e:Event=new Event(ThoundsStatusEvent.SONG_RECEIVED);
			dispatchEvent(e);
		}
	}
}