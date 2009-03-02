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
	import com.bourre.ioc.assembler.locator.Import;
	import com.bourre.ioc.assembler.locator.ImportExpert;
	import com.bourre.ioc.core.ContextNameList;
	import com.bourre.ioc.load.ApplicationLoaderState;
	import com.bourre.load.LoaderEvent;
	import com.bourre.load.QueueLoader;
	import com.bourre.load.QueueLoaderEvent;
	import com.bourre.load.XMLLoader;
	import com.bourre.log.PalmerDebug;
	
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;	

	/**
	 * The XMLImportParser class allow to inject IoC context into another 
	 * IoC context. ( import feature )
	 * 
	 * @example How to import context
	 * <pre class="prettyprint">
	 * 
	 * &lt;beans&gt;
	 * 	&lt;import url="config/context.xml" root-ref="container" /&gt;
	 * 
	 * 	&lt;root id="root"&gt;
	 * 		&lt;child id="container" /&gt;
	 * 	&lt;/root&gt;
	 * &lt;/beans&gt; 
	 * </pre>
	 * 
	 * @author Romain Ecarnot
	 */
	public class ImportParser extends XMLParser
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _loader : QueueLoader;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates new <code>XMLImportParser</code> instance.
		 */
		public function ImportParser(   )
		{
			_loader = new QueueLoader( );
		}
		
		/**
		 * Starts include job.
		 */
		override public function parse() : void
		{
			parseImport( getXMLContext( ) );
			
			executeQueue( );
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.IMPORT_PARSE_STATE;
		}

		/**
		 * @private
		 */
		protected function executeQueue( ) : void
		{
			if( !_loader.isEmpty( ) )
			{
				getApplicationLoader().fireOnApplicationState( ApplicationLoaderState.IMPORT_LOAD_STATE );
				
				_loader.addEventListener( QueueLoaderEvent.onItemLoadInitEVENT, onImportLoadInit );
				_loader.addEventListener( LoaderEvent.onLoadProgressEVENT,  onImportLoadProgress );				_loader.addEventListener( LoaderEvent.onLoadTimeOutEVENT, onImportLoadError );
				_loader.addEventListener( LoaderEvent.onLoadErrorEVENT, onImportLoadError );
				_loader.addEventListener( LoaderEvent.onLoadInitEVENT, onLoadQueueInit );
				_loader.execute( );
			}
			else fireOnCompleteEvent( );
		}
		
		/**
		 * @private
		 */
		protected function release() : void
		{
			_loader.removeEventListener( QueueLoaderEvent.onItemLoadInitEVENT, onImportLoadInit );			_loader.removeEventListener( LoaderEvent.onLoadProgressEVENT,  onImportLoadProgress );
			_loader.removeEventListener( LoaderEvent.onLoadTimeOutEVENT, onImportLoadError );
			_loader.removeEventListener( LoaderEvent.onLoadErrorEVENT, onImportLoadError );
			_loader.removeEventListener( LoaderEvent.onLoadInitEVENT, onLoadQueueInit );
			_loader.release( );
			
			ImportExpert.release();
		}
		
		/**
		 * @private
		 */
		protected function parseImport( xml : XML ) : void
		{
			var incXML : XMLList = xml.child( ContextNameList.IMPORT );
			var l : int = incXML.length( );
			
			for ( var i : int = 0; i < l ; i++ ) 
			{
				var node : XML = incXML[ i ];
				var info : Import = new Import( new URLRequest( AttributeUtils.getURL( node ) ), AttributeUtils.getRootRef( node ) );
				
				var id : String = info.url.url;
				
				ImportExpert.getInstance( ).register( id, info );
				
				var xl : XMLLoader = new XMLLoader( );
				
				_loader.add( xl, id, info.url, new LoaderContext( false, ApplicationDomain.currentDomain ) );
			}
			
			delete xml[ ContextNameList.IMPORT ];
		}
		
		/**
		 * @private
		 */
		protected function onImportLoadInit( event : LoaderEvent ) : void
		{
			var xml : XML = XMLLoader( event.getLoader( ) ).getXML( );
			var info : Import = ImportExpert.getInstance( ).locate( event.getName( ) ) as Import;
			
			parseImport( xml );
			
			try
			{
				var container : XMLList = getXMLContext( ).descendants( ).(  hasOwnProperty( "@id" ) && @id == info.rootRef );
				
				if( xml.hasOwnProperty( ContextNameList.ROOT ) )
				{
					container.appendChild( xml.child( ContextNameList.ROOT ).children( ) );
					
					delete xml[ ContextNameList.ROOT ];
				}
			}
			catch( e : Error )
			{
				PalmerDebug.ERROR( this + "::no rootref for " + info.url.url + " -> " + info.rootRef );
			}
			finally
			{
				for each (var node : XML in xml.children( ) ) 
				{
					getXMLContext( ).appendChild( node );
				}
				
				ImportExpert.getInstance( ).unregister( info.url.url );
			}
		}
		
		/**
		 * @private
		 */
		protected function onImportLoadProgress( event : LoaderEvent ) : void
		{
			
		}
		
		/**
		 * @private
		 */
		protected function onImportLoadError( event : LoaderEvent ) : void
		{
			fireOnCompleteEvent( );
		}
		
		/**
		 * @private
		 */
		protected function onLoadQueueInit( event : QueueLoaderEvent ) : void
		{
			release( );
			
			fireOnCompleteEvent( );
		}

		/**
		 * Triggered when all context pre processors are completed. 
		 */
		protected function fireOnCompleteEvent( ) : void
		{
			fireCommandEndEvent( );
		}
	}
}
