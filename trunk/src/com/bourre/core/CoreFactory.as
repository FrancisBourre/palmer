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
package com.bourre.core
{
	import com.bourre.collections.HashMap;
	import com.bourre.events.EventBroadcaster;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.exceptions.NoSuchElementException;
	import com.bourre.log.PalmerDebug;
	import com.bourre.log.PalmerStringifier;
	
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;	

	/**
	 * A factory for object creation. The <code>CoreFactory</code>
	 * can build any object of any type. The <code>CoreFactory</code>
	 * is intensively used in the IoC assembler of LowRA.
	 * 
	 * @author	Francis Bourre
	 */
	public class CoreFactory
	{
		/**
		 * Builds an instance of the passed-in class with the specified arguments
		 * passed to the class constructor. The function can also work with singleton
		 * factory and factory methods.
		 * <p>
		 * When trying to create an object, the function will work as below :
		 * </p><ol>
		 * <li>The function try to retreive a reference to te specified class, if
		 * the class cannot be found in the current application domain the function
		 * will fail with an exception.</li>
		 * <li>Then the function will look to a factory method, if one have been
		 * specified, if the <code>singletonAccess</code> is also specified, the
		 * function retreive a reference to the singleton instance and then call
		 * the factory method on it. If there is no singleton access, the function
		 * call the factory method directly on the class.</li>
		 * <li>If <code>singletonAccess</code> is specified and <code>factoryMethod</code>
		 * parameter is null, this method will try to return an instance using singleton
		 * access parameter as static method name of the class passed.</li>
		 * <li>If there is neither a factory method nor a singleton accessor, the
		 * function will instantiate the class using its constructor.</li>
		 * </ol><p>
		 * In AS3, the <code>constructor</code> property of a class is not a function
		 * but an object, resulting that it is not possible to use the <code>apply</code>
		 * or <code>call</code> method on the constructor of a class. The workaround
		 * we use is to create wrapping methods which correspond each to a specific call
		 * to a class constructor with a specific number of arguments, in that way, we can
		 * select the right method to use according to the number of arguments specified
		 * in the <code>buildInstance</code> call. However, there's a limitation, we decided
		 * to limit the number of arguments to <code>30</code> values.
		 * </p>
		 * 
		 * @param	qualifiedClassName	the full classname of the class to create as returned
		 * 								by the <code>getQualifiedClassName</code> function
		 * @param	args				array of arguments to transmit into the constructor
		 * @param	factoryMethod		the name of a factory method provided by the class
		 * 								to use in place of the constructor
		 * @param	singletonAccess		the name of the singleton accessor method if the
		 * 								factory method is a member of the singleton instance
		 * @return	an instance of the specified class, or <code>null</code>
		 * @throws 	<code>ReferenceError</code> — The specified classname cannot be found
		 * 			in the current application domain 
		 * @example Creating a <code>Point</code> instance using the <code>CoreFactory</code> class : 
		 * <listing>CoreFactory.buildInstance( "flash.geom::Point", [ 50, 50 ] );</listing>
		 * 
		 * Using the factory method <code>createObject</code> of the class to create the instance : 
		 * <listing>CoreFactory.buildInstance( "com.package::SomeClass", ["someParam"], "createObject" );</listing>
		 */
		public function buildInstance( qualifiedClassName : String, args : Array = null, factoryMethod : String = null, singletonAccess : String = null ) : Object
		{
			var msg : String;
			var clazz : Class;

			try
			{
				clazz = getDefinitionByName( qualifiedClassName ) as Class;

			} 
			catch ( e : Error )
			{
				msg = clazz + "' class is not available in current domain";
				PalmerDebug.FATAL( msg );
				throw( e );
			}

			var o : Object;
	
			if ( factoryMethod )
			{
				if ( singletonAccess )
				{
					var i : Object;
					
					try
					{
						i = clazz[ singletonAccess ].call();

					} catch ( eFirst : Error ) 
					{
						msg = qualifiedClassName + "." + singletonAccess + "()' singleton access failed.";
						PalmerDebug.FATAL( msg );
						return null;
					}
					
					try
					{
						o = i[factoryMethod].apply( i, args );

					} catch ( eSecond : Error ) 
					{
						msg = qualifiedClassName + "." + singletonAccess + "()." + factoryMethod + "()' factory method call failed.";
						PalmerDebug.FATAL( msg );
						return null;
					}

				} else
				{
					try
					{
						o = clazz[factoryMethod].apply( clazz, args );

					} catch( eThird : Error )
					{
						msg = qualifiedClassName + "." + factoryMethod + "()' factory method call failed.";
						PalmerDebug.FATAL( msg );
						return null;
					}

				}

			} else if ( singletonAccess )
			{
				try
				{
					o = clazz[ singletonAccess ].call();

				} catch ( eFourth : Error ) 
				{
					msg = qualifiedClassName + "." + singletonAccess + "()' singleton call failed.";
					PalmerDebug.FATAL( msg );
					return null;
				}
				
			} else
			{
				o = _buildInstance( clazz, args );
			}

			return o;
		}
		
		/**
		 * A map between number of arguments and buld function
		 * @private
		 */
		private const _A : Array = [	_build0,_build1,_build2,_build3,_build4,_build5,_build6,_build7,_build8,_build9,
										_build10,_build11,_build12,_build13,_build14,_build15,_build16,_build17,_build18,_build19,
										_build20,_build21,_build22,_build23,_build24,_build25,_build26,_build27,_build28,_build29,
										_build30];
			
		/**
		 * Wrapping method which select which build method use
		 * according to the argument count.
		 * @private
		 */
		private function _buildInstance( clazz : Class, args : Array = null ) : Object
		{
			var f : Function = _A[ args ? args.length : 0 ];
			var _args : Array = [clazz];
			if ( args ) _args = _args.concat( args );
			return f.apply( null, _args );
		}
		
		private function _build0( clazz : Class ) : Object{ return new clazz(); }
		private function _build1( clazz : Class ,a1:* ) : Object{ return new clazz( a1 ); }
		private function _build2( clazz : Class ,a1:*,a2:* ) : Object{ return new clazz( a1,a2 ); }
		private function _build3( clazz : Class ,a1:*,a2:*,a3:* ) : Object{ return new clazz( a1,a2,a3 ); }
		private function _build4( clazz : Class ,a1:*,a2:*,a3:*,a4:* ) : Object{ return new clazz( a1,a2,a3,a4 ); }
		private function _build5( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:* ) : Object{ return new clazz( a1,a2,a3,a4,a5 ); }
		private function _build6( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6 ); }
		private function _build7( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7 ); }
		private function _build8( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8 ); }
		private function _build9( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9 ); }
		private function _build10( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10 ); }
		private function _build11( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11 ); }
		private function _build12( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12 ); }
		private function _build13( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13 ); }
		private function _build14( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14 ); }
		private function _build15( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15 ); }
		private function _build16( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16 ); }
		private function _build17( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17 ); }
		private function _build18( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18 ); }
		private function _build19( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19 ); }
		private function _build20( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20 ); }
		private function _build21( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21 ); }
		private function _build22( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:*,a22:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22 ); }
		private function _build23( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:*,a22:*,a23:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23 ); }
		private function _build24( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:*,a22:*,a23:*,a24:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24 ); }
		private function _build25( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:*,a22:*,a23:*,a24:*,a25:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25 ); }
		private function _build26( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:*,a22:*,a23:*,a24:*,a25:*,a26:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26 ); }
		private function _build27( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:*,a22:*,a23:*,a24:*,a25:*,a26:*,a27:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27 ); }
		private function _build28( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:*,a22:*,a23:*,a24:*,a25:*,a26:*,a27:*,a28:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27,a28 ); }
		private function _build29( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:*,a22:*,a23:*,a24:*,a25:*,a26:*,a27:*,a28:*,a29:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27,a28,a29 ); }
		private function _build30( clazz : Class ,a1:*,a2:*,a3:*,a4:*,a5:*,a6:*,a7:*,a8:*,a9:*,a10:*,a11:*,a12:*,a13:*,a14:*,a15:*,a16:*,a17:*,a18:*,a19:*,a20:*,a21:*,a22:*,a23:*,a24:*,a25:*,a26:*,a27:*,a28:*,a29:*,a30:* ) : Object{ return new clazz( a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27,a28,a29,a30 ); }
	
		static private  var _oI : CoreFactory ;
		
		private var _oEB : EventBroadcaster ;
		private var _m : HashMap ;

		static public function getInstance() : CoreFactory
		{
			if ( !(CoreFactory._oI is CoreFactory) ) CoreFactory._oI = new CoreFactory( new ConstructorAccess() );
			return CoreFactory._oI;
		}
		
		static public function release():void
		{
			if ( CoreFactory._oI is CoreFactory ) CoreFactory._oI = null;
		}
		
		public function CoreFactory( access : ConstructorAccess )
		{
			_oEB = new EventBroadcaster( this ) ;
			_m = new HashMap() ;
		}
		
		public function  getKeys () : Array
		{
			return _m.getKeys() ;
		}
		
		public function getValues() : Array
		{
			return _m.getValues() ;
		}
		
		public function clear() : void
		{
			_m.clear();
		}
		
		public function  locate ( key : String ) : Object
		{
			if ( isRegistered(key) )
			{
				return _m.get( key ) ;

			} else
			{
				var msg : String = this + ".locate(" + key + ") fails." ;
				PalmerDebug.ERROR( msg ) ;
				throw( new NoSuchElementException( msg ) ) ;
			}
		}
		
		public function isRegistered( key : String ) : Boolean
		{
			return _m.containsKey( key ) ;
		}
		
		public function isBeanRegistered( bean : Object ) : Boolean
		{
			return _m.containsValue( bean ) ;
		}

		public function register ( key : String, bean : Object ) : Boolean
		{
			if ( !( isRegistered( key ) ) && !( isBeanRegistered( bean ) ) )
			{
				_m.put( key, bean ) ;
				_oEB.broadcastEvent( new CoreFactoryEvent( CoreFactoryEvent.onRegisterBeanEVENT, key, bean ) ) ;
				return true ;

			} else
			{
				var msg:String = "";

				if ( isRegistered( key ) )
				{
					msg += this+".register(" + key + ", " + bean + ") fails, key is already registered." ;
				}

				if ( isBeanRegistered( bean ) )
				{
					msg += this + ".register(" + key + ", " + bean + ") fails, bean is already registered.";
				}

				PalmerDebug.ERROR( msg ) ;
				throw( new IllegalArgumentException( msg ) );
				return false ;
			}
		}

		public function unregister ( key : String ) : Boolean
		{
			if ( isRegistered( key ) )
			{
				_m.remove( key ) ;
				_oEB.broadcastEvent( new CoreFactoryEvent( CoreFactoryEvent.onUnregisterBeanEVENT, key, null ) ) ;
				return true ;
			}
			else
			{
				return false ;
			}
		}

		public function unregisterBean ( bean : Object ) : Boolean
		{
			var key : String = getKey( bean );
			return ( key != null ) ? unregister( key ) : false;
		}
		
		public function getKey( bean : Object ) : String
		{
			var key : String;
			var b : Boolean = isBeanRegistered( bean );

			if ( b )
			{
				var a : Array = _m.getKeys();
				var l : uint = a.length;

				while( -- l > - 1 ) 
				{
					key = a[ l ];
					if ( locate( key ) == bean ) return key;
				}
			}
			
			return null;
		}

		public function addListener( listener : CoreFactoryListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}

		public function removeListener( listener : CoreFactoryListener ) : Boolean
		{
			return _oEB.removeListener( listener );
		}

		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			return _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
		}

		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			return _oEB.removeEventListener( type, listener );
		}

		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}

		public function add( d : Dictionary ) : void
		{
			for ( var key : * in d ) 
			{
				try
				{
					register( key, d[ key ] as Object );

				} catch( e : IllegalArgumentException )
				{
					e.message = this + ".add() fails. " + e.message;
					PalmerDebug.ERROR( e.message );
					throw( e );
				}
			}
		}
	}
}


internal class ConstructorAccess {}