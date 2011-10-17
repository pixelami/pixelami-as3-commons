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

package org.pixelami.ui.model
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	public class SelectableDataDescriptor extends EventDispatcher implements ISelectableDataDescriptor
	{
		private var selectedItems:Dictionary = new Dictionary(true);
		private var changeHandlers:Dictionary = new Dictionary(true);
		public function SelectableDataDescriptor()
		{
			
		}
		
		public function isSelected(object:*):Boolean
		{
			var selected:Boolean = selectedItems[object];
			if(selected) return true;
			return false;
		}
		
		public function setSelected(object:*, value:Boolean, updateHandler:Boolean=true):void
		{
			if(!value)
			{
				delete selectedItems[object];
			}
			else
			{
				selectedItems[object] = value;
			}
			
			if(updateHandler)
			{
				var handler:Function = changeHandlers[object];
				if(handler != null)
				{
					handler.call();
				}
			}
		}
		
		public function registerSelectionUpdateHandler(object:*,handler:Function):void
		{
			changeHandlers[object] = handler;
		}
		
	}
}