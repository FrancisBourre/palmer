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
	import flash.system.Capabilities;
	
	/**
	 * Useful informations about client environement.
	 * 
	 * @author Romain Ecarnot
	 */
	public class SystemConfig 
	{
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * Windows Os identifier.
		 * 
		 * @default "Windows"
		 */
		public static var OS_WINDOWS : String = "Win";

		/**
		 * Mac Os identifier.
		 * 
		 * @default "Mac"
		 */
		public static var OS_MAC : String = "Mac";

		/**
		 * Linux Os identifier.
		 * 
		 * @default "Linux"
		 */
		public static var OS_LINUX : String = "Linux";

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------		
		
		/**
		 * Specifies the current operating system.
		 */
		public static function getOS(  ) : String
		{
			return Capabilities.os;
		}
		
		/**
		 * Returns <code>true</code> if current platform is windows 
		 * platform.
		 */
		public static function isWindows() : Boolean 
		{
			return Capabilities.os.indexOf( OS_WINDOWS ) > -1;
		}

		/**
		 * Returns <code>true</code> if current platform is Mac OS 
		 * platform.
		 */
		public static function isMacOS() : Boolean 
		{
			return Capabilities.os.indexOf( OS_MAC ) > -1;
		}

		/**
		 * Returns <code>true</code> if current platform is Linux 
		 * platform.
		 */
		public static function isLinux() : Boolean 
		{
			return Capabilities.os.indexOf( OS_LINUX ) > -1;
		}

		/**
		 * Returns <code>true</code> if current platform is unknown ( not
		 * Windows, not linux and not MacOs platform.
		 */
		public static function isUnknow() : Boolean
		{
			return !isWindows( ) && !isLinux( ) && !isMacOS( );	
		}
		
		/**
		 * Returns <code>Flash player</code> informations.
		 */		public static function getFlashPlayer() : FlashPlayer
		{
			return FlashPlayer.getInstance( );
		}
		
		
		//--------------------------------------------------------------------
		// Private implementations
		//--------------------------------------------------------------------
		
		/** @private */
		function SystemConfig( )
		{
		}
	}
}

import flash.system.Capabilities;

internal class FlashPlayer
{
	//--------------------------------------------------------------------
	// Private properties
	//--------------------------------------------------------------------

	private static var _oI : FlashPlayer = null;

	private var _major : int;
	private var _minor : int;
	private var _revision : int;
	private var _type : String;

	
	//--------------------------------------------------------------------
	// Public properties
	//--------------------------------------------------------------------

	public static function getInstance() : FlashPlayer
	{
		if ( !(FlashPlayer._oI is FlashPlayer) ) 
		{
			FlashPlayer._oI = new FlashPlayer( );
		}
		return FlashPlayer._oI;
	}

	/** Major of Flash player. */
	public function get major() : int 	{ 		return _major; 	}

	/** Minor of Flash player. */
	public function get minor() : int 	{ 		return _minor; 	}

	/** Revision of Flash player. */
	public function get revision() : int 	{ 		return _revision; 	}
	
	/** Type of Flash player. */
	public function get type() : String 	{ 		return _type; 	}
	
	
	//--------------------------------------------------------------------
	// Public API
	//--------------------------------------------------------------------
	
	/**
	 * Returns <code>true</code> if current player is a 
	 * <strong>ActiveX</strong> player.
	 */
	public function isActiveX() : Boolean
	{
		return _check( "ActiveX" );	
	}

	/**
	 * Returns <code>true</code> if current player is a 
	 * <strong>Adobe Air</strong> player.
	 */
	public function isAir() : Boolean
	{
		return _check( "Desktop" );	
	}

	/**
	 * Returns <code>true</code> if current player is an 
	 * <strong>external</strong> player.
	 */
	public function isExternal() : Boolean
	{
		return _check( "External" );	
	}

	/**
	 * Returns <code>true</code> if current player is a 
	 * <strong>plugin</strong> player.
	 */
	public function isPlugin() : Boolean
	{
		return _check( "PlugIn" );
	}

	/**
	 * Returns <code>true</code> if current player is a 
	 * <strong>standalone</strong> player.
	 */
	public function isStandAlone() : Boolean
	{
		return _check( "StandAlone" );
	}

	/**
	 * Checks if passed in flash player version is compliant to current 
	 * supported version.
	 * 
	 * @param maj Major version
	 * @param min Minor version
	 * @param rev ( optional ) revision version
	 * 
	 * @return <code>true</code> if version is compliant ( >= )
	 */
	public function isCompliant( maj : int = 0, min : int = 0, rev : int = 0 ) : Boolean
	{
		if( _major < maj ) return false;
		if( _major > maj ) return true;
		if( _minor < min ) return false;
		if( _minor > min ) return true;
		if( _revision < rev ) return false;
		
		return true;
	}

	/**
	 * Returns <code>true</code> if current player has 
	 * "FullScreen mode" support.
	 * 
	 * <p>Player is compliant if version >= 9.0.18
	 */
	public function isFullScreenCompliant() : Boolean
	{
		return isCompliant( 9, 0, 18 );
	}

	/**
	 * Returns player version in string format. 
	 */
	public function toString() : String
	{
		return _major + '.' + _minor + '.' + _revision;
	}
	
	
	//--------------------------------------------------------------------
	// Private implementations
	//--------------------------------------------------------------------
	
	/** @private */
	function FlashPlayer( )
	{
		_checkPlayer( );
	}

	private function _checkPlayer() : void
	{
		var v : Array = Capabilities.version.split( ' ' );
		var a : Array = v[1].split( ',' );
		
		_major = Number( a[0] );
		_minor = Number( a[1] );
		_revision = Number( a[2] );
		
		_type = Capabilities.playerType;
	}
	
	private function _check( type : String ) : Boolean
	{
		return _type.toUpperCase( ) == type.toUpperCase( );
	}
}