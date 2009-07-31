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
	import flash.events.Event;

	/**
	 * @author Cédric Néhémie
	 */
	public class MockCommand 
		extends AbstractCommand
	{
		public var called 		: Boolean;
		public var callCount 	: Number;
		public var event 		: Event;
		
		public function MockCommand ()
		{
			callCount = 0;
			called = false;
		}
		
		public function isRegistered ( o : CommandListener ) : Boolean
		{
			return _oEB.isRegistered( o,  AbstractCommand.onCommandEndEVENT );
		}
		
		override public function execute( e : Event = null ) : void
		{
			called = true;
			event = e;
			callCount++;

			fireCommandEndEvent();
		}
	}
}