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
package net.pixlib.services 
{
	import net.pixlib.collections.Collection;
	import net.pixlib.commands.Command;
	
	import flash.events.Event;	
	
	/**
	 * @author Francis Bourre
	 */
	public interface Service 
		extends Command
	{
		function setResult( result : Object ) : void;
		function getResult() : Object;
		function addServiceListener( listener : ServiceListener ) : Boolean;
		function removeServiceListener( listener : ServiceListener ) : Boolean;
		function getServiceListener() : Collection;
		function setArguments( ... rest ) : void;
		function getArguments() : Object;
		function fireResult( e : Event = null ) : void;
		function fireError( e : Event = null ) : void;
		function release() : void;

		function addEventListener( type : String, listener : Object, ... rest ) : Boolean;
		function removeEventListener( type : String, listener : Object ) : Boolean;
	}}