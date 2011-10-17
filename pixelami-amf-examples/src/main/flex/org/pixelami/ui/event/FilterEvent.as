
package org.pixelami.ui.event
{
	
	
	import flash.events.Event;
	
	public class FilterEvent extends Event
	{
		static public var APPLY:String = "apply";
		
		public function FilterEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}