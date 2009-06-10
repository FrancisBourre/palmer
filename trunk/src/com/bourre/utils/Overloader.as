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

package com.bourre.utils 
{
	import com.bourre.collections.Iterator;
	import com.bourre.collections.Set;
	import com.bourre.exceptions.NoSuchElementException;
	import com.bourre.log.PalmerDebug;

	import flash.utils.getQualifiedClassName;

	/**
	 * Overloads a method.
	 * 
	 * <p>With overloading you have typically two or more methods with the 
	 * same name but with different arguments signatures.<br />
	 * ActionScript 3.0 does not support overloading, that's why 
	 * <code>Overloader</code> class provides system to simulate overloading 
	 * process easily.</p>
	 * 
	 * @example
	 * <pre class="prettyprint">
	 * 
	 * public function testMe( ...rest ) : void
	 * {
	 * 	var o : Overloader = new Overloader( );
	 * 	o.addOverloading( [ String, int ], _doByStringAndNumber );
	 * 	o.addOverloading( [ String, String ], _doByStringAndString );
	 * 	o.overload( rest );
	 * }
	 * </pre>
	 * 
	 * @author Romain Ecarnot
	 */
	public class Overloader 
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _oSet : Set;
		private var _oDefaultHandler : Function;

		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * Specifies default overloading method to use if 
		 * arguments sequence overloading is not find.
		 */
		public function get defaultOverloading( ) : Function
		{
			return _oDefaultHandler;		
		}

		/** @private */
		public function set defaultOverloading( value : Function ) : void
		{
			_oDefaultHandler = value;
		}

		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function Overloader( )
		{
			_oSet = new Set( Overloading );
		}

		/**
		 * Adds overloading definition.
		 * 
		 * @example
		 * <pre class="prettyprint">
		 * 
		 * var o : Overloader = new Overloader( );
		 * o.addOverloading( [ String, int ], _doByStringAndNumber );
		 * o.addOverloading( [ String, String ], _doByStringAndString );
		 * </pre>
		 * 
		 * @param	types		sequence types
		 * @param	handler		handler to trigger		 */
		public function addOverloading( types : Array, handler : Function) : void
		{
			_oSet.add( new Overloading( types, handler ) );
		}

		/**
		 * Overloads method.
		 * 
		 * @example
		 * <pre class="prettyprint">
		 * 
		 * var o : Overloader = new Overloader( this );
		 * o.addOverloading( [ String, int ], _doByStringAndNumber );
		 * o.addOverloading( [ String, String ], _doByStringAndString );
		 * o.overload( arguments );
		 * </pre>
		 * 
		 * @param	argSequence	arguments sequence to check
		 * 
		 * @return	overloaded method result
		 * 
		 * @throws	<code>NoSuchElementException</code> - No overloading 
		 * 			definition is found for passed-in arguments sequence
		 */
		public function overload( args : Array ) : *
		{
			var l : int = args.length;
			var it : Iterator = _oSet.iterator( );
			
			while( it.hasNext( ) )
			{
				var o : Overloading = it.next( ) as Overloading;
				
				if( o.length == l )
				{
					if( o.matches( args ) )
					{
						return o.handler.apply( null, args );
					}
				}
			}
			
			var a : Array = new Array( );
			for( var i : int = 0; i < l ; i++ ) a.push( getQualifiedClassName( args[i] ) );	
			
			if( _oDefaultHandler != null )
			{
				PalmerDebug.DEBUG( "Use default overloading for [" + a + "]" );
				
				return _oDefaultHandler.apply( null, args );
			}
			else
			{
				var msg : String = "No overloading found for current arguments list [" + a + "]";
				PalmerDebug.ERROR( msg );
				throw new NoSuchElementException( )( msg );
			}
			
			return null;
		}
	}
}

import flash.utils.describeType;
import flash.utils.getQualifiedClassName;

/**
 * @private
 * 
 * Overloading definition structure.
 * 
 * @author Romain Ecarnot
 */
internal class Overloading
{
	//--------------------------------------------------------------------
	// Private properties
	//--------------------------------------------------------------------

	private var _aTypes : Array;
	private var _nLength : int;	private var _fHandler : Function;
	
	//--------------------------------------------------------------------
	// Public properties
	//--------------------------------------------------------------------
	
	/** Type sequence length. */
	public function get length( ) : int 
	{ 
		return _nLength; 
	}

	/** Handler to trigger. */	public function get handler( ) : Function 
	{ 
		return _fHandler; 
	}

	
	//--------------------------------------------------------------------
	// Public API
	//--------------------------------------------------------------------
	
	/**
	 * Constructor.
	 * 
	 * @param	types	data types sequence
	 * @param	handler	handler to trigger when overloading 
	 * 					definition is found.
	 */	
	public function Overloading( types : Array, handler : Function )
	{
		_aTypes = types.slice( 0 );
		_nLength = _aTypes.length;
		_fHandler = handler;
	}

	/**
	 * Returns <code>true</code> if passed-in <code>argSequence</code> has 
	 * correct data type according type sequence defined in constructor.
	 * 
	 * @param	args	arguments collection
	 */
	public function matches( args : Array ) : Boolean
	{
		var l : int = args.length;
		
		for( var i : int = 0; i < l ; i++ )
		{
			var o : * = args[ i ];
			
			if( o != null )
			{
				var t : Class = _aTypes[ i ];
				
				if( 
					!_isImplementationOf( o, t ) && !_isSubclassOf( o, t ) && ( getQualifiedClassName( o ) != getQualifiedClassName( t ) )
				) return false;
			}
		}
		
		return true;
	}

	
	//--------------------------------------------------------------------
	// Private implementation
	//--------------------------------------------------------------------

	private function _isImplementationOf( arg : *, type : Class ) : Boolean
	{
		return describeType( arg ).implementsInterface.(@type == getQualifiedClassName( type ) ).length( ) > 0;
	}

	private function _isSubclassOf( arg : *, type : Class ) : Boolean
	{
		return describeType( arg ).extendsClass.(@type == getQualifiedClassName( type ) ).length( ) > 0;
	}	
}
