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
package net.pixlib.ioc.assembler.builder 
{
	import net.pixlib.collections.HashMap;
	import net.pixlib.commands.CommandListener;
	import net.pixlib.core.CoreFactory;
	import net.pixlib.core.ValueObject;
	import net.pixlib.encoding.Deserializer;
	import net.pixlib.events.EventBroadcaster;
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.exceptions.IllegalStateException;
	import net.pixlib.ioc.assembler.builder.DisplayObjectBuilder;
	import net.pixlib.ioc.assembler.builder.DisplayObjectBuilderEvent;
	import net.pixlib.ioc.assembler.builder.DisplayObjectBuilderListener;
	import net.pixlib.ioc.assembler.builder.DisplayObjectEvent;
	import net.pixlib.ioc.assembler.builder.DisplayObjectInfo;
	import net.pixlib.ioc.assembler.locator.Resource;
	import net.pixlib.ioc.assembler.locator.ResourceExpert;
	import net.pixlib.ioc.core.ContextTypeList;
	import net.pixlib.load.FileLoader;
	import net.pixlib.load.GraphicLoader;
	import net.pixlib.load.Loader;
	import net.pixlib.load.LoaderEvent;
	import net.pixlib.load.LoaderLocator;
	import net.pixlib.load.QueueLoader;
	import net.pixlib.load.QueueLoaderEvent;
	import net.pixlib.load.palmer_GraphicLoader;
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.utils.FlashVars;
	import net.pixlib.utils.HashCodeFactory;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 *  Dispatched when a context element starts loading.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onLoadStartEVENT
	 */
	[Event(name="onLoadStart", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when a context element loading is finished.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onLoadInitEVENT
	 */
	[Event(name="onLoadInit", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched during context element loading progression.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onLoadProgressEVENT
	 */
	[Event(name="onLoadProgress", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when a timemout occurs during context element loading.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onLoadTimeOutEVENT
	 */
	[Event(name="onLoadTimeOut", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when an error occurs during context element loading.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onLoadErrorEVENT
	 */
	[Event(name="onLoadErrorEVENT", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when display list build is processing.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onDisplayObjectBuilderLoadStartEVENT
	 */
	[Event(name="onDisplayObjectBuilderLoadStart", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when display list build is finished.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onDisplayObjectBuilderLoadInitEVENT
	 */
	[Event(name="onDisplayObjectBuilderLoadInit", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when engine starts display list treatment.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onDisplayObjectLoadStartEVENT
	 */
	[Event(name="onDisplayObjectLoadStart", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when display list treatment is finished. 
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onDisplayObjectLoadInitEVENT
	 */
	[Event(name="onDisplayObjectLoadInit", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when engine starts DLL list treatment.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onDLLLoadStartEVENT
	 */
	[Event(name="onDLLLoadStart", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when DLL list treatment is finished. 
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onDLLLoadInitEVENT
	 */
	[Event(name="onDLLLoadInit", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when engine starts resources list treatment.
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onRSCLoadStartEVENT
	 */
	[Event(name="onRSCLoadStart", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 *  Dispatched when resources list treatment is finished. 
	 *  
	 *  @eventType net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent.onRSCLoadInitEVENT
	 */
	[Event(name="onRSCLoadInit", type="net.pixlib.ioc.assembler.displayobject.DisplayObjectBuilderEvent")]

	/**
	 * <p>Default display object builder implementation.</p>
	 * 
	 * @author Francis Bourre
	 */
	public class DefaultDisplayObjectBuilder implements DisplayObjectBuilder
	{
		//--------------------------------------------------------------------
		// Constants
		//--------------------------------------------------------------------
		
		static public const SPRITE : String = ContextTypeList.SPRITE;
		static public const MOVIECLIP : String = ContextTypeList.MOVIECLIP;
		static public const TEXTFIELD : String = ContextTypeList.TEXTFIELD;
		
		
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------

		protected var _target : DisplayObjectContainer;
		protected var _rootID : String;
		protected var _oEB : EventBroadcaster;
		protected var _dllQueue : QueueLoader;		protected var _rscQueue : QueueLoader;
		protected var _gfxQueue : QueueLoader;
		
		protected var _mDisplayObject : HashMap;
		protected var _bIsAntiCache : Boolean;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates instance.
		 */
		public function DefaultDisplayObjectBuilder( rootTarget : DisplayObjectContainer = null )
		{
			if  ( rootTarget != null ) setRootTarget( rootTarget );

			_dllQueue = new QueueLoader( );			_rscQueue = new QueueLoader( );
			_gfxQueue = new QueueLoader( );
			_mDisplayObject = new HashMap( );
			
			_oEB = new EventBroadcaster( this, DisplayObjectBuilderListener );
			_bIsAntiCache = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setAntiCache( b : Boolean ) : void
		{
			_bIsAntiCache = b;
			_dllQueue.setAntiCache( b );
			_rscQueue.setAntiCache( b );			_gfxQueue.setAntiCache( b );
		}

		/**
		 * @inheritDoc
		 */
		public function isAntiCache() : Boolean
		{
			return _bIsAntiCache;
		}

		/**
		 * Returns the root registration ID.
		 */
		public function getRootID() : String
		{
			return _rootID ? _rootID : generateRootID( );
		}

		/**
		 * @inheritDoc
		 */
		public function size() : uint
		{
			return _dllQueue.size( ) + _gfxQueue.size( ) + _rscQueue.size( );
		}

		/**
		 * @inheritDoc
		 */
		public function setRootTarget( target : DisplayObjectContainer ) : void
		{
			if ( target is DisplayObjectContainer )
			{
				_target = target;

				try
				{
					var param : Object = LoaderInfo( _target.root.loaderInfo ).parameters;
					for ( var p : * in param ) 
					{
						FlashVars.getInstance().register( p, param[ p ] );
					}
				} 
				catch ( e : Error )
				{
					PalmerDebug.ERROR( this + "::" + e.message );
				}
			} 
			else
			{
				var msg : String = this + ".setRootTarget call failed. Argument is not a DisplayObjectContainer.";
				PalmerDebug.ERROR( msg );
				throw( new IllegalStateException( msg ) );
			}
		}

		/**
		 * @inheritDoc
		 */
		public function getRootTarget() : DisplayObjectContainer
		{
			return _target;
		}
		
		/**
		 * @inheritDoc
		 */
		public function buildDLL( valueObject : ValueObject ) : void
		{
			var info : DisplayObjectInfo = valueObject as DisplayObjectInfo;

			var gl : GraphicLoader = new GraphicLoader( null, -1, false );
			_dllQueue.add( gl, "DLL" + HashCodeFactory.getNextKey( ), info.url, new LoaderContext( false, ApplicationDomain.currentDomain ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function buildResource( valueObject : ValueObject) : void
		{
			var info : Resource = valueObject as Resource;
			var loader : FileLoader = new FileLoader( );
			
			if( info.type == URLLoaderDataFormat.BINARY )
			{
				loader.setDataFormat( URLLoaderDataFormat.BINARY );
			}
			
			ResourceExpert.getInstance( ).register( info.id, info );
			
			_rscQueue.add( loader, info.id, info.url, new LoaderContext( false, ApplicationDomain.currentDomain ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function buildDisplayObject( valueObject : ValueObject ) : void
		{
			var info : DisplayObjectInfo = valueObject as DisplayObjectInfo;

			if ( !info.isEmptyDisplayObject( ) )
			{
				var gl : GraphicLoader = new GraphicLoader( null, -1, info.isVisible );
				_gfxQueue.add( gl, info.ID, info.url, new LoaderContext( false, ApplicationDomain.currentDomain ) );
			}
			
			_mDisplayObject.put( info.ID, info );

			if ( info.parentID ) 
			{
				_mDisplayObject.get( info.parentID ).addChild( info );
			} 
			else
			{
				_rootID = info.ID;
			}
		}

		/**
		 * Builds display list.
		 */
		public function buildDisplayList() : void
		{
			if( !CoreFactory.getInstance().isBeanRegistered( _target ) )
			{
				CoreFactory.getInstance( ).register( getRootID( ), _target );
			}
			
			_buildDisplayList( getRootID( ) );
			fireEvent( DisplayObjectBuilderEvent.onDisplayObjectBuilderLoadInitEVENT );
		}

		/**
		 * Starts processing.
		 */
		public function execute( e : Event = null ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDisplayObjectBuilderLoadStartEVENT );
			
			loadDLLQueue( );
		}
		
		/**
		 * Loads DLL queue.( if any ).
		 * 
		 * <p>If queue is empty, pass to <code>loadRSCQueue()</code> method.</p>
		 * 
		 * @see #loadRSCQueue()
		 */
		public function loadDLLQueue() : void
		{
			if ( !(_executeQueueLoader( _dllQueue, onDLLLoadStart, onDLLLoadInit )) ) loadRSCQueue( );
		}
		
		/**
		 * Triggered when DLL queue starts loading.
		 */
		public function onDLLLoadStart( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDLLLoadStartEVENT, e.getLoader( ) );
		}
		
		/**
		 * Triggered when DLL queue loading is finished.
		 */
		public function onDLLLoadInit( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDLLLoadInitEVENT, e.getLoader( ) );
			loadRSCQueue( );
		}
		
		/**
		 * Loads Resources queue.( if any ).
		 * 
		 * <p>If queue is empty, pass to <code>loadDisplayObjectQueue()</code> method.</p>
		 * 
		 * @see #loadDisplayObjectQueue()
		 */
		public function loadRSCQueue() : void
		{
			if ( !(_executeQueueLoader( _rscQueue, onRSCLoadStart, onRSCLoadInit, qlOnRSCLoadInit )) ) loadDisplayObjectQueue( );
		}
		
		/**
		 * Triggered when Resources queue starts loading.
		 */
		public function onRSCLoadStart( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onRSCLoadStartEVENT, e.getLoader( ) );
		}
		
		/**
		 * Triggered when Resources queue loading is finished.
		 */
		public function onRSCLoadInit( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onRSCLoadInitEVENT, e.getLoader( ) );
			
			ResourceExpert.release( );
			
			loadDisplayObjectQueue( );
		}
		
		/**
		 * Loads Display objects queue.( if any ).
		 * 
		 * <p>If queue is empty, pass to <code>buildDisplayList()</code> method.</p>
		 * 
		 * @see #buildDisplayList()
		 */
		public function loadDisplayObjectQueue() : void
		{
			if ( !(_executeQueueLoader( _gfxQueue, onDisplayObjectLoadStart, onDisplayObjectLoadInit )) ) buildDisplayList( );
		}
		
		/**
		 * Triggered when Display objects queue starts loading.
		 */
		public function onDisplayObjectLoadStart( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDisplayObjectLoadStartEVENT, e.getLoader( ) );
		}
		
		/**
		 * Triggered when Display objects queue loading is finished.
		 */
		public function onDisplayObjectLoadInit( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDisplayObjectLoadInitEVENT, e.getLoader( ) );
			buildDisplayList( );
		}

		// QueueLoader callbacks
		/**
		 * Triggered when an element contains in queues starts loading.
		 */
		public function qlOnLoadStart( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadStartEVENT, e.getLoader( ) );
		}
		
		/**
		 * Triggered when an element contains in queues stops loading.
		 */
		public function qlOnLoadInit( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadInitEVENT, e.getLoader( ) );
		}
		
		/**
		 * Triggered when an element ( resources only ) contains in queues stops loading.
		 */
		public function qlOnRSCLoadInit( e : QueueLoaderEvent ) : void
		{
			var loader : FileLoader = FileLoader( e.getLoader( ) );
			var ID : String = loader.getName( );
			var content : Object = loader.getContent( );
			var resource : Resource = ResourceExpert.getInstance( ).locate( ID ) as Resource;
			
			if( resource.hasDeserializer( ) )
			{
				try
				{
					var deserializer : Deserializer = CoreFactory.getInstance().buildInstance( resource.deserializerClass ) as Deserializer;
					content = deserializer.deserialize( content, null, ID );
				}
				catch( err : Error )
				{
					PalmerDebug.ERROR( this + "::" + err.message );
				}
			}
			
			CoreFactory.getInstance( ).register( loader.getName( ), content );
			
			fireEvent( LoaderEvent.onLoadInitEVENT, e.getLoader( ) );
		}
		
		/**
		 * Triggered during element, contained in queues, loading progession.
		 */
		public function qlOnLoadProgress( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadProgressEVENT, e.getLoader( ) );
		}
		
		/**
		 * Triggered when a timout occurs during element, contained in 
		 * queues, loading.
		 */
		public function qlOnLoadTimeOut( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadTimeOutEVENT, e.getLoader( ) );
		}
		
		/**
		 * Triggered when an error occurs during element, contained in 
		 * queues, fail.
		 */
		public function qlOnLoadError( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadErrorEVENT, e.getLoader( ), e.getErrorMessage( ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function addListener( listener : DisplayObjectBuilderListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeListener( listener : DisplayObjectBuilderListener ) : Boolean
		{
			return _oEB.removeListener( listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			return _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
		}
	
		/**
		 * @inheritDoc
		 */
		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			return _oEB.removeEventListener( type, listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function addCommandListener(listener : CommandListener, ...rest) : Boolean
		{
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeCommandListener(listener : CommandListener) : Boolean
		{
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function run() : void
		{
			execute();
		}
		
		/**
		 * @inheritDoc
		 */
		public function isRunning() : Boolean
		{
			return false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function fireCommandEndEvent() : void
		{
			
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
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		protected function generateRootID() : String
		{
			_rootID = HashCodeFactory.getKey( this );
			return _rootID;
		}

		protected function fireEvent( type : String, loader : Loader = null, errorMessage : String = null ) : void
		{
			var e : DisplayObjectBuilderEvent = new DisplayObjectBuilderEvent( type, loader, errorMessage );
			_oEB.broadcastEvent( e );
		}

		protected function _buildEmptyDisplayObject( info : DisplayObjectInfo ) : Boolean
		{
			try
			{
				var oParent : DisplayObjectContainer = CoreFactory.getInstance( ).locate( info.parentID ) as DisplayObjectContainer;

				var oDo : DisplayObject = CoreFactory.getInstance( ).buildInstance( info.type ) as DisplayObject;

				if ( !(oDo is DisplayObject) )
				{
					var msg : String = this + ".buildDisplayList() failed. '" + info.type + "' doesn't extend DisplayObject.";
					PalmerDebug.ERROR( msg );
					throw new IllegalArgumentException( msg );
				}
				
				oDo.name = info.ID;
				
				oParent.addChild( oDo );
				
				CoreFactory.getInstance( ).register( info.ID, oDo );

				_oEB.broadcastEvent( new DisplayObjectEvent( DisplayObjectEvent.onBuildDisplayObjectEVENT, oDo ) );
				return true;
			} catch ( e : Error )
			{
				return false;
			}
			
			return false;
		}
		
		protected function _buildDisplayObject( info : DisplayObjectInfo ) : Boolean
		{
			try
			{
				var gl : GraphicLoader = LoaderLocator.getInstance( ).palmer_GraphicLoader::getLoader( info.ID );
				var parent : DisplayObjectContainer = CoreFactory.getInstance( ).locate( info.parentID ) as DisplayObjectContainer;
				
				gl.setTarget( parent );
				if ( info.isVisible ) gl.show( );
				
				CoreFactory.getInstance( ).register( info.ID, gl.getDisplayObject( ) );
	
				_oEB.broadcastEvent( new DisplayObjectEvent( DisplayObjectEvent.onBuildDisplayObjectEVENT, gl.getDisplayObject( ) ) );
				return true;
			} catch ( e : Error )
			{
				return false;
			}
			
			return false;
		}
		
		
				
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
		
		private function _executeQueueLoader( ql : QueueLoader, startCallback : Function, endCallback : Function, itemCallback : Function = null ) : Boolean
		{
			if ( ql.size( ) > 0 )
			{
				var f : Function = ( itemCallback == null ) ? qlOnLoadInit : itemCallback;
				
				ql.addEventListener( QueueLoaderEvent.onItemLoadStartEVENT, qlOnLoadStart );
				ql.addEventListener( QueueLoaderEvent.onItemLoadInitEVENT, f );
				ql.addEventListener( QueueLoaderEvent.onLoadProgressEVENT, qlOnLoadProgress );
				ql.addEventListener( QueueLoaderEvent.onLoadTimeOutEVENT, qlOnLoadTimeOut );
				ql.addEventListener( QueueLoaderEvent.onLoadErrorEVENT, qlOnLoadError );
				ql.addEventListener( QueueLoaderEvent.onLoadStartEVENT, startCallback );
				ql.addEventListener( QueueLoaderEvent.onLoadInitEVENT, endCallback );
				ql.execute( );
				
				return true;
			} 
			else
			{
				return false;
			}
		}

		private function _buildDisplayList( ID : String ) : void
		{
			var info : DisplayObjectInfo = _mDisplayObject.get( ID );

			if ( info != null )
			{
				if ( ID != getRootID( ) )
				{
					if ( info.isEmptyDisplayObject( ) )
					{
						if ( !_buildEmptyDisplayObject( info ) ) return ;
					} 
					else
					{
						if ( !_buildDisplayObject( info ) ) return;
					}
				}
				
				// recursivity
				if ( info.hasChild( ) )
				{
					var aChild : Array = info.getChild( );
					var l : int = aChild.length;
					for ( var i : int = 0 ; i < l ; i++ ) _buildDisplayList( aChild[i].ID );
				}
			}
		}
	}
}