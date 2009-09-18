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
	import net.pixlib.events.CommandEvent;
	import net.pixlib.commands.MacroCommand;
	import net.pixlib.events.ObjectEvent;
	import net.pixlib.exceptions.IllegalStateException;
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.plugin.Plugin;

	import flash.events.Event;

	/**
	 *  Dispatched when sequencer starts.
	 *  
	 *  @eventType com.commands.Sequencer.onSequencerStartEVENT
	 */
	[Event(name="onSequencerStart", type="com.commands.Sequencer.onSequencerStartEVENT")]
	
	/**
	 *  Dispatched when a new command is ready to be executed.
	 *  
	 *  @eventType com.commands.Sequencer.onSequencerProgressEVENT
	 */
	[Event(name="onSequencerProgress", type="com.commands.Sequencer.onSequencerProgressEVENT")]
	
	/**
	 *  Dispatched when sequencer ends.
	 *  
	 *  @eventType com.commands.Sequencer.onSequencerEndEVENT
	 */
	[Event(name="onSequencerEnd", type="com.commands.Sequencer.onSequencerEndEVENT")]
	
	
	/**
	 * <code>Sequencer</code> object encapsulate a set of <code>Commands</code>
	 * to execute.
	 * 
	 * <p>Sequencer is a first-in first-out stack (FIFO) where commands
	 * are executed in the order they were registered.</p>
	 * 
	 * <p>Default, the <code>Event</code> object received in the <code>execute</code> is passed
	 * to each commands contained in this sequencer.<br />
	 * But you can relay event from command to command using 
	 * <code>useEventFlow</code> property.</p>
	 * 
	 * <p>The Sequencer class extends <code>AbstractCommand</code>
	 * and so, dispatch an <code>onCommandEnd</code> event at the execution end
	 * of all commands.</p> 
	 * 
	 * @author Romain Ecarnot
	 * @author Francis Bourre
	 */
	public class Sequencer 
		extends AbstractCommand 
		implements MacroCommand, CommandListener
	{
		//--------------------------------------------------------------------
		// Events
		//--------------------------------------------------------------------
		
		/**
		 * Name of the event dispatched at the start of the command's process.
		 */
		public static const onSequencerStartEVENT 	: String = "onSequencerStart";
		
		/**
		 * Name of the event dispatched at each step of computation.
		 */
		public static const onSequencerProgressEVENT : String = "onSequencerProgress";
		
		/**
		 * Name of the event dispatched at the stop of the command's process.
		 */
		public static const onSequencerEndEVENT 	: String = "onSequencerEnd";
		
		
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private var _bUseEventFlow : Boolean;
		
		
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		/** Stores commands list. */
		protected var aCommands : Vector.<Command>;
		
		/** Current command index. */
		protected var nIndex : int;
		
		/** Main source event data. */
		protected var eEvent : Event;
		
		/** Returns true if a command is currently processing. */
		protected var _isCommandProcessing : Boolean;

		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 *  Indicates if Sequencer use command event flow or only 
		 *  main source event data.
		 *  
		 *  <p>If <code>true</code> next command is executed using 
		 *  last command event result.<br />
		 *  If <code>false</code>, only use the main source event data 
		 *  passed-in Sequencer.execute() call.</p>
		 *  
		 *  @default false
		 */
		public function get useEventFlow() : Boolean
		{
			return _bUseEventFlow;
		}

		/** @private */
		public function set useEventFlow(useEventFlow : Boolean) : void
		{
			_bUseEventFlow = useEventFlow;
		}
		
			
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates a new instance sequencer.
		 */
		public function Sequencer( )
		{
			aCommands = new Vector.<Command>( );
			
			useEventFlow = false;
			_isCommandProcessing = false;
		}

		/**
		 * @inheritDoc
		 */
		override public function setOwner( owner : Plugin ) : void
		{
			super.setOwner( owner );
			var l : Number = aCommands.length;
			var c : AbstractCommand;
			while( --l - (-1 ) ) if( ( c = aCommands[ l ] as AbstractCommand ) != null ) c.setOwner( owner );
		}
		
		/**
		 * @inheritDoc
		 */
		public function addCommand( command : Command ) : Boolean
		{
			return addCommandEnd( command );
		}
		
		/**
		 * Adds passed-in <code>command</code> before passed-in <code>searchCommand</code>.
		 * 
		 * <p><code>indexCommand</code> must be registered in sequencer command list to find 
		 * his position.<br />
		 * The <code>command</code> command is inserted before 
		 * <code>searchCommand</code> command.</p>
		 * 
		 * @param	searchCommand	Command to search
		 * @param	command			Command to add before <code>searchCommand</code> 
		 * 							command.
		 * 							
		 * @return	<code>true</code> if <code>command</code> is was successfully inserted.
		 * 
		 */
		public function addCommandBefore( searchCommand : Command, command : Command ) : Boolean
		{
			var index : int = aCommands.indexOf( searchCommand ) ;
			if( command == null && index != -1) return false;
			
			return addCommandAt( index, command ) ;
		}
		
		/**
		 * Adds passed-in <code>command</code> after passed-in 
		 * <code>searchCommand</code>. 
		 * 
		 * <p><code>searchCommand</code> must be registered in sequencer to find 
		 * his position.<br />
		 * The <code>command</code> command is added after 
		 * <code>searchCommand</code> command.</p>
		 * 
		 * @param	searchCommand	Command to search
		 * @param	command			Command to add after <code>indexCommand</code> 
		 * 							command.
		 * 					
		 * @return	<code>true</code> if <code>command</code> is was successfully inserted.
		 */
		public function addCommandAfter( searchCommand : Command, command : Command ) : Boolean
		{
			var index : int = aCommands.indexOf( searchCommand ) ;
			if( command == null && index != -1) return false;
			
			return addCommandAt( index + 1, command ) ;
		}
		
		/**
		 * Adds passed-in command in first position in sequencer.
		 * 
		 * @param	command	Command to add
		 * 
		 * @return	<code>true</code> if <code>command</code> is was successfully inserted.
		 */
		public function addCommandStart( command : Command ) : Boolean
		{
			return addCommandAt( 0, command ) ;
		}
		
		/**
		 * Adds passed-in command at last position in sequencer.
		 * 
		 * @param	command	Command to add
		 * 
		 * @return	<code>true</code> if <code>command</code> is was successfully inserted.
		 */
		public function addCommandEnd( command : Command ) : Boolean
		{
			return addCommandAt( aCommands.length, command ) ;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeCommand( command : Command ) : Boolean
		{
			if( !isRunning() )
			{
				var id : int = aCommands.indexOf( command ); 
				if ( id == -1 ) return false;
				while ( ( id = aCommands.indexOf( command ) ) != -1 ) aCommands.splice( id, 1 );
				return true;
			}
			
			return false;
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
			return aCommands.indexOf( command ) != -1;
		}
		
		/**
		 * Starts the execution of the batch. The received event 
		 * is registered and then passed to sub commands.
		 */
		override protected function onExecute( e : Event = null ) : void
		{
			if( !_isCommandProcessing && size() > 0 )
			{
				eEvent = e;
				nIndex = 0;
				fireStartEvent();
				executeNextCommand( eEvent );
			}
		}
		
		override protected function onCancel() : void
		{
			//TODO implementation
		}
		
		/**
		 * Called when the command process is beginning.
		 * 
		 * @param	e	event dispatched by the command
		 */
		public function onCommandStart( e : CommandEvent ) : void
		{
			_isCommandProcessing = true;
		}
		
		/**
		 * Called when the command process is over.
		 * 
		 * @param	e	event dispatched by the command
		 */
		public function onCommandEnd( e : CommandEvent ) : void
		{
			_isCommandProcessing = false;

			if ( nIndex + 1 < size() )
			{
				aCommands[ nIndex ].removeCommandListener( this );
				nIndex++;
				executeNextCommand( e );
			} 
			else
			{
				nIndex = 0;
				fireEndEvent();
				fireCommandEndEvent( );
			}
		}
		
		/**
		 * Returns the <code>Command</code> that running at this time in the sequencer.
		 * 
		 * @return the <code>Command</code> that running at this time in the sequencer
		 */
		public function getRunningCommand () : Command
		{
			if( isRunning() )
			{
				return aCommands[ nIndex ];

			} else
			{
				throw new IllegalStateException()( this + ".getRunningCommand() cannot be called when the sequencer is not running ");
				return null ;
			}
		}
		
		/**
		 * Removes all commands stored in the batch stack.
		 */
		public function clear() : void
		{
			if( !isRunning() )
			{
				aCommands = new Vector.<Command>( );
			}
		}
		
		/**
		 * Returns the number of commands stored in this sequencer.
		 * 
		 * @return	the number of commands stored in this sequencer
		 */
		public function size() : uint
		{
			return aCommands.length;		
		}
		
		/**
		 * Adds a listener that will be notified about sequencer process.
		 * 
		 * @param	listener	listener that will receive events
		 * 
		 * @return	<code>true</code> if the listener has been added
		 */
		public function addSequencerListener( listener : SequencerListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}
		
		/**
		 * Removes listener from receiving any sequencer information.
		 * 
		 * @param	listener	listener to remove
		 * 
		 * @return	<code>true</code> if the listener has been removed
		 */
		public function removeSequencerListener( listener : SequencerListener ) : Boolean
		{
			return _oEB.removeListener( listener );
		}

		/**
		 * @inheritDoc
		 */
		override public function toString() : String
		{
			return super.toString() + " [" + size() +"]";
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * Adds passed-in command at index position in sequencer.
		 * 
		 * @param	index		Index for insertion (must be valid)
		 * @param	command		Command to add
		 * 
		 * @return	<code>true</code> if <code>command</code> was successfully inserted.
		 */
		protected function addCommandAt( index : uint, command : Command ) : Boolean
		{
			if( !isRunning()  )
			{
				var l : uint = aCommands.length;
				
				if( command == null || index > l) return false;
				
				if( command is AbstractCommand ) ( command as AbstractCommand).setOwner( getOwner( ) );
				
				aCommands.splice( index, 0, command );
				return (l != aCommands.length );
			}
			
			return false;
		}
		
		/**
		 * Executes next method, if available.
		 */
		protected function executeNextCommand ( event : Event ) : void
		{
			if ( nIndex == -1 )
	  		{
	  			PalmerDebug.WARN( this + " process has been aborted. Can't execute next command." );		
	  		} 
	  		else 
			{
		  		aCommands[ nIndex ].addCommandListener ( this );
		  		
		  		var c : AbstractCommand;
		  		if( ( c = aCommands[ nIndex ] as AbstractCommand ) != null ) c.setOwner( getOwner() );
				
				fireProgressEvent( aCommands[ nIndex ] );
		  		
				aCommands[ nIndex ].execute( useEventFlow ? event : eEvent );
			}
		}
		
		/**
		 * Fires <code>onSequencerStartEVENT</code> event when sequencer starts 
		 * execution.
		 */
		protected function fireStartEvent() : void
		{
			_oEB.broadcastEvent( new ObjectEvent( onSequencerStartEVENT, this, null ) );
		}
		
		/**
		 * Fires <code>onSequencerProgressEVENT</code> event when a new 
		 * command is ready to be executed.
		 * 
		 * @param	command	Command to be executed
		 */
		protected function fireProgressEvent( command : Command ) : void
		{
			_oEB.broadcastEvent( new ObjectEvent( onSequencerProgressEVENT, this, command ) );
		}
		
		/**
		 * Fires <code>onSequencerEndVENT</code> event when sequencer ends 
		 * execution.
		 */
		protected function fireEndEvent() : void
		{
			_oEB.broadcastEvent( new ObjectEvent( onSequencerEndEVENT, this, null ) );
		}
	}
}
