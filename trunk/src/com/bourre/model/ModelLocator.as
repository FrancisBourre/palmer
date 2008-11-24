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
package com.bourre.model
{
	import com.bourre.collections.ArrayIterator;
	import com.bourre.collections.HashMap;
	import com.bourre.collections.Iterator;
	import com.bourre.core.AbstractLocator;
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.plugin.NullPlugin;
	import com.bourre.plugin.Plugin;
	import com.bourre.plugin.PluginDebug;	

	/**
	 * @author Francis Bourre
	 */
	final public class ModelLocator 
		extends AbstractLocator
	{
		static private const _M : HashMap = new HashMap();

		private var _owner : Plugin;

		public function ModelLocator( access : ConstructorAccess, owner : Plugin = null ) 
		{
			_owner = owner;
			super( Model, null, PluginDebug.getInstance( getOwner() ) );
			
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();
		}

		static public function getInstance( owner : Plugin = null ) : ModelLocator
		{
			if ( owner == null ) owner = NullPlugin.getInstance();

			if ( !(ModelLocator._M.containsKey( owner )) ) 
				ModelLocator._M.put( owner, new ModelLocator(new ConstructorAccess() , owner ) );

			return ModelLocator._M.get( owner );
		}

		public function getOwner() : Plugin
		{
			return _owner;
		}

		public function getModel( key : String ) : Model
		{
			return locate( key ) as Model;
		}

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
	}
}
internal class ConstructorAccess {}