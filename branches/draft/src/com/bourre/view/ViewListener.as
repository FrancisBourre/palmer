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
package com.bourre.view 
{

	/**
	 * The ViewListener interface defines rules for view listeners.
	 * 
	 * @author 	Francis Bourre
	 */
	public interface ViewListener 
	{
		/**
		 * Triggered when view is initialized.
		 */
		function onInitView( e : ViewEvent ) : void;

		/**
		 * Triggered when view is released.
		 */
		function onReleaseView( e : ViewEvent ) : void;
	}
}
