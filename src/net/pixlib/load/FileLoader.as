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
	import net.pixlib.load.strategy.URLLoaderStrategy;				

	/**
	 * The FileLoader class allow to load text, binary or variables data 
	 * format from passed-in file.
	 * 
	 * @example
	 * <pre class="prettyprint">
	 * 
	 * var loader : FileLoader = new FileLoader( FileLoader.BINARY );
	 * loader.addEventListener( LoaderEvent.onLoadInitEVENT, onLoaded );
	 * loader.load( new URLRequest( "logo.swf" );
	 * 
	 * function onLoaded( event : FileLoaderEvent ) :void
	 * {
	 * 	var content : ByteArray = event.getFileContent() as ByteArray;
	 * }
	 * </pre>
	 * 
	 * @author 	Francis Bourre
	 */
	public class FileLoader extends AbstractLoader
	{
		//--------------------------------------------------------------------
		// Constants
		//--------------------------------------------------------------------
				
		/**
		 * Specifies that downloaded data is received as raw binary data. 
		 */	
		public static const BINARY : String = URLLoaderStrategy.BINARY;
		
		/**
		 * Specifies that downloaded data is received as text. 
		 */		public static const TEXT : String = URLLoaderStrategy.TEXT;

		/**
		 * Specifies that downloaded data is received as URL-encoded variables. 
		 */		public static const VARIABLES : String = URLLoaderStrategy.VARIABLES;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates new <code>FileLoader</code> instance.
		 * 
		 * @param	dataFormat	(optional) Downloaded data format.		 * @param	name		(optional) Loader identifier.
		 * 
		 * @see #setDataFormat()
		 */	
		public function FileLoader( dataFormat : String = null, name : String = null )
		{
			super( new URLLoaderStrategy( dataFormat ) );
			
			if( name != null ) setName( name );
		}

		/**
		 * Sets how the downloaded data is received.
		 * 
		 * <p>If the value of the dataFormat property is 
		 * <code>URLLoaderDataFormat.TEXT</code>, 
		 * the received data is a string containing the text of 
		 * the loaded file.</p>
		 * <p>If the value of the dataFormat property is 
		 * <code>URLLoaderDataFormat.BINARY</code>, the received data is 
		 * a ByteArray object containing the raw binary data.</p>
		 * <p>If the value of the dataFormat property is 
		 * <code>URLLoaderDataFormat.VARIABLES</code>, the received data is 
		 * a URLVariables object containing the URL-encoded variables.</p>
		 * 
		 * <p>The default is <code>URLLoaderStrategy.TEXT</code></p>
		 * 
		 * @param	dataFormat	Downloaded data format
		 */
		public function setDataFormat( dataFormat : String ) : void
		{
			( getStrategy( ) as URLLoaderStrategy ).setDataFormat( dataFormat );
		}
	}
}