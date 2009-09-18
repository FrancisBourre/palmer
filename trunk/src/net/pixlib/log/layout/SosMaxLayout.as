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
package net.pixlib.log.layout 
{
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.log.LogEvent;
	import net.pixlib.log.LogListener;
	import net.pixlib.log.PalmerStringifier;

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
		
		protected function output ( message : String ) : void
		{
			if ( _oXMLSocket.connected )
			{
				_oXMLSocket.send( message );
				
			} else
			{	
				_aBuffer.push( message );
			}
		}

		protected function formatMessage( e : LogEvent ) : String
		{
			var message : String = String( e.message );

			var lines 		: Array = message.split("\n");
			var xmlMessage 	: XML 	= new XML( "<" + (lines.length == 1 ? "showMessage" : "showFoldMessage") +" key='" + e.level.getName() + "' />" );

			if ( lines.length > 1 )
			{
				xmlMessage.title = lines[0];
				xmlMessage.message = message.substr( message.indexOf("\n") + 1, message.length );

			} else
			{
				xmlMessage.appendChild( message );
			}

			return '!SOS' + xmlMessage.toXMLString() + '\n';
		}
		
		
		public function clearOutput() : void
		{
			output( "!SOS<clear/>\n" );
		}
		
		public function onLog( e : LogEvent ) : void
		{
			output( formatMessage( e ) );
		}
		
		/**
		 * Clears console messages.
		 */
		public function onClear( e : Event = null ) : void
		{
			clearOutput();
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