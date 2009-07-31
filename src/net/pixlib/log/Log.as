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
	import net.pixlib.events.EventChannel;	
	
	/**
	 * Logging interface.
	 * 
	 * @see PalmerDebug	 * 
	 * @author Francis Bourre	 */
	public interface Log 
	{
		/**
		 * Logs passed-in message with a log level defined  
		 * at 'debug' mode.
		 * 
		 * @param	o		Message to log
		 * @param	target	(optional) The target from where the log 
		 * 					is called 
		 */
		function debug ( o : *, target : Object = null ) : void;
		
		/**
		 * Logs passed-in message with a log level defined  
		 * at 'info' mode..
		 * 
		 * @param	o		Message to log
		 * @param	target	(optional) The target from where the log 
		 * 					is called 
		 */		function info ( o : *, target : Object = null ) : void;
		
		/**
		 * Logs passed-in message with a log level defined  
		 * at 'warn' mode..
		 * 
		 * @param	o		Message to log
		 * @param	target	(optional) The target from where the log 
		 * 					is called 
		 */		function warn ( o : *, target : Object = null ) : void;
		
		/**
		 * Logs passed-in message with a log level defined  
		 * at 'error' mode..
		 * 
		 * @param	o		Message to log
		 * @param	target	(optional) The target from where the log 
		 * 					is called 
		 */		function error ( o : *, target : Object = null ) : void;
		
		/**
		 * Logs passed-in message with a log level defined  
		 * at 'fatal' mode..
		 * 
		 * @param	o		Message to log
		 * @param	target	(optional) The target from where the log 
		 * 					is called 
		 */		function fatal ( o : *, target : Object = null ) : void;
		
		/**
		 * Clears Logging layout registered for this event channel.
		 */
		function clear( ) : void;
		
		/**
		 * Returns event channel used for communication.
		 */
		function getChannel() : EventChannel;
		
		/**
		 * Returns <code>true</code> if logging tunnel is opened.
		 */
		function isOn () : Boolean;
		
		/**
		 * Opens the logging tunnel.
		 */
		function on () : void;
		
		/**
		 * Closes the logging tunnel.
		 */
		function off () : void;
	}}