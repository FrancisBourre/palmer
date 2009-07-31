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
	import net.pixlib.core.Locator;
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.log.PalmerStringifier;

	import flash.utils.Dictionary;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.getDefinitionByName;
	
	/**
	 * The <code>FlashVars</code> class stores 
	 * flashvars in basic Dictionary structure.
	 * 
	 * @author Romain Ecarnot
	 */
	final public class FlashVars extends Proxy implements Locator
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private static  var _oI : FlashVars ;

		private var _oDico : Dictionary;		
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Returns singleton instance of <code>FlashVars</code> class.
		 * 
		 * @return The singleton instance of <code>FlashVars</code> class.
		 */	
		public static function getInstance() : FlashVars
		{
			if ( !(FlashVars._oI is FlashVars) ) FlashVars._oI = new FlashVars( ConstructorAccess.instance );
			return FlashVars._oI;
		}

		/**
		 * Releases singleton instance.
		 */
		public static function release() : void
		{
			if ( FlashVars._oI is FlashVars ) FlashVars._oI = null;
		}

		/**
		 * Returns <code>true</code> is there is a ressource associated
		 * with the passed-in <code>key</code> in this config. <br />
		 * To avoid errors when retreiving ressources from a locator 
		 * you should systematically use the <code>isRegistered</code> 
		 * function to check if the ressource you would access is 
		 * already accessible before any call to the <code>locate</code> 
		 * function.
		 * 
		 * @return 	<code>true</code> is there is a ressource associated
		 * 			with the passed-in <code>key</code>.
		 */
		public function isRegistered( key : String ) : Boolean
		{
			return ( _oDico.hasOwnProperty( key ) );
		}
		
		/**
		 * Registers passed-in value with key identifier.
		 * 
		 * @param key	Identifier
		 * @param value	Value to register
		 */
		public function register( key : String, value : * ) : void
		{
			_oDico[ key ] = value;
		}

		/**
		 * Returns the ressource associated with the passed-in <code>key</code>.
		 * If there is no ressource identified by the passed-in key, the
		 * function will return <code>null</code>.
		 * 
		 * @param	key	identifier of the ressource to access
		 * @return	the ressource associated with the passed-in <code>key</code>
		 */
		public function locate( key : String ) : Object
		{
			if( _oDico.hasOwnProperty( key ) )
			{
				return _oDico[ key ];	
			}
			else return null;
		}

		/**
		 * @inheritDoc
		 */
		public function add(d : Dictionary) : void
		{
			for ( var key : * in d ) 
			{
				try
				{
					register( key, d[ key ] );
				} 
				catch ( e : IllegalArgumentException )
				{
					e.message = this + ".add() fails. " + e.message;
					PalmerDebug.ERROR( e.message );
					throw( e );
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		public function getKeys() : Array
		{
			var keys : Array = new Array();
			
			for( var key : String in _oDico ) keys.push( key );
			
			return keys;
		}

		/**
		 * @inheritDoc
		 */
		public function getValues() : Array
		{
			var values : Array = new Array();
			
			for( var key : String in _oDico ) values.push( _oDico[ key ] );
			
			return values;
		}

		/**
		 * Returns Flashvar value registred with passed-in 
		 * <code>key</code> identifier as <strong>Boolean</strong>.
		 * 
		 * @param key Flashvar key to search
		 * @param defaultValue Value to return if Flashvar is not defined
		 */
		public function getBoolean( key : String, defaultValue : Boolean = false ) : Boolean
		{
			var o : * = locate( key );
			
			if( o != null )
			{
				if( o is Boolean ) return o as Boolean;
				else return new Boolean( o == "true" || !isNaN( Number( o ) ) && Number( o ) != 0 );
			}
			else return defaultValue;
		}

		/**
		 * Returns resource value registred with passed-in 
		 * <code>key</code> identifier as <strong>Number</strong>.
		 * 
		 * @param key Flashvar key to search
		 * @param defaultValue Value to return if Flashvar is not defined
		 */
		public function getNumber( key : String, defaultValue : Number = NaN ) : Number
		{
			var o : * = locate( key );
			
			if( o != null )
			{
				if( o is Number ) return o as Number;
				else return Number( o );
			}
			else return defaultValue;
		}

		/**
		 * Returns Flashvar value registred with passed-in 
		 * <code>key</code> identifier as <strong>String</strong>.
		 * 
		 * @param key Flashvar key to search
		 * @param defaultValue Value to return if Flashvar is not defined
		 */
		public function getString( key : String, defaultValue : String = null ) : String
		{
			var o : * = locate( key );
			
			if( o != null ) return o.toString( );
			else return defaultValue;
		}

		/**
		 * Returns Flashvar value registred with passed-in 
		 * <code>key</code> identifier as <strong>Array</strong>.
		 * 
		 * @param key Flashvar key to search
		 * @param defaultValue Value to return if Flashvar is not defined
		 */
		public function getArray( key : String, defaultValue : Array = null ) : Array
		{
			var o : * = locate( key );
			
			if( o != null )
			{
				var a : Array = o is Array ? o as Array : new Array( o );
				return a;	
			}
			else return defaultValue;
		}

		/**
		 * Returns Flashvar value registred with passed-in 
		 * <code>key</code> identifier as <strong>Class</strong>.
		 * 
		 * @param key Flashvar key to search
		 */
		public function getClass( key : String ) : Class
		{
			var o : * = locate( key );
			
			if( o != null ) return getDefinitionByName( o.toString( ) ) as Class;
			else return null;
		}
		
		/**
		 * Returns string representation of instance.
		 * 
		 * @return The string representation of instance.
		 */
		public function toString() : String
		{
			return PalmerStringifier.stringify( this );
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override flash_proxy function getProperty( name : * ) : * 
		{
			return locate( name );
		}

		/**
		 * @inheritDoc
		 */
		override flash_proxy function setProperty(name : *, value : *) : void 
		{
			if( !_oDico.hasOwnProperty( name ) )
			{
				_oDico[ name ] = value;
			}
		}	

		/**
		 * @inheritDoc
		 */
		override flash_proxy function hasProperty(name : *) : Boolean
		{
			return _oDico.hasOwnProperty( name );
		}

		/**
		 * @inheritDoc
		 */
		override flash_proxy function deleteProperty(name : *) : Boolean
		{
			return delete _oDico[ name ];
		}

		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
			
		/**
		 * @private
		 */
		function FlashVars( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException( );
			
			_oDico = new Dictionary( true );
		}
	}
}

internal class ConstructorAccess 
{
	static public const instance : ConstructorAccess = new ConstructorAccess( );
}