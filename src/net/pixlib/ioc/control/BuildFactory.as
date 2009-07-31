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
package net.pixlib.ioc.control
{
	import net.pixlib.collections.HashMap;
	import net.pixlib.commands.Command;
	import net.pixlib.core.CoreFactory;
	import net.pixlib.events.ValueObjectEvent;
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.ioc.assembler.locator.Constructor;
	import net.pixlib.ioc.core.ContextTypeList;
	import net.pixlib.log.PalmerStringifier;	

	/**
	 * @author Francis Bourre
	 */
	public class BuildFactory
	{
		static private var _oI : BuildFactory = null;

		/**
		 * @return singleton instance of BuildFactory
		 */
		static public function getInstance() : BuildFactory 
		{
			if ( _oI == null ) _oI = new BuildFactory( new PrivateConstructorAccess() );
			return _oI;
		}

		private var _m : HashMap;

		public function BuildFactory( access : PrivateConstructorAccess )
		{
			if ( !(access is PrivateConstructorAccess) ) throw new PrivateConstructorException();
			
			init();
		}

		public function init() : void
		{
			_m = new HashMap();

			addType( ContextTypeList.ARRAY, new BuildArray() );
			addType( ContextTypeList.BOOLEAN, new BuildBoolean() );
			addType( ContextTypeList.INSTANCE, new BuildInstance() );
			addType( ContextTypeList.INT, new BuildInt() );
			addType( ContextTypeList.NULL, new BuildNull() );
			addType( ContextTypeList.NUMBER, new BuildNumber() );
			addType( ContextTypeList.OBJECT, new BuildObject() );
			addType( ContextTypeList.STRING, new BuildString() );
			addType( ContextTypeList.UINT, new BuildUint() );
			addType( ContextTypeList.DEFAULT, new BuildString() );
			addType( ContextTypeList.DICTIONARY, new BuildDictionary() );
			addType( ContextTypeList.CLASS, new BuildClass() );
			addType( ContextTypeList.XML, new BuildXML() );
			addType( ContextTypeList.FUNCTION, new BuildFunction() );
		}
		
		/**
		 * Adds new command to build a new object of type paased-in.
		 *
		 * @param	type	Object type to build
		 * @param	build	Command to use to build the object
		 */
		public function addType( type : String, build : Command ) : void
		{
			_m.put( type, build );
		}
		
		public function build( constructor : Constructor, id : String = null ) : *
		{
			var type : String = constructor.type;
			var cmd : Command = ( _m.containsKey( type ) ) ? _m.get( type ) as Command : _m.get( ContextTypeList.INSTANCE ) as Command;
			cmd.execute( new ValueObjectEvent( type, this, constructor ) );
			
			if ( id ) CoreFactory.getInstance().register( id, constructor.result );
			
			return constructor.result;
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

internal class PrivateConstructorAccess{}