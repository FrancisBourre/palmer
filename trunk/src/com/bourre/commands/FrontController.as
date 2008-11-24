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
	import com.bourre.core.AbstractLocator;
	import com.bourre.events.EventBroadcaster;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.exceptions.NoSuchElementException;
	import com.bourre.plugin.NullPlugin;
	import com.bourre.plugin.Plugin;
	import com.bourre.plugin.PluginDebug;
	import com.bourre.utils.ClassUtils;
	
	import flash.events.Event;
	import flash.utils.Dictionary;	

	/**
	 * A base class for an application specific front controller,
	 * that is able to dispatch control following particular events
	 * to appropriate command classes.
	 * <p>
	 * The Front Controller is the centralised request handling class in a
	 * Palmer plugin or application. It could be used with or without the
	 * plugin architecture of Palmer. By default all classes which will extend
	 * <code>AbstractPlugin</code> will own an instance of the 
	 * <code>FrontController</code> class.
	 * </p><p>
	 * The role of the Front Controller is to first register all the different
	 * events that it is capable of handling against worker classes, called
	 * command classes.  On hearing an application event, the Front Controller
	 * will look up its table of registered events, find the appropriate
	 * command for handling the event, before dispatching control to the
	 * command by calling its execute() method.
	 * </p><p>
	 * When used inside a plugin the Front Controller is automatically registered
	 * as a listener of all private events. It will receive all private events 
	 * dispatched in all plugin's MVC components. 
	 * </p>
	 * @author Francis Bourre
	 */
	public class FrontController 
		extends AbstractLocator
		implements CommandListener
	{

		protected var _owner 		: Plugin;
		protected var _dCommands 	: Dictionary;

		/**
		 * Creates a new Front Controller instance for the passed-in
		 * plugin. If the plugin argument is omitted, the Front Controller
		 * is owned by the global instance of the <code>NullPlugin</code
		 * class.
		 * 
		 * @param	owner	plugin instance which owns the controller
		 */
		public function FrontController( owner : Plugin = null ) 
		{
			_owner = ( owner == null ) ? NullPlugin.getInstance() : owner;
			if ( owner == null ) EventBroadcaster.getInstance().addListener( this );

			super( Command, null, PluginDebug.getInstance( getOwner() ) );

			_dCommands = new Dictionary();
		}

		/**
		 * Returns the owner of this controller
		 * 
		 * @return 	the owner plugin of this controller
		 */
		final public function getOwner() : Plugin
		{
			return _owner;
		}

		/**
		 * @inheritDoc
		 */
		override public function register( eventName : String, o : Object ) : Boolean
		{
			try
			{
				if ( o is Class )
				{
					return pushCommandClass( eventName, o as Class );

				} else
				{
					return pushCommandInstance( eventName, o as Command );
				}

			} catch( e : Error )
			{
				getLogger().fatal( e.message );
				throw e;
			}
			
			return false;
		}

		/**
		 * Registers the passed-in command class to be triggered each time
		 * the controller will receive an event of type <code>eventType</code>.
		 * <p>
		 * The passed-in command class must at least implement the <code>Command</code>
		 * interface. If the class doesn't inherit from <code>Command</code> the
		 * association failed and an exception is thrown.
		 * </p><p>
		 * If there is already a command or a class associated with the passed-in event
		 * type, the association failed and an exception is thrown.
		 * </p>
		 * @param	eventType	 name of the event type with which the command
		 * 						 will be registered
		 * @param	commandClass class to associate with the passed-in event type
		 * @return	<code>true</code> if the command class has been succesfully	
		 * 			registered with the passed-in event type 
		 * @throws 	<code>IllegalArgumentException</code> — There is already
		 * 			a command or class registered with the specified event type. 			
		 * @throws 	<code>IllegalArgumentException</code> — The passed-in command 
		 * 			class doesn't inherit from Command interface.
		 */
		public function pushCommandClass( eventType : String, commandClass : Class ) : Boolean
		{
			var key : String = eventType.toString();
			var msg : String;

			if ( isRegistered( key ) )
			{
				msg = "There is already a command class registered with '" + key + "' name in " + this;
				getLogger().fatal( msg );
				throw new IllegalArgumentException( msg );

			} else if( !ClassUtils.inherit( commandClass, Command ) )
			{
				msg = "The class '" + commandClass + "' doesn't inherit from Command interface in " + this;
				getLogger().fatal( msg );
				throw new IllegalArgumentException( msg );

			} else
			{
				_m.put( key, commandClass );
				return true;
			}
		}

		/**
		 * Registers the passed-in command to be triggered each time
		 * the controller will receive an event of type <code>eventType</code>.
		 * <p>
		 * If there is already a class or a command associated with the passed-in
		 * event type, the association failed and an exception is thrown.
		 * </p>
		 * @param	eventType	name of the event type with which the command
		 * 						will be registered
		 * @param	command		command to associate with the passed-in event type
		 * @return	<code>true</code> if the command has been succesfully	
		 * 			registered with the passed-in event type 
		 * @throws 	<code>IllegalArgumentException</code> — There is already
		 * 			a command or class registered with the specified event type. 			
		 * @throws 	<code>NullPointerException</code> — The passed-in command 
		 * 			is null
		 */
		public function pushCommandInstance( eventType : String, command : Command ) : Boolean
		{
			var key : String = eventType.toString();
			var msg : String;
			
			if ( isRegistered( key ) )
			{
				msg = "There is already a command class registered with '" + key + "' name in " + this;
				getLogger().fatal( msg );
				throw new IllegalArgumentException( msg );

			} else if( command == null )
			{
				msg = "The passed-in command is null in " + this;
				getLogger().fatal( msg );
				throw new IllegalArgumentException( msg );

			} else
			{
				_m.put( key, command );
				return true;
			}
		}

		/**
		 * Removes the class or the command registered with the
		 * passed-in event type.
		 * 
		 * @param	eventName event type to unregister
		 */
		public function remove( eventType : String ) : void
		{
			_m.remove( eventType.toString() );
		}

		/**
		 * Handles all events received by this controller.
		 * For each received event the controller will look up
		 * its registered events table. If a command or
		 * a class is registered, the controller proceeds.
		 * <p>
		 * Command instance is stored in a specific map in order
		 * to keep a reference to that command during all its
		 * execution, and prevent it to be collected by the
		 * garbage collector. The front controller will
		 * automatically remove the reference when it will receive
		 * <code>onCommandEnd</code> event from the command.
		 * </p>
		 * 
		 * @param	event event object dispatched by the
		 * 			source object
		 */
		final public function handleEvent( event : Event ) : void
		{
			var type : String = event.type.toString();
			var cmd : Command;

			try
			{
				cmd = locate( type ) as Command;

			} catch ( e : Error )
			{
				getLogger().debug( this + ".handleEvent() fails to retrieve command associated with '" + type + "' event type." );
			}

			if ( cmd != null )
			{
				_dCommands[ cmd ] = true;
				( cmd as Command ).addCommandListener( this );
				cmd.execute( event );
			}
		}

		/**
		 * Catch callback events from asynchronous commands thiggered
		 * by this front controller. When the controller receive an event
		 * from the command, that command is removed from the controller
		 * storage.
		 * 
		 * @param	e	event object propagated by the command
		 */
		public function onCommandEnd ( e : Event ) : void
		{
			delete _dCommands[ e.target ];
		}

		/**
		 * Returns the command linked to specified <code>eventType</code>.
		 * If there's no command linked, this method call will fail and 
		 * throw an error.
		 * <p>
		 * The <code>locate</code> method will always return a <code>Command</code>
		 * instance, even if it was a class which was registered with this key.
		 * The <code>locate</code> will instanciate the command and then return it.
		 * </p> 
		 * @throws 	<code>NoSuchElementException</code> — There is no command
		 * 			registered with the passed-in event type
		 */
		override public function locate( eventType : String ) : Object
		{
			var o : Object;

			if ( isRegistered( eventType ) ) 
			{
				o = _m.get( eventType );

			} else
			{
				var msg : String = "Can't find Command instance with '" + eventType + "' name in " + this;
				getLogger().fatal( msg );
				throw new NoSuchElementException( msg );
			}

			if ( o is Class )
			{
				var cmd : Command = new ( o as Class )();
				if ( cmd is AbstractCommand ) ( cmd as AbstractCommand ).setOwner( getOwner() );
				return cmd;

			} else if ( o is Command )
			{
				if ( o is AbstractCommand ) 
				{
					var acmd : AbstractCommand = ( o as AbstractCommand );
					if ( acmd.getOwner() == null ) acmd.setOwner( getOwner() );
				}

				return o;
			}

			return null;
		}

		/**
		 * Adds all key/commands associations within the passed-in
		 * <code>Dictionnary</code> in the current front controller.
		 * The errors thrown by the <code>pushCommandClass</code> and
		 * <code>pushCommandInstance</code> are also thrown in the
		 * <code>add</code> method.
		 * 
		 * @param	d	a dictionary object used to fill this controller
		 * @throws 	<code>IllegalArgumentException</code> — There is already
		 * 			a command or class registered with a key in the dictionary. 
		 * @throws 	<code>IllegalArgumentException</code> — A command class
		 * 			in the dictionary doesn't inherit from Command interface.			
		 * @throws 	<code>NullPointerException</code> — A command in the
		 * 			dictionary is null
		 */
		override public function add( d : Dictionary ) : void
		{
			for ( var key : * in d ) 
			{
				try
				{
					var o : Object = d[ key ] as Object;

					if ( o is Class )
					{
						pushCommandClass( key, o as Class );

					} else
					{
						pushCommandInstance( key, o as Command );
					}

				} catch( e : Error )
				{
					e.message = this + ".add() fails. " + e.message;
					getLogger().error( e.message );
					throw( e );
				}
			}
		}
		
		override public function release() : void
		{
			super.release();
			_owner = null ;
		}
		
		/**
		 * Returns the string representation of this instance.
		 * @return the string representation of this instance
		 */
		override public function toString () : String
		{
			return super.toString() + ( _owner != null ? " of " + _owner : "" );
		}
	}
}