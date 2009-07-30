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
package com.bourre.model 
{
	import com.bourre.plugin.Plugin;

	import flash.events.Event;

	/**	 * Defines basic rules for implemented <code>Model</code>
	 * 
	 * @author Francis Bourre	 * @author Romain Ecarnot	 */	public interface Model 
	{
		/**
		 * Returns model identifier.
		 * 
		 * @return the model identifier.
		 */
		function getName() : String;
		
		/**
		 * Sets the model identifer.
		 * 
		 * <p>Model is automatically registred into <code>ModelLocator</code> 
		 * locator.</p>
		 * @param	name	New model identifier
		 * 
		 * @see ModelLocator
		 */
		function setName( name : String ) : void;
		
		/**
		 * Returns view <code>Plugin</code> owner.
		 * 
		 * @return the view <code>Plugin</code> owner.
		 */
		function getOwner() : Plugin;
		
		/**
		 * Sets the <code>Plugin</code> owner of this view.
		 * 
		 * <p>if owner is <code>null</code>, use <code>NullPlugin</code> 
		 * instance as default owner.</p>
		 * 
		 * @param	owner	<code>Plugin</code> instance
		 */
		function setOwner( owner : Plugin ) : void;
		
		/**
		 * Broascasts passed-in event to all view listeners.
		 * 
		 * @param e	Event to dispatch
		 */
		function notifyChanged( e : Event ) : void;
		
		/**
		 * @copy com.bourre.events.EventBroadcaster#addListener
		 */
		function addListener( listener : ModelListener ) : Boolean;
		
		/**
		 * @copy com.bourre.events.EventBroadcaster#removeListener
		 */
		function removeListener( listener : ModelListener ) : Boolean;
		
		/**
		 * @copy com.bourre.events.EventBroadcaster#addEventListener
		 */
		function addEventListener( type : String, listener : Object, ... rest ) : Boolean;
		
		/**
		 * @copy com.bourre.events.EventBroadcaster#removeEventListener
		 */
		function removeEventListener( type : String, listener : Object ) : Boolean;
		
		/**
		 * Releases model.
		 */
		function release() : void
		
		/**
		 * Returns string representation of instance.
		 * 
		 * @return the string representation of instance.
		 */
		function toString() : String;
	}}