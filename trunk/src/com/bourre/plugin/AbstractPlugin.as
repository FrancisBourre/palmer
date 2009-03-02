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
	import com.bourre.commands.FrontController;
	import com.bourre.core.CoreFactory;
	import com.bourre.events.ApplicationBroadcaster;
	import com.bourre.events.Broadcaster;
	import com.bourre.events.EventChannel;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.log.Log;
	import com.bourre.log.PalmerStringifier;
	import com.bourre.model.Model;
	import com.bourre.model.ModelLocator;
	import com.bourre.view.View;
	import com.bourre.view.ViewLocator;
	
	import flash.events.Event;	

	/**
	 * The AbstractPlugin class.
	 * 
	 * @author 	Francis Bourre
	 */
	public class AbstractPlugin
		implements Plugin
	{
		protected var _oEBPublic 		: Broadcaster;
		protected var _oController 		: FrontController;
		protected var _oModelLocator 	: ModelLocator;
		protected var _oViewLocator 	: ViewLocator;

		public function AbstractPlugin() 
		{
			_initialize();
		}

		protected function _initialize() : void
		{
			_oController = new FrontController( this );
			_oModelLocator = ModelLocator.getInstance( this );
			_oViewLocator = ViewLocator.getInstance( this );

			_oEBPublic = ApplicationBroadcaster.getInstance().getChannelDispatcher( getChannel(), this );
			if( _oEBPublic ) _oEBPublic.addListener( this );
		}
		
		public function getController() : FrontController
		{
			return _oController;
		}
		
		protected function getModelLocator() : ModelLocator
		{
			return _oModelLocator;
		}

		protected function getViewLocator() : ViewLocator
		{
			return _oViewLocator;
		}

		protected function fireOnInitPlugin() : void
		{
			firePublicEvent( new PluginEvent( PluginEvent.onInitPluginEVENT, this ) );
		}

		protected function fireOnReleasePlugin() : void
		{
			firePublicEvent( new PluginEvent( PluginEvent.onReleasePluginEVENT, this ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getChannel() : EventChannel
		{
			return ChannelExpert.getInstance().getChannel( this );
		}
		
		/**
		 * @inheritDoc
		 */
		public function isModelRegistered( name : String ) : Boolean
		{
			return _oModelLocator.isRegistered( name );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getModel( key : String ) : Model
		{
			return _oModelLocator.getModel( key );
		}
		
		/**
		 * @inheritDoc
		 */
		public function isViewRegistered( name : String ) : Boolean
		{
			return _oViewLocator.isRegistered( name );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getView( key : String ) : View
		{
			return _oViewLocator.getView( key );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getLogger() : Log
		{
			return PluginDebug.getInstance( this );
		}
		
		/**
		 * @inheritDoc
		 */
		public function fireExternalEvent( e : Event, externalChannel : EventChannel ) : void
		{
			if ( externalChannel != getChannel() ) 
			{
				ApplicationBroadcaster.getInstance().broadcastEvent( e, externalChannel );
				
			} else
			{
				var msg : String = this + ".fireExternalEvent() failed, '" + externalChannel + "' is its public channel.";
				getLogger().error( msg );
				throw new IllegalArgumentException( msg );
			}
		}
		
		
		public function handleEvent ( e : Event = null ):void
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function firePublicEvent( e : Event ) : void
		{
			if( _oEBPublic ) ( _oEBPublic as PluginBroadcaster ).firePublicEvent( e, this );
				else getLogger().warn( this + " doesn't have public dispatcher" );
		}
		
		/**
		 * @inheritDoc
		 */
		public function firePrivateEvent( e : Event ) : void
		{
			if ( _oController.isRegistered( e.type ) ) 
			{
				_oController.handleEvent( e );

			} else
			{
				getLogger().debug( this + ".firePrivateEvent() fails to retrieve command associated with '" + e.type + "' event type." );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationInit( ) : void
		{
			fireOnInitPlugin();
		}
		
		public function release() : void
		{
			_oController.release();
			_oModelLocator.release( );
			_oViewLocator.release();

			var key : String = CoreFactory.getInstance().getKey( this );
			CoreFactory.getInstance().unregister( key );
			fireOnReleasePlugin();

			_oEBPublic.removeAllListeners();

			ApplicationBroadcaster.getInstance().releaseChannelDispatcher( getChannel() );
			PluginDebug.release( this );
			ChannelExpert.getInstance().releaseChannel( this );
		}

		public function addListener( listener : PluginListener ) : Boolean
		{
			if( _oEBPublic ) 
			{
				return _oEBPublic.addListener( listener );
				
			} else 
			{
				getLogger().warn( this + " doesn't have public dispatcher" );
				return false;
			}
		}
		
		public function removeListener( listener : PluginListener ) : Boolean
		{
			if( _oEBPublic ) 
			{
				return _oEBPublic.removeListener( listener );

			} else 
			{
				getLogger().warn( this + " doesn't have public dispatcher" );
				return false;
			}
		}

		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			if( _oEBPublic ) 
			{
				return _oEBPublic.addEventListener.apply( _oEBPublic, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
			
			} else 
			{
				getLogger().warn( this + " doesn't have public dispatcher" );
				return false;
			}
		}

		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			if( _oEBPublic ) 
			{
				return _oEBPublic.removeEventListener( type, listener );

			} else 
			{
				getLogger().warn( this + " doesn't have public dispatcher" );
				return false;
			}
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