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
package net.pixlib.view
{
	import net.pixlib.core.CoreFactory;
	import net.pixlib.events.EventBroadcaster;
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.model.ModelEvent;
	import net.pixlib.plugin.NullPlugin;
	import net.pixlib.plugin.Plugin;
	import net.pixlib.plugin.PluginDebug;
	import net.pixlib.structures.Dimension;
	import net.pixlib.utils.DisplayUtil;

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 *  Dispatched when view is initialized.
	 *  
	 *  @eventType net.pixlib.view.ViewEvent.onInitViewEVENT
	 */
	[Event(name="onInitView", type="net.pixlib.view.ViewEvent.onInitViewEVENT")]
	
	/**
	 *  Dispatched when view is released.
	 *  
	 *  @eventType net.pixlib.view.ViewEvent.onReleaseViewEVENT
	 */
	[Event(name="onReleaseView", type="net.pixlib.view.ViewEvent.onReleaseViewEVENT")]
	
	
	/**
	 * Abstract implementation of View part of the MVC implementation.
	 * 
	 * @author Francis Bourre
	 */
	public class AbstractView implements View
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		/** Instance identifier in <code>ViewLocator</code>. */
		protected var _sName	: String;
		
		/** EventBroadcaster for this instance. */
		protected var _oEB		: EventBroadcaster;
		
		/** Plugin owner og this view. */
		protected var _owner 	: Plugin;
		
		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/** DisplayObject controlled by this view instance. */
		public var content 		: DisplayObject;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates instance.
		 * 
		 * @param	owner	Plugins owner
		 * @param	name	View identifier
		 * @param	dpo		DisplayObject to control in this view
		 */
		public function AbstractView( owner : Plugin = null, name : String = null, dpo : DisplayObject = null ) 
		{
			_oEB = new EventBroadcaster( this );
		
			setOwner( owner );
			if ( name != null ) _initAbstractView( name, dpo, null );
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
		 * Returns view logger instance.
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
		 * Registers passed-in <code>dpo</code> display object as 
		 * controlled display object by this view instance.
		 * 
		 * @param	dpo		DisplayObject to control in this view
		 * @param	name	View identifier
		 */
		public function registerView( dpo : DisplayObject, name : String = null ) : void
		{
			_initAbstractView( getName(), dpo, (( name && (name != getName()) ) ? name : null) );
		}
		
		/**
		 * Shows or hide view content.
		 * 
		 * @param b	<code>true</code> to show content.
		 */
		public function setVisible( b : Boolean ) : void
		{
			if ( b ) show(); else hide();
		}
		
		/**
		 * @inheritDoc
		 */
		public function show() : void
		{
			content.visible = true;
		}
		
		/**
		 * @inheritDoc
		 */
		public function hide() : void
		{
			content.visible = false;
		}
		
		/**
		 * Moves content using passed-in coordinates.
		 * 
		 * @param	x	X coordinate		 * @param	y	Y coordinate
		 */
		public function move( x : Number, y : Number ) : void
		{
			setPosition( new Point( x, y ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getPosition() : Point
		{
			return new Point( content.x, content.y );
		}
		
		/**
		 * @inheritDoc
		 */
		public function setPosition( p : Point ) : void
		{
			content.x = p.x;
			content.y = p.y;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setSize( size : Dimension ) : void
		{
			content.width = size.width;
			content.height = size.height;
		}
	
		/**
		 * Sets new content size using passed-in size arguments.
		 * 
		 * @param	w	New content width		 * @param	h	New content height
		 */
		public function setSizeWH( w : Number, h : Number ) : void
		{
			content.width = w;
			content.height = h;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getSize () : Dimension
		{
			return new Dimension( content.width, content.height );
		}
		
		/**
		 * @inheritDoc
		 */
		public function getName() : String
		{
			return _sName;
		}
		
		/**
		 * Returns <code>true</code> if Display object in passed-in tree path 
		 * can be located in view content display tree.
		 * 
		 * @param	label	Name or tree path for object to search
		 * 
		 * @return <code>true</code> if Display object in passed-in tree path 
		 * can be located in view content display tree.
		 */
		public function canResolveUI ( label : String ) : Boolean
		{
			try
			{
				return resolveUI( label, true ) is DisplayObject;
			}
			catch ( e : Error )
			{
				return false;
			}
			
			return false;
		}
		
		/**
		 * @copy net.pixlib.utils.DisplayUtils#resolveUI
		 */
		public function resolveUI( label : String, tryToResolve : Boolean = false ) : DisplayObject 
		{
			return DisplayUtil.resolveUI( content, label, tryToResolve );
		}
		
		/**
		 * 
		 */
		public function canResolveFunction ( label : String ) : Boolean
		{
			try
			{
				return resolveFunction( label , true ) is Function;
			}
			catch ( e : Error )
			{
				return false;
			}

			return false;
		}
		
		/**
		 * @copy net.pixlib.utils.DisplayUtils#resolveFunction
		 */
		public function resolveFunction( label : String  , tryToResolve : Boolean = false ) : Function
		{
			return DisplayUtil.resolveFunction( content, label, tryToResolve );	
		}
		
		/**
		 * @inheritDoc
		 */
		public function release() : void
		{
			ViewLocator.getInstance( getOwner() ).unregister( getName() );

			if ( content != null )
			{
				if ( content.parent != null ) content.parent.removeChild( content );
				content = null;
			}

			onReleaseView();
			getBroadcaster().removeAllListeners();
			_sName = null;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addListener( listener : ViewListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeListener( listener : ViewListener ) : Boolean
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
		public function isVisible() : Boolean
		{
			return content.visible;
		}
		
		/**
		 * @inheritDoc
		 */
		public function setName( name : String ) : void
		{
			var vl : ViewLocator = ViewLocator.getInstance( getOwner() );

			if ( name != null && ( !(vl.isRegistered( name )) || name == getName() ) )
			{
				if ( getName() != null && vl.isRegistered( getName() ) ) vl.unregister( getName() );
				if ( vl.register( name, this ) ) _sName = name;

			} else
			{
				var msg : String = this + ".setName() failed. '" + name + "' is already registered in ViewLocator.";
				getLogger().error( msg );
				throw new IllegalArgumentException( msg );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onInitModel( e : ModelEvent ) : void
		{
			//
		}
		
		/**
		 * @inheritDoc
		 */
		public function onReleaseModel( e : ModelEvent ) : void
		{
			//
		}
		
		/**
		 * Returns the string representation of this instance.
		 * @return the string representation of this instance
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
		
		/**
		 * Broadcasts <code>onInitView</code> event to listeners.
		 */
		protected function onInitView() : void
		{
			notifyChanged( new ViewEvent( ViewEvent.onInitViewEVENT, this, getName() ) );
		}
		
		/**
		 * Broadcasts <code>onReleaseView</code> event to listeners.
		 */
		protected function onReleaseView() : void
		{
			notifyChanged( new ViewEvent( ViewEvent.onReleaseViewEVENT, this, getName() ) );
		}
		
		/**
		 * 
		 */
		protected function firePrivateEvent( e : Event ) : void
		{
			getOwner().firePrivateEvent( e );
		}
		
		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
				
		private function _initAbstractView( name : String, dpo : DisplayObject, avName : String  ) : void
		{	
			if ( dpo != null )
			{
				this.content = dpo;

			} else if ( ( CoreFactory.getInstance().isRegistered( name ) &&  CoreFactory.getInstance().locate( name ) is DisplayObject ) )
			{					
					this.content = ( CoreFactory.getInstance().locate( name ) as DisplayObject );
			}

			setName( avName? avName: name );
			onInitView();
		}
	}
}