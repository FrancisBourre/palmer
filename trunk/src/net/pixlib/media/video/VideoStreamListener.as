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
	import net.pixlib.media.MediaStreamListener;
	import net.pixlib.media.MetaDataEvent;	

	/**
	 * @author Romain Ecarnot
	 */
	public interface VideoStreamListener extends MediaStreamListener
	{
		/**
		 * 
		 */
		function onCuePoint( event : CuePointEvent ) : void;
		
		/**
		 * 
		 */
		function onMetadata( event : MetaDataEvent ) : void;
		
		/**
		 * 
		 */
		function onXMPData( event : VideoXMPDataEvent ) : void;
		
		/**
		 * 
		 */
		function onTextData( event : VideoTextDataEvent ) : void;
		
		/**
		 * 
		 */
		function onImageData( event : VideoImageDataEvent ) : void;
	}
}
