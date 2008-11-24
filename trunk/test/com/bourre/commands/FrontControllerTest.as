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
package com.bourre.commands
{
	import flexunit.framework.TestCase;
	
	import com.bourre.events.EventBroadcaster;
	import com.bourre.plugin.NullPlugin;
	import com.bourre.plugin.Plugin;
	
	import flash.events.Event;
	import flash.utils.Dictionary;	

	public class FrontControllerTest 
		extends TestCase
	{
		private var _oFC : FrontController;
		private var _oFCOwner : FrontController;
		private var _oPlugin : Plugin;

		public var isExecuted : Boolean;
		public var commandOwner : Plugin;
		
		override public function setUp() : void
		{
			this._oFC = new FrontController();
			this._oPlugin = new MockPlugin();
			this._oFCOwner = new FrontController(_oPlugin);
			
			this.isExecuted = false;
			this.commandOwner= null;
			MockCommand.testclass=this;
		}

		public function testConstructor() : void
		{
			/*assertNotNull("Failed to construct a new Front controller", _oFC)
			assertNotNull("Failed to construct a new Front controller with a pugin", _oFCOwner)*/
		}

		public function testGetOwner() : void
		{
			assertEquals("Failed to getOwner", NullPlugin.getInstance(), _oFC.getOwner());
			assertEquals("Failed to getOwner", _oPlugin, _oFCOwner.getOwner());
		}

		public function testRunCommand() : void
		{
			var evt : Event = new Event("anEvent");
			_oFC.pushCommandClass("anEvent", MockCommand);
			_oFC.handleEvent (evt);
			assertTrue("Failed to execute a command", this.isExecuted);
			assertEquals("Failed to get good command owner",  NullPlugin.getInstance(), this.commandOwner);
		}
		
		public function testRunCommandWithOwner() : void
		{
			 var evt : Event = new Event("anEvent");
			_oFCOwner.pushCommandClass("anEvent", MockCommand);
			_oFCOwner.handleEvent (evt);
			assertTrue("Failed to execute a command", this.isExecuted);
			assertEquals("Failed to get good command owner", _oPlugin, this.commandOwner);
		}
		
		public function testRunCommandWithEmptyFC() : void
		{
			var evt : Event = new Event("anEvent");
			var errorOccure : Boolean = false;
			try
			{
				_oFC.handleEvent (evt);
			}
			catch(e : Event)
			{
				errorOccure = true;
			}
			assertFalse("Failed to handle event with an empty Front controler", errorOccure);
		}
		
		public function testRemove() : void
		{
			 var evt : Event = new Event("anEvent");
			_oFCOwner.pushCommandClass("anEvent", MockCommand);
			_oFCOwner.remove("anEvent");
			
			var errorOccure : Boolean = false;
			try
			{
				_oFC.handleEvent (evt);
				
			}catch(e : Event)
			{
				errorOccure = true;
			}
			assertFalse("Failed to handle event with an empty Front controler after remove", errorOccure);
			assertFalse("Failed to execute a command", this.isExecuted);
			assertNull("Failed to get good command owner", this.commandOwner);
			
		}
		
		public function testRunDelegate() : void
		{
			var o : Object = {};
			var e : Event = new Event( "onTest" );
			_oFC.pushCommandInstance( "onTest", new Delegate( onTestRunDelegate, o ) );
			EventBroadcaster.getInstance().broadcastEvent( e );
			assertEquals( "", 5, o.n );
			assertStrictlyEquals( "", e, o.e );
		}

		public function onTestRunDelegate( e : Event, o : Object ) : void
		{
			o.e = e;
			o.n = 5;
		}

		public function testAdd() : void
		{
			var d : Dictionary = new Dictionary();
			d["anEvent"] = MockCommand;

			_oFC.add( d );
			_oFC.handleEvent ( new Event("anEvent") );

			assertTrue( "Failed to execute a command", this.isExecuted );
			assertEquals( "Failed to get good command owner",  NullPlugin.getInstance(), this.commandOwner );
		}
	}
}

import com.bourre.commands.AbstractCommand;
import com.bourre.commands.FrontControllerTest;
import com.bourre.events.EventChannel;
import com.bourre.log.Log;
import com.bourre.model.Model;
import com.bourre.model.ModelLocator;
import com.bourre.plugin.Plugin;
import com.bourre.plugin.PluginDebug;
import com.bourre.view.View;
import com.bourre.view.ViewLocator;

import flash.events.Event;

internal class MockCommand extends AbstractCommand
{
	public static var testclass : FrontControllerTest;
	
	override public function execute( e : Event= null ) : void 
	{
		testclass.isExecuted = true;
		testclass.commandOwner = this.getOwner();
	}
}

internal class MockPlugin implements Plugin
{
	public function  fireOnInitPlugin() : void
	{}
	
	public function  fireOnReleasePlugin() : void
	{}
	
	public function fireExternalEvent( e : Event, channel : EventChannel ) : void
	{}
	
	public function firePublicEvent( e : Event ) : void
	{}
	
	public function firePrivateEvent( e : Event ) : void
	{}
	
	public function getChannel() : EventChannel
	{
		return new AChannel();
	}
	
	public function getLogger() : Log
	{
		return  PluginDebug.getInstance();
	}

	public function getModel( key : String ) : Model
	{
		return ModelLocator.getInstance().getModel( key );
	}
	
	public function getView( key : String ) : View
	{
		return ViewLocator.getInstance().getView( key );
	}
	
	public function isModelRegistered(name : String) : Boolean
	{
		return ModelLocator.getInstance().isRegistered(name);
	}
	
	public function isViewRegistered(name : String) : Boolean
	{
		return ViewLocator.getInstance().isRegistered(name);
	}

}

internal  class AChannel extends EventChannel
{
	function AChannel()
	{
	}
}


