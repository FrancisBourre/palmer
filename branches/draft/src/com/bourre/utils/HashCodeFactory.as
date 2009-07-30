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
package com.bourre.utils
{
	import flash.utils.Dictionary;
	
	/**
	 * The <code>HashCodeFactory</code> class provides convenient methods
	 * to emulate the behavior of the Java&trade; <code>Object.hashcode()</code>
	 * method. The hashcode factory provides an unique identifier for any
	 * instance in a Flash Player instance.
	 * <p>
	 * However, there is a major difference between the Java&trade; behavior
	 * and the Flash&trade; behavior. In Java&trade; the hashcode method
	 * will return the same value for two different instances of the same
	 * class which have the same properties value, in Flash&trade; the 
	 * hashcode factory will return a different identifier for all instances
	 * even if their properties are equals.
	 * </p>
	 * @author	Francis Bourre
	 */
	public class HashCodeFactory
	{
		static protected var _K : uint;
		static protected const _d : Dictionary = new Dictionary( true );
		
		public static const PREFIX : String = "KEY";
		
		/**
		 * Returns the hashcode key associated to the passed-in object.
		 * If the objects aint't got a hashcode yet, the method will generate
		 * one and will register the object linked to its hashcode.
		 * 
		 * @param	o	target object
		 * @return	the string hashcode for the passed-in object
		 */
		static public function getKey( o : * ) : String
		{
			if( !hasKey( o ) ) _d[ o ] = getNextKey( );
			return _d[ o ] as String;
		}

		/**
		 * Returns <code>true</code> if the passed-in object has already
		 * got an hashcode key.
		 * 
		 * @param	o	target object
		 * @return	<code>true</code> if the passed-in object has already
		 * 			got an hashcode key.
		 */
		static public function hasKey( o : * ) : Boolean
		{
			return _d[ o ] != null;
		}

		/**
		 * Returns the next unique identifier, two consecutives
		 * calls to <code>getNextKey</code> will generate two
		 * different keys. To get the next key without changing 
		 * the next call result use <code>previewNextKey</code>
		 * method.
		 * 
		 * @return	next unique identifier
		 * @see		#previewNextKey()
		 */
		static public function getNextKey() : String
		{
			return PREFIX + _K++;
		}

		/**
		 * Returns the next key that will be returned by net
		 * <code>getNextKey</code> call. Calling several times
		 * <code>previewNextKey</code> method will never affect
		 * the next call of <code>getNextKey</code> method.
		 * 
		 * @return	preview of next unique identifier
		 */
		static public function previewNextKey() : String
		{
			return PREFIX + _K;
		}
	}
}