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
 
package com.bourre.ioc.display 
{	import flash.display.MovieClip;	

	/**	 * Default implementation of display loader object.
	 * 
	 * <p>This implementations use loader callback definition in xml 
	 * context file as :
	 * <pre class="prettyprint lang-xml">
	 * &lt;application-loader url="loader.swf" 
	 *		start-callback="onStartApplication" 
	 *		name-callback="onNameCallback"
	 *	
	 *		load-callback="onLoadCallback"
	 *		progress-callback="onProgressCallback"
	 *		timeout_callback="onTimeoutCallback"
	 *		error-callback="onErrorCallback"
	 *		init-callback="onInitCallback"
	 *	
	 *		parsed-callback="onParsedCallback"
	 *		objects-built-callback="onBuiltCallback"
	 *		channels-assigned-callback="onChannelsCallback"
	 *		methods-call-callback="onMethodsCallback"
	 *	
	 *		complete-callback="onCompleteCallback"
	 * /&gt;</pre>
	 * </p>
	 * 
	 * <p>Extends class to customize loading renderer.</p>
	 * 
	 * @see DisplayLoader	 * @see DisplayLoaderProxy
	 * 
	 * @author Romain Ecarnot	 */	public class AbstractDisplayLoader extends MovieClip implements DisplayLoader
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates instance.
		 */		
		public function AbstractDisplayLoader()
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onStartApplication( url : String, size : uint = 0 ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onNameCallback( state : String ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onLoadCallback( url : String ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onProgressCallback( url : String, percent : Number ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onTimeoutCallback( url : String ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onErrorCallback( url : String ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onInitCallback( url : String ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onParsedCallback( ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onBuiltCallback( ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onChannelsCallback( ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onMethodsCallback( ) : void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function onCompleteCallback( ) : void
		{
		}	}}