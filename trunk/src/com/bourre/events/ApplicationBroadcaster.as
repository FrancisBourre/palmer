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
package com.bourre.events
{
	import com.bourre.plugin.PluginBroadcaster;	

	/**
	 * @author 	Francis Bourre
	 */
	public class ApplicationBroadcaster	extends ChannelBroadcaster
	{
		static private var _oI : ApplicationBroadcaster;

		public const NO_CHANNEL : EventChannel = new NoChannel();
		public const SYSTEM_CHANNEL : EventChannel = new SystemChannel();

		static public function getInstance () : ApplicationBroadcaster 
		{
			if ( !(ApplicationBroadcaster._oI is ApplicationBroadcaster) ) ApplicationBroadcaster._oI = new ApplicationBroadcaster( new ConstructorAccess( ) );
			return ApplicationBroadcaster._oI;
		}

		public function ApplicationBroadcaster ( access : ConstructorAccess )
		{
			super( PluginBroadcaster, SYSTEM_CHANNEL );
		}

		override public function getChannelDispatcher ( channel : EventChannel = null, owner : Object = null ) : Broadcaster
		{
			return ( channel != NO_CHANNEL ) ? super.getChannelDispatcher( channel, owner ) : null;
		}
	}
}

import com.bourre.events.EventChannel;

internal class NoChannel extends EventChannel{}
internal class SystemChannel extends EventChannel{}
internal class ConstructorAccess {}