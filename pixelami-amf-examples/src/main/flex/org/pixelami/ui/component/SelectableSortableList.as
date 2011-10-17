package org.pixelami.ui.component
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.menuClasses.IMenuDataDescriptor;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	import org.pixelami.ui.event.FilterEvent;
	import org.pixelami.ui.model.ISelectableDataDescriptor;
	import org.pixelami.ui.model.SelectableDataDescriptor;
	import org.pixelami.ui.renderer.CheckBoxItemRenderer;
	
	import spark.components.Button;
	import spark.components.CheckBox;
	import spark.components.List;
	import spark.components.SkinnableContainer;
	import spark.events.IndexChangeEvent;
	import spark.skins.spark.DefaultItemRenderer;
	
	[Event(name="change", type="spark.events.IndexChangeEvent")]
	
	public class SelectableSortableList extends SkinnableContainer
	{
		[SkinPart('required=true')]
		public var list:List;
		
		[SkinPart('required=true')]
		public var selectAllChkBox:CheckBox; 
		
		[SkinPart('required=true')]
		public var sortButton:Button; 
		
		[SkinPart]
		public var filterInput:FilterInput;
		
		public var labelFunction:Function;
		
		public var sortField:String = "name";
		
		public var itemRenderer:IFactory = new ClassFactory(CheckBoxItemRenderer);
		
		private var _dataProvider:ArrayCollection;
		[Bindable]
		public function set dataProvider(value:IList):void
		{
			_dataProvider = ArrayCollection(value);
			preSelectAllIndices = new Dictionary();
			
			_dataProvider.filterFunction = filterFunc;
		}
		
		public function get dataProvider():IList
		{
			return _dataProvider;
		}
		
		public var dataDescriptor:ISelectableDataDescriptor = new SelectableDataDescriptor();
		
		private var preSelectAllIndices:Dictionary;
		
		
		public function SelectableSortableList()
		{
			super();
		}
		
		override protected function initializationComplete():void
		{
			super.initializationComplete();
			var properties:Object = {};
			properties.dataDescriptor = dataDescriptor;
			ClassFactory(itemRenderer).properties = properties;
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if(instance == list)
			{
				list.itemRenderer = itemRenderer;
				list.labelFunction = labelFunction;
				list.addEventListener(IndexChangeEvent.CHANGE,list_indexChangeHandler);
			}
			
			if(instance == selectAllChkBox)
			{
				selectAllChkBox.addEventListener(MouseEvent.CLICK,selectAllChkBox_clickHandler);
			}
			
			if(instance == sortButton)
			{
				sortButton.addEventListener(MouseEvent.CLICK,sortButton_clickHandler);
			}
			
			if(instance == filterInput)
			{
				filterInput.addEventListener(FilterEvent.APPLY,filterInput_applyHandler);
			}
		}
		
		
		
		
		protected function selectAllChkBox_clickHandler(event:MouseEvent):void
		{
			var o:Object;
			trace(event);
			if(event.target.selected)
			{
				for each(o in dataProvider)
				{
					if(dataDescriptor.isSelected(o))
						preSelectAllIndices[o] = true;
					else
						preSelectAllIndices[o] = false;
				}
				for each(o in dataProvider)
				{
					dataDescriptor.setSelected(o, true);
				}
				
			}
			else
			{
				for(o in preSelectAllIndices)
				{
					dataDescriptor.setSelected(o, preSelectAllIndices[o]);
				}
			}
		}
		
		protected function sortButton_clickHandler(event:MouseEvent):void
		{
			var sort:Sort = new Sort();
			sort.fields = [new SortField(sortField,true)];
			ArrayCollection(dataProvider).sort = sort;
			ArrayCollection(dataProvider).refresh();
		}
		
		protected function list_indexChangeHandler(event:IndexChangeEvent):void
		{
			dispatchEvent(event);	
		}
		
		protected function filterInput_applyHandler(event:Event):void
		{
			trace("filterInput.input.text: "+filterInput.input.text);
			trace("filterInput.included: "+filterInput.included);
			pattern = new RegExp(filterInput.input.text);
			_dataProvider.refresh();
		}
		
		private var pattern:RegExp;
		protected function filterFunc(obj:Object):Boolean
		{
			if(!filterInput || filterInput.input.text=="") return true;
			
			// get the index of the match if any
			var idx:int = String(obj.name).search(pattern);
			
			// create an int of -1 or 1 based on whether or not there was a match
			var foundMatch:int = idx > -1 ? 1 : -1;
			
			// multiply the include / exclude (1 or -1) by the foundMatch value.
			// if >1 we need to include the matched item - if <1 we need to exclude the matched item
			if(foundMatch * filterInput.included > 0) return true;
			return false;
		}
		
	}
}