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
package com.bourre.log 
{
	import com.bourre.events.EventChannel;
	import com.bourre.exceptions.PrivateConstructorException;	

	/**
	 * @author Francis Bourre
	 */
	public final class PalmerDebug 
		implements Log
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
			if ( b ) PalmerDebug.getInstance().on() else PalmerDebug.getInstance().off();
		}

		static public function DEBUG( o : * ) : void
		{
			PalmerDebug.getInstance().debug( o );
		}

		static public function INFO( o : * ) : void
		{
			PalmerDebug.getInstance().info( o );
		}

		static public function WARN( o : * ) : void
		{
			PalmerDebug.getInstance().warn( o );
		}

		static public function ERROR( o : * ) : void
		{
			PalmerDebug.getInstance().error( o );
		}

		static public function FATAL( o : * ) : void
		{
			PalmerDebug.getInstance().fatal( o );
		}
		
		//
		public function debug(o : *) : void
		{
			if ( isOn() ) Logger.DEBUG ( o, channel );
		}
		
		public function info(o : *) : void
		{
			if ( isOn() ) Logger.INFO ( o, channel );
		}
		
		public function warn(o : *) : void
		{
			if ( isOn() ) Logger.WARN ( o, channel );
		}
		
		public function error(o : *) : void
		{
			if ( isOn() ) Logger.ERROR ( o, channel );
		}
		
		public function fatal(o : *) : void
		{
			if ( isOn() ) Logger.FATAL ( o, channel );
		}
		
		public function getChannel() : EventChannel
		{
			return channel;
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
	}
}

import com.bourre.events.EventChannel;

internal class PixlibDebugChannel 
	extends EventChannel
{}

internal class ConstructorAccess {}