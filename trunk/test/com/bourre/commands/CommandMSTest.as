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
	import flexunit.framework.TestCase;

	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;

	/**
	 * @author Cédric Néhémie
	 */
	public class CommandMSTest 
		extends TestCase
	{
		protected var _oCMS : CommandMS;
		protected var _oC : MockCommand;

		public override function setUp() : void
		{
			_oCMS = new CommandMS( );
			_oC = new MockCommand( );
		} 

		public function testConstruct() : void
		{
			assertNotNull( "CommandMS constructor return null - test1 failed", _oCMS );
		}

		public function testPushAndRemove() : void
		{
			var sn : String = _oCMS.push( _oC, 50 );
			
			assertNotNull( "CommandMS.push() return null as key of the command - test1 failed", sn );
			assertEquals( "CommandMS.push() haven't modify the length - test2 failed", 1, _oCMS.getLength( ) );
			
			_oCMS.pushWithName( _oC, 50, sn );		
			assertEquals( "CommandMS.pushWithName() have modify the length when replacing a command - test3 failed", 1, _oCMS.getLength( ) );
			
			_oCMS.push( _oC, 50 );
			assertEquals( "CommandMS.push() haven't modify the length - test4 failed", 2, _oCMS.getLength( ) );	
			
			_oCMS.removeWithName( sn );
			assertEquals( "CommandMS.removeWithName() haven't modify the length - test5 failed", 1, _oCMS.getLength( ) );	
			
			_oCMS.remove( _oC );
			assertEquals( "CommandMS.remove() haven't modify the length - test6 failed", 0, _oCMS.getLength( ) );	
			
			_oCMS.push( _oC, 50 );
			_oCMS.push( _oC, 50 );	
			_oCMS.push( _oC, 50 );
			assertEquals( "CommandMS.push() haven't modify the length - test7 failed", 3, _oCMS.getLength( ) );	
			_oCMS.removeAll( );
			assertEquals( "CommandMS.removeAll() haven't modify the length - test8 failed", 0, _oCMS.getLength( ) );				
		}

		public function testRun() : void
		{		
			_oCMS.push( _oC, 50 );
			var o : Timer = new Timer( 600, 1 );
			o.addEventListener( TimerEvent.TIMER_COMPLETE, addAsync( aSyncRunCallBack, 1000, 3 ) );
			o.start( );
		}

		public function testDelay() : void
		{
			_oCMS.delay( _oC, 500 );
			
			var o : Timer = new Timer( 600, 1 );
			o.addEventListener( TimerEvent.TIMER_COMPLETE, addAsync( aSyncRunCallBack, 1000, 1 ) );
			o.start( );
		}

		public function aSyncRunCallBack( e : Event, min : Number ) : void
		{			
			assertTrue( "Command haven't been called by the CommandMS - test1 failed", _oC.called );
			assertTrue( "Command haven't been called the right number of times", _oC.callCount >= min );
		}
	}
}