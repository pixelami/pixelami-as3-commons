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
	import flash.events.Event;
	import flash.utils.getTimer;
	

	public class RunnerImpl implements IRunner
	{
		private var loaderInfo:LoaderInfo;
		
		public function RunnerImpl(loaderInfo:LoaderInfo)
		{
			this.loaderInfo = loaderInfo;
			var mspf:int = calculateMSPerFrame();
			maxExecutionTime = mspf - (mspf * .39);
			//trace("maxExecutionTime",maxExecutionTime);
		}
		
		
		
		public function calculateMSPerFrame():int
		{
			return 1000 / loaderInfo.content.stage.frameRate;
		}
		
		private var invokationQueue:Vector.<MethodInvokation> = new Vector.<MethodInvokation>();

		private var frameCounter:uint;
		private var running:Boolean;
		
		public function run(method:Function, args:Array = null, scope:Object = null):void
		{
			invokationQueue.push(MethodInvokation.getMethodInvokation(method, args, scope));
			
			if(!running)
			{
				trace("invokationQueue.length",invokationQueue.length);
				// start processing
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
			log("invokationQueue.length",invokationQueue.length);
			frameStart = t;
			
			var lastExecutionDuration:int = 0;
			while(running && getTimer() - frameStart < maxExecutionTime - lastExecutionDuration)
			//while(getTimer() - frameStart < previousFrameDuration - lastExecutionDuration)
			{
				t = getTimer();
				processQueue();
				lastExecutionDuration = getTimer() - t;
			}
		}
		
		public function processQueue():void
		{
			var invokation:MethodInvokation = invokationQueue.shift();
			//log(invokation);
			invokation.execute();
			invokation.destroy();
			
			if(invokationQueue.length == 1)
			{
				trace("loaderInfo.content",loaderInfo.content);
				if(loaderInfo.content)
				{
					loaderInfo.content.removeEventListener(Event.ENTER_FRAME,onEnterFrame);
				}
				
				
				invokation = invokationQueue.shift();
				log("final invocation",invokation);
				invokation.execute();
				invokation.destroy();
				
				running = false;
			}
		}
		
		protected function log(...params):void
		{
			trace.apply(this,params);
		}
	}
}