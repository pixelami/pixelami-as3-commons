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

package org.pixelami.ui.renderer
{
	import flash.events.Event;
	
	import org.pixelami.ui.model.ISelectableDataDescriptor;
	
	import spark.components.supportClasses.ItemRenderer;
	
	public class SelectableItemRenderer extends ItemRenderer
	{
		public function SelectableItemRenderer()
		{
			super();
		}
		
		private var _itemSelected:Boolean;
		[Bindable("itemSelectionChange")]
		public function set itemSelected(value:Boolean):void
		{
			if(itemSelected != value)
			{
				_itemSelected = value;
				dataDescriptor.setSelected(data,value,false);
				dispatchEvent(new Event("itemSelectionChange"));
			}
		}
		
		public function get itemSelected():Boolean
		{
			//_itemSelected = dataDescriptor.isSelected( data );
			return _itemSelected;
		}
		
		private var _dataDescriptor:ISelectableDataDescriptor

		public function get dataDescriptor():ISelectableDataDescriptor
		{
			return _dataDescriptor;
		}

		public function set dataDescriptor(value:ISelectableDataDescriptor):void
		{
			_dataDescriptor = value;
		}
		
		public function invalidate():void
		{
			_itemSelected = dataDescriptor.isSelected(data);
			dispatchEvent(new Event("itemSelectionChange"));
			trace("selected",selected);
		}
		
		override public function set data(value:Object):void
		{
			

			super.data = value;
			
			if(dataDescriptor)
			{
				_itemSelected = dataDescriptor.isSelected(data);
				dispatchEvent(new Event("itemSelectionChange"));
				dataDescriptor.registerSelectionUpdateHandler(data,invalidate);
			}
		}

	}
}