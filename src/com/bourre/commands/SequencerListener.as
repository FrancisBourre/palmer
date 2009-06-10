package com.bourre.commands 
{
	import flash.events.Event;

	/**
	 * Interface for objects which want to be notified of execution 
	 * of a Sequencer.
	 * 
	 * @see Sequencer
	 * 
	 * @author Romain Ecarnot
	 */
	public interface SequencerListener extends CommandListener
	{
		/**
		 * Triggered when sequencer starts execution.
		 * 
		 * @param event	ObjectEvent data with sequencer owner as event target 
		 */
		function onSequencerStart( event : Event ) : void;
		
		/**
		 * Triggered when new command is ready to be executed.
		 * 
		 * @param event	ObjectEvent data with sequencer owner as event target 
		 * 				and command ready to be executed 
		 * 				in <code>ObjectEvent.getObject()</code>
		 */
		function onSequencerProgress( event : Event = null ) : void;
		
		/**
		 * Triggered when sequencer ends execution.
		 * 
		 * <p>Triggered juste before the <code>onCommandEnd</code>.</p>
		 * 
		 * @param event	Event data with sequencer owner as event target
		 */
		function onSequencerEnd( event : Event ) : void;
	}
}
