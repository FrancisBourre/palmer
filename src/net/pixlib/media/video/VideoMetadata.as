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
 
package net.pixlib.media.video 
{
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.media.Metadata;	

	/**
	 * @author Romain Ecarnot
	 */
	public dynamic class VideoMetadata implements Metadata
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		protected var aCuePoints : Array;
		
				
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * A Boolean value that is true if the FLV file is encoded with a 
		 * keyframe on the last frame that allows seeking to the end of a 
		 * progressive download movie clip. <br/>
		 * It is false if the FLV file is 
		 * not encoded with a keyframe on the last frame.
		 */
		public var canSeekToEnd : Boolean;

		/**
		 * Audio codec (code/decode technique) ID.
		 */
		public var audiocodecid : Number;

		/**
		 * A Number that represents time 0 in the source file from which 
		 * the FLV file was encoded. 
		 */
		public var audiodelay : Number;

		/**
		 * Audio data rate.
		 */
		public var audiodatarate : Number;

		/**
		 * Video code
		 */
		public var videocodecid : Number;

		/**
		 * The video frame rate.
		 */		public var framerate : Number;

		/**
		 * The video data rate.
		 */		public var videodatarate : Number;

		/**
		 * The video height.
		 */		public var height : Number;

		/**
		 * The video width.
		 */		public var width : Number;

		/**
		 * The video duration.
		 */		public var duration : Number;
		
		/**
		 * Number of video audio channels.
		 */
		public var audiochannels : Number;
		
		/**
		 * Seeks points.
		 */
		public var seekpoints : Array;
		
		/**
		 * 
		 */		public var trackinfo : Array;
		
		/**
		 * An Array of cue points object defined in video.
		 */
		public function get cuePoints( ) : Array
		{
			return aCuePoints; 
		}
		/** @private */
		public function set cuePoints( a : Array ) : void
		{
			for (var i : int = 0; i < a.length; i++) 
			{
				aCuePoints.push( a[ i ] ); 
			}
		}
		
		/**
		 * 
		 */
		public var xmpData : XML;
		

		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function VideoMetadata( ) 
		{
			canSeekToEnd = false;			audiocodecid = Number.NaN;			audiodelay = Number.NaN;			audiodatarate = Number.NaN;			videocodecid = Number.NaN;			framerate = Number.NaN;			videodatarate = Number.NaN;			width = -1;			height = -1;			duration = Number.NaN;
			audiochannels = Number.NaN;
			
			aCuePoints = new Array( );
			seekpoints = new Array();			trackinfo = new Array();
		}

		/**
		 *
		 */
		public function append( metadata : Object ) : void
		{
			if( metadata )
			{
				for (var p : String in metadata)
				{
					this[ p ] = metadata[p];
				}
			}
		}
		
		/**
		 *
		 */
		public function toString(  ) : String
		{
			return PalmerStringifier.stringify( this ) + "(" + 
				"\n\t canSeekToEnd:" + canSeekToEnd + ", " + 
				"\n\t cuePoints:" + cuePoints.length + ", " + 
				"\n\t audiocodecid:[" + audiocodecid + "], " + 
				"\n\t audiodelay:" + audiodelay + ", " + 
				"\n\t audiodatarate:" + audiodatarate + ", " + 
				"\n\t audiochannels:" + audiochannels + ", " + 
				"\n\t videocodecid:" + videocodecid + ", " + 
				"\n\t framerate:" + framerate + ", " + 
				"\n\t videodatarate:" + videodatarate + ", " + 
				"\n\t width:" + width + ", " +
				"\n\t height:" + height + ", " + 				"\n\t duration:" + duration + ", " + 				"\n\t trackinfo:" + trackinfo.length + ", " + 
				"\n\t seekpoints:" + seekpoints.length + ")";
		}
	}
}
