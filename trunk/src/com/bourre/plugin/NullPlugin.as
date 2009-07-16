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
package com.bourre.plugin 
{
	import com.bourre.events.EventChannel;
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.log.Log;
	import com.bourre.log.PalmerStringifier;
	import com.bourre.model.Model;
	import com.bourre.model.ModelLocator;
	import com.bourre.view.View;
	import com.bourre.view.ViewLocator;

	import flash.events.Event;

	/**
	 * @author Francis Bourre
	 */
	final public class NullPlugin 
		implements Plugin
	{
		static private var _oI : NullPlugin = null;

		private var _channel : NullPluginChannel;

		public function NullPlugin ( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();

			_channel = new NullPluginChannel();
		}

		static public function getInstance() : NullPlugin
		{
			if ( !(NullPlugin._oI is NullPlugin) ) NullPlugin._oI = new NullPlugin( new ConstructorAccess() );
			return NullPlugin._oI;
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationInit( ) : void
		{
			fireOnInitPlugin();
		}
		
		/**
		 * @inheritDoc
		 */
		public function fireOnInitPlugin() : void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function fireOnReleasePlugin() : void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function fireExternalEvent( e : Event, channel : EventChannel ) : void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function firePublicEvent( e : Event ) : void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function firePrivateEvent( e : Event ) : void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function getChannel() : EventChannel
		{
			return _channel;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getName() : String
		{
			return getChannel().toString();	
		}
		
		/**
		 * @inheritDoc
		 */
		public function getLogger() : Log
		{
			return PluginDebug.getInstance( this );
		}

		/**
		 * Returns the string representation of this instance.
		 * @return the string representation of this instance
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getModel( key : String ) : Model
		{
			return ModelLocator.getInstance( this ).getModel( key );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getView( key : String ) : View
		{
			return ViewLocator.getInstance( this ).getView( key );
		}		
		/**
		 * @inheritDoc
		 */		public function isModelRegistered( key : String ) : Boolean		{
			return ModelLocator.getInstance( this ).isRegistered( key );
		}		
		/**
		 * @inheritDoc
		 */		public function isViewRegistered( key : String ) : Boolean		{
			return ViewLocator.getInstance( this ).isRegistered( key );
		}
	}
}

import com.bourre.events.EventChannel;

internal class ConstructorAccess 
{
}

internal class NullPluginChannel extends EventChannel{}