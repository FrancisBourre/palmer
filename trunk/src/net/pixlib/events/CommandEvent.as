package net.pixlib.events 
{
	import net.pixlib.commands.Command;

	import flash.events.Event;
	
	/**
	 *  Dispatched when command process is beginning.
	 *  
	 *  @eventType com.events.CommandEvent.onCommandStartEVENT
	 */
	[Event(name="onCommandStart", type="com.events.CommandEvent.onCommandStartEVENT")]

	/**
	 *  Dispatched when command process is over.
	 *  
	 *  @eventType com.events.CommandEvent.onCommandEndEVENT
	 */
	[Event(name="onCommandEnd", type="com.events.CommandEvent.onCommandEndEVENT")]

	/**
	 * An event broadcasted by a Command object.
	 * 
	 * @author 	Francis Bourre
	 * @see		BasicEvent
	 */
	public class CommandEvent 
		extends BasicEvent
	{
		static public const onCommandStartEVENT : String 	= "onCommandStart";
		static public const onCommandEndEVENT : String 		= "onCommandEnd";

		/**
		 * Creates a new <code>CommandEvent</code> object.
		 * 
		 * @param	type	name of the event type
		 * @param	target	target of this event
		 */
		public function CommandEvent( type : String, target : Object = null, bubbles : Boolean = false, cancelable : Boolean = false )
		{
			super ( type, target, bubbles, cancelable );
		}
		
		/**
		 * Returns the <code>Command</code> target.
		 * 
		 * @return	the command which broadcasted this event.
		 */
		public function getCommand() : Command
		{
			return target as Command;
		}
		
		/**
		 * Clone the event
		 * 
		 * @return	a clone of the event
		 */
		override public function clone() : Event
		{
			return new BooleanEvent( type, target );
		}
	}
}
