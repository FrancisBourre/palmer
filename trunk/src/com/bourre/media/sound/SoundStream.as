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
 
package com.bourre.media.sound 
{
	import com.bourre.media.AbstractMediaStream;
	import com.bourre.media.MediaStream;	

	/**
	 * @author Romain Ecarnot
	 */
	public class SoundStream extends AbstractMediaStream implements MediaStream
	{
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function get duration() : Number
		{
			return null;
		}
		
		/**
		 * 
		 */
		public function get volume() : Number
		{
			return null;
		}
		/** @private */
		public function set volume(value : Number) : void
		{
		}
		
				
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function SoundStream( )
		{
			super( getContructorAccess() );
		}
		
		public function play() : void
		{
		}
		
		public function pause() : void
		{
		}
		
		public function resume() : void
		{
			play();
		}
		
		public function stop() : void
		{
		}
		
		
		public function run() : void
		{
			play();
		}
		
		public function start() : void
		{
			play();
		}
		
		public function reset() : void
		{
			stop();
		}
	}
}