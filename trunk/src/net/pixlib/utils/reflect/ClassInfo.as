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
	import net.pixlib.collections.ArrayIterator;
	import net.pixlib.collections.HashMap;
	import net.pixlib.collections.Iterator;
	import net.pixlib.commands.Delegate;
	import net.pixlib.core.CoreFactory;
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.exceptions.NoSuchElementException;
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.log.PalmerDebug;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Provides class description.
	 *
	 * @example
	 * <pre class="prettyprint">
	 *
	 * var info : ClassInfo = ClassInfo.describe( EventBroadcaster );
	 * FeverDebug.INFO( info.toString( false ) );
	 *
	 * FeverDebug.INFO( info.getContructor() );
	 * FeverDebug.INFO( info.getAccessorIterator( ) );
	 * FeverDebug.INFO( info.getPropertyIterator( ) );
	 * FeverDebug.INFO( info.getConstantIterator( ) );
	 * FeverDebug.INFO( info.getMethodIterator( ClassInfo.STATIC_FILTER ) );
	 *
	 * FeverDebug.INFO( info.containsMethod( "addEventListener" ) );
	 * FeverDebug.INFO( info.containsProperty( "otto" ) );
	 * FeverDebug.INFO( info.containsAccessor( "enabled" ) );
	 * </pre>
	 *
	 * <p>Informations are cached, so if a <code>ClassInfo</code> instance
	 * already exist for a class type, returns the cached instance.</p>
	 *
	 * @example
	 * <pre class="prettyprint">
	 *
	 * var instance : PopupContextMenu = new PopupContextMenu(   );
	 *
	 * var info1 : ClassInfo = ClassInfo.describe( PopupContextMenu );
	 * var info2 : ClassInfo = ClassInfo.describe( PopupContextMenu );
	 * var info3 : ClassInfo = ClassInfo.describe( "flash.geom.Point" );
	 * var info4 : ClassInfo = ClassInfo.describe( new Sprite() );
	 * </pre>
	 * <p>In this example, just only one <code>ClassInfo</code> instance
	 * is created.</p>
	 *
	 * @author Romain Ecarnot
	 */
	public class ClassInfo
	{
		//--------------------------------------------------------------------
		// Constants
		//--------------------------------------------------------------------
           
		/** 
		 * Filter identifier to retreive all methods and properties (default).
		 */
		public static const NONE_FILTER : int = 0;

		/**
		 * Filter identifier to retreive static methods and properties.
		 */
		public static const STATIC_FILTER : int = 1;

		/** 
		 * Filter identifier to retreive factory methods and properties.
		 */
		public static const FACTORY_FILTER : int = 2;

		
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private static var _mCache : HashMap = new HashMap( );

		private var _xmlDesc : XML;
		private var _sFullName : String;
		private var _oType : Class;
		private var _aInterfaceList : Array;
		private var _aSuperList : Array;
		private var _oConstuctor : MethodInfo;
		private var _aMethodList : Array;
		private var _aAccessorList : Array;
		private var _aPropertyList : Array;
		
		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
           
		/**
		 * Linebreak for output display using <code>toString()</code> only.
		 * 
		 * @see #toString()
		 */
		public static var LINEBREAK : String = "\n";

		/**
		 * Tab separator for output display using <code>toString()</code> only.
		 * 
		 * @see #toString()
		 */
		public static var TAB : String = "\t";

		/** <code>true</code> if class is <code>static</code>. */
		public function get staticFlag( ) : Boolean
		{
			return _xmlDesc.@isStatic == "true" ? true : false;
		}

		/** <code>true</code> if class is <code>final</code>. */
		public function get finalFlag( ) : Boolean
		{
			return _xmlDesc.@isFinal == "true" ? true : false;
		}

		/** <code>true</code> if class is <code>dynamic</code>. */
		public function get dynamicFlag( ) : Boolean
		{
			return _xmlDesc.@isDynamic == "true" ? true : false;
		}

		/** Full qualified class name. */
		public function get fullQualifiedName( ) : String
		{
			return _sFullName;      
		}

		/** Class name. */
		public function get name( ) : String
		{
			return _sFullName.split( "::" ).pop( );
		}

		/** Class package. */
		public function get packageName( ) : String
		{
			if( _sFullName.indexOf( "::" ) > -1 )
                           return _sFullName.split( "::" ).shift( );
                   else return "";
		}

		/** XML desciption. */
		public function get description() : XML 
		{ 
			return _xmlDesc; 
		}

		/** Class type. */
		public function get type() : Class 
		{ 
			return _oType; 
		}

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
           
		/**
		 * Builds and returns <strong>ClassInfo</strong> instance for passed-in
		 * <code>o</code> object.
		 *
		 * <p>Informations are cached, so if a <strong>ClassInfo</strong>
		 * instance already exist for a class type, returns the cached
		 * instance.</p>
		 *
		 * <p><span class="label"><b>Overloading</b></span>
		 * <ul>
		 *   <li>ClassInfo.describe( PopupContextMenu )</li>
		 *   <li>ClassInfo.describe( new Sprite() )</li>
		 *   <li>ClassInfo.describe( "flash.geom.Point" )</li>
		 * </ul></p>
		 *
		 * @param 	o	Overloading support
		 *
		 * @throws 	<code>IllegalArgumentException</code> - <code>o</code> is 
		 * 			not a valid object to describe.
		 *
		 * @return	Class or instance informations
		 */
		public static function describe( target : Object ) : ClassInfo
		{
			if( target is String )
			{
				try
				{
					target = getDefinitionByName( target as String );
				}
				catch( e : Error )
				{
					var msg : String = target + " class is not loaded in context.";
					PalmerDebug.ERROR( msg );
					throw( new IllegalArgumentException( msg ) );
					return null;    
				}
			}
			
			var clazzName : String = getQualifiedClassName( target );
			
			if( !_mCache.containsKey( clazzName ) )
			{
				_mCache.put( clazzName, new ClassInfo( target, ConstructorAccess.instance ) );      
			}
			
			return _mCache.get( clazzName ) as ClassInfo;
		}

		/**
		 * Releases <strong>ClassInfo</strong> instance for passed-in 
		 * <code>o</code> object.
		 *
		 * <p><span class="label"><b>Overloading</b></span>
		 * <ul>
		 *   <li>ClassInfo.release( PopupContextMenu )</li>
		 *   <li>ClassInfo.release( new PopupContextMenu() )</li>
		 *   <li>ClassInfo.release( "fever.ui.menu.PopupContextMenu" )</li>
		 * </ul></p>
		 *
		 * @param	o	Overloading support
		 */
		public static function release( target : Object ) : void
		{
			if( target is String )
			{
				try
				{
					target = getDefinitionByName( target as String );
				}
				catch( e : Error )
				{
					PalmerDebug.ERROR( target + " class is not loaded in context." );
					return;
				}
			}
            
			var clazzName : String = getQualifiedClassName( target );
                   
			if( _mCache.containsKey( clazzName ) )
			{
				var info : ClassInfo = _mCache.remove( clazzName ) as ClassInfo;
				info._clean( );
			}
		}

		/**
		 * Builds and returns instance of current class.
		 *
		 * @param	aArgs			arguments to apply to instanciation process
		 * @param	factoryMethod	factory method to use for instanciation
		 * @param	singletonAccess	singleton method to use for instanciation
		 *
		 * @throws	<code>NoSuchElementException</code> - <code>factoryMethod</code> 
		 * 			or <code>singletonAccess</code> parameters are defined 
		 * 			and not implemented in current class.<br />
		 * 			<code>static</code> flag test is done for 
		 * 			<code>singletonAccess</code> method name.
		 *
		 * @return	New instance of current class type
		 */
		public function buildInstance( 
				aArgs : Array = null,
                factoryMethod : String = null,
                singletonAccess : String = null ) : Object
		{
			if( factoryMethod != null && !containsMethod( factoryMethod ) )
			{
				throw new NoSuchElementException( "'" + factoryMethod + "( )'" + " method is not implemented in " + fullQualifiedName );
				return null;
			}
                   
			if( singletonAccess != null )
			{
				var method : MethodInfo = getMethod( singletonAccess );
                           
				if( method != null )
				{
					if( !method.staticFlag )
					{
						throw new NoSuchElementException( "'" + singletonAccess + "( )'" + " method is not static in " + fullQualifiedName );
                                           
						return null;    
					}
				}
				else
				{
					throw new NoSuchElementException( "'" + singletonAccess + "( )'" + " method is not implemented in " + fullQualifiedName );
                                           
					return null;    
				}
			}
            
			return CoreFactory.getInstance( ).buildInstance( fullQualifiedName, aArgs, factoryMethod, singletonAccess );
		}

		/**
		 * Returns extended super classes list.
		 */
		public function getSuperClasseList( ) : Array
		{
			return _aSuperList;
		}

		/**
		 * Returns extended super classes list.
		 */
		public function getSuperClasseIterator( ) : Iterator
		{
			return new ArrayIterator( _aSuperList );        
		}

		/**
		 * Returns implemented interfaces list.
		 */
		public function getInterfaceList() : Array
		{
			return _aInterfaceList;
		}

		/**
		 * Returns implemented interfaces iterator.
		 */
		public function getInterfaceIterator( ) : Iterator
		{
			return new ArrayIterator( _aInterfaceList );    
		}

		/**
		 * Returns constructor information.
		 */
		public function getConstructor( ) : MethodInfo
		{
			return _oConstuctor;
		}

		/**
		 * Returns class methods list.
		 *
		 * <p>Uses <code>filter</code> to retreive all methods, static methods
		 * or only factory methods.
		 * <ul>
		 *   <li>ClassInfo.NONE_FILTER ( default )</li>
		 *   <li>ClassInfo.STATIC_FILTER</li>
		 *   <li>ClassInfo.FACTORY_FILTER</li>
		 * </ul></p>
		 *
		 * @example
		 * <pre class="prettyprint">
		 *      
		 *      var info : ClassInfo = ClassInfo.describe( EventBroadcaster );
		 *      var all : Array = info.getMethodList();
		 *      var staticAndParent : Array = info.getMethodList( ClassInfo.STATIC_FILTER, true );
		 *      var staticOnlyOwner : Array = info.getMethodList( ClassInfo.STATIC_FILTER, false );
		 *      var factoryAndParent : Array = info.getMethodList( ClassInfo.FACTORY_FILTER, true );
		 *      var factoryOnlyOwner : Array = info.getMethodList( ClassInfo.FACTORY_FILTER, false );
		 * </pre>
		 *
		 * @param	filter		filtering method
		 * @param	inheritance	<code>true</code> to show elements in all 
		 * 						extends classes too, <code>false</code> 
		 * 						to filter current class only implementation.
		 *
		 * @return	Method list according passed-in filters
		 */
		public function getMethodList( filter : Number = NONE_FILTER, inheritance : Boolean = true ) : Array
		{
			switch( filter )
			{
				case STATIC_FILTER :
					return _aMethodList.filter( Delegate.create( _getStatic, inheritance ) );
				case FACTORY_FILTER :
					return _aMethodList.filter( Delegate.create( _getFactory, inheritance ) );
				default :
					return _aMethodList.filter( Delegate.create( _getInheritance, inheritance ) );
			}
		}

		/**
		 * Returns class methods iterator.
		 *
		 * <p>Uses <code>filter</code> to retreive all methods, static methods
		 * or only factory methods.
		 * <ul>
		 *   <li>ClassInfo.NONE_FILTER ( default )</li>
		 *   <li>ClassInfo.STATIC_FILTER</li>
		 *   <li>ClassInfo.FACTORY_FILTER</li>
		 * </ul></p>
		 *
		 * @example
		 * <pre class="prettyprint">
		 *      
		 *      var info : ClassInfo = ClassInfo.describe( EventBroadcaster );
		 *      var all : Iterator = info.getMethodIterator();
		 *      var staticAndParent : Iterator = info.getMethodIterator( ClassInfo.STATIC_FILTER, true );
		 *      var staticOnlyOwner : Iterator = info.getMethodIterator( ClassInfo.STATIC_FILTER, false );
		 *      var factoryAndParent : Iterator = info.getMethodIterator( ClassInfo.FACTORY_FILTER, true );
		 *      var factoryOnlyOwner : Iterator = info.getMethodIterator( ClassInfo.FACTORY_FILTER, false );
		 * </pre>
		 *
		 * @param	filter		filtering method
		 * @param	inheritance	<code>true</code> to show elements in all 
		 * 						extends classes too, <code>false</code> 
		 * 						to filter current class only implementation
		 *
		 * @return	an iterator throw methods collection
		 */
		public function getMethodIterator( filter : Number = NONE_FILTER, inheritance : Boolean = true ) : Iterator
		{
			return new ArrayIterator( getMethodList( filter, inheritance ) );
		}

		/**
		 * Returns class accessors list.
		 *
		 * <p>Uses <code>filter</code> to retreive all accessors, static accessors
		 * or only factory accessors.
		 * <ul>
		 *   <li>ClassInfo.NONE_FILTER ( default )</li>
		 *   <li>ClassInfo.STATIC_FILTER</li>
		 *   <li>ClassInfo.FACTORY_FILTER</li>
		 * </ul></p>
		 *
		 * @example
		 * <pre class="prettyprint">
		 *      
		 *      var info : ClassInfo = ClassInfo.describe( EventBroadcaster );
		 *      var all : Array = info.getAccessorList();
		 *      var staticAndParent : Array = info.getAccessorList( ClassInfo.STATIC_FILTER, true );
		 *      var staticOnlyOwner : Array = info.getAccessorList( ClassInfo.STATIC_FILTER, false );
		 *      var factoryAndParent : Array = info.getAccessorList( ClassInfo.FACTORY_FILTER, true );
		 *      var factoryOnlyOwner : Array = info.getAccessorList( ClassInfo.FACTORY_FILTER, false );
		 * </pre>
		 *
		 * @param	filter		filtering method
		 * @param	inheritance	<code>true</code> to show elements in all 
		 * 						extends classes too, <code>false</code> 
		 * 						to filter current class only implementation.
		 *
		 * @return	accessor list according passed-in filters
		 */
		public function getAccessorList( filter : Number = NONE_FILTER, inheritance : Boolean = true ) : Array
		{
			switch( filter )
			{
				case STATIC_FILTER :
					return _aAccessorList.filter( Delegate.create( _getStatic, inheritance ) );
				case FACTORY_FILTER :
					return _aAccessorList.filter( Delegate.create( _getFactory, inheritance ) );
				default :
					return _aAccessorList.filter( Delegate.create( _getInheritance, inheritance ) );
			}
		}

		/**
		 * Returns class accessors iterator.
		 *
		 * <p>Uses <code>filter</code> to retreive all accessors, static accessors
		 * or only factory accessors.
		 * <ul>
		 *   <li>ClassInfo.NONE_FILTER ( default )</li>
		 *   <li>ClassInfo.STATIC_FILTER</li>
		 *   <li>ClassInfo.FACTORY_FILTER</li>
		 * </ul></p>
		 *
		 * @example
		 * <pre class="prettyprint">
		 *      
		 *      var info : ClassInfo = ClassInfo.describe( EventBroadcaster );
		 *      var all : Iterator = info.getAccessorIterator();
		 *      var staticAndParent : Iterator = info.getAccessorIterator( ClassInfo.STATIC_FILTER, true );
		 *      var staticOnlyOwner : Iterator = info.getAccessorIterator( ClassInfo.STATIC_FILTER, false );
		 *      var factoryAndParent : Iterator = info.getAccessorIterator( ClassInfo.FACTORY_FILTER, true );
		 *      var factoryOnlyOwner : Iterator = info.getAccessorIterator( ClassInfo.FACTORY_FILTER, false );
		 * </pre>
		 *
		 * @param	filter		filtering method
		 * @param	inheritance	<code>true</code> to show elements in all 
		 * 			extends classes too, <code>false</code> to filter current 
		 * 			class only implementation
		 *
		 * @return	an iterator throw accessors collection
		 */
		public function getAccessorIterator( filter : Number = NONE_FILTER, inheritance : Boolean = true ) : Iterator
		{
			return new ArrayIterator( getAccessorList( filter, inheritance ) );
		}

		/**
		 * Returns class properties list.
		 *
		 * <p>Uses <code>filter</code> to retreive all properties,
		 * static properties or only factory properties.
		 * <ul>
		 *   <li>ClassInfo.NONE_FILTER ( default )</li>
		 *   <li>ClassInfo.STATIC_FILTER</li>
		 *   <li>ClassInfo.FACTORY_FILTER</li>
		 * </ul></p>
		 *
		 * @example
		 * <pre class="prettyprint">
		 *      
		 *      var info : ClassInfo = ClassInfo.describe( EventBroadcaster );
		 *      var all : Array = info.getPropertyList();
		 *      var staticProperties : Array = info.getPropertyList( ClassInfo.STATIC_FILTER );
		 *      var factoryProperties : Array = info.getPropertyList( ClassInfo.FACTORY_FILTER );
		 * </pre>
		 *
		 * @param	filter	filtering method
		 *
		 * @return	properties list according passed-in filters
		 */
		public function getPropertyList( filter : Number = NONE_FILTER ) : Array
		{
			var a : Array = _aPropertyList.filter( _isProperty );
			  
			switch( filter )
			{
				case STATIC_FILTER :
					return a.filter( Delegate.create( _getStatic, true ) );
				case FACTORY_FILTER :
					return a.filter( Delegate.create( _getFactory, true ) );
				default :
					return a;
			}
		}

		/**
		 * Returns class properties iterator.
		 *
		 * <p>Uses <code>filter</code> to retreive all properties,
		 * static properties or only factory properties.
		 * <ul>
		 *   <li>ClassInfo.NONE_FILTER ( default )</li>
		 *   <li>ClassInfo.STATIC_FILTER</li>
		 *   <li>ClassInfo.FACTORY_FILTER</li>
		 * </ul></p>
		 *
		 *  @example
		 * <pre class="prettyprint">
		 *      
		 *      var info : ClassInfo = ClassInfo.describe( EventBroadcaster );
		 *      var all : Iterator = info.getPropertyIterator();
		 *      var staticProperties : Iterator = info.getPropertyIterator( ClassInfo.STATIC_FILTER );
		 *      var factoryProperties : Iterator = info.getPropertyIterator( ClassInfo.FACTORY_FILTER );
		 * </pre>
		 *
		 * @param	filter	filtering method
		 *
		 * @return	an iterator throw properties collection
		 */
		public function getPropertyIterator( filter : Number = NONE_FILTER ) : Iterator
		{
			return new ArrayIterator( getPropertyList( filter ) );
		}

		/**
		 * Returns class constants list
		 *
		 * <p>Uses <code>filter</code> to retreive all constants,
		 * static constants or only factory constants.
		 * <ul>
		 *   <li>ClassInfo.NONE_FILTER ( default )</li>
		 *   <li>ClassInfo.STATIC_FILTER</li>
		 *   <li>ClassInfo.FACTORY_FILTER</li>
		 * </ul></p>
		 *
		 * @example
		 * <pre class="prettyprint">
		 *      
		 *      var info : ClassInfo = ClassInfo.describe( EventBroadcaster );
		 *      var all : Array = info.getContantList();
		 *      var staticProperties : Array = info.getContantList( ClassInfo.STATIC_FILTER );
		 *      var factoryProperties : Array = info.getContantList( ClassInfo.FACTORY_FILTER );
		 * </pre>
		 *
		 * @param	filter	filtering method
		 *
		 * @return	constants list according passed-in filters
		 */
		public function getContantList( filter : Number = NONE_FILTER ) : Array
		{
			var a : Array = _aPropertyList.filter( _isConstant );
                   
			switch( filter )
			{
				case STATIC_FILTER :
					return a.filter( Delegate.create( _getStatic, true ) );
				case FACTORY_FILTER :
					return a.filter( Delegate.create( _getFactory, true ) );
				default :
					return a;
			}
		}

		/**
		 * Returns class constants iterator.
		 *
		 * <p>Uses <code>filter</code> to retreive all constants,
		 * static constants or only factory constants.
		 * <ul>
		 *   <li>ClassInfo.NONE_FILTER ( default )</li>
		 *   <li>ClassInfo.STATIC_FILTER</li>
		 *   <li>ClassInfo.FACTORY_FILTER</li>
		 * </ul></p>
		 *
		 * @example
		 * <pre class="prettyprint">
		 *      
		 *      var info : ClassInfo = ClassInfo.describe( EventBroadcaster );
		 *      var all : Iterator = info.getConstantIterator();
		 *      var staticProperties : Iterator = info.getConstantIterator( ClassInfo.STATIC_FILTER );
		 *      var factoryProperties : Iterator = info.getConstantIterator( ClassInfo.FACTORY_FILTER );
		 * </pre>
		 *
		 * @param	filter	filtering method
		 *
		 * @return	an iterator throw constants collection
		 */
		public function getConstantIterator( filter : Number = NONE_FILTER ) : Iterator
		{
			return new ArrayIterator( getContantList( filter ) );
		}

		/**
		 * Returns <code>true</code> if passed-in <code>accessor</code>
		 * name is defined by current class.
		 *
		 * @param	accessor	name of the accessor to search
		 *
		 * @return	<code>true</code> if passed-in <code>accessor</code> 
		 * 			name is defined by current class, either <code>false</code>
		 */
		public function containsAccessor( accessor : String ) : Boolean
		{
			return _containsElementName( getAccessorIterator( ), accessor );
		}

		/**
		 * Returns <code>true</code> if passed-in <code>method</code>
		 * name is defined by current class.
		 *
		 * @param	method	name of the method to search
		 *
		 * @return	<code>true</code> if passed-in <code>method</code> name 
		 * 			is defined by current class, either <code>false</code>
		 */
		public function containsMethod( method : String ) : Boolean
		{
			return _containsElementName( getMethodIterator( ), method );
		}

		/**
		 * Returns <code>true</code> if passed-in <code>property</code>
		 * name is defined by current class.
		 *
		 * @param	property	name of the property to search
		 *
		 * @return	<code>true</code> if passed-in <code>property</code> name 
		 * 			is defined by current class, either <code>false</code>
		 */
		public function containsProperty( property : String ) : Boolean
		{
			return _containsElementName( getPropertyIterator( ), property );
		}

		/**
		 * Returns <strong>MethodInfo</strong> of method defined by passed-in
		 * <code>method</code> name.
		 *
		 * @param	method	name of the method to search
		 *
		 * @return	information about method ( or <code>null</code> )
		 */
		public function getMethod( method : String ) : MethodInfo
		{
			return  _getElementByName( getMethodIterator( ), method ) as MethodInfo;
		}

		/**
		 * Returns <strong>PropertyInfo</strong> of property defined by passed-in
		 * <code>property</code> name.
		 *
		 * @param	property	name of the property to search
		 *
		 * @return	information about property ( or <code>null</code> )
		 */
		public function getProperty( property : String ) : PropertyInfo
		{
			return  _getElementByName( getPropertyIterator( ), property ) as PropertyInfo;
		}

		/**
		 * Returns <strong>PropertyInfo</strong> of constant defined by 
		 * passed-in <code>constant</code> name.
		 *
		 * @param	constant	name of the constant to search
		 *
		 * @return	information about constant ( or <code>null</code> )
		 */
		public function getConstant( constant : String ) : PropertyInfo
		{
			return  _getElementByName( getConstantIterator( ), constant ) as PropertyInfo;
		}

		/**
		 * Returns <strong>AccessorInfo</strong> of accessor defined by 
		 * passed-in <code>accessor</code> name.
		 *
		 * @param	accessor	name of the accessor to search
		 *
		 * @return	information about accessor ( or <code>null</code> )
		 */
		public function getAccessor( accessor : String ) : AccessorInfo
		{
			return  _getElementByName( getAccessorIterator( ), accessor ) as AccessorInfo;
		}

		/**
		 * Returns string representation.
		 *
		 * @see #LINEBREAK
		 * @see #TAB
		 */
		public function toString( inheritance : Boolean = true ) : String
		{
			var result : String = "";
                   
			result += "Name " + name + LINEBREAK;
			result += "Package " + packageName + LINEBREAK;
			result += "Extends " + getSuperClasseList( ) + LINEBREAK;
			result += "Implements " + getInterfaceList( ) + LINEBREAK;
                   
			result += "Constants" + LINEBREAK;
			result += _stringify( getConstantIterator( ) );
                   
			result += "Properties" + LINEBREAK;
			result += _stringify( getPropertyIterator( ) );
                   
			result += "Accessors" + LINEBREAK;
			result += _stringify( getAccessorIterator( NONE_FILTER, inheritance ) );

			if( _oConstuctor != null )
			{
				result += "Constructor" + LINEBREAK;
				result += ( TAB + getConstructor( ).toString( ) + LINEBREAK );
			}
                   
			result += "Methods" + LINEBREAK;
			result += _stringify( getMethodIterator( NONE_FILTER, inheritance ) );

			return result;
		}

		
		//--------------------------------------------------------------------
		// Private implementations
		//--------------------------------------------------------------------
           
		/**
		 * @private
		 * Constuctor.
		 */
		function ClassInfo( o : Object, access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException( );
			
			_sFullName = getQualifiedClassName( o );
                   
			_oType = ( o is Class ) ? (o as Class) : getDefinitionByName( _sFullName ) as Class;
                   
			_xmlDesc = describeType( _oType );
            
			_buildSuperClass( );
			_buildInterfaces( );
			_buildConstructor( );
			_buildMethods( );

			_buildAccesssors( );
			_buildProperties( );
		}

		private function _buildSuperClass() : void
		{
			var x : XMLList = _xmlDesc.factory.extendsClass.@type;
                   
			_aSuperList = new Array( );
                   
			if( x.length( ) > 0 )
			{
				for each( var name : XML in x )
				{
					_aSuperList.push( name.toString( ) );
				}
			}
		}

		private function _buildInterfaces() : void
		{
			var x : XMLList = _xmlDesc.factory.implementsInterface.@type;
                   
			_aInterfaceList = new Array( );
                   
			if( x.length( ) > 0 )
			{
				for each( var name : XML in x )
				{
					_aInterfaceList.push( name.toString( ) );
				}
			}
		}

		private function _buildConstructor() : void
		{
			if( _xmlDesc.factory.constructor[0] != null )
			{
				_oConstuctor = new MethodInfo( _xmlDesc.factory.constructor[0] );  
			}
			else
			{
				_oConstuctor = null;
			}
		}

		private function _buildMethods() : void
		{
			var x : XMLList = _xmlDesc.factory.method;
                   
			_aMethodList = new Array( );
                   
			if( x.length( ) > 0 )
			{
				for each( var node : XML in x )
				{
					_aMethodList.push( new MethodInfo( node ) );
				}
			}
                   
			if( staticFlag )
			{
				x = _xmlDesc.method;      
				if( x.length( ) > 0 )
				{
					for each( var node2 : XML in x )
					{
						_aMethodList.push( new MethodInfo( node2, true ) );
					}
				}
			}
		}

		private function _buildAccesssors() : void
		{
			var x : XMLList = _xmlDesc.factory.accessor;
                   
			_aAccessorList = new Array( );
                   
			if( x.length( ) > 0 )
			{
				for each( var node : XML in x )
				{
					_aAccessorList.push( new AccessorInfo( node ) );
				}
			}
            
			if( staticFlag )
			{
				x = _xmlDesc.accessor;    
				if( x.length( ) > 0 )
				{
					for each( var node2 : XML in x )
					{
						if( node2.@name != 'prototype' )
                                                   _aAccessorList.push( new AccessorInfo( node2, true ) );
					}
				}
			}
		}

		private function _buildProperties() : void
		{
			var x : XMLList = _xmlDesc.factory.variable;
                   
			_aPropertyList = new Array( );
                   
			if( x.length( ) > 0 )
			{
				for each( var node : XML in x )
				{
					_aPropertyList.push( new PropertyInfo( node ) );
				}
			}
            
			if( staticFlag )
			{
				x = _xmlDesc.variable;    
                           
				if( x.length( ) > 0 )
				{
					for each( var node2 : XML in x )
					{
						_aPropertyList.push( new PropertyInfo( node2, true ) );
					}
				}
			}
                   
			_buildConstants( );
		}

		private function _buildConstants() : void
		{
			var x : XMLList = _xmlDesc.factory.constant;
                   
			if( x.length( ) > 0 )
			{
				for each( var node : XML in x )
				{
					_aPropertyList.push( new PropertyInfo( node, false, true ) );
				}
			}
			
			if( staticFlag )
			{
				x = _xmlDesc.constant;    
				if( x.length( ) > 0 )
				{
					for each( var node2 : XML in x )
					{
						_aPropertyList.push( new PropertyInfo( node2, true, true ) );
					}
				}
			}
		}

		private function _stringify( list : Iterator ) : String
		{
			var result : String = '';
                   
			while( list.hasNext( ) )
			{
				result += ( TAB + list.next( ).toString( ) + LINEBREAK );
			}
                   
			return result;
		}

		private function _getStatic( element : ElementInfo, index : int, arr : Array, inheritance : Boolean ) : Boolean
		{
			if( !inheritance )
			{
				return ( !element.staticFlag && element.declaredBy == fullQualifiedName );
			}
                   
			return ( element.staticFlag == true );
		}

		private function _getFactory( element : ElementInfo, index : int, arr : Array, inheritance : Boolean ) : Boolean
		{
			if( !inheritance )
			{
				return ( element.staticFlag && element.declaredBy == fullQualifiedName );
			}
                   
			return element.staticFlag;
		}

		private function _getInheritance( element : ElementInfo, index : int, arr : Array, inheritance : Boolean ) : Boolean
		{
			if( !inheritance )
			{
				return ( element.declaredBy == fullQualifiedName );
			}
                   
			return true;
		}

		private function _isProperty( element : PropertyInfo, index : int, arr : Array ) : Boolean
		{
			return ( element.constantFlag == false );
		}

		private function _isConstant( element : PropertyInfo, index : int, arr : Array ) : Boolean
		{
			return ( element.constantFlag == true );
		}

		private function _containsElementName( list : Iterator, sName : String ) : Boolean
		{
			while( list.hasNext( ) )
			{
				if( ( list.next( ) as ElementInfo ).name == sName )
                                   return true;    
			}
            
			return false;
		}
		
		private function _getElementByName( list : Iterator, sName : String ) : ElementInfo
		{
			while( list.hasNext( ) )
			{
				var o : ElementInfo = list.next( ) as ElementInfo;
                           
				if( o.name == sName ) return o;        
			}
                   
			return null;
		}
		
		private function _clean() : void
		{
			_xmlDesc = null;
			_sFullName = null;
			_oType = null;
			_aInterfaceList = null;
			_aSuperList = null;
			_oConstuctor = null;
			_aMethodList = null;
			_aAccessorList = null;
			_aPropertyList = null;
		}
	}
}

internal class ConstructorAccess 
{
	static public const instance : ConstructorAccess = new ConstructorAccess( );
}