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

	import com.bourre.events.BooleanEvent;

	public class BooleanEventTest 
		extends TestCase
	{
		protected var _o : Object ;
		protected var _e : BooleanEvent ;

		public override function setUp() : void
		{
			_o = new Object();
			_e = new BooleanEvent( "blabla", _o, true );			
		}

		public function testConstruct() : void
		{
			assertNotNull( "BooleanEvent constructor returns null", _e );
		}

		public function testGetBoolean() : void
		{
			assertEquals( "BooleanEvent getter doesn't return the same value given to constructor", _e.getBoolean(), true );
		}
	}
}