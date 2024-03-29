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
	import flexunit.framework.TestCase;

	import flash.events.Event;

	/**
	 * @author Francis Bourre
	 * @version 1.0
	 */
	public class DelegateTest 
		extends TestCase
	{
		private var _e : Event;
		private var _n : int;
		
		private var _arg1 : int;
		private var _arg2 : String;

		
		public override function setUp() : void
		{
			_e = null;
			_n = -1;
		}
		
		public function standardCallback( n : int ) : void
		{
			_n = n;
		}
		
		public function eventCallbackNoArgs( e : Event ) : void
		{
			_e = e;
		}
		
		public function callbackNoArgs() : void
		{
			_e = null;
		}
		
		public function eventCallbackArgs( e : Event, n : int ) : void
		{
			_e = e;
			_n = n;
		}
		
		public function testCreate() : void
		{
			var arg1 : int = 1;
			var arg2 : String = "a";
			var f : Function;
			f = Delegate.create( _methodDelegate );
			
			f( arg1, arg2 );
			assertEquals("f = Delegate.create( function, arg1, arg2 ) ; f() => function doesn't receive arg1 ", _arg1, 1);
			assertEquals("f = Delegate.create( function, arg1, arg2 ) ; f() => function doesn't receive arg2 ", _arg2, "a");
			
			_arg1 = 0;
			_arg2 = null;
			
			//
			f = Delegate.create( _methodDelegate );
			
			var bIsErrorCaught : Boolean = false;
			try
			{
				f( 127 );

			} catch ( e : ArgumentError )
			{
				bIsErrorCaught = true;
			}

			assertTrue( "f = Delegate.create( function, arg1 ) ; f() => function didn't catch the error", bIsErrorCaught );
			
			_arg1 = 0;
			_arg2 = null;
		}
		
		private function _methodDelegate( arg1:int, arg2:String ) : void
		{
			_arg1 = arg1;
			_arg2 = arg2;
		}		
		
		public function testConstruct() : void
		{
			assertNotNull( "Delegate constructor returns null", new Delegate( standardCallback, 0 ) );
		}
		
		public function testGetSetArguments() : void
		{
			var d : Delegate = new Delegate( _methodDelegate );
			assertTrue("Delegate.getArguments() doesn't return an Array ", d.getArguments() is Array );
			assertEquals("Delegate.getArguments() doesn't return the expected Array ", d.getArguments().length, 0 );
			d.setArguments("arg1","arg2");
			assertEquals("Delegate.getArguments() doesn't return the expected Array after Delegate.setArguments('arg1','arg2')", d.getArguments()[0], "arg1" );
			assertEquals("Delegate.getArguments() doesn't return the expected Array after Delegate.setArguments('arg1','arg2')", d.getArguments()[1], "arg2" );
			d.setArgumentsArray( new Array("argArray1","argArray2") );
			assertEquals("Delegate.getArguments() doesn't return the expected Array after Delegate.setArgumentsArray( new Array('argArray1','argArray2') )", d.getArguments()[0], "argArray1" );
			assertEquals("Delegate.getArguments() doesn't return the expected Array after Delegate.setArgumentsArray( new Array('argArray1','argArray2') )", d.getArguments()[1], "argArray2" );			
			d.addArguments("addArgs1","addArgs2");
			assertEquals("Delegate.getArguments() doesn't return the expected Array after Delegate.addArguments('addArgs1','addArgs2')", d.getArguments()[2], "addArgs1" );
			assertEquals("Delegate.getArguments() doesn't return the expected Array after Delegate.addArguments('addArgs1','addArgs2')", d.getArguments()[3], "addArgs2" );						
			d.addArgumentsArray( new Array("addArrayArg1","addArrayArg2") );
			assertEquals("Delegate.getArguments() doesn't return the expected Array after Delegate.addArgumentsArray('addArrayArg1','addArrayArg2')", d.getArguments()[4], "addArrayArg1" );
			assertEquals("Delegate.getArguments() doesn't return the expected Array after Delegate.addArgumentsArray('addArrayArg1','addArrayArg2')", d.getArguments()[5], "addArrayArg2" );									
		}
		
		public function testExecute() : void
		{
			var d : Delegate = new Delegate( standardCallback, 0 );
			d.execute();
			assertEquals( "Delegate.execute() failed", _n, 0 );
		}
		
		public function testExecuteWithoutArguments() : void
		{
			var d : Delegate = new Delegate( callbackNoArgs );
			_e = new Event("test" );
			d.execute();
			assertNull( "Delegate.execute() without arguments failed", _e );
		}
		
		public function testHandleEventWithoutArguments() : void
		{
			var d : Delegate = new Delegate( eventCallbackNoArgs );
			d.handleEvent( new Event("test") );
			assertNotNull( "Delegate.handleEvent() without arguments failed", _e );
		}
		
		public function testHandleEventWithArguments() : void
		{
			var d : Delegate = new Delegate( eventCallbackArgs, 1 );
			d.handleEvent( new Event("test") );
			assertNotNull( "Delegate.handleEvent() with arguments failed", _e );
			assertEquals( "Delegate.handleEvent() with arguments failed", _n, 1 );
		}
	}
}