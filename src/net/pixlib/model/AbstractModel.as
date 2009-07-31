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
package net.pixlib.model
{
	import net.pixlib.events.EventBroadcaster;
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.plugin.NullPlugin;
	import net.pixlib.plugin.Plugin;
	import net.pixlib.plugin.PluginDebug;

	import flash.events.Event;

	/**
	 *  Dispatched when model is initialized.
	 *  
	 *  @eventType net.pixlib.model.ModelEvent.onInitModelEVENT
	 */
	[Event(name="onInitModel", type="net.pixlib.model.ModelEvent.onInitModelEVENT")]
	
	/**
	 *  Dispatched when model is released.
	 *  
	 *  @eventType net.pixlib.model.ModelEvent.onReleaseModelEVENT
	 */
	[Event(name="onReleaseModel", type="net.pixlib.model.ModelEvent.onReleaseModelEVENT")]
	
	
	/**
	 * Abstract implementation of Model part of the MVC implementation.
	 * 
	 * @author Francis Bourre
	 */
	public class AbstractModel implements Model
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
				
		/** EventBroadcaster for this instance. */
		protected var _oEB 		: EventBroadcaster;
		
		/** Instance identifier in <code>ModelLocator</code>. */
		protected var _sName 	: String;
		
		/** Plugin owner og this model. */
		protected var _owner 	: Plugin;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
			
		/**
		 * Creates instance.
		 * 
		 * @param	owner	Plugins owner
		 * @param	name	Model identifier
		 */
		public function AbstractModel( owner : Plugin = null, name : String = null ) 
		{
			_oEB = new EventBroadcaster( this );
			
			setOwner( owner );
			if ( name ) setName( name );
		}
		
		/**
		 * @copy net.pixlib.events.EventBroadcaster#setListenerType
		 */
		public function setListenerType( type : Class ) : void
		{
			_oEB.setListenerType(type);
		}
		
		/**
		 * @private
		 */
		public function handleEvent( e : Event ) : void
		{
			//
		}
		
		/**
		 * @inheritDoc
		 */
		public function setName( name : String ) : void
		{
			var ml : ModelLocator = ModelLocator.getInstance( getOwner() );
			
			if ( !( ml.isRegistered( name ) ) )
			{
				if ( getName() != null && ml.isRegistered( getName() ) ) ml.unregister( getName() );
				if ( ml.register( name, this ) ) _sName = name;
				
			} else
			{
				getLogger().error( this + ".setName() failed. '" + name + "' is already registered in ModelLocator." );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function getOwner() : Plugin
		{
			return _owner;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setOwner( owner : Plugin ) : void
		{
			_owner = owner ? owner : NullPlugin.getInstance();
		}
		
		/**
		 * @inheritDoc
		 */
		public function getLogger() : PluginDebug
		{
			return PluginDebug.getInstance( getOwner() );
		}
		
		/**
		 * @inheritDoc
		 */
		public function notifyChanged( e : Event ) : void
		{
			getBroadcaster().broadcastEvent( e );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getName() : String
		{
			return _sName;
		}
		
		/**
		 * @inheritDoc
		 */
		public function release() : void
		{
			ModelLocator.getInstance( getOwner() ).unregister( getName() );
			getBroadcaster().removeAllListeners();
			onReleaseModel();
			_sName = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addListener( listener : ModelListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeListener( listener : ModelListener ) : Boolean
		{
			return _oEB.removeListener( listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			return _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			return _oEB.removeEventListener( type, listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		protected function getBroadcaster() : EventBroadcaster
		{
			return _oEB;
		}	
		
		protected function onInitModel() : void
		{
			notifyChanged( new ModelEvent( ModelEvent.onInitModelEVENT, this, getName() ) );
		}
		
		protected function onReleaseModel() : void
		{
			notifyChanged( new ModelEvent( ModelEvent.onReleaseModelEVENT, this, getName() ) );
		}	
	}
}