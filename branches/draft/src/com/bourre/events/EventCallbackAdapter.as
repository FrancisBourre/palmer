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
package com.bourre.events 
{
	import com.bourre.commands.AbstractCommand;
	import com.bourre.commands.Command;
	import com.bourre.commands.CommandListener;
	import com.bourre.commands.Delegate;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.log.PalmerDebug;
	import com.bourre.log.PalmerStringifier;
	import com.bourre.transitions.TickListener;
	import com.bourre.utils.ClassUtils;
	
	import flash.events.Event;		

	/**
	 * The EventCallbackAdapter class.
	 * 
	 * @author 	Francis Bourre
	 */
	public class EventCallbackAdapter 
		implements Command, TickListener
	{
		protected var _oEB : EventBroadcaster;
		protected var _cArgumentCallbackFactoryClass : Class;
		protected var _oCallbackTarget : Object;		protected var _a : Array;

		public function EventCallbackAdapter( argumentCallbackFactoryClass : Class = null, callbackTarget : Object = null, ... rest ) 
		{
			_oEB = new EventBroadcaster ( this );
			if ( argumentCallbackFactoryClass != null ) setArgumentCallbackFactoryClass( argumentCallbackFactoryClass );			if ( callbackTarget != null ) setCallbackTarget( callbackTarget );
			_a = rest;
		}

		public function getArguments() : Array
		{
			return _a;
		}

		public function setArguments( ... rest ) : void
		{
			if ( rest.length > 0 ) _a = rest;
		}

		public function setArgumentsArray( a : Array ) : void
		{
			if ( a.length > 0 ) _a = a;
		}

		public function addArguments( ... rest ) : void
		{
			if ( rest.length > 0 ) _a = _a.concat( rest );
		}

		public function addArgumentsArray( a : Array ) : void
		{
			if ( a.length > 0 ) _a = _a.concat( a );
		}

		public function setArgumentCallbackFactoryClass( argumentCallbackFactoryClass : Class ) : void
		{
			if ( ClassUtils.inherit( argumentCallbackFactoryClass, ArgumentCallbackFactory ) )
			{
				_cArgumentCallbackFactoryClass = argumentCallbackFactoryClass;

			} else
			{
				var msg : String = this + ".setSource(" + argumentCallbackFactoryClass + ") fails. Argument doesn't implement " + ArgumentCallbackFactory;
				PalmerDebug.ERROR( msg );
				throw new IllegalArgumentException( msg );
			}
		}

		public function getArgumentCallbackFactoryClass() : Class
		{
			return _cArgumentCallbackFactoryClass;
		}

		public function getArgumentCallbackFactoryInstance() : ArgumentCallbackFactory
		{
			try
			{
				var argumentCallBackFactory : ArgumentCallbackFactory = new _cArgumentCallbackFactoryClass () as ArgumentCallbackFactory;
				return argumentCallBackFactory;

			} catch ( e : Error )
			{
				PalmerDebug.ERROR( e.message );
				throw e;
			}
			
			return null;
		}

		public function setCallbackTarget( callbackTarget : Object, ...typeList ): void
		{
			_oCallbackTarget = callbackTarget;
		}

		public function getCallbackTarget() : Object
		{
			return _oCallbackTarget;
		}

		public function getCallbackTargetCaller( event : Event ) : Delegate
		{
			var d : Delegate;

			if ( _oCallbackTarget is Function )
			{
				d = new Delegate( _oCallbackTarget as Function );

			} else
			{
				try
				{
					d = new Delegate( _oCallbackTarget[ event.type ] );

				} catch ( e : Error )
				{
					PalmerDebug.ERROR( e.message );
					throw e;
				}
			}

			return d;
		}

		public function handleEvent( e : Event ) : void
		{
			execute( e );
		}

		public function execute( event : Event = null ) : void
		{
			try
			{
				var argumentCallbackFactory : ArgumentCallbackFactory = getArgumentCallbackFactoryInstance();
				var d : Delegate = getCallbackTargetCaller( event );
				var a : Array = [ event ];
				if ( _a != null && _a.length > 0 ) a = a.concat( _a );
				d.setArgumentsArray( argumentCallbackFactory.getArguments.apply( null, a ) );
				d.execute();

			} catch( e : Error )
			{
				var msg : String = this + ".handleEvent(" + e + ") fails.";
				PalmerDebug.ERROR( msg );
				throw new IllegalArgumentException( msg );
			}
		}

		public function onTick( e : Event = null ) : void
		{
			execute( e );
		}

		/**
		 * Returns the string representation of this instance.
		 * 
		 * @return the string representation of this instance
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}
		
		//
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
			return false;
		}
		
		/**
		 * Fires <code>onCommandEnd</code> event to the listeners
		 * of this command. 
		 */
		public function fireCommandEndEvent() : void
		{
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
		}	}}