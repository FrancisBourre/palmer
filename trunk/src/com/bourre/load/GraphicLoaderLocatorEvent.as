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
	import flash.events.Event;	

	/**
	 * @author Francis Bourre
	 */
	public class GraphicLoaderLocatorEvent 
		extends Event 
	{
		static public const onRegisterGraphicLoaderEVENT 	: String = "onRegisterGraphicLoader";
		static public const onUnregisterGraphicLoaderEVENT 	: String = "onUnregisterGraphicLoader";
	
		protected var _sName 	: String;
		protected var _gl 		: GraphicLoader;
		
		public function GraphicLoaderLocatorEvent( type : String, name : String, gl : GraphicLoader ) 
		{
			super( type );
			
			_sName = name;
			_gl = gl;
		}
		
		public function getName() : String
		{
			return _sName;
		}
		
		public function getGraphicLib() : GraphicLoader
		{
			return _gl;
		}
	}
}