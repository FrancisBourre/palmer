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
package com.bourre.ioc.load 
{
	import com.bourre.commands.Command;
	import com.bourre.commands.CommandListener;
	import com.bourre.commands.Delegate;
	import com.bourre.exceptions.NullPointerException;
	import com.bourre.ioc.assembler.ApplicationAssembler;
	import com.bourre.ioc.assembler.DefaultApplicationAssembler;
	import com.bourre.ioc.assembler.builder.DefaultDisplayObjectBuilder;
	import com.bourre.ioc.assembler.builder.DisplayObjectBuilder;
	import com.bourre.ioc.assembler.builder.DisplayObjectBuilderEvent;
	import com.bourre.ioc.assembler.builder.DisplayObjectBuilderListener;
	import com.bourre.ioc.assembler.builder.DisplayObjectEvent;
	import com.bourre.ioc.assembler.locator.ChannelListenerExpert;
	import com.bourre.ioc.assembler.locator.ConstructorExpert;
	import com.bourre.ioc.assembler.locator.MethodExpert;
	import com.bourre.ioc.assembler.locator.PluginExpert;
	import com.bourre.ioc.assembler.locator.PropertyExpert;
	import com.bourre.ioc.display.DisplayLoaderInfo;
	import com.bourre.ioc.display.DisplayLoaderProxy;
	import com.bourre.ioc.parser.ContextParser;
	import com.bourre.ioc.parser.ParserCollection;
	import com.bourre.ioc.parser.XMLCollection;
	import com.bourre.ioc.parser.factory.ContextProcessor;
	import com.bourre.load.AbstractLoader;
	import com.bourre.load.FileLoader;
	import com.bourre.load.Loader;
	import com.bourre.load.LoaderEvent;
	import com.bourre.load.LoaderListener;
	import com.bourre.log.PalmerDebug;

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * IoC Application context loader.
	 * 
	 * @author Francis Bourre
	 * @author Romain Ecarnot
	 */
	public class ApplicationLoader extends AbstractLoader
		implements LoaderListener, DisplayObjectBuilderListener, CommandListener
	{
		//--------------------------------------------------------------------
		// Constants
		//--------------------------------------------------------------------
		
		/**
		 * Default IoC context file URL.
		 * 
		 * @default "applicationContext.xml"
		 */
		static public const DEFAULT_URL : URLRequest = new URLRequest( "applicationContext.xml" );
		
		
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
				
		/** @private */
		protected var _oRootTarget : DisplayObjectContainer;
		
		/** @private */
		protected var _oDisplayObjectBuilder : DisplayObjectBuilder;
		
		/** @private */
		protected var _oApplicationAssembler : ApplicationAssembler;
		
		/** @private */
		protected var _oParserCollection : ParserCollection;
		
		/** @private */
		protected var _oDLoader : DisplayLoaderProxy;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates loader instance.
		 * 
		 * @param	rootTarget	Main sprite target for display tree creation.
		 * @param	autoExecute	(optional) <code>true</code> to start loading 
		 * 						just after loader instanciation.
		 * @param	url			URL request for 'applicationContext' file 
		 * 						to load.
		 */
		public function ApplicationLoader( 	rootTarget : DisplayObjectContainer, 
											autoExecute : Boolean = false, 
											url : URLRequest = null )
		{
			super( );
			
			setListenerType( ApplicationLoaderListener );
			
			_oRootTarget = rootTarget;
			
			setURL( url ? url : ApplicationLoader.DEFAULT_URL );
			
			setApplicationAssembler( new DefaultApplicationAssembler( ) );
			setDisplayObjectBuilder( new DefaultDisplayObjectBuilder( ) );
			
			initParserCollection( );
			
			if ( autoExecute ) execute( );
		}
		
		/**
		 * Returns <code>ApplicationAssembler</code> used in by this loader.
		 */
		public function getApplicationAssembler() : ApplicationAssembler
		{
			return _oApplicationAssembler;
		}
		
		/**
		 * Sets the <code>ApplicationAssembler</code> to use by this loader.
		 */
		public function setApplicationAssembler( assembler : ApplicationAssembler ) : void
		{
			_oApplicationAssembler = assembler;
		}
		
		/**
		 * Returns parser collection used by assembler.
		 */
		public function getParserCollection() : ParserCollection
		{
			return _oParserCollection;
		}
		
		/**
		 * Sets the parsers collection to use in order to build context.
		 */
		public function setParserCollection( pc : ParserCollection ) : void
		{
			_oParserCollection = pc;
		}
		
		/**
		 * Sets new pair name / value for variable replacement when context 
		 * file will be laoded.
		 * 
		 * @param	name	Name of the variable to replace.
		 * @param	value	New value for this variable.
		 * 
		 * @example Variable definition somewhere in the xml context :
		 * <pre class="prettyprint">
		 * 
		 * ${POSITION_X}
		 * </pre>
		 * 
		 * @example Setting this variable using setVariable() method :
		 * <pre class="prettyprint">
		 * 
		 * rtLoader.addProcessingVariable( "POSITION_X", 200 );
		 * </pre>
		 */
		public function addProcessingVariable( name : String, value : Object ) : void
		{
			getParserCollection().getASPreProcessor().addVariable(  name, value );
		}
		
		/**
		 * Adds new preprocessing method.
		 * 
		 * <p>Preprocessing act after xml loading and before context parsing.<br />
		 * Used to transform context data on fly.</p>
		 * 
		 * @param	processingMethod	Method to call.<br/>
		 * 								Method must accept an XML object as first argument 
		 * 								and return an XML object when completed.
		 * 	@param	...					Additionals parameters to pass to method when 
		 * 								executing.
		 * 								
		 * @example
		 * <pre class="prettyprint">
		 * 
		 * var oLoader : ApplicationLoader = new ApplicationLoader( this, false );
		 * oLoader.addProcessingMethod( XMLProcessingHelper.changeObjectAttribute, "cross", "visible", "false" );
		 * oLoader.addProcessingMethod( XMLProcessingHelper.changePropertyValue, "cross", "x", 600 );
		 * oLoader.addProcessingMethod( XMLProcessingHelper.addResource, "newStyle", "myStyle.css" );
		 * </pre>
		 * 
		 * @see com.bourre.ioc.context.processor.ProcessingHelper 
		 */
		public function addProcessingMethod( processingMethod : Function, ...args ) : void
		{
			var d : Delegate = new Delegate( processingMethod );
			d.setArgumentsArray( args );
			
			getParserCollection().getASPreProcessor().addMethod( d );
		}
		
		/**
		 * Adds new pre processing processor.
		 * 
		 * <p>Preprocessing act after xml loading and before context parsing.<br />
		 * Used to transform context data on fly.</p>
		 * 
		 * @example
		 * <pre class="prettyprint">
		 * 
		 * var oLoader : ApplicationLoader = new ApplicationLoader( this, false );
		 * oLoader.addProcessor( new LocalisationProcessor() );
		 * </pre>
		 */
		public function addProcessor( processor : ContextProcessor ) : void
		{
			getParserCollection().getASPreProcessor().addProcessor( processor );
		}
		
		/**
		 * Returns the <code>DisplayObjectBuilder</code> used by this loader 
		 * to load and build all context elements.
		 */
		public function getDisplayObjectBuilder() : DisplayObjectBuilder
		{
			return _oDisplayObjectBuilder;		}
		
		/**
		 * Sets the <code>DisplayObjectBuilder</code> to use by this loader 
		 * to load and build all context elements.
		 */
		public function setDisplayObjectBuilder( displayObjectBuilder : DisplayObjectBuilder ) : void
		{
			_oDisplayObjectBuilder = displayObjectBuilder;
		}
		
		/**
		 * Adds the passed-in <code>listener</code> as listener for all 
		 * events dispatched by loader.
		 * 
		 * @param	listener	<code>ApplicationLoaderListener</code> instance.
		 */
		public function addApplicationLoaderListener( listener : ApplicationLoaderListener ) : Boolean
		{
			return addListener( listener );
		}
		
		/**
		 * Removes the passed-in <code>listener</code> object from loader. 
		 * 
		 * @param	listener	<code>ApplicationLoaderListener</code> instance.
		 */
		public function removeApplicationLoaderListener( listener : ApplicationLoaderListener ) : Boolean
		{
			return removeListener( listener );
		}
		
		/**
		 * Attaches IoC DisplayLoader now.
		 */
		public function setDisplayLoader( mc : DisplayObjectContainer, info : DisplayLoaderInfo ) : void
		{
			if( _oDLoader ) removeListener( _oDLoader );
			
			_oDLoader = new DisplayLoaderProxy( mc, info );
			addListener( _oDLoader );
		}
		
		/**
		 * Returns IoC DisplayLoader ( if exist ).
		 */
		public function getDisplayLoader( ) : DisplayLoaderProxy
		{
			return _oDLoader;
		}
		
		/**
		 * Starts context loading.
		 * 
		 * @param	url		(optional) URL request for 'applicationContext' file 
		 * 					to load.
		 * 	@paam	context	(optional) <code>LoaderContext</code> definition.
		 */
		override public function load( url : URLRequest = null, context : LoaderContext = null ) : void
		{
			if ( url != null ) setURL( url );

			if ( getURL( ).url.length > 0 )
			{
				var loader : Loader = getContextLoader( );
				loader.setURL( getURL( ) );
				loader.addEventListener( LoaderEvent.onLoadInitEVENT, onContextLoaderLoadInit );
				loader.addEventListener( LoaderEvent.onLoadProgressEVENT, this );
				loader.addEventListener( LoaderEvent.onLoadTimeOutEVENT, this );
				loader.addEventListener( LoaderEvent.onLoadErrorEVENT, this );
				
				loader.load( getURL( ), context );
			} 
			else
			{
				var msg : String = this + ".load() can't retrieve file url.";
				PalmerDebug.ERROR( msg );
				throw new NullPointerException( msg );
			}
		}
		
		/**
		 * Triggered when Ioc Parsing is complete.
		 */
		public function onCommandEnd( event : Event ) : void
		{
			try
			{
				Command( event.target ).removeCommandListener( this );
			}
			catch( e : Error ) 
			{
				//
			}
			finally
			{
				getDisplayObjectBuilder( ).addListener( this );
				getDisplayObjectBuilder( ).execute( );
			}
		}
		
		/**
		 * Broadcasts <code>ApplicationLoaderEvent.onApplicationStartEVENT</code> 
		 * event type when xml is parsed.
		 */
		public function fireOnApplicationStart() : void
		{
			fireEvent( new ApplicationLoaderEvent( ApplicationLoaderEvent.onApplicationLoadStartEVENT, this ) );
		}
		
		/**
		 * Broadcasts <code>ApplicationLoaderEvent.onApplicationStateEVENT</code> when IOC engine 
		 * processing change his state ( DLL, Resources, GFX, etc. )
		 */
		public function fireOnApplicationState( state : String ) : void
		{
			var e : ApplicationLoaderEvent = new ApplicationLoaderEvent( ApplicationLoaderEvent.onApplicationStateEVENT, this );
			e.setApplicationState( state );	
			
			fireEvent( e );
		}
		
		/**
		 * Broadcasts <code>ApplicationLoaderEvent.onApplicationParsedEVENT</code> 
		 * event type when xml is parsed.
		 */
		public function fireOnApplicationParsed() : void
		{
			fireEvent( new ApplicationLoaderEvent( ApplicationLoaderEvent.onApplicationParsedEVENT, this ) );
		}
		
		/**
		 * Broadcasts <code>ApplicationLoaderEvent.onApplicationObjectsBuiltEVENT</code> 
		 * event type when all elements in xml are built.
		 */
		public function fireOnObjectsBuilt() : void
		{
			fireEvent( new ApplicationLoaderEvent( ApplicationLoaderEvent.onApplicationObjectsBuiltEVENT, this ) );
		}
		
		/**
		 * Broadcasts <code>ApplicationLoaderEvent.onApplicationChannelsAssignedEVENT</code> 
		 * event type when all plugin channels are initialized.
		 */
		public function fireOnChannelsAssigned() : void
		{
			fireEvent( new ApplicationLoaderEvent( ApplicationLoaderEvent.onApplicationChannelsAssignedEVENT, this ) );
		}
		
		/**
		 * Broadcasts <code>ApplicationLoaderEvent.onApplicationMethodsCalledEVENT</code> 
		 * event type when all <code>method-call</code> are executed.
		 */
		public function fireOnMethodsCalled() : void
		{
			fireEvent( new ApplicationLoaderEvent( ApplicationLoaderEvent.onApplicationMethodsCalledEVENT, this ) );
		}
		
		/**
		 * Broadcasts <code>ApplicationLoaderEvent.onApplicationInitEVENT</code> 
		 * event type when application is ready.
		 */
		public function fireOnApplicationInit() : void 
		{
			fireEvent( new ApplicationLoaderEvent( ApplicationLoaderEvent.onApplicationInitEVENT, this ) );
			
			fireOnApplicationState( ApplicationLoaderState.COMPLETE_STATE );
			
			if( _oDLoader != null ) removeListener( _oDLoader );
			
			release( );
			
			PluginExpert.getInstance( ).notifyAllPlugins( );
		}
		
		/**
		 * @inheritdoc
		 */
		public function onLoadStart( e : LoaderEvent ) : void
		{
			fireEvent( e );
		}
		
		/**
		 * @inheritdoc
		 */
		public function onLoadInit( e : LoaderEvent ) : void
		{
			fireEvent( e );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadProgress( e : LoaderEvent ) : void
		{
			fireEvent( e );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadTimeOut( e : LoaderEvent ) : void
		{
			fireOnLoadTimeOut( );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadError( e : LoaderEvent ) : void
		{
			fireOnLoadErrorEvent( e.getErrorMessage( ) );
		}
		
		/**
		 * DisplayObjectExpert callbacks
		 */
		public function onBuildDisplayObject( e : DisplayObjectEvent ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onDisplayObjectBuilderLoadStart( e : DisplayObjectBuilderEvent ) : void
		{
			fireOnApplicationStart( );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onDLLLoadStart( e : DisplayObjectBuilderEvent ) : void
		{
			fireOnApplicationState( ApplicationLoaderState.DLL_LOAD_STATE );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onDLLLoadInit( e : DisplayObjectBuilderEvent ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onRSCLoadStart( e : DisplayObjectBuilderEvent ) : void
		{
			fireOnApplicationState( ApplicationLoaderState.RSC_LOAD_STATE );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onRSCLoadInit( e : DisplayObjectBuilderEvent ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onDisplayObjectLoadStart( e : DisplayObjectBuilderEvent ) : void
		{
			fireOnApplicationState( ApplicationLoaderState.GFX_LOAD_STATE );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onDisplayObjectLoadInit( e : DisplayObjectBuilderEvent ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onDisplayObjectBuilderLoadInit( e : DisplayObjectBuilderEvent ) : void
		{
			fireOnApplicationParsed( );
			
			fireOnApplicationState( ApplicationLoaderState.BUILD_STATE );
			
			ConstructorExpert.getInstance( ).buildAllObjects( );
			fireOnObjectsBuilt( );
			
			ChannelListenerExpert.getInstance( ).assignAllChannelListeners( );
			fireOnChannelsAssigned( );

			MethodExpert.getInstance( ).callAllMethods( );
			fireOnMethodsCalled( );

			fireOnApplicationInit( );
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * Sets <code>XMLCollection</code> as default context parser 
		 * collection.
		 * 
		 * <p>Overrides to use own parser collection or use 
		 * <code>setParserCollection()</code> method before context 
		 * loading.</p>
		 * 
		 * @see #setParserCollection()
		 */	
		protected function initParserCollection() : void
		{
			try
			{
				setParserCollection( new XMLCollection( ) );
			}
			catch( e : Error )
			{
				PalmerDebug.ERROR( e.message );
			}
		}
		
		/**
		 * Returns context Loader.
		 */
		protected function getContextLoader( ) : Loader
		{
			return new FileLoader( FileLoader.TEXT );
		}
		
		/**
		 * Triggered when the context file is loaded.
		 */
		protected function onContextLoaderLoadInit( e : LoaderEvent ) : void
		{
			e.getLoader( ).removeListener( this );
			
			clearExperts();
			initParsing();
			runParsing( getContextContent( e.getLoader() ) );		}
		
		/**
		 * Returns loaded content.
		 * 
		 * <p>Overrides to customize loaded context content before 
		 * running IoC parsers.</p>
		 * 
		 * @param	loader	Context loader instance.
		 */
		protected function getContextContent( loader : Loader ) : *
		{
			return loader.getContent();
		}
		
		/**
		 * Clears all agregators.
		 */
		protected function clearExperts( ) : void
		{
			ChannelListenerExpert.getInstance( ).release( );
			ConstructorExpert.getInstance( ).release( );
			MethodExpert.getInstance( ).release( );
			PropertyExpert.getInstance( ).release( );	
		}
		
		/**
		 * Inits parsing engine.
		 */
		protected function initParsing() : void
		{
			if ( getDisplayObjectBuilder( ) == null ) setDisplayObjectBuilder( new DefaultDisplayObjectBuilder( ) );
			if ( isAntiCache( ) ) getDisplayObjectBuilder( ).setAntiCache( true );
			
			getDisplayObjectBuilder( ).setRootTarget( _oRootTarget );
			getApplicationAssembler( ).setDisplayObjectBuilder( getDisplayObjectBuilder( ) );
		}
		
		/**
		 * Starts content parsing.
		 * 
		 * @param	rawData	The context content
		 */
		protected function runParsing( rawData : * ) : void
		{
			var cp : ContextParser = new ContextParser( getParserCollection( ) );			cp.setApplicationLoader( this );
			cp.setContextData( rawData );
			cp.addCommandListener( this );
			cp.execute( );	
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function getLoaderEvent( type : String, errorMessage : String = "" ) : LoaderEvent
		{
			return new ApplicationLoaderEvent( type, this, errorMessage );
		}
	}
}