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
package net.pixlib.structures 
{
	import net.pixlib.log.PalmerStringifier;

	import flash.geom.Point;

	/**
	 * The Dimension class encapsulates the width and height
	 * of an object (in double precision) in a single object.
	 * <p>
	 * Normally the values of width and height are non-negative
	 * integers. The constructors that allow you to create
	 * a dimension do not prevent you from setting a negative
	 * value for these properties. If the value of width or height
	 * is negative, the behavior of some methods defined by other
	 * objects is undefined. 
	 * </p>
	 * @author Cédric Néhémie
	 */
	public class Dimension 
	{
		/**
		 * The width dimension, negative values can be used. 
		 */
		public var width : Number;
		
		/**
		 * The height dimension, negative values can be used. 
		 */
		public var height : Number;
		
		/**
		 * Constructs a Dimension and initializes it
		 * to the specified width and specified height. 
		 * 
		 * @param	width	specified width
		 * @param	height	specified height
		 */
		public function Dimension ( width : Number = 0, height : Number = 0 )
		{
			this.width = width;
			this.height = height;
		}
		
		/**
		 * Checks whether two dimension objects have equal values.
		 * 
		 * @param	dimension	the reference object with which to compare.
		 * @return	<code>true</code> if this object is the same as the obj
		 * 			argument, <code>false</code> otherwise.
		 */
		public function equals ( dimension : Dimension ) : Boolean
		{
			return (width == dimension.width && height == dimension.height );
		}
		
		/**
		 * Sets the size of this Dimension object to the specified size.
		 * 
		 * @param	dimension	the new size for this Dimension object
		 */
		public function setSize ( dimension : Dimension ) : void
		{
			width = dimension.width;
			height = dimension.height;
		}
		/**
		 * Sets the size of this Dimension object to the specified width and height.
		 * 
		 * @param	width	the new width for this Dimension object
		 * @param	height	the new height for this Dimension object
		 */
		public function setSizeWH ( width : Number, height : Number ) : void
		{
			this.width = width;
			this.height = height;
		}
		/**
		 * Returns a copy of this Dimension object.
		 * 
		 * @return	a copy of this Dimension object
		 */
		public function clone() : Dimension
		{
			return new Dimension ( width, height );
		}
		
		/**
		 * Scales dimension using passed-in <code>n</code> factor.
		 * 
		 * <p>Instance is not altered.</p>
		 * 
		 * @param	n	Scale factor
		 */
		public function scale ( n : Number ) : Dimension
		{
			return new Dimension( width * n, height * n );
		}
		
		/**
		 * Substracts passed-in <code>size</code> dimension from 
		 * current instance size.
		 * 
		 * <p>Instance is not altered.</p>
		 * 
		 * @param	size	Dimension to substract
		 */
		public function substract( size : Dimension ) : Dimension
		{
			return new Dimension( width - size.width, height - size.height );
		}
		
		/**
		 * Adds passed-in <code>size</code> dimension to 
		 * current instance size.
		 * 
		 * <p>Instance is not altered.</p>
		 * 
		 * @param	size	Dimension to add
		 */
		public function add( size : Dimension ) : Dimension
		{
			return new Dimension( width + size.width, height + size.height );
		}
		
		/**
		 * Returns a Point object with its x and y sets
		 * respectively on width and height of this 
		 * Dimension.
		 * 
		 * @return	a Point object which contains values
		 * 			of this Dimension
		 */
		public function toPoint () : Point
		{
			return new Point( width, height );
		}
		
		/**
		 * Returns the String representation of this object.
		 * 
		 * @return	the String representation of this object
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify ( this ) + "[" + width + ", " + height +"]";
		}	
	}
}
