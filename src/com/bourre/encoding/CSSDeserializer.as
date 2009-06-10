/* * Copyright the original author or authors. *  * Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License"); * you may not use this file except in compliance with the License. * You may obtain a copy of the License at *  *      http://www.mozilla.org/MPL/MPL-1.1.html *  * Unless required by applicable law or agreed to in writing, software * distributed under the License is distributed on an "AS IS" BASIS, * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. * See the License for the specific language governing permissions and * limitations under the License. */ package com.bourre.encoding {	import com.bourre.display.CSS;	import com.bourre.encoding.Deserializer;	import com.bourre.exceptions.IllegalArgumentException;	import com.bourre.log.PalmerStringifier;	import flash.text.StyleSheet;	/**	 * CSS deserializer.	 * 	 * <p>Automatically register created <code>CSS</code> instance 	 * in global <code>CSSLocator</code> if possible</p>	 * 	 * @example CSS resource on IoC context	 * <pre class="prettyprint">	 * 	&lt;dll url="CSSDeserializerDLL.swf" /&gt;	 * 	&lt;rsc id="myCss" url="style.css" type="text" deserializer-class="com.bourre.encoding.CSSDeserializer" /&gt;	 * </pre>	 * 	 * @example Retreive Css	 * <pre class="prettyprint">	 * var styles : CSS = CSSLocator.getInstance().getCSS( "myCss" );	 * //or	 * //var shader : CSS = CoreFactory.getInstance().locate( "myCss" ) as CSS;	 * </pre>	 * 	 * @author Romain Ecarnot	 * 	 * @see Deserializer	 * @see	com.bourre.display.CSS	 * @see	com.bourre.display.CSSLocator	 */	public class CSSDeserializer implements Deserializer	{		//--------------------------------------------------------------------		// Public API		//--------------------------------------------------------------------				/**		 * Creates instance.		 */					public function CSSDeserializer()		{		}				/**		 * @inheritDoc.		 * 		 * <p>Returns content is a <code>StyleSheet</code> instance if deserialization 		 * process is success.</p>		 */		public function deserialize(serializedContent : Object, target : Object = null, key : String = null ) : Object		{			try			{				var sheet : StyleSheet = new StyleSheet( );				sheet.parseCSS( serializedContent as String );								var css : CSS = new CSS( key, sheet );				return css;				}			catch( e : Error )			{				throw( new IllegalArgumentException( this + ".deserialize() error. Content is not CSS compliant" ) );			}						return null;		}				/**		 * Returns string represenation.		 */		public function toString() : String 		{			return PalmerStringifier.stringify( this );		}	}}