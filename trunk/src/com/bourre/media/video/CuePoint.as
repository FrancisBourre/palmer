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
 
package com.bourre.media.video 
{
	import com.bourre.core.ValueObject;
	import com.bourre.log.PalmerStringifier;	

	/**
	 * Video cue point data structure.
	 * 
	 * @author Romain Ecarnot
	 */
	public class CuePoint implements ValueObject
	{
		//--------------------------------------------------------------------
		// Constants
		//--------------------------------------------------------------------
		
		/** Navigation type. */
		public static const NAVIGATION_TYPE: String = "navigation";
		
		/** Event type. */
		public static const EVENT_TYPE : String = "event";
		
		/** Actionscript type. */
		public static const ACTIONSCRIPT_TYPE : String = "actionscript";
		
				
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * Type of cue point.
		 * 
		 * <p>Can be : 
		 * 	<ul>
		 * 		<li>navigation</li>		 * 		<li>event</li>		 * 		<li>actionscript</li>
		 * 	</ul>
		 * </p>
		 */
		public var type : String;
		
		/**
		 * Name of cue point.
		 */
		public var name : String;
		
		/**
		 * Cue point time.
		 */
		public var time : Number;
		
		/**
		 * Cue point optional parameters.
		 */
		public var parameters : Array;
		
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates new instance.
		 * 
		 * @param	o	(optional) a Raw cue point data
		 */
		public function CuePoint( o : Object = null ) 
		{
			if( o )
			{
				type = o.type || null;				name = o.name || null;				time = o.time || Number.NaN;				parameters = o.parameters || [];
			}
			else 
			{
				type = CuePoint.ACTIONSCRIPT_TYPE;
				parameters = new Array();
			}
		}

		/**
		 * Returns string representation of instance.
		 * 
		 * @return A string representation of instance.
		 */
		public function toString(  ) : String
		{
			return PalmerStringifier.stringify( this ) + "(" + 
				"type:" + type + ", " + 
				"name:" + name + ", " + 
				"time:[" + time + "], " + 
				"parameters:[" + parameters.length + "])";
		}
	}
}
