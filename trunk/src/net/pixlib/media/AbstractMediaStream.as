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
 
package net.pixlib.media 
{
	import net.pixlib.commands.CommandMS;
	import net.pixlib.commands.Delegate;
	import net.pixlib.core.palmer_internal;
	import net.pixlib.events.Broadcaster;
	import net.pixlib.events.EventBroadcaster;
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.exceptions.UnimplementedMethodException;
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.log.PalmerStringifier;
	import net.pixlib.media.video.VideoStreamListener;

	import flash.events.Event;
	
	use namespace palmer_internal;
	
	/**
	 * 
	 */
	public class AbstractMediaStream
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private var _bRunning : Boolean;
		private var _oEB : EventBroadcaster;
		private var _oMeta : Metadata;
		private var _nPlayheadUpdateInterval : int;		private var _dPlayheadUpdateMethod : Delegate;
		
		
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		/** last correct media playhead position. */
		protected var lastPlayheadPosition : Number;
		
		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * 
		 */
		public function get playheadUpdateInterval() : uint
		{
			return _nPlayheadUpdateInterval;
		}
		/** @private */
		public function set playheadUpdateInterval( value : uint ) : void
		{
			_nPlayheadUpdateInterval = value;
			
			CommandMS.getInstance().remove( _dPlayheadUpdateMethod );
			
			if( isRunning() )
			{
				CommandMS.getInstance().push( _dPlayheadUpdateMethod, _nPlayheadUpdateInterval );
			}
		}		
		
		/**
		 * @inheritDoc
		 */
		public function get playheadTime() : Number
		{
			return lastPlayheadPosition;	
		}
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Returns <code>true</code> if media is currently playing.
		 */
		public function isRunning(  ) : Boolean
		{
			return _bRunning;	
		}
		
		/**
		 *	Returns media metadata.
		 */
		public function getMetadata(  ) : Metadata
		{
			return _oMeta;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addListener( listener : VideoStreamListener ) : Boolean
		{
			return getBroadcaster().addListener( listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeListener( listener : VideoStreamListener ) : Boolean
		{
			return getBroadcaster().removeListener( listener );
		}
		
		/**
		 * @inheritDoc
		 */
		public function addEventListener( type : String, listener : Object, ... rest ) : Boolean
		{
			return getBroadcaster().addEventListener.apply( _oEB, rest.length > 0 ? [ type, listener ].concat( rest ) : [ type, listener ] );
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeEventListener( type : String, listener : Object ) : Boolean
		{
			return getBroadcaster().removeEventListener( type, listener );
		}
		
		
		/**
		 * Returns the string representation of instance.
		 * 
		 * @return THe string representation of instance.
		 */
		public function toString(  ) : String
		{
			return PalmerStringifier.stringify( this );
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * Sets metadata properties.
		 */
		protected function setMetadata( meta : Metadata ) : void
		{
			_oMeta = meta;
		}
		
		/**
		 * Sets the media running state.
		 */
		protected function setRunning( b : Boolean ) : void
		{
			_bRunning = b;
			
			if( _bRunning )
			{
				CommandMS.getInstance().push( _dPlayheadUpdateMethod, _nPlayheadUpdateInterval );	
			}
			else
			{
				CommandMS.getInstance().remove( _dPlayheadUpdateMethod );	
			}
			
			fireEventType( MediaStreamEvent.onMediaPlayheadEVENT );
		}
		
		/**
		 * Default media playhead checker.
		 */
		protected function checkPlayhead(  ) : void
		{
			lastPlayheadPosition = palmer_internal::getPlayheadTime();
			
			fireEventType( MediaStreamEvent.onMediaPlayheadEVENT );
		}
		
		/**
		 * @private
		 * 
		 * Returns concrete media playhead position
		 */
		palmer_internal function getPlayheadTime() : Number
		{
			var msg : String = this + ".palmer_internal::playheadTime must be implemented in class.";
			PalmerDebug.ERROR( msg );
			throw( new UnimplementedMethodException( msg ) );
			
			return 0;
		}

		/**
		 * Returns media broadcaster.
		 */
		protected function getBroadcaster(  ) : Broadcaster
		{
			return _oEB;
		}
		
		/**
		 * Dispatches event using passed-in type.
		 * 
		 * @param	type			Event type so dispatch
		 * 
		 * @see #fireEvent()
		 */
		protected function fireEventType( type : String ) : void
		{
			fireEvent( getMediaEvent( type ) );
		}
		
		/**
		 * Dispatched passed-in event to all registered listeners.
		 * 
		 * @param	e	Event to dispatch
		 */
		protected function fireEvent( e : Event ) : void
		{
			getBroadcaster().broadcastEvent( e );
		}	
		
		/**
		 * Returns a MediaEvent event.
		 * 
		 * <p>Must be override by subclasses.</p>
		 * 
		 * @return A MediaStreamEvent event for current media instance.
		 */
		protected function getMediaEvent( type : String ) : MediaStreamEvent
		{
			return new MediaStreamEvent( type, null );
		}
		
		/**
		 * Returns Abstract constructor access.
		 */
		protected function getContructorAccess() : ConstructorAccess
		{
			return ConstructorAccess.instance;
		}
		
		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
		
		/**
		 * @private
		 */
		function AbstractMediaStream( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
			
			_bRunning = false;
			_oEB = new EventBroadcaster( this );
			
			_nPlayheadUpdateInterval = 500;
			_dPlayheadUpdateMethod = new Delegate( checkPlayhead );
		}		
	}
}

internal class ConstructorAccess
{
	public static const instance : ConstructorAccess = new ConstructorAccess( );
}