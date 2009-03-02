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
package com.bourre.ioc.parser.factory.xml 
{
	import com.bourre.ioc.core.ContextNameList;
	import com.bourre.ioc.load.ApplicationLoaderState;
	import com.bourre.ioc.display.DisplayLoaderInfo;
	import com.bourre.load.GraphicLoader;
	import com.bourre.load.Loader;
	import com.bourre.load.LoaderEvent;
	
	import flash.net.URLRequest;	

	/**
	 * @author Francis Bourre
	 */
	public class LoaderParser extends XMLParser
	{
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
			
			fireCommandEndEvent( );
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
			var info : DisplayLoaderInfo = new DisplayLoaderInfo( AttributeUtils.getID( node ), new URLRequest( AttributeUtils.getURL( node ) ), AttributeUtils.getProgressCallback( node ), AttributeUtils.getNameCallback( node ), AttributeUtils.getTimeoutCallback( node ), AttributeUtils.getParsedCallback( node ), AttributeUtils.getMethodsCallCallback( node ), AttributeUtils.getObjectsBuiltCallback( node ), AttributeUtils.getChannelsAssignedCallback( node ), AttributeUtils.getInitCallback( node ) );
			
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
			
			getApplicationLoader( ).setDisplayLoader( loader.getView( ), info );
			
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