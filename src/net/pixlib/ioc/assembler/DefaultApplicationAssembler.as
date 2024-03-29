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
package net.pixlib.ioc.assembler
{
	import net.pixlib.ioc.assembler.ApplicationAssembler;
	import net.pixlib.ioc.assembler.builder.DisplayObjectBuilder;
	import net.pixlib.ioc.assembler.builder.DisplayObjectInfo;
	import net.pixlib.ioc.assembler.locator.ChannelListener;
	import net.pixlib.ioc.assembler.locator.ChannelListenerExpert;
	import net.pixlib.ioc.assembler.locator.Constructor;
	import net.pixlib.ioc.assembler.locator.ConstructorExpert;
	import net.pixlib.ioc.assembler.locator.DictionaryItem;
	import net.pixlib.ioc.assembler.locator.Method;
	import net.pixlib.ioc.assembler.locator.MethodExpert;
	import net.pixlib.ioc.assembler.locator.Property;
	import net.pixlib.ioc.assembler.locator.PropertyExpert;
	import net.pixlib.ioc.assembler.locator.Resource;
	import net.pixlib.ioc.core.ContextTypeList;
	import net.pixlib.ioc.core.IDExpert;
	import net.pixlib.utils.HashCodeFactory;

	import flash.net.URLRequest;

	/**
	 * @author Francis Bourre	 * @author Romain Ecarnot
	 */
	public class DefaultApplicationAssembler  implements ApplicationAssembler
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------

		protected var _oIE : IDExpert;
		protected var _oDOB : DisplayObjectBuilder;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
				
		/**
		 * @inheritDoc
		 */
		public function setDisplayObjectBuilder( displayObjectBuilder : DisplayObjectBuilder ) : void
		{
			_oDOB = displayObjectBuilder;
			_oIE = new IDExpert( );
		}

		/**
		 * @inheritDoc
		 */
		public function getDisplayObjectBuilder() : DisplayObjectBuilder
		{
			return _oDOB;
		}

		/**
		 * @inheritDoc
		 */
		public function buildRoot( ID : String ) : void
		{
			getDisplayObjectBuilder( ).buildDisplayObject( new DisplayObjectInfo( ID, null, true, null, null ) );
		}

		/**
		 * @inheritDoc
		 */
		public function buildDLL( url : URLRequest ) : void
		{
			getDisplayObjectBuilder( ).buildDLL( new DisplayObjectInfo( null, null, false, url ) );
		}

		/**
		 * @inheritDoc
		 */
		public function buildResource( ID : String, url : URLRequest, type : String = null, deserializer : String = null ) : void
		{
			getDisplayObjectBuilder( ).buildResource( new Resource( ID, url, type, deserializer ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function buildDisplayObject( 		ID : String,
													parentID : String,
													url : URLRequest = null,
													isVisible : Boolean = true,
													type : String = null ) : void
		{
			getDisplayObjectBuilder( ).buildDisplayObject( new DisplayObjectInfo( ID, parentID, isVisible, url, type ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function buildProperty( 	ownerID : String, 
										name : String = null, 
										value : String = null, 
										type : String = null, 
										ref : String = null, 
										method : String = null	) : void
		{
			PropertyExpert.getInstance( ).addProperty( ownerID, name, value, type, ref, method );
		}
		
		/**
		 * @inheritDoc
		 */
		public function buildObject( 	ownerID : String, 
										type : String = null, 
										args : Array = null, 
										factory : String = null, 
										singleton : String = null) : void
		{
			if ( args != null )
			{
				var l : int = args.length;
				var i : int;
				var o : Object;

				if ( type == ContextTypeList.DICTIONARY )
				{
					for ( i = 0; i < l ; i++ )
					{
						o = args[ i ];
						var key : Object = o.key;
						var value : Object = o.value;
						var pKey : Property = PropertyExpert.getInstance( ).buildProperty( ownerID, key.name, key.value, key.type, key.ref, key.method );
						var pValue : Property = PropertyExpert.getInstance( ).buildProperty( ownerID, value.name, value.value, value.type, value.ref, value.method );
						args[ i ] = new DictionaryItem( pKey, pValue );
					}
				} 
				else
				{
					for ( i = 0; i < l ; i++ )
					{
						o = args[ i ];
						var p : Property = PropertyExpert.getInstance( ).buildProperty( ownerID, o.name, o.value, o.type, o.ref, o.method );
						args[ i ] = p;
					}
				}
			}

			ConstructorExpert.getInstance( ).register( ownerID, new Constructor( ownerID, type, args, factory, singleton ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function buildMethodCall( ownerID : String, methodCallName : String, args : Array = null ) : void
		{
			if ( args != null )
			{
				var l : int = args.length;
				for ( var i : int; i < l ; i++ )
				{
					var o : Object = args[ i ];
					var p : Property = new Property( o.id, o.name, o.value, o.type, o.ref, o.method );
					args[ i ] = p;
				}
			}
			
			var method : Method = new Method( ownerID, methodCallName, args );
			var index : Number = MethodExpert.getInstance( ).getKeys( ).length++;
			MethodExpert.getInstance( ).register( getOrderedKey( index ), method );
		}
		
		/**
		 * @inheritDoc
		 */
		public function buildChannelListener( ownerID : String, channelName : String, args : Array = null ) : void
		{
			var channelListener : ChannelListener = new ChannelListener( ownerID, channelName, args );
			ChannelListenerExpert.getInstance( ).register( HashCodeFactory.getKey( channelListener ), channelListener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function registerID( ID : String ) : Boolean
		{
			return _oIE.register( ID );
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * Returns ordered key using passed-in index value.
		 */
		protected function getOrderedKey( index : Number ) : String
		{
			var d : Number = 5 - index.toString( ).length;
			var s : String = "";
			if( d > 0 ) for( var i : Number = 0; i < d ; i++ ) s += "0";
			return s + index;
		}
	}
}

internal class ConstructorAccess 
{
}