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
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class SaySomethingProcess extends EventDispatcher
	{
		public function SaySomethingProcess()
		{
			super(null);
		}
		
		public function start(count:uint = 1000):void
		{
			while (--count > 0)
			{
				run(say,["something"]);
			}
			//trace("adding complete callback");
			run(complete,null,this);
		}
		
		public function say(string:String):void
		{
			var a:String = string;
		}
		
		public function complete():void
		{
			trace("COMPLETE");
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}