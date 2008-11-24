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
package com.bourre.load
{
	import com.bourre.commands.AbstractCommand;
	import com.bourre.commands.Command;
	import com.bourre.events.EventBroadcaster;
	import com.bourre.exceptions.IllegalStateException;
	import com.bourre.exceptions.NullPointerException;
	import com.bourre.load.strategy.LoadStrategy;
	import com.bourre.log.PalmerDebug;
	import com.bourre.log.PalmerStringifier;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import com.bourre.commands.CommandListener;	

	/**
	 * @author Francis Bourre
	 */
	public class AbstractLoader 
		implements 	com.bourre.load.Loader, Command
	{
		static private var _oPool : Dictionary = new Dictionary();

		static protected function registerLoaderToPool ( o : Loader ) : void
		{
			if( _oPool[ o ] == null )
			{
				_oPool[ o ] = true;

			} else
			{
				PalmerDebug.WARN( o + " is already registered in the loading pool" );
			}
		}

		static protected function unregisterLoaderFromPool ( o : Loader ) : void
		{
			if( _oPool[ o ] != null )
			{
				delete _oPool[ o ];

			} else
			{
				PalmerDebug.WARN( o + " is not registered in the loading pool" );
			}
		}

		protected var _oEB : EventBroadcaster;
		protected var _sName : String;
		protected var _nTimeOut : Number;
		protected var _oURL : URLRequest;
		protected var _bAntiCache : Boolean;
		protected var _sPrefixURL : String;

		protected var _loadStrategy : LoadStrategy;
		protected var _oContent : Object;
		protected var _bIsRunning : Boolean;
		protected var _nLastBytesLoaded : Number;
		protected var _nTime : int;

		public function AbstractLoader( strategy : LoadStrategy = null )
		{
			_loadStrategy = (strategy != null) ? strategy : new NullLoadStrategy();
			_loadStrategy.setOwner( this );

			_oEB = new EventBroadcaster( this, LoaderListener );
			_nTimeOut = 10000;
			_bAntiCache = false;
			_sPrefixURL = "";
			_bIsRunning = false;
		}

		public function execute( e : Event = null ) : void
		{
			load();
		}

		public function getStrategy () : LoadStrategy
		{
			return _loadStrategy;
		}

		public function load( url : URLRequest = null, context : LoaderContext = null ) : void
		{
			if ( url ) setURL( url );

			if ( getURL().url.length > 0 )
			{
				_nLastBytesLoaded = 0;
				_nTime = getTimer();

				registerLoaderToPool( this );
				_loadStrategy.load( getURL(), context );

			} else
			{
				var msg : String = this + ".load() can't retrieve file url.";
				PalmerDebug.ERROR( msg );
				throw new NullPointerException( msg );
			}
		}

		protected function onInitialize() : void
		{
			fireEventType( LoaderEvent.onLoadProgressEVENT );
			fireEventType( LoaderEvent.onLoadInitEVENT );
		}

		final protected function setListenerType( type : Class ) : void
		{
			_oEB.setListenerType( type );
		}

		public function getBytesLoaded() : uint
		{
			return _loadStrategy.getBytesLoaded();
		}

		public function getBytesTotal() : uint
		{
			return _loadStrategy.getBytesTotal();
		}

		final public function getPerCent() : Number
		{
			var n : Number = Math.min( 100, Math.ceil( getBytesLoaded() / ( getBytesTotal() / 100 ) ) );
			return ( isNaN(n) ) ? 0 : n;
		}
		
		final public function isLoaded( ) : Boolean
		{
			return ( getBytesLoaded() / getBytesTotal() ) == 1 ;
		}

		public function getURL() : URLRequest
		{
			return _bAntiCache ? new URLRequest( _sPrefixURL + _oURL.url + "?nocache=" + _getStringTimeStamp() ) : new URLRequest( _sPrefixURL + _oURL.url );
		}

		public function setURL( url : URLRequest ) : void
		{
			_oURL = url;
		}

		public function addListener( listener : LoaderListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}

		public function removeListener( listener : LoaderListener ) : Boolean
		{
			return _oEB.removeListener( listener );
		}

		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			return _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
		}

		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			return _oEB.removeEventListener( type, listener );
		}

		public function getName() : String
		{
			return _sName;
		}

		public function setName( sName : String ) : void
		{
			_sName = sName;
		}

		public function setAntiCache( b : Boolean ) : void
		{
			_bAntiCache = b;
		}

		public function isAntiCache() : Boolean
		{
			return _bAntiCache;
		}

		public function prefixURL( sURL : String ) : void
		{
			_sPrefixURL = sURL;
		}

		final public function getTimeOut() : Number
		{
			return _nTimeOut;
		}

		final public function setTimeOut( n : Number ) : void
		{
			_nTimeOut = Math.max( 1000, n );
		}

		public function release() : void
		{
			_loadStrategy.release();
			_oEB.removeAllListeners();
		}
		public function getContent() : Object
		{
			return _oContent;
		}

		public function setContent( content : Object ) : void
		{	
			_oContent = content;
		}

		public function fireOnLoadProgressEvent() : void
		{
			fireEventType( LoaderEvent.onLoadProgressEVENT );
		}

		final public function fireOnLoadInitEvent() : void
		{
			_bIsRunning = false;
			onInitialize();
			unregisterLoaderFromPool( this );
		}

		public function fireOnLoadStartEvent() : void
		{
			fireEventType( LoaderEvent.onLoadStartEVENT );
		}

		public function fireOnLoadErrorEvent( message : String = "" ) : void
		{
			fireEventType( LoaderEvent.onLoadErrorEVENT, message );
		}

		public function fireOnLoadTimeOut() : void
		{
			unregisterLoaderFromPool( this );
			fireEventType( LoaderEvent.onLoadTimeOutEVENT );
		}

		final public function fireCommandEndEvent() : void
		{
			fireEventType( AbstractCommand.onCommandEndEVENT );
		}

		/**
		 * Returns the string representation of this instance.
		 * 
		 * @return the string representation of this instance
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}

		//
		protected function fireEventType( type : String, errorMessage : String = "" ) : void
		{
			fireEvent( getLoaderEvent( type, errorMessage ) );
		}

		protected function fireEvent( e : Event ) : void
		{
			_oEB.broadcastEvent( e );
		}

		protected function getLoaderEvent( type : String, errorMessage : String = "" ) : LoaderEvent
		{
			return new LoaderEvent( type, this, errorMessage );
		}

		//
		private function _getStringTimeStamp() : String
		{
			var d : Date = new Date();
			return String( d.getTime() );
		}

		public function run () : void
		{
			if ( !isRunning() )
			{
				_bIsRunning = true;
				execute();

			} else
			{
				var msg : String = this + ".run() called wheras an operation is currently running";
				PalmerDebug.ERROR( msg );
				throw new IllegalStateException( msg );
			}
		}

		public function isRunning () : Boolean
		{
			return _bIsRunning;
		}

		/**
		 * Adds a listener that will be notified about end process.
		 * <p>
		 * The <code>addListener</code> method supports custom arguments
		 * provided by <code>EventBroadcaster.addEventListener()</code> method.
		 * </p> 
		 * @param	listener	listener that will receive events
		 * @param	rest		optional arguments
		 * @return	<code>true</code> if the listener has been added
		 * @see		com.bourre.events.EventBroadcaster#addEventListener()
		 * 			EventBroadcaster.addEventListener() documentation
		 */
		public function addCommandListener( listener : CommandListener, ... rest ) : Boolean
		{
			return _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ AbstractCommand.onCommandEndEVENT, listener ].concat( rest ) : [ AbstractCommand.onCommandEndEVENT, listener ] );
		}
		
		/**
		 * Removes listener from receiving any end process information.
		 * 
		 * @param	listener	listener to remove
		 * @return	<code>true</code> if the listener has been removed
		 * @see		com.bourre.events.EventBroadcaster#addEventListener()
		 * 			EventBroadcaster.addEventListener() documentation
		 */
		public function removeCommandListener( listener : CommandListener ) : Boolean
		{
			return _oEB.removeEventListener( AbstractCommand.onCommandEndEVENT, listener );
		}
	}
}

import com.bourre.load.Loader;
import com.bourre.load.strategy.LoadStrategy;

import flash.net.URLRequest;
import flash.system.LoaderContext;

internal class NullLoadStrategy 
	implements LoadStrategy
{
		public function load( request : URLRequest = null, context : LoaderContext = null  ) : void {}
		public function getBytesLoaded() : uint { return 0; }
		public function getBytesTotal() : uint { return 0; }
		public function setOwner( owner : Loader ) : void {}
		public function release() : void {}
}