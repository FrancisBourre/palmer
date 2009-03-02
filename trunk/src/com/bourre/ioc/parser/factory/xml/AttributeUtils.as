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
package com.bourre.ioc.parser.factory.xml
{
	import com.bourre.exceptions.PrivateConstructorException;
	import com.bourre.ioc.core.ContextAttributeList;
	import com.bourre.ioc.core.ContextTypeList;	

	/**
	 * @author Francis Bourre
	 */
	public class AttributeUtils
	{	
		static public function getID( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.ID );
		}
		
		static public function getType( xml : XML ) : String
		{
			var type : String = xml.attribute( ContextAttributeList.TYPE );
			return type ? type : ContextTypeList.STRING;
		}
		
		static public function getDisplayType( xml : XML ) : String
		{
			var type : String = xml.attribute( ContextAttributeList.TYPE );
			return type ? type : ContextTypeList.SPRITE;
		}

		static public function getName( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.NAME );
		}

		static public function getRef( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.REF );
		}

		static public function getValue( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.VALUE ) || null;
		}

		static public function getURL( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.URL );
		}

		static public function getVisible( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.VISIBLE );
		}

		static public function getFactoryMethod( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.FACTORY ) || null;
		}

		static public function getSingletonAccess( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.SINGLETON_ACCESS ) || null;
		}

		static public function getMethod( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.METHOD );
		}

		static public function getProgressCallback( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.PROGRESS_CALLBACK );
		}

		static public function getNameCallback( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.NAME_CALLBACK );
		}

		static public function getTimeoutCallback( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.TIMEOUT_CALLBACK );
		}

		static public function getParsedCallback( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.PARSED_CALLBACK );
		}

		static public function getObjectsBuiltCallback( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.OBJECTS_BUILT_CALLBACK );
		}

		static public function getMethodsCallCallback( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.METHODS_CALL_CALLBACK );
		}

		static public function getChannelsAssignedCallback( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.CHANNELS_ASSIGNED_CALLBACK );
		}

		static public function getInitCallback( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.INIT_CALLBACK );
		}

		static public function getDelay( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.DELAY );
		}

		static public function getDeserializerClass( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.DESERIALIZER_CLASS ) || null;
		}		
		
		/**
		 * Returns <code>root-ref</code> attibute value.
		 */
		public static function getRootRef( xml : XML ) : String
		{
			return xml.attribute( ContextAttributeList.ROOT_REF );
		}
		
		
		//--------------------------------------------------------------------
		// Private implementation
		//--------------------------------------------------------------------
			
		/** @private */
		function AttributeUtils( access : ConstructorAccess )
		{
			if ( !(access is ConstructorAccess) ) throw new PrivateConstructorException( );
		}
	}
}

internal class ConstructorAccess{}