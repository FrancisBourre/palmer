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
 
package com.bourre.ioc.assembler.locator
{
	import com.bourre.core.AbstractLocator;
	import com.bourre.exceptions.PrivateConstructorException;	

	/**
	 * The ImportExpert class is a locator for 
	 * <code>Import</code> object.
	 * 
	 * @see Import
	 * 
	 * @author Romain Ecarnot
	 */
	public class ImportExpert extends AbstractLocator
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
				
		private static var _oI : ImportExpert;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Returns unique instance of IncludeExpert class.
		 */
		public static function getInstance() : ImportExpert 
		{
			if ( !(ImportExpert._oI is ImportExpert) ) 
				ImportExpert._oI = new ImportExpert( new ConstructorAccess() );

			return ImportExpert._oI;
		}
		
		/**
		 * Release instance.
		 */
		public static  function release() : void
		{
			if( ImportExpert._oI is ImportExpert ) _oI.release();			ImportExpert._oI = null;
		}
		
		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
		
		/** @private */
		function ImportExpert( access : ConstructorAccess )
		{
			super( Import, null, null );
			
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}
				
	}
}

internal class ConstructorAccess {}