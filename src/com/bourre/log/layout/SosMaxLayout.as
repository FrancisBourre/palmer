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
package com.bourre.log.layout 
{
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.log.LogEvent;
	import com.bourre.log.LogLevel;
	import com.bourre.log.LogListener;
	import com.bourre.log.PalmerStringifier;
	
	import flash.events.Event;
	import flash.net.XMLSocket;

	/**
	 * The <code>SosMaxLayout</code> class provides a convenient way
	 * to output messages through SOS Max console.
	 * <p>
	 * To get more details, visit: 
	 * http://solutions.powerflasher.com/products/sosmax/ 
	 * </p> 
	 * @author 	Francis Bourre
	 */
	public class SosMaxLayout 
		implements LogListener
	{
		protected var _oXMLSocket 	: XMLSocket;
		protected var _aBuffer 		: Array;
		
		static public var IP 		: String = "localhost";
		static public var PORT 		: Number = 4444;

		static private var _oI : SosMaxLayout = null;
		
		public function SosMaxLayout( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();

			_aBuffer = new Array();
			_oXMLSocket = new XMLSocket();
			_oXMLSocket.addEventListener( Event.CONNECT, _emptyBuffer );
			_oXMLSocket.addEventListener( Event.CLOSE, _tryToReconnect );
            _oXMLSocket.connect ( SosMaxLayout.IP, SosMaxLayout.PORT );
		}
		
		static public function getInstance() : SosMaxLayout
		{
			if ( !(SosMaxLayout._oI is SosMaxLayout) ) SosMaxLayout._oI = new SosMaxLayout( new ConstructorAccess() );
			return SosMaxLayout._oI;
		}

		public function output(  o : Object, level : LogLevel ) : void
		{						
			if ( _oXMLSocket.connected )
			{
				_oXMLSocket.send( "!SOS<showMessage key='" + level.getName() + "'>" + String(o) + "</showMessage>\n" );
				
			} else
			{	
				_aBuffer.push( "!SOS<showMessage key='" + level.getName() + "'>" + String(o) + "</showMessage>\n" );
			}
		}
		
		public function clearOutput() : void
		{
			_oXMLSocket.send( "!SOS<clear/>\n" );
		}
		
		public function onLog( e : LogEvent ) : void
		{
			output( e.message, e.level );
		}
		
		/**
		 * Returns the string representation of this instance.
		 * @return the string representation of this instance
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}
		
		//
		protected function _emptyBuffer( event : Event ) : void
		{
			var l : Number = _aBuffer.length;
			for (var i : Number = 0; i<l; i++) _oXMLSocket.send( _aBuffer[i] );
		}
		
		//
		protected function _tryToReconnect( event : Event ) : void 
		{
            // TODO try to reconnect every n seconds
        }
	}
}

internal class ConstructorAccess {}