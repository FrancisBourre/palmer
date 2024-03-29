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
	import net.pixlib.events.EventChannel;
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.log.Log;
	import net.pixlib.log.Logger;
	import net.pixlib.log.PalmerStringifier;	

	/**
	 * @author Francis Bourre
	 */
	public class PluginDebug implements Log
	{
		static public var isOn 	: Boolean = true;
		static private const _M : HashMap = new HashMap();

		protected var _channel 	: EventChannel;
		protected var _owner 	: Plugin;
		protected var _bIsOn 	: Boolean;

		public function PluginDebug(  access : ConstructorAccess, owner : Plugin = null ) 
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();

			_owner = owner;
			_channel = owner.getChannel();
			on();
		}
		
		public function getOwner() : Plugin
		{
			return _owner;
		}
		
		public function isOn() : Boolean
		{
			return _bIsOn;
		}
		
		public function on() : void
		{
			_bIsOn = true;
		}
		
		public function off() : void
		{
			_bIsOn = false;
		}

		public function getChannel() : EventChannel
		{
			return _channel;
		}
	
		static public function getInstance ( owner : Plugin = null ) : PluginDebug
		{
			if ( owner == null ) owner = NullPlugin.getInstance();
			if ( !(PluginDebug._M.containsKey( owner )) ) PluginDebug._M.put( owner, new PluginDebug( new ConstructorAccess(), owner ) );
			return PluginDebug._M.get( owner );
		}

		static public function release( owner : Plugin ) : Boolean
		{
			if ( PluginDebug._M.containsKey( owner ) ) 
			{
				PluginDebug._M.remove( owner );
				return true;

			} else
			{
				return false;
			}
		}

		public function debug( o : *, target : Object = null ) : void
		{
			if ( PluginDebug.isOn && _bIsOn ) Logger.DEBUG( o, _channel, target );
		}
		
		public function info( o : *, target : Object = null ) : void
		{
			if ( PluginDebug.isOn && _bIsOn ) Logger.INFO( o, _channel, target );
		}
		
		public function warn( o : *, target : Object = null ) : void
		{
			if ( PluginDebug.isOn && _bIsOn ) Logger.WARN( o, _channel, target );
		}
		
		public function error( o : *, target : Object = null ) : void
		{
			if ( PluginDebug.isOn && _bIsOn ) Logger.ERROR( o, _channel, target );
		}
		
		public function fatal( o : *, target : Object = null ) : void
		{
			if ( PluginDebug.isOn && _bIsOn ) Logger.FATAL( o, _channel, target );
		}
		
		public function clear( ) : void
		{
			if ( PluginDebug.isOn && _bIsOn ) Logger.CLEAR( _channel );
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