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
package net.pixlib.plugin
{
	import net.pixlib.collections.HashMap;
	import net.pixlib.events.ApplicationBroadcaster;
	import net.pixlib.events.EventChannel;
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.log.PalmerStringifier;
	
	import flash.utils.Dictionary;	

	/**
	 * @author Francis Bourre
	 * @author Romain Flacher
	 */
	public class ChannelExpert
	{
		static private var _oI 	: ChannelExpert;
		static private var _N 	: uint = 0;

		private var _m 				: HashMap;
		private var _oRegistered 	: Dictionary;
		
		/**
		 * @return singleton instance of ChannelExpert
		 */
		static public function getInstance() : ChannelExpert 
		{
			if ( !( ChannelExpert._oI is ChannelExpert ) ) ChannelExpert._oI = new ChannelExpert( new ConstructorAccess() );
			return ChannelExpert._oI;
		}
		
		static public function release():void
		{
			if ( ChannelExpert._oI is ChannelExpert ) 
			{
				ChannelExpert._oI = null;
				ChannelExpert._N = 0;
			}
		}
		
		public function ChannelExpert( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
			
			_m = new HashMap();
			_oRegistered = new Dictionary( true );
		}
		
		public function getChannel( o : Plugin ) : EventChannel
		{
			if( _oRegistered[o] == null )
			{
				if ( _m.containsKey( ChannelExpert._N ) )
				{
					var channel : EventChannel = _m.get( ChannelExpert._N ) as EventChannel;
					_oRegistered[o] = channel;
					++ ChannelExpert._N;
					return channel;
		
				} else
				{
					PluginDebug.getInstance().debug( this + ".getChannel() failed on " + o );
					_oRegistered[o] = ApplicationBroadcaster.getInstance().NO_CHANNEL;
					return ApplicationBroadcaster.getInstance().NO_CHANNEL;
				}
			}
			else
			{
				 return _oRegistered[o] as EventChannel;
			}
		}
		
		public function releaseChannel( o : Plugin ) : Boolean
		{
			if( _oRegistered[o] )
			{
				if ( _m.containsKey( o.getChannel() ) ) _m.remove( o.getChannel() );
				_oRegistered[o] = null;

				return true;
			}
			else
			{
				 return false;
			}
		}
		
		public function registerChannel( channel : EventChannel ) : void
		{
			_m.put( ChannelExpert._N, channel );
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

internal class ConstructorAccess {}