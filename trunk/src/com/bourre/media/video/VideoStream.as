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
 
package com.bourre.media.video 
{
	import com.bourre.commands.CommandManagerMS;
	import com.bourre.commands.Delegate;
	import com.bourre.core.palmer_internal;
	import com.bourre.load.VideoLoader;
	import com.bourre.load.palmer_VideoLoader;
	import com.bourre.log.PalmerDebug;
	import com.bourre.media.AbstractMediaStream;
	import com.bourre.media.MediaStream;
	import com.bourre.media.MediaStreamEvent;
	import com.bourre.media.MetaDataEvent;
	import com.bourre.media.sound.SoundTransformInfo;
	import com.bourre.structures.Dimension;

	import flash.display.BitmapData;
	import flash.media.Video;
	import flash.net.NetStream;
	
	use namespace palmer_VideoLoader;
	
	use namespace palmer_internal;

	/**
	 * 
	 * @example Basic use
	 * <pre class="prettyprint">
	 * 
	 * var loader : VideoLoader = new VideoLoader( videoContainer, true, 30 );
	 * loader.setName( "Tweenpix Movie" );
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
	public class VideoStream extends AbstractMediaStream implements MediaStream
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _oCOManager : CuePointManager;

		private var _bAutoPlay : Boolean;		private var _bAutoSize : Boolean;
		private var _bAutoRewind : Boolean;
		private var _bLoopMode : Boolean;

		private var _oVideoMeta : VideoMetadata;
		private var _bXMPReceived : Boolean;		private var _bLoaded : Boolean;
		private var _dCuePointUpdateMethod : Delegate;
		private var _oST : SoundTransformInfo ;

		
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------

		protected var video : Video;
		protected var stream : NetStream;

		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		public function get volume( ) : Number
		{
			return stream ? _oST.getVolume( ) : 0 ;
		}

		/** @private */
		public function set volume( value : Number ) : void
		{
			_oST.setVolume( value ) ;
		}

		/**
		 *  Height of the loaded video file.
		 *  <code>-1</code> if no FLV file loaded yet.
		 */
		public function get height() : Number
		{
			return video ? video.height : -1;
		}

		/** @private */
		public function set height( value : Number ) : void
		{
			setSize( width, value );	
		}

		/**
		 *  Width of the loaded video file.
		 *  <code>-1</code> if no FLV file loaded yet.
		 */
		public function get width() : Number
		{
			return video ? video.width : -1;
		}

		/** @private */
		public function set width( value : Number ) : void
		{
			setSize( value, height );	
		}

		/**
		 * @inheritDoc
		 */
		public function get duration( ) : Number
		{
			return _oVideoMeta ? _oVideoMeta.duration : 0 ;
		}

		/**
		 * Auto play mode.
		 * 
		 * <p>If <code>true</code> video starts playing when 
		 * loaded ( or buffered ).
		 */
		public function get autoPlay() : Boolean
		{
			return _bAutoPlay;
		}

		/** @private */
		public function set autoPlay( enabled : Boolean ) : void
		{
			_bAutoPlay = enabled;
		}

		/**
		 * Auto resize mode.
		 * 
		 * <p>If <code>true</code> video is resized when 
		 * metadata are received.
		 */
		public function get autoSize() : Boolean
		{
			return _bAutoSize;
		}

		/** @private */
		public function set autoSize( enabled : Boolean ) : void
		{
			_bAutoSize = enabled;
		}

		/**
		 * Auto rewind mode.
		 * 
		 * <p>If <code>true</code> video is rewinded when finished.
		 */
		public function get autoRewind() : Boolean
		{
			return _bAutoRewind;
		}

		/** @private */
		public function set autoRewind( enabled : Boolean ) : void
		{
			_bAutoRewind = enabled;
		}

		/**
		 * Loop mode.
		 * 
		 * <p>If <code>true</code> video restart when finished.
		 */
		public function get loopPlayback() : Boolean
		{
			return _bLoopMode;
		}

		/** @private */
		public function set loopPlayback( enabled : Boolean ) : void
		{
			_bLoopMode = enabled;
		}

		/**
		 * Specifies whether the video should be smoothed (interpolated) when 
		 * it is scaled.
		 * 
		 * @default true
		 */
		public function get smoothing( ) : Boolean
		{
			return video.smoothing;
		}

		/** @private */
		public function set smoothing( b : Boolean ) : void
		{
			video.smoothing = b;
		}

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 *	
		 */
		public function getVideo( ) : Video
		{
			return video;
		}

		/**
		 *	
		 */
		public function getVideoMetadata(  ) : VideoMetadata
		{
			return getMetadata( ) as VideoMetadata;
		}

		/**
		 * Returns video screenshoot.
		 */
		public function getScreenShoot(  ) : BitmapData
		{
			var bmp : BitmapData = new BitmapData( video.width, video.height, true, 0xFFFFFF );
			bmp.draw( video );
			
			return bmp;
		}

		/**
		 * 
		 */
		public function setSoundTransform( o : SoundTransformInfo ) : void
		{
			_oST = o ;
			if( stream )
			{
				_oST.addStream( stream ) ;
				stream.soundTransform = _oST.getSoundTransform( ) ;
			}
		}

		/**
		 * 
		 */
		public function getSoundTransform( ) : SoundTransformInfo
		{
			return _oST ;
		}

		/**
		 *
		 */
		public function setCuePointManager( manager : * ) : void
		{
			_oCOManager = manager;
		}	

		/**
		 *
		 */
		public function getCuePointManager(  ) : CuePointManager
		{
			return _oCOManager;
		}	

		/**
		 * 
		 */
		public function setSize( w : Number, h : Number ) : void
		{
			if( video && !isNaN( w ) && !isNaN( h ) )
			{
				video.width = w;
				video.height = h;
				
				PalmerDebug.FATAL( "new size " + w + "x" + h );
			}
		}

		/**
		 * 
		 */
		public function getSize( ) : Dimension
		{
			return new Dimension( width, height );
		}

		/**
		 * @inheritDoc
		 */
		public function play() : void
		{
			if( !isRunning( ) )
			{
				stream.seek( lastPlayheadPosition );
				stream.resume( );
				
				setRunning( true );
			}
		}

		/**
		 *
		 */
		public function seek( n : Number, relative : Boolean = false ) : void
		{
			var seekpoints : Array = getVideoMetadata( ).seekpoints;
			
			var nextPosition : Number = n;
			if( relative ) nextPosition = stream.time + n;
			
			var l : Number = seekpoints.length;
			while( --l > -1 ) if ( n > seekpoints[ l ] ) nextPosition = seekpoints[ l ];
			
			if( nextPosition >= 0 && nextPosition <= duration );
			stream.seek( nextPosition );
		}

		/**
		 * @inheritDoc
		 */
		public function pause() : void
		{
			if( isRunning( ) )
			{
				stream.pause( );
				
				lastPlayheadPosition = stream.time;
			
				setRunning( false );
								
				fireEventType( MediaStreamEvent.onMediaPauseVENT );
			}
		}

		/**
		 * 
		 */
		public function togglePause( ) : void
		{
			isRunning( ) ? pause( ) : resume( );
		}
		
		/**
		 * @inheritDoc
		 */
		public function resume() : void
		{
			play( );
		}

		/**
		 * 
		 */
		public function stop() : void
		{
			if( isRunning( ) )
			{
				stream.pause( );
				stream.seek( 0 );
				
				lastPlayheadPosition = 0;
				
				setRunning( false );
				
				fireEventType( MediaStreamEvent.onMediaStopEVENT );			}
		}

		/**
		 * @copy #play()
		 */
		public function run() : void
		{
			play( );
		}

		/**
		 * @copy #play()
		 */
		public function start() : void
		{
			play( );
		}

		/**
		 * @copy #stop()
		 */
		public function reset() : void
		{
			stop( );
		}

		/**
		 * Triggered when receives descriptive information 
		 * embedded in the video being played.
		 */
		public function onMetaData( metadata : Object = null  ) : void
		{
			if( metadata != null ) 
			{
				_oVideoMeta.append( metadata );
				
				setMetadata( _oVideoMeta );
				
				if( _bLoaded ) 
				{
					fireEvent( new MetaDataEvent( MetaDataEvent.onMetaDataReceivedEVENT, this, getMetadata( ) ) );
				}
				
				if ( autoSize ) setSize( getVideoMetadata( ).width, getVideoMetadata( ).height );
			}
		}

		/**
		 * Triggered when an embedded cue point is reached while 
		 * playing video file.
		 */
		public function onCuePoint( cuePoint : Object  ) : void
		{
			//Don't use FLV CuePoint event system.
			//Use internal cue points checker to be compliant with all video format.
		}

		/**
		 * Triggered when Flash Player receives text data embedded in a media file that 
		 * is playing. 
		 * 
		 * <p>The text data is in UTF-8 format and can contain information about 
		 * formatting based on the 3GP timed text specification.</p>
		 */
		public function onTextData( data : Object  ) : void
		{
			fireEvent( new VideoTextDataEvent( VideoTextDataEvent.onTextDataEVENT, this, data ) );
		}

		/**
		 * Triggered when Flash Player receives image data as a byte array 
		 * embedded in a media file that is playing. 
		 * 
		 * <p>The image data can produce either JPEG, PNG, or GIF content.<br/>
		 * Use the flash.display.Loader.loadBytes() method to load the byte 
		 * array into a display object.</p>
		 * 
		 * @example
		 * <pre class="prettyprint">
		 * 
		 * var l:Loader = new Loader();    
		 * l.loadBytes(image.data);
		 * addChild(l);
		 * </pre>
		 */
		public function onImageData( data : Object  ) : void
		{
			fireEvent( new VideoImageDataEvent( VideoImageDataEvent.onImageDataEVENT, this, data ) );
		}

		/**
		 * Triggered when a NetStream object has completely played 
		 * a stream.
		 */
		public function onPlayStatus( data : Object  ) : void
		{
			if( VideoLoader.DEBUG ) 
			{
				PalmerDebug.DEBUG( this + ".onPlayStatus()" );
				for (var p : String in data) 
				{
					PalmerDebug.FATAL( p + " -> " + data[p] );
				}
			}
			
			if( data.code == "NetStream.Play.Complete")
			{
				complete( );
			}
		}
		
		/**
		 * 
		 */
		public function onXMPData( xmpData : Object = null ) : void
		{
			if( _bXMPReceived ) return;
			
			var xmpDM : Namespace = new Namespace( "http://ns.adobe.com/xmp/1.0/DynamicMedia/" ); 
			var rdf : Namespace = new Namespace( "http://www.w3.org/1999/02/22-rdf-syntax-ns#" ); 
			
			var xmp : XML = new XML( xmpData.data ); 
			
			for each (var track : XML in xmp..xmpDM::Tracks) 
			{ 
				var fr : String = track.rdf::Bag.rdf::li.rdf::Description.@xmpDM::frameRate;
				var rate : Number = Number( fr.substr( 1, fr.length ) );
				var markers : XMLList = track.rdf::Bag.rdf::li.rdf::Description.xmpDM::markers.rdf::Seq.rdf::li;
				
				for each (var marker : XML in markers) 
				{
					var cp : CuePoint = new CuePoint( );
					
					if( marker.children( ).length( ) > 0 )
					{
						cp.name = marker.rdf::Description.@xmpDM::name;
						cp.type = marker.rdf::Description.@xmpDM::cuePointType;
						cp.time = Number( marker.rdf::Description.@xmpDM::startTime ) / rate;
						
						for each (var param : XML in marker.rdf::Description.xmpDM::cuePointParams.rdf::Seq.rdf::li ) 
						{
							cp.parameters.push( { key : param.@xmpDM::key, value : param.@xmpDM::value } );
						}
					}
					else
					{
						cp.name = marker.@xmpDM::name;
						cp.type = marker.@xmpDM::cuePointType;
						cp.time = Number( marker.@xmpDM::startTime ) / rate;
					}
					
					getCuePointManager( ).addCuePoint( cp );
				}
			}
			
			getVideoMetadata( ).xmpData = xmp;
			
			_bXMPReceived = true;
			
			fireEvent( new VideoXMPDataEvent( VideoXMPDataEvent.onXMPDataEVENT, this, xmp ) );
		}

		
		//--------------------------------------------------------------------
		// palmer_VideoLoader methods
		//--------------------------------------------------------------------

		palmer_VideoLoader function setStream( loadedStream : NetStream ) : void
		{
			stream = loadedStream;
			stream.client = this;
			getVideo( ).attachNetStream( stream );
		}

		palmer_VideoLoader function setLoaded( b : Boolean ) : void
		{
			if( !_bLoaded )
			{
				try
				{
					_bLoaded = b;
					
					if( !isNaN( getVideoMetadata( ).duration ) )
					{
						getCuePointManager( ).addCuePoints( getVideoMetadata( ).cuePoints );
						
						fireEvent( new MetaDataEvent( MetaDataEvent.onMetaDataReceivedEVENT, this, getMetadata( ) ) );
						
						if ( autoSize ) setSize( getVideoMetadata( ).width, getVideoMetadata( ).height );
					}
					else
					{
						PalmerDebug.WARN( this + " wait for metadata..." );
					}
				}
				catch( e : Error )
				{
					PalmerDebug.ERROR( this + "::" + e.message );
				}
				finally
				{
					setRunning( true );
					
					fireEventType( MediaStreamEvent.onMediaPlayEVENT );
				}
			}
		}

		palmer_VideoLoader function isLoaded( ) : Boolean
		{
			return _bLoaded;
		}

		palmer_VideoLoader function fireEventType( type : String ) : void
		{
			super.fireEventType( type );
		}

		palmer_VideoLoader function complete( ) : void
		{
			setRunning( false );
			
			if( loopPlayback )
			{
				lastPlayheadPosition = 0;
				
				fireEventType( MediaStreamEvent.onMediaLoopEVENT );
				
				play( );
			}
			else
			{
				if( autoRewind )
				{
					stream.pause( );
					stream.seek( 0 );
					lastPlayheadPosition = 0;
					
					fireEventType( MediaStreamEvent.onMediaPlayheadEVENT );
				}
				
				fireEventType( MediaStreamEvent.onMediaStopEVENT );
			}
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------

		override protected function setRunning( b : Boolean ) : void
		{
			super.setRunning( b );
			
			if( isRunning( ) )
			{
				CommandManagerMS.getInstance( ).push( _dCuePointUpdateMethod, 500 );	
			}
			else
			{
				CommandManagerMS.getInstance( ).remove( _dCuePointUpdateMethod );
			}
		}

		protected function checkCuePoint(  ) : void
		{
			var cp : CuePoint = getCuePointManager( ).palmer_internal::getCuePoint( stream.time );
			if( cp != null )
			{
				fireEvent( new CuePointEvent( CuePointEvent.onCuePointEVENT, this, cp ) );
			}
		}

		/**
		 * Returns a VideoStreamEvent event.
		 * 
		 * @return A VideoStreamEvent event for current loader instance.
		 */
		override protected function getMediaEvent( type : String ) : MediaStreamEvent
		{
			return new VideoStreamEvent( type, this );
		}

		/**
		 * 
		 */
		protected function initVideo(  ) : void
		{
			if( autoPlay )
			{
				play( );
			}
		}

		/**
		 * @private
		 * 
		 * Returns real video stream playhead position.
		 */
		override palmer_internal function getPlayheadTime() : Number
		{
			return stream.time;
		}

		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		palmer_VideoLoader static function buildInstance( video : Video ) : VideoStream
		{
			return new VideoStream( video );
		}

		/**
		 * Creates new VideoStream instance.
		 * 
		 * @param	video	Video container
		 * @param	stream	Video stream to use
		 */
		function VideoStream( video : Video )
		{
			super( getContructorAccess( ) );
			
			this.video = video;
			
			_bAutoPlay = false;
			_bAutoSize = false;
			_bAutoRewind = false;
			_bLoopMode = false;
			
			lastPlayheadPosition = 0;
			
			_oVideoMeta = new VideoMetadata( );
			setMetadata( _oVideoMeta );
			
			_bLoaded = false;
			_bXMPReceived = false;
			
			setCuePointManager( new CuePointManager( this ) );
			
			_dCuePointUpdateMethod = new Delegate( checkCuePoint );
			
			setSoundTransform( SoundTransformInfo.NORMAL );
		}
	}
}
