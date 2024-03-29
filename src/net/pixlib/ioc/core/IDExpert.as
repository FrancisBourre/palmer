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
package net.pixlib.ioc.core
{
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.exceptions.NoSuchElementException;
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.log.PalmerStringifier;
	
	import flash.utils.Dictionary;	

	/**
	 * @author Francis Bourre
	 */
	public class IDExpert
	{
		protected var _d : Dictionary;

		public function IDExpert()
		{
			_d = new Dictionary( true );
		}

		public function isRegistered( id : String ) : Boolean
		{
			return _d[ id ] == true;
		}

		public function clear() : void
		{
			_d = new Dictionary( true );
		}
		
		public function register( id : String ) : Boolean
		{
			if (  _d[ id ] ) 
			{
				var msg : String = this + ".register(" + id + ") failed. This id was already registered, check conflicts in your config file.";
				PalmerDebug.ERROR( msg );
				throw( new IllegalArgumentException( msg ) );

			} else
			{
				_d[ id ] = true;
				return true;
			}

			return false;
		}
		
		public function unregister( id : String ) : Boolean
		{
			if ( isRegistered( id ) ) 
			{
				_d[ id ] = false;
				return true;

			} else
			{
				var msg : String =  this + ".unregister(" + id + ") failed.";
				PalmerDebug.ERROR( msg );
				throw( new NoSuchElementException( msg ) );
			}

			return false;
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