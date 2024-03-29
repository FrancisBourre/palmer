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
	import net.pixlib.commands.FrontController;
	import net.pixlib.commands.QueueController;
	import net.pixlib.core.CoreFactory;
	import net.pixlib.events.ApplicationBroadcaster;
	import net.pixlib.events.Broadcaster;
	import net.pixlib.events.EventChannel;
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.log.Log;
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.model.Model;
	import net.pixlib.model.ModelLocator;
	import net.pixlib.view.View;
	import net.pixlib.view.ViewLocator;

	import flash.events.Event;

	/**
	 * The AbstractPlugin class.
	 * 
	 * @author 	Francis Bourre
	 */
	public class AbstractPlugin 
		implements Plugin
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		/** Public broadcaster. */	
		protected var _oEBPublic : Broadcaster;

		/** Plugin FrontController. */
		protected var _oController : FrontController;
		
		/** Plugin QueueController. */
		protected var _oQueueController : QueueController;

		/** Application's model locator. */
		protected var _oModelLocator : ModelLocator;

		/** Application's view locator. */
		protected var _oViewLocator : ViewLocator;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
				
		/**
		 * Returns plugin Front controller
		 */
		public function getController() : FrontController
		{
			return _oController;
		}
		
		/**
		 * Returns plugin Queue controller
		 */
		public function getQueueController() : QueueController
		{
			return _oQueueController;
		}

		/**
		 * @inheritDoc
		 */
		public function getChannel() : EventChannel
		{
			return ChannelExpert.getInstance( ).getChannel( this );
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
			if ( externalChannel != getChannel( ) ) 
			{
				ApplicationBroadcaster.getInstance( ).broadcastEvent( e, externalChannel );
			} 
			else
			{
				var msg : String = this + ".fireExternalEvent() failed, '" + externalChannel + "' is its public channel.";
				getLogger( ).error( msg );
				throw new IllegalArgumentException( msg );
			}
		}

		/**
		 * Generic event handler.
		 */
		public function handleEvent( e : Event = null ) : void
		{
		}

		/**
		 * @inheritDoc
		 */
		public function firePublicEvent( e : Event ) : void
		{
			if( _oEBPublic ) ( _oEBPublic as PluginBroadcaster ).firePublicEvent( e, this );
				else getLogger( ).warn( this + " doesn't have public dispatcher" );
		}

		/**
		 * @inheritDoc
		 */
		public function firePrivateEvent( e : Event ) : void
		{
			if ( _oController.isRegistered( e.type ) || _oQueueController.isRegistered( e.type ) ) 
			{
				if ( _oController.isRegistered( e.type ) ) _oController.handleEvent( e );
				if ( _oQueueController.isRegistered( e.type ) ) _oQueueController.handleEvent( e );
			} 
			else
			{
				getLogger( ).debug( this + ".firePrivateEvent() fails to retrieve command associated with '" + e.type + "' event type." );
			}
		}

		/**
		 * @inheritDoc
		 */
		public function onApplicationInit( ) : void
		{
			fireOnInitPlugin( );
		}

		/**
		 * Releases plugin.
		 */
		public function release() : void
		{
			_oController.release( );
			_oModelLocator.release( );
			_oViewLocator.release( );

			var key : String = CoreFactory.getInstance( ).getKey( this );
			CoreFactory.getInstance( ).unregister( key );
			fireOnReleasePlugin( );

			_oEBPublic.removeAllListeners( );

			ApplicationBroadcaster.getInstance( ).releaseChannelDispatcher( getChannel( ) );
			PluginDebug.release( this );
			ChannelExpert.getInstance( ).releaseChannel( this );
		}

		/**
		 * @copy net.pixlib.event.Broadcaster#addListener()
		 */
		public function addListener( listener : PluginListener ) : Boolean
		{
			if( _oEBPublic ) 
			{
				return _oEBPublic.addListener( listener );
			} 
			else 
			{
				getLogger( ).warn( this + " doesn't have public dispatcher" );
				return false;
			}
		}

		/**
		 * @copy net.pixlib.event.Broadcaster#removeListener()
		 */
		public function removeListener( listener : PluginListener ) : Boolean
		{
			if( _oEBPublic ) 
			{
				return _oEBPublic.removeListener( listener );
			} 
			else 
			{
				getLogger( ).warn( this + " doesn't have public dispatcher" );
				return false;
			}
		}

		/**
		 * @copy net.pixlib.event.Broadcaster#addEventListener()
		 */
		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			if( _oEBPublic ) 
			{
				return _oEBPublic.addEventListener.apply( _oEBPublic, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
			} 
			else 
			{
				getLogger( ).warn( this + " doesn't have public dispatcher" );
				return false;
			}
		}

		/**
		 * @copy net.pixlib.event.Broadcaster#removeEventListener()
		 */
		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			if( _oEBPublic ) 
			{
				return _oEBPublic.removeEventListener( type, listener );
			} 
			else 
			{
				getLogger( ).warn( this + " doesn't have public dispatcher" );
				return false;
			}
		}

		/**
		 * Returns the string representation of this instance.
		 * 
		 * @return the string representation of this instance
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}

		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * Inits plugin properties.
		 */
		protected function _initialize() : void
		{
			_oController = new FrontController( this );
			_oQueueController = new QueueController( this );
			_oModelLocator = ModelLocator.getInstance( this );
			_oViewLocator = ViewLocator.getInstance( this );

			_oEBPublic = ApplicationBroadcaster.getInstance( ).getChannelDispatcher( getChannel( ), this );
			if( _oEBPublic ) _oEBPublic.addListener( this );
		}

		/**
		 * Returns plugin model locator.
		 */
		protected function getModelLocator() : ModelLocator
		{
			return _oModelLocator;
		}

		/**
		 * Returns plugin view locator.
		 */
		protected function getViewLocator() : ViewLocator
		{
			return _oViewLocator;
		}

		/**
		 * Fires <code>PluginEvent.onInitPluginEVENT</code> public event.
		 */
		protected function fireOnInitPlugin() : void
		{
			firePublicEvent( new PluginEvent( PluginEvent.onInitPluginEVENT, this ) );
		}

		/**
		 * Fires <code>PluginEvent.onReleasePluginEVENT</code> public event.
		 */
		protected function fireOnReleasePlugin() : void
		{
			firePublicEvent( new PluginEvent( PluginEvent.onReleasePluginEVENT, this ) );
		}	

		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
		
		/**
		 * Constructor.
		 * 
		 * <p>Overrides <code>#_initialize()</code> method to customize 
		 * plugin initialization process.</p>
		 * 
		 * @see #_initialize()
		 */
		function AbstractPlugin() 
		{
			_initialize( );
		}			
	}
}