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
 
package net.pixlib.media.sound 
{
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.media.Metadata;	

	/**
	 * @author Romain Ecarnot
	 */
	public dynamic class SoundMetadata implements Metadata
	{
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * The sound duration.
		 */		public var duration : Number;
		
		

		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function SoundMetadata( ) 
		{
			duration = Number.NaN;
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
				"\n\t duration:" + duration + ")";
		}
	}
}
