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

	/**
	 * @author Cédric Néhémie
	 */
	public class RunnableTest 
		extends TestCase 
	{
		private var _oRunnable : Runnable;

		public function RunnableTest( methodName : String = null )
		{
			super( methodName );
		}

		protected function setRunnableObject( runnable : Runnable ) : void
		{
			_oRunnable = runnable;
		}

		public function testRunnableRun() : void
		{
			_oRunnable.run( );
			
			assertTrue( _oRunnable + ".run() failed to change its running state to true", _oRunnable.isRunning( ) );
			
			var b : Boolean = false;
			
			try
			{
				_oRunnable.run( );
			}
			catch( e : Error )
			{
				b = true;
			}
			assertTrue( _oRunnable + " doesn't throw an exception when attempting to run a running operation", b );
		}
	}
}
