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

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/**
	 * Command implementation to call a HTTP service.
	 * 
	 * @example
	 * <pre class="prettyprint">
	 * 
	 * public function test( ) : void
	 * {
	 * 	var service : HTTPService = new HTTPService( "getSession.php" );
	 * 	service.addVariable( "name", "myName" );
	 * 	service.addVariable( "pwd", "myPass" );
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
	public class HTTPService 
		extends AbstractService
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _helper 	: HTTPServiceHelper;
		private var _oLoader 	: URLLoader;
		private var _request 	: URLRequest;
		
		
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
		 * Returns url.
		 */
		public function get url() : String
		{
			return _helper.url;		
		}

		/**
		 * Returns remote method name.
		 */
		public function get method() : String
		{
			return _helper.method;
		}

		/**
		 * Returns remoting encoding use.
		 */
		public function get dataFormat() : String
		{
			return _helper.dataFormat;
		}

		/**
		 * Returns timeout delay.
		 */
		public function get timeout() : uint
		{
			return _helper.timeout;
		}

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */	
		public function HTTPService( url : String = "", method : String = "POST", dataFormat : String = "text", timeout : uint = 3000 )
		{
			super( );
			setExecutionHelper( new HTTPServiceHelper( url, method, dataFormat, timeout ) );
		}

		/**
		 * @inheritDoc
		 */
		override protected function onExecute( e : Event = null ) : void
		{
			super.onExecute( e );

			if ( _helper is HTTPServiceHelper )
			{
				try
				{
					_oLoader = new URLLoader();
					_oLoader.dataFormat = dataFormat;
					_oLoader.addEventListener( Event.COMPLETE, onCompleteHandler );
					_oLoader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onErrorHandler );
					_oLoader.addEventListener( IOErrorEvent.IO_ERROR, onErrorHandler );
	
					_oLoader.load( getRemoteArguments()[0] as URLRequest );
	            	
					nTimeoutHandler = setInterval( onTimeoutHandler, timeout );
	
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
			disposeURLLoader();
			super.release();
		}

		/**
		 * 
		 */
		public function setVariables( variables : URLVariables ) : void
		{
			_request.data = variables;
		}
		
		/**
		 * 
		 */
		public function getVariables() : URLVariables
		{
			return _request.data as URLVariables;
		}

		/**
		 * 
		 */
		public function addVariable( name : String, value : * ) : void
		{
			_request.data[name] = value;
		}

		/**
		 * 
		 */
		public function addHeader( name : String, value : String ) : void
		{
            _request.requestHeaders.push( new URLRequestHeader( name, value ) );
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		override protected function setExecutionHelper( helper : ValueObject ) : void
		{
			_helper = helper as HTTPServiceHelper;
			_request = new URLRequest( url );
			_request.method = method;
			setVariables( new URLVariables() );
		}
		
		/**
		 * 
		 */
		override protected function getRemoteArguments() : Array
		{
			return [_request];
		}

		/**
		 * 
		 */
		protected function disposeURLLoader() : void
		{
			if( _oLoader )
			{
				_oLoader.removeEventListener( Event.COMPLETE, onCompleteHandler );
				_oLoader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onErrorHandler );
				_oLoader.removeEventListener( IOErrorEvent.IO_ERROR, onErrorHandler );
				_oLoader.close();
			}
		}
		
		/**
		 * 
		 */
		protected function onCompleteHandler( event : Event ) : void
		{
			onResultHandler( (event.target as URLLoader).data );
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
		 * Triggered when an error occured in connection or in the call.
		 */
		protected function onErrorHandler( event : Event ) : void 
		{
			getLogger( ).error( this + "::" + event );
			
			onFaultHandler( null );
		}
	}
}