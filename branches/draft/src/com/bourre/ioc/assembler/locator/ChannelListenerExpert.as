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
	import com.bourre.ioc.assembler.locator.ChannelListener;
	import com.bourre.commands.Batch;
	import com.bourre.core.AbstractLocator;
	import com.bourre.core.CoreFactory;
	import com.bourre.events.ApplicationBroadcaster;
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.plugin.PluginChannel;	

	/**
	 * @author Francis Bourre
	 */
	public class ChannelListenerExpert 
		extends AbstractLocator
	{
		static private var _oI : ChannelListenerExpert;

		static public function getInstance() : ChannelListenerExpert
		{
			if ( !(ChannelListenerExpert._oI is ChannelListenerExpert) ) 
				ChannelListenerExpert._oI = new ChannelListenerExpert( new ConstructorAccess() );

			return ChannelListenerExpert._oI;
		}
		
		static public function release():void
		{
			ChannelListenerExpert._oI = null ;
		}
		
		public function ChannelListenerExpert( access : ConstructorAccess )
		{
			super( ChannelListener, null, null );

			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}
		
		public function assignAllChannelListeners() : void
		{
			Batch.process( assignChannelListener, getKeys() );
		}
		
		public function assignChannelListener( id : String ) : Boolean
		{
			var channelListener : ChannelListener = locate( id ) as ChannelListener;
			var listener : Object = CoreFactory.getInstance().locate( channelListener.listenerID );
			var channel : PluginChannel = PluginChannel.getInstance( channelListener.channelName );

			var args : Array = channelListener.arguments;
			
			if ( args && args.length > 0 )
			{
				var l : int = args.length;
				for ( var i : int; i < l; i++ )
				{
					var o : Object = args[ i ];
					var method : String = o.method;
					listener = ( method && listener.hasOwnProperty(method) && listener[method] is Function) ? listener[method] : listener[o.type];
					ApplicationBroadcaster.getInstance().addEventListener( o.type, listener, channel );
				}

				return true;

			} else 
			{
				return ApplicationBroadcaster.getInstance().addListener( listener, channel );
			}
		}
	}
}

internal class ConstructorAccess {}