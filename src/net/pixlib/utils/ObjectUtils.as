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
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.exceptions.NoSuchElementException;
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.log.PalmerDebug;

	import flash.display.DisplayObject;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * The ObjectUtil utility class is an all-static class with methods for 
	 * working with objects.
	 * 
	 * @author	Francis Bourre
	 * @author	Cédric Néhémie
	 */
	final public class ObjectUtils
	{
		/**
		 * Clone an object
		 * 
		 * @param   source	Object to clone
		 * @return  Object  Object cloned
		 */
		static public function clone( source : Object ) : Object 
		{
			if( source === null ) return null;
			if ( source is DisplayObject ) 
			{
				var msg : String = "ObjectUtils.clone(" + source + ") failed. This method can't work with a DisplayObject argument";
				PalmerDebug.ERROR( msg );
				throw new IllegalArgumentException( msg );
			}

			if ( source.hasOwnProperty( "clone" ) && source.clone is Function ) return source.clone( );
			if ( source is Array ) return ObjectUtils.cloneArray( source as Array ) ;

			var qualifiedClassName : String = getQualifiedClassName( source );
			var aliasName : String = qualifiedClassName.split( "::" )[1];
			if ( aliasName ) registerClassAlias( aliasName, (getDefinitionByName( qualifiedClassName ) as Class) );
			var ba : ByteArray = new ByteArray( );
			ba.writeObject( source );
			ba.position = 0;
			return( ba.readObject( ) );
		}

		/**
		 * Clone array's content
		 * 
		 * @param   a	Array to clone
		 * @return  a   Array cloned
		 */
		static public function cloneArray( a : Array ) : Array
		{
			var newArray : Array = new Array( );

			for each( var o : Object in a )
			{
				if ( o is Array )
					newArray.push( ObjectUtils.cloneArray( o as Array ) );
				else
				{
					if( o.hasOwnProperty( "clone" ) && o.clone is Function )
						newArray.push( o.clone( ) ) ;
					else
						newArray.push( ObjectUtils.clone( o ) );
				}
			}
			
			return newArray;
		}

		/**
		 * <p>Allow access to a value like dot syntax in as2</p>
		 * 
		 * <b>sample:</b>
		 * <p>
		 * var btnLaunch : DisplayObject = evalFromTarget( this , "mcHeader.btnLaunch") as DisplayObject;
		 * </p>
		 * 
		 * @param   target the root path of the first element write in the string <p>in the example mcHeader is a child of this</p>
		 * @param   toEval the path of the element to retrieve
		 * @return  null if object not found , else the object pointed by <b>toEval</b>
		 */
		static public function evalFromTarget( target : Object, toEval : String ) : Object 
		{
			var a : Array = toEval.split( "." );
			var l : int = a.length;

			for ( var i : int = 0; i < l ; i++ )
			{
				var p : String = a[ i ];
				if ( target.hasOwnProperty( p ) )
				{
					target = target[ p ];
				} 
				else
				{
					var msg : String = "ObjectUtils.evalFromTarget(" + target + ", " + toEval + ") failed.";
					PalmerDebug.ERROR( msg );
					throw new NoSuchElementException( msg );
				}
			}

			return target;
		}

		/**
		 *  Returns <code>true</code> if the passed-in <code>source</code> object 
		 *  reference specified is a simple data type.
		 *  
		 *  <p>Simple data types include :
		 *  <ul>
		 *    <li><code>String</code></li>
		 *    <li><code>Number</code></li>
		 *    <li><code>uint</code></li>
		 *    <li><code>int</code></li>
		 *    <li><code>Boolean</code></li>
		 *    <li><code>Date</code></li>
		 *    <li><code>Array</code></li>
		 *  </ul></p>
		 *	
		 *  @param source Object inspected.
		 *
		 *  @return <code>true</code> if the object is a simple data type
		 */
		public static function isSimple( source : Object ) : Boolean
		{
			switch ( typeof( source ) )
			{
				case "number":
				case "string":
				case "boolean":
					return true;
				case "object":
	                return (source is Date) || (source is Array);
			}
			
			return false;
		}
		
		/**
		 * @private
		 */
		function ObjectUtils( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException( );
		}
	}
}

internal class ConstructorAccess {}