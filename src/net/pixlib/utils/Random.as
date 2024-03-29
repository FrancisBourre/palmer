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
	import net.pixlib.log.PalmerDebug;

	/**
	 * The Random utility class is an all-static class with methods for 
	 * generating pseudorandom numbers, chars or words.
	 * 
	 * @author Romain Ecarnot
	 */
	final public class Random 
	{
		//--------------------------------------------------------------------
		// Constants
		//--------------------------------------------------------------------
				
		/** Defines if char or word must be in upper case or not. */
		public static const UPPER_TYPE : String = "upper";

		/** Defines if char or worf must be in lower case or not. */
		public static const LOWER_TYPE : String = "lower";

		/** 
		 * Defines if char or word can contain upper and lower 
		 * case char.
		 */
		public static const MIXED_TYPE : String = "mixed";

		/**
		 * Default password length.
		 * 
		 * @see #nextPassword()
		 */
		public static const DEFAULT_PASSWORD_LENGTH : Number = 8;

		/**
		 *  Special characters which can be used to generate password.
		 */
		public static const SPECIAL_CHARACTERS_TABLE : Array = [ "+", "&", "\"", "'", "(", "[", "-", "|", "_", "^", ")", "]", 
			"?", "$", "?", "*", "?", "?", "?", "!", ":", "/", ";", ".", 
			",", "?","{", "}" ];
		
		
		//-------------------------------------------------------------------------
		// Public API
		//-------------------------------------------------------------------------
		
		/**
		 * Returns 1 or -1.
		 */
		public static function nextSign( percent : Number = 0.5  ) : int
		{
			return ( Math.random( ) < percent ) ? 1 : -1;
		}
		
		/**
		 * Returns a new random boolean.
		 */
		public static function nextBoolean( percent : Number = 0.5 ) : Boolean
		{
			return ( Math.random( ) < percent );
		}
		
		/**
		 * Returns 0 or 1.
		 */
		public static function nextBit( percent : Number = 0.5  ) : int
		{
			return  ( Math.random( ) < percent ) ? 0 : 1;
		}
		
		/**
		 * Returns a new random float.
		 * 
		 * @param	min	Minimum value for random range		 * @param	max	( optional )Maximum value for random range. If not set, use <code>min</code> 
		 * 				as max value and sets minumum value to 0.
		 */
		public static function nextFloat( min : Number, max : Number = NaN ) : Number
		{
			if ( isNaN( max ) ) 
			{ 
				max = min; 
				min = 0; 
			}
						
			return Math.random( ) * (max - min) + min;
		}
		
		/**
		 * Returns a new random integer.
		 * 
		 * @param	min	Minimum value for random range
		 * @param	max	( optional )Maximum value for random range. If not set, use <code>min</code> 
		 * 				as max value and sets minumum value to 0.
		 */
		public static function nextInt( min : Number, max : Number = NaN ) : int
		{
			return Math.floor( nextFloat( min, max ) );
		}
		
		/**
		 * Returns a new random char.
		 * 
		 * @param	readable	generation still in human readable chars table
		 * @param	type		possible values are :
		 * <ul>
		 *   <li>Random.UPPER_TYPE</li>
		 *   <li>Random.LOWER_TYPE</li>
		 *   <li>Random.MIXED_TYPE</li>
		 * </ul>
		 * 
		 * @see #UPPER_TYPE		 * @see #LOWER_TYPE		 * @see #MIXED_TYPE
		 */
		public static function nextChar( readable : Boolean = true, type : String = "mixed" ) : String
		{
			var human : Boolean = ( readable == false ) ? false : true;
			
			var min : Number = human ? 97 : 0;  
			var max : Number = human ? 122 : 255;
			
			var result : String = String.fromCharCode( MathUtil.random( min, max, true ) );
			
			switch( type )
			{
				case UPPER_TYPE :
					return result.toUpperCase( );
				case MIXED_TYPE : 
					return ( nextBoolean( ) ) ? result : result.toUpperCase( );
				default :
					return result;
			}
		}

		/**
		 * Returns a new random word.
		 * 
		 * @param	limit	max chars in word ( must be &gt; -1 and &lt; 27 )
		 * @param	type	possible values are :
		 * <ul>
		 *   <li>Random.UPPER_TYPE</li>
		 *   <li>Random.LOWER_TYPE</li>
		 *   <li>Random.MIXED_TYPE</li>
		 * </ul>
		 * 
		 * @see #UPPER_TYPE
		 * @see #LOWER_TYPE
		 * @see #MIXED_TYPE
		 */
		public static function nextWord( limit : uint = 12, type : String = "mixed" ) : String
		{
			var result : String = "";
			
			for( var i : int = 0; i < limit ; i += 1 )
			{
				result += nextChar( true, type );
			}
			return result;
		}

		/**
		 * Returns a new random generated password.
		 * 
		 * @param	useNumber	<code>true</code> to enable number in 
		 * 						string ( default is <code>true</code> )
		 * @param	mixCap		<code>true</code> to enable lower and 
		 * 						uppercase mix ( either just lowercase 
		 * 						are used ). Default is <code>true</code>
		 * @param	useOther	<code>true</code> to enable special character 
		 * 						use ( default is <code>false</code> )
		 * @param	min			( optional )Minimum length for generated 
		 * 						password, 
		 * 						default is Random.DEFAULT_PASSWORD_LENGTH
		 * @param	max			( optional )maximum length for generated 
		 * 						password
		 * 
		 * @return	generated password
		 */
		public static function nextPassword( 
			useNumber : Boolean = true, 
			mixCap : Boolean = true, 
			useOther : Boolean = true, 
			min : Number = DEFAULT_PASSWORD_LENGTH, 
			max : Number = DEFAULT_PASSWORD_LENGTH 
			) : String
		{
			useNumber = ( useNumber == false ) ? false : true;
			mixCap = ( mixCap == false ) ? false : true;
			useOther = ( useOther == true ) ? true : false;
			
			if( isNaN( min ) || min <= 0 ) min = DEFAULT_PASSWORD_LENGTH;
			if( isNaN( max ) || max < min ) max = min;
			
			var template : Array = _createTemplate( useNumber, mixCap, useOther );
			
			var l : int = MathUtil.random( min, max, true );
			var result : String = "";
			
			for ( var i : uint = 0; i < l ; i += 1 )
			{
				result += _getRandomSlot( template )( );
			}
			
			return result;
		}

		
		//--------------------------------------------------------------------
		// Private implementations
		//--------------------------------------------------------------------
		
		/** @private */
		public function Random( access : PrivateConstructorAccess ) 
		{
		}
		
		private static function _getRandomSlot( a : Array ) : *
		{
			if( !a || a.length < 1 ) return null;
			
			var index : Number = Random.nextInt( a.length - 1 );
			
			if( a[ index ] == undefined )
			{
				PalmerDebug.ERROR( "Index out of bounds" );
				index = 0;
			}
			
			return a[ index ];
		}
		
		private static function _createTemplate( useNumber : Boolean, mixCap : Boolean, useOther : Boolean ) : Array
		{
			var pattern : Array = new Array( );
			
			if( useNumber ) pattern.push( _getNumber );
			
			if( mixCap ) pattern.push( _getMix );
			else pattern.push( _getLower );
			
			if( useOther ) pattern.push( _getCustom );
			
			return pattern;
		}

		private static function _getNumber() : String
		{
			return String( MathUtil.random( 0, 9, true ) );
		}

		private static function _getLower() : String
		{
			return nextChar( true, Random.LOWER_TYPE );	
		}

		private static function _getMix() : String
		{
			return nextChar( true, Random.MIXED_TYPE );
		}
		
		private static function _getCustom() : String
		{
			return String( _getRandomSlot( SPECIAL_CHARACTERS_TABLE ) );	
		}
	}
}


internal class PrivateConstructorAccess 
{
}
