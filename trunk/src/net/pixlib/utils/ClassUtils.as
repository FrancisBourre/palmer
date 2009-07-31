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
package net.pixlib.utils 
{
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;	

	/**
	 * The ClassUtil utility class is an all-static class with methods for 
	 * working with Class objects.
	 * 
	 * @author Cedric Nehemie
	 * @author	Francis Bourre
	 */
	public class ClassUtils
	{		
		/**
		 * Verify that the passed-in <code>childClass</code> is a descendant of the 
		 * specified <code>parentClass</code>.
		 * 
		 * @param clazz	class to check inheritance with the ascendant class
		 * @param parent	class which is the ascendant
		 */
		static public function inherit( clazz : Class, parent : Class) : Boolean 
		{
			var xml : XML = describeType( clazz );
			var parentName : String = getQualifiedClassName( parent );
			return 	(xml.factory.extendsClass.@type).contains( parentName ) || (xml.factory.implementsInterface.@type).contains( parentName );
		}	
	}
}