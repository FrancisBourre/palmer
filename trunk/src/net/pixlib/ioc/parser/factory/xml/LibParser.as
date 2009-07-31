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
	import net.pixlib.ioc.core.ContextNameList;
	import net.pixlib.ioc.load.ApplicationLoaderState;
	import net.pixlib.ioc.parser.factory.xml.AttributeUtils;
	import net.pixlib.ioc.parser.factory.xml.XMLParser;
	import net.pixlib.load.GraphicLoader;
	import net.pixlib.load.LoaderEvent;
	import net.pixlib.load.QueueLoader;
	import net.pixlib.load.QueueLoaderEvent;
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.utils.HashCodeFactory;

	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * @author Romain Ecarnot
	 */
	public class LibParser extends XMLParser
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _oLoader : QueueLoader;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */	
		public function LibParser(  )
		{
		}

		/**
		 * 
		 */
		override public function parse( ) : void
		{
			var libXML : XMLList = getXMLContext( ).child( ContextNameList.LIB );	
			var l : int = libXML.length( );
			
			_oLoader = new QueueLoader( );
			_oLoader.setAntiCache( false );
			
			for ( var i : int = 0; i < l ; i++ ) 
			{
				var url : String = AttributeUtils.getURL( libXML[ i ] );
				
				_oLoader.add( new GraphicLoader( null, -1, false ), HashCodeFactory.getNextKey( ) + "_lib", new URLRequest( url ), new LoaderContext( false, ApplicationDomain.currentDomain ) );
			}
			
			if( !_oLoader.isEmpty( ) )
			{
				_oLoader.addEventListener( QueueLoaderEvent.onItemLoadInitEVENT, onLibLoaded );
				_oLoader.addEventListener( QueueLoaderEvent.onLoadErrorEVENT, onError );
				_oLoader.addEventListener( QueueLoaderEvent.onLoadInitEVENT, onComplete );
				
				_oLoader.execute( );
			}
			else
			{
				onComplete( );
			}
		}
		
		/**
		 * 
		 */
		protected function onEvent( event : LoaderEvent ) : void
		{
			PalmerDebug.FATAL( event.getLoader().getURL().url + " -> " + event.getType() );
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.LIB_PARSE_STATE;
		}

		/**
		 * 
		 */
		protected function onLibLoaded( event : LoaderEvent ) : void
		{
			PalmerDebug.DEBUG( "[" + getState( ) + "] " + event.getLoader( ).getURL( ).url + " loaded" );
		}
		
		/**
		 * Triggered when error occurs during pre processor dll loading.
		 */
		protected function onError( event : LoaderEvent ) : void
		{
			PalmerDebug.ERROR( this + ":: " + event.getErrorMessage( ) );
		}

		/**
		 * Triggered when all context pre processors are loaded. 
		 */
		protected function onComplete( event : LoaderEvent = null ) : void
		{
			_oLoader.removeEventListener( QueueLoaderEvent.onLoadErrorEVENT, onError );
			_oLoader.removeEventListener( QueueLoaderEvent.onLoadInitEVENT, onComplete );
			_oLoader.release( );
			
			delete getXMLContext( )[ ContextNameList.LIB ];
			
			fireCommandEndEvent( );
		}	}}