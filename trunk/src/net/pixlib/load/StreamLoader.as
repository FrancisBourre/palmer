/* * Copyright the original author or authors. *  * Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License"); * you may not use this file except in compliance with the License. * You may obtain a copy of the License at *  *      http://www.mozilla.org/MPL/MPL-1.1.html *  * Unless required by applicable law or agreed to in writing, software * distributed under the License is distributed on an "AS IS" BASIS, * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. * See the License for the specific language governing permissions and * limitations under the License. */ package net.pixlib.load {
	import net.pixlib.load.AbstractLoader;
	import net.pixlib.load.strategy.StreamLoaderStrategy;
	
	import flash.net.URLStream;	

	/**	 * The StreamLoader class allow to load content using 	 * <code>URLStream</code> loader.	 * 	 * @author 	Romain Ecarnot	 * 	 * @see net.pixlib.load.strategy.StreamLoaderStrategy	 * @see http://livedocs.adobe.com/flex/3/langref/flash/net/URLStream.html URLStream class	 */
	public class StreamLoader extends AbstractLoader	{		//--------------------------------------------------------------------		// Public API		//--------------------------------------------------------------------				/**		 * Creates new <code>StreamLoader</code> instance.		 */			public function StreamLoader( )		{			super( new StreamLoaderStrategy( ) );		}				/**		 * Returns URLStream content.		 * 		 * @return	The URLStream content		 */		public function getStream() : URLStream		{			return URLStream( getContent() );		}	}
}
