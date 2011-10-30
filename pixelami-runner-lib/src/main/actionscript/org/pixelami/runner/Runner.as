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

package org.pixelami.runner
{
	import flash.display.LoaderInfo;
	
	import org.pixelami.runner.impl.RunnerImpl;


	public class Runner
	{
		
		
		private static var _loaderInfo:LoaderInfo;
		internal static function get loaderInfo():LoaderInfo
		{
			if(!_loaderInfo) _loaderInfo = LoaderInfo.getLoaderInfoByDefinition(new Object());
			return _loaderInfo;
		}
		
		private static var _instance:IRunner;
		public static function get instance():IRunner
		{
			if(!_instance) _instance = new org.pixelami.runner.impl.RunnerImpl(loaderInfo);
			return _instance;
		}
		
	}
}