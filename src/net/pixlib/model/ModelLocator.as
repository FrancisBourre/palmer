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
	import net.pixlib.collections.ArrayIterator;
	import net.pixlib.collections.HashMap;
	import net.pixlib.collections.Iterator;
	import net.pixlib.core.AbstractLocator;
	import net.pixlib.exceptions.PrivateConstructorException;
	import net.pixlib.plugin.NullPlugin;
	import net.pixlib.plugin.Plugin;
	import net.pixlib.plugin.PluginDebug;

	/**
	 * The ModelLocator class is a locator for 
	 * <code>Model</code> object.
	 * 
	 * <p>A locator is unique for a <code>Plugin</code> instance.</p>
	 * 
	 * @see AbstractModel	 * @see Model
	 * 
	 * @author Francis Bourre
	 */
	final public class ModelLocator 
		extends AbstractLocator
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		static private const _M : HashMap = new HashMap();

		private var _owner : Plugin;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Returns the unique <code>ModelLocator</code> instance for 
		 * passed-in <code>Plugin</code>.
		 * 
		 * @return The unique <code>ModelLocator</code> instance.
		 */
		static public function getInstance( owner : Plugin = null ) : ModelLocator
		{
			if ( owner == null ) owner = NullPlugin.getInstance();

			if ( !(ModelLocator._M.containsKey( owner )) ) 
				ModelLocator._M.put( owner, new ModelLocator(new ConstructorAccess() , owner ) );

			return ModelLocator._M.get( owner );
		}
		
		/**
		 * Returns the plugin owner of this locator.
		 * 
		 * @return The plugin owner of this locator.
		 */
		public function getOwner() : Plugin
		{
			return _owner;
		}
		
		/**
		 * Returns <code>AbstractModel</code> registered with passed-in 
		 * key identifier.
		 * 
		 * @param	key	Model registration ID
		 * 
		 * @throws 	<code>NoSuchElementException</code> — There is no model
		 * 			associated with the passed-in key
		 */
		public function getModel( key : String ) : Model
		{
			return locate( key ) as Model;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function release() : void
		{
			var i : Iterator = new ArrayIterator( _m.getValues() );
			while( i.hasNext() ) i.next().release();
			super.release();
			_owner = null ;
		}

		/**
		 * Returns the string representation of this instance.
		 * @return the string representation of this instance
		 */
		override public function toString() : String 
		{
			return super.toString() + (_owner?", owner: "+_owner:"No owner.");
		}
		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
		
		/** @private */
		function ModelLocator( access : ConstructorAccess, owner : Plugin = null ) 
		{
			_owner = owner;
			super( Model, null, PluginDebug.getInstance( getOwner() ) );
			
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}
	}
}
internal class ConstructorAccess {}