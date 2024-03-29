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
 
package net.pixlib.ioc.display 
{
	import net.pixlib.ioc.display.DisplayLoaderInfo;
	import net.pixlib.ioc.load.ApplicationLoaderEvent;
	import net.pixlib.ioc.load.ApplicationLoaderListener;
	import net.pixlib.load.LoaderEvent;
	import net.pixlib.log.PalmerStringifier;
	
	import flash.display.DisplayObjectContainer;
	import flash.net.URLRequest;	

	/**	 * <p>Proxy to allow connection between <code>ApplicationLoaderListener</code> and 
	 * a generic Display Loader object.</p>
	 * 
	 * @see DisplayLoader
	 * @see AbstractDisplayLoader
	 * 
	 * @author Romain Ecarnot	 */	public class DisplayLoaderProxy implements ApplicationLoaderListener
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _oTarget : Object;
		private var _oInfo : DisplayLoaderInfo;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates instance
		 * 
		 * @param	target	Display Loader object
		 * @param	info	Informations about Display loader callbacks.
		 */
		public function DisplayLoaderProxy( target : DisplayObjectContainer, info : DisplayLoaderInfo )
		{
			_oTarget = target;
			_oInfo = info;
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationState(e : ApplicationLoaderEvent) : void
		{
			call( _oInfo.nameCallback, e.getApplicationState( ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationLoadStart(e : ApplicationLoaderEvent) : void
		{
			call( _oInfo.startCallback, cleanURL( e.getApplicationLoader( ).getURL( ) ), e.getApplicationLoader( ).getDisplayObjectBuilder( ).size( ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationParsed(e : ApplicationLoaderEvent) : void
		{
			call( _oInfo.parsedCallback );
		}

		/**
		 * @inheritDoc
		 */
		public function onApplicationObjectsBuilt(e : ApplicationLoaderEvent) : void
		{
			call( _oInfo.objectsBuiltCallback );
		}

		/**
		 * @inheritDoc
		 */
		public function onApplicationChannelsAssigned(e : ApplicationLoaderEvent) : void
		{
			call( _oInfo.channelsAssignedCallback );
		}

		/**
		 * @inheritDoc
		 */
		public function onApplicationMethodsCalled(e : ApplicationLoaderEvent) : void
		{
			call( _oInfo.methodsCallCallback );
		}

		/**
		 * @inheritDoc
		 */
		public function onApplicationInit(e : ApplicationLoaderEvent) : void
		{
			call( _oInfo.completeCallback );
		}

		/**
		 * @inheritDoc
		 */
		public function onLoadStart(e : LoaderEvent) : void
		{
			call( _oInfo.loadCallback, cleanURL( e.getLoader( ).getURL( ) ) );
		}

		/**
		 * @inheritDoc
		 */
		public function onLoadInit(e : LoaderEvent) : void
		{
			call( _oInfo.initCallback, cleanURL( e.getLoader( ).getURL( ) ) );
		}

		/**
		 * @inheritDoc
		 */
		public function onLoadProgress(e : LoaderEvent) : void
		{
			call( _oInfo.progressCallback, cleanURL( e.getLoader( ).getURL( ) ), e.getPerCent( ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadTimeOut(e : LoaderEvent) : void
		{
			call( _oInfo.timeoutCallback, cleanURL( e.getLoader( ).getURL( ) )  + " timeout" );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadError(e : LoaderEvent) : void
		{
			call( _oInfo.errorCallback, e.getErrorMessage( ) );
		}
		
		/**
		 * Returns string representation.
		 */
		public function toString(  ) : String
		{
			return PalmerStringifier.stringify( this ) + "\n" + _oInfo.toString( );
		}	
		
		
		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		
		/**
		 * Call passed-in callback on Display Loader target.
		 * 
		 * @param	callback	Method to call on target
		 * @param	...			Methods arguments
		 */
		protected function call( callback : String, ...args ) : void
		{
			if( callback.length > 0 && _oTarget.hasOwnProperty( callback ) )
			{
//				PalmerDebug.DEBUG( this + " call " + callback + "( " + args  + " )" );
				
				_oTarget[callback].apply( _oTarget, args );
			}
		}
		
		/**
		 * Cleans passed-in <code>request</code> url removing anticache 
		 * informations if any.
		 */
		protected function cleanURL( request : URLRequest ) : String
		{
			return request.url.substring( 0, request.url.indexOf( "?" ) );
		}
	}}