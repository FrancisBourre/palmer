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
package com.bourre.ioc.assembler 
{
	import com.bourre.collections.HashMap;
	import com.bourre.commands.CommandListener;
	import com.bourre.core.CoreFactory;
	import com.bourre.core.ValueObject;
	import com.bourre.events.EventBroadcaster;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.exceptions.IllegalStateException;
	import com.bourre.ioc.parser.ContextTypeList;
	import com.bourre.load.GraphicLoader;
	import com.bourre.load.GraphicLoaderEvent;
	import com.bourre.load.GraphicLoaderLocator;
	import com.bourre.load.Loader;
	import com.bourre.load.LoaderEvent;
	import com.bourre.load.QueueLoader;
	import com.bourre.load.QueueLoaderEvent;
	import com.bourre.log.PalmerDebug;
	import com.bourre.log.PalmerStringifier;
	import com.bourre.utils.HashCodeFactory;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;	

	/**
	 * @author Francis Bourre
	 */
	public class DefaultDisplayObjectBuilder 
		implements DisplayObjectBuilder
	{
		static public const SPRITE 				: String = ContextTypeList.SPRITE;
		static public const MOVIECLIP 			: String = ContextTypeList.MOVIECLIP;
		static public const TEXTFIELD 			: String = ContextTypeList.TEXTFIELD;

		protected var _target					: DisplayObjectContainer;
		protected var _rootID 					: String;
		protected var _oEB 						: EventBroadcaster;
		protected var _dllQueue 				: QueueLoader;
		protected var _gfxQueue 				: QueueLoader;
		protected var _mDisplayObject			: HashMap;
		protected var _glDisplayLoader 			: GraphicLoader;
		protected var _bIsAntiCache 			: Boolean;

		public function DefaultDisplayObjectBuilder( rootTarget : DisplayObjectContainer = null )
		{
			if  ( rootTarget != null ) setRootTarget( rootTarget );

			_dllQueue = new QueueLoader();
			_gfxQueue = new QueueLoader();
			_mDisplayObject = new HashMap();

			_oEB = new EventBroadcaster( this, DisplayObjectBuilderListener );
			_bIsAntiCache = false;
		}

		public function setAntiCache( b : Boolean ) : void
		{
			_bIsAntiCache = b;
			_dllQueue.setAntiCache( b );
			_gfxQueue.setAntiCache( b );
		}

		public function isAntiCache() : Boolean
		{
			return _bIsAntiCache;
		}

		public function getRootID() : String
		{
			return _rootID ? _rootID : generateRootID();
		}
		
		protected function generateRootID() : String
		{
			_rootID = HashCodeFactory.getKey( this );
			return _rootID;
		}

		public function size() : uint
		{
			return _dllQueue.size() + _gfxQueue.size();
		}

		public function setRootTarget( target : DisplayObjectContainer ) : void
		{
			if ( target is DisplayObjectContainer )
			{
				_target = target;

				try
				{
					var param : Object = LoaderInfo( _target.root.loaderInfo ).parameters;
					for ( var p : * in param ) CoreFactory.getInstance().register( "flashvars::" + p,  param[ p ] );

				} catch ( e : Error )
				{
					//
				}

			} else
			{
				var msg : String = this + ".setRootTarget call failed. Argument is not a DisplayObjectContainer.";
				PalmerDebug.ERROR( msg );
				throw( new IllegalStateException( msg ) );
			}
		}

		public function getRootTarget() : DisplayObjectContainer
		{
			return _target;
		}

		public function buildDisplayLoader( valueObject : ValueObject ) : void
		{
			var displayLoaderInfo : DisplayLoaderInfo = valueObject as DisplayLoaderInfo;

			_glDisplayLoader = new GraphicLoader( null, -1, true );
			_glDisplayLoader.setURL( displayLoaderInfo.url );
			_glDisplayLoader.addEventListener( GraphicLoaderEvent.onLoadInitEVENT, onDisplayLoaderInit, displayLoaderInfo );
			_glDisplayLoader.addEventListener( GraphicLoaderEvent.onLoadErrorEVENT, qlOnLoadError );
			_glDisplayLoader.addEventListener( GraphicLoaderEvent.onLoadTimeOutEVENT, qlOnLoadTimeOut );
		}

		public function buildDLL ( valueObject : ValueObject ) : void
		{
			var info : DisplayObjectInfo = valueObject as DisplayObjectInfo;

			var gl : GraphicLoader = new GraphicLoader( null, -1, false );
			_dllQueue.add( gl, "DLL" + _dllQueue.size(), info.url, new LoaderContext( false, ApplicationDomain.currentDomain ) );
		}
		
		public function buildDisplayObject( valueObject : ValueObject ) : void
		{
			var info : DisplayObjectInfo = valueObject as DisplayObjectInfo;

			if ( !info.isEmptyDisplayObject() )
			{
				var gl : GraphicLoader = new GraphicLoader( null, -1, info.isVisible );
				_gfxQueue.add( gl, info.ID, info.url, new LoaderContext( false, ApplicationDomain.currentDomain ) );
			}
			
			_mDisplayObject.put( info.ID, info );

			if ( info.parentID ) 
			{
				_mDisplayObject.get( info.parentID ).addChild( info );

			} else
			{
				_rootID = info.ID;
			}
		}

		public function execute( e : Event = null ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDisplayObjectBuilderLoadStartEVENT );
			
			if ( _glDisplayLoader != null )
			{
				_glDisplayLoader.execute();

			} else
			{
				loadDLLQueue();
			}
		}

		protected function fireEvent( type : String, loader : Loader = null, errorMessage : String = null ) : void
		{
			var e : DisplayObjectBuilderEvent = new DisplayObjectBuilderEvent( type, loader, errorMessage );
			_oEB.broadcastEvent( e );
		}

		public function onDisplayLoaderInit( e : GraphicLoaderEvent, displayLoaderInfo : DisplayLoaderInfo ) : void
		{
			( e.getLoader() as GraphicLoader ).setTarget( getRootTarget() );
			loadDLLQueue();
		}

		public function loadDLLQueue() : void
		{
			if ( !(_executeQueueLoader( _dllQueue, onDLLLoadStart, onDLLLoadInit )) ) loadDisplayObjectQueue();
		}

		public function onDLLLoadStart( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDLLLoadStartEVENT, e.getLoader() );
		}
		
		public function onDLLLoadInit( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDLLLoadInitEVENT, e.getLoader() );
			loadDisplayObjectQueue();
		}

		public function loadDisplayObjectQueue() : void
		{
			if ( !(_executeQueueLoader( _gfxQueue, onDisplayObjectLoadStart, onDisplayObjectLoadInit )) ) buildDisplayList();
		}
		
		public function onDisplayObjectLoadStart( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDisplayObjectLoadStartEVENT, e.getLoader() );
		}
		
		public function onDisplayObjectLoadInit( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onDisplayObjectLoadInitEVENT, e.getLoader() );
			buildDisplayList();
		}
		
		private function _executeQueueLoader( ql : QueueLoader, startCallback : Function, endCallback : Function ) : Boolean
		{
			if ( ql.size() > 0 )
			{
				ql.addEventListener( QueueLoaderEvent.onItemLoadStartEVENT, qlOnLoadStart );
				ql.addEventListener( QueueLoaderEvent.onItemLoadInitEVENT, qlOnLoadInit );
				ql.addEventListener( QueueLoaderEvent.onLoadProgressEVENT, qlOnLoadProgress );
				ql.addEventListener( QueueLoaderEvent.onLoadTimeOutEVENT, qlOnLoadTimeOut );
				ql.addEventListener( QueueLoaderEvent.onLoadErrorEVENT, qlOnLoadError );
				ql.addEventListener( QueueLoaderEvent.onLoadStartEVENT, startCallback );
				ql.addEventListener( QueueLoaderEvent.onLoadInitEVENT, endCallback );
				ql.execute();

				return true;

			} else
			{
				return false;
			}
		}
		
		public function buildDisplayList() : void
		{
			CoreFactory.getInstance().register( getRootID(), _target );
			_buildDisplayList( getRootID() );
			fireEvent( DisplayObjectBuilderEvent.onDisplayObjectBuilderLoadInitEVENT );
		}

		private function _buildDisplayList( ID : String ) : void
		{
			var info : DisplayObjectInfo = _mDisplayObject.get( ID );

			if ( info != null )
			{
				if ( ID != getRootID() )
				{
					if ( info.isEmptyDisplayObject() )
					{
						if ( !_buildEmptyDisplayObject( info ) ) return ;

					} else
					{
						if ( !_buildDisplayObject( info ) ) return;
					}

				}

				// recursivity
				if ( info.hasChild() )
				{
					var aChild : Array = info.getChild();
					var l : int = aChild.length;
					for ( var i : int = 0 ; i < l ; i++ ) _buildDisplayList( aChild[i].ID );
				}
			}
		}

		protected function _buildEmptyDisplayObject( info : DisplayObjectInfo ) : Boolean
		{
			try
			{
				var oParent : DisplayObjectContainer = CoreFactory.getInstance().locate( info.parentID ) as DisplayObjectContainer;

				var oDo : DisplayObject = CoreFactory.getInstance().buildInstance( info.type ) as DisplayObject;

				if ( !(oDo is DisplayObject) )
				{
					var msg : String = this + ".buildDisplayList() failed. '" + info.type + "' doesn't extend DisplayObject.";
					PalmerDebug.ERROR( msg );
					throw new IllegalArgumentException( msg );
				}

				oParent.addChild( oDo );
				CoreFactory.getInstance().register( info.ID, oDo );

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
				var gl : GraphicLoader = GraphicLoaderLocator.getInstance().getGraphicLoader( info.ID );
				var parent : DisplayObjectContainer = CoreFactory.getInstance().locate( info.parentID ) as DisplayObjectContainer;
				
				gl.setTarget( parent );
				if ( info.isVisible ) gl.show();
				CoreFactory.getInstance().register( info.ID, gl.getView() );
	
				_oEB.broadcastEvent( new DisplayObjectEvent( DisplayObjectEvent.onBuildDisplayObjectEVENT, gl.getView() ) );
				return true;

			} catch ( e : Error )
			{
				return false;
			}
			
			return false;
		}


		// QueueLoader callbacks
		public function qlOnLoadStart( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadStartEVENT, e.getLoader() );
		}

		public function qlOnLoadInit( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadInitEVENT, e.getLoader() );
		}

		public function qlOnLoadProgress( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadProgressEVENT, e.getLoader() );
		}

		public function qlOnLoadTimeOut( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadTimeOutEVENT, e.getLoader() );
		}

		public function qlOnLoadError( e : LoaderEvent ) : void
		{
			fireEvent( DisplayObjectBuilderEvent.onLoadErrorEVENT, e.getLoader(), e.getErrorMessage() );
		}

		/**
		 * Event system
		 */
		public function addListener( listener : DisplayObjectBuilderListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}

		public function removeListener( listener : DisplayObjectBuilderListener ) : Boolean
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

		/**
		 * Returns the string representation of this instance.
		 * @return the string representation of this instance
		 */
		public function toString() : String
		{
			return PalmerStringifier.stringify( this );
		}
		
		//TODO implement below
		public function fireCommandEndEvent() : void
		{
		}
		
		public function addCommandListener(listener : CommandListener, ...rest) : Boolean
		{
			return false;
		}
		
		public function removeCommandListener(listener : CommandListener) : Boolean
		{
			return false;
		}
		
		public function run() : void
		{
		}
		
		public function isRunning() : Boolean
		{
			return false;
		}
	}
}