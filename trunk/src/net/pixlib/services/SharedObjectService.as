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
package net.pixlib.services 
{
	import net.pixlib.core.ValueObject;
	import net.pixlib.exceptions.NullPointerException;
	import net.pixlib.utils.ObjectUtils;

	import flash.events.Event;
	import flash.net.SharedObject;

	/**
	 * Command implementation to retreive Local SharedObject data.
	 * 
	 * @example
	 * <pre class="prettyprint">
	 * 
	 * public function test( ) : void
	 * {
	 * 	var service : SharedObjectService = new SharedObjectService( "config.user.name", "/" );
	 * 	service.addServiceListener( this );
	 * 	service.execute();
	 * }
	 * 
	 * public function onDataResult ( event : ServiceEvent ) : void
	 * {
	 * 	var result : Object = event.getService().getResult();
	 * }
	 * </pre>
	 * 
	 * @author Romain Ecarnot
	 * @author Francis Bourre
	 */
	public class SharedObjectService 
		extends AbstractService
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		
		private var _helper : SharedObjectServiceHelper;
		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		/**
		 * The name of the object.
		 */
		public function get name( ) : String
		{
			return _helper.name;		
		}
		
		/**
		 * The shared object path.
		 */
		public function get localPath(  ) : String
		{
			return _helper.localPath;
		}

		/**
		 * Restricted to HTTPS connection.
		 */
		public function get secured(  ) : Boolean
		{
			return _helper.secure;
		}

		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * @param	name		The name of the object.
		 * @param	localPath	The full or partial path to the SWF file that 
		 * 						created the	shared object, and that determines 
		 * 						where the shared object will be stored locally. 
		 * 						If you do not specify this parameter, 
		 * 						the root "/" is used.
		 * 	@param	secure		Determines whether access to this shared object 
		 * 						is restricted to SWF files that are delivered 
		 * 						over an HTTPS connection.(default is false)
		 */	
		public function SharedObjectService ( name : String = "", localPath : String = "/", secure : Boolean = false )
		{
			super( );
			setExecutionHelper( new SharedObjectServiceHelper( name, localPath, secure ) );
		}

		/**
		 * @inheritDoc
		 */
		override protected function onExecute( e : Event = null ) : void
        {
        	super.onExecute( e );

			if ( _helper is SharedObjectServiceHelper )
			{
	        	try
				{					var so : SharedObject = SharedObject.getLocal.apply( null, getRemoteArguments() );
					onResultHandler( so.data );
	
				} catch( e : Error )
				{
					getLogger( ).error( this + " call failed !. " + e.message );
					onFaultHandler( null );
				}

			} else
			{
				var msg : String = this + ".execute() failed. Can't retrieve valid execution helper.";
				getLogger().error( msg );
				throw new NullPointerException( msg );
			}
        }
        
        /**
		 * @inheritDoc
		 */
        override public function setResult( result : Object ) : void
		{
			var a : Array = name.split(".");
			if ( a.length > 1 ) 
			{
				a.splice( 0, 1 );
				result = ObjectUtils.evalFromTarget( result, a.join(".") );
			}

			super.setResult( result );
		}
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------

		/**
		 * 
		 */
		override protected function setExecutionHelper( helper : ValueObject ) : void
		{
			_helper = helper as SharedObjectServiceHelper;
		}

		/**
		 * 
		 */
		override protected function getRemoteArguments() : Array
		{
			return [name.split( "." )[0], localPath, secured];
		}
	}
}