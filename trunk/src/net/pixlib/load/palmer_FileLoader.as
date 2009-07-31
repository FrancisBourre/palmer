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
	/**
	 * Reserved namespace to manage FileLoader locator registration.
	 * 
	 * @example
	 * <pre class="prettyprint">
	 * 
	 * var loader : FileLoader = LoaderLocator.getIntance().palmer_FileLoader::getLoader( "myLoaderName" );
	 * </pre>
	 * 
	 * @author Romain Ecarnot
	 * 
	 * @see LoaderLocator
	 * @see	FileLoader
	 */
	public namespace palmer_FileLoader = "http://palmer.pixlib.net/actionscript/loader/file";
}
