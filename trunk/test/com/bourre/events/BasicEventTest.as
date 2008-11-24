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
	import flexunit.framework.TestCase;

	public class BasicEventTest 
		extends TestCase
	{
		protected var _o 	: Object;
		protected var _o2 	: Object;
		protected var _e 	: BasicEvent;

		public override function setUp() : void
		{
			_o = new Object();
			_o2 = new Object();
			_e = new BasicEvent( "type", _o );
		}

		public function testConstruct() : void
		{
			assertNotNull( "BasicEvent constructor returns null", _e );
		}

		public function testGetSetType() : void
		{
			assertEquals( "BasicEvent.type doesn't return the same value as given to constructor", _e.type, "type" );
			assertTrue( "BasicEvent.type doesn't return the String type", _e.type is String );
			
			_e.type = "newType" ;
			assertEquals( "BasicEvent.type doesn't set the right value", _e.type, "newType" );
			assertEquals( "BasicEvent.getType doesn't return the right value", _e.getType( ), "newType" );
			assertTrue( "BasicEvent type getter doesn't return the String type", _e.getType( ) is String );
			
			_e.setType( "anotherType" );
			assertEquals( "BasicEvent.setType doesn't set the right value", _e.type, "anotherType" );
		}

		public function testGetSetTarget() : void
		{
			assertStrictlyEquals( "BasicEvent.target doesn't return value passed to constructor", _e.target, _o );
			assertTrue( "BasicEvent.target doesn't return Object type", _e.target is Object );
			
			_e.target = _o2;
			assertStrictlyEquals( "BasicEvent.target doesn't set the right value", _e.target, _o2 );
									
			assertStrictlyEquals( "BasicEvent.getTarget doesn't return the right value", _e.getTarget( ), _o2 );
			assertTrue( "BasicEvent.getTarget doesn't return the Object type", _e.getTarget( ) is Object );
			
			_e.setTarget( _o );
			assertStrictlyEquals( "BasicEvent.setTarget doesn't set the right value", _e.target, _o );
		}
	}
}