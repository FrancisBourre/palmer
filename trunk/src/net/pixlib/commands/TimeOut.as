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
package net.pixlib.commands 
{
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.transitions.RealTimeBeacon;
	import net.pixlib.transitions.TickEvent;
	import net.pixlib.transitions.TickListener;

	import flash.events.Event;

	public class TimeOut
		implements CommandListener, TickListener
	{
		protected var command 	: Command;
		protected var nElasped 	: uint;
		protected var nLimit 	: uint;
		protected var oBeacon 	: RealTimeBeacon;

		public function get limit() : uint
		{
			return nLimit;	
		}

		public function set limit ( value : uint ) : void
		{
			if( !command.isRunning() )
			{
				nLimit = isNaN( value ) ? 0 : value;

			} else
			{
				PalmerDebug.WARN( this + ".limit property is not writable while timeout's running." );
			}
		}

		public function TimeOut ( command : Command, limit : uint = 5000 )
		{
			this.command 	= command;
			this.limit 		= limit;

			nElasped 		= 0;
			oBeacon 		= RealTimeBeacon.getInstance();
			
			this.command.addCommandListener( this );
		} 

		public function onTick ( e : Event = null ) : void
		{
			if ( nLimit != 0 )
			{
				nElasped += ( e as TickEvent ).bias * oBeacon.speedFactor;
				if ( nElasped > nLimit ) command.fireCommandEndEvent( );
			}
		}

		public function toString() : String
		{
			return PalmerStringifier.stringify( this );
		}

		public function fireCommandEndEvent() : void
		{
			command.fireCommandEndEvent();
		}

		public function onCommandStart ( e : Event ) : void
		{
			oBeacon.addTickListener( this );
			oBeacon.start();
		}

		public function onCommandEnd ( e : Event ) : void
		{
			oBeacon.stop();
			oBeacon.removeTickListener( this );
		}
	}
}