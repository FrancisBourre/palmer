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
	import com.bourre.log.PalmerStringifier;

	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;	

	/**
	 * @author Cédric Néhémie
	 * @author Francis Bourre
	 */
	public class RealTimeBeacon 
		implements TickBeacon
	{
		static private var _oI : RealTimeBeacon;

		static public function getInstance() : RealTimeBeacon
        {
			if ( !(RealTimeBeacon._oI is RealTimeBeacon) ) RealTimeBeacon._oI = new RealTimeBeacon();
			return RealTimeBeacon._oI;
		}

		static public function release() : void
        {
			RealTimeBeacon._oI.stop();
			RealTimeBeacon._oI = null;
        }

		public var speedFactor : Number;
		public var smoothFactor : Number;
		public var maxBias : Number;

		protected const _oShape 	: Shape = new Shape();
		protected var _oED 			: EventDispatcher;
		protected var lastTime 		: Number;
		protected var pastValues 	: Vector.<Number>;
		protected var pastValuesSum : Number;

		protected const tickEventType : String = TickEvent.TICK;

		public function RealTimeBeacon( speedFactor : Number = 1, smoothFactor : Number = -1, maxBias : Number = -1 )
		{
			_oED = new EventDispatcher();

			this.speedFactor = speedFactor;
			this.smoothFactor = smoothFactor;
			this.maxBias = maxBias;
			this.pastValues = new Vector.<Number>();
			this.pastValuesSum = 0;			
			this.lastTime = getTimer();
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
		protected function enterFrameHandler( e : Event ) : void
		{
			var currentTime : Number = getTimer();
			var bias : Number = ( currentTime - lastTime ) * speedFactor;
			
			if( maxBias > 0 ) bias = restrict( bias );
			if( smoothFactor > 0 ) bias = smooth ( bias );
			
			_oED.dispatchEvent( new TickEvent( tickEventType, bias ) );
			
			lastTime = currentTime;
		}

		protected function smooth( n : Number ) : Number
		{
			pastValues.push( n );
			var l : Number = pastValues.length;
			if( l > smoothFactor )
			{
				pastValuesSum -= Number( pastValues.shift() );
				l--;
			}
			pastValuesSum += n;
			
			return pastValuesSum / l;
		}

		protected function restrict( n : Number ) : Number
		{
			var l : Number = maxBias * speedFactor;
			 return n > l ? l : n;
		}
	}
}