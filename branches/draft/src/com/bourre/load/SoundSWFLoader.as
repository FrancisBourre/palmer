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
	import com.bourre.exceptions.NullPointerException;
	import com.bourre.load.SoundLoader;
	import com.bourre.load.strategy.LoaderStrategy;
	import com.bourre.log.PalmerDebug;

	import flash.display.DisplayObjectContainer;
	import flash.display.LoaderInfo;
	import flash.media.Sound;

	/**
	 * @author Aigret Axel
	 * @version 1.0
	 */
	public class SoundSWFLoader extends SoundLoader
	{
	
		public function SoundSWFLoader(  name : String = null   )
		{
			super( new LoaderStrategy() );
			if( name != null ) setName( name ) ;
		
		}
		
		public function getSound( sLinkageId : String ) : Sound
		{
			var clazz : Class;
			try
			{
				clazz = getApplicationDomain().getDefinition( sLinkageId ) as Class;
			} catch ( e : Error )
			{
				PalmerDebug.ERROR( this+".getSound("+sLinkageId+") failed, '" + sLinkageId + "' class can't be found in specified SoundFactory application domain");
				throw new NullPointerException(this + ".getSound("+sLinkageId+") failed, '" + sLinkageId + "' class can't be found in specified SoundFactory application domain") ;
			}
				
			return new clazz() ;	
		}
		
		/**
		 * Returns a LoaderInfo object corresponding to the object being loaded.
		 * 
		 * @return A LoaderInfo object corresponding to the object being loaded.
		 */
		public function getContentLoaderInfo() : LoaderInfo
		{
			return LoaderStrategy( getStrategy() ).getContentLoaderInfo();
		}
		
		static public function getSoundInSWF( d : DisplayObjectContainer , sLinkageId : String) : Sound
		{
			var clazz : Class;
			try
			{
				clazz = d.loaderInfo.applicationDomain.getDefinition( sLinkageId ) as Class;
			} catch ( e : Error )
			{
				PalmerDebug.ERROR("com.bourre.media.sound.getSoundInSWF("+sLinkageId+") failed, '" + sLinkageId + "' class can't be found in specified SoundFactory application domain");
				throw new NullPointerException("com.bourre.media.sound.getSoundInSWF"+sLinkageId+") failed, '" + sLinkageId + "' class can't be found in specified SoundFactory application domain") ;
			}
				
			return new clazz() ;	
		}
	}
}