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
	public interface ISelectableDataDescriptor 
	{
		function isSelected(object:*):Boolean;
		
		function setSelected(object:*,value:Boolean,updateHandler:Boolean=true):void;
		
		function registerSelectionUpdateHandler(object:*,handler:Function):void;
		
	}
}