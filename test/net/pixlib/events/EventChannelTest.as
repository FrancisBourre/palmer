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

	import net.pixlib.log.PalmerDebug;

	import flash.utils.getQualifiedClassName;

	/**
	 * @author Francis Bourre
	 */
	public class EventChannelTest 
		extends TestCase
	{
		public function testConstruct() : void
		{
			assertNotNull( "EventChannel constructor returns null", PalmerDebug.CHANNEL );
		}
		
		public function testValue() : void
		{
			assertEquals( "EventChannel instance doesn't return expected String value", PalmerDebug.CHANNEL.toString(), getQualifiedClassName(PalmerDebug.CHANNEL) );
		}
	}
}