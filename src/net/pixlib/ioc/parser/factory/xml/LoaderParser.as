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
package net.pixlib.ioc.parser.factory.xml 
{
	import net.pixlib.ioc.core.ContextAttributeList;
	import net.pixlib.ioc.core.ContextNameList;
	import net.pixlib.ioc.display.DisplayLoaderInfo;
	import net.pixlib.ioc.load.ApplicationLoaderState;
	import net.pixlib.load.GraphicLoader;
	import net.pixlib.load.Loader;
	import net.pixlib.load.LoaderEvent;

	import flash.net.URLRequest;

	/**
	 * @author Francis Bourre
	 */
	public class LoaderParser extends XMLParser
	{
		protected var _hasLoader : Boolean = false;
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		public function LoaderParser(  )
		{
		}
		
		override public function parse( ) : void
		{
			for each ( var node : XML in getXMLContext( )[ ContextNameList.APPLICATION_LOADER ] ) parseNode( node );
			delete getXMLContext( )[ ContextNameList.APPLICATION_LOADER ];
			
			if ( !_hasLoader ) fireCommandEndEvent( );
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------

		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.LOADER_PARSE_STATE;
		}

		protected function parseNode( node : XML ) : void
		{
			_hasLoader = true;
			
			var info : DisplayLoaderInfo = new DisplayLoaderInfo( 
				AttributeUtils.getID( node ), 
				new URLRequest( AttributeUtils.getURL( node ) ), 
				AttributeUtils.getAttribute( node, ContextAttributeList.START_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.NAME_CALLBACK), 				AttributeUtils.getAttribute( node, ContextAttributeList.LOAD_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.PROGRESS_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.TIMEOUT_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.ERROR_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.INIT_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.PARSED_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.OBJECTS_BUILT_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.CHANNELS_ASSIGNED_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.METHODS_CALL_CALLBACK ), 				AttributeUtils.getAttribute( node, ContextAttributeList.COMPLETE_CALLBACK )
			);
			
			var loader : GraphicLoader = new GraphicLoader( null, -1, true );
			loader.addEventListener( LoaderEvent.onLoadInitEVENT, onDisplayLoaderInit, info );
			loader.addEventListener( LoaderEvent.onLoadErrorEVENT, onDisplayLoaderError );
			loader.addEventListener( LoaderEvent.onLoadTimeOutEVENT, onDisplayLoaderError );
			loader.load( info.url );
		}
		
		/**
		 * Triggered when display loader is loaded.
		 */
		protected function onDisplayLoaderInit( event : LoaderEvent, info : DisplayLoaderInfo ) : void
		{
			var loader : GraphicLoader = event.getLoader( ) as GraphicLoader;
			loader.setTarget( getApplicationLoader( ).getDisplayObjectBuilder( ).getRootTarget( ) );
			
			getApplicationLoader( ).setDisplayLoader( loader.getDisplayObject( ), info );
			
			release( event );
			
			fireCommandEndEvent( );
		}
		
		protected function onDisplayLoaderError( event : LoaderEvent ) : void
		{
			release( event );
			
			fireCommandEndEvent( );
		}
		
		protected function release( e : LoaderEvent ) : void
		{
			var loader : Loader = e.getLoader( );
			loader.addEventListener( LoaderEvent.onLoadInitEVENT, onDisplayLoaderInit );
			loader.addEventListener( LoaderEvent.onLoadErrorEVENT, onDisplayLoaderError );
			loader.addEventListener( LoaderEvent.onLoadTimeOutEVENT, onDisplayLoaderError );
		}
	}
}