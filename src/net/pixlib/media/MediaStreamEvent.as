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
 
package net.pixlib.media 
{
	import net.pixlib.events.BasicEvent;

	import flash.events.Event;
	/**
	 * @author Michael Barbero
	 * @author Romain Ecarnot
	 */
	public class MediaStreamEvent extends BasicEvent 
	{
		//--------------------------------------------------------------------
		// Events
		//--------------------------------------------------------------------
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onMediaPlay</code> event.
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
		 *     	<td><code>getMediaStream()</code>
		 *     	</td><td>The media stream object</td>
		 *     </tr>
		 * </table>
		 * 
		 * @eventType onMediaPlay
		 */		
		public static const onMediaPlayEVENT : String = "onMediaPlay";	
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onMediaPause</code> event.
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
		 *     	<td><code>getMediaStream()</code>
		 *     	</td><td>The media stream object</td>
		 *     </tr>
		 * </table>
		 * 
		 * @eventType onMediaPause
		 */		
		public static const onMediaPauseVENT : String = "onMediaPause";	
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onMediaStop</code> event.
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
		 *     	<td><code>getMediaStream()</code>
		 *     	</td><td>The media stream object</td>
		 *     </tr>
		 * </table>
		 * 
		 * @eventType onMediaStop
		 */		
		public static const onMediaStopEVENT : String = "onMediaStop";	
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onMediaPlayhead</code> event.
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
		 *     	<td><code>getMediaStream()</code>
		 *     	</td><td>The media stream object</td>
		 *     </tr>
		 * </table>
		 * 
		 * @eventType onMediaPlayhead
		 */		
		public static const onMediaPlayheadEVENT : String = "onMediaPlayhead";	
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onMediaLoop</code> event.
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
		 *     	<td><code>getMediaStream()</code>
		 *     	</td><td>The media stream object</td>
		 *     </tr>
		 * </table>
		 * 
		 * @eventType onMediaLoop
		 */		
		public static const onMediaLoopEVENT : String = "onMediaLoop";	
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onMediaComplete</code> event.
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
		 *     	<td><code>getMediaStream()</code>
		 *     	</td><td>The media stream object</td>
		 *     </tr>
		 * </table>
		 * 
		 * @eventType onMediaComplete
		 */		
		public static const onMediaCompleteEVENT : String = "onMediaComplete";
		

		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function MediaStreamEvent(type : String, media : MediaStream, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super(type, media, bubbles, cancelable);
		}

		/**
		 * 
		 */
		public function getMediaStream( ) : MediaStream
		{
			return getTarget() as MediaStream;
		}

		/**
		 * @inheritDoc
		 */
		override public function clone( ) : Event
		{
			return new MediaStreamEvent(getType(), getMediaStream(), bubbles, cancelable);
		}
	}
}
