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
	 * Encapsulate a process as an object.
	 * <p>
	 * Command dispatchs an <code>onCommandEnd</code> event at the end of the process.
	 * </p>
	 * @author 	Francis Bourre
	 * @see		Runnable
	 */
	public interface Command
		extends Runnable
	{
		/**
		 * Execute a request.
		 * <p>
		 * If execution can't be performed, the command must throw an error.
		 * </p> 
		 * @param	e	An event that will contain data to help command execution. 
		 * @throws 	<code>UnreachableDataException</code> — Sometimes commands use event 
		 * argument as data container to help process execution. In this case the event 
		 * must transport expected data.
		 */
		function execute( e : Event = null ) : void;
		
		/**
		 * Fires <code>onCommandEnd</code> event to each command listener when
		 * process is over. 
		 */
		function fireCommandEndEvent() : void;
		
		/**
		 * Adds a listener that will be notified about end process.
		 * <p>
		 * The <code>addListener</code> method supports custom arguments
		 * provided by <code>EventBroadcaster.addEventListener()</code> method.
		 * </p> 
		 * @param	listener	listener that will receive events
		 * @param	rest		optional arguments
		 * @return	<code>true</code> if the listener has been added
		 * @see		net.pixlib.events.EventBroadcaster#addEventListener()
		 * 			EventBroadcaster.addEventListener() documentation
		 */
		function addCommandListener( listener : CommandListener, ... rest ) : Boolean;
		
		/**
		 * Removes listener from receiving any end process information.
		 * 
		 * @param	listener	listener to remove
		 * @return	<code>true</code> if the listener has been removed
		 * @see		net.pixlib.events.EventBroadcaster#addEventListener()
		 * 			EventBroadcaster.addEventListener() documentation
		 */
		function removeCommandListener( listener : CommandListener ) : Boolean;
	}
}