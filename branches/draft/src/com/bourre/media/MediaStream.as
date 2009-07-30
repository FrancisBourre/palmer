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
 
package com.bourre.media 
{
	import com.bourre.commands.Runnable;
	import com.bourre.commands.Suspendable;	

	/**
	 * @author Romain Ecarnot
	 */
	public interface MediaStream extends Runnable, Suspendable
	{
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * Media duration.
		 */
		function get duration( ) : Number;
		
		/**
		 * Media volume.
		 */
		function get volume( ) : Number;
		/** @private */
		function set volume( value : Number ) : void;
		
		/**
		 * Returns media playhead position.
		 */
		function get playheadTime() : Number;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
						
		/**
		 * Starts playing media.
		 */
		function play( ) : void;
		
		/**
		 * Pauses the media.
		 */
		function pause( ) : void;
		
		/**
		 * Resumes media after a pause.
		 */
		function resume( ) : void;
		
		/**
		 * Returns media metadata.
		 */
		function getMetadata(  ) : Metadata
	}
}
