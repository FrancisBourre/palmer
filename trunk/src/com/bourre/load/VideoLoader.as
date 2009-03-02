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
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.load.AbstractLoader;
	import com.bourre.load.palmer_VideoLoader;
	import com.bourre.log.PalmerDebug;
	import com.bourre.media.MediaStreamEvent;
	import com.bourre.media.NetStreamStatus;
	import com.bourre.media.video.VideoStream;
	
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;	

	/**
	 * 
	 */
	public class VideoLoader extends AbstractLoader 
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _oConnection : NetConnection;		private var _oStream : NetStream;		private var _oDisplay : VideoStream;		private var _bLoaded : Boolean;
		
		
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
			
			_oConnection = new NetConnection( );
			_oConnection.connect( null );
			
			_oStream = new NetStream( _oConnection );
			
			_oDisplay = VideoStream.palmer_VideoLoader::buildInstance( video, _oStream );
			_oDisplay.getVideo( ).attachNetStream( _oStream );			_oDisplay.autoPlay = autoplay;			
			setContent( _oDisplay );
						
			_oStream.addEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
			_oStream.bufferTime = bufferTime;
			_oStream.client = _oDisplay;
			
			_bLoaded = false;
		}
		
		override public function load( url : URLRequest = null, context : LoaderContext = null ) : void
		{
			if( url ) setURL( url );
			
			if ( getURL( ).url.length > 0 )
			{
				onInitialize();
					
				if( context ) setContext( context );
				
				_bIsRunning = true;
								_oStream.play( getURL( ).url );
				
				if( !_oDisplay.autoPlay ) _oStream.pause();
			}
		}
		
		public function getVideoStream( ) : VideoStream
		{
			return _oDisplay;
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		protected function onNetStatus(  event : NetStatusEvent ) : void
		{
			PalmerDebug.DEBUG( event.info.code );
			
			switch( event.info.code )
			{
				case NetStreamStatus.PLAY_START :
					fireEventType( LoaderEvent.onLoadStartEVENT );
					if( _oStream.bufferTime > 0 ) fireEventType( LoaderEvent.onLoadProgressEVENT );
					break;
				case NetStreamStatus.PLAY_NOTFOUND :
					fireEventType( LoaderEvent.onLoadErrorEVENT,  " can't find video url passed to the play() method : '" + getURL().url + "'" );
					break;
				case NetStreamStatus.PLAY_FAILED:
					fireEventType( LoaderEvent.onLoadErrorEVENT,  " An error has occurred in playback for a reason other than those listed elsewhere in this table, such as the subscriber not having read access." );
					break;
				case NetStreamStatus.BUFFER_FULL :
					if( !_bLoaded )
					{
						_bLoaded = true;
						fireEventType( LoaderEvent.onLoadInitEVENT );
						getVideoStream().palmer_VideoLoader::setLoaded( true );
						
						_bIsRunning = false;
					}
					else
					{
						getVideoStream().palmer_VideoLoader::fireEventType( MediaStreamEvent.onMediaPlayEVENT );
					}
					break;
				case NetStreamStatus.PLAY_STOP :
					if( _bLoaded )
					{
						getVideoStream().palmer_VideoLoader::complete( );
					}
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
	}
}
