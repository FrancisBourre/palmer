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
import flexunit.framework.TestSuite;

import mx.core.Application;

import net.pixlib.collections.*;import net.pixlib.commands.*;
import net.pixlib.encoding.*;
import net.pixlib.events.*;import net.pixlib.ioc.*;
import net.pixlib.log.*;
import net.pixlib.structures.*;
import net.pixlib.utils.*;

private function onCreationComplete():void
{
	Logger.getInstance().setLevel( LogLevel.ALL );
	//Logger.getInstance().addLogListener( LuminicBoxLayout.getInstance() );
	//Logger.getInstance().addLogListener( SosMaxLayout.getInstance() );

	testRunner.test = createSuite();
	testRunner.startTest();	
}

private function createSuite() : TestSuite
{
	var ts:TestSuite = new TestSuite();

	// com.bourre.collection
	ts.addTestSuite( HashMapTest );	ts.addTestSuite( QueueTest );	ts.addTestSuite( SetTest );	ts.addTestSuite( StackTest );
	ts.addTestSuite( WeakCollectionTest );

	// com.bourre.commands
	ts.addTestSuite( AbstractCommandTest );	ts.addTestSuite( BatchTest );	ts.addTestSuite( CommandFPSTest );	ts.addTestSuite( CommandMSTest );	ts.addTestSuite( DelegateTest );	ts.addTestSuite( FrontControllerTest );
	
	// com.bourre.encoding
	ts.addTestSuite( XMLToObjectDeserializerTest );

	// com.bourre.events
	ts.addTestSuite( BasicEventTest );	ts.addTestSuite( BooleanEventTest );	ts.addTestSuite( ChannelBroadcasterTest );	ts.addTestSuite( EventBroadcasterTest );	ts.addTestSuite( EventCallbackAdapterTest );	ts.addTestSuite( EventChannelTest );	ts.addTestSuite( NumberEventTest );	ts.addTestSuite( StringEventTest );

	// com.bourre.ioc
	ts.addTestSuite( IOCTest );

	// com.bourre.log
	ts.addTestSuite( BasicStringifierTest );
	ts.addTestSuite( LogEventTest );
	ts.addTestSuite( LoggerTest );
	ts.addTestSuite( LogLevelTest );
	
	// com.bourre.structures
	ts.addTestSuite( GridTest );
	ts.addTestSuite( RangeTest );
	
	// com.bourre.utils
	ts.addTestSuite( ClassUtilsTest );

	return ts;
}