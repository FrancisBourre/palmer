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
package net.pixlib.load
{
	/**
	 * The XMLLoader class allow to load xml content.
	 * 
	 * @example
	 * <pre class="prettyprint">
	 * 
	 * var loader : XMLLoader = new XMLLoader(  );
	 * loader.addEventListener( LoaderEvent.onLoadInitEVENT, onLoaded );
	 * loader.load( new URLRequest( "content.xml" ) );
	 * </pre>
	 * 
	 * @author 	Francis Bourre
	 */
	public class XMLLoader extends FileLoader
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates new <code>XMLLoader</code> instance.
		 */	
		public function XMLLoader()
		{
			super( FileLoader.TEXT );
		}
		
		/**
		 * Returns xml content.
		 * 
		 * @return	XML content
		 */
		public function getXML() : XML
		{
			return XML( getContent() );
		}
	}
}