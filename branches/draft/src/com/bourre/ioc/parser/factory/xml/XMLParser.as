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
 
package com.bourre.ioc.parser.factory.xml 
{
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.ioc.parser.factory.AbstractParserCommand;	

	/**
	 * @author Romain Ecarnot
	 */
	public class XMLParser extends AbstractParserCommand 
	{
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		final override protected function setContextData( data : * = null ) : void
		{
			if( data != null )
			{
				oContext = new XML( data );
			}
			else
			{
				var msg : String = this + ".setContext() failed : " + data;
				getLogger( ).error( msg );
				throw( new IllegalArgumentException( msg ) );
			}
		}
		
		/**
		 * 
		 */
		final protected function getXMLContext( ) : XML
		{
			return getContextData( ) as XML;	
		}
		
		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
		
		function XMLParser( )
		{
			super( getConstructorAccess() );
		}		
	}
}