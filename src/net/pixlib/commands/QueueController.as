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
	import net.pixlib.commands.Command;
	import net.pixlib.commands.FrontController;
	import net.pixlib.events.CommandEvent;
	import net.pixlib.plugin.Plugin;

	import flash.events.Event;
	import flash.utils.Dictionary;

	/**
	 * <code>QueueController</code> enqueues requests 
	 * of the same type and process them one by one at 
	 * the same time. It ensures that two requests of 
	 * the same type can't be processed at the same time.
	 * @author	Francis Bourre
	 * @see FrontController
	 */
	public class QueueController 
		extends FrontController
	{
		protected var _dRunningCommandMap 		: Dictionary;
		protected var _dCommandCollectionMap 	: Dictionary;
		protected var _dCommandMap 				: Dictionary;
		
		public function QueueController(  owner : Plugin = null  ) 
		{
			super( owner );

			_dRunningCommandMap 	= new Dictionary( false );
			_dCommandCollectionMap 	= new Dictionary( false );
			_dCommandMap			= new Dictionary( false );
		}
		
		public function hasCommandQueued( eventType : String ) : Boolean
		{
			return getCommandCollection( eventType ).length > 0;
		}
		
		public function isRunning( eventType : String ) : Boolean
		{
			return _dRunningCommandMap[ eventType ];
		}

		override public function onCommandEnd ( e : CommandEvent ) : void
		{
			var eventType 	: String 	= _dCommandMap[ e.getCommand() ] as String;
			
			super.onCommandEnd( e );
			
			if ( hasCommandQueued( eventType ) )
			{
				executeNextCommand( eventType );

			} else
			{
				_dRunningCommandMap[ eventType ] = false;
			}
		}

		/** @private */
		override protected function executeCommand( event : Event, cmd : Command  ) : void
		{
			getCommandCollection( event.type ).push( new SequencerItem( event, cmd ) );
			if ( !isRunning( event.type ) ) executeNextCommand( event.type );
		}
		
		/** @private */
		protected function getCommandCollection( eventType : String ) : Array
		{
			if ( !(_dCommandCollectionMap[eventType] is Array) ) _dCommandCollectionMap[eventType] = new Array();
			return _dCommandCollectionMap[eventType];
		}
		
		/** @private */
		protected function executeNextCommand( eventType : String ) : void
		{
			_dRunningCommandMap[ eventType ] = true;

			var item : SequencerItem = getCommandCollection(eventType).shift() as SequencerItem;
			_dCommandMap[ item.commandItem ] = eventType;

			super.executeCommand( item.eventItem, item.commandItem );
		}
	}
}

import net.pixlib.commands.Command;

import flash.events.Event;

internal class SequencerItem
{
	public var eventItem 	: Event;
	public var commandItem 	: Command;
	public function SequencerItem( eventItem : Event, commandItem : Command ) 
	{
		this.eventItem 		= eventItem;
		this.commandItem 	= commandItem;
	}
}