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
package com.bourre.events
{
	import com.bourre.log.PalmerStringifier;		

	/**
	 * The <code>DynBasicEvent</code> class extends the 
	 * <code>BasicEvent</code> class and make it dynamic.
	 * <p>
	 * The <code>DynBasicEvent</code> class is used by 
	 * the <code>EventBroadcaster.dispatchEvent</code>
	 * function, which dispatch event using anonymous object,
	 * the event object is then decorated with the object
	 * properties and finally broadcasted as any other event
	 * object. 
	 * </p>
	 * @author 	Francis Bourre
	 * @see		BasicEvent
	 * @see		EventBroadcaster#dispatchEvent()
	 */
	public dynamic class DynBasicEvent extends BasicEvent
	{
		/**
		 * Creates a new <code>DynBasicEvent</code> event for the
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
		 */
		public function DynBasicEvent( type : String, target : Object = null, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, target, bubbles, cancelable );
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