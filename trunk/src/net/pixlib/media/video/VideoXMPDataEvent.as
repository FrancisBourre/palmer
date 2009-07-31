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
	import net.pixlib.events.ObjectEvent;				

	/**
	 * @author Romain Ecarnot
	 */
	public class VideoXMPDataEvent extends ObjectEvent
	{
		//--------------------------------------------------------------------
		// Events
		//--------------------------------------------------------------------
		
		public static const onXMPDataEVENT : String = "onXMPData";
		
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function VideoXMPDataEvent( type : String, videoDisplay : VideoStream, data : XML )
		{
			super( type, videoDisplay, data );
		}			
		
		/**
		 *
		 */
		public function getXMPData(  ) : XML
		{
			return getObject() as XML;
		}
	}
}
