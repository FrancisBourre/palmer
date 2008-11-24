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
package com.bourre.transitions
{
	import com.bourre.events.BasicEvent;
	import com.bourre.log.PalmerStringifier;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;	

	/**
	 * <code>FPSBeacon</code> provides tick to its listeners based
	 * on the native <code>ENTER_FRAME</code> event. A <code>Shape</code>
	 * object is instanciated internally to provide this callback. By the
	 * way, the minimum time step for this beacon is subject to the flash
	 * player restrictions (playing in a browser or in a stand-alone player
	 * for example).
	 * <p>
	 * The <code>FPSBeacon</code> provides an access to a global instance
	 * of the class, concret <code>TickListener</code> may uses that instance
	 * by default when starting or stopping their animations.
	 * </p>
	 * @author	Cédric Néhémie
	 * @see		TickBeacon
	 */
	public class FPSBeacon 
		implements TickBeacon
	{
		static private var _oI 			: FPSBeacon;
		protected const tickEventType 	: String = TickEvent.TICK;

		/**
		 * Provides an access to a global instance of the 
		 * <code>FPSBeacon</code> class. That doesn't mean
		 * that the FPSBeacon class is a singleton, it simplify
		 * the usage of that beacon into concret <code>TickListener</code>
		 * implementation, which would register to a FPSBeacon instance.
		 * 
		 * @return a global instance of the <code>FPSBeacon</code> class
		 */
		static public function getInstance() : FPSBeacon
		{
			if ( !(FPSBeacon._oI is FPSBeacon) ) FPSBeacon._oI = new FPSBeacon();
			return FPSBeacon._oI;
		}
		
		/**
		 * Stops and the delete the current global instance
		 * of the <code>FPSBeacon</code> class.
		 */
		static public function release () : void
		{
			FPSBeacon._oI.stop();
			FPSBeacon._oI = null;
		}

		protected const _oShape : Shape = new Shape(); 
		protected var _oED 		: EventDispatcher;
		
		/**
		 * Creates a new <code>FPSBeacon</code>.
		 */
		public function FPSBeacon ()
		{
			_oED = new EventDispatcher();
		}

		/**
		 * Starts this beacon.
		 */
		public function start() : void
		{
			if( !isPlaying() ) _oShape.addEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}

		/**
		 * Stops this beacon.
		 */	
		public function stop() : void
		{
			if( isPlaying() ) _oShape.removeEventListener( Event.ENTER_FRAME, enterFrameHandler );
		}

		/**
		 * Returns <code>true</code> if this beacon is currently running..
		 * 
		 * @return	<code>true</code> if this beacon is currently running
		 */		
		public function isPlaying() : Boolean
		{
			return _oShape.hasEventListener( Event.ENTER_FRAME );
		}
		
		/**
		 * Adds the passed-in <code>listener</code> as listener for
		 * this <code>TickBeacon</code>. If the passed-in listener
		 * is the first listener added to this beacon, the beacon
		 * will be automatically started.
		 * 
		 * @param	listener	tick listener to be added
		 */
		public function addTickListener( listener : TickListener ) : void
		{
			if( !_oED.hasEventListener( tickEventType ) ) start();
			_oED.addEventListener( tickEventType, listener.onTick, false, 0, true );
		}
		
		/**
		 * Removes the passed-in <code>listener</code> as listener 
		 * for this <code>TickBeacon</code>. If the passed-in listener
		 * is the last listener registered to this beacon, the beacon
		 * will be automatically stopped.
		 * 
		 * @param	listener	tick listener to be removed
		 */
		public function removeTickListener( listener : TickListener ) : void
		{
			_oED.removeEventListener( tickEventType, listener.onTick );
			if( !_oED.hasEventListener( tickEventType ) ) stop();
		}

		/**
		 * Returns the string representation of this object.
		 * 
		 * @return	the string representation of this object.
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}
		
		/**
		 * Handles the <code>ENTER_FRAME</code> from the internal
		 * <code>Shape</code> object, and dispatches <code>onTick</code>
		 * event to each listener.
		 * 
		 * @param	e	event dispatched by the Shape object property
		 */
		protected function enterFrameHandler ( e : Event = null ) : void
		{
			var evt : BasicEvent = new BasicEvent( tickEventType, this );
			_oED.dispatchEvent( evt );
		}
	}
}