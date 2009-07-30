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
	import com.bourre.ioc.core.ContextNameList;
	import com.bourre.ioc.load.ApplicationLoaderState;
	import com.bourre.ioc.parser.factory.xml.XMLParser;
	import com.bourre.utils.FlashVars;

	/**
	 * Parses <code>var</code> node from IoC XML Context and registers 
	 * values into the FlashVars data model.
	 * 
	 * @author Romain Ecarnot
	 */
	public class VarParser extends XMLParser
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
					
		/**
		 * Creates instance.
		 */
		public function VarParser(  )
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		override public function parse( ) : void
		{
			var varList : XMLList = getXMLContext().child( ContextNameList.VAR );	
			for each( var node : XML in varList )
			{
				FlashVars.getInstance().register( node.@name.toString(), node.@value.toString() );
			}
			
			delete getXMLContext()[ ContextNameList.VAR ];
			
			fireCommandEndEvent();
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.VAR_PARSE_STATE;
		}
	}
}
