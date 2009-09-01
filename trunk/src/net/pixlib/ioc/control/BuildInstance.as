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
	import net.pixlib.commands.AbstractCommand;	import net.pixlib.commands.Command;	import net.pixlib.core.CoreFactory;	import net.pixlib.events.ValueObjectEvent;	import net.pixlib.ioc.assembler.locator.Constructor;	import net.pixlib.plugin.ChannelExpert;	import net.pixlib.plugin.Plugin;	import net.pixlib.plugin.PluginChannel;	import net.pixlib.utils.ClassUtils;		import flash.events.Event;	import flash.utils.getDefinitionByName;	
	/**
	 * @author Francis Bourre
	 */
	public class BuildInstance
		extends AbstractCommand
	{
		override protected function onExecute( e : Event = null ) : void
		{
			var constructor : Constructor = ( e as ValueObjectEvent ).getValueObject() as Constructor;

			if ( constructor.ref )
			{
				var cmd : Command = new BuildRef();
				cmd.execute( e );

			} else
			{
				try
				{
					var isPlugin : Boolean = ClassUtils.inherit( getDefinitionByName( constructor.type ) as Class, Plugin );
	
					if ( isPlugin && constructor.id != null && constructor.id.length > 0 ) 
						ChannelExpert.getInstance().registerChannel( PluginChannel.getInstance( constructor.id ) );
	
				} catch ( error1 : Error )
				{
					// do nothing as expected
				}

				BuildInstance.buildConstructor( constructor );
			}

			fireCommandEndEvent();
		}
		
		static public function buildConstructor( cons : Constructor ) : void
		{
			try
			{
				cons.result = CoreFactory.getInstance().buildInstance( cons.type, cons.arguments, cons.factory, cons.singleton );

			} catch ( e : Error )
			{
				throw e;
			}
		}
	}
}