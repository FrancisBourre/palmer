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
package net.pixlib.log 
{
	import net.pixlib.events.EventChannel;
	import net.pixlib.exceptions.PrivateConstructorException;

	/**
	 * @author Francis Bourre
	 */
	public final class PalmerDebug implements Log
	{
		static private var _oI : PalmerDebug;

		public const channel : EventChannel = new PixlibDebugChannel();
		protected var _bIsOn : Boolean;

		public function PalmerDebug( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
			on();
		}

		static public function getInstance() : Log
		{
			if ( !( PalmerDebug._oI is PalmerDebug ) ) PalmerDebug._oI = new PalmerDebug( new ConstructorAccess() );
			return PalmerDebug._oI;
		}

		static public function get CHANNEL() : EventChannel
		{
			return PalmerDebug.getInstance().getChannel();
		}

		static public function get isOn() : Boolean
		{
			return PalmerDebug.getInstance().isOn();
		}

		static public function set isOn( b : Boolean ) : void
		{
			if ( b ) PalmerDebug.getInstance().on(); else PalmerDebug.getInstance().off();
		}

		static public function DEBUG( o : *, target : Object = null ) : void
		{
			PalmerDebug.getInstance().debug( o, target );
		}

		static public function INFO( o : *, target : Object = null ) : void
		{
			PalmerDebug.getInstance().info( o, target );
		}

		static public function WARN( o : *, target : Object = null ) : void
		{
			PalmerDebug.getInstance().warn( o, target );
		}

		static public function ERROR( o : *, target : Object = null ) : void
		{
			PalmerDebug.getInstance().error( o, target );
		}
		
		static public function FATAL( o : *, target : Object = null ) : void
		{
			PalmerDebug.getInstance().fatal( o, target );
		}
		
		static public function CLEAR(  ) : void
		{
			PalmerDebug.getInstance().clear( );
		}
		
		/**
		 * @inheritDoc
		 */
		public function debug(o : *, target : Object = null) : void
		{
			if ( isOn() ) Logger.DEBUG ( o, channel, target );
		}
		
		/**
		 * @inheritDoc
		 */
		public function info(o : *, target : Object = null) : void
		{
			if ( isOn() ) Logger.INFO ( o, channel, target );
		}
		
		/**
		 * @inheritDoc
		 */
		public function warn(o : *, target : Object = null) : void
		{
			if ( isOn() ) Logger.WARN ( o, channel, target );
		}
		
		/**
		 * @inheritDoc
		 */
		public function error(o : *, target : Object = null) : void
		{
			if ( isOn() ) Logger.ERROR ( o, channel, target );
		}
		
		/**
		 * @inheritDoc
		 */
		public function fatal(o : *, target : Object = null) : void
		{
			if ( isOn() ) Logger.FATAL ( o, channel, target );
		}
		
		/**
		 * @inheritDoc
		 */
		public function clear( ) : void
		{
			if ( isOn() ) Logger.CLEAR( channel );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getChannel() : EventChannel
		{
			return channel;
		}
		
		/**
		 * @inheritDoc
		 */
		public function isOn() : Boolean
		{
			return _bIsOn;
		}
		
		/**
		 * @inheritDoc
		 */
		public function on() : void
		{
			_bIsOn = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function off() : void
		{
			_bIsOn = false;
		}
	}
}

import net.pixlib.events.EventChannel;

internal class PixlibDebugChannel extends EventChannel {}

internal class ConstructorAccess {}