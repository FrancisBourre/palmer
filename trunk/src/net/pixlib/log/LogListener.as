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
package net.pixlib.log 
{
	import flash.events.Event;

	/**
	 * The LogListener must be implemented by all objects which want to listen 
	 * to Logging API events, like logging console.
	 * 
	 * @see	net.pixlib.log.layout.AirLoggerLayout
	 * @see net.pixlib.log.layout.SOSLayout
	 * @see net.pixlib.log.layout.FlashInspectorLayout
	 * @see net.pixlib.log.layout.FirebugLayout	 * @see net.pixlib.log.layout.DeMonsterDebuggerLayout	 * 
	 * @author Francis Bourre
	 */
	public interface LogListener 
	{
		/**
		 * Triggered when a Log event is broadcasted by the Logging API.
		 * 
		 * @param	e	LogEvent event
		 * 
		 * @see	Logger	
		 */
		function onLog( e : LogEvent ) : void;
		
		/**
		 * Triggered when a clear event is broadcasted by the Logging API.
		 * 
		 * @param	e	Event event
		 * 
		 * @see	Logger	
		 */
		function onClear( e : Event = null ) : void;
	}
}