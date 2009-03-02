package com.bourre.media 
{
	import com.bourre.events.BasicEvent;
	import com.bourre.events.ObjectEvent;
	import com.bourre.media.MediaStream;	

	/**
	 * @author Romain Ecarnot
	 */
	public class MetaDataEvent extends ObjectEvent 
	{
		//--------------------------------------------------------------------
		// Events
		//--------------------------------------------------------------------
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onMetaDataReceived</code> event.
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
		 *     	</td><td>The media stream</td>
		 *     </tr>
		 *     <tr>
		 *     	<td><code>getMetaData()</code>
		 *     	</td><td>The metadata object</td>
		 *     </tr>
		 * </table>
		 * 
		 * @eventType onMetaDataReceived
		 */		
		public static const onMetaDataReceivedEVENT : String = "onMetaDataReceived";
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function MetaDataEvent(type : String, media : MediaStream, meta : Metadata )
		{
			super( type, media, meta );
		}
		
		/**
		 *
		 */
		public function getMediaStream(  ) : MediaStream
		{
			return getTarget( ) as MediaStream;
		}
		
		/**
		 *
		 */
		public function getMetaData(  ) : Metadata
		{
			return getObject( ) as Metadata;
		}
	}
}
