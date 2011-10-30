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

	public class SaySomethingNestedProcess extends EventDispatcher
	{
		public function SaySomethingNestedProcess()
		{
			super(null);
		}
		
		public function start(count:uint = 100):void
		{
			while (--count > 0)
			{
				run(say,["something",count]);
			}
			run(complete,null,this);
		}
		
		public function say(string:String,n:Object):void
		{
			trace("say:",string,n);
			var a:String = string;
			for(var i:uint = 0; i < 10; i++)
			{
				var fn:Function = function(n:uint):void {
					trace("inner",n);
				};
				run(fn,[i]);
			}
		}
		
		public function complete():void
		{
			trace("COMPLETE");
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}