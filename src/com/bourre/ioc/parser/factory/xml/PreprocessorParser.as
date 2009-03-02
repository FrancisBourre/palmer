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
	import com.bourre.ioc.assembler.locator.Constructor;
	import com.bourre.ioc.assembler.locator.ConstructorExpert;
	import com.bourre.ioc.assembler.locator.Property;
	import com.bourre.ioc.assembler.locator.PropertyExpert;
	import com.bourre.ioc.control.BuildFactory;
	import com.bourre.ioc.core.ContextNameList;
	import com.bourre.ioc.load.ApplicationLoaderState;
	import com.bourre.ioc.parser.factory.ContextProcessor;
	import com.bourre.load.GraphicLoader;
	import com.bourre.load.Loader;
	import com.bourre.load.LoaderEvent;
	import com.bourre.load.QueueLoader;
	import com.bourre.load.QueueLoaderEvent;
	import com.bourre.log.PalmerDebug;
	import com.bourre.utils.HashCodeFactory;
	
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;	

	/**
	 * The ContextPreprocessorLoader class allow xml context pre processing 
	 * from xml context nodes.
	 * 
	 * <p>Context preprocessing order is :
	 * <ul>
	 * 	<li>ApplicationLoader.addProcessingMethod() job</li>
	 * 	<li>ApplicationLoader.addProcessor() job</li>
	 * 	<li>ContextPreprocessorLoader job</li>
	 * </ul>  
	 * 
	 * @example Basic Processor to insert a node into xml context
	 * <pre class="prettyprint">
	 * 
	 * package com.project
	 * {
	 * 	import com.bourre.ioc.context.processor.ContextProcessor;
	 * 	
	 * 	public class TestProcessor implements ContextProcessor 
	 * 	{
	 * 		public function TestProcessor( ...args )
	 * 		{
	 * 		
	 * 		}
	 * 		
	 * 		public function process(xml : XML) : XML
	 * 		{			
	 * 			//do preprocessing here
	 * 			
	 * 			return xml;
	 * 		}
	 * 		
	 * 		public function customMethod( xml : XML ) : XML
	 * 		{
	 * 			return process( xml );
	 * 		}
	 * 	}
	 * }
	 * </pre>
	 * 
	 * <p>Define preprocessing using xml context node</p>
	 * 
	 * @example Preprocessor class is in current application domain and processor is 
	 * <code>ContextProcessor</code> implementation :
	 * <pre class="prettyprint">
	 * 
	 * &lt;preprocessor type="com.project.TestProcessor" /&gt; 
	 * </pre>
	 * 
	 * @example Preprocessor class is not in current application domain, loads it 
	 * from passed-in url ( like DLL library ) :
	 * <pre class="prettyprint">
	 * 
	 * &lt;preprocessor type="com.project.TestProcessor" url="TestProcessorDLL.swf" /&gt; 
	 * </pre>
	 * 
	 * @example Preprocessor class is not in current application domain and it is not a 
	 * <code>ContextProcessor</code> object, use <code>method</code> attribute : 
	 * <pre class="prettyprint">
	 * 
	 * &lt;preprocessor type="com.project.TestProcessor" url="TestProcessorDLL.swf" method="customMethod" /&gt; 
	 * </pre>
	 * 
	 * <p>Instance arguments are allowed, also <code>factory</code> and <code>singleton-access</code> too.
	 * 
	 * @see com.bourre.ioc.context.processor.ContextProcessor
	 * 
	 * @author Romain Ecarnot
	 */
	public class PreprocessorParser extends XMLParser //FIXME Not work
	{
		//--------------------------------------------------------------------
		// Constants
		//--------------------------------------------------------------------
		
		/**
		 * Method name that processor must implement to 
		 * transform xml context data.
		 * 
		 * <p>Used only when <code>method</code> attribute is not 
		 * defined in preprocessor xml node.
		 * 
		 * @default process
		 * 
		 * @see com.boure.ioc.context.processor.ContextProcessor
		 */
		public static const PROCESS_METHOD_NAME : String = "process";
		
		
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _loader : QueueLoader;		private var _mPreprocessor : PreprocessorMap;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates new <code>ContextPreprocessorLoader</code>.
		 */
		public function PreprocessorParser( )
		{
		}
		
		/**
		 * @inheritDoc
		 */
		override public function parse( ) : void
		{
			var processors : XMLList = getXMLContext( ).child( ContextNameList.PREPROCESSOR ).copy( );
			delete getXMLContext( )[ ContextNameList.PREPROCESSOR ];
			
			_mPreprocessor = new PreprocessorMap( );
			
			_loader = new QueueLoader( );
			_loader.setAntiCache( getApplicationLoader().isAntiCache() );
			
			var l : int = processors.length( );
			for ( var i : int = 0; i < l ; i++ ) _parseProcessor( processors[ i ] );
			
			if( _loader.isEmpty( ) )
			{
				fireOnCompleteEvent( );
			}
			else
			{
				getApplicationLoader().fireOnApplicationState( ApplicationLoaderState.PREPROCESSOR_LOAD_STATE );
				
				_loader.addEventListener( QueueLoaderEvent.onItemLoadInitEVENT, onProcessorInit );
				_loader.addEventListener( QueueLoaderEvent.onLoadErrorEVENT, onProcessorError );
				_loader.addEventListener( QueueLoaderEvent.onLoadInitEVENT, onProcessorComplete );
				_loader.execute( );
			}
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.PREPROCESSOR_PARSE_STATE;
		}
				
		/**
		 * Triggered when a pre processor dll is loaded.
		 */
		protected function onProcessorInit( event : QueueLoaderEvent ) : void
		{
			var id : String = event.getLoader( ).getName( );
			
			_activePreprocessor( id, _mPreprocessor.getNode( id ) );
		}
		
		/**
		 * Triggered when error occurs during pre processor dll loading.
		 */
		protected function onProcessorError( event : QueueLoaderEvent ) : void
		{
			PalmerDebug.ERROR( this + ":: " + event.getErrorMessage() );
		}
		
		/**
		 * Triggered when all context pre processors are loaded. 
		 */
		protected function onProcessorComplete( event : QueueLoaderEvent ) : void
		{
			fireOnCompleteEvent( );
		}
		
		/**
		 * Triggered when all context pre processors are completed. 
		 */
		protected function fireOnCompleteEvent( ) : void
		{
			ConstructorExpert.getInstance( ).release( );
			
			if( _loader )
			{
				_loader.removeEventListener( QueueLoaderEvent.onItemLoadInitEVENT, onProcessorInit );
				_loader.removeEventListener( QueueLoaderEvent.onLoadErrorEVENT, onProcessorError );
				_loader.removeEventListener( QueueLoaderEvent.onLoadInitEVENT, onProcessorComplete );
				
				_loader.release( );
			}
						if( _mPreprocessor ) _mPreprocessor.release( );
			
			fireCommandEndEvent( );
		}

		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------

		private function _parseProcessor( node : XML ) : void
		{
			var id : String = ContextNameList.PREPROCESSOR + HashCodeFactory.getNextKey( );
			var url : String = AttributeUtils.getURL( node );
			
			_buildObject( id, node );
			
			if( url.length > 0 )
			{
				_mPreprocessor.registrer( id, node );
				
				var request : URLRequest = new URLRequest( url );
				var gl : GraphicLoader = new GraphicLoader( null, -1, false );
				
				_loader.add( gl, id, request, new LoaderContext ( false, ApplicationDomain.currentDomain ) );
			}
			else
			{
				_activePreprocessor( id, node );
			}
		}	
		
		private function _activePreprocessor( id : String, node : XML ) : void
		{
			var mN : String = AttributeUtils.getMethod( node );
			if( mN.length < 1 ) mN = PreprocessorParser.PROCESS_METHOD_NAME;
			
			try
			{
				var cons : Constructor = ConstructorExpert.getInstance( ).locate( id ) as Constructor;
				if ( cons.arguments != null )  cons.arguments = PropertyExpert.getInstance( ).deserializeArguments( cons.arguments );
				
				PalmerDebug.WARN( cons.type );
				
				var o : Object = BuildFactory.getInstance( ).build( cons );
				
				if( o is ContextProcessor )
				{
					setContextData( ContextProcessor( o ).process( getXMLContext() ) );
				}
				else if( o.hasOwnProperty( mN ) )
				{
					setContextData( o[ mN ].apply( null, [ getXMLContext( ) ] ) );
				}
				else 
				{
					PalmerDebug.ERROR( this + ":: preprocessor is not compliant " + AttributeUtils.getType( node ) + "#" + mN + "()" );
				}
			}
			catch( e : Error )
			{
				PalmerDebug.ERROR( this + "::" + e.message );
			}
			finally
			{
				ConstructorExpert.getInstance( ).unregister( id );
			}
		}
		
		private function _buildObject( id : String, node : XML ) : void
		{
			var type : String = AttributeUtils.getType( node );
			var args : Array = XMLUtils.getArguments( node, ContextNameList.ARGUMENT, type );
			var factory : String = AttributeUtils.getFactoryMethod( node );
			var singleton : String = AttributeUtils.getSingletonAccess( node );
			
			if ( args != null )
			{
				var l : int = args.length;
				
				for ( var i : uint = 0; i < l ; i++ )
				{
					var o : Object = args[ i ];
					var p : Property = PropertyExpert.getInstance( ).buildProperty( id, o.name, o.value, o.type, o.ref, o.method );
					args[ i ] = p;
				}
			}
			
			ConstructorExpert.getInstance( ).register( id, new Constructor( id, type, args, factory, singleton ) );
		}
	}
}

import com.bourre.collections.HashMap;

internal class PreprocessorMap
{
	private var _map : HashMap;

	public function PreprocessorMap( )
	{
		_map = new HashMap( );
	}

	public function registrer( id : String, node : XML ) : void
	{
		_map.put( id, node );
	}

	public function getNode( id : String ) : XML
	{
		return _map.get( id );
	}

	public function release( ) : void
	{
		_map.clear( );
	}
}
