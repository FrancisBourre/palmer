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
	/**
	 * An event object which carry a <code>QueueLoader</code> value.
	 * 
	 * @author 	Francis Bourre
	 */
	public class QueueLoaderEvent extends LoaderEvent
	{
		//--------------------------------------------------------------------
		// Events
		//--------------------------------------------------------------------
		
		static public const onLoadStartEVENT 	: String = LoaderEvent.onLoadStartEVENT;
		static public const onLoadInitEVENT 	: String = LoaderEvent.onLoadInitEVENT;
		static public const onLoadProgressEVENT : String = LoaderEvent.onLoadProgressEVENT;
		static public const onLoadTimeOutEVENT 	: String = LoaderEvent.onLoadTimeOutEVENT;
		static public const onLoadErrorEVENT 	: String = LoaderEvent.onLoadErrorEVENT;
				/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onItemLoadStart</code> event.
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
	     *     	<td><code>getQueue()</code>
	     *     	</td><td>The queue loader object</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getLoader()</code>
	     *     	</td><td>The current loader object</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getName()</code>
	     *     	</td><td>The current loader identifier</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getErrorMessage()</code>
	     *     	</td><td>The loader identifier</td>
	     *     </tr>
	     * </table>
	     * 
		 * @eventType onItemLoadStart
		 */
		public static const onItemLoadStartEVENT 	: String = "onItemLoadStart";
		
		/**
		 * Defines the value of the <code>type</code> property of the event 
		 * object for a <code>onItemLoadInit</code> event.
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
	     *     	</td><td>The current loader object</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getName()</code>
	     *     	</td><td>The current loader identifier</td>
	     *     </tr>
	     *     <tr>
	     *     	<td><code>getErrorMessage()</code>
	     *     	</td><td>The loader identifier</td>
	     *     </tr>
	     * </table>
	     * 
		 * @eventType onItemLoadInit
		 */
		public static const onItemLoadInitEVENT 	: String = "onItemLoadInit";
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates a new <code>QueueLoaderEvent</code> object.
		 * 
		 * @param	type			Name of the event type
		 * @param	ql				Queue loader object carried by this event
		 * @param	errorMessage	(optional) Error message carried by this event
		 */	
		public function QueueLoaderEvent( type : String, ql : QueueLoader, errorMessage : String = "" )
		{
			super( type, ql, errorMessage );
		}
		
		/**
		 * Returns the queue object carried by this event.
		 * 
		 * @return	The queue value carried by this event.
		 */
		public function getQueue() : QueueLoader
		{
			return super.getLoader() as QueueLoader;
		}
		
		/**
		 * Returns the current loader object carried by this queue loader 
		 * event.
		 * 
		 * @return	The current loader object carried by this queue loader 
		 * 			event.
		 */
		override public function getLoader() : Loader
		{
			return ( super.getLoader() as QueueLoader ).getCurrentLoader();
		}
		
		/**
		 * Returns the current loader named carried by this queue loader 
		 * event.
		 * 
		 * @return	The current loader named carried by this queue loader 
		 * event.
		 */
		override public function getName() : String
		{
			return getLoader().getName();
		}
		
		/**
		 * Returns the loading progression value of current object carried 
		 * by this queue loader event.
		 * 
		 * @return	The loading progression value of current object carried 
		 * 			by this queue loader event.
		 */
		override public function getPerCent():Number
		{
			return getLoader().getPerCent();
		}
	}
}