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
	import com.bourre.ioc.assembler.builder.DefaultDisplayObjectBuilder;
	import com.bourre.ioc.load.ApplicationLoader;
	import com.bourre.log.PalmerDebug;
	import com.bourre.utils.FlashVars;

	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	/**
	 * IoC Application runner.
	 * 
	 * <p>Basic IoC builder implementation.<br />
	 * Just need to compile this class to starts IoC processing.</p>
	 * 
	 * @author Romain Ecarnot
	 */
	public class BasicApplicationRunner extends Sprite
	{
		//-------------------------------------------------------------------------
		// Protected properties
		//-------------------------------------------------------------------------
		
		/** Aplication loader instance. */
		protected var oLoader : ApplicationLoader;

		
		//-------------------------------------------------------------------------
		// Public API
		//-------------------------------------------------------------------------
		
		/**
		 * Creates instance.
		 */
		public function BasicApplicationRunner() 
		{
			checkFlashvars();
			
			initStage( );
			
			loadContext( );
		}
		
		
		//-------------------------------------------------------------------------
		// Protected methods
		//-------------------------------------------------------------------------
		
		/**
		 * Retreives Flashvars if defined.
		 */
		protected function checkFlashvars( ) : void
		{
			try
			{
				var param : Object = LoaderInfo( root.loaderInfo ).parameters;
				for ( var p : * in param ) 
				{
					FlashVars.getInstance().register( p, param[ p ] );
				}
			} 
			catch ( e : Error )
			{
				PalmerDebug.ERROR( this + "::" + e.message );
			}
		}
		
		/**
		 * Defines some stage properties.
		 * 
		 * <p>Default is 
		 * <ul>
		 * 	<li><code>StageAlign.TOP_LEFT</code></li>
		 * 	<li><code>StageScaleMode.NO_SCALE</code></li>
		 *</ul></p>
		 *
		 *<p>Overrides to customize stage properties.</p>
		 */
		protected function initStage( ) : void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;	
		}

		/**
		 * Loads application context.
		 * 
		 * <p>Before loading context, you can do some preprocessing 
		 * as method <code>preprocess</code> is call just before.</p>
		 * 
		 * @see #preprocess()
		 */
		protected function loadContext( ) : void
		{
			oLoader = createApplicationLoader( );
			
			preprocess( );
			
			oLoader.execute( );
		}

		/**
		 * Creates new basic ApplicationLoader instance.
		 */
		protected function createApplicationLoader( ) : ApplicationLoader
		{
			var loader : ApplicationLoader = new ApplicationLoader( createApplicationTarget( ), false );
			loader.setAntiCache( true );
			loader.setDisplayObjectBuilder( new DefaultDisplayObjectBuilder( ) );
			
			return loader;
		}

		/**
		 * Creates the main application container.
		 * 
		 * @return The main application container.
		 */
		protected function createApplicationTarget( ) : DisplayObjectContainer
		{
			return this;	
		}

		/**
		 * Runs actions before application loading
		 * 
		 * <p>Do nothing here, just override this method in subclass 
		 * to customize preprocessing actions.</p>
		 */
		protected function preprocess() : void
		{
			//
			
		}
	}
}
