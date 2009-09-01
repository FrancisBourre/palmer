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
package net.pixlib.load
{
	import net.pixlib.load.strategy.LoaderStrategy;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.system.ApplicationDomain;	

	/**
	 * The GraphicLoader class is used to load SWF files or image (JPG, PNG, 
	 * or GIF) files. 
	 * 
	 * @example
	 * <pre class="prettyprint">
	 * 
	 * var loader : GraphicLoader = new GraphicLoader( mcContainer, -1, true );
	 * loader.load( new URLRequest( "logo.swf" );
	 * </pre>
	 * 
	 * @author 	Francis Bourre
	 */
	public class GraphicLoader extends AbstractLoader
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------

		private var _target : DisplayObjectContainer;
		private var _index : int;
		private var _bAutoShow : Boolean;
		private var _oBitmapContainer : Sprite;

		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates new <code>GraphicLoader</code> instance.
		 * 
		 * @param	target		(optional) Container of loaded display object
		 * @param	index		(optional) Index of loaded display object in target 
		 * 						display list
		 * @param	autoShow	(optional) Loaded object visibility
		 */	
		public function GraphicLoader( target : DisplayObjectContainer = null, index : int = -1, autoShow : Boolean = true )
		{
			super( new LoaderStrategy( ) );

			_target = target;
			_index = index;
			_bAutoShow = autoShow;
		}
		
		/**
		 * Returns the container of loaded object.
		 * 
		 * @return The container of loaded object.
		 */
		public function getTarget() : DisplayObjectContainer
		{
			return _target;
		}
		
		/**
		 * Sets the container of loaded display object.
		 * 
		 * @param	target	Container of loaded display object
		 */
		public function setTarget( target : DisplayObjectContainer ) : void
		{
			_target = target ;

			if ( _target != null )
			{
				if ( _index != -1 )
				{
					_target.addChildAt( getDisplayObject( ), _index );
				} 
				else
				{
					_target.addChild( getDisplayObject( ) );
				}
			} 
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function onInitialize() : void
		{
			if ( _target ) setTarget( _target );
			
			if ( _bAutoShow ) 
			{
				show();

			} else
			{
				hide();
			}
			
			super.onInitialize();
		}
		
		/**
		 * Defines the new content ( display object ) of the loader.
		 */
		override public function setContent( content : Object ) : void
		{	
			if ( content is Bitmap )
			{
				_oBitmapContainer = new Sprite( );
				_oBitmapContainer.addChild( content as Bitmap );
			} 
			else
			{
				_oBitmapContainer = null;
			}

			super.setContent( content );
			
			if( getName() != null )
			{
				try
				{
					getDisplayObject().name = getName();
				}
				catch( e : Error )
				{
					//timeline based object
				}
			}
		}
		
		/**
		 * Shows the display object.
		 */
		public function show() : void
		{
			getDisplayObject( ).visible = true;
		}
		
		/**
		 * Hides the display object.
		 */
		public function hide() : void
		{
			getDisplayObject( ).visible = false;
		}
		
		/**
		 * Returns <code>true</code> if display object is visible.
		 * 
		 * @return <code>true</code> if display object is visible.
		 */
		public function isVisible() : Boolean
		{
			return getDisplayObject( ).visible;
		}
		
		/**
		 * 
		 */
		public function setAutoShow( b : Boolean ) : void
		{
			_bAutoShow = b;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function release() : void
		{
			if ( getContent( ) && _target && _target.contains( getDisplayObject( ) ) ) _target.removeChild( getDisplayObject( ) );
			
			super.release( );
		}
		
		/**
		 * Returns the display object.
		 * 
		 * @return The display object.
		 */
		public function getDisplayObject() : DisplayObjectContainer
		{
			return _oBitmapContainer ? _oBitmapContainer : super.getContent( ) as DisplayObjectContainer;
		}
		
		/**
		 * @private
		 */
		override public function getContent() : Object
		{
			return getDisplayObject();
		}
		
		/**
		 * Returns a LoaderInfo object corresponding to the object being loaded.
		 * 
		 * @return A LoaderInfo object corresponding to the object being loaded.
		 */
		public function getContentLoaderInfo() : LoaderInfo
		{
			return LoaderStrategy( getStrategy() ).getContentLoaderInfo();
		}
		
		/**
		 * Returns the <code>applicationDomain</code> of loaded display object.
		 * 
		 * @return The <code>applicationDomain</code> of loaded display object.
		 */
		public function getApplicationDomain() : ApplicationDomain
		{
			return ( getStrategy( ) as LoaderStrategy ).getContentLoaderInfo( ).applicationDomain;
		}
	}
}