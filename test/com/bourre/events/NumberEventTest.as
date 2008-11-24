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

	import com.bourre.events.NumberEvent;	

	public class NumberEventTest 
		extends TestCase
	{
		protected var _o : Object;
		protected var _e : NumberEvent;

		public override function setUp() : void
		{
			_o = new Object();
			_e = new NumberEvent( "type", _o, 5 ) ;
		}

		public function testConstruct() : void
		{
			assertNotNull( "NumberEvent constructor returns null", _o );
		}

		public function testGetNumber() : void
		{
			assertEquals( "NumberEvent getter doesn't return value passed to constructor", _e.getNumber( ), 5 ); 
		}
	}
}