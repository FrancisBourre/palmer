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
	import net.pixlib.exceptions.NoSuchElementException;
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.structures.Dimension;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * The DisplayUtil utility class is an all-static class with methods for 
	 * working with DislayObject objects.
	 * 
	 * @author Romain Ecarnot
	 */
	final public class DisplayUtil 
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates <code>Sprite</code> object using passed-in 
		 * <code>linkage</code> ActionScript export identifier.
		 * 
		 * <p>If <code>parent</code> is not <code>null</code>, Sprite is 
		 * automatically added into <code>parent</code> childs list.</p>
		 * 
		 * @param	linkage	ActionScript export identifier
		 * @param	parent	(optional) Created object's parent
		 * @param	domain	(optional) Domain where <code>linkage</code> is 
		 * 					defined.
		 */
		public static function attachSprite( linkage : String, parent : DisplayObjectContainer = null, domain : ApplicationDomain = null ) : Sprite
		{
			return _attachObject( linkage, parent, domain ) as Sprite;
		}

		/**
		 * Creates <code>MovieClip</code> object using passed-in 
		 * <code>linkage</code> ActionScript export identifier.
		 * 
		 * <p>If <code>parent</code> is not <code>null</code>, MovieClip is 
		 * automatically added into <code>parent</code> childs list.</p>
		 * 
		 * @param	linkage	ActionScript export identifier
		 * @param	parent	(optional) Created object's parent
		 * @param	domain	(optional) Domain where <code>linkage</code> is 
		 * 					defined.
		 */
		public static function attachMovie( linkage : String, parent : DisplayObjectContainer = null, domain : ApplicationDomain = null ) : MovieClip
		{
			return _attachObject( linkage, parent, domain ) as MovieClip;
		}

		/**
		 * Resizes passed-in <code>object</code> in <code>max</code> dimension.
		 * 
		 * <p>If <code>debug</code> is <code>true</code>, logs source and 
		 * result dimension using <strong>Palmer</strong> Loggin API.</p>
		 * 
		 * @param object	Object to resize
		 * @param max		Maximum dimension for resizing
		 * @param debug		(optional) Logs (or not) output messages 
		 * 					( default is <code>false</code> )
		 */
		public static function resize( object : DisplayObject, max : Dimension, debug : Boolean = false ) : void
		{
			if( ( object == null ) || ( max == null ) ) return;
			 
			if( object.width > max.width || object.height > max.height )
			{
				if( debug )
				{
					PalmerDebug.DEBUG( _stringify( ) + " source = " + object.width + "x" + object.height );
					PalmerDebug.DEBUG( _stringify( ) + " bounds = " + max.width + "x" + max.height );
				}
				
				var ratio : Number = object.height / object.width;
				
				if (object.width > max.width) 
				{
					object.width = max.width;
					object.height = Math.round( object.width * ratio );
				}
				
				if (object.height > max.height ) 
				{
					object.height = max.height;
					object.width = Math.round( object.height / ratio );
				}
				
				if( debug ) PalmerDebug.DEBUG( _stringify( ) + " resize = " + object.width + "x" + object.height );
			}
		}

		/**
		 * Retreives and returns <code>container</code> child using passed-in <code>label</code> child names chain.
		 * 
		 * @param 	container		Target container
		 * @param	label			Child names chain
		 * @param	throwException	(optional)<code>true</code> to throw <code>NoSuchElementException</code> exeption if
		 * 							child is not found. Either, only return <code>null</code> without exception thrown.
		 * 							
		 * @return Container child or <code>null</code> if not find in container.
		 */
		public static function resolveUI( container : DisplayObject, label : String, throwException : Boolean = true  ) : DisplayObject
		{
			var target : DisplayObject = container;
			
			var a : Array = label.split( "." );
			var l : int = a.length;
			
			for ( var i : int = 0; i < l ; i++ )
			{
				var name : String = a[ i ];
				if ( (target as DisplayObjectContainer).getChildByName( name ) != null )
				{
					target = (target as DisplayObjectContainer).getChildByName( name );
				}
				else
				{
					if ( throwException )
					{
						var msg : String = _stringify( ) + ".resolveUI(" + label + ") failed on " + container;
						PalmerDebug.ERROR( msg );
						throw new NoSuchElementException( msg );
					}
					
					return null;
				}
			}
			
			return target;
		}

		/**
		 * 
		 */
		public static function resolveFunction( container : DisplayObject, label : String  , throwException : Boolean = true ) : Function
		{
			var a : Array = label.split( "." );
			var f : String = a.pop( );
			var target : DisplayObjectContainer = resolveUI( container, a.join( "." ), false ) as DisplayObjectContainer ; 
			
			if ( target.hasOwnProperty( f ) && target[f] is Function  )
			{
				return target[f] ;
			}
			else
			{
				if ( throwException ) 
				{
					var msg : String = _stringify( ) + ".resolveFunction(" + label + ") failed on " + container;
					PalmerDebug.ERROR( msg );
					throw new NoSuchElementException( msg );
				}
			}
			
			return null;
		}

		/**
		 * Calls passed-in <code>callback</code> on all <code>target</code> display tree child.
		 * 
		 * @param 	target			Displayobject target
		 * @param 	callback		Function to call on each tree child
		 * @param	processOwner	<code>true</code>(default) to call function on <code>target</code>
		 */
		public static function callOnDisplayTree( target : DisplayObject, callback : Function, processOwner : Boolean = true ) : void
		{
			if( processOwner ) callback( target );
			
			if ( target is DisplayObjectContainer )
			{
				var l : int = DisplayObjectContainer( target ).numChildren;
				
				for (var i : uint = 0; i < l ; i++)
				{
					callOnDisplayTree( DisplayObjectContainer( target ).getChildAt( i ), callback, true );
				}
			}
		}

		/**
		 * Returns tree path in dot syntax for passed-in display object.
		 * 
		 * @return tree path in dot syntax for passed-in display object
		 */
		public static function getTreePath( target : DisplayObject ) : String
		{
			var result : String;
			
			try
			{
				for ( var o : DisplayObject = target; o != null ; o = o.parent )
				{
					if (o.parent && o.stage && o.parent == o.stage)  break;
                   
					result = result == null ? o.name : o.name + "." + result;
				}
			}
			catch ( e : Error )
			{
			}
        	
			return result;
		}
		
		/**
		 * Creates an unique name for passed-in object.
		 * 
		 * <p>Name is created using <code>HashCodeFactory.getNextKey()</code> 
		 * method and the type of passed-in object.</p>
		 * 
		 * @param object	Object requiring a name
		 * 
		 * @return String containing the object name 
		 */
		public static function createUniqueName( object : Object ) : String
		{
			var key : String = HashCodeFactory.getKey( object );
			var name : String = getQualifiedClassName( object );
			var index : int = name.indexOf( "::" );
			if (index != -1) name = name.substr( index + 2 );
			
			return name + "_" + key.substr( HashCodeFactory.PREFIX.length + 1 );
		}
		
		/**
		 * Removes all childrens of passed-in <code>container</code>.
		 * 
		 * @param container	DisplayObjectContainer to empty
		 */
		public static function removeAllChildren( container : DisplayObjectContainer ) : void 
		{
			while( container.numChildren > 0 ) container.removeChildAt( 0 );
		}
		

		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------

		private static function _attachObject( linkage : String, parent : DisplayObjectContainer = null, domain : ApplicationDomain = null ) : * 
		{
			try
			{
				var clazz : Class = domain ? domain.getDefinition( linkage ) as Class : getDefinitionByName( linkage ) as Class;
				
				if( parent != null )
				{
					return parent.addChild( new clazz( ) );
				}
				else return new clazz( );
			}	
			catch( e : ReferenceError )
			{
				PalmerDebug.ERROR( _stringify( ) + "::" + e.message );
			}
			
			return null;
		}

		private static function _stringify() : String
		{
			return PalmerStringifier.stringify( DisplayUtil );	
		}

		/** @private */
		function DisplayUtil( )
		{
		}
	}
}
