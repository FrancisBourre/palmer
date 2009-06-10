/* * Copyright the original author or authors. *  * Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License"); * you may not use this file except in compliance with the License. * You may obtain a copy of the License at *  *      http://www.mozilla.org/MPL/MPL-1.1.html *  * Unless required by applicable law or agreed to in writing, software * distributed under the License is distributed on an "AS IS" BASIS, * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. * See the License for the specific language governing permissions and * limitations under the License. */ package com.bourre.encoding {	import com.bourre.encoding.Deserializer;	import com.bourre.exceptions.IllegalArgumentException;	import com.bourre.log.PalmerStringifier;		import flash.display.Loader;	import flash.utils.ByteArray;			/**	 * Display object deserializer.	 * 	 * @author Romain Ecarnot	 * 	 * @see Deserializer	 */	public class DisplayDeserializer implements Deserializer	{		//--------------------------------------------------------------------		// Public API		//--------------------------------------------------------------------				/**		 * Creates instance.		 */				public function DisplayDeserializer()		{					}				/**		 * @inheritDoc.		 * 		 * <p>Returns content is a <code>Loader</code> instance if deserialization 		 * process is success.</p>		 */		public function deserialize(serializedContent : Object, target : Object = null, key : String = null ) : Object		{			try			{				var ba : ByteArray = serializedContent as ByteArray;				var swf : Loader = new Loader( );				swf.loadBytes(ba);								return swf;			}			catch( e : Error )			{				throw( new IllegalArgumentException( this + ".deserialize() error. Content is not Display compliant" ) );			}						return null;		}				/**		 * Returns string represenation.		 */
		public function toString() : String 		{			return PalmerStringifier.stringify( this );		}	}}