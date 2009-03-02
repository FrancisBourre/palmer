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
{	import com.bourre.ioc.core.ContextNameList;
	import com.bourre.ioc.load.ApplicationLoaderState;
	
	import flash.net.URLRequest;	

	/**
	 * Parser implementation for 'resources' defined in xml context.
	 *  
	 * @author romain Ecarnot
	 */
	public class ResourceParser extends XMLParser
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates instance.
		 */	
		public function ResourceParser( )
		{
			
		}		
		
		/**
		 * @inheritDoc
		 */
		override public function parse( ) : void
		{
			var dllXML : XMLList = getXMLContext().child( ContextNameList.RSC );	
			var l : int = dllXML.length( );
			for ( var i : int = 0; i < l ; i++ ) 
			{
				_parseNode( dllXML[ i ] );
			}
			delete getXMLContext()[ ContextNameList.RSC ];
			
			fireCommandEndEvent();
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.RSC_PARSE_STATE;
		}
		
		/** @private */
		protected function _parseNode( node : XML ) : void
		{
			getAssembler( ).buildResource( AttributeUtils.getID( node ), new URLRequest( AttributeUtils.getURL( node ) ), AttributeUtils.getType( node ), AttributeUtils.getDeserializerClass( node ) );
		}	}}