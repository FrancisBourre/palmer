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
		private var _aArgs2 : Array;		private var _aArgs3 : Array;
		
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
		
		public function testAddAndRemoveListenerObject() : void
		{
			assertTrue( "_oEB.addListener() doesn't return true with Object type listener.", _oEB.addListener( this ) );
			assertTrue( "EventBroadcaster.addListener() failed, TestCase instance isn't registered", _oEB.isRegistered( this ) );
			assertTrue( "_oEB.removeListener() doesn't return true with Function type listener.", _oEB.removeListener( this ) );
			assertFalse( "EventBroadcaster.removeListener() failed, TestCase instance still registered", _oEB.isRegistered( this ) );
		}
		
		public function testAddAndRemoveListenerFunction() : void
		{
			assertTrue( "_oEB.addListener() doesn't return true with Function type listener.", _oEB.addListener( onDelegateCallbackWithoutArgs ) );
			assertTrue( "EventBroadcaster.addListener() failed, TestCase.onDelegateCallbackWithoutArgs instance isn't registered", _oEB.isRegistered( onDelegateCallbackWithoutArgs ) );
			assertTrue( "_oEB.removeListener() doesn't return true with Function type listener.", _oEB.removeListener( onDelegateCallbackWithoutArgs ) );
			assertFalse( "EventBroadcaster.removeListener() failed, TestCase.onDelegateCallbackWithoutArgs instance still registered", _oEB.isRegistered( onDelegateCallbackWithoutArgs ) );
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
		
		public function testBroadcastToFunction() : void
		{
			_oEB.addListener( onDelegateCallbackWithoutArgs );
			
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
			_oEB.removeListener( onDelegateCallbackWithoutArgs );
			_initBroadcastTestConfig();
			_oEB.broadcastEvent( new Event( "onCallback1" ) );
			
			assertNull( "EventBroadcaster.removeListener() failed, EventBroadcaster.broadcastEvent callback happenned", _oEvent );
			
			//
			_oEB.addListener( onDelegateCallbackWithoutArgs );
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
			var e : Event = new Event( "onNoCallback" );
			
			assertTrue( "_oEB.addEventListener() doesn't return true with Function type listener.", _oEB.addEventListener( "onNoCallback", onDelegateCallbackWithoutArgs ) );			assertTrue( "_oEB.isRegistered() doesn't return true with Function type listener.", _oEB.isRegistered( onDelegateCallbackWithoutArgs, "onNoCallback" ) );
			
			_oEvent = null;
			_oEB.broadcastEvent( e );
			assertEquals( "EventBroadcaster.broadcastEvent() failed.", e, _oEvent );
			assertEquals( "Event type received mismatched with broadcasted one.", _oEvent.type, "onNoCallback" );
			
			assertTrue( "_oEB.removeEventListener() doesn't return true with Function type listener.", _oEB.removeEventListener( "onNoCallback", onDelegateCallbackWithoutArgs ));
			assertFalse( "_oEB.isRegistered() doesn't return false with Function type listener after remove.", _oEB.isRegistered( onDelegateCallbackWithoutArgs, "onNoCallback" ) );
			
			_oEvent = null;
			_oEB.broadcastEvent( e );
			assertNull( "EventBroadcaster.removeEventListener() failed with function", _oEvent );
			
			assertTrue( "_oEB.addEventListener() doesn't return true with Function type - after remove", _oEB.addEventListener( "onNoCallback", onDelegateCallbackWithoutArgs ) );
			
			_oEvent = null;
			_oEB.broadcastEvent( e );
			assertEquals( "EventBroadcaster.broadcastEvent() failed.", e, _oEvent );
			assertEquals( "Event type received mismatched with broadcasted one - after remove.", _oEvent.type, "onNoCallback" );
			assertFalse( "_oEB.isRegistered() doesn't return false with Function type listener not registered yet to a second event type.", _oEB.isRegistered( onDelegateCallbackWithoutArgs, "onNoCallback2" ) );
			assertTrue( "_oEB.addEventListener() doesn't return true with Function type listener registered to a second event type.", _oEB.addEventListener( "onNoCallback2", onDelegateCallbackWithoutArgs ) );
			assertTrue( "_oEB.isRegistered() doesn't return true with Function type listener registered to a second event type.", _oEB.isRegistered( onDelegateCallbackWithoutArgs, "onNoCallback" ) );
		}
		
		public function onDelegateCallbackWithoutArgs( e : Event ) : void
		{
			_oEvent = e;
		}
		
		public function testDelegateListenerWithArgs() : void
		{
			var e : Event = new Event( "onTestDelegateListenerWithArgs" );
			
			assertTrue( "_oEB.addEventListener() failed with Function type listener and args.", _oEB.addEventListener( "onTestDelegateListenerWithArgs", onDelegateCallbackWith2Args, 5, "hello" ) );
			assertTrue( "_oEB.isRegistered() doesn't return true with Function type listener and args.", _oEB.isRegistered( onDelegateCallbackWith2Args, "onTestDelegateListenerWithArgs" ) );

			_oEvent = null;
			_oEB.broadcastEvent( e );

			assertEquals( "EventBroadcaster.broadcastEvent() failed.", e, _oEvent );
			assertTrue( "2 args received by onDelegateCallbackWith2Args callback mismatch with registered one", argsMatch2(5, "hello") );
			
			
			assertTrue( "_oEB.removeEventListener() failed with Function type listener.", _oEB.removeEventListener( "onTestDelegateListenerWithArgs", onDelegateCallbackWith2Args ) );
			assertTrue( "_oEB.addEventListener() failed with Function type listener and args.", _oEB.addEventListener( "onTestDelegateListenerWithArgs", onDelegateCallbackWith3Args, 1, "world", true ) );
			
			_oEvent = null;
			_aArgs2 = null;			_aArgs3 = null;
			_oEB.addEventListener( "onTestDelegateListenerWithArgs", onDelegateCallbackWith2Args, 5, "hello" );
			_oEB.broadcastEvent( e );

			assertEquals( "EventBroadcaster.broadcastEvent() failed.", e, _oEvent );
			assertTrue( "2 args received by onDelegateCallbackWith2Args callback mismatch with registered one", argsMatch2(5, "hello") );
			assertTrue( "3 args received by onDelegateCallbackWith3Args callback mismatch with registered one", argsMatch3(1, "world",true) );
		}
		
		public function onDelegateCallbackWith2Args( e : Event, _n : int, s : String ) : void
		{
			_oEvent = e;
			_aArgs2 = [_n,s];
		}
		
		public function onDelegateCallbackWith3Args( e : Event, _n : int, s : String, b : Boolean ) : void
		{
			_oEvent = e;
			_aArgs3 = [_n,s,b];
		}
		
		public function argsMatch2( ...rest ) : Boolean
		{
			var l : int = rest.length;
			while(--l>-1) if (rest[l] != _aArgs2[l]) return false;
			return true;
		}
		
		public function argsMatch3( ...rest ) : Boolean
		{
			var l : int = rest.length;
			while(--l>-1) if (rest[l] != _aArgs3[l]) return false;
			return true;
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
		
		public function testListenerType() : void
		{
			_oEB.setListenerType( EventBroadcasterTest );
			assertTrue( "_oEB.addListener failed with EventBroadcasterTest instance.", _oEB.addListener( this ) );			assertTrue( "_oEB.addListener failed with Function type listener.", _oEB.addListener( onDelegateCallbackWithoutArgs ) );
			
			var b : Boolean = false;
			try
			{
				_oEB.addListener( {} );
				
			} catch ( e : Error )
			{
				b = true;
			}
			assertTrue( "EventBroadcaster listener type was set to 'EventBroadcasterTest' and EventBroadcaster.addListener( {} ) didn't throw an error", b );
			
			b = false;
			try
			{
				_oEB.setListenerType( Array );
				
			} catch ( e : Error )
			{
				b = true;
			}
			assertTrue( "EventBroadcaster listener type was set to 'Array' and EventBroadcaster didn't throw an error", b );
			
			_oEB.removeAllListeners();
			_oEB.setListenerType( Array );
			assertTrue( "_oEB.addListener failed with Array instance.", _oEB.addListener( [] ) );
		}
	}
}