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
	 
package com.bourre.load
{
	import com.bourre.load.AbstractLoader;
	import com.bourre.load.strategy.LoadStrategy;
	import com.bourre.load.strategy.LoaderStrategy;
	
	import flash.system.ApplicationDomain;	
	
	/**
	 * @author Aigret Axel
	 * @version 1.0
	 */
	public class SoundLoader extends AbstractLoader
	{
		//--------------------------------------------------------------------
		// Public API
		//--------------------------------------------------------------------
		
		public function SoundLoader( strategy : LoadStrategy = null )
		{
			super(strategy );
		}
		
		public function getApplicationDomain() : ApplicationDomain
		{
			return ( getStrategy() as LoaderStrategy ).getContentLoaderInfo().applicationDomain;
		}
	}
}