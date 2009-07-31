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
package net.pixlib.ioc.assembler.locator
{
	import net.pixlib.commands.Batch;
	import net.pixlib.core.AbstractLocator;
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.ioc.assembler.locator.Constructor;
	import net.pixlib.ioc.control.BuildFactory;
	import net.pixlib.plugin.Plugin;	

	/**
	 * @author Francis Bourre
	 */
	public class ConstructorExpert 
		extends AbstractLocator
	{
		static private var _oI : ConstructorExpert;

		static public function getInstance() : ConstructorExpert 
		{
			if ( !(ConstructorExpert._oI is ConstructorExpert) ) 
				ConstructorExpert._oI = new ConstructorExpert( new ConstructorAccess() );

			return ConstructorExpert._oI;
		}

		static public function release() : void
		{
			ConstructorExpert._oI = null;
		}

		public function ConstructorExpert( access : ConstructorAccess )
		{
			super( Constructor, null, null );
			
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}
		
		public function buildObject( id : String ) : void
		{
			if ( isRegistered( id ) )
			{
				var cons : Constructor = locate( id ) as Constructor;
				
				if ( cons.arguments != null )  cons.arguments = PropertyExpert.getInstance().deserializeArguments( cons.arguments );
				
				var o : * = BuildFactory.getInstance().build( cons, id );
				if( o is Plugin ) PluginExpert.getInstance().register( id, o );
				
				unregister( id );
			}
		}

		public function buildAllObjects() : void
		{
			Batch.process( buildObject, getKeys() );
		}
	}
}

internal class ConstructorAccess {}