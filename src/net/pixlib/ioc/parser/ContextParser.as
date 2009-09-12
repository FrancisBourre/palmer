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
package net.pixlib.ioc.parser 
{
	import net.pixlib.events.CommandEvent;
	import net.pixlib.collections.Iterator;
	import net.pixlib.commands.Batch;
	import net.pixlib.exceptions.NullPointerException;
	import net.pixlib.ioc.load.ApplicationLoader;
	import net.pixlib.log.PalmerDebug;
	
	import flash.events.Event;	

	/**
	 * @author Francis Bourre
	 * @author Romain Ecarnot
	 */
	public class ContextParser extends Batch
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------

		protected var _oLoader : ApplicationLoader;
		protected var _oContext : *;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */	
		public function ContextParser( pc : ParserCollection = null ) 
		{
			super();
			
			_oLoader = null;
			_oContext = null;
			
			if( pc ) setParserCollection( pc );
		}

		/**
		 *
		 */
		public function setApplicationLoader( assembler : ApplicationLoader ) : void
		{
			_oLoader = assembler;
		}
		
		/**
		 *
		 */
		public function getApplicationLoader(  ) : ApplicationLoader
		{
			return _oLoader;
		}

		/**
		 *
		 */
		public function setContextData( context : * ) : void
		{
			_oContext = context;
		}

		/**
		 *
		 */
		public function getContextData(  ) : *
		{
			return _oContext;
		}

		/**
		 *
		 */
		final public function parse( context : * = null, loader : ApplicationLoader = null ) : void
		{
			if( context ) setContextData( context );
			if( loader ) setApplicationLoader( loader );
			
			var msg : String;
			
			if( getApplicationLoader() == null )
			{
				msg = this + ".parse() can't application assembler instance.";
				PalmerDebug.ERROR( msg );
				throw new NullPointerException( msg );
			}
			
			if( getContextData() == null )
			{
				msg = this + ".parse() can't retrieve IoC context data";
				PalmerDebug.ERROR( msg );
				throw new NullPointerException( msg );
			}
			
			super.onExecute( new ContextParserEvent( "", this, getApplicationLoader(), getContextData() ) );
		}
		
		/**
		 * 
		 */
		final override protected function onExecute( e : Event = null ) : void
		{
			parse();
		}
		
		/**
		 * Called when the command process is over.
		 * 
		 * @param	e	event dispatched by the command
		 */
		final override public function onCommandEnd( e : CommandEvent ) : void
		{
			if( _hasNext( ) )
			{
				_next( ).execute( e );

			} else
			{
				fireCommandEndEvent( );
			}
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 *
		 */
		protected function setParserCollection( pc : ParserCollection  ) : void
		{
			removeAll( );
			
			var it : Iterator = pc.iterator( );
			while( it.hasNext( ) )
			{
				addCommand( it.next( ) );
			}	
		}	
	}
}