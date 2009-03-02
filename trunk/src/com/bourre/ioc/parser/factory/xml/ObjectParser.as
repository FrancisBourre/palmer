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
	import com.bourre.events.ApplicationBroadcaster;
	import com.bourre.ioc.assembler.ApplicationAssembler;
	import com.bourre.ioc.core.ContextNameList;
	import com.bourre.ioc.core.ContextTypeList;
	import com.bourre.ioc.exceptions.NullChannelException;
	import com.bourre.ioc.exceptions.NullIDException;
	import com.bourre.ioc.load.ApplicationLoaderState;
	import com.bourre.log.PalmerDebug;	

	/**
	 * @author Francis Bourre
	 */
	public class ObjectParser
		extends XMLParser
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
				
		public function ObjectParser( )
		{
		}
		
		override public function parse( ) : void
		{
			for each ( var node : XML in getXMLContext( ).* ) parseNode( node );
			
			fireCommandEndEvent();
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.OBJECT_PARSE_STATE;
		}

		protected function parseNode( xml : XML ) : void
		{
			var msg : String;
			
			var id : String = AttributeUtils.getID( xml );
			if ( !id )
			{
				msg = this + " encounters parsing error with '" + xml.name( ) + "' node. You must set an id attribute.";
				PalmerDebug.FATAL( msg );
				throw( new NullIDException( msg ) );
			}
			
			getAssembler( ).registerID( id );
			
			var type : String;
			var args : Array;
			var factory : String;
			var singleton : String;

			// Build object.
			type = AttributeUtils.getType( xml );

			if ( type == ContextTypeList.XML )
			{
				args = new Array( );
				args.push( {ownerID:id, value:xml.children( )} );
				factory = AttributeUtils.getDeserializerClass( xml );
				getAssembler( ).buildObject( id, type, args, factory );
			} 
			else
			{
				args = (type == ContextTypeList.DICTIONARY) ? XMLUtils.getItems( xml ) : XMLUtils.getArguments( xml, ContextNameList.ARGUMENT, type );
				factory = AttributeUtils.getFactoryMethod( xml );
				singleton = AttributeUtils.getSingletonAccess( xml );

				getAssembler( ).buildObject( id, type, args, factory, singleton );
	
				// register each object to system channel.
				getAssembler( ).buildChannelListener( id, ApplicationBroadcaster.getInstance( ).SYSTEM_CHANNEL.toString( ) );
	
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
						var listenerArgs : Array = XMLUtils.getArguments( listener, ContextNameList.EVENT );
						getAssembler( ).buildChannelListener( id, channelName, listenerArgs );
					} 
					else
					{
						msg = this + " encounters parsing error with '" + xml.name( ) + "' node, 'ref' attribute is mandatory in a 'listen' node.";
						PalmerDebug.FATAL( msg );
						throw( new NullChannelException( msg ) );
					}
				}
			}
		}
	}
}