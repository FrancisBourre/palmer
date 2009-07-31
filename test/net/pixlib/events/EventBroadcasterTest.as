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
package net.pixlib.events
{
	import flexunit.framework.TestCase;

	import net.pixlib.exceptions.UnsupportedOperationException;

	import flash.events.Event;

	/**
	 * @author Francis Bourre
	 */	public class EventBroadcasterTest 
		extends TestCase
	{	
		private var _oEB : EventBroadcaster;
		private var _oEvent : Event;
		private var _nCounter : int;
		
		public override function setUp() : void
		{
			_oEB = new EventBroadcaster();
			_initBroadcastTestConfig();
		}
		
		private function _initBroadcastTestConfig() : void
		{
			_oEvent = null;
		}
		
		public function onCallback( e : Event ) : void
		{
			//
		}
		
		public function testConstruct() : void
		{
			assertNotNull( "EventBroadcaster constructor returns null", new EventBroadcaster() );
		}
		
		public function testAddAndRemoveListener() : void
		{
			_oEB.addListener( this );
			assertTrue( "EventBroadcaster.addListener() failed, TestCase instance isn't registered", _oEB.isRegistered( this ) );
			_oEB.removeListener( this );
			assertFalse( "EventBroadcaster.removeListener() failed, TestCase instance still registered", _oEB.isRegistered( this ) );
		}
		
		public function testAddAndRemoveEventListenerObject() : void
		{
			assertTrue( "_oEB.addEventListener() doesn't return true", _oEB.addEventListener( "onCallback",  this ) );
			assertTrue( "EventBroadcaster.addEventListener() failed,  TestCase instance isn't registered", _oEB.isRegistered( this, "onCallback" ) );
			assertTrue( "_oEB.removeEventListener() doesn't return true", _oEB.removeEventListener( "onCallback",  this ) );
			assertFalse( "EventBroadcaster.removeEventListener() failed, TestCase instance still registered", _oEB.isRegistered( this, "onCallback" ) );
		}
		
		public function testRemoveAllListeners() : void
		{
			_oEB.addListener( this );
			_oEB.addListener( new Array() );
			assertTrue( "this TestCase instance isn't registered to EventBroadcaster instance", _oEB.isRegistered( this ) );
			_oEB.removeAllListeners();
			assertTrue( "EventBroadcaster.isEmpty() returns false after EventBroadcaster.removeAllListeners()", _oEB.isEmpty() );
		}
		
		public function testBroadcastToListener() : void
		{
			_oEB.addListener( this );
			
			//
			_oEB.broadcastEvent( new Event( "onCallback1" ) );
			
			assertNotNull( "EventBroadcaster.broadcastEvent() failed", _oEvent );
			assertEquals( "Event type received mismatched with broadcasted one", _oEvent.type, "onCallback1" );
			
			//
			_initBroadcastTestConfig();
			_oEB.broadcastEvent( new Event( "onCallback2" ) );
			
			assertNotNull( "EventBroadcaster.broadcastEvent() failed", _oEvent );
			assertEquals( "Event type received mismatched with broadcasted one", _oEvent.type, "onCallback2" );
			
			//
			_oEB.removeListener( this );
			_initBroadcastTestConfig();
			_oEB.broadcastEvent( new Event( "onCallback1" ) );
			
			assertNull( "EventBroadcaster.removeListener() failed, EventBroadcaster.broadcastEvent callback happenned", _oEvent );
			
			//
			_oEB.addListener( this );
			_oEB.removeAllListeners();
			_initBroadcastTestConfig();
			_oEB.broadcastEvent( new Event( "onCallback1" ) );
			
			assertNull( "EventBroadcaster.removeAllListeners() failed, EventBroadcaster.broadcastEvent callback happenned", _oEvent );
		}
		
		public function onCallback1( e : Event ) : void
		{
			_oEvent = e;
		}
		
		public function onCallback2( e : Event ) : void
		{
			_oEvent = e;
		}
		
		public function testBroadcastToEventListener() : void
		{
			_oEB.addEventListener( "onCallback1", this );
			
			//
			_oEB.broadcastEvent( new Event( "onCallback1" ) );
			
			assertNotNull( "EventBroadcaster.broadcastEvent() failed", _oEvent );
			assertEquals( "Event type received mismatched with broadcasted one", _oEvent.type, "onCallback1" );
			
			//
			_initBroadcastTestConfig();
			_oEB.broadcastEvent( new Event( "onCallback2" ) );
			
			assertNull( "EventBroadcaster.addEventListener() failed, EventBroadcaster.broadcastEvent wrong callback happenned", _oEvent );
			
			//
			_oEB.removeEventListener( "onCallback1", this );
			_initBroadcastTestConfig();
			_oEB.broadcastEvent( new Event( "onCallback1" ) );
			
			assertNull( "EventBroadcaster.removeEventListener() failed, EventBroadcaster.broadcastEvent callback happenned", _oEvent );
			
			//
			_oEB.addEventListener( "onCallback1", this );
			_oEB.removeListener( this );
			
			_initBroadcastTestConfig();
			_oEB.broadcastEvent( new Event( "onCallback1" ) );
			
			assertNull( "EventBroadcaster.removeListener() failed after EventBroadcaster.addEventListener(), EventBroadcaster.broadcastEvent callback happenned", _oEvent );
			
			//
			_oEB.addEventListener( "onCallback1", this );
			_oEB.removeAllListeners();
			
			_initBroadcastTestConfig();
			_oEB.broadcastEvent( new Event( "onCallback1" ) );
			
			assertNull( "EventBroadcaster.removeAllListeners() failed after EventBroadcaster.addEventListener(), EventBroadcaster.broadcastEvent callback happenned", _oEvent );
		}
		
		public function testBroadcastWith2Register() : void
		{
			_oEB.addEventListener( "onCallback3", this );
			_oEB.addListener( this );
			
			//
			_nCounter = 0;
			_initBroadcastTestConfig();
			_oEB.broadcastEvent( new Event( "onCallback3" ) );
			
			assertEquals( "Event type received mismatched with broadcasted one", _nCounter, 1 );
		}	
		
		public function onCallback3( e : Event ) : void
		{
			_nCounter++;
		}
		
		public function testDispatchEvent() : void
		{
			_oEB.addEventListener( "onCallback1", this );
			_oEB.dispatchEvent( {type: "onCallback1", prop:3} );
			
			assertNotNull( "EventBroadcaster.broadcastEvent() failed", _oEvent );
			assertEquals( "Event type received mismatched with broadcasted one", _oEvent.type, "onCallback1" );
			assertEquals( "Event dynamic property received mismatched with broadcasted one", _oEvent["prop"], 3 );
		}
		
		public function testDelegateListenerWithoutArgs() : void
		{
			assertTrue( "_oEB.addEventListener() doesn't return true with Function type", _oEB.addEventListener( "onNoCallback", onDelegateCallbackWithoutArgs ) );
			_oEB.broadcastEvent( new Event( "onNoCallback" ) );
			
			assertNotNull( "EventBroadcaster.broadcastEvent() failed", _oEvent );
			assertEquals( "Event type received mismatched with broadcasted one", _oEvent.type, "onNoCallback" );
			
			assertTrue( "_oEB.removeEventListener() doesn't return true with Function type", _oEB.removeEventListener( "onNoCallback", onDelegateCallbackWithoutArgs ));
			_oEvent = null;
			_oEB.broadcastEvent( new Event( "onNoCallback" ) );
			assertNull( "EventBroadcaster.removeEventListener() failed with function", _oEvent );
			
			assertTrue( "_oEB.addEventListener() doesn't return true with Function type - after remove", _oEB.addEventListener( "onNoCallback", onDelegateCallbackWithoutArgs ) );
			_oEB.broadcastEvent( new Event( "onNoCallback" ) );
			
			assertNotNull( "EventBroadcaster.broadcastEvent() failed - after remove", _oEvent );
			assertEquals( "Event type received mismatched with broadcasted one - after remove", _oEvent.type, "onNoCallback" );
			
			assertTrue( "_oEB.addEventListener() doesn't return true with Function type - after remove", _oEB.addEventListener( "onNoCallback2", onDelegateCallbackWithoutArgs ) );
		}
		
		public function onDelegateCallbackWithoutArgs( e : Event ) : void
		{
			_oEvent = e;
		}
		
		public function testDelegateListenerWithArgs() : void
		{
			_oEB.addEventListener( "onNoCallback", onDelegateCallbackWithArgs, 5, "hello" );
			_oEB.broadcastEvent( new Event( "onNoCallback" ) );
			
			assertNotNull( "EventBroadcaster.broadcastEvent() failed", _oEvent );
			assertEquals( "Event type received mismatched with broadcasted one", _oEvent.type, "onNoCallback" );
		}
		
		public function onDelegateCallbackWithArgs( e : Event, _n : int, s : String ) : void
		{
			_oEvent = e;
		}
		
		public function testAddEventListenerError() : void
		{
			var b : Boolean = false;
			
			try
			{
				_oEB.addEventListener( "onNoCallback", this );

			} catch ( e : UnsupportedOperationException )
			{
				b = true;
			}
			assertTrue( "No Callback was implemented in Testcase and EventBroadcaster.addEventListener() didn't throw an error", b );
		}
		
		public function testCallbackError() : void
		{
			_oEB.addListener( this );
			
			var b : Boolean = false;
			
			try
			{
				_oEB.broadcastEvent( new Event( "onNoCallback" ) );
				
			} catch ( e : UnsupportedOperationException )
			{
				b = true;
			}
			assertTrue( "No callback was implemented in Testcase and EventBroadcaster.broadcastEvent() didn't throw an error", b );
		}
	}
}