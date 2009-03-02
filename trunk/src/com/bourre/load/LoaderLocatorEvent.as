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
package com.bourre.load
{
	import com.bourre.core.Locator;
	import com.bourre.core.LocatorEvent;	

	/**
	 * The LoaderLocatorEvent class represents the event object passed 
	 * to the event listener for <code>LoaderLocator</code> events.
	 * 
	 * @author 	Romain Ecarnot
	 * 
	 * @see LoaderLocator
	 */
	public class LoaderLocatorEvent extends LocatorEvent 
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates a new <code>LoaderLocatorEvent</code> object.
		 * 
		 * @param	type			Name of the event type
		 * @param	name			Registration key
		 * @param	gl				Loader object
		 */	
		public function LoaderLocatorEvent( type : String, locator : Locator, name : String, loader : Loader ) 
		{
			super( type, locator, name, loader );
		}
		
		/**
		 * Returns the loader object carried by this event.
		 * 
		 * @return The loader object carried by this event.
		 */
		public function getLoader() : Loader
		{
			return getObject() as Loader;
		}
	}
}