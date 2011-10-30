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

package org.pixelami.runner.impl
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import mx.utils.ObjectUtil;
	
	import org.pixelami.runner.IRunner;
	import org.pixelami.runner.MethodInvokation;
	

	public class RunnerImpl implements IRunner
	{
		private var loaderInfo:LoaderInfo;
		
		private var currentInvokation:MethodInvokation;
		
		public function RunnerImpl(loaderInfo:LoaderInfo)
		{
			this.loaderInfo = loaderInfo;
			var mspf:int = calculateMSPerFrame();
			maxExecutionTime = mspf - (mspf * .39);
			//log("maxExecutionTime",maxExecutionTime);
		}
		
		public function calculateMSPerFrame():int
		{
			return 1000 / loaderInfo.content.stage.frameRate;
		}
		
		private var frameCounter:uint;
		private var running:Boolean;
		
		public function run(method:Function, args:Array = null, scope:Object = null):void
		{
			if(!currentInvokation)
			{
				currentInvokation = MethodInvokation.getMethodInvokation(function():void{
					trace("root invokation executed");
				});
			}
			
			currentInvokation.addChildInvokation(MethodInvokation.getMethodInvokation(method, args, scope));
			
			if(!running)
			{
				running = true;
				frameCounter = 0;
				frameStart = getTimer();
				loaderInfo.content.addEventListener(Event.ENTER_FRAME,onEnterFrame);
			}
		}
		
		private var previousFrameDuration:int = 0;
		private var maxExecutionTime:int = 1;
		private var frameStart:int = 0;
		private function onEnterFrame(event:Event):void
		{
			var t:uint = getTimer();
			previousFrameDuration = t - frameStart;
			log("previousFrameDuration",previousFrameDuration);
			frameStart = t;
			
			var lastExecutionDuration:int = 0;
			while(running && getTimer() - frameStart < maxExecutionTime - lastExecutionDuration)
			{
				t = getTimer();
				processQueue();
				lastExecutionDuration = getTimer() - t;
			}
		}
		
		public function processQueue():void
		{
			currentInvokation = currentInvokation.getNextInvokation();
			
			if(!currentInvokation) 
			{
				if(loaderInfo.content)
				{
					loaderInfo.content.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
				}
				running = false;
				return;
			}
			log(currentInvokation);
			currentInvokation.execute();
		}
		
		protected function log(...params):void
		{
			trace.apply(this,params);
		}
	}
}