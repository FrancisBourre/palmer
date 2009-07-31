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
package net.pixlib.utils 
{
	import flexunit.framework.TestCase;

	import net.pixlib.commands.Runnable;

	/**
	 * @author Cedric Nehemie
	 */
	public class ClassUtilsTest 
		extends TestCase 
	{
		public function ClassUtilsTest (methodName : String = null)
		{
			super( methodName );
		}
		
		public function testInherit () : void
		{
			assertTrue( "ClassUtils.inherit() don't return true for MockChild -> MockInterface", 
						ClassUtils.inherit( MockFailChild, MockInterface ) );
						
			assertTrue( "ClassUtils.inherit() don't return true for MockChild -> MockParent", 
						ClassUtils.inherit( MockFailChild, MockParent ) );
						
			assertFalse( "ClassUtils.inherit() don't return false for Runnable -> MockChild", 
						 ClassUtils.inherit( Runnable, MockFailChild ) );
		}
	}
}
