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
package com.bourre.ioc.core
{

	 * @author Francis Bourre
	 */
	public class ContextAttributeList
	{
		//--------------------------------------------------------------------
		// Constants
		//--------------------------------------------------------------------
				
		static public const ID 								: String = "id";
		static public const TYPE 							: String = "type";
		static public const NAME 							: String = "name";
		static public const REF 							: String = "ref";
		static public const VALUE 							: String = "value";
		static public const FACTORY 						: String = "factory";
		static public const URL 							: String = "url";
		static public const VISIBLE 						: String = "visible";
		static public const SINGLETON_ACCESS 				: String = "singleton-access";
		static public const METHOD 							: String = "method";
		static public const PROGRESS_CALLBACK				: String = "progress-callback";
		static public const NAME_CALLBACK 					: String = "name-callback";
		static public const TIMEOUT_CALLBACK 				: String = "timeout-callback";	
		static public const PARSED_CALLBACK 				: String = "parsed-callback";	
		static public const INIT_CALLBACK 					: String = "init-callback";	
		static public const DELAY 							: String = "delay";
		public static const ROOT_REF : 						String = "root-ref";
		
		/** @private */
		function ContextAttributeList( )
		{
			
		}
	}
}