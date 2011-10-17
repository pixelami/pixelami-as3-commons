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
	import mx.collections.ArrayCollection;
	
	import org.pixelami.util.ObjectDescriptor;
	import org.pixelami.util.TypedAttribute;

	public class ObjectComposerPM
	{
		[Bindable]
		public var attributesCollection:ArrayCollection;
		
		private var _object:ObjectDescriptor;

		public function get object():ObjectDescriptor
		{
			return _object;
		}

		public function set object(value:ObjectDescriptor):void
		{
			if(value != object)
			{
				_object = value;
				
				if(_object)
				{
					attributesCollection = new ArrayCollection(_object.getAttributes());
				}
			}
		}
		
		
		
		public function ObjectComposerPM()
		{
			object = new ObjectDescriptor();
		}
		
		public function createNew():void
		{
			var attribute:TypedAttribute = new TypedAttribute();
			attributesCollection.addItem(attribute);
		}
		
		public function removeItemAt(index:int):void
		{
			attributesCollection..removeItemAt(index);
		}
		
		public function dispatchMessage():void
		{
			
		}
	}
}