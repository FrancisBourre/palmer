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
	import net.pixlib.events.BasicEvent;
	import net.pixlib.events.StringEvent;
	import net.pixlib.model.AbstractModel;
	import net.pixlib.plugin.AbstractPlugin;
	import net.pixlib.view.AbstractView;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;

	/**
	 * @author Francis Bourre
	 */
	public class MockPlugin 
		extends AbstractPlugin
	{
		public var s : String;
		
		public var model : AbstractModel;
		public var view : AbstractView;

		public function MockPlugin( s : String, doc : DisplayObjectContainer = null ) 
		{
			this.s = s;
			getController().pushCommandClass( PrivateEventList.onOutputString, Output );
			
			model = new ModelTest( this, ModelList.modelTest );

			if ( doc != null )
			{
				view = new ViewTest( this );
				view.registerView( doc as DisplayObject, ViewList.viewTest );
				view.show( );
				
				model.addListener( view as ViewTest );
			}
			
			firePublicEvent( new BasicEvent("echo") );
		}

		public function testPlugin() : void
		{
			firePrivateEvent( new StringEvent( PrivateEventList.onOutputString, this, s ) );			
			firePublicEvent( new StringEvent( PrivateEventList.onOutputString, this, s ) );
		}
		
		public function echo( e : Event ) : void
		{
			throw new Error( this + ".echo()" );
		}
	}
}

import net.pixlib.model.ModelEvent;
import net.pixlib.commands.AbstractCommand;
import net.pixlib.events.StringEvent;
import net.pixlib.model.AbstractModel;
import net.pixlib.model.ModelListener;
import net.pixlib.plugin.Plugin;
import net.pixlib.view.AbstractView;

import flash.events.Event;
import flash.text.TextField;

internal class Output
	extends AbstractCommand
{
	override protected function onExecute( e : Event = null ) : void
	{
		(getModel( ModelList.modelTest ) as ModelTest).setString( (e as StringEvent).getString() );
	}
}

internal class PrivateEventList
{
	public static const onOutputString : String = "onOutputString";
}

internal class ModelTest 
	extends AbstractModel
{
	public static const onSetStringEVENT : String = "onSetString";

	protected var _s : String;

	public function ModelTest( owner : Plugin, id : String ) 
	{
		super( owner, id );
		
		setListenerType( ModelTestListener );
	}

	public function setString( s : String ) : void
	{
		_s = s;
		notifyChanged( new StringEvent( ModelTest.onSetStringEVENT, this, s ) );
	}
}

internal interface ModelTestListener
	extends ModelListener
{
	function onSetString( e : StringEvent ) : void;
}

internal class ModelList
{
	public static const modelTest : String = "modelTest";
}

internal class ViewTest 
	extends AbstractView
	implements ModelTestListener
{
	protected var _tf : TextField;

	public function ViewTest( owner : Plugin ) 
	{
		super( owner );
	}
	
	override protected function onInitView() : void
	{
		if ( canResolveUI( "tf" ) ) _tf = resolveUI( "tf" ) as TextField;
		super.onInitView();
	}
	
	public function onSetString( e : StringEvent ) : void
	{
		_tf.text = e.getString( );
	}
	
	override public function onInitModel( e : ModelEvent ) : void
	{
	}
	
	override public function onReleaseModel( e : ModelEvent ) : void
	{
	}
}

internal class ViewList
{
	public static const viewTest : String = "viewTest";
}