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
 
package net.pixlib.ioc.parser 
{
	import net.pixlib.events.CommandEvent;
	import net.pixlib.ioc.load.ApplicationLoader;

	/**
	 * @author Francis Bourre
	 */
	public class ContextParserEvent extends CommandEvent
	{
		
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private var _oLoader : ApplicationLoader;
		private var _oContext : *;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		public function ContextParserEvent( type : String, parser : ContextParser = null, loader : ApplicationLoader = null, rawContext : * = null )
		{
			super( type, parser );
			
			_oLoader = loader;
			_oContext = rawContext;
		}
		
		public function getContextParser() :ContextParser
		{
			return getTarget( ) as ContextParser;
		}
		
		public function getApplicationLoader( ) : ApplicationLoader
		{
			return _oLoader;
		}
		
		public function getContextData( ) : *
		{
			return _oContext;
		}
	}
}
