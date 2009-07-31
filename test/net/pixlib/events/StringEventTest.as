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

	public class StringEventTest 
		extends TestCase
	{
		protected var _s : StringEvent;
		protected var _o : Object;

		public override function setUp() : void
		{
			_o = new Object( ) ;
			_s = new StringEvent( "type", _o, "value" );
		}

		public function testConstruct() : void
		{
			assertNotNull( "StringEvent constructor returns null", _s );
		}

		public function testGetString() : void
		{
			assertEquals( "StringEvent getter doesn't return value passed to constructor", _s.getString( ), "value" );
		}
	}
}