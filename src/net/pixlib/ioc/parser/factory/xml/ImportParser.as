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
 
package net.pixlib.ioc.parser.factory.xml 
{
	import net.pixlib.ioc.assembler.locator.Import;
	import net.pixlib.ioc.assembler.locator.ImportExpert;
	import net.pixlib.ioc.core.ContextAttributeList;
	import net.pixlib.ioc.core.ContextNameList;
	import net.pixlib.ioc.load.ApplicationLoaderState;
	import net.pixlib.load.LoaderEvent;
	import net.pixlib.load.QueueLoader;
	import net.pixlib.load.QueueLoaderEvent;
	import net.pixlib.load.XMLLoader;
	import net.pixlib.log.PalmerDebug;
	import net.pixlib.utils.NetUtil;

	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * The ImportParser class allow to inject IoC context into another 
	 * IoC context. ( import feature )
	 * 
	 * @example How to import context
	 * <pre class="prettyprint">
	 * 
	 * &lt;beans&gt;
	 * 	&lt;import url="config/context.xml" root-ref="container" /&gt;
	 * 
	 * 	&lt;root id="root"&gt;
	 * 		&lt;child id="container" /&gt;
	 * 	&lt;/root&gt;
	 * &lt;/beans&gt; 
	 * </pre>
	 * 
	 * <p><code>sandbox</code> url parsing are checked to enable full 
	 * plugin structure management.</p>
	 * @example In imported XML context
	 * <pre class="prettyprint">
	 * 
	 * &lt;beans&gt;
	 * 	&lt;rsc id="logo" url="sandbox://bitmap.png" type="binary" /&gt;
	 * &lt;/beans&gt; 
	 * </pre>
	 * <p>Here, the <code>bitmap.png</code> url are relative to the imported 
	 * xml context file.<br />
	 * Note : only <code>sandbox</code> url are threated, all others types 
	 * ( flashvars replacement for example ) are threated later with the global 
	 * <code>PathParser</code> context processing.</p>
	 * 
	 * @author Romain Ecarnot
	 */
	public class ImportParser extends XMLParser
	{
		//--------------------------------------------------------------------
		// Private properties
		//--------------------------------------------------------------------
		private var _loader : QueueLoader;

		
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		/**
		 * Creates new <code>XMLImportParser</code> instance.
		 */
		public function ImportParser(   )
		{
			_loader = new QueueLoader();
		}

		/**
		 * Starts include job.
		 */
		override public function parse() : void
		{
			parseImport(getXMLContext());
			
			executeQueue();
		}

		//--------------------------------------------------------------------
		// Protected methods
		//--------------------------------------------------------------------
		override protected function getState(  ) : String
		{
			return ApplicationLoaderState.IMPORT_PARSE_STATE;
		}

		/**
		 * @private
		 */
		protected function executeQueue( ) : void
		{
			if( !_loader.isEmpty() )
			{
				_loader.addEventListener(QueueLoaderEvent.onItemLoadInitEVENT, onImportLoadInit);
				_loader.addEventListener(LoaderEvent.onLoadProgressEVENT, onImportLoadProgress);				_loader.addEventListener(LoaderEvent.onLoadTimeOutEVENT, onImportLoadError);
				_loader.addEventListener(LoaderEvent.onLoadErrorEVENT, onImportLoadError);
				_loader.addEventListener(LoaderEvent.onLoadInitEVENT, onLoadQueueInit);
				_loader.execute();
			}
			else fireOnCompleteEvent();
		}

		/**
		 * @private
		 */
		protected function release() : void
		{
			_loader.removeEventListener(QueueLoaderEvent.onItemLoadInitEVENT, onImportLoadInit);			_loader.removeEventListener(LoaderEvent.onLoadProgressEVENT, onImportLoadProgress);
			_loader.removeEventListener(LoaderEvent.onLoadTimeOutEVENT, onImportLoadError);
			_loader.removeEventListener(LoaderEvent.onLoadErrorEVENT, onImportLoadError);
			_loader.removeEventListener(LoaderEvent.onLoadInitEVENT, onLoadQueueInit);
			_loader.release();
			
			ImportExpert.release();
		}

		/**
		 * @private
		 */
		protected function parseImport( xml : XML ) : void
		{
			var incXML : XMLList = xml.child(ContextNameList.IMPORT);
			var l : int = incXML.length();
			
			for ( var i : int = 0;i < l; i++ ) 
			{
				var node : XML = incXML[ i ];
				var info : Import = new Import(new URLRequest(AttributeUtils.getURL(node)), AttributeUtils.getRootRef(node));
				
				var id : String = info.url.url;
				
				ImportExpert.getInstance().register(id, info);
				
				var xl : XMLLoader = new XMLLoader();
				
				_loader.add(xl, id, info.url, new LoaderContext(false, ApplicationDomain.currentDomain));
			}
			
			delete xml[ ContextNameList.IMPORT ];
		}

		/**
		 * @private
		 */
		protected function onImportLoadInit( event : LoaderEvent ) : void
		{
			var xml : XML = XMLLoader(event.getLoader()).getXML();
			var info : Import = ImportExpert.getInstance().locate(event.getName()) as Import;
			
			checkImportSandbox(xml, event.getLoader().getURL().url);
			checkImportDomain(xml);
			
			parseImport(xml);
			
			try
			{
				var container : XMLList = getXMLContext().descendants().(  hasOwnProperty("@id") && @id == info.rootRef );
				
				if( xml.hasOwnProperty(ContextNameList.ROOT) )
				{
					container.appendChild(xml.child(ContextNameList.ROOT).children());
					
					delete xml[ ContextNameList.ROOT ];
				}
			}
			catch( e : Error ) {
				PalmerDebug.ERROR(this + "::no rootref for " + info.url.url + " -> " + info.rootRef);
			}
			finally {
				for each (var node : XML in xml.children() ) 
				{
					getXMLContext().appendChild(node);
				}
				
				ImportExpert.getInstance().unregister(info.url.url);
			}
		}

		/**
		 * @private
		 */
		protected function onImportLoadProgress( event : LoaderEvent ) : void
		{
		}

		/**
		 * @private
		 */
		protected function onImportLoadError( event : LoaderEvent ) : void
		{
			fireOnCompleteEvent();
		}

		/**
		 * @private
		 */
		protected function onLoadQueueInit( event : QueueLoaderEvent ) : void
		{
			release();
			
			fireOnCompleteEvent();
		}

		/**
		 * Triggered when all context pre processors are completed. 
		 */
		protected function fireOnCompleteEvent( ) : void
		{
			fireCommandEndEvent();
		}
		
		/**
		 * Resolve "sandbox" url type for imported XML content.
		 * 
		 * @param	imported	Imported XML data
		 * @param	contextURL	URL of imported file
		 */
		protected function checkImportSandbox( imported : XML, contextURL : String ) : void
		{
			var result : XMLList = imported..*.( hasOwnProperty(getAttributeName(ContextAttributeList.URL)) && String(@[ContextAttributeList.URL]).length > 0 );
			
			for each (var node : XML in result)
			{
				var separator : String = "://";
				var url : String = node.@url;
				var key : String = url.substring(0, url.indexOf(separator));
				
				if( key == "sandbox" )
				{
					node.@url = NetUtil.createCleanRelativeURL(contextURL, url.substr(url.indexOf(separator) + separator.length));
				}
			}
		}
		
		protected function checkImportDomain( imported : XML ) : void
		{
			if( imported.hasOwnProperty(getAttributeName("domain")) )
			{
				var domain : String = imported.@domain;
				
				if( domain.length > 0 )
				{
					var node : XML;
					
					//ID process
					var nodes : XMLList = imported..*.( hasOwnProperty(getAttributeName(ContextAttributeList.ID)) && String(@[ContextAttributeList.ID]).length > 0 );
					for each ( node in nodes ) 
					{
						node.@id = domain + "_" + node.@id;
					}
					
					//REF process
					nodes = imported..*.( hasOwnProperty(getAttributeName(ContextAttributeList.REF)) && String(@[ContextAttributeList.REF]).length > 0 );
					for each (node  in nodes ) 
					{
						if( String(node.@ref).indexOf("/") == 0 )
						{
							node.@ref = String(node.@ref).substr(1);	
						}
						else
						{
							node.@ref = domain + "_" + node.@ref;
						}
					}
				}
			}
		}

		/**
		 * Returns XML attribute full qualified name.
		 */
		protected function getAttributeName( name : String ) : String
		{
			return "@" + name;		
		}

		/**
		 * Parses url.
		 */
		protected function getSandboxURL( url : String, contextURL : String  ) : String
		{
			var cURL : String = contextURL.substring(0, getApplicationLoader().getURL().url.indexOf("?"));
			var contextPath : String = cURL.substring(0, contextURL.lastIndexOf("/"));
			
			if( contextPath.length > 0 ) contextPath += "/";
			
			return contextPath + url;
		}
	}
}
