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
package net.pixlib.commands 
{
	import net.pixlib.commands.MacroCommand;
	import net.pixlib.plugin.Plugin;

	import flash.events.Event;

	/**
	 * <code>Batch</code> object encapsulate a set of <code>Commands</code>
	 * to execute.
	 * 
	 * <p>Default, Batch is a first-in first-out stack (FIFO) where commands
	 * are executed in the order they were registered.<br />
	 * Batch can be LIFO using Batch instanctiation 2nd argument.</p>
	 * 
	 * <p>Default, the <code>Event</code> object received in the 
	 * <code>execute</code> is passed to each commands contained in this 
	 * batch.<br />
	 * But you can relay event from command to command using Batch 
	 * <code>instanciaton</code> first argument.
	 * </p>
	 * 
	 * <p>The Batch class extends <code>AbstractCommand</code>
	 * and so, dispatch an <code>onCommandEnd</code> event at the execution end
	 * of all commands.</p> 
	 * 
	 * @author Cédric Néhémie
	 * @author Francis Bourre	 * @author Romain Ecarnot
	 */
	public class Batch 
		extends AbstractCommand 
		implements MacroCommand, CommandListener
	{

		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		/** Stores commands list. */
		protected var _aCommands : Vector.<Command>;

		/** Current command index. */
		protected var _nIndex : Number;

		/** Main source event data. */
		protected var _eEvent : Event;

		/** Last executed command. */
		protected var _oLastCommand : Command;
		
		/**
		 *  Indicates if Batch use command event flow or only 
		 *  source event data.
		 *  
		 *  <p>If <code>true</code> next command is executed using 
		 *  last command event result.<br />
		 *  If <code>false</code>, only use the main source event data 
		 *  passed-in Batch.execute() call.</p>
		 *  
		 *  @default false
		 *   
		 *  @see #Batch()
		 */
		protected var _bUseEventFlow : Boolean;
		
		/**
		 * Defines command list execution order.
		 * 
		 * <p>Default is FIFO mode (<code>false</code>).<br />
		 * Sets to <code>true</code> to use LIFO mode.</p>
		 * 
		 * @default false
		 */
		protected var _bReversed : Boolean;
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Takes all elements of an Array and pass them one by one as arguments
		 * to a method of an object.
		 * It's exactly the same concept as batch processing in audio or video
		 * software, when you choose to run the same actions on a group of files.
		 * <p>
		 * Basical example which sets _alpha value to 0.4 and scale to 0.5
		 * on all MovieClips nested in the Array :
		 * </p>
		 * @example
		 * <listing>
		 * import net.pixlib.commands.*;
		 *
		 * function changeAlphaAndScale( mc : MovieClip, a : Number, s : Number )
		 * {
		 *      mc.alpha = a;
		 *      mc.scaleX = mc.scaleY = s;
		 * }
		 *
		 * Batch.process( changeAlphaAndScale, [mc0, mc1, mc2], .4, 0.5 );
		 * </listing>
		 *
		 * @param	f		function to run.
		 * @param	a		array of parameters.
		 * @param 	args	additionnal parameters to concat with the passed-in
		 * 					arguments array
		 */
		static public function process( f : Function, a : Array, ...args ) : void
		{
			var l : Number = a.length;
			for( var i : int; i < l ; i++ ) f.apply( null, (args.length > 0 ) ? [ a[i] ].concat( args ) : [ a[i] ] );
		}

		/**
		 * Creates a new batch object.
		 */
		public function Batch( useEventFlow : Boolean = false, reversed : Boolean = false )
		{
			_aCommands = new Vector.<Command>( );
			
			_bUseEventFlow = useEventFlow;			_bReversed = reversed;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function setOwner( owner : Plugin ) : void
		{
			super.setOwner( owner );
			var l : Number = _aCommands.length;
			var c : AbstractCommand;
			while( --l - (-1 ) ) if( ( c = _aCommands[ l ] as AbstractCommand ) != null ) c.setOwner( owner );
		}
		
		/**
		 * @inheritDoc
		 */
		public function addCommand( command : Command ) : Boolean
		{
			if( command == null ) return false;
			if( command is AbstractCommand ) ( command as AbstractCommand).setOwner( getOwner( ) );
			var l : uint = _aCommands.length;
			return (l != _aCommands.push( command ) );
		}

		/**
		 * @inheritDoc
		 */
		public function removeCommand( command : Command ) : Boolean
		{
			var id : int = _aCommands.indexOf( command ); 
			if ( id == -1 ) return false;
			while ( ( id = _aCommands.indexOf( command ) ) != -1 ) _aCommands.splice( id, 1 );
			return true;
		}

		/**
		 * Returns <code>true</code> if the passed-in command is stored
		 * in this batch.
		 * 
		 * @param	command command object to look at
		 * @return	<code>true</code> if the passed-in command is stored
		 * 		   	in the <code>Batch</code>
		 */
		public function contains( command : Command ) : Boolean
		{
			return _aCommands.indexOf( command ) != -1;
		}
		
		/**
		 * Starts the execution of the batch. The received event 
		 * is registered and then passed to sub commands.
		 */
		override public function execute( e : Event = null ) : void
		{
			_eEvent = e;
			_nIndex = -1;
			_bIsRunning = true;
			
			if( _bReversed ) _aCommands.reverse();
			
			if( _hasNext( ) ) _next( ).execute( _eEvent );
		}

		/**
		 * Called when the command process is over.
		 * 
		 * @param	e	event dispatched by the command
		 */
		public function onCommandEnd( e : Event ) : void
		{
			if( _hasNext( ) )
			{
				_next( ).execute( _bUseEventFlow ? e : _eEvent );
			} 
			else
			{
				_bIsRunning = false;
				fireCommandEndEvent( );
			}
		}

		/**
		 * Removes all commands stored in the batch stack.
		 */
		public function removeAll() : void
		{
			_aCommands = new Vector.<Command>( );
		}

		/**
		 * Returns the number of commands stored in this batch.
		 * 
		 * @return	the number of commands stored in this batch
		 */
		public function size() : uint
		{
			return _aCommands.length;		
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * Returns the next command to execute.
		 * 
		 * @return 	the next command to execute
		 */
		protected function _next() : Command
		{
			if( _oLastCommand ) _oLastCommand.removeCommandListener( this );
			_oLastCommand = _aCommands.shift( ) as Command;
			_oLastCommand.addCommandListener( this );
			return _oLastCommand;
		}
		
		/**
		 * Returns <code>true</code> if there is a command
		 * left to execute.
		 * 
		 * @return	<code>true</code> if there is a command
		 * 			left to execute
		 */
		protected function _hasNext() : Boolean
		{
			return _nIndex + 1 < _aCommands.length;
		}
	}
}
