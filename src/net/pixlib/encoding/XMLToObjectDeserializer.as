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
package net.pixlib.encoding
{
	import net.pixlib.collections.HashMap;	import net.pixlib.core.CoreFactory;	import net.pixlib.exceptions.IllegalArgumentException;	import net.pixlib.log.PalmerDebug;	import net.pixlib.structures.Dimension;	import net.pixlib.structures.Range;		import flash.geom.Point;		
	/**
	 * XML object deserializer.
	 * 
	 * @author Francis Bourre
	 * 
	 * @see Deserializer
	 */
	public class XMLToObjectDeserializer implements Deserializer
	{
		//--------------------------------------------------------------------
		// Protected properties
		//--------------------------------------------------------------------
		
		protected var _m 						: HashMap;		protected var _f 						: CoreFactory;
		protected var _bDeserializeAttributes 	: Boolean;
		
		
		//--------------------------------------------------------------------
		// Public properties
		//--------------------------------------------------------------------
		
		public var pushInArray 					: Boolean;
		
		static public var DEBUG_IDENTICAL_NODE_NAMES 		: Boolean = false;
		static public var PUSHINARRAY_IDENTICAL_NODE_NAMES 	: Boolean = true;
		static public var ATTRIBUTE_TARGETED_PROPERTY_NAME 	: String = null;
		static public var DESERIALIZE_ATTRIBUTES 			: Boolean = false;
		
		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
				
		/**
		 * Creates instance.
		 */	
		public function XMLToObjectDeserializer ()
		{
			_f = CoreFactory.getInstance();
			_m = new HashMap() ;
			
			addType( "Number", getNumber );
			addType( "String", getString );
			addType( "Array", getArray );
			addType( "Boolean", getBoolean );
			addType( "Class", getInstance );
			addType( "Point", getPoint );
			addType( "Dimension", getDimension );
			addType( "Range", getRange );
			addType( "", getObject );
			
			pushInArray = XMLToObjectDeserializer.PUSHINARRAY_IDENTICAL_NODE_NAMES;
			deserializeAttributes = XMLToObjectDeserializer.DESERIALIZE_ATTRIBUTES;
		}

		/**
		 * <p>Returns content is a <code>XML</code> instance if deserialization 
		 * process is success.</p>
		 * 
		 * @param	serializedContent	<code>String</code> or <code>XML</code> object.
		 * @param	target				Target object to store deserialization result.
		 *
		 * @return The <code>serializedContent</code> deserialization result.
		 */
		public function deserialize( serializedContent : Object, target : Object = null, key : String = null ) : Object
		{
			if ( target == null ) target = {};
			
			var xml : XML;
			if( serializedContent is String )
			{
				xml = new XML( serializedContent as String );
			}
			else xml = serializedContent as XML;
			
			for each ( var property : XML in xml.* ) deserializeNode( target, property ) ;
			return target ;
		}
		
		public function	deserializeNode ( target : Object, node : XML ) : Object
		{
			var member:String = node.name().toString();
			var obj : Object = {};
			
			if (node.attribute("type").length()== 0 && !node.hasSimpleContent())
			{
				obj =_getData( node );
			}
			else
			{
				obj["value"] = _getData( node ) ;
			}
				
			obj["attribute"] = {};
			for ( var i : int = 0 ; i < node.attributes().length() ; i++ )
			{
				var nom : String = String( node.attributes()[i].name() );
				obj["attribute"][nom] = node.attributes()[i];
			}
			
			if ( target[member] ) 
			{
				target[member] = XMLToObjectDeserializer._getNodeContainer( target, member );
				target[member].push( obj ) ;
			} 
			else
			{
				target[member] = obj ;
			}

			return target ;
		}
		
		/**
	 	 * Add new type to deserializer
	 	 */
		public function addType( type : String, parsingMethod : Function ) : void
		{
			_m.put( type, parsingMethod ) ;
		}
	
	  	private function _getData( node:XML ):*
		{
			var dataType:String = node.attribute("type");
			
			if ( _m.containsKey( dataType ) )
			{
				var d:Function = _m.get( dataType );
				return d.apply(this, [node]);
					
			} else
			{
				PalmerDebug.WARN( dataType + ' type is not supported!' );
				return null;
			}
		}

	  	static private function _getNodeContainer( target:*, member : String ) : Array
	  	{
	  		var temp : Object = target[ member ];

	  		if ( temp.__nodeContainer )
	  		{
	  			return target[ member ] as Array;

	  		} else
	  		{
	  			var a : Array = new Array();
	  			a[ "__nodeContainer" ] = true;
				a.setPropertyIsEnumerable( "__nodeContainer", false );
	  			a.push( temp );
	  			return a;
	  		}
	  	}

		
		/**
		 * Explode string to arguments array.
		 */
		public function getArguments( sE:String ) : Array 
		{
	  		var t : Array = split(sE);

	  		var aR : Array = new Array();
	  		var l : Number = t.length;

	  		for ( var y : int = 0; y < l; y++ ) 
			{
				var s:String = stripSpaces( t[y] );
				if (s == 'true' || s == 'false')
				{
					aR.push( s == 'true' );

				} else
				{
					if ( s.charCodeAt(0) == 34 || s.charCodeAt(0) == 39 )
					{
						aR.push( s.substr( 1, s.length-2 ) );

					} else
					{
						aR.push( Number(s) );
					}
				}
			}

	 		return aR;
	  	}
		
		/*
		 * setters - parsers's behaviors
		 */
	  	public function getNumber ( node:XML ) : Number
	  	{
	  		return Number( XMLToObjectDeserializer.stripSpaces( node ) );
	  	}

	  	public function getString ( node:XML ) : String
	  	{
	  		return node;
	  	}

	  	public function getArray ( node:XML ) : Array
	  	{
	  		return getArguments( node );
	  	}

	  	public function getBoolean ( node:XML ) : Boolean
	  	{
	  		var s : String = XMLToObjectDeserializer.stripSpaces( node );
			return new Boolean( s == "true" || !isNaN( Number(s) ) && Number(s) != 0 );
	  	}

	  	public function getObject ( node:XML ) : Object
		{
			var data : XML = node;	  		
	  		return data.hasSimpleContent() ? data : deserialize( node, {} );
		}

		public function getInstance( node: XML ) : Object
	  	{
	  		var o : Object;
	  		var args : Array = getArguments( node );
			var sPackage : String = args[0]; 
			args.splice( 0, 1 );

			try 
			{
				o = _f.buildInstance( sPackage, args );

			} catch ( e : Error )
			{
				var msg : String = this + ".getInstance() failed, can't build class instance specified in xml node [" + sPackage + "]";
				PalmerDebug.FATAL( msg  );
				throw new IllegalArgumentException( msg );
			}

			return  o;
	  	}

		public function getPoint( node : XML ) : Point
	  	{
	  		var args : Array = getArguments( node );

	  		if ( args[0] == null || args[1] == null )
	  		{
	  			var msg : String = this + ".getPoint() failed with values: (" + args[0] + ", " + args[1] + ").";
				PalmerDebug.FATAL( msg );
	  			throw new IllegalArgumentException( msg );
	  		}

			return new Point( args[0], args[1] );
	  	}
		
		/**
		 * Returns <code>Dimension</code> instance using passed-in 
		 * <code>XML node</code> as source.
		 * 
		 * @example
		 * <pre class="prettyprint">
		 * 
		 * &lt;node type="Dimension"&gt;10,100&lt;/node&gt;
		 * </pre>
		 * 
		 * @param	node	XML Node with dimension informations
		 * 
		 * @returns	<code>Dimension</code> instance
		 */
		protected function getDimension( node : XML ) : Dimension
	  	{
	  		var args : Array = getArguments( node );
	  		
	  		if ( args[0] == null || args[1] == null )
	  		{
	  			var msg : String = this + ".getDimension() failed with values: (" + args[0] + ", " + args[1] + ").";
				PalmerDebug.FATAL( msg );
	  			throw new IllegalArgumentException( msg );
	  		}
	  		
	  		return new Dimension( args[0], args[1] );
		}
	  	
	  	/**
		 * Returns <code>getRange</code> instance using passed-in 
		 * <code>XML node</code> as source.
		 * 
		 * @example
		 * <pre class="prettyprint">
		 * 
		 * &lt;node type="Dimension"&gt;10,10&lt;/node&gt;
		 * </pre>
		 * 
		 * @param	node	XML Node with range informations
		 * 
		 * @returns	<code>Dimension</code> instance
		 */
	  	protected function getRange( node : XML ) : Range
		{
			var args : Array = getArguments( node );
	  		
	  		if ( args[0] == null || args[1] == null )
	  		{
	  			var msg : String = this + ".getRange() failed with values: (" + args[0] + ", " + args[1] + ").";
				PalmerDebug.FATAL( msg );
	  			throw new IllegalArgumentException( msg );
	  		}
	  		
			return new Range( args[0], args[1] );
	  	}
	  	
	  	public function getObjectWithAttributes ( node:XML ) : Object
		{
			var data:XML = node;
			var o : Object = new Object();
			var attribTarget : Object;

			var s : String = XMLToObjectDeserializer.ATTRIBUTE_TARGETED_PROPERTY_NAME;
			if ( s.length > 0 ) attribTarget = o[s] = new Object();

	    	for ( var p : String in node.attributes() ) 
	    	{
	    		if ( !(_m.containsKey(p)) ) 
	    		{
	    			if ( attribTarget )
	    			{
	    				attribTarget[p] = node.attributes[p];

	    			} else
	    			{
	    				o[p] = node.attributes[p];
	    			}
	    		}
	    	}

			return data? data : deserialize( node, o );
		}

	  	static public function stripSpaces( s : String ) : String 
		{
	        var i : Number = 0;
			while( i < s.length && s.charCodeAt(i) == 32 ) i++;
			var j : Number = s.length-1;
			while( j > -1 && s.charCodeAt(j) == 32 ) j--;
	        return s.substr( i, j-i+1 );
	  	}
	  	
	  	static public function split( sE : String ) : Array
	  	{
	  		var b : Boolean = true;
	  		var a : Array = new Array();
	  		var l : Number = sE.length;
	  		var n : Number;
	  		var s : String = '';

	  		for ( var i : Number = 0; i < l; i++ )
	  		{
	  			var c : Number = sE.charCodeAt( i );

	  			if ( b && (c == 34 || c == 39) )
	  			{
	  				b = false;
	  				n = c;

	  			} else if ( !b && n == c )
	  			{
	  				b = true;
	  				n = undefined;
	  			}

	  			if ( c == 44 && b )
	  			{
	   				a.push( s );
	  				s = '';
	  			} else
	  			{
	  				s += sE.substr( i, 1 );	
	  			}
	  		}

	  		a.push( s );
	  		return a;
	  	}

	  	public function get deserializeAttributes () : Boolean
		{
			return _bDeserializeAttributes;
		}

		public function set deserializeAttributes ( b : Boolean ) : void
		{
			if ( b != _bDeserializeAttributes )
			{
				if ( b )
				{
					addType( "", getObjectWithAttributes );

				} else
				{
					addType( "", getObject );
				}
			}
		}
	}
}