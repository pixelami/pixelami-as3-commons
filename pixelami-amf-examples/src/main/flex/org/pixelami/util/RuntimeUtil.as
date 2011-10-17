////////////////////////////////////////////////////////////////////////////////
//
//  pixelami.com
//  Copyright 2011 Original Authors
//  All Rights Reserved.
//
//  NOTICE: Pixelami permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package org.pixelami.util
{
	import flash.display.LoaderInfo;
	import flash.utils.Dictionary;
	
	import mx.managers.ISystemManager;
	
	import ru.etcs.utils.getDefinitionNames;

	public class RuntimeUtil
	{
		public function RuntimeUtil()
		{
		}
		
		public static function getLoadedClassDefinitions():Array
		{
			var allDefinitions:Array = [];
			var loaderInfo:LoaderInfo = LoaderInfo.getLoaderInfoByDefinition(Object);
			var preloadedRSLs:Dictionary = ISystemManager(loaderInfo.content).preloadedRSLs;
			for(var key:* in preloadedRSLs)
			{
				allDefinitions = allDefinitions.concat(getDefinitionNames(key));
			}
			allDefinitions = allDefinitions.concat(getDefinitionNames(loaderInfo));
			return allDefinitions;
		}
	}
}