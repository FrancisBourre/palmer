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
package com.bourre.core 
{
	import com.bourre.collections.HashMap;
	import com.bourre.collections.TypedContainer;
	import com.bourre.core.Locator;
	import com.bourre.events.Broadcaster;
	import com.bourre.events.EventBroadcaster;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.exceptions.NoSuchElementException;
	import com.bourre.exceptions.UnsupportedOperationException;
	import com.bourre.log.Log;
	import com.bourre.log.PalmerDebug;
	import com.bourre.log.PalmerStringifier;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;	

	/**
	 * Dispatched when an object is registered into locator.
	 *  
	 *  @eventType com.bourre.core.LocatorEvent.onRegisterObjectEVENT
	 */
	[Event(name="onRegisterObject", type="com.bourre.core.LocatorEvent")]

	/**
	 *  Dispatched when an object is unregistered form locator.
	 *  
	 *  @eventType com.bourre.core.LocatorEvent.onUnregisterObjectEVENT
	 */
	[Event(name="onUnregisterObject", type="com.bourre.core.LocatorEvent")]

	/**
	 * The AbstractLocator class.
	 * 
	 * @author 	Francis Bourre
	 */
	public class AbstractLocator implements Locator, TypedContainer
	{
		/**
		 * Map storing <code>String</code> keys associated with
		 * <code>Object</code> values.
		 */
		protected var _m : HashMap;

		private var _oEB : Broadcaster;
		private var _cType : Class;
		private var _logger : Log;

		/**
		 * Creates a new locator instance. If the <code>type</code>
		 * argument is defined, the locator is considered as typed, and
		 * then the type of all elements inserted in this locator is checked.
		 * 
		 * @param	type 			<code>Class</code> type for locator elements.
		 * @param	typeListener 	<code>Class</code> type for locator listeners.
		 * @param	logger 			custom logger to output locator messages.
		 */
		public function AbstractLocator( type : Class = null, typeListener : Class = null, logger : Log = null ) 
		{
			_cType = ( type != null ) ? type : Object;
			_m = new HashMap( );
			_oEB = new EventBroadcaster( this, ( typeListener == null ) ? LocatorListener : typeListener );
			_logger = (logger == null ) ? PalmerDebug.getInstance( ) : logger;
		}
		
		/**
		 * Call this method to do something when an object is registered 
		 * in locator.
		 * 
		 * @param	name	Name of the registered object
		 * @param	o		The registered object
		 */
		protected function onRegister( name : String = null, o : Object = null ) : void
		{
			broadcastEvent( getLocatorEvent( getOnRegisterEventType( ), name, o ) );
		}

		/**
		 * Call this method to do something when an object is unregistered 
		 * from locator.
		 * 
		 * @param	name	Name of the registered object
		 * @param	o		The registered object
		 */
		protected function onUnregister( name : String = null ) : void
		{
			broadcastEvent( getLocatorEvent( getOnUnregisterEventType( ), name ) );
		}

		/**
		 * Returns event type for "onRegister" event.
		 * 
		 * @default onRegisterObject
		 */
		protected function getOnRegisterEventType(  ) : String
		{
			return LocatorEvent.onRegisterObjectEVENT;
		}

		/**
		 * Returns event type for "onUnregister" event.
		 * 
		 * @default onUnregisterObject
		 */
		protected function getOnUnregisterEventType(  ) : String
		{
			return LocatorEvent.onUnregisterObjectEVENT;
		}

		/**
		 * Builds locator event structure.
		 * 
		 * <p>Overrides to use custom event type.</p>
		 */
		protected function getLocatorEvent( type : String, name : String = null, o : Object = null ) : LocatorEvent
		{
			return new LocatorEvent( type, this, name, o );
		}

		/**
		 * @copy com.bourre.events.Broadcaster#broadcastEvent()
		 */
		protected function broadcastEvent( e : Event ) : void
		{
			_oEB.broadcastEvent( e );
		}

		/**
		 * Returns event <code>Broadcaster</code> owned by this locator.
		 * 
		 * @return The event <code>Broadcaster</code> owned by this locator.
		 */
		protected function getBroadcaster() : Broadcaster
		{
			return _oEB;
		}

		/**
		 * Returns the exclusive logger object owned by this locator.
		 * It allow this logger to send logging message directly on
		 * its owner logging channel.
		 * 
		 * @return	logger associated to the owner
		 */
		public function getLogger() : Log
		{
			return _logger;
		}

		/**
		 * Returns <code>true</code> is there is a ressource associated
		 * with the passed-in <code>key</code>. To avoid errors when
		 * retreiving ressources from a locator you should systematically
		 * use the <code>isRegistered</code> function to check if the
		 * ressource you would access is already accessible before any
		 * call to the <code>locate</code> function.
		 * 
		 * @return 	<code>true</code> is there is a ressource associated
		 * 			with the passed-in <code>key</code>.
		 */
		public function isRegistered( name : String ) : Boolean
		{
			return _m.containsKey( name );
		}

		/**
		 * Registers passed-in object with identifier name to this locator.
		 * 
		 * @param	name	Key identifier
		 * @param	o		Object to store
		 * 
		 * @return 	<code>true</code> if success
		 * 			
		 * @throws 	<code>IllegalArgumentException</code> — Key or object 
		 * 			are already defined in this locator.
		 */
		public function register( name : String, o : Object ) : Boolean
		{
			var msg : String;

			if ( isTyped( ) && !( o is getType( ) ) )
			{
				msg = this + ".register() failed. Item must be '" + getType( ).toString( ) + "' typed.";
				getLogger( ).error( msg );
				throw new IllegalArgumentException( msg );
			}

			if ( _m.containsKey( name ) )
			{
				msg = " item is already registered with '" + name + "' name in " + this;
				getLogger( ).error( msg );
				throw new IllegalArgumentException( msg );

				return false;
			} 
			else
			{
				_m.put( name, o );
				onRegister( name, o );
				return true;
			}
		}

		/**
		 * Unregisters object registered with identifier name.
		 * 
		 * @param	name	Key identifier
		 * 
		 * @return 	<code>true</code> if success
		 */
		public function unregister( name : String ) : Boolean
		{
			if ( isRegistered( name ) )
			{
				_m.remove( name );
				onUnregister( name );
				return true;
			} 
			else
			{
				return false;
			}
		}

		/**
		 * Returns the ressource associated with the passed-in <code>key</code>.
		 * If there is no ressource identified by the passed-in key, the
		 * function will fail with an error. To avoid the throw of an exception
		 * when attempting to access to a ressource, take care to check the
		 * existence of the ressource before trying to access to it.
		 * 
		 * @param	key	identifier of the ressource to access
		 * @return	the ressource associated with the passed-in <code>key</code>
		 * @throws 	<code>NoSuchElementException</code> — There is no ressource
		 * 			associated with the passed-in key
		 */
		public function locate( name : String ) : Object
		{
			if ( isRegistered( name ) ) 
			{
				return _m.get( name );
			} 
			else
			{
				var msg : String = "Can't find '" + getType( ).toString( ) + "' item with '" + name + "' name in " + this;
				getLogger( ).fatal( msg );
				throw new NoSuchElementException( msg );
			}
		}

		/**
		 * Clears all association between keys and objects
		 * registered for this locator.
		 */
		public function release() : void
		{
			_m.clear( );
			_logger = null ;
		}

		/**
		 * Adds all ressources contained in the passed-in dictionnary
		 * into this locator instance. If there is keys used both in
		 * the locator and in the dictionnary an exception is thrown.
		 * 
		 * @param	d	dictionnary instance which contains ressources
		 * 				to be added
		 * @throws 	<code>IllegalArgumentException</code> — One or more
		 * 			keys present in the dictionnary already exist in this
		 * 			locator instance.
		 */
		public function add( d : Dictionary ) : void
		{
			for ( var key : * in d ) 
			{
				try
				{
					register( key, d[ key ] );
				} catch ( e : IllegalArgumentException )
				{
					e.message = this + ".add() fails. " + e.message;
					_logger.error( e.message );
					throw( e );
				}
			}
		}

		/**
		 * Verify that the passed-in object type match the current 
		 * container element's type. 
		 * 
		 * @return  <code>true</code> if the object is elligible for this
		 * 			container, either <code>false</code>.
		 */
		public function matchType( o : * ) : Boolean
		{
			return o is _cType || o == null;
		}

		/**
		 * Return the class type of elements in this container.
		 * <p>
		 * An untyped container returns <code>null</code>, as the
		 * wildcard type (<code>*</code>) is not a <code>Class</code>
		 * and <code>Object</code> class doesn't fit for primitive types.
		 * </p>
		 * @return <code>Class</code> type of the container's elements
		 */
		public function getType() : Class
		{
			return _cType;
		}

		/**
		 * Returns <code>true</code> if this container perform a verification
		 * of the type of elements.
		 * 
		 * @return  <code>true</code> if this container perform a verification
		 * 			of the type of elements.
		 */
		public function isTyped() : Boolean
		{
			return _cType != null;
		}

		/**
		 * @copy com.bourre.events.Broadcaster#addEventListener()
		 */
		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			return _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
		}

		/**
		 * @copy com.bourre.events.Broadcaster#removeEventListener()
		 */
		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			return _oEB.removeEventListener( type, listener );
		}

		/**
		 * @copy com.bourre.events.Broadcaster#addListener()
		 */
		public function addListener( listener : LocatorListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}

		/**
		 * @copy com.bourre.events.Broadcaster#removeListener()
		 */
		public function removeListener( listener : LocatorListener ) : Boolean
		{
			return _oEB.removeListener( listener );
		}

		/**
		 * Returns an <code>Array</code> view of the keys contained in this locator.
		 *
		 * @return an array view of the keys contained in this locator
		 */
		public function getKeys() : Array
		{
			return _m.getKeys( );
		}

		/**
		 * Returns an <code>Array</code> view of the values contained in this locator.
		 *
		 * @return an array view of the values contained in this locator
		 */
		public function getValues() : Array
		{
			return _m.getValues( );
		}
		
		/**
		 * Returns a collection of registered values depending of passed-in 
		 * value <code>type</code>.
		 * 
		 * @param	type	Class type filter
		 */
		protected function getTypedValues( type : Class = null ) : Array
		{
			var a : Array = new Array( );
			
			if( type != null )
			{
				for each (var value : * in getValues( ) )
				{
					if( value is type ) a.push( value );
				}
			}
			else return getValues( );
			
			return a;
		}

		/**
		 * Takes all values of a Locator and pass them one by one as arguments
		 * to a method of an object.
		 * It's exactly the same concept as batch processing in audio or video
		 * software, when you choose to run the same actions on a group of files.
		 * <p>
		 * Basical example which sets _alpha value to .4 and scale to 50
		 * on all MovieClips nested in the Locator instance:
		 * </p>
		 * @example
		 * <listing>
		 * 
		 * function changeAlpha( mc : MovieClip, a : Number, s : Number )
		 * {
		 *      mc._alpha = a;
		 *      mc._xscale = mc._yscale = s;
		 * }
		 *
		 * locator.batchOnAll( changeAlpha, .4, 50 );
		 * </listing>
		 *
		 * @param	f		function to execute on each value stored in the locator.
		 * @param 	args	additionnal parameters.
		 */
		public function batchOnAll( f : Function, ...args ) : void
		{
			batch.apply( this, (args.length > 0 ) ? [ getValues(), f ].concat( args ) : [ getValues(), f ] );		}
		
		/**
		 * Takes values by type in Locator and pass them one by one as arguments
		 * to a method of an object.
		 * It's exactly the same concept as batch processing in audio or video
		 * software, when you choose to run the same actions on a group of files.
		 * <p>
		 * Basical example which sets _alpha value to .4 and scale to 50
		 * on all MovieClips nested in the Locator instance:
		 * </p>
		 * @example
		 * <listing>
		 * 
		 * function changeAlpha( mc : MovieClip, a : Number, s : Number )
		 * {
		 *      mc._alpha = a;
		 *      mc._xscale = mc._yscale = s;
		 * }
		 *
		 * locator.batchOnType( MovieClip, changeAlpha, .4, 50 );
		 * </listing>
		 * 
		 * @param	type	Value type filter.
		 * @param	f		function to execute on each value stored in the locator.
		 * @param 	args	additionnal parameters.
		 */
		public function batchOnType( type : Class, f : Function, ...args ) : void
		{
			batch.apply( this, (args.length > 0 ) ? [ getTypedValues( type ), f ].concat( args ) : [ getTypedValues( type ), f ] );
		}
		
		/** @private */
		protected function batch( collection : Array, f : Function, ...args ) : void
		{
			var l : int = collection.length;
			for( var i : int; i < l ; ++i ) f.apply( null, (args.length > 0 ) ? [ collection[i] ].concat( args ) : [ collection[i] ] );
		}
		
		/**
		 * Takes all values of a Locator and call on each value the method name
		 * passed as 1st argument.
		 * <p>
		 * Basical example which plays all MovieClips from frame 10.
		 * </p>
		 * @example
		 * <listing>
		 *
		 * locator.callOnAll( "gotoAndPlay", 10 );
		 * </listing>
		 *
		 * @param	methodName	method name to call on each value stored in the locator.
		 * @param 	args		additionnal parameters.
		 */
		public function callOnAll( methodName : String, ...args ) : void
		{
			call.apply( this, (args.length > 0 ) ? [ getValues(), methodName ].concat( args ) : [ getValues(), methodName ] );
		}
		
		/**
		 * Takes values by type in Locator and call on each value the method name
		 * passed as 1st argument.
		 * <p>
		 * Basical example which plays all MovieClips from frame 10.
		 * </p>
		 * @example
		 * <listing>
		 *
		 * locator.callOnType( MovieClip, "gotoAndPlay", 10 );
		 * </listing>
		 *
		 * @param	type		Value type filter.		 * @param	methodName	method name to call on each value.
		 * @param 	args		additionnal parameters.
		 */
		public function callOnType( type : Class, methodName : String, ...args ) : void
		{
			call.apply( this, (args.length > 0 ) ? [ getTypedValues( type ), methodName ].concat( args ) : [ getTypedValues( type ), methodName ] );
		}
		
		/** @private */
		protected function call( collection : Array, methodName : String, ...args ) : void
		{
			var l : int = collection.length;
			for( var i : int; i < l ; ++i )
			{
				var target : Object = collection[i];
				if ( target.hasOwnProperty( methodName ) && target[ methodName ] is Function )
				{
					(target[ methodName ]).apply( null, args );
				} 
				else
				{
					var msg : String;
					msg = this + ".callMethodOnAllValues() failed. " + getQualifiedClassName( target ) + "' class doesn't implement '" + methodName + "'";
					PalmerDebug.ERROR( msg );
					throw( new UnsupportedOperationException( msg ) );
				}
			}
		}
		
		/**
		 * Returns the string representation of this instance.
		 * 
		 * @return the string representation of this instance
		 */
		public function toString() : String
		{
			var hasType : Boolean = getType( ) != null;
			var parameter : String = "";

			if ( hasType )
			{
				parameter = getType( ).toString( );
				parameter = "<" + parameter.substr( 7, parameter.length - 8 ) + ">";
			}

			return PalmerStringifier.stringify( this ) + parameter;
		}
	}}