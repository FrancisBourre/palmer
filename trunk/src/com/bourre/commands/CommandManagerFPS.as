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
package com.bourre.commands
{
	import com.bourre.transitions.FPSBeacon;	

	/**
	 * @author 	Francis Bourre
	 */
	public class CommandManagerFPS 
		extends CommandFPS
	{
		static private var _oI : CommandManagerFPS;
	
		static public function getInstance() : CommandManagerFPS
		{
			if ( !(CommandManagerFPS._oI is CommandManagerFPS) ) CommandManagerFPS._oI = new CommandManagerFPS( new ConstructorAccess() );
			return CommandManagerFPS._oI;
		}

		static public function release() : void
		{
			FPSBeacon.getInstance().removeTickListener( CommandManagerFPS._oI );
			CommandManagerFPS._oI = null;
		}

		public function CommandManagerFPS ( o : ConstructorAccess )
		{
			//
		}
	}
}
internal class ConstructorAccess {}