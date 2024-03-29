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
 
package net.pixlib.utils.reflect 
{

	/**
	 * Method parameters informations.
	 * 
	 * @see ClassInfo	 * @see MethodInfo
	 * 
	 * @author Romain Ecarnot
	 */
	public class ParameterInfo extends ElementInfo
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private var _index : int;		private var _optional : Boolean;
		
				
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/** Static flag is not available for parameter elements. */
		override public function get staticFlag( ) : Boolean { return _static; }
		
		/** <code>true</code> if parameter is optional.*/
		public function get optionalFlag( ) : Boolean { return _optional; }
		
		/** Parameter index in method signature.*/
		public function get index( ) : int { return _index; }
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Constructor.
		 * 
		 * @param	eDesc	XML Node description
		 */
		public function ParameterInfo( eDesc : XML )
		{
			super( eDesc, "", eDesc.@type );
			
			_index = parseInt( eDesc.@index );			_optional = eDesc.@optional;
			_name = "arg" + _index;
		}
		
		/** 
		 * @inheritDoc
		 */
		override public function toString() : String
		{
			return ( name + " : " + type );
		}
	}
}
