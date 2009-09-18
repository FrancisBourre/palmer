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
	import net.pixlib.events.EventBroadcaster;
	import net.pixlib.exceptions.IllegalStateException;
	import net.pixlib.exceptions.UnimplementedMethodException;
	import net.pixlib.log.Log;
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.model.Model;
	import net.pixlib.plugin.NullPlugin;
	import net.pixlib.plugin.Plugin;
	import net.pixlib.plugin.PluginDebug;
	import net.pixlib.view.View;

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
		implements Command, Cancelable
	{
		protected var _oEB 			: EventBroadcaster;
		
		private var _owner 			: Plugin;
		private var _bIsRunning 	: Boolean;
		private var _bIsCancelled 	: Boolean;

		public function AbstractCommand() 
		{
			_bIsRunning 	= false;
			_bIsCancelled 	= false;
			_oEB 			= new EventBroadcaster ( this );
			_owner			= NullPlugin.getInstance();
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
		final public function execute( e : Event = null ) : void 
		{
			var msg : String;

			if ( isRunning() )
			{
				msg = this + ".execute() failed. This command is already processing.";
				msg += " It cannot be called twice. Next call must wait for fireCommandEndEvent() call.";
				getLogger().error( msg );
				throw new IllegalStateException( msg );

			} else if ( isCancelled() )
			{
				msg = this + ".execute() failed. This command has been cancelled.";
				getLogger().error( msg );
				throw new IllegalStateException( msg );

			} else
			{
				fireCommandStartEvent();

				try
				{
					onExecute( e );

				} catch ( exception : Error )
				{
					getLogger().error( this + ".execute() failed." );
					fireCommandEndEvent();
					throw( exception );
				}
			}
		}
		
		/**
		 * Fires <code>onCommandStart</code> event to each listener when
		 * process is beginning. 
		 */
		final public function fireCommandStartEvent() : void
		{
			_bIsRunning = true;
			broadcastCommandStartEvent();
		}

		/**
		 * Fires <code>onCommandEnd</code> event to each listener when
		 * process is over. 
		 */
		final public function fireCommandEndEvent() : void
		{
			if ( _bIsRunning )
			{
				_bIsRunning = false;
				broadcastCommandEndEvent();

			} else
			{
				var msg : String = this + ".fireCommandEndEvent() failed. This command was not running.";
				getLogger().warn( msg );
			}
		}

		/**
		 * Adds a listener that will receive a start event <code>
		 * AbstractCommand.onCommandStartEVENT</code> each time  
		 * command process is beginning and an end event <code>
		 * AbstractCommand.onCommandEndEVENT</code> each time when 
		 * command process is over.
		 * <p>
		 * The <code>addListener</code> method supports custom arguments
		 * provided by <code>EventBroadcaster.addEventListener()</code> method.
		 * </p> 
		 * @param	listener	listener that will receive events
		 * @param	rest		optional arguments
		 * @return	<code>true</code> if the listener has been added to
		 * 			receive both events.
		 * @see		net.pixlib.events.EventBroadcaster#addEventListener()
		 * 			EventBroadcaster.addEventListener() documentation
		 */
		public function addCommandListener( listener : CommandListener, ... rest ) : Boolean
		{
			return (_oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ CommandEvent.onCommandStartEVENT, listener ].concat( rest ) : [ CommandEvent.onCommandStartEVENT, listener ] ) 
			&& _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ CommandEvent.onCommandEndEVENT, listener ].concat( rest ) : [ CommandEvent.onCommandEndEVENT, listener ] ));
		}

		/**
		 * Removes listener from receiving any start and end process 
		 * information.
		 * 
		 * @param	listener	listener to remove
		 * @return	<code>true</code> if the listener has been removed to
		 * 			receive both events.
		 * @see		net.pixlib.events.EventBroadcaster#addEventListener()
		 * 			EventBroadcaster.addEventListener() documentation
		 */
		public function removeCommandListener( listener : CommandListener ) : Boolean
		{
			return (_oEB.removeEventListener( CommandEvent.onCommandStartEVENT, listener ) 
			&& _oEB.removeEventListener( CommandEvent.onCommandEndEVENT, listener ));
		}
		
		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			return _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
		}

		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			return _oEB.removeEventListener( type, listener );
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
		 * it instantiates a command.
		 * 
		 * @param	owner plugin which owns this command 
		 */		
		public function setOwner( owner : Plugin ) : void
		{
			_owner = owner;
		}

		/**
		 * Returns the exclusive logger object owned by the plugin.
		 * It allows this command to send logging message directly on
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
		 * It allows this command to locate any model registered to
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
		 * It allows this command to locate any view registered to
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
		 * Implementation of the <code>Runnable</code> interface. 
		 * A call to <code>run()</code> is equivalent to a call to
		 * <code>execute</code> without any argument.
		 */
		final public function run() : void
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
		final public function isRunning () : Boolean
		{
			return _bIsRunning;
		}

		/**
		 * Attempts to cancel command execution.
		 * This attempt will fail if the command has been already completed,
		 * has been already cancelled, or could not be cancelled for
		 * any reason. If cancellation is successful, and this command has 
		 * not started when cancel is called, this command should never run 
		 * later.
		 * <p>
		 * After this method call, subsequent calls to <code>isRunning</code>
		 * will always return <code>false</code>. Subsequent calls to
		 * <code>run</code> will always fail with an exception. Subsequent
		 * calls to <code>cancel</code> will always failed with the throw
		 * of an exception. 
		 * </p>
		 * @throws 	<code>IllegalStateException</code> — if the <code>cancel</code>
		 * 			method has been called wheras the operation has been already
		 * 			cancelled
		 */
		final public function cancel() : void
		{
			if ( isCancelled() )
			{
				var msg : String = this + ".cancel() illegal call. This command has been already cancelled.";
				getLogger().error( msg );
				throw new IllegalStateException( msg );

			} else
			{
				try
				{
					_bIsCancelled = true;
					onCancel();
					fireCommandEndEvent();

				} catch ( exception : UnimplementedMethodException )
				{
					_bIsCancelled = false;
					throw( exception );
				}
			}
		}

		/**
		 * Returns <code>true</code> if the command has been stopped
		 * after a <code>cancel</code> method call.
		 * 
		 * @return	<code>true</code> if the operation have been stopped
		 * 			as a result of a <code>cancel</code> call
		 */
		final public function isCancelled() : Boolean
		{
			return _bIsCancelled;
		}

		/**
		 * Returns the string representation of the object.
		 * 
		 * @return the string representation of the object
		 */
		public function toString() : String
		{
			return PalmerStringifier.stringify( this );
		}

		/**
		 * Fires a private event in the scope of the plugin. 
		 */
		protected function firePrivateEvent( e : Event ) : void
		{
			getOwner().firePrivateEvent( e );
		}
		
		/**
		 * Sends to each listener <code>AbstractCommand.onCommandStartEVENT</code>
		 * when process is beginning. Override this method if you need 
		 * to change the message broadcasted. 
		 */
		protected function broadcastCommandStartEvent() : void
		{
			_oEB.broadcastEvent( new CommandEvent ( CommandEvent.onCommandStartEVENT, this ) );
		}
		
		/**
		 * Sends to each listener <code>AbstractCommand.onCommandEndEVENT</code>
		 * when process is over. Override this method if you need to
		 * change the message broadcasted.
		 */
		protected function broadcastCommandEndEvent() : void
		{
			_oEB.broadcastEvent( new CommandEvent ( CommandEvent.onCommandEndEVENT, this ) );
		}

		/**
		 * Override this method in concrete class to implement command 
		 * execution. 
		 */
		protected function onExecute( e : Event = null ) : void
		{
			var msg : String = this + ".onExecute() must be implemented in concrete class to allow execute() call.";
			getLogger().error( msg );
			throw( new UnimplementedMethodException( msg ) );
		}

		/**
		 * Override this method in concrete class to implement cancel 
		 * behavior. 
		 */
		protected function onCancel() : void
		{
			var msg : String = this + ".onCancel() must be implemented in concrete class to allow cancel() call.";
			getLogger().error( msg );
			throw( new UnimplementedMethodException( msg ) );
		}
	}
}