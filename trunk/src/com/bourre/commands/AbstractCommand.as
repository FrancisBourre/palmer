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
	import com.bourre.events.BasicEvent;
	import com.bourre.events.EventBroadcaster;
	import com.bourre.exceptions.UnimplementedMethodException;
	import com.bourre.log.Log;
	import com.bourre.log.PalmerStringifier;
	import com.bourre.model.Model;
	import com.bourre.plugin.Plugin;
	import com.bourre.plugin.PluginDebug;
	import com.bourre.view.View;
	
	import flash.events.Event;	

	/**
	 * <code>AbstractCommand</code> provides a skeleton for commands which
	 * might work within plugin's <code>FrontController</code>. Abstract command
	 * provides methods which allow the <code>FrontController</code> to set
	 * the command owner at the command creation. Additionally the 
	 * <code>AbstractCommand</code> class provides convenient method to access
	 * all MVC components and logging tools of the plugin owner.
	 * <p>
	 * LowRA encourage the creation of stateless commands, it means
	 * that commands must realize all their process entirely in
	 * the <code>execute</code> call. The constructor of a stateless
	 * command should always be empty.
	 * </p><p>
	 * See the <a href="../../../howto/howto-commands.html">How to use
	 * the Command pattern implementation in LowRA</a> document for more details
	 * on the commands package structure.
	 * </p>
	 * @author	Francis Bourre
	 * @author 	Cédric Néhémie
	 */
	public class AbstractCommand 
		implements Command
	{
		static public const onCommandEndEVENT : String = "onCommandEnd";

		protected var _owner : Plugin;
		protected var _oEB : EventBroadcaster;
		protected var _bIsRunning : Boolean;

		public function AbstractCommand() 
		{
			_bIsRunning = false;
			_oEB = new EventBroadcaster ( this );
		}
		
		/**
		 * Implementation of the <code>Runnable</code> interface. 
		 * A call to <code>run()</code> is equivalent to a call to
		 * <code>execute</code> without argument.
		 */
		public function run() : void
		{
			execute();
		}
		
		/**
		 * Returns <code>true</code> if this command is currently
		 * processing.
		 * 
		 * @return	<code>true</code> if this command is currently
		 * 			processing.
		 */
		public function isRunning () : Boolean
		{
			return _bIsRunning;
		}

		/**
		 * Execute a request.
		 * <p>
		 * If execution can't be performed, the command must throw an error.
		 * </p> 
		 * @param	e	An event that will contain data to help command execution. 
		 * @throws 	<code>UnreachableDataException</code> — Sometimes commands use event 
		 * argument as data container to help process execution. In this case the event 
		 * must transport expected data.
		 */
		public function execute( e : Event = null ) : void 
		{
			var msg : String = this + ".execute() must be implemented in concrete class.";
			getLogger().error( msg );
			throw( new UnimplementedMethodException( msg ) );
		}
		
		/**
		 * Fires <code>onCommandEnd</code> event to each command listener when
		 * process is over. 
		 */
		public function fireCommandEndEvent() : void
		{
			_bIsRunning = false;
			_oEB.broadcastEvent( new BasicEvent ( AbstractCommand.onCommandEndEVENT, this ) );
		}
		
		/**
		 * Adds a listener that will be notified about end process.
		 * <p>
		 * The <code>addListener</code> method supports custom arguments
		 * provided by <code>EventBroadcaster.addEventListener()</code> method.
		 * </p> 
		 * @param	listener	listener that will receive events
		 * @param	rest		optional arguments
		 * @return	<code>true</code> if the listener has been added
		 * @see		com.bourre.events.EventBroadcaster#addEventListener()
		 * 			EventBroadcaster.addEventListener() documentation
		 */
		public function addCommandListener( listener : CommandListener, ... rest ) : Boolean
		{
			return _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ AbstractCommand.onCommandEndEVENT, listener ].concat( rest ) : [ AbstractCommand.onCommandEndEVENT, listener ] );
		}
		
		/**
		 * Removes listener from receiving any end process information.
		 * 
		 * @param	listener	listener to remove
		 * @return	<code>true</code> if the listener has been removed
		 * @see		com.bourre.events.EventBroadcaster#addEventListener()
		 * 			EventBroadcaster.addEventListener() documentation
		 */
		public function removeCommandListener( listener : CommandListener ) : Boolean
		{
			return _oEB.removeEventListener( AbstractCommand.onCommandEndEVENT, listener );
		}

		/**
		 * Returns a reference to the owner of this command.
		 * 
		 * @return	the plugin owner of this command
		 */
		public function getOwner() : Plugin
		{
			return _owner;
		}
		
		/**
		 * Defines the plugin owner of this command.
		 * Generally the owner is defined by the
		 * <code>FrontController</code> of a plugin when
		 * it instantiate a command.
		 * 
		 * @param	owner plugin which will own the command 
		 */		
		public function setOwner( owner : Plugin ) : void
		{
			_owner = owner;
		}
		
		/**
		 * Returns the exclusive logger object owned by the plugin.
		 * It allow this command to send logging message directly on
		 * its owner logging channel.
		 * 
		 * @return	logger associated to the owner
		 */
		public function getLogger() : Log
		{
			return PluginDebug.getInstance( getOwner() );
		}

		/**
		 * Returns a reference to the model <code>AbstractModel</code>.
		 * It allow this command to locate any model registered to
		 * owner's <code>ModelLocator</code>.
		 * 
		 * @param	model's key
		 * @return	a reference to the model registered with key argument
		 */
		public function getModel( key : String ) : Model
		{
			return getOwner().getModel( key );
		}
		
		/**
		 * Returns a reference to the view <code>AbstractView</code>.
		 * It allow this command to locate any view registered to
		 * owner's <code>ViewLocator</code>.
		 * 
		 * @param	view's key
		 * @return	a reference to registered view
		 */
		public function getView( key : String ) : View
		{
			return getOwner().getView( key );
		}

		/**
		 * Check if a model <code>AbstractModel</code> is registered
		 * with passed key in owner's <code>ModelLocator</code>.
		 * 
		 * @param	model's key
		 * @return	true if model a model <code>AbstractModel</code> is registered.
		 */
		public function isModelRegistered( key : String ) : Boolean
		{
			return getOwner().isModelRegistered( key );
		}
		
		/**
		 * Check if a view <code>AbstractView</code> is registered
		 * with passed key in owner's <code>ViewLocator</code>.
		 * 
		 * @param	view's key
		 * @return	true if model a view <code>AbstractView</code> is registered.
		 */
		public function isViewRegistered( key : String ) : Boolean
		{
			return getOwner().isViewRegistered( key );
		}

		/**
		 * Fires a private event directly on this command's owner. 
		 */
		protected function firePrivateEvent( e : Event ) : void
		{
			getOwner().firePrivateEvent( e );
		}

		/**
		 * Returns the string representation of the object.
		 * 
		 * @return the string representation of the object
		 */
		public function toString():String
		{
			return PalmerStringifier.stringify( this );
		}
	}
}