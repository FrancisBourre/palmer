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
package net.pixlib.ioc 
{
	import flexunit.framework.TestCase;

	import net.pixlib.core.CoreFactory;
	import net.pixlib.events.Broadcaster;
	import net.pixlib.ioc.assembler.locator.ChannelListenerExpert;
	import net.pixlib.ioc.assembler.locator.ConstructorExpert;
	import net.pixlib.ioc.assembler.locator.MethodExpert;
	import net.pixlib.ioc.assembler.locator.PropertyExpert;
	import net.pixlib.ioc.load.ApplicationLoader;
	import net.pixlib.ioc.load.ApplicationLoaderEvent;
	import net.pixlib.load.LoaderLocator;
	import net.pixlib.log.Logger;
	import net.pixlib.structures.Dimension;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;

	/**
	 * @author Francis Bourre
	 */
	public class IOCTest 
		extends TestCase
	{
		private static var _c : Class = MockPlugin;

		protected var _al : ApplicationLoader;
		protected var _xml : XML;
		protected var _bf : CoreFactory;

		public override function setUp():void
		{			PropertyExpert.release();			ConstructorExpert.release();			ChannelListenerExpert.release();			MethodExpert.release();

			CoreFactory.release();
			LoaderLocator.getInstance().release();

			_bf = CoreFactory.getInstance();
			_al = new ApplicationLoader( new MovieClip() );
			
			_xml = 

			<beans>
				<root id="myRoot">
					<test id="container" type="flash.display.MovieClip">
						<test id="sprite" type="flash.display.Sprite"/>
						<test id="text" type="flash.text.TextField"/>
					</test>
				</root>
				
				<test id="mockPlugin" type="net.pixlib.ioc.MockPlugin">
					<argument ref="stringTest"/>
					<argument ref="container"/>
				</test>

				<test id="obj" type="Object">
					<property name="p1" value="hello p1"/>
					<property name="p2" ref="stringTest"/>
					<property name="p3" ref="numberTest"/>
					<property name="p4" ref="booleanTest"/>
					<property name="p5" ref="instanceTest"/>
					<property name="p6" ref="objChild"/>
				</test>
				
				<test id="objChild" type="Object">
					<property name="prop" value="world"/>
				</test>

				<test id="collection" type="Array">
					<argument ref="stringTest"/>
					<argument ref="numberTest"/>
					<argument ref="booleanTest"/>
					<argument ref="instanceTest"/>
				</test>

				<test id="stringTest" value="hello"/>
				<test id="numberTest" type="Number" value="13"/>
				<test id="booleanTest" type="Boolean" value="true"/>

				<test id="instanceTest" type="net.pixlib.ioc.MockClass"/>
				<test id="logger" type="net.pixlib.log.Logger" singleton-access="getInstance"/>
				<test id="broadcaster" type="net.pixlib.events.ApplicationBroadcaster" factory="getChannelDispatcher" singleton-access="getInstance"/>

				<test id="dimensionClass" type="Class">
					<argument value="net.pixlib.structures.Dimension"/>
				</test>
			</beans>;
		}

		public function testOnApplicationObjectsBuilt() : void
		{
			_al.addEventListener( ApplicationLoaderEvent.onApplicationObjectsBuiltEVENT, addAsync( onObjectsBuilt, 5000 ) );
			_al.parseContext( _xml );
		}
		
		public function onObjectsBuilt( e : Event ) : void
		{
			assertTrue( "ApplicationLoaderEvent.onApplicationObjectsBuiltEVENT fails", true );
	
			assertNotNull( "ApplicationLoader constructor returns null", _al );
			assertEquals( "build Sprite fails", true, _bf.locate( "container" ) is MovieClip );
			assertEquals( "build Sprite fails", true, _bf.locate( "sprite" ) is Sprite );
			assertEquals( "build Sprite fails", true, _bf.locate( "text" ) is TextField );
			assertEquals( "build String fails", "hello", _bf.locate( "stringTest" ) );
			assertEquals( "build Number fails", 13, _bf.locate( "numberTest" ) );			assertEquals( "build Boolean fails", true, _bf.locate( "booleanTest" ) );
			assertTrue( "build 'com.bourre.ioc.MockClass' instance fails", _bf.locate( "instanceTest" ) is MockClass );
			assertTrue( "build 'com.bourre.log.Logger.getInstance()' instance fails", _bf.locate( "logger" ) is Logger );
			assertTrue( "build 'com.bourre.events.ApplicationBroadcaster.getInstance().getChannelDispatcher()' instance fails", _bf.locate( "broadcaster" ) is Broadcaster );
		
			var a : Array = _bf.locate( "collection" ) as Array;
			assertEquals( "collection[ 0 ] as String ref fails", "hello", a[ 0 ] );
			assertEquals( "collection[ 1 ] as Number ref fails", 13, a[ 1 ] );
			assertEquals( "collection[ 2 ] as Boolean ref fails", true, a[ 2 ] );
			assertTrue( "collection[ 3 ] as 'com.bourre.ioc.MockClass' instance ref fails", a[ 3 ] );
			
			var o : Object = _bf.locate( "obj" ) as Object;
			assertEquals( "obj.p1 as String property fails", "hello p1", o.p1 );
			assertEquals( "obj.p2 as String ref fails", "hello", o.p2 );
			assertEquals( "obj.p3 as Number ref fails", 13, o.p3 );
			assertEquals( "obj.p4 as Boolean ref fails", true, o.p4 );
			assertTrue( "obj.p5 as 'com.bourre.ioc.MockClass' instance ref fails", o.p5 is MockClass );			assertEquals( "obj.p6 as 'obj.objChild.prop' ref fails", "world", o.p6.prop );
			assertEquals( "build 'com.bourre.structures.Dimension' class fails", _bf.locate( "dimensionClass" ), Dimension );

			assertTrue( "build 'com.bourre.ioc.MockPlugin' instance fails", _bf.locate( "mockPlugin" ) is MockPlugin );		}	}}