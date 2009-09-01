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
	import net.pixlib.commands.AbstractCommand;
	import net.pixlib.core.CoreFactory;
	import net.pixlib.events.ValueObjectEvent;
	import net.pixlib.ioc.assembler.locator.Constructor;
	import net.pixlib.ioc.assembler.locator.ConstructorExpert;
	import net.pixlib.utils.ObjectUtils;
	
	import flash.events.Event;	

	/**
	 * @author Francis Bourre
	 */
	public class BuildRef 
		extends AbstractCommand
	{
		override protected function onExecute( e : Event = null ) : void
		{
			var constructor : Constructor = ( e as ValueObjectEvent ).getValueObject() as Constructor;

			var key : String = constructor.ref;
			if ( key.indexOf(".") != -1 ) key = String( (key.split(".")).shift() );

			if ( !(CoreFactory.getInstance().isRegistered( key )) )
				ConstructorExpert.getInstance().buildObject( key );
				
			constructor.result = CoreFactory.getInstance().locate( key );

			if ( constructor.ref.indexOf(".") != -1 )
			{
				var args : Array = constructor.ref.split(".");
                args.shift();
                constructor.result =  ObjectUtils.evalFromTarget( constructor.result, args.join(".") );
			}

			fireCommandEndEvent();
		}
	}
}