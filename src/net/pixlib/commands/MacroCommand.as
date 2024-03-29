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
	/**
	 * A macro command wraps many commands execution in a single 
	 * <code>execute</code> call. The <code>MacroCommand</code>
	 * doesn't guarantee the order of commands to be executed,
	 * except if a concret implementation provide a guarantee
	 * over the order of commands.
	 * <p>
	 * Some implementations can choose to allow more than one 
	 * instance of the same command in its commands list. In
	 * that case the macro command should follow the rules defines
	 * by the <code>Collection</code> interface about duplicate
	 * entries.
	 * </p><p>
	 * Some implementation can stretch the execution of its sub-commands
	 * outside of the <code>execute</code> call, in that case the concret
	 * implementation had better tom also implements the <code>ASyncCommand</code>
	 * interface to provide a feedback for its execution end.
	 * </p>  
	 * @author	Francis Bourre
	 * @see		net.pixlib.collection.Collection
	 */
	public interface MacroCommand 
		extends Command
	{
		/**
		 * Adds the passed-in command to this macro command.
		 * 
		 * @param	command	command to add in this macro command
		 * @return	<code>true</code> if the command have been
		 * 			succesfully added. The <code>addCommand</code>
		 * 			ensure that the command exist in the macro
		 * 			command at the end of the call
		 */
		function addCommand( command : Command ) : Boolean;
		
		/**
		 * Removes the passed-in command from this macro command.
		 * 
		 * @param	command	command to remove from this macro command
		 * @return	<code>true</code> if the command have been
		 * 			succesfully removed
		 */
		function removeCommand( command : Command ) : Boolean;
	}
}