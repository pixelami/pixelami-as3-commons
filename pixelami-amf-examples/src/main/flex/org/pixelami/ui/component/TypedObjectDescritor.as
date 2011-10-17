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

package org.pixelami.ui.component
{
	import mx.collections.IList;
	
	import org.pixelami.component.IMenuDataDescriptor;
	
	public class TypedObjectDescritor implements IMenuDataDescriptor
	{
		public function TypedObjectDescritor()
		{
		}
		
		public function getChildren(object:*):IList
		{
			return null;
		}
		
		public function hasChildren(object:*):Boolean
		{
			return false;
		}
		
		public function isSelectable(object:*):Boolean
		{
			return false;
		}
	}
}