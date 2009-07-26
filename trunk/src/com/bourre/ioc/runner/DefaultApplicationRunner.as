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

package com.bourre.ioc.runner 
{
	import com.bourre.ioc.load.ApplicationLoaderEvent;
	import com.bourre.ioc.load.ApplicationLoaderListener;
	import com.bourre.ioc.load.ApplicationLoaderState;
	import com.bourre.load.LoaderEvent;
	import com.bourre.log.Logger;
	import com.bourre.log.PalmerDebug;
	import com.bourre.log.layout.FirebugLayout;

	/**
	 * IoC Application runner.
	 * 
	 * <p>This dedicated runner adds Logging rules.</p>
	 * 
	 * @see #initLogger()
	 * 
	 * @author Romain Ecarnot
	 */
	public class DefaultApplicationRunner extends BasicApplicationRunner implements ApplicationLoaderListener
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		/** IoC engine state name. */
		protected var state : String = "IoC";

		
		//-------------------------------------------------------------------------
		// Public API
		//-------------------------------------------------------------------------
		
		/**
		 * Creates instance.
		 */
		public function DefaultApplicationRunner() 
		{
			super( );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationState(e : ApplicationLoaderEvent) : void
		{
			state = e.getApplicationState( );
			
			PalmerDebug.DEBUG( "[IoC] run " + state + " task", this );
			
			if( state == ApplicationLoaderState.COMPLETE_STATE )
			{
				oLoader.removeListener( this );
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationLoadStart(e : ApplicationLoaderEvent) : void
		{
			logStep( e );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationParsed(e : ApplicationLoaderEvent) : void
		{
			logStep( e );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationObjectsBuilt(e : ApplicationLoaderEvent) : void
		{
			logStep( e );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationChannelsAssigned(e : ApplicationLoaderEvent) : void
		{
			logStep( e );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationMethodsCalled(e : ApplicationLoaderEvent) : void
		{
			logStep( e );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationInit(e : ApplicationLoaderEvent) : void
		{
			logStep( e );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadStart(e : LoaderEvent) : void
		{
			//PalmerDebug.DEBUG( getLoaderString( e ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadInit(e : LoaderEvent) : void
		{
			PalmerDebug.DEBUG( getLoaderString( e ), this );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadProgress(e : LoaderEvent) : void
		{
			//PalmerDebug.DEBUG( getLoaderString( e ) + "[ " + formatPercent( e ) + "% ] " );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadTimeOut(e : LoaderEvent) : void
		{
			PalmerDebug.ERROR( "[" + state + "] " + e.getErrorMessage( ), this );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadError(e : LoaderEvent) : void
		{
			PalmerDebug.ERROR( "[" + state + "] " + e.getErrorMessage( ), this );
		}
		
		
		//-------------------------------------------------------------------------
		// Protected methods
		//-------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function preprocess() : void
		{
			oLoader.addListener( this );
			
			initLogger( );
		}
		
		/**
		 * Adds <code>FirebugLayout</code> logging target to Palmer Logger.
		 * 
		 * <p>Overrides this method to define own logging logic.</p>
		 */
		protected function initLogger() : void
		{
			Logger.getInstance( ).addLogListener( FirebugLayout.getInstance( ) );
		}
		
		/**
		 * @private
		 */
		protected function logStep( e : LoaderEvent ) : void
		{
			PalmerDebug.DEBUG( "[IoC] pass " + e.getType( ), this );
		}
		
		/**
		 * @private
		 */
		protected function getLoaderString( e : LoaderEvent ) : String
		{
			return "[" + state + "] " + e.getType( ) + "( " + formatURL( e ) + " ) ";	
		}
		
		/**
		 * @private
		 */
		protected function formatURL( e : LoaderEvent ) : String
		{
			if( e.getLoader() != null )
			{
				var url : String = e.getLoader( ).getURL( ).url;
				
				return url.substring( 0, url.indexOf( "?" ) );
			}
			else return "";	
		}
		
		/**
		 * @private
		 */
		protected function formatPercent( e : LoaderEvent ) : String
		{
			var n : Number = e.getPerCent( );
			var d : Number = 3 - n.toString( ).length;
			var s : String = "";
			if( d > 0 ) for( var i : Number = 0; i < d ; i++ ) s += "0";
			return s + n;
		}
	}
}	