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
package net.pixlib.encoding 
{
	/**
	 * Deserializer interface defines rules for deserialization implementation.
	 * 
	 * @author Francis Bourre
	 */
	public interface Deserializer 
	{
		/**
		 * Returns <code>serializedContent</code> deserialization result.
		 * 
		 * @param	serializedContent	Content to deserialize
		 * @param	target				(optional)
		 * @param	key					(optional) Identifier to allow possible 
		 * 								object registration	
		 * @return The <code>serializedContent</code> deserialization result.
		 */
		function deserialize( serializedContent : Object, target : Object = null, key : String = null ) : Object;
	}
}