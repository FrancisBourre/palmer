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
	import com.bourre.events.BasicEvent;
	
	import flash.display.DisplayObject;	

	/**
	 * @author Francis Bourre
	 */
	public class DisplayObjectEvent 
		extends BasicEvent
	{
		static public const onBuildDisplayObjectEVENT : String = "onBuildDisplayObject" ;
	
		protected var _do : DisplayObject;
		
		public function DisplayObjectEvent( type : String, d : DisplayObject ) 
		{
			super( type, d );
			
			_do = d;
		}
		
		public function getDisplayObject() : DisplayObject
		{
			return _do;
		}
	}
}