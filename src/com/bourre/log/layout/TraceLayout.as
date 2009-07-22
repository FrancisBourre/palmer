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
	import com.bourre.collections.HashMap;
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.log.LogEvent;
	import com.bourre.log.LogLevel;
	import com.bourre.log.LogListener;

	import flash.events.Event;

	/**
	 * The TraceLayout class provides a convenient way
	 * to output messages through the Adobe Flash IDE output panel.
	 * 
	 * @example Add TraceLayout as Log listener
	 * <pre class="prettyprint">
	 * 
	 * //Add Firebug for all channels
	 * Logger.getInstance().addLogListener( TraceLayout.getInstance() );
	 * 
	 * //Add Firebug for a dedicated channel
	 * Logger.getInstance().addLogListener( TraceLayout.getInstance(), PalmerDebug.CHANNEL );
	 * </pre>
	 * 
	 * @example Output message
	 * <pre class="prettyprint">
	 * 
	 * //Simple ouput
	 * Logger.DEBUG( "My message" );
	 * 
	 * //Channel target
	 * Logger.WARN( "My messsage", PalmerDebug.CHANNEL );
	 * 
	 * //Channel use
	 * PalmerDebug.ERROR( "My error" );
	 * </pre>
	 * 
	 * @see com.bourre.log.Logger
	 * @see com.bourre.log.LogListener
	 * @see com.bourre.log.LogLevel
	 * 
	 * @author	Romain Ecarnot
	 */
	public class TraceLayout implements LogListener
	{
		//--------------------------------------------------------------------
		// Constants
		//--------------------------------------------------------------------

		public const DEBUG_PREFIX : String = "[debug]";
		public const INFO_PREFIX : String = "[info]";
		public const WARN_PREFIX : String = "[warn]";
		public const ERROR_PREFIX : String = "[error]";
		public const FATAL_PREFIX : String = "[fatal]";

		
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private static var _oI : TraceLayout = null;

		private var _mFormat : HashMap;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Retreives <code>TraceLayout</code> unique instance.
		 */
		public static function getInstance() : TraceLayout
		{
			if( _oI == null )
				_oI = new TraceLayout( new ConstructorAccess( ) );
				
			return _oI;
		}

		/**
		 * Triggered when a log message is sent by the <code>Logger</code>.
		 * 
		 * @param	e	<code>LogEvent</code> event containing information about 
		 * 				the message to log.
		 */
		public function onLog( event : LogEvent ) : void
		{
			var prefix : String = _mFormat.get( event.level );
			
			trace( prefix + event.message );
		}
		
		/**
		 * Clears console messages.
		 */
		public function onClear( e : Event = null ) : void
		{
			//Not available here
		}
		
		
		//--------------------------------------------------------------------
		// Private implementations
		//--------------------------------------------------------------------		
		
		/** @private */
		function TraceLayout( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException( );
			
			_initPrefixMap( );
		}

		private function _initPrefixMap( ) : void
		{
			_mFormat = new HashMap( );
			_mFormat.put( LogLevel.DEBUG, DEBUG_PREFIX );
			_mFormat.put( LogLevel.INFO, INFO_PREFIX );
			_mFormat.put( LogLevel.WARN, WARN_PREFIX );
			_mFormat.put( LogLevel.ERROR, ERROR_PREFIX );
			_mFormat.put( LogLevel.FATAL, FATAL_PREFIX );
		}
	}
}

internal class ConstructorAccess 
{
}