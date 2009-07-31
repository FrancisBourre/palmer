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
package net.pixlib.ioc.parser.factory.xml
{
	import net.pixlib.ioc.core.ContextAttributeList;
	import net.pixlib.ioc.core.ContextNameList;
	import net.pixlib.ioc.exceptions.NullChannelException;
	import net.pixlib.ioc.exceptions.NullIDException;
	import net.pixlib.ioc.load.ApplicationLoaderState;
	import net.pixlib.log.PalmerDebug;

	import flash.net.URLRequest;

	/**
	 * @author Francis Bourre
	 */
	public class DisplayObjectParser extends XMLParser
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
				
		public function DisplayObjectParser(  )
		{
		}

		override public function parse( ) : void
		{
			var displayXML : XMLList = getXMLContext( )[ ContextNameList.ROOT ];

			if ( displayXML.length( ) > 0  )
			{
				var rootID : String = displayXML.attribute( ContextAttributeList.ID );
				
				if ( rootID )
				{
					getAssembler( ).buildRoot( rootID );
				} 
				else
				{
					var msg : String = this + "ID attribute is mandatory with 'root' node.";
					PalmerDebug.FATAL( msg );
					throw( new NullIDException( msg ) );
				}
				
				for each ( var node : XML in displayXML.* ) _parseNode( node, rootID );
				delete getXMLContext( )[ ContextNameList.ROOT ];
			}
			
			fireCommandEndEvent();
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.GFX_PARSE_STATE;
		}

		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
				
		private function _parseNode( xml : XML, parentID : String = null ) : void
		{
			var msg : String;

			// Filter reserved nodes
			if ( ContextNameList.getInstance( ).nodeNameIsReserved( xml.name( ) ) ) return;

			var id : String = AttributeUtils.getID( xml );
			if ( !id )
			{
				msg = this + " encounters parsing error with '" + xml.name( ) + "' node. You must set an id attribute.";
				PalmerDebug.FATAL( msg );
				throw( new NullIDException( msg ) );
			}

			getAssembler( ).registerID( id );

			var url : String = AttributeUtils.getURL( xml );
			var visible : String = AttributeUtils.getVisible( xml );
			var isVisible : Boolean = visible ? (visible == "true") : true;
			var type : String = AttributeUtils.getDisplayType( xml );

			getAssembler( ).buildDisplayObject( id, parentID, url ? new URLRequest( url ) : null, isVisible, type );

			// Build property.
			for each ( var property : XML in xml[ ContextNameList.PROPERTY ] )
			{
				getAssembler( ).buildProperty( id, AttributeUtils.getName( property ), AttributeUtils.getValue( property ), AttributeUtils.getType( property ), AttributeUtils.getRef( property ), AttributeUtils.getMethod( property ) );
			}

			// Build method call.
			for each ( var method : XML in xml[ ContextNameList.METHOD_CALL ] )
			{
				getAssembler( ).buildMethodCall( id, AttributeUtils.getName( method ), XMLUtils.getArguments( method, ContextNameList.ARGUMENT ) );
			}

			// Build channel listener.
			for each ( var listener : XML in xml[ ContextNameList.LISTEN ] )
			{
				var channelName : String = AttributeUtils.getRef( listener );
				if ( channelName )
				{
					getAssembler( ).buildChannelListener( id, channelName );
				} 
				else
				{
					msg = this + " encounters parsing error with '" + xml.name( ) + "' node, 'channel' attribute is mandatory in a 'listen' node.";
					PalmerDebug.FATAL( msg );
					throw( new NullChannelException( msg ) );
				}
			}

			// recursivity
			for each ( var node : XML in xml.* ) _parseNode( node, id );
		}
	}
}