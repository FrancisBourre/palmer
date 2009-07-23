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
	import com.bourre.media.MediaStreamEvent;

	/**
	 * The VideoStreamEvent class.
	 * 
	 * @author 	Romain Ecarnot
	 */
	public class VideoStreamEvent extends MediaStreamEvent 
	{
		//--------------------------------------------------------------------
		// Events
		//--------------------------------------------------------------------
		
		/**
		 * @copy CuePointEvent#onCuePointEVENT
		 */
		public static const onCuePointEVENT : String = CuePointEvent.onCuePointEVENT;		
		/**
		 * @copy VideoXMPDataEvent#onXMPDataEVENT
		 */
		public static const onXMPDataEVENT : String = VideoXMPDataEvent.onXMPDataEVENT;		
		/**
		 * @copy VideoImageDataEvent.onImageDataEVENT;
		 */		public static const onImageDataEVENT : String = VideoImageDataEvent.onImageDataEVENT;
		
		/**
		 * @copy VideoTextDataEvent.onTextDataEVENT
		 */		public static const onTextDataEVENT : String = VideoTextDataEvent.onTextDataEVENT;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		public function VideoStreamEvent( type : String, videoDisplay : VideoStream )
		{ 
			super( type, videoDisplay );
		}
		
		public function getVideoStream() : VideoStream
		{
			return getTarget( ) as VideoStream;
		}
	}
}
