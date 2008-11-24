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

	/**
	 * @author Cédric Néhémie
	 */
	public class AbstractCommandTest 
		extends TestCase
	{
		private var _c : MockCommand;

		public override function setUp () : void
		{
			_c = new MockCommand();
		}
		
		public function testConstruct () : void
		{
			assertNotNull ( "MockCommand constructor returns null - test1 failed", _c );
		}
		
		public function testListenerRegister () : void
		{
			var listener : MockCommandListener = new MockCommandListener();
			
			_c.addCommandListener( listener );			
			assertTrue ( _c + ".addCommandListener failed to add the mock as listener", _c.isRegistered( listener ) );
			
			_c.execute();			
			assertTrue ( listener + ".onCommandEnd hasn't been called by " + _c + ".execute()", _c.called );
			
			_c.removeCommandListener( listener );
			assertFalse ( _c + ".removeCommandListener failed to remove the mock from listeners", _c.isRegistered( listener ) );
		}
	}
}