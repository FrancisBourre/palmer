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
	import com.bourre.ioc.parser.factory.xml.AttributeUtils;
	import com.bourre.ioc.parser.factory.xml.XMLParser;
	
	import flash.net.URLRequest;	

	/**
	 * @author Francis Bourre
	 */
	public class DLLParser extends XMLParser
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */	
		public function DLLParser(  )
		{
		}
		
		/**
		 * @inheritDoc
		 */
		override public function parse( ) : void
		{
			var list : XMLList = getXMLContext().child( ContextNameList.DLL );	
			var l : int = list.length();
			for ( var i : int = 0; i < l; i++ ) parseNode( list[ i ] );
			delete getXMLContext()[ ContextNameList.DLL ];
			
			fireCommandEndEvent();
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.DLL_PARSE_STATE;
		}
		
		protected function parseNode( node : XML ) : void
		{
			getAssembler().buildDLL( new URLRequest( AttributeUtils.getURL( node ) ) );
		}	}}