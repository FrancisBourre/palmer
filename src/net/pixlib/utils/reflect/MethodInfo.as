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
	 * Methods class informations.
	 * 
	 * @see ClassInfo
	 * 
	 * @author Romain Ecarnot
	 */
	public class MethodInfo extends ElementInfo
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private var _aParameterList : Array;		
		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * Returns method parameters list.
		 * 
		 * @see fever.utils.reflect.ParameterInfo
		 */
		public function get parameters( ) : Array { return _aParameterList; }
				
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Constructor.
		 * 
		 * @param	eDesc	XML Node description
		 * @param	eStatic	Method is static
		 */
		public function MethodInfo( eDesc : XML, eStatic : Boolean = false )
		{
			super( eDesc, _getName( eDesc ), _getType( eDesc ), eStatic, eDesc.@declaredBy );
			
			_buildParameters();		}
		
		/** 
		 * @inheritDoc
		 */
		override public function toString() : String
		{
			return ( ( staticFlag ) ? "static " : "" ) + name + " ( " + _stringifyParamters() + " ) : " + type;
		}
		
		
		//--------------------------------------------------------------------
		// Private implementations
		//--------------------------------------------------------------------
		
		private function _getName( eDesc : XML ) : String
		{
			return ( eDesc.@name != undefined ) 
				? eDesc.@name 
				: "constructor";
		}
		
		private function _getType( eDesc : XML ) : String
		{
			return ( eDesc.@returnType != undefined ) 
				? eDesc.@returnType 
				: "";
		}
		
		private function _buildParameters() : void
		{
			var x : XMLList = description.parameter;
			
			_aParameterList = new Array();
			
			if( x.length() > 0 )
			{
				for each( var node : XML in x )
				{
					_aParameterList.push( new ParameterInfo( node ) );
				}
			}
		}

		private function _stringifyParamters() : String
		{
			var l : int = _aParameterList.length;
			var s : String = "";
			
			for( var i : int = 0; i < l; i ++ )
			{
				s += _aParameterList[ i ].toString();
				if( i + 1 < l ) s+= ", ";
			}
			
			return s;
		}
	}
}
