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
package net.pixlib.plugin
{
	import net.pixlib.collections.HashMap;
	import net.pixlib.events.EventChannel;
	import net.pixlib.exceptions.PrivateConstructorException;	

	/**
	 * @author Francis Bourre
	 */
	public class PluginChannel
		extends EventChannel
	{
		static private var _M : HashMap = new HashMap();
		
		public function PluginChannel( access : ConstructorAccess, channelName : String )
		{
			super( channelName );
			
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}
		
		static public function getInstance( channelName : String ) : PluginChannel
		{
			if ( !(PluginChannel._M.containsKey( channelName )) )
				PluginChannel._M.put( channelName, new PluginChannel( new ConstructorAccess(), channelName ) );
				
			return PluginChannel._M.get( channelName ) as PluginChannel;
		}
	}
}

internal class ConstructorAccess{}