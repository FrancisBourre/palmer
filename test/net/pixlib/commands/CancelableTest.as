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
	 * @author Cédric Néhémie
	 */
	public class CancelableTest 
		extends RunnableTest 
	{
		private var _oCancelable : Cancelable;

		public function CancelableTest(methodName : String = null)
		{
			super( methodName );
		}		

		protected function setCancelableObject( o : Cancelable ) : void
		{
			_oCancelable = o;
		}		

		public function testCancelableCancel() : void
		{
			_oCancelable.run( );
			
			assertTrue( _oCancelable + ".run() doesn't change its running state to true", _oCancelable.isRunning( ) );
			
			_oCancelable.cancel( );
			
			assertFalse( _oCancelable + ".cancel() doesn't change its running state to false", _oCancelable.isRunning( ) );
			
			var b : Boolean = false;
			try
			{
				_oCancelable.cancel( );
			}
			catch( e : Error )
			{
				b = true;
			}
			assertTrue( _oCancelable + ".cancel() doesn't throw an exception when attempting to cancel a previously cancelled operation", b );
			
			b = false;
			try
			{
				_oCancelable.run( );
			}
			catch( e : Error )
			{
				b = true;
			}
			assertTrue( _oCancelable + ".run() doesn't throw an exception when attempting to run a cancelled operation", b );
		}
	}
}
