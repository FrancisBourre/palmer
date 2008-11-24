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
package com.bourre.ioc.context
{
	import com.bourre.load.LoaderEvent;	

	/**
	 * @author Francis Bourre
	 */
	public class ContextLoaderEvent
		extends LoaderEvent
	{
		static public const onLoadStartEVENT 	: String = LoaderEvent.onLoadStartEVENT;
		static public const onLoadInitEVENT 	: String = LoaderEvent.onLoadInitEVENT;
		static public const onLoadProgressEVENT : String = LoaderEvent.onLoadProgressEVENT;
		static public const onLoadTimeOutEVENT 	: String = LoaderEvent.onLoadTimeOutEVENT;
		static public const onLoadErrorEVENT 	: String = LoaderEvent.onLoadErrorEVENT;
		
		public function ContextLoaderEvent( type : String, cl : ContextLoader, errorMessage : String = "" )
		{
			super( type, cl, errorMessage );
		}
		
		public function getContextLoader() : ContextLoader
		{
			return getLoader() as ContextLoader;
		}
		
		public function getContext() : XML
		{
			return getContextLoader().getContext();
		}
	}
}