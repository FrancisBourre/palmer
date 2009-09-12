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
package net.pixlib.load
{
	import net.pixlib.commands.AbstractCommand;
	import net.pixlib.events.CommandEvent;
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.exceptions.NullPointerException;
	import net.pixlib.load.Loader;
	import net.pixlib.load.strategy.LoadStrategy;
	import net.pixlib.log.PalmerDebug;

	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.Dictionary;

	/**
	 *  Dispatched when loader starts loading.
	 *  
	 *  @eventType net.pixlib.load.LoaderEvent.onLoadStartEVENT
	 */
	[Event(name="onLoadStart", type="net.pixlib.load.LoaderEvent")]

	/**
	 *  Dispatched when loading is finished.
	 *  
	 *  @eventType net.pixlib.load.LoaderEvent.onLoadInitEVENT
	 */
	[Event(name="onLoadInit", type="net.pixlib.load.LoaderEvent")]

	/**
	 *  Dispatched during loading progression.
	 *  
	 *  @eventType net.pixlib.load.LoaderEvent.onLoadProgressEVENT
	 */
	[Event(name="onLoadProgress", type="net.pixlib.load.LoaderEvent")]

	/**
	 *  Dispatched when a timeout occurs during loading.
	 *  
	 *  @eventType net.pixlib.load.LoaderEvent.onLoadTimeOutEVENT
	 */
	[Event(name="onLoadTimeOut", type="net.pixlib.load.LoaderEvent")]

	/**
	 *  Dispatched when an error occurs during loading.
	 *  
	 *  @eventType net.pixlib.load.LoaderEvent.onLoadErrorEVENT
	 */
	[Event(name="onLoadError", type="net.pixlib.load.LoaderEvent")]

	/**
	 * The AbstractLoader class.
	 * 
	 * @author 	Francis Bourre
	 */
	public class AbstractLoader 
		extends AbstractCommand
		implements 	net.pixlib.load.Loader
	{
		static private var _oPool : Dictionary = new Dictionary();

		/**
		 * @private
		 * 
		 * Allow to avoid gc on local loader.
		 */
		static protected function registerLoaderToPool( o : Loader ) : void
		{
			if( _oPool[ o ] == null )
			{
				_oPool[ o ] = true;
			} 
			else
			{
				PalmerDebug.WARN( o + " is already registered in the loading pool" );
			}
		}

		/**
		 * @private
		 */
		static protected function unregisterLoaderFromPool( o : Loader ) : void
		{
			if( _oPool[ o ] != null )
			{
				delete _oPool[ o ];
			} 
			else
			{
				PalmerDebug.WARN( o + " is not registered in the loading pool" );
			}
		}

		
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------

		protected var _sName : String;
		protected var _URL : URLRequest;
		protected var _sURL : String;
		protected var _bAntiCache : Boolean;
		protected var _sPrefixURL : String;

		protected var _loadStrategy : LoadStrategy;		protected var _oContext : LoaderContext;
		protected var _oContent : Object;
		protected var _nLastBytesLoaded : Number;
		
		protected var _bMustUnregister : Boolean;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates new <code>AbstractLoader</code> instance.
		 * 
		 * @param	strategy	Loading strategy to use in this loader.
		 */
		public function AbstractLoader( strategy : LoadStrategy = null )
		{
			super();

			_oEB.setListenerType( LoaderListener );

			_loadStrategy = (strategy != null) ? strategy : new NullLoadStrategy( );
			_loadStrategy.setOwner( this );

			_bAntiCache = false;
			_sPrefixURL = "";
			_oContext = new LoaderContext( false, ApplicationDomain.currentDomain );
		}

		/**
		 * @inheritDoc
		 */
		public function getStrategy() : LoadStrategy
		{
			return _loadStrategy;
		}

		/**
		 * 
		 */
		public function load( url : URLRequest = null, context : LoaderContext = null ) : void
		{
			if ( url ) setURL( url );
			if ( context ) setContext( context );
			execute();
		}

		/**
		 * @inheritDoc
		 */
		public function setContext( context : LoaderContext ) : void
		{
			_oContext = context;
		}

		/**
		 * @inheritDoc
		 */
		public function getContext() : LoaderContext
		{
			return _oContext;
		}
		
		/**
		 * Returns the number of bytes loaded.
		 * 
		 * @return The number of bytes loaded
		 */
		public function getBytesLoaded() : uint
		{
			return _loadStrategy.getBytesLoaded( );
		}
		
		/**
		 * Returns the total number of bytes to load.
		 * 
		 * @return The total number of bytes to load
		 */
		public function getBytesTotal() : uint
		{
			return _loadStrategy.getBytesTotal( );
		}
		
		/**
		 * @inheritDoc
		 */
		final public function getPerCent() : Number
		{
			var n : Number = Math.min( 100, Math.ceil( getBytesLoaded( ) / ( getBytesTotal( ) / 100 ) ) );
			return ( isNaN( n ) ) ? 0 : n;
		}
		
		/**
		 * Returns <code>true</code> if all bytes are loaded.
		 * 
		 * @return	<code>true</code> if all bytes are loaded.
		 */
		final public function isLoaded( ) : Boolean
		{
			return ( getBytesLoaded( ) / getBytesTotal( ) ) == 1 ;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getURL() : URLRequest
		{
			_URL.url = _bAntiCache ? _sPrefixURL + _sURL + "?nocache=" + _getStringTimeStamp( ) : _sPrefixURL + _sURL;
			
			return _URL;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setURL( url : URLRequest ) : void
		{
			_URL = url;
			_sURL = _URL.url;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addListener( listener : LoaderListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeListener( listener : LoaderListener ) : Boolean
		{
			return _oEB.removeListener( listener );
		}

		/**
		 * @inheritDoc
		 */
		public function getName() : String
		{
			return _sName;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setName( sName : String ) : void
		{
			_sName = sName;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setAntiCache( b : Boolean ) : void
		{
			_bAntiCache = b;
		}
		
		/**
		 * Returns <code>true</code> if 'anticache' system is on.
		 * 
		 * @return <code>true</code> if 'anticache' system is on.
		 */
		public function isAntiCache() : Boolean
		{
			return _bAntiCache;
		}
		
		/**
		 * @inheritDoc
		 */
		public function prefixURL( sURL : String ) : void
		{
			_sPrefixURL = sURL;
		}

		/**
		 * Releases instance and all registered listeners.
		 */
		public function release() : void
		{
			if ( _bMustUnregister ) 
			{
				LoaderLocator.getInstance().unregister( getName() );
				_bMustUnregister = false;
			}
			
			_loadStrategy.release( );
			_oEB.removeAllListeners( );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getContent() : Object
		{
			return _oContent;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setContent( content : Object ) : void
		{	
			_oContent = content;
		}

		/**
		 * @inheritDoc
		 */
		public function fireOnLoadStartEvent() : void
		{
			fireEventType( LoaderEvent.onLoadStartEVENT );
		}
		
		/**
		 * @inheritDoc
		 */
		public function fireOnLoadProgressEvent() : void
		{
			fireEventType( LoaderEvent.onLoadProgressEVENT );
		}
		
		/**
		 * @inheritDoc
		 */
		final public function fireOnLoadInitEvent() : void
		{
			onInitialize();
			fireCommandEndEvent();
		}
		
		/**
		 * @inheritDoc
		 */
		public function fireOnLoadErrorEvent( message : String = "" ) : void
		{
			fireEventType( LoaderEvent.onLoadErrorEVENT, message );
			fireCommandEndEvent();
		}
		
		/**
		 * @inheritDoc
		 */
		public function fireOnLoadTimeOut() : void
		{
			fireEventType( LoaderEvent.onLoadTimeOutEVENT );
			fireCommandEndEvent();
		}

		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected function onInitialize() : void
		{
			if ( getName( ) != null ) 
			{
				if ( !(LoaderLocator.getInstance( ).isRegistered( getName( ) )) )
				{
					_bMustUnregister = true;
					LoaderLocator.getInstance( ).register( getName( ), this );
				} 
				else
				{
					_bMustUnregister = false;
					var msg : String = this + " can't be registered to " + LoaderLocator.getInstance( ) + " with '" + getName( ) + "' name. This name already exists.";
					PalmerDebug.ERROR( msg );
					fireOnLoadErrorEvent( msg );
					throw new IllegalArgumentException( msg );
				}
			}
			
			fireEventType( LoaderEvent.onLoadProgressEVENT );
			fireEventType( LoaderEvent.onLoadInitEVENT );
		}
		
		/**
		 * @copy net.pixlib.events.EventBroadcaster#setListenerType()
		 */
		final protected function setListenerType( type : Class ) : void
		{
			_oEB.setListenerType( type );
		}
		
		/**
		 * Dispatches event using passed-in type and optional error message.
		 * 
		 * @param	type			Event type so dispatch
		 * @param	errorMessage	(optional) Error message to carry
		 * 
		 * @see #fireEvent()
		 */
		protected function fireEventType( type : String, errorMessage : String = "" ) : void
		{
			fireEvent( getLoaderEvent( type, errorMessage ) );
		}
		
		/**
		 * Dispatched passed-in event to all registered listeners.
		 * 
		 * @param	e	Event to dispatch
		 */
		protected function fireEvent( e : Event ) : void
		{
			_oEB.broadcastEvent( e );
		}
		
		/**
		 * Returns a loader event for current loader instance.
		 * 
		 * @return A loader event for current loader instance.
		 */
		protected function getLoaderEvent( type : String, errorMessage : String = "" ) : LoaderEvent
		{
			return new LoaderEvent( type, this, errorMessage );
		}
		
		/**
		 * @copy #load()
		 */
		override protected function onExecute( e : Event = null ) : void
		{
			if ( getURL( ).url.length > 0 )
			{
				_nLastBytesLoaded = 0;
				_loadStrategy.load( getURL( ), getContext() );

			} else
			{
				var msg : String = this + ".load() can't retrieve file url.";
				PalmerDebug.ERROR( msg );
				throw new NullPointerException( msg );
			}
		}
		
		override protected function onCancel() : void
		{
			release();
		}
		
		override protected function broadcastCommandStartEvent() : void
		{
			registerLoaderToPool( this );
			fireEventType( CommandEvent.onCommandStartEVENT );
		}

		override protected function broadcastCommandEndEvent() : void
		{
			fireEventType( CommandEvent.onCommandEndEVENT );
			unregisterLoaderFromPool( this );
		}
		
		//
		private function _getStringTimeStamp() : String
		{
			var d : Date = new Date( );
			return String( d.getTime( ) );
		}
	}
}

import net.pixlib.load.Loader;
import net.pixlib.load.strategy.LoadStrategy;

import flash.net.URLRequest;
import flash.system.LoaderContext;

internal class NullLoadStrategy 
	implements LoadStrategy
{
	public function load( request : URLRequest = null, context : LoaderContext = null  ) : void 
	{
	}

	public function getBytesLoaded() : uint 
	{ 
		return 0; 
	}

	public function getBytesTotal() : uint 
	{ 
		return 0; 
	}

	public function setOwner( owner : Loader ) : void 
	{
	}

	public function release() : void 
	{
	}
}