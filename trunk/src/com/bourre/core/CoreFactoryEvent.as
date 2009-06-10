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
package com.bourre.core
{
	import com.bourre.events.BasicEvent;
	import com.bourre.log.*;	

	/**
	 * @author Francis Bourre
	 */
	public class CoreFactoryEvent extends BasicEvent
	{
		static public const onRegisterBeanEVENT		:String = "onRegisterBean";
		static public const onUnregisterBeanEVENT	:String = "onUnregisterBean";

		private var _sID	: String;
		private var _oBean 	: Object;
		
		public function CoreFactoryEvent( type : String, id : String, bean : Object )
		{
			super( type, bean );
			_sID = id;
			_oBean = bean;
		}
		
		public function getID() : String
		{
			return _sID ;
		}
		
		public function getBean() : Object
		{
			return _oBean ;
		}
		
		override public function toString() : String
		{
			return PalmerStringifier.stringify( this );
		}
	}
}