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
package com.bourre.commands 
{
	import com.bourre.commands.MacroCommand;	import com.bourre.plugin.Plugin;		import flash.events.Event;	
	/**
	 * An asynchronous batch behave as a normal batch, but is designed to handle 
	 * asynchronous commands. A command executed by this batch could only start 
	 * when the previous command have fire its <code>onCommandEnd</code> event.
	 * <p>
	 * The <code>Event</code> object received in the <code>execute</code> is passed
	 * to each commands contained in this batch.
	 * </p><p>
	 * The <code>ASyncBatch</code> class extends <code>AbstractSyncCommand</code>
	 * and so, dispatch an <code>onCommandEnd</code> event at the execution end
	 * of all commands.
	 * </p> 
	 * @author Cédric Néhémie
	 * @author Francis Bourre
	 */
	public class Batch 
		extends AbstractCommand 
		implements MacroCommand, CommandListener
	{
		/**
		 * Takes all elements of an Array and pass them one by one as arguments
		 * to a method of an object.
		 * It's exactly the same concept as batch processing in audio or video
		 * software, when you choose to run the same actions on a group of files.
		 * <p>
		 * Basical example which sets _alpha value to .4 and scale to 50
		 * on all MovieClips nested in the Array :
		 * </p>
		 * @example
		 * <listing>
		 * import com.bourre.commands.*;
		 *
		 * function changeAlpha( mc : MovieClip, a : Number, s : Number )
		 * {
		 *      mc._alpha = a;
		 *      mc._xscale = mc._yscale = s;
		 * }
		 *
		 * Batch.process( changeAlpha, [mc0, mc1, mc2], .4, 50 );
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

		protected var _aCommands 	: Vector.<Command>;
		protected var _nIndex 		: Number;
		protected var _eEvent 		: Event;
		protected var _oLastCommand : Command;
		
		/**
		 * Creates a new batch object.
		 */
		public function Batch()
		{
			_aCommands = new Vector.<Command>();
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
			var l : Number = _aCommands.length;
			return (l != _aCommands.push( command ) );
		}

		/**
		 * @inheritDoc
		 */
		public function removeCommand( command : Command ) : Boolean
		{
			var id : Number = _aCommands.indexOf( command ); 
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
				_next( ).execute( _eEvent );
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
			_aCommands = new Vector.<Command>();
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
