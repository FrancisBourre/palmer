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
	 * The CuePointEvent class represents the event object passed 
	 * to the event listener for <strong>VideoStream</strong> 
	 * cue point events.
	 * 
	 * @see VideoStream
	 * 
	 * @author Romain Ecarnot
	 */
	public class CuePointEvent extends ObjectEvent 
	{
		//--------------------------------------------------------------------
		// Events
		//--------------------------------------------------------------------
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onCuePoint</code> event.
		 * 
		 * <p>The properties of the event object have the following values:</p>
		 * <table class="innertable">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr>
		 *     	<td><code>type</code></td>
		 *     	<td>Dispatched event type</td>
		 *     </tr>
		 *     
		 *     <tr><th>Method</th><th>Value</th></tr>
		 *     <tr>
		 *     	<td><code>getMedia()</code>
		 *     	</td><td>The media stream</td>
		 *     </tr>
		 *     <tr>
		 *     	<td><code>getCuePoint()</code>
		 *     	</td><td>The metadata object</td>
		 *     </tr>
		 * </table>
		 * 
		 * @eventType onCuePoint
		 */		
		public static const onCuePointEVENT : String = "onCuePoint";
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function CuePointEvent ( type : String, media : VideoStream, cuePoint : Object ) 
		{
			super( type, media, cuePoint );
		}
		
		/**
		 * 
		 */
		public function getMedia( ) : VideoStream
		{
			return getTarget( ) as VideoStream;
		}
		
		/**
		 * 
		 */
		public function getCuePoint(  ) : CuePoint
		{
			return getObject( ) as CuePoint;
		}
	}
}
