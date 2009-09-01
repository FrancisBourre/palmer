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
	import net.pixlib.core.ValueObject;

	/**
	 * @author Francis Bourre
	 */
	public class HTTPServiceHelper 
		implements ValueObject
	{
		public var url 			: String;
		public var method 		: String;
		public var dataFormat 	: String;
		public var timeout 		: uint;

		/**
		 * @param	url		
		 * @param	method		
		 * @param	dataFormat		
		 * @param	timeout		
		 */	
		public function HTTPServiceHelper ( url : String, method : String = "POST", dataFormat : String = "text", timeout : uint = 3000 )
		{
			this.url 		= url;			this.method 	= method;			this.dataFormat = dataFormat;			this.timeout 	= timeout;
		}
	}
}
