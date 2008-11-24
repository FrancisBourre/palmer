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
package com.bourre.ioc.load
{
	import com.bourre.load.LoaderEvent;		

	/**
	 * @author Francis Bourre
	 */
	public class ApplicationLoaderEvent
		extends LoaderEvent
	{
		static public const onLoadStartEVENT 	: String = LoaderEvent.onLoadStartEVENT;
		static public const onLoadInitEVENT 	: String = LoaderEvent.onLoadInitEVENT;
		static public const onLoadProgressEVENT : String = LoaderEvent.onLoadProgressEVENT;
		static public const onLoadTimeOutEVENT 	: String = LoaderEvent.onLoadTimeOutEVENT;
		static public const onLoadErrorEVENT 	: String = LoaderEvent.onLoadErrorEVENT;
		
		static public const onApplicationParsedEVENT 			: String = "onApplicationParsed";
		static public const onApplicationObjectsBuiltEVENT 		: String = "onApplicationObjectsBuilt";
		static public const onApplicationMethodsCalledEVENT 	: String = "onApplicationMethodsCalled";
		static public const onApplicationChannelsAssignedEVENT 	: String = "onApplicationChannelsAssigned";
		static public const onApplicationInitEVENT 				: String = "onApplicationInit";

		public function ApplicationLoaderEvent( type : String, al : ApplicationLoader, errorMessage : String = "" )
		{
			super( type, al, errorMessage );
		}
		
		public function getApplicationLoader() : ApplicationLoader
		{
			return getLoader() as ApplicationLoader;
		}
	}
}