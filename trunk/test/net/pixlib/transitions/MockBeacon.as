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
package net.pixlib.transitions
{
	import net.pixlib.events.BasicEvent;

	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	/**
	 * @author Cédric Néhémie
	 */
	public class MockBeacon 
		implements TickBeacon
	{
		private static var _oInstance : MockBeacon;
		private static const TICK : String = TickEvent.TICK;
		
		protected var _oShape 	: Shape; 
		protected var _bIP 		: Boolean;
		protected var _oED 		: EventDispatcher;
		
		public function MockBeacon ( o : ConstructorAccess )
		{
			_oShape = new Shape();
			_bIP = false;
			_oED = new EventDispatcher ();
		}
		public function start() : void
		{
			if( !_bIP )
			{
				_bIP = true;
				_oShape.addEventListener( Event.ENTER_FRAME, fireOnTickEvent );
			}
		}
		
		public function stop() : void
		{
			if( _bIP )
			{
				_bIP = false;
				_oShape.removeEventListener( Event.ENTER_FRAME, fireOnTickEvent );
			}
		}
		
		public function isPlaying() : Boolean
		{
			return _bIP;
		}
		
		public function addTickListener( listener : TickListener ) : void
		{
			_oED.addEventListener( TICK, listener.onTick, false, 0, true );
		}
		public function removeTickListener( listener : TickListener ) : void
		{
			_oED.removeEventListener( TICK, listener.onTick );
		}
		
		public function fireOnTickEvent ( e : Event ) : void
		{
			var evt : BasicEvent = new BasicEvent( TICK, this );
			_oED.dispatchEvent( evt );
		}
		
		public static function getInstance() : MockBeacon
		{
			if( !_oInstance ) _oInstance = new MockBeacon( new ConstructorAccess () );
			return _oInstance;
		}
	}
}
internal class ConstructorAccess {}