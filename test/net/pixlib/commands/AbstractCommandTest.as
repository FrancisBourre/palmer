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
package net.pixlib.commands
{
	import net.pixlib.events.CommandEvent;
	import net.pixlib.events.BasicEvent;
	import net.pixlib.exceptions.IllegalArgumentException;
	import net.pixlib.ioc.MockPlugin;
	import net.pixlib.plugin.NullPlugin;
	import net.pixlib.plugin.PluginDebug;

	import flash.display.MovieClip;

	/**
	 * @author Francis Bourre
	 */
	public class AbstractCommandTest 
		extends CancelableTest
	{
		private var _c : MockCommand;
		private var _cASync : AsyncMockCommand;
		private var _cError : CommandWithErrorHandling;

		public function testConstruct () : void
		{
			_c = new MockCommand();
			assertNotNull ( "MockCommand constructor returns null", _c );
		}

		public function testExecute() : void
		{
			_c = new MockCommand();
			var e : BasicEvent = new BasicEvent("test");
			_c.execute( e );			
			assertEquals ( _c + ".onExecute() call failed.", e, _c.event );
		}

		public function testEvents() : void
		{
			_c = new MockCommand();
			var listener : MockCommandListener = new MockCommandListener();
			
			_c.addCommandListener( listener );			
			assertTrue ( _c + ".addCommandListener failed", _c.isRegistered( listener ) );
			
			_c.execute();
			assertEquals( listener + ".onCommandStart hasn't been called as expected", CommandEvent.onCommandStartEVENT, listener.startEventReceived.type );
			assertEquals( listener + ".onCommandEnd hasn't been called as expected", CommandEvent.onCommandEndEVENT, listener.endEventReceived.type );
			
			_c.removeCommandListener( listener );
			assertFalse ( _c + ".removeCommandListener failed", _c.isRegistered( listener ) );
		}

		override public function testRunnableRun() : void
		{
			_cASync = new AsyncMockCommand();
			setRunnableObject( _cASync );
			super.testRunnableRun();
		}

		override public function testCancelableCancel() : void
		{
			_cASync = new AsyncMockCommand();
			setCancelableObject( _cASync );
			super.testCancelableCancel();
		}
		
		public function testOwner() : void
		{
			var m : MockModel, v : MockView;
			m = new MockModel ( null, MockModelList.MOCK_MODEL );
			v = new MockView ( null, MockViewList.MOCK_VIEW, new MovieClip() );
			
			_c = new MockCommand();
			assertEquals ( _c + ".getOwner() failed.", NullPlugin.getInstance(), _c.getOwner() );
			assertEquals ( _c + ".getLogger() failed.", PluginDebug.getInstance( NullPlugin.getInstance() ), _c.getLogger() );
			assertTrue ( _c + ".isModelRegistered() failed.", _c.isModelRegistered( MockModelList.MOCK_MODEL ) );
			assertEquals ( _c + ".getModel() failed.", m, _c.getModel( MockModelList.MOCK_MODEL ) );
			assertTrue ( _c + ".isViewRegistered() failed.", _c.isViewRegistered( MockViewList.MOCK_VIEW ) );
			assertEquals ( _c + ".getView() failed.", v, _c.getView( MockViewList.MOCK_VIEW ) );
			
			m.release();
			v.release();
			var p : MockPlugin = new MockPlugin( "test" );
			m = new MockModel( p, MockModelList.MOCK_MODEL );
			v = new MockView( p, MockViewList.MOCK_VIEW, new MovieClip() );

			_c.setOwner( p );
			assertEquals ( _c + ".getOwner() failed after setOwner() call.", p, _c.getOwner() );
			assertEquals ( _c + ".getLogger() failed after setOwner() call.", PluginDebug.getInstance( p ), _c.getLogger() );
			assertTrue ( _c + ".isModelRegistered() failed after setOwner() call.", _c.isModelRegistered( MockModelList.MOCK_MODEL ) );
			assertEquals ( _c + ".getModel() failed after setOwner() call.", m, _c.getModel( MockModelList.MOCK_MODEL ) );
			assertTrue ( _c + ".isViewRegistered() failed after setOwner() call.", _c.isViewRegistered( MockViewList.MOCK_VIEW ) );
			assertEquals ( _c + ".getView() failed after setOwner() call.", v, _c.getView( MockViewList.MOCK_VIEW ) );
			
			m.release();
			v.release();
		}
		
		public function testErrorHandling() : void
		{
			var errorCaught : Boolean = false;
			
			_cError = new CommandWithErrorHandling();
			var listener : MockCommandListener = new MockCommandListener();
			_cError.addCommandListener( listener );			

			try
			{
				_cError.execute();

			} catch ( e : IllegalArgumentException )
			{
				errorCaught = true;
				assertFalse ( _cError + ".isRunning() returns True after error caught.", _cError.isRunning() );
			}

			assertTrue( _cError + ".execute didn't catch the error.", errorCaught );
			assertEquals( listener + ".onCommandStart hasn't been called as expected", CommandEvent.onCommandStartEVENT, listener.startEventReceived.type );
			assertEquals( listener + ".onCommandEnd hasn't been called as expected", CommandEvent.onCommandEndEVENT, listener.endEventReceived.type );
			
			
			var e : BasicEvent = new BasicEvent( "test" );
			_cError.execute( e );			
			assertEquals ( _cError + ".onExecute() callfailed.", e, _cError.event );
		}
	}
}

import net.pixlib.commands.*;
import net.pixlib.exceptions.IllegalArgumentException;
import net.pixlib.model.AbstractModel;
import net.pixlib.plugin.Plugin;
import net.pixlib.view.AbstractView;

import flash.display.DisplayObject;
import flash.events.Event;

class AsyncMockCommand
	extends AbstractCommand
{
	public var onCommandExecuteCalled 	: Boolean;
	public var onCommandCancelCalled 	: Boolean;

	public function AsyncMockCommand ()
	{
		onCommandExecuteCalled = false;
		onCommandCancelCalled = false;
	}

	override protected function onExecute( e : Event = null ) : void
	{
		onCommandExecuteCalled = true;
		CommandFPS.getInstance().delay( new Delegate( fireCommandEndEvent ) );
	}

	override protected function onCancel() : void
	{
		onCommandCancelCalled = true;
	}
}

class CommandWithErrorHandling
	extends AbstractCommand
{
	public var event : Event;

	override protected function onExecute( e : Event = null ) : void
	{
		event = e;
		
		if ( e == null )
		{ 
			throw new IllegalArgumentException();

		} else
		{
			fireCommandEndEvent();
		}
	}
}

internal class MockModel 
	extends AbstractModel
{
	public function MockModel( owner : Plugin, id : String ) 
	{
		super( owner, id );
	}
}

internal class MockModelList
{
	public static const MOCK_MODEL : String = "mockModel";
}

internal class MockView 
	extends AbstractView
{
	public function MockView( owner : Plugin, id : String, dpo : DisplayObject ) 
	{
		super( owner, id, dpo );
	}
}

internal class MockViewList
{
	public static const MOCK_VIEW : String = "mockView";
}