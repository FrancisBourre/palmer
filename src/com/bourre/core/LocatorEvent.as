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
 
package com.bourre.core 
{
	import com.bourre.core.Locator;
	import com.bourre.events.BasicEvent;
	import com.bourre.log.PalmerStringifier;
	
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;		

	/**
	 * The LocatorEvent class represents the event object passed 
	 * to the event listener for <code>Locator</code> events.
	 * 
	 * @author Romain Ecarnot
	 * 
	 * @see com.bourre.core.Locator	 * @see LocatorListener
	 */
	public class LocatorEvent extends BasicEvent 
	{
		//--------------------------------------------------------------------
		// Events
		//--------------------------------------------------------------------
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onRegisterObject</code> event.
		 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>type</code></td>
	     *     	<td>Dispatched event type</td>
	     *     </tr>
	     *     
	     *     <tr><th>Method</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>getLocator()</code>
	     *     	</td><td>The Locator owner</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getID()</code>
	     *     	</td><td>The object identifier in use</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getObject()</code>
	     *     	</td><td>The object registered in locator</td>
	     *     </tr>
	     * </table>
	     *  
		 * @eventType onRegisterObject
		 */			
		public static const onRegisterObjectEVENT : String = "onRegisterObject";
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onUnregisterObject</code> event.
		 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>type</code></td>
	     *     	<td>Dispatched event type</td>
	     *     </tr>
	     *     
	     *     <tr><th>Method</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>getLocator()</code>
	     *     	</td><td>The Locator owner</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getID()</code>
	     *     	</td><td>The object identifier in use</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getObject()</code>
	     *     	</td><td>Not available in this case</td>
	     *     </tr>
	     * </table>
	     * 
		 * @eventType onUnregisterObject
		 */	
		public static const onUnregisterObjectEVENT : String = "onUnregisterObject";
		
		
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private var _sID : String;		private var _o : Object;
		
				
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates a new <code>LocatorEvent</code> object.
		 * 
		 * @param	type		Name of the event type
		 * @param	locator		Locator owner
		 * @param	id			Registration ID
		 */		
		public function LocatorEvent( type : String, locator : Locator, id : String, o : Object = null )
		{
			super( type, locator );
			
			_sID = id;
			_o = o;
		}
		
		/**
		 * Returns the Locator object carried by this event.
		 * 
		 * @return	The Locator object carried by this event.
		 */
		public function getLocator(  ) : Locator
		{
			return getTarget( ) as Locator;	
		}
		
		/**
		 * Returns the identifier value carried by this event.
		 * 
		 * @return	The identifier value carried by this event.
		 */
		public function getID(  ) : String
		{
			return _sID;
		}
		
		/**
		 * Returns the object carried by this event.
		 * 
		 * @return	If event type is <code>onRegisterObject</code>, returns 
		 * 			the registered object in locator.<br />
		 * 			If event type is <code>onUnregisterObject</code> returns 
		 * 			<code>null</code>
		 */
		public function getObject() : Object
		{
			return _o;
		}
		
		/**
		 * Clone the event.
		 * 
		 * @return	A cloned event
		 */
		override public function clone() : Event
		{
			return new LocatorEvent( getType(), getLocator(), getID() );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function toString() : String
		{
			return PalmerStringifier.stringify( this ) + 
				"<" + getQualifiedClassName( getLocator() ) + ">." + 
				getType() + "(" + getID() + ")";
		}
	}
}
