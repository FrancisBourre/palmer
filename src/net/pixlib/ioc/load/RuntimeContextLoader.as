package net.pixlib.ioc.load 
{
	import net.pixlib.ioc.assembler.locator.PluginExpert;
	import net.pixlib.load.LoaderLocator;

	import flash.display.DisplayObjectContainer;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * RuntimeContextLoader class allow to load / unload IoC 
	 * context at runtime.
	 * 
	 * @example Loads IoC context
	 * <pre class="prettyprint">
	 * 
	 * var loader : RuntimeContextLoader = new RuntimeContextLoader( "myContext", this, new URLRequest( "runtime.xml" ) );
	 * loader.addEventListener( ApplicationLoaderEvent.onApplicationInitEVENT, testRuntime );
	 * loader.execute();
	 * </pre>
	 * 
	 * @example Unloads IoC context
	 * <pre class="prettyprint">
	 * 
	 * RuntimeContextLoader( LoaderLocator.getInstance().getLoader( "myContext" ) ).unload();
	 * </pre>
	 * 
	 * //TODO Check DisplayLoader rules
	 * 
	 * @author Romain Ecarnot
	 */
	public class RuntimeContextLoader extends ApplicationLoader
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function RuntimeContextLoader(	runtimeID : String,
												rootTarget : DisplayObjectContainer, 
												url : URLRequest = null )
		{
			super( rootTarget, false, url );
			
			setName( runtimeID );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function load( url : URLRequest = null, context : LoaderContext = null ) : void
		{	
			addProcessor( new RuntimeGCProcessor( RuntimeGCLocator.getInstance( getName( ), getDisplayObjectBuilder() ) ) );
			
			super.load( url, context );
		}

		/**
		 * Unloads context components.
		 */
		public function unload() : void
		{
			RuntimeGCLocator.getInstance( getName( ) ).release( );
			
			if ( _bMustUnregister ) 
			{
				LoaderLocator.getInstance( ).unregister( getName( ) );
				_bMustUnregister = false;
			}
			
			_loadStrategy.release( );
			_oEB.removeAllListeners( );
		}

		/**
		 * @private
		 */
		override public function release() : void
		{
			
		}

		/**
		 * @inheritDoc
		 */
		override public function fireOnApplicationInit() : void 
		{
			fireEvent( new ApplicationLoaderEvent( ApplicationLoaderEvent.onApplicationInitEVENT, this ) );
			
			fireOnApplicationState( ApplicationLoaderState.COMPLETE_STATE );
			
			if( _oDLoader != null ) removeListener( _oDLoader );
			
			onInitialize( );
			
			PluginExpert.getInstance( ).notifyAllPlugins( );
		}
	}
}

import net.pixlib.collections.HashMap;
import net.pixlib.collections.Iterator;
import net.pixlib.collections.Set;
import net.pixlib.core.CoreFactory;
import net.pixlib.ioc.assembler.builder.DisplayObjectBuilder;
import net.pixlib.ioc.core.ContextAttributeList;
import net.pixlib.ioc.parser.factory.ContextProcessor;
import net.pixlib.plugin.Plugin;

import flash.display.DisplayObject;

internal class RuntimeGCProcessor implements ContextProcessor
{
	private var _oLocator : RuntimeGCLocator;
	
	public function RuntimeGCProcessor( cgLocator : RuntimeGCLocator )
	{
		_oLocator = cgLocator;
	}
	
	public function process(context : *) : *
	{
		var xml : XML = context is XML ? context as XML : new XML( context );
		var list : XMLList = xml..*.( hasOwnProperty( getAttributeName( ContextAttributeList.ID ) ) );
		var l : uint = list.length( );
		
		for( var i : uint = 0; i < l ; i++ )
		{
			_oLocator.register( list[i].@id );	
		}
		
		return xml;
	}
	
	private function getAttributeName( name : String ) : String
	{
		return "@" + name;		
	}
}

internal class RuntimeGCLocator
{
	private static var _M : HashMap = new HashMap( );
	
	private var _aID : Set;
	private var _oDisplayBuilder : DisplayObjectBuilder;
	
	public static function getInstance( context : String, displayObjectBuilder : DisplayObjectBuilder = null ) : RuntimeGCLocator
	{
		if( !_M.containsKey( context ) )
		{
			_M.put( context, new RuntimeGCLocator( displayObjectBuilder ) );
		}
		
		return _M.get( context );
	}

	public function register( id : String ) : void
	{
		if( !_aID.contains( id ) ) _aID.add( id );			
	}
	
	public function release() : void
	{
		var it : Iterator = _aID.iterator( );
		var cf : CoreFactory = CoreFactory.getInstance( );
		
		while( it.hasNext( ) )
		{
			var key : String = it.next( );
			
			if( cf.isRegistered( key ) )
			{
				var bean : * = cf.locate( key );
				
				switch( true )
				{
					case bean is Plugin : 
						Plugin( bean ).release( );	
						break;
						
					case bean is DisplayObject :
						var mc : DisplayObject = bean as DisplayObject;
						
						if( _oDisplayBuilder && mc != _oDisplayBuilder.getRootTarget() )
						{
							if( mc.parent ) mc.parent.removeChild( mc );
							else mc = null;
						}
						break;
					
					default :
						var val : * = CoreFactory.getInstance().locate( key );
						val = null;
						
						CoreFactory.getInstance().unregister( key );
				}
			}
		}
	}
	
	function RuntimeGCLocator( displayObjectBuilder : DisplayObjectBuilder = null )
	{
		_aID = new Set( String );
		_oDisplayBuilder = displayObjectBuilder;
	}
}