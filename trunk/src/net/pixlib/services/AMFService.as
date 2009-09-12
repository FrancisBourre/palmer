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
	import net.pixlib.core.ValueObject;
	import net.pixlib.exceptions.NullPointerException;

	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.Responder;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/**
	 * Command implementation to call a remote service method.
	 * 
	 * @example
	 * <pre class="prettyprint">
	 * 
	 * public function test( ) : void
	 * {
	 * 	var service : AMFService = new AMFService( "gateway.php", "UserService.login" );
	 * 	service.setArguments( "myLogin", "myPassword" );
	 * 	service.addServiceListener( this );
	 * 	service.execute();
	 * }
	 * 
	 * public function onDataResult ( event : ServiceEvent ) : void
	 * {
	 * 	var result : Object = event.getService().getResult();
	 * }
	 * </pre>
	 * 
	 * @author Romain Ecarnot
	 * @author Francis Bourre
	 */
	public class AMFService 
		extends AbstractService
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _helper 		: AMFServiceHelper;
		private var _oConnection 	: NetConnection;

		
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
				
		/** 
		 * @private
		 * 
		 * timeout handler.
		 */
		protected var nTimeoutHandler : uint;

		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * Returns gateway url.
		 */
		public function get gateway( ) : String
		{
			return _helper.gateway;		
		}

		/**
		 * Returns remote method name.
		 */
		public function get method(  ) : String
		{
			return _helper.method;
		}

		/**
		 * Returns remoting encoding use.
		 */
		public function get encoding(  ) : uint
		{
			return _helper.encoding;
		}

		/**
		 * Returns timeout delay.
		 */
		public function get timeout(  ) : uint
		{
			return _helper.timeout;
		}

		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */	
		public function AMFService(  gateway : String = "", method : String = "", timeout : uint = 3000, encoding : uint = 3 )
		{
			super( );
			setExecutionHelper( new AMFServiceHelper( gateway, method, timeout, encoding ) );
		}

		/**
		 * @inheritDoc
		 */
		override protected function onExecute( e : Event = null ) : void
		{
			super.onExecute( e );
			
			if ( _helper is AMFServiceHelper )
			{
				try
				{
					nTimeoutHandler = setInterval( onTimeoutHandler, timeout );
					getConnection( ).call.apply( null, getRemoteArguments() );
	
				} catch( e : Error )
				{
					getLogger( ).error( this + " call failed !. " + e.message );
					onFaultHandler( null );
				}

			} else
			{
				var msg : String = this + ".execute() failed. Can't retrieve valid execution helper.";
				getLogger().error( msg );
				throw new NullPointerException( msg );
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function setResult( result : Object ) : void
		{
			clearInterval( nTimeoutHandler );
			super.setResult( result );
		}

		/**
		 * @inheritDoc
		 */
		override public function release() : void
		{
			disposeNetConnection();
			super.release( );
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------

		/**
		 * 
		 */
		override protected function setExecutionHelper( helper : ValueObject ) : void
		{
			_helper = helper as AMFServiceHelper;
			disposeNetConnection(),
			connect();
		}

		/**
		 * 
		 */
		override protected function getRemoteArguments() : Array
		{
			return ( getArguments().length > 0 ) ? [method, getResponder()].concat(getArguments()) : [method, getResponder()];
		}

		/**
		 * 
		 */
		protected function getResponder() : Responder
		{
			return new Responder( onResultHandler, onFaultHandler );
		}
		
		protected function disposeNetConnection() : void
		{
			if( _oConnection )
			{
				_oConnection.removeEventListener( NetStatusEvent.NET_STATUS, onNetStatusHandler );
				_oConnection.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onErrorHandler );
				_oConnection.removeEventListener( IOErrorEvent.IO_ERROR, onErrorHandler );
				_oConnection.removeEventListener( AsyncErrorEvent.ASYNC_ERROR, onErrorHandler );
				_oConnection.close( );
			}
		}

		/**
		 * Inits connection.
		 */
		protected function connect() : void
		{
			_oConnection = new NetConnection();
			
			_oConnection.objectEncoding = encoding;
			_oConnection.addEventListener( NetStatusEvent.NET_STATUS, onNetStatusHandler );
			_oConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onErrorHandler );
			_oConnection.addEventListener( IOErrorEvent.IO_ERROR, onErrorHandler );
			_oConnection.addEventListener( AsyncErrorEvent.ASYNC_ERROR, onErrorHandler );
			
			try
			{
				_oConnection.connect( gateway );
			} 
			catch ( e : Error )
			{
				getLogger( ).error( this + " connection failed !. " + e.message );
			}
		}

		/**
		 * Triggered when remoting process is timeout.
		 */
		protected function onTimeoutHandler( ) : void
		{
			clearInterval( nTimeoutHandler );
			getLogger().error( this + " call failed !. Timeout !" );
			onFaultHandler( null );
		}

		/**
		 * Returns NetConnection instance used by this remoting call.
		 */
		protected function getConnection() : NetConnection
		{
			return _oConnection;
		}

		/**
		 * Triggered when NetStatus event are received from Netconnection status.
		 */
		protected function onNetStatusHandler( event : NetStatusEvent ) : void
		{
			getLogger( ).debug( this + "::" + event.info.code );
		}

		/**
		 * Triggered when an error occured in connection or in the call.
		 */
		protected function onErrorHandler( event : Event ) : void 
		{
			getLogger( ).error( this + "::" + event );
			onFaultHandler( null );
		}
	}
}