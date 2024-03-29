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
	import net.pixlib.events.BasicEvent;
	import net.pixlib.events.EventBroadcaster;
	import net.pixlib.exceptions.UnsupportedOperationException;
	
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;	

	/**
	 * @author Francis Bourre
	 */
	public class PluginBroadcaster 
		extends EventBroadcaster
	{
		public function PluginBroadcaster ( source : Object = null, type : Class = null )
		{
			super( source, type );
		}

		public function firePublicEvent ( e : Event, owner : Plugin ) : void
		{
			if( e.target == null && e is BasicEvent ) ( e as BasicEvent ).target = _oSource;
			if ( hasListenerCollection( e.type ) ) _broadcastEvent( getListenerCollection(e.type), e );

			var type : String = e.type;
			var a : Array = _mAll.toArray();
			var l : Number = a.length;

			while ( --l > -1 ) 
			{
				var listener : Object = a[l];

				if ( listener != owner )
				{
					if ( listener.hasOwnProperty( type ) && listener[ type ] is Function )
					{
						listener[type](e);

					} else if ( listener.hasOwnProperty( "handleEvent" ) && listener.handleEvent is Function )
					{
						listener.handleEvent(e);

					} else 
					{
						var msg : String;
						msg = this + ".firePublicEvent() failed, you must implement '" 
						+ type + "' method or 'handleEvent' method in '" + 
						getQualifiedClassName(listener) + "' class";

						owner.getLogger().error( msg );
						throw( new UnsupportedOperationException( msg ) );
					}
				}
			}
		}
	}}