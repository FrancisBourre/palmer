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
	import com.bourre.log.LogLevel;
	import com.bourre.log.Logger;
	import com.bourre.log.PalmerDebug;
	import com.bourre.log.layout.FirebugLayout;	

	/**
	 * IoC Runner.
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

		public function onApplicationState(e : ApplicationLoaderEvent) : void
		{
			state = e.getApplicationState( );
			
			PalmerDebug.DEBUG( "[IoC] run " + state + " task" );
			
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
			PalmerDebug( getStep( e ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationParsed(e : ApplicationLoaderEvent) : void
		{
			PalmerDebug( getStep( e ) );
		}

		public function onApplicationObjectsBuilt(e : ApplicationLoaderEvent) : void
		{
			PalmerDebug( getStep( e ) );
		}

		public function onApplicationChannelsAssigned(e : ApplicationLoaderEvent) : void
		{
			PalmerDebug( getStep( e ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationMethodsCalled(e : ApplicationLoaderEvent) : void
		{
			PalmerDebug( getStep( e ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onApplicationInit(e : ApplicationLoaderEvent) : void
		{
			PalmerDebug( getStep( e ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadStart(e : LoaderEvent) : void
		{
			PalmerDebug.DEBUG( getLoaderString( e ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadInit(e : LoaderEvent) : void
		{
			PalmerDebug.DEBUG( getLoaderString( e ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadProgress(e : LoaderEvent) : void
		{
			PalmerDebug.DEBUG( getLoaderString( e ) + "[ " + formatPercent( e ) + "% ] " );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadTimeOut(e : LoaderEvent) : void
		{
			PalmerDebug.ERROR( "[" + state + "] " + e.getErrorMessage( ) );
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadError(e : LoaderEvent) : void
		{
			PalmerDebug.ERROR( "[" + state + "] " + e.getErrorMessage( ) );
		}
		
		
		//-------------------------------------------------------------------------
		// Protected methods
		//-------------------------------------------------------------------------
		
		/**
		 * @inheritDoc
		 */
		override protected function preprocess() : void
		{
			if( palmer_compilation::productionBuild ) 
			{
				Logger.getInstance( ).setLevel( LogLevel.ERROR );
			}
			else
			{
				oLoader.addListener( this );
			}
			
			initLogger( );
		}
		
		/**
		 * 
		 */
		protected function initLogger() : void
		{
			Logger.getInstance( ).addLogListener( FirebugLayout.getInstance( ) );
		}
		
		/**
		 * @private
		 */
		protected function getStep( e : LoaderEvent ) : void
		{
			PalmerDebug.DEBUG( "[IoC] pass " + e.getType( ) );
		}
		
		/**
		 * @private
		 */
		protected function getLoaderString( e : LoaderEvent ) : String
		{
			return "[" + state + "] " + e.getType( ) + "( " + formatURL( e ) + " ) ";	
		}
		
		/**
		 * 
		 */
		protected function formatURL( e : LoaderEvent ) : String
		{
			var url : String = e.getLoader( ).getURL( ).url;
			
			return url.substring( 0, url.indexOf( "?" ) );	
		}
		
		/**
		 * 
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