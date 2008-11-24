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
package com.bourre.ioc.assembler 
{
	import com.bourre.commands.Batch;
	import com.bourre.core.AbstractLocator;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.ioc.control.BuildFactory;
	import com.bourre.ioc.parser.ContextTypeList;	

	/**
	 * @author Francis Bourre
	 */
	public class MethodExpert 
		extends AbstractLocator
	{
		static private var	_oI	: MethodExpert;

		static public function getInstance() : MethodExpert
		{
			if ( !(MethodExpert._oI is MethodExpert) ) 
				MethodExpert._oI = new MethodExpert( new ConstructorAccess() );

			return MethodExpert._oI;
		}

		static public function release() : void
		{
			MethodExpert._oI = null;
		}

		public function MethodExpert( access : ConstructorAccess )
		{
			super( Method, MethodExpertListener, null );

			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}
		
		override protected function onRegister( id : String = null, method : Object = null ) : void
		{
			broadcastEvent( new MethodEvent( MethodEvent.onRegisterMethodEVENT, id, method as Method ) );
		}

		override protected function onUnregister( id : String = null ) : void
		{
			broadcastEvent( new MethodEvent( MethodEvent.onUnregisterMethodEVENT, id ) );
		}

		public function callMethod( id : String ) : void
		{
			var msg : String;

			var method : Method = locate( id ) as Method;
			var cons : Constructor = new Constructor( null, ContextTypeList.FUNCTION, [ method.ownerID + "." + method.name ] );
			var f : Function = BuildFactory.getInstance().build( cons );

			var args : Array = PropertyExpert.getInstance().deserializeArguments( method.arguments );

			try
			{
				f.apply( null, args );

			} catch ( error2 : Error )
			{
				msg = error2.message;
				msg += " " + this + ".callMethod() failed on instance with id '" + method.ownerID + "'. ";
				msg += "'" + method.name + "' method can't be called with these arguments: [" + args + "]";
				getLogger().fatal( msg );
				throw new IllegalArgumentException( msg );
			}
		}

		public function callAllMethods() : void
		{
			Batch.process( callMethod, getKeys() );
		}

		public function addListener( listener : MethodExpertListener ) : Boolean
		{
			return getBroadcaster().addListener( listener );
		}

		public function removeListener( listener : MethodExpertListener ) : Boolean
		{
			return getBroadcaster().removeListener( listener );
		}
	}
}

internal class ConstructorAccess {}