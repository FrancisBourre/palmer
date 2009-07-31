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
package net.pixlib.view 
{
	import net.pixlib.model.ModelListener;
	import net.pixlib.plugin.Plugin;
	import net.pixlib.structures.Dimension;

	import flash.events.Event;
	import flash.geom.Point;

	/**	 * Defines basic rules for implemented <code>View</code>
	 * 
	 * @author Francis Bourre	 * @author Romain Ecarnot	 */	public interface View extends ModelListener
	{
		/**
		 * Returns view identifier.
		 * 
		 * @return the view identifier.
		 */
		function getName() : String;
		
		/**
		 * Sets the view identifer.
		 * 
		 * <p>View is automatically registred into <code>ViewLocator</code> 
		 * locator.</p>
		 * @param	name	New view identifier
		 * 
		 * @see ViewLocator
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
		 * Shows view.
		 */
		function show() : void;
		
		/**
		 * Hides view.
		 */
		function hide() : void;
		
		/**
		 * Returns <code>true</code> if view is visible.
		 * 
		 * @return <code>true</code> if view is visible.
		 */
		function isVisible() : Boolean;
		
		/**
		 * Returns view position.
		 * 
		 * @return the view position.
		 */
		function getPosition() : Point;
		
		/**
		 * Sets view position.
		 * 
		 * @param p	New view position
		 */
		function setPosition( p : Point ) : void;
		
		/**
		 * Returns view size.
		 * 
		 * @return the view size.
		 */
		function getSize () : Dimension;
		
		/**
		 * Sets the view size.
		 * 
		 * @param size New view size
		 */
		function setSize( size : Dimension ) : void;
		
		/**
		 * @copy net.pixlib.events.EventBroadcaster#addListener
		 */
		function addListener( listener : ViewListener ) : Boolean;
		
		/**
		 * @copy net.pixlib.events.EventBroadcaster#removeListener
		 */
		function removeListener( listener : ViewListener ) : Boolean;
		
		/**
		 * @copy net.pixlib.events.EventBroadcaster#addEventListener
		 */
		function addEventListener( type : String, listener : Object, ... rest ) : Boolean;
		
		/**
		 * @copy net.pixlib.events.EventBroadcaster#removeEventListener
		 */
		function removeEventListener( type : String, listener : Object ) : Boolean;
		
		/**
		 * Releases view.
		 */
		function release() : void
		
		/**
		 * Returns string representation of instance.
		 * 
		 * @return the string representation of instance.
		 */
		function toString() : String;	}}