/*
 * Copyright the original author or authors.
 * 
 * Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.mozilla.org/MPL/MPL-1.1.html
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
package com.bourre.load 
{
	import com.bourre.commands.Delegate;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.load.AbstractLoader;
	import com.bourre.load.palmer_VideoLoader;
	import com.bourre.log.PalmerDebug;
	import com.bourre.media.MediaStreamEvent;
	import com.bourre.media.NetStreamStatus;
	import com.bourre.media.video.VideoStream;

	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * Loader implementation for video file.
	 * 
	 * @example Basic use
	 * <pre class="prettyprint">
	 * 
	 * var loader : VideoLoader = new VideoLoader( videoContainer, true, 30 );
	 * loader.setName( "Movie" );
	 * loader.addEventListener( LoaderEvent.onLoadStartEVENT, onVideoLoadstart );
	 * loader.addEventListener( LoaderEvent.onLoadProgressEVENT, onVideoLoadprogress );
	 * loader.addEventListener( LoaderEvent.onLoadInitEVENT, onVideoLoadInit );
	 * loader.addEventListener( LoaderEvent.onLoadErrorEVENT, onVideoLoadError );
	 * 
	 * var media : VideoStream = loader.getVideoStream( );
	 * media.volume = 0.2;
	 * media.autoRewind = true;
	 * media.loopPlayback = true;
	 * media.addEventListener( MetaDataEvent.onMetaDataReceivedEVENT, onVideoMeta );
	 * media.addEventListener( MediaStreamEvent.onMediaPauseVENT, onPauseHandler );
	 * media.addEventListener( MediaStreamEvent.onMediaPlayEVENT, onPlayHandler );
	 * media.addEventListener( MediaStreamEvent.onMediaStopEVENT, onStopHandler );
	 * media.addEventListener( MediaStreamEvent.onMediaPlayheadEVENT, onHeadHandler );
	 * media.addEventListener( MediaStreamEvent.onMediaLoopEVENT, onLoopHandler );
	 * media.addEventListener( CuePointEvent.onCuePointEVENT, onCuePointHandler );
	 * 
	 * loader.load( new URLRequest ( "video.f4v" ) );
	 * </pre>
	 * 
	 * @author Romain Ecarnot
	 */
	public class VideoLoader extends AbstractLoader 
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------

		protected var oConnection : NetConnection;		protected var oStream : NetStream;		protected var oDisplay : VideoStream;		protected var bLoaded : Boolean;

		protected var nBufferTime : Number;

		protected var sServerHost : String;

		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * Enables or not logging message from VideoLoader instance.
		 * 
		 * @default false
		 */
		public static var DEBUG : Boolean = false;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
						
		/**
		 * Creates new <code>VideoLoader</code> instance.
		 * 
		 * @param	video		Videao container
		 * @param	bufferTime	Number of seconds of video to buffer in 
		 * 						memory before starting to play the 
		 * 						video file.
		 */	
		public function VideoLoader( video : Video,  autoplay : Boolean = false, bufferTime : Number = 2 )
		{
			super( null );
			
			oDisplay = VideoStream.palmer_VideoLoader::buildInstance( video );
			oDisplay.autoPlay = autoplay;			
			setContent( oDisplay );
			
			sServerHost = null;
			nBufferTime = bufferTime;
			bLoaded = false;
		}

		/**
		 * Sets Streaming Server address
		 */
		public function setStreamingServer( host : String = null ) : void
		{
			sServerHost = host;
		}
		
		/**
		 * Returns Streaming Server address.
		 */
		public function getStreamingServer(  ) : String
		{
			return sServerHost;
		}

		/**
		 * Returns <code>true</code> if current video 
		 * loader comes from a Streaming Server.
		 * 
		 * @return <code>true</code> if current video 
		 * loader comes form a Streaming Server.
		 */
		public function hasStreamingServer(  ) : Boolean
		{
			return sServerHost != null;
		}

		/**
		 * 
		 */
		override public function load( url : URLRequest = null, context : LoaderContext = null ) : void
		{
			if( url ) setURL( url );
			
			if ( getURL( ).url.length > 0 )
			{
				if( !LoaderLocator.getInstance( ).isRegistered( getName( ) ) )
				{
					onInitialize( );
				}
				
				if( context ) setContext( context );
				
				_bIsRunning = true;
				bLoaded = false;
				
				if( oStream ) 
				{
					oStream.close( );
					oConnection.close( );
					oConnection = null;
				}
								connect( );
			}
		}

		/**
		 * 
		 */
		public function getVideoStream( ) : VideoStream
		{
			return oDisplay;
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		protected function connect() : void
		{
			if( hasStreamingServer( ) )
			{
				_sURL = _removeFirst( getURL( ).url, getStreamingServer( ) );
				_sURL = _sURL.substr( 1, _sURL.length - _getFileExtension( _sURL ).length - 1 );
				setURL( new URLRequest( _sURL ) );
				
				if( DEBUG ) PalmerDebug.DEBUG( this + " host   URL = " + getStreamingServer( ) );
				if( DEBUG ) PalmerDebug.DEBUG( this + " stream URL = " + getURL( ).url );
				
				oConnection = new NetConnection( );
				oConnection.client = { onBWDone : Delegate.create( onBWDoneHandler ) };
				oConnection.addEventListener( NetStatusEvent.NET_STATUS, onConnectionStatusHandler );
				oConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onConnectionErrorHandler );
				oConnection.connect( getStreamingServer( ) );
			}
			else
			{
				oConnection = new NetConnection( );
				oConnection.connect( null );
				
				loadStream( );
			}	
		}

		/**
		 * 
		 */
		protected function onBWDoneHandler( ... rest ) : void
		{
			if (rest.length > 0)
			{
				if( DEBUG ) PalmerDebug.DEBUG( this + " bandwidth = " + rest[0] ); 
			}
		}

		/**
		 * Triggered when Media Server connection is established.
		 */
		protected function onConnectionStatusHandler( event : NetStatusEvent ) : void
		{
			if( DEBUG ) PalmerDebug.DEBUG( this + " NetStatus = " + event.info.code );
			if( DEBUG ) PalmerDebug.DEBUG( this + " NetConnection = " + oConnection.uri );
			
			oConnection.removeEventListener( NetStatusEvent.NET_STATUS, onConnectionStatusHandler );
			oConnection.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onConnectionErrorHandler );
			
			switch (event.info.code) 
			{ 
				case "NetConnection.Connect.Success": 
					if( DEBUG ) PalmerDebug.DEBUG( this + " Streaming Media Server Connection success." );
					loadStream( );
					break; 
				case "NetConnection.Connect.Rejected": 
				case "NetConnection.Connect.Failed": 
					PalmerDebug.ERROR( this + " Streaming Media Server Connection error." );
					fireEventType( LoaderEvent.onLoadErrorEVENT, " An error has occurred during Streaming Server connection." );
					break; 
			}
		}
		
		/**
		 * Triggered when an error occured during Media Server connection.
		 */
		protected function onConnectionErrorHandler( event : SecurityErrorEvent = null ) : void
		{
			var msg : String = " An error has occurred during Streaming Server connection.";
			PalmerDebug.ERROR( this + msg );
			
			fireEventType( LoaderEvent.onLoadErrorEVENT, msg );
		}

		/**
		 * 
		 */
		protected function loadStream( ) : void
		{
			if( DEBUG ) PalmerDebug.DEBUG( this + ".loadStream() " + getURL( ).url );
			
			oStream = new NetStream( oConnection );
			oStream.bufferTime = nBufferTime;
			oStream.addEventListener( NetStatusEvent.NET_STATUS, onNetStreamStatus );
			
			oDisplay.palmer_VideoLoader::setStream( oStream );	
				
			oStream.play( getURL( ).url );
			
			if ( !oDisplay.autoPlay ) oStream.pause( );
		}

		protected function onNetStreamStatus(  event : NetStatusEvent ) : void
		{
			if( DEBUG ) PalmerDebug.DEBUG( this + ".onNetStreamStatus() " + event.info.code );
			
			switch( event.info.code )
			{
				case NetStreamStatus.PLAY_START :
					fireEventType( LoaderEvent.onLoadStartEVENT );
					if( oStream.bufferTime > 0 ) fireEventType( LoaderEvent.onLoadProgressEVENT );
					break;
				case NetStreamStatus.PLAY_NOTFOUND :
					fireEventType( LoaderEvent.onLoadErrorEVENT, " can't find video url passed to the play() method : '" + getURL( ).url + "'" );
					break;
				case NetStreamStatus.PLAY_FAILED:
					fireEventType( LoaderEvent.onLoadErrorEVENT, " An error has occurred in playback for a reason other than those listed elsewhere in this table, such as the subscriber not having read access." );
					break;
				case NetStreamStatus.BUFFER_FULL :
					if( !bLoaded )
					{
						bLoaded = true;
						fireEventType( LoaderEvent.onLoadInitEVENT );
						getVideoStream( ).palmer_VideoLoader::setLoaded( true );
						
						_bIsRunning = false;
					}
					else
					{
						getVideoStream( ).palmer_VideoLoader::fireEventType( MediaStreamEvent.onMediaPlayEVENT );
					}
					break;
				case NetStreamStatus.PLAY_STOP :
					if( bLoaded )
					{
						getVideoStream( ).palmer_VideoLoader::complete( );
					}
					break;
				case NetStreamStatus.SEEK_NOTIFY : 
					getVideoStream( ).palmer_VideoLoader::fireEventType( MediaStreamEvent.onMediaPlayheadEVENT );
					break;
			}
		}	
		
		override protected function onInitialize() : void
		{
			if ( getName( ) != null ) 
			{
				if ( !(LoaderLocator.getInstance( ).isRegistered( getName( ) )) )
				{
					_bMustUnregister = true;
					LoaderLocator.getInstance( ).register( getName( ), this );
				} 
				else
				{
					_bMustUnregister = false;
					var msg : String = this + " can't be registered to " + LoaderLocator.getInstance( ) + " with '" + getName( ) + "' name. This name already exists.";
					PalmerDebug.ERROR( msg );
					fireOnLoadErrorEvent( msg );
					throw new IllegalArgumentException( msg );
				}
			}
		}

		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------

		private static function _removeFirst( source : String, search : String, casesensitive : Boolean = true ) : String
		{
			var pattern : RegExp = new RegExp( search, casesensitive ? "" : "i" );  
			
			return source.replace( pattern, "" );
		}

		private static function _getFileExtension( path : String ) : String
		{
			var reg : RegExp = new RegExp( "(.*?)(\.[^.]*$|$)", "" );
			return reg.exec( path )[2];
		}		
	}
}
