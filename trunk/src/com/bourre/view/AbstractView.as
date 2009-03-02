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
package com.bourre.view
{
	import com.bourre.core.CoreFactory;
	import com.bourre.events.EventBroadcaster;
	import com.bourre.exceptions.IllegalArgumentException;
	import com.bourre.exceptions.NoSuchElementException;
	import com.bourre.log.PalmerStringifier;
	import com.bourre.model.ModelEvent;
	import com.bourre.plugin.NullPlugin;
	import com.bourre.plugin.Plugin;
	import com.bourre.plugin.PluginDebug;
	import com.bourre.structures.Dimension;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;	

	/**
	 * Abstract implementation of View part of the MVC implementation.
	 * 
	 * @author Francis Bourre
	 */
	public class AbstractView 
		implements View
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		protected var _sName	: String;
		protected var _oEB		: EventBroadcaster;
		protected var _owner 	: Plugin;
		
		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
				
		public var view 		: DisplayObject;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
				
		public function AbstractView( owner : Plugin = null, name : String = null, dpo : DisplayObject = null ) 
		{
			_oEB = new EventBroadcaster( this );

			setOwner( owner );
			if ( name != null ) _initAbstractView( name, dpo, null );
		}

		public function handleEvent( e : Event ) : void
		{
			//
		}
		
		/**
		 * Returns plugin owner.
		 */
		public function getOwner() : Plugin
		{
			return _owner;
		}
		
		/**
		 * Sets the plugin owner for model.
		 * 
		 * <p>if owner is <code>null</code>, use <code>NullPlugin</code> 
		 * instance.</p>
		 */
		public function setOwner( owner : Plugin ) : void
		{
			_owner = owner ? owner : NullPlugin.getInstance();
		}
		
		/**
		 * Returns model logger tunnel.
		 */
		public function getLogger() : PluginDebug
		{
			return PluginDebug.getInstance( getOwner() );
		}
		
		/**
		 * @copy com.bourre.events.Broadcaster#broadcastEvent()
		 */
		public function notifyChanged( e : Event ) : void
		{
			getBroadcaster().broadcastEvent( e );
		}

		public function registerView( dpo : DisplayObject, name : String = null ) : void
		{
			_initAbstractView( getName(), dpo, (( name && (name != getName()) ) ? name : null) );
		}
		
		public function setVisible( b : Boolean ) : void
		{
			if ( b ) show(); else hide();
		}

		public function show() : void
		{
			view.visible = true;
		}

		public function hide() : void
		{
			view.visible = false;
		}

		public function move( x : Number, y : Number ) : void
		{
			setPosition( new Point( x, y ) );
		}

		public function getPosition() : Point
		{
			return new Point( view.x, view.y );
		}
		
		public function setPosition( p : Point ) : void
		{
			view.x = p.x;
			view.y = p.y;
		}
		
		public function setSize( size : Dimension ) : void
		{
			view.width = size.width;
			view.height = size.height;
		}

		public function setSizeWH( w : Number, h : Number ) : void
		{
			view.width = w;
			view.height = h;
		}

		public function getSize () : Dimension
		{
			return new Dimension( view.width, view.height );
		}

		public function getName() : String
		{
			return _sName;
		}

		public function canResolveUI ( label : String ) : Boolean
		{
			try
			{
				return resolveUI( label, true ) is DisplayObject;

			} catch ( e : Error )
			{
				return false;
			}

			return false;
		}

		public function resolveUI( label : String, tryToResolveUI : Boolean = false ) : DisplayObject 
		{
			var target : DisplayObject = this.view;

			var a : Array = label.split( "." );
			var l : int = a.length;

			for ( var i : int = 0; i < l; i++ )
			{
				var name : String = a[ i ];
				if ( target is DisplayObjectContainer && (target as DisplayObjectContainer).getChildByName( name ) != null )
					target = (target as DisplayObjectContainer).getChildByName( name );
				else
				{
					var msg : String;
					if ( !tryToResolveUI ) 
					{
						msg = this + ".resolveUI(" + label + ") failed.";
						getLogger().error( msg );
						throw new NoSuchElementException( msg );
					}
					return null;
				}
			}

			return target;
		}

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
		
		public function resolveFunction( label : String  , tryToResolveFunction : Boolean = false ) : Function
		{
			var a : Array = label.split( "." );
			var f : String = a.pop();
			var target : DisplayObjectContainer  = resolveUI( a.join('.')) as DisplayObjectContainer ; 
			
			if ( target.hasOwnProperty( f ) &&  target[f] is Function  )
				return target[f] ;
			else
			{
				var msg : String;
				if ( !tryToResolveFunction ) 
				{
					msg = this + ".resolveFunction(" + label + ") failed.";
					getLogger().error( msg );
					throw new NoSuchElementException( msg );
				}
				return null;
			}
			
		}

		public function release() : void
		{
			ViewLocator.getInstance( getOwner() ).unregister( getName() );

			if ( view != null )
			{
				if ( view.parent != null ) view.parent.removeChild( view );
				view = null;
			}

			onReleaseView();
			getBroadcaster().removeAllListeners();
			_sName = null;
		}
		
		/**
		 * @copy com.bourre.events.Broadcaster#addListener()
		 */
		public function addListener( listener : ViewListener ) : Boolean
		{
			return _oEB.addListener( listener );
		}
		
		/**
		 * @copy com.bourre.events.Broadcaster#removeListener()
		 */
		public function removeListener( listener : ViewListener ) : Boolean
		{
			return _oEB.removeListener( listener );
		}
		
		/**
		 * @copy com.bourre.events.Broadcaster#addEventListener()
		 */
		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			return _oEB.addEventListener.apply( _oEB, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
		}
		
		/**
		 * @copy com.bourre.events.Broadcaster#removeEventListener()
		 */
		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			return _oEB.removeEventListener( type, listener );
		}

		public function isVisible() : Boolean
		{
			return view.visible;
		}

		public function setName( name : String ) : void
		{
			var vl : ViewLocator = ViewLocator.getInstance( getOwner() );

			if ( name != null && !( vl.isRegistered( name ) ) )
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
				this.view = dpo;

			} else if ( ( CoreFactory.getInstance().isRegistered( name ) &&  CoreFactory.getInstance().locate( name ) is DisplayObject ) )
			{					
					this.view = ( CoreFactory.getInstance().locate( name ) as DisplayObject );
			}

			setName( avName? avName: name );
			onInitView();
		}
	}
}