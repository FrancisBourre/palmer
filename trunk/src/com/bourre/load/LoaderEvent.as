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
package com.bourre.load
{
	import com.bourre.events.BasicEvent;
	
	use namespace palmer_GraphicLoader;
	
	use namespace palmer_FileLoader;
	
	use namespace palmer_StreamLoader;
	
	use namespace palmer_XMLLoader;
	
	use namespace palmer_VideoLoader;
	
	use namespace palmer_SoundLoader;
		use namespace palmer_CSSLoader;
	
	/**
	 * An event object which carry a <code>Loader</code> value.
	 * 
	 * @author 	Francis Bourre
	 * 
	 * @see Loader
	 */
	public class LoaderEvent extends BasicEvent
	{
		//--------------------------------------------------------------------
		// Events
		//--------------------------------------------------------------------
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onLoadStart</code> event.
		 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>type</code></td>
	     *     	<td>Dispatched event type</td>
	     *     </tr>
	     *     
	     *     <tr><th>Method</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>getLoader()</code>
	     *     	</td><td>The loader object</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getName()</code>
	     *     	</td><td>The loader identifier</td>
	     *     </tr>
	     * </table>
	     * 
		 * @eventType onLoadStart
		 */		
		public static const onLoadStartEVENT 	: String = "onLoadStart";
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onLoadInit</code> event.
		 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>type</code></td>
	     *     	<td>Dispatched event type</td>
	     *     </tr>
	     *     
	     *     <tr><th>Method</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>getLoader()</code>
	     *     	</td><td>The loader object</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getName()</code>
	     *     	</td><td>The loader identifier</td>
	     *     </tr>
	     * </table>
	     * 
		 * @eventType onLoadInit
		 */
		public static const onLoadInitEVENT 	: String = "onLoadInit";
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onLoadProgress</code> event.
		 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>type</code></td>
	     *     	<td>Dispatched event type</td>
	     *     </tr>
	     *     
	     *     <tr><th>Method</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>getLoader()</code>
	     *     	</td><td>The loader object</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getName()</code>
	     *     	</td><td>The loader identifier</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getPercent()</code>
	     *     	</td><td>The loading progression</td>
	     *     </tr>
	     * </table>
	     * 
		 * @eventType onLoadProgress
		 */
		public static const onLoadProgressEVENT : String = "onLoadProgress";
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onLoadTimeOut</code> event.
		 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>type</code></td>
	     *     	<td>Dispatched event type</td>
	     *     </tr>
	     *     
	     *     <tr><th>Method</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>getLoader()</code>
	     *     	</td><td>The loader object</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getName()</code>
	     *     	</td><td>The loader identifier</td>
	     *     </tr>
	     * </table>
	     * 
		 * @eventType onLoadTimeOut
		 */
		public static const onLoadTimeOutEVENT 	: String = "onLoadTimeOut";
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onLoadError</code> event.
		 * 
		 * <p>The properties of the event object have the following values:</p>
	     * <table class="innertable">
	     *     <tr><th>Property</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>type</code></td>
	     *     	<td>Dispatched event type</td>
	     *     </tr>
	     *     
	     *     <tr><th>Method</th><th>Value</th></tr>
	     *     <tr>
	     *     	<td><code>getLoader()</code>
	     *     	</td><td>The loader object</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getName()</code>
	     *     	</td><td>The loader identifier</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getErrorMessage()</code>
	     *     	</td><td>The loader identifier</td>
	     *     </tr>
	     * </table>
	     * 
		 * @eventType onLoadError
		 */
		public static const onLoadErrorEVENT 	: String = "onLoadError";
		
		
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		/** @private */
		protected var _loader : Loader;
		
		/** @private */
		protected var _sErrorMessage : String;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
				
		/**
		 * Creates a new <code>LoaderEvent</code> object.
		 * 
		 * @param	type			Name of the event type
		 * @param	loader			Loader object carried by this event
		 * @param	errorMessage	(optional) Error message carried by this event
		 */	
		public function LoaderEvent( type : String, loader : Loader, errorMessage : String = "", bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super( type, loader, bubbles, cancelable );
			
			_loader = loader;
			_sErrorMessage = errorMessage;
		}
		
		/**
		 * Returns the loading progression value of object carried by 
		 * this event.
		 * 
		 * @return	The loading progression value of object carried by 
		 * 			this event.
		 */
		public function getPerCent() : Number
		{
			return getLoader().getPerCent();
		}
		
		/**
		 * Returns the loader named carried by this event.
		 * 
		 * @return	The loader name carried by this event.
		 */
		public function getName() : String
		{
			return getLoader().getName();
		}
		
		/**
		 * Sets the error message to be carried by this event.
		 * 
		 * @param	errorMessage	Error message to carry
		 */
		public function setErrorMessage( errorMessage : String = "" ) : void
		{
			_sErrorMessage = errorMessage.length > 0 ? errorMessage : getLoader() + " loading fails with '" + getLoader().getURL().url + "'";
		}
		
		/**
		 * Returns the error message carried by this event.
		 * 
		 * @return	The error message carried by this event.
		 */
		public function getErrorMessage() : String
		{
			return _sErrorMessage;
		}
		
		/**
		 * Returns the loader object carried by this event.
		 * 
		 * @return	The loader value carried by this event.
		 */
		public function getLoader() : Loader
		{
			return _loader;
		}
		
		/**
		 * Returns the FileLoader object carried by this event.
		 * 
		 * @return	The loader value carried by this event.
		 */
		palmer_FileLoader function getLoader() : Loader
		{
			return _loader as FileLoader;
		}
		
		/**
		 * Returns the GraphicLoader object carried by this event.
		 * 
		 * @return	The loader value carried by this event.
		 */
		palmer_GraphicLoader function getLoader() : GraphicLoader
		{
			return _loader as GraphicLoader;
		}
		
		/**
		 * Returns the SoundLoader object carried by this event.
		 * 
		 * @return	The loader value carried by this event.
		 */
		palmer_SoundLoader function getLoader() : SoundLoader
		{
			return _loader as SoundLoader;
		}
		
		/**
		 * Returns the StreamLoader object carried by this event.
		 * 
		 * @return	The loader value carried by this event.
		 */
		palmer_StreamLoader function getLoader() : StreamLoader
		{
			return _loader as StreamLoader;
		}
		
		/**
		 * Returns the VideoLoader object carried by this event.
		 * 
		 * @return	The loader value carried by this event.
		 */
		palmer_VideoLoader function getLoader() : VideoLoader
		{
			return _loader as VideoLoader;
		}
		
		/**
		 * Returns the XMLLoader object carried by this event.
		 * 
		 * @return	The loader value carried by this event.
		 */
		palmer_XMLLoader function getLoader() : XMLLoader
		{
			return _loader as XMLLoader;
		}
		
		/**
		 * Returns the CSSLoader object carried by this event.
		 * 
		 * @return	The loader value carried by this event.
		 */
		palmer_CSSLoader function getLoader() : CSSLoader
		{
			return _loader as CSSLoader;
		}
	}
}