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
	 * The ResourceExpert class is a locator for 
	 * <code>Resource</code> object.
	 * 
	 * @see Resource
	 * 
	 * @author Francis Bourre
	 */
	public class ResourceExpert extends AbstractLocator
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
				
		private static var _oI : ResourceExpert;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Returns unique instance of ResourceExpert class.
		 */
		public static function getInstance() : ResourceExpert 
		{
			if ( !(ResourceExpert._oI is ResourceExpert) ) 
				ResourceExpert._oI = new ResourceExpert( new ConstructorAccess() );

			return ResourceExpert._oI;
		}
		
		/**
		 * Release instance.
		 */
		public static  function release() : void
		{
			_oI.release();
		}
		
		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
		
		/** @private */
		function ResourceExpert( access : ConstructorAccess )
		{
			super( Resource, null, null );
			
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}
				
	}
}

internal class ConstructorAccess {}