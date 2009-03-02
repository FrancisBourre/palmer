/* * Copyright the original author or authors. *  * Licensed under the MOZILLA PUBLIC LICENSE, Version 1.1 (the "License"); * you may not use this file except in compliance with the License. * You may obtain a copy of the License at *  *      http://www.mozilla.org/MPL/MPL-1.1.html *  * Unless required by applicable law or agreed to in writing, software * distributed under the License is distributed on an "AS IS" BASIS, * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. * See the License for the specific language governing permissions and * limitations under the License. */package com.bourre.ioc.parser.factory {
	import com.bourre.commands.Delegate;
	import com.bourre.ioc.load.ApplicationLoaderState;
	import com.bourre.ioc.parser.factory.AbstractParserCommand;
	import com.bourre.ioc.parser.factory.ContextProcessor;	

	/**
	 * @author Romain Ecarnot
	 */
	public class ASPreProcessorParser extends AbstractParserCommand	{		//--------------------------------------------------------------------		// Private properties		//--------------------------------------------------------------------				private var _aVariables : Vector.<VariableProcessor>;				private var _aMethods : Vector.<Delegate>;			private var _aProcessor : Vector.<ContextProcessor>;							//--------------------------------------------------------------------		// Public API		//--------------------------------------------------------------------				/**		 * 		 */		public function ASPreProcessorParser()		{			super( getConstructorAccess() );						_aVariables = new Vector.<VariableProcessor>();			_aMethods = new Vector.<Delegate>();			_aProcessor = new Vector.<ContextProcessor>();		}				/**		 *		 */		public function addVariable( name : String, value : Object ) : void		{			_aVariables.push( new VariableProcessor( name, value ) );		}				/**		 * 		 */		public function addMethod( processor : Delegate ) : void		{			_aMethods.push( processor );		}				/**		 *		 */		public function addProcessor( processor : ContextProcessor ) : void		{			_aProcessor.push( processor );		}				override public function parse( ) : void		{			if( _aVariables.length > 0 )			{				var src : String = String( getContextData() );								for each (var variable : VariableProcessor in _aVariables) 				{					src = src.split( variable.name ).join( variable.value );				}				setContextData( src );			}						for each (var method : Delegate in _aMethods) 			{				method.setArgumentsArray( [ getContextData() ].concat( method.getArguments( ) ) );								var mr : * = getContextData();								try				{					mr = method.callFunction( );				}				catch( e : Error ) 				{				}				finally				{					setContextData( mr );				}			}						for each (var processor : ContextProcessor in _aProcessor ) 			{				var pr :* = getContextData();								try				{					pr = processor.process( getContextData() );				}				catch( e : Error ) 				{				}				finally				{					setContextData( pr );				}			}						fireCommandEndEvent();		}						//--------------------------------------------------------------------		// Protected methods		//--------------------------------------------------------------------				override protected function getState(  ) : String		{			return ApplicationLoaderState.PREPROCESSOR_PARSE_STATE;		}		
	}
}internal class VariableProcessor {	private var _name : String;	private var _value : Object;			public function VariableProcessor( name : String, value : Object )	{		_name = "${" + name + "}";		_value = value;	}		public function get name( ) : String	{		return _name;	}	public function get value( ) : String	{		return _value.toString( );	}}
