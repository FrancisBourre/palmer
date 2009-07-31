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
package net.pixlib.ioc.assembler.locator 
{
	import net.pixlib.ioc.assembler.locator.Property;
	import net.pixlib.events.BasicEvent;		

	/**
	 * @author Francis Bourre
	 */
	public class PropertyEvent 
		extends BasicEvent
	{
		static public const onBuildPropertyEVENT 			: String = "onBuildProperty";

		protected var _sID 			: String;		protected var _oProperty 	: Property;

		public function PropertyEvent( type : String, id : String, property : Property = null )
		{
			super( type );

			_sID = id;
			_oProperty = property;
		}
		
		public function getExpertID() : String
		{
			return _sID;
		}

		public function getProperty() : Property
		{
			return _oProperty;
		}

		public function getPropertyOwnerID() : String
		{
			return _oProperty.ownerID;
		}
		
		public function getPropertyName() : String
		{
			return _oProperty.name;
		}
		
		public function getPropertyValue() : String
		{
			return _oProperty.value;
		}
		
		public function getPropertyType() : String
		{
			return _oProperty.type;
		}

		public function getPropertyRef() : String
		{
			return _oProperty.ref;
		}
		
		public function getPropertyMethod() : String
		{
			return _oProperty.method;
		}
	}
}