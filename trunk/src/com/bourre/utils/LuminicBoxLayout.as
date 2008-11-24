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
package com.bourre.utils
{
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.log.LogEvent;
	import com.bourre.log.LogListener;
	import com.bourre.log.PalmerStringifier;

	import flash.net.LocalConnection;	

	/**
	 * <code>LuminicboxLayout</code> class provides a convenient way
	 * to output messages through Luminic Box console.
	 * <p>
	 * To get more details, visit: 
	 * http://osflash.org/luminicbox.log
	 * </p> 
	 * @author 	Francis Bourre
	 */
	public class LuminicBoxLayout 
		implements LogListener
	{
		static private var _oI 				: LuminicBoxLayout = null;
		public const LOCALCONNECTION_ID 	: String = "_luminicbox_log_console";
		
		protected const _lc 	: LocalConnection	= new LocalConnection();
		protected const _sID 	: String 			= String( ( new Date()).getTime() );

		public function LuminicBoxLayout( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}
		
		static public function getInstance() : LuminicBoxLayout
		{
			if ( !(LuminicBoxLayout._oI is LuminicBoxLayout) ) LuminicBoxLayout._oI = new LuminicBoxLayout( new ConstructorAccess() );
			return LuminicBoxLayout._oI;
		}

		public function onLog( e : LogEvent ) : void
		{
			_lc.send( LOCALCONNECTION_ID, "log", {loggerId:_sID, levelName:e.level.getName(), time:new Date(), version:.15, argument:{type:"string", value:e.message.toString()}} );
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