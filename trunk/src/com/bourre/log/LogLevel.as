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
package com.bourre.log
{
	/**
	 * @author Francis Bourre
	 */
	public class LogLevel
	{
		static public const ALL 	: LogLevel = new LogLevel ( uint.MIN_VALUE, "ALL" );
		static public const DEBUG 	: LogLevel = new LogLevel ( 10000, 			"DEBUG" );
		static public const INFO 	: LogLevel = new LogLevel ( 20000, 			"INFO" );
		static public const WARN	: LogLevel = new LogLevel ( 30000, 			"WARN" );
		static public const ERROR	: LogLevel = new LogLevel ( 40000, 			"ERROR" );
		static public const FATAL	: LogLevel = new LogLevel ( 50000, 			"FATAL" );
		static public const OFF		: LogLevel = new LogLevel ( uint.MAX_VALUE, "OFF" );
	
		private var _sName : String;
		private var _nLevel : Number;
		
		public function LogLevel( nLevel : uint = uint.MIN_VALUE, sName : String = "" )
		{
			_sName = sName;
			_nLevel = nLevel;
		}
		
		public function getName() : String
		{
			return _sName;
		}
	
		public function getLevel() : uint
		{
			return _nLevel;
		}
		
		/**
		 * Returns the string representation of this instance.
		 * @return the string representation of this instance
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}
	}
}
