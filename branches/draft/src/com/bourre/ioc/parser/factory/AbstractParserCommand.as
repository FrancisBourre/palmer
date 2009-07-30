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
 
package com.bourre.ioc.parser.factory 
{
	import com.bourre.commands.AbstractCommand;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.exceptions.NullPointerException;
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.exceptions.UnimplementedMethodException;
	import com.bourre.ioc.assembler.ApplicationAssembler;
	import com.bourre.ioc.load.ApplicationLoader;
	import com.bourre.ioc.load.ApplicationLoaderState;
	import com.bourre.ioc.parser.ContextParserEvent;
	import com.bourre.ioc.parser.factory.ParserCommand;
	
	import flash.events.Event;	

	/**
	 * @author Romain Ecarnot
	 */
	public class AbstractParserCommand extends AbstractCommand implements ParserCommand 
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private var _oLoader : ApplicationLoader;

		
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------

		protected var oContext : *;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------

		/**
		 * @inheritDoc
		 */
		final public function getApplicationLoader() : ApplicationLoader
		{
			return _oLoader;
		}

		/**
		 * @inheritDoc
		 */
		final public function getAssembler() : ApplicationAssembler
		{
			return getApplicationLoader( ).getApplicationAssembler( );
		}

		/**
		 * @inheritDoc
		 */
		final public function getContextData(  ) : *
		{
			return oContext;
		}

		/**
		 * @inheritDoc
		 */
		public function parse( ) : void
		{
			var msg : String = this + ".parse() must be implemented in concrete class.";
			getLogger( ).error( msg );
			throw( new UnimplementedMethodException( msg ) );
		}
		
		/**
		 * @inheritDoc
		 */
		final override public function execute( event : Event = null ) : void
		{
			var msg : String;
			
			if( event == null || !( event is ContextParserEvent ) )
			{
				msg = this + ".execute() failed, event data is unreachable";
				getLogger( ).error( msg );
				throw( new NullPointerException( msg ) );
			}
			else
			{
				var evt : ContextParserEvent = ContextParserEvent( event );
				
				try
				{
					setApplicationLoader( evt.getApplicationLoader( ) );
					setContextData( evt.getContextData( ) );
					
					getApplicationLoader( ).fireOnApplicationState( getState( ) );
					
					parse( );				}
				catch( err : Error )
				{
					msg = this + ".execute() failed " + err.message;
					getLogger( ).error( msg );
					throw( new IllegalArgumentException( msg ) );
				}
			}
		}
		
		final override public function fireCommandEndEvent() : void
		{
			_oEB.broadcastEvent( new ContextParserEvent( AbstractCommand.onCommandEndEVENT, null, getApplicationLoader(), getContextData() ) );
		}
		

		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------

		protected function getState(  ) : String
		{
			return ApplicationLoaderState.PARSE_STATE;	
		}

		/**
		 * 
		 */
		final protected function setApplicationLoader( loader : ApplicationLoader = null ) : void
		{
			if( loader != null )
			{
				_oLoader = loader;
			}
			else
			{
				var msg : String = this + ".setApplicationLoader() failed : " + loader;
				getLogger( ).error( msg );
				throw( new IllegalArgumentException( msg ) );
			}
		}

		/**
		 * 
		 */
		protected function setContextData( data : * = null ) : void
		{
			if( data != null )
			{
				oContext = data;
			}
			else
			{
				var msg : String = this + ".setContext() failed : " + data;
				getLogger( ).error( msg );
				throw( new IllegalArgumentException( msg ) );
			}
		}
		
		final protected function getConstructorAccess( ) : ConstructorAccess
		{
			return ConstructorAccess.instance;
		}
		

		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------

		function AbstractParserCommand( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException( );
		}		
	}
}

internal class ConstructorAccess 
{
	public static const instance : ConstructorAccess = new ConstructorAccess();
}