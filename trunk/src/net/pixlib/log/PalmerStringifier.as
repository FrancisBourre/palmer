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
package net.pixlib.log
{
	import net.pixlib.exceptions.PrivateConstructorException;

	/**
	 * @author Francis Bourre
	 */
	public class PalmerStringifier
	{
		static private var _STRINGIFIER : Stringifier = new BasicStringifier();
		
		public function PalmerStringifier( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}
		
		static public function setStringifier( o : Stringifier ) : void
		{
			PalmerStringifier._STRINGIFIER = o;
		}
		
		static public function getStringifier() : Stringifier
		{
			return PalmerStringifier._STRINGIFIER;
		}
	
		static public function stringify( target : * ) : String 
		{
			return PalmerStringifier._STRINGIFIER.stringify( target );
		}
	}
}

internal class ConstructorAccess {}