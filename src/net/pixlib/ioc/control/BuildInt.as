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
	import net.pixlib.events.ValueObjectEvent;
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.ioc.assembler.locator.Constructor;
	
	import flash.events.Event;	

	/**
	 * @author Francis Bourre
	 */
	public class BuildInt
		extends AbstractCommand
	{
		override protected function onExecute( e : Event = null ) : void 
		{
			var constructor : Constructor = ( e as ValueObjectEvent ).getValueObject( ) as Constructor;

			var args : Array = constructor.arguments;
			var n : Number = NaN;

			if ( args != null && args.length > 0 ) n = parseInt( ( args[0] ).toString() );

			if ( !isNaN(n) && n <= int.MAX_VALUE && n >= int.MIN_VALUE ) 
			{
				constructor.result = new int( n );

			} else
			{
				var msg : String = this + ".build(" + n + ") failed.";
				getLogger().fatal( msg );
				throw new IllegalArgumentException( msg );
			}

			fireCommandEndEvent();
		}
	}
}