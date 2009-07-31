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
 
package net.pixlib.ioc.parser.factory.xml 
{
	import net.pixlib.collections.HashMap;
	import net.pixlib.ioc.core.ContextAttributeList;
	import net.pixlib.ioc.load.ApplicationLoaderState;
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.utils.FlashVars;

	/**
	 * Context URL manager.
	 * 
	 * @example Default url definition ( URL is relative to assembler file )
	 * <pre class="prettyprint">&lt;dll url="mylib.swf" /&gt;</pre>
	 * 
	 * @example Sandbox url definition ( URL is relative to context file )
	 * <pre class="prettyprint">&lt;dll url="sandbox://mylib.swf" /&gt;</pre>
	 * 
	 * @example Flashvar url definition ( URL is prefixed with Flashvar value )<br />
	 * The flashvar name is the string before "://" characters ( case sensitive ).<br/>
	 * If the Flashvar is not available, return original url.
	 * <pre class="prettyprint">&lt;dll url="dllDirectory://mylib.swf" /&gt;</pre>
	 * 
	 * @author Romain Ecarnot
	 */
	public class PathParser extends XMLParser
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private var _m : HashMap;
		private var _reserved : HashMap;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function PathParser(  )
		{
			_reserved = new HashMap( );
			addReservedURL( "http", "" );			addReservedURL( "https", "" );			addReservedURL( "ftp", "" );			addReservedURL( "rtmp", "" );
			
			_m = new HashMap( ) ;
			addMethod( "sandbox", getSandboxURL );
		}
		
		/**
		 * 
		 */
		public function addMethod( type : String, parsingMethod : Function ) : void
		{
			_m.put( type, parsingMethod ) ;
		}
		
		/**
		 * 
		 */
		public function addReservedURL( type : String, value : * ) : void
		{
			_reserved.put( type, value ) ;
		}

		/**
		 * @inheritDoc
		 */
		override public function parse( ) : void
		{
			var result : XMLList = getXMLContext( )..*.( hasOwnProperty( getAttributeName( ContextAttributeList.URL ) ) && String( @[ContextAttributeList.URL] ).length > 0 );
			
			for each (var node : XML in result)
			{
				var separator : String = "://";
				var url : String = node.@url;
				var key : String = url.substring( 0, url.indexOf( separator ) );
				
				if( key && key.length > 0 && !isReserved( key ) )
				{
					node.@url = getURL( key, url.substr( url.indexOf( separator ) + separator.length ) );
				}
			}
			
			fireCommandEndEvent( );
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------

		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.PATH_PARSE_STATE;
		}
		
		protected function getAttributeName( name : String ) : String
		{
			return "@" + name;		
		}
		
		protected function isReserved( key : String ) : Boolean
		{
			return _reserved.containsKey(key);
		}
		
		protected function getURL( key : String, url : String ) : String
		{
			var d : Function;
			
			if ( _m.containsKey( key ) )
			{
				d = _m.get( key );
			} 
			else
			{
				d = getFlashVarURL;
			}
			
			return d.apply( this, [ key, url ] );
		}

		protected function getFlashVarURL( key : String, url : String  ) : String
		{
			var path : String = FlashVars.getInstance().locate( key ) as String;
			
			if( path )
			{
				return path + url;
			}
			else
			{
				PalmerDebug.ERROR( this + ".getFlashVarURL() failed. Variable '" + key + "' is not registered in application" );
			}
			
			return url;
		}
		
		protected function getSandboxURL( key : String, url : String  ) : String
		{
			var contextURL : String = getApplicationLoader().getURL( ).url.substring( 0, getApplicationLoader().getURL( ).url.indexOf( "?" ) );
			var contextPath : String = contextURL.substring( 0, contextURL.lastIndexOf( "/" ) );
			
			if( contextPath.length > 0 ) contextPath += "/";
			
			return contextPath + url;
		}
	}
}