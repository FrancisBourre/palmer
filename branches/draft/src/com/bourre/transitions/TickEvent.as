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
package com.bourre.transitions
{
	import com.bourre.events.BasicEvent;	

	/**
	 * @author Cédric Néhémie
	 */
	public class TickEvent 
		extends BasicEvent 
	{
		static public const TICK : String = "tick";
		
		public var bias : Number;
		public var biasInSeconds : Number;
		
		public function TickEvent ( type : String, bias : Number = 0 )
		{
			super( type );
			this.bias = bias;
			this.biasInSeconds = bias / 1000;
		}
	}
}
