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
package com.bourre.ioc.assembler 
{
	import com.bourre.load.Loader;
	import com.bourre.load.LoaderEvent;
	import com.bourre.load.QueueLoaderEvent;	

	/**
	 * @author Francis Bourre
	 */
	public class DisplayObjectBuilderEvent 
		extends LoaderEvent
	{
		static public const onLoadStartEVENT 		: String = QueueLoaderEvent.onLoadStartEVENT;
		static public const onLoadInitEVENT			: String = QueueLoaderEvent.onLoadInitEVENT; 
		static public const onLoadProgressEVENT		: String = QueueLoaderEvent.onLoadProgressEVENT; 
		static public const onLoadTimeOutEVENT		: String = QueueLoaderEvent.onLoadTimeOutEVENT;
		static public const onLoadErrorEVENT 		: String = QueueLoaderEvent.onLoadErrorEVENT;

		static public const onDisplayObjectBuilderLoadStartEVENT 	: String = "onDisplayObjectBuilderLoadStart"; 
		static public const onDLLLoadStartEVENT 					: String = "onDLLLoadStart";	
		static public const onDLLLoadInitEVENT 						: String = "onDLLLoadInit";	
		static public const onDisplayObjectLoadStartEVENT 			: String = "onDisplayObjectLoadStart"; 
		static public const onDisplayObjectLoadInitEVENT 			: String = "onDisplayObjectLoadInit"; 
		static public const onDisplayObjectBuilderLoadInitEVENT 	: String = "onDisplayObjectBuilderLoadInit";

		public function DisplayObjectBuilderEvent ( type : String, loader : Loader = null, errorMessage : String = "" ) 
		{
			super( type, loader, errorMessage );
		}
	}
}