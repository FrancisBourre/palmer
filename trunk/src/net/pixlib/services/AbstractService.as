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
package net.pixlib.services 
{
	import net.pixlib.collections.Collection;
	import net.pixlib.commands.AbstractCommand;
	import net.pixlib.core.ValueObject;
	import net.pixlib.encoding.Deserializer;
	import net.pixlib.exceptions.UnsupportedOperationException;
	import net.pixlib.log.PalmerDebug;

	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * @author Francis Bourre
	 */
	public class AbstractService 
		extends AbstractCommand 
		implements Service
	{
		static private var _POOL : Dictionary = new Dictionary();
		
		static protected function isRegistered( o : AbstractService ) : Boolean
		{
			return AbstractService._POOL[ o ];
		}

		static protected function register( o : AbstractService ) : void
		{
			if ( AbstractService._POOL[ o ] == null )
			{
				AbstractService._POOL[ o ] = true;

			} else
			{
				PalmerDebug.WARN( o + " is already registered" );
			}
		}
		
		static protected function unregister( o : AbstractService ) : void
		{
			if( AbstractService._POOL[ o ] != null )
			{
				delete AbstractService._POOL[ o ];
			} 
			else
			{
				PalmerDebug.WARN( o + " cannot be unregistered" );
			}
		}

		private var _result 	: Object;
		private var _rawResult 	: Object;
		private var _args 		: Array;

		protected var _deserializer : Deserializer;

		public function setResult( result : Object ) : void
		{
			_rawResult = result;
			_result = _deserializer ? _deserializer.deserialize( result, this ) : result;
		}
		
		public function getResult() : Object
		{
			return _result;
		}
		
		public function getRawResult() : Object
		{
			return _rawResult;
		}
		
		public function addServiceListener( listener : ServiceListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}
		
		public function removeServiceListener( listener : ServiceListener ) : Boolean
		{
			return _oEB.removeListener( listener );
		}

		public function getServiceListener() : Collection
		{
			return _oEB.getListenerCollection();
		}
		
		public function addArguments( ...rest ) : void
		{
			if ( !_args ) _args = new Array();
			_args.concat( rest.concat() );
		}

		public function setArguments( ...rest ) : void
		{
			_args = rest.concat();
		}

		final public function getArguments() : Object
		{
			return _args;
		}

		override protected function onExecute( e : Event = null ) : void
		{
			AbstractService.register( this );
		}
		
		override protected function onCancel() : void
		{
			//TODO implementation
		}

		public function fireResult( e : Event = null ) : void
		{
			_oEB.broadcastEvent( new ServiceEvent( ServiceEvent.onDataResultEVENT, this ) );
		}

		public function fireError( e : Event = null ) : void
		{
			_oEB.broadcastEvent( new ServiceEvent( ServiceEvent.onDataErrorEVENT, this ) );
		}

		public function release() : void
		{
			_oEB.removeAllListeners();
			_args 			= null;
			_result 		= null;
			_deserializer 	= null;
		}

		public function setDeserializer( deserializer : Deserializer, target : Object = null ) : void
		{
			_deserializer 	= deserializer;
			_result 		= target;
		}

		protected function setExecutionHelper( helper : ValueObject ) : void
		{
			var msg : String = this + ".setExecutionHelper() is unsupported.";
			getLogger().error( msg );
			throw new UnsupportedOperationException( msg );	
		}
		
		protected function getRemoteArguments() : Array
		{
			var msg : String = this + ".getRemoteArguments() is unsupported.";
			getLogger().error( msg );
			throw new UnsupportedOperationException( msg );	
		}
		
		/**
		 * Triggered when result is received.
		 */
		final protected function onResultHandler( o : Object ) : void
		{
			if ( isRegistered( this ) )
			{
				AbstractService.unregister( this );
				setResult( o );
				fireResult();
				fireCommandEndEvent();
			}
		}

		/**
		 * Triggered when an error occured.
		 */
		final protected function onFaultHandler( o : Object ) : void
		{
			if ( isRegistered( this ) )
			{
				AbstractService.unregister( this );
				fireError();
				fireCommandEndEvent();
			}
		}
	}
}
