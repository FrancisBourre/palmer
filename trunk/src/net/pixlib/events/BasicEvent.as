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
package net.pixlib.events
{
	import net.pixlib.log.PalmerStringifier;
	
	import flash.events.Event;	

	/**
	 * The <code>BasicEvent</code> class adds the ability for
	 * developpers to change the <code>type</code> and the 
	 * <code>target</code> of an event after its creation.
	 * <p>
	 * Target and type redefinition is useful when creating
	 * macro objects, which dispatch events, but according to
	 * their children event flow. The macro object may only 
	 * change event's type or target of the child event and
	 * then redispatch it to its own liteners. You could take
	 * a look to the <code>QueueLoader</code> class fo a concret 
	 * usage of this concept.
	 * </p> 
	 * @author 	Francis Bourre
	 * @see		net.pixlib.load.QueueLoader
	 */	
	public class BasicEvent extends Event
	{
		/**
		 * The source object of this event, redefined to provide write access
		 */
		protected var _oTarget : Object;
		/**
		 * The type of the event, redefined to provide write access
		 */
		protected var _sType : String;
		
		/**
		 * Creates a new <code>BasicEvent</code> event for the
		 * passed-in event type. The <code>target</code> is optional, 
		 * if the target is omitted and the event used in combination
		 * with the <code>EventBroadcaster</code> class, the event
		 * target will be set on the event broadcaster source.
		 * 
		 * @param	type		<code>String</code> name of the event
		 * @param	target		an object considered as source for this event
		 * @param 	bubbles		Determines whether the Event object participates 
		 * 						in the bubbling stage of the event flow
		 * @param 	cancelable	Determines whether the Event object can be canceled.
		 * 
		 * @see		EventBroadcaster#broadcastEvent() The EventBroadcaster.broadcastEvent() method
		 */
		public function BasicEvent( type : String, target : Object = null, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super ( type, bubbles, cancelable );
			
			_sType = type;
			_oTarget = target;
		}
		
		/**
		 * The type of this event
		 */
		override public function get type() : String
		{
			return _sType;
		}
		
		/**
		 * @private
		 */
		public function set type( en : String ) : void
		{
			_sType = en;
		}
		
		/**
		 * Defines the new event type for this event object.
		 * 
		 * @param	en	the new event name, or event type, as string
		 */
		public function setType( en : String ) : void
		{
			_sType = en;
		}
		
		/**
		 * Returns the type of this event, which generally correspond
		 * to the name of the called function on the listener.
		 * 
		 * @return	the type of this event
		 */
		public function getType() : String
		{
			return _sType;
		}
		
		/**
		 * The source object of this event
		 */
		override public function get target() : Object
		{ 
			return _oTarget; 
		}
		/**
		 * @private
		 */
		public function set target( oTarget : Object ) : void 
		{ 
			_oTarget = oTarget; 
		}
		
		/**
		 * Defines the new source object of this event.
		 *  
		 * @param	oTarget	the new source object of this event
		 */
		public function setTarget( oTarget : Object ) : void 
		{ 
			_oTarget = oTarget; 
		}
		
		/**
		 * Returns the current source of this event object.
		 * 
		 * @return	object source of this event
		 */
		public function getTarget() : Object
		{ 
			return _oTarget; 
		}
		
		/**
		 * Clone the event
		 * 
		 * @return	a clone of the event
		 */
		override public function clone() : Event
		{
			return new BasicEvent(type, target);
		}

		/**
		 * Returns the string representation of this instance.
		 * 
		 * @return the string representation of this instance
		 */
		override public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}
	}
}