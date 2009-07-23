package com.bourre.ioc.assembler.locator 
{
	import com.bourre.ioc.assembler.locator.Property;
	import com.bourre.log.PalmerStringifier;	
	
	/**
	 * @author Francis Bourre
	 */
	public class DictionaryItem 
	{
		protected var _pKey : Property;
		protected var _pValue : Property;
		
		public var key : Object;
		public var value : Object;

		public function DictionaryItem ( key : Property, value : Property ) 
		{
			_pKey = key;
			_pValue = value;
		}

		public function getPropertyKey() : Property
		{
			return _pKey;
		}

		public function getPropertyValue() : Property
		{
			return _pValue;
		}

		/**
		 * Returns the string representation of this instance.
		 * @return the string representation of this instance
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this ) + " [key:" + getPropertyKey() + ", value:" + getPropertyValue() + "]";
		}
	}
}