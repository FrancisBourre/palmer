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
 
package com.bourre.ioc.core
{
	import com.bourre.collections.HashMap;
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.log.PalmerStringifier;	

	/**
	 * @author Francis Bourre
	 */
	public class ContextNameList
	{
		static private var _oI 					: ContextNameList;

		static public var BEANS 				: String = "beans";
		static public var PREPROCESSOR 			: String = "preprocessor";
		static public var PROPERTY 				: String = "property";
		static public var ARGUMENT 				: String = "argument";
		static public var ROOT 					: String = "root";
		static public var APPLICATION_LOADER 	: String = "application-loader";
		static public var VAR					: String = "var";
		static public var DLL 					: String = "dll";
		static public var METHOD_CALL 			: String = "method-call";
		static public var LISTEN 				: String = "listen";
		static public var ITEM 					: String = "item";
		static public var KEY 					: String = "key";
		static public var VALUE 				: String = "value";
		static public var INCLUDE 				: String = "include";
		static public var IMPORT 				: String = "import";
		static public var RSC 					: String = "rsc";
		static public var EVENT 				: String = "event";
		
		private var _mNodeName : HashMap;

		static public function getInstance() : ContextNameList
		{
			if ( !(ContextNameList._oI is ContextNameList) ) ContextNameList._oI = new ContextNameList( new ConstructorAccess() );
			return ContextNameList._oI;
		}

		public function ContextNameList( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException();

			init();
		}

		public function init() : void
		{
			_mNodeName = new HashMap();

			addNodeName( ContextNameList.BEANS, "" );
			addNodeName( ContextNameList.PROPERTY, "" );
			addNodeName( ContextNameList.ARGUMENT, "" );
			addNodeName( ContextNameList.ROOT, "" );
			addNodeName( ContextNameList.APPLICATION_LOADER, "" );
			addNodeName( ContextNameList.METHOD_CALL, "" );
			addNodeName( ContextNameList.LISTEN, "" );
			addNodeName( "attribute", "" );
			
			//TODO add DLL, RSC, VAR, etc into reserved ?
		}

		public function addNodeName( nodeName : String, value:* ) : void
		{
			_mNodeName.put( nodeName, value );
		}

		public function nodeNameIsReserved( nodeName:* ) : Boolean
		{
			return _mNodeName.containsKey( nodeName );
		}

		/**
		* Returns the string representation of this instance.
		* @return the string representation of this instance
		*/
		public function toString() : String 
		{
			return PalmerStringifier.stringify( this );
		}
	}
}
internal class ConstructorAccess {}